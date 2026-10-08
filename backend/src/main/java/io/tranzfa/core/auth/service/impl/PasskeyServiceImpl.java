package io.tranzfa.core.auth.service.impl;

import io.tranzfa.core.auth.dto.PasskeyChallengeResponse;
import io.tranzfa.core.auth.dto.PasskeyDeviceResponse;
import io.tranzfa.core.auth.dto.PasskeyRegisterRequest;
import io.tranzfa.core.auth.model.entity.Identity;
import io.tranzfa.core.auth.model.entity.PasskeyCredential;
import io.tranzfa.core.auth.model.enums.IdentityType;
import io.tranzfa.core.auth.repository.PasskeyCredentialRepository;
import io.tranzfa.core.auth.service.AuthHelper;
import io.tranzfa.core.auth.service.PasskeyService;
import io.tranzfa.core.auth.provider.WebAuthnProvider;
import io.tranzfa.core.auth.provider.dto.WebAuthnAssertionChallenge;
import io.tranzfa.core.auth.provider.dto.WebAuthnRegistrationChallenge;
import io.tranzfa.core.auth.provider.dto.WebAuthnRegistrationResult;
import io.tranzfa.core.common.exception.ConflictException;
import io.tranzfa.core.common.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class PasskeyServiceImpl implements PasskeyService {

    private final PasskeyCredentialRepository passkeyCredentialRepository;
    private final WebAuthnProvider webAuthnProvider;

    @Override
    public PasskeyChallengeResponse generateRegisterChallenge(Identity identity) {
        WebAuthnRegistrationChallenge challenge = webAuthnProvider.startRegistration(identity);
        log.info("Generated FIDO2 registration challenge for identity ID: {}", identity.getId());

        return PasskeyChallengeResponse.builder()
                .challenge(challenge.getChallenge())
                .rpId(challenge.getRpId())
                .userId(challenge.getUserId())
                .timeoutSeconds(challenge.getTimeoutSeconds())
                .optionsJson(challenge.getOptionsJson())
                .build();
    }

    @Override
    @Transactional
    public PasskeyDeviceResponse registerPasskey(Identity identity, PasskeyRegisterRequest request) {
        WebAuthnRegistrationResult result = webAuthnProvider.finishRegistration(identity, request);
        String credId = result.getCredentialId();

        if (passkeyCredentialRepository.findByCredentialId(credId).isPresent()) {
            throw new ConflictException("A biometric passkey with this credential ID is already registered.");
        }

        PasskeyCredential credential = PasskeyCredential.builder()
                .identity(identity)
                .credentialId(credId)
                .publicKey(result.getPublicKey())
                .deviceId(result.getDeviceId())
                .deviceName(result.getDeviceName() != null ? result.getDeviceName() : "Mobile Device")
                .signCount(result.getSignCount())
                .build();

        PasskeyCredential saved = passkeyCredentialRepository.save(credential);
        log.info("Successfully registered biometric passkey [{}] on device [{}] for identity ID: {}",
                credId, request.getDeviceId(), identity.getId());

        return mapToDeviceResponse(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public PasskeyChallengeResponse generateLoginChallenge(String identifier) {
        WebAuthnAssertionChallenge challenge = webAuthnProvider.startAssertion(identifier);
        log.info("Generated FIDO2 login challenge for identifier: {}", identifier);

        return PasskeyChallengeResponse.builder()
                .challenge(challenge.getChallenge())
                .rpId(challenge.getRpId())
                .userId(challenge.getUserId())
                .timeoutSeconds(challenge.getTimeoutSeconds())
                .optionsJson(challenge.getOptionsJson())
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public List<PasskeyDeviceResponse> listDevices(Identity identity) {
        return passkeyCredentialRepository.findAllByIdentityId(identity.getId())
                .stream()
                .map(this::mapToDeviceResponse)
                .toList();
    }

    @Override
    @Transactional
    public void revokePasskey(Identity identity, String credentialId) {
        PasskeyCredential credential = passkeyCredentialRepository.findByCredentialId(credentialId.trim())
                .orElseThrow(() -> new ResourceNotFoundException("Passkey credential not found: " + credentialId));

        if (!credential.getIdentity().getId().equals(identity.getId())) {
            throw new ResourceNotFoundException("Passkey credential does not belong to this account.");
        }

        credential.setRevokedAt(Instant.now());
        passkeyCredentialRepository.save(credential);
        log.info("Revoked biometric passkey [{}] for identity ID: {}", credentialId, identity.getId());
    }

    private PasskeyDeviceResponse mapToDeviceResponse(PasskeyCredential credential) {
        return PasskeyDeviceResponse.builder()
                .id(credential.getId())
                .credentialId(credential.getCredentialId())
                .deviceId(credential.getDeviceId())
                .deviceName(credential.getDeviceName())
                .createdOn(credential.getCreatedOn())
                .lastUsedAt(credential.getLastUsedAt())
                .isRevoked(credential.isRevoked())
                .build();
    }
}
