package io.tranzfa.core.auth.strategy;

import io.tranzfa.core.auth.dto.AuthTokenResponse;
import io.tranzfa.core.auth.dto.LoginRequest;
import io.tranzfa.core.auth.model.entity.Identity;
import io.tranzfa.core.auth.model.entity.PasskeyCredential;
import io.tranzfa.core.auth.model.enums.LoginMethod;
import io.tranzfa.core.auth.repository.PasskeyCredentialRepository;
import io.tranzfa.core.auth.service.AuthHelper;
import io.tranzfa.core.auth.provider.WebAuthnProvider;
import io.tranzfa.core.auth.provider.dto.WebAuthnAssertionResult;
import io.tranzfa.core.common.exception.UnauthorizedException;
import io.tranzfa.core.common.exception.ValidationException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class PasskeyLoginStrategy implements LoginStrategy {

    private final AuthHelper authHelper;
    private final PasskeyCredentialRepository passkeyCredentialRepository;
    private final WebAuthnProvider webAuthnProvider;

    @Override
    public LoginMethod getSupportedMethod() {
        return LoginMethod.PASSKEY;
    }

    @Override
    @Transactional
    public AuthTokenResponse authenticate(LoginRequest request) {
        String credentialId = request.getCredentialId();
        Identity identity = null;

        // If identifier is provided, resolve identity
        if (request.getIdentifier() != null && !request.getIdentifier().isBlank()) {
            identity = authHelper.resolveIdentity(request.getIdentifier(), request.getUserType());
        }

        PasskeyCredential passkey;
        if (credentialId != null && !credentialId.isBlank()) {
            passkey = passkeyCredentialRepository.findByCredentialId(credentialId.trim())
                    .orElseThrow(() -> new UnauthorizedException(
                            "Biometric passkey not registered on this device. Please log in with your 4-digit PIN or password."));
        } else if (identity != null) {
            // Fallback: lookup by identity if device credential ID was not explicitly passed
            List<PasskeyCredential> passkeys = passkeyCredentialRepository.findAllByIdentityId(identity.getId());
            if (passkeys.isEmpty()) {
                throw new UnauthorizedException(
                        "No biometric passkey registered for this account. Please log in with your 4-digit PIN or password.");
            }
            passkey = passkeys.stream()
                    .filter(p -> !p.isRevoked())
                    .findFirst()
                    .orElseThrow(() -> new UnauthorizedException(
                            "All biometric credentials for this account have been revoked. Please log in with your password."));
        } else {
            throw new ValidationException("Either a credential ID or login identifier is required for biometric authentication.");
        }

        if (passkey.isRevoked()) {
            throw new UnauthorizedException("Biometric credential for this device has been revoked. Please log in with your password.");
        }

        // Delegate FIDO2 assertion verification to pluggable WebAuthn provider
        try {
            WebAuthnAssertionResult assertionResult = webAuthnProvider.finishAssertion(request, passkey);
            passkey.setSignCount(assertionResult.getSignatureCount());
        } catch (UnauthorizedException e) {
            if (e.getMessage() != null && e.getMessage().contains("Cloned biometric authenticator")) {
                passkey.setRevokedAt(Instant.now());
                passkeyCredentialRepository.save(passkey);
            }
            throw e;
        }

        passkey.setLastUsedAt(Instant.now());
        passkeyCredentialRepository.save(passkey);

        Identity authIdentity = passkey.getIdentity();

        // New Device Step-Up Verification: Check if device is unrecognized
        if (authHelper.isNewDevice(authIdentity, request.getDeviceId())) {
            return authHelper.triggerNewDeviceVerification(authIdentity, request.getDeviceId(), request.getDeviceName());
        }

        log.info("Biometric passkey authentication successful for identity ID: {} on device: {}",
                authIdentity.getId(), request.getDeviceId());

        return authHelper.issueTokensAndCreateSession(
                authIdentity,
                request.getDeviceId(),
                request.getDeviceName(),
                null,
                null);
    }
}
