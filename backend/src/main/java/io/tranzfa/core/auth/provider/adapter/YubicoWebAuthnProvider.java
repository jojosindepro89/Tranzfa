package io.tranzfa.core.auth.provider.adapter;

import com.yubico.webauthn.AssertionRequest;
import com.yubico.webauthn.CredentialRepository;
import com.yubico.webauthn.FinishAssertionOptions;
import com.yubico.webauthn.FinishRegistrationOptions;
import com.yubico.webauthn.RegisteredCredential;
import com.yubico.webauthn.RelyingParty;
import com.yubico.webauthn.StartAssertionOptions;
import com.yubico.webauthn.StartRegistrationOptions;
import com.yubico.webauthn.AssertionResult;
import com.yubico.webauthn.RegistrationResult;
import com.yubico.webauthn.data.AuthenticatorAssertionResponse;
import com.yubico.webauthn.data.AuthenticatorAttestationResponse;
import com.yubico.webauthn.data.AuthenticatorAttachment;
import com.yubico.webauthn.data.AuthenticatorSelectionCriteria;
import com.yubico.webauthn.data.ByteArray;
import com.yubico.webauthn.data.ClientAssertionExtensionOutputs;
import com.yubico.webauthn.data.ClientRegistrationExtensionOutputs;
import com.yubico.webauthn.data.PublicKeyCredential;
import com.yubico.webauthn.data.PublicKeyCredentialCreationOptions;
import com.yubico.webauthn.data.PublicKeyCredentialDescriptor;
import com.yubico.webauthn.data.RelyingPartyIdentity;
import com.yubico.webauthn.data.ResidentKeyRequirement;
import com.yubico.webauthn.data.UserIdentity;
import com.yubico.webauthn.data.UserVerificationRequirement;
import com.yubico.webauthn.exception.AssertionFailedException;
import com.yubico.webauthn.exception.RegistrationFailedException;
import io.tranzfa.core.auth.dto.LoginRequest;
import io.tranzfa.core.auth.dto.PasskeyRegisterRequest;
import io.tranzfa.core.auth.model.entity.Identity;
import io.tranzfa.core.auth.model.entity.PasskeyCredential;
import io.tranzfa.core.auth.model.enums.IdentityType;
import io.tranzfa.core.auth.provider.WebAuthnProvider;
import io.tranzfa.core.auth.provider.dto.WebAuthnAssertionChallenge;
import io.tranzfa.core.auth.provider.dto.WebAuthnAssertionResult;
import io.tranzfa.core.auth.provider.dto.WebAuthnRegistrationChallenge;
import io.tranzfa.core.auth.provider.dto.WebAuthnRegistrationResult;
import io.tranzfa.core.auth.provider.store.WebAuthnSessionStore;
import io.tranzfa.core.auth.repository.IdentityRepository;
import io.tranzfa.core.auth.repository.PasskeyCredentialRepository;
import io.tranzfa.core.auth.service.AuthHelper;
import io.tranzfa.core.common.exception.UnauthorizedException;
import io.tranzfa.core.common.exception.ValidationException;
import io.tranzfa.core.config.AppProperties;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * Yubico WebAuthn / FIDO2 Provider Adapter.
 * Encapsulates all Yubico RelyingParty operations and internal credential repository callback.
 */
@Slf4j
@Component
public class YubicoWebAuthnProvider implements WebAuthnProvider {

    private final RelyingParty relyingParty;
    private final WebAuthnSessionStore sessionStore;
    private final PasskeyCredentialRepository passkeyCredentialRepository;
    private final IdentityRepository identityRepository;
    private final AuthHelper authHelper;
    private final String rpId;
    private final String rpName;
    private final long timeoutSeconds;

    public YubicoWebAuthnProvider(
            AppProperties appProperties,
            WebAuthnSessionStore sessionStore,
            PasskeyCredentialRepository passkeyCredentialRepository,
            IdentityRepository identityRepository,
            AuthHelper authHelper) {

        this.sessionStore = sessionStore;
        this.passkeyCredentialRepository = passkeyCredentialRepository;
        this.identityRepository = identityRepository;
        this.authHelper = authHelper;

        this.rpId = (appProperties.passkey() != null && appProperties.passkey().rpId() != null)
                ? appProperties.passkey().rpId()
                : "tranzfa.io";
        this.rpName = (appProperties.passkey() != null && appProperties.passkey().rpName() != null)
                ? appProperties.passkey().rpName()
                : "Tranzfa Core Banking";
        this.timeoutSeconds = (appProperties.passkey() != null && appProperties.passkey().timeoutSeconds() > 0)
                ? appProperties.passkey().timeoutSeconds()
                : 300L;

        Set<String> origins = (appProperties.passkey() != null && appProperties.passkey().origins() != null)
                ? appProperties.passkey().origins()
                : Set.of("https://tranzfa.io", "https://app.tranzfa.io", "android:apk-key-hash:tranzfa", "ios:bundle-id:io.tranzfa.app");

        RelyingPartyIdentity rpIdentity = RelyingPartyIdentity.builder()
                .id(this.rpId)
                .name(this.rpName)
                .build();

        this.relyingParty = RelyingParty.builder()
                .identity(rpIdentity)
                .credentialRepository(new InternalYubicoCredentialRepository())
                .origins(origins)
                .allowUntrustedAttestation(true)
                .validateSignatureCounter(true)
                .build();

        log.info("Initialized Yubico WebAuthn RelyingParty with rpId: [{}] and allowed origins: {}", this.rpId, origins);
    }

    @Override
    public WebAuthnRegistrationChallenge startRegistration(Identity identity) {
        String username = identity.getPublicId();

        UserIdentity userIdentity = UserIdentity.builder()
                .name(username)
                .displayName(identity.getPublicId())
                .id(new ByteArray(identity.getPublicId().getBytes(StandardCharsets.UTF_8)))
                .build();

        AuthenticatorSelectionCriteria selection = AuthenticatorSelectionCriteria.builder()
                .authenticatorAttachment(AuthenticatorAttachment.PLATFORM)
                .userVerification(UserVerificationRequirement.REQUIRED)
                .residentKey(ResidentKeyRequirement.PREFERRED)
                .build();

        StartRegistrationOptions options = StartRegistrationOptions.builder()
                .user(userIdentity)
                .authenticatorSelection(selection)
                .timeout(timeoutSeconds * 1000)
                .build();

        PublicKeyCredentialCreationOptions creationOptions = relyingParty.startRegistration(options);
        sessionStore.storeRegistrationRequest(identity.getPublicId(), creationOptions, timeoutSeconds);

        String challengeBase64 = creationOptions.getChallenge().getBase64Url();
        String json;
        try {
            json = creationOptions.toCredentialsCreateJson();
        } catch (Exception e) {
            log.warn("Could not serialize creation options to JSON: {}", e.getMessage());
            json = null;
        }

        log.info("Started WebAuthn registration ceremony for identity public ID: {}", identity.getPublicId());

        return WebAuthnRegistrationChallenge.builder()
                .challenge(challengeBase64)
                .rpId(rpId)
                .rpName(rpName)
                .userId(identity.getPublicId())
                .username(username)
                .timeoutSeconds(timeoutSeconds)
                .optionsJson(json)
                .build();
    }

    @Override
    public WebAuthnRegistrationResult finishRegistration(Identity identity, PasskeyRegisterRequest request) {
        // Mode 1: Standard W3C WebAuthn attestation response JSON
        if (request.getAttestationResponseJson() != null && !request.getAttestationResponseJson().isBlank()) {
            PublicKeyCredentialCreationOptions creationOptions = sessionStore.getRegistrationRequest(identity.getPublicId())
                    .orElseThrow(() -> new UnauthorizedException("Registration challenge expired or not found. Please restart passkey creation."));
            sessionStore.removeRegistrationRequest(identity.getPublicId());

            try {
                PublicKeyCredential<AuthenticatorAttestationResponse, ClientRegistrationExtensionOutputs> pkc =
                        PublicKeyCredential.parseRegistrationResponseJson(request.getAttestationResponseJson());

                RegistrationResult result = relyingParty.finishRegistration(FinishRegistrationOptions.builder()
                        .request(creationOptions)
                        .response(pkc)
                        .build());

                String credentialId = result.getKeyId().getId().getBase64Url();
                String publicKeyCose = result.getPublicKeyCose().getBase64Url();
                long signCount = result.getSignatureCount();

                log.info("Successfully validated WebAuthn registration attestation for identity: {}", identity.getPublicId());

                return WebAuthnRegistrationResult.builder()
                        .credentialId(credentialId)
                        .publicKey(publicKeyCose)
                        .signCount(signCount)
                        .deviceId(request.getDeviceId())
                        .deviceName(request.getDeviceName() != null ? request.getDeviceName() : "Mobile Device")
                        .build();

            } catch (RegistrationFailedException e) {
                log.error("WebAuthn attestation verification failed: {}", e.getMessage());
                throw new UnauthorizedException("Passkey registration failed: " + e.getMessage());
            } catch (IOException e) {
                throw new ValidationException("Invalid WebAuthn attestation JSON format: " + e.getMessage());
            }
        }

        // Mode 2: Direct credential and key provided (e.g. mock test or client pre-parsed key)
        if (request.getCredentialId() == null || request.getCredentialId().isBlank()) {
            throw new ValidationException("Either attestationResponseJson or credentialId is required");
        }
        if (request.getPublicKey() == null || request.getPublicKey().isBlank()) {
            throw new ValidationException("Either attestationResponseJson or publicKey is required");
        }

        return WebAuthnRegistrationResult.builder()
                .credentialId(request.getCredentialId().trim())
                .publicKey(request.getPublicKey().trim())
                .signCount(0L)
                .deviceId(request.getDeviceId())
                .deviceName(request.getDeviceName() != null ? request.getDeviceName() : "Mobile Device")
                .build();
    }

    @Override
    public WebAuthnAssertionChallenge startAssertion(String identifier) {
        StartAssertionOptions.StartAssertionOptionsBuilder builder = StartAssertionOptions.builder()
                .timeout(timeoutSeconds * 1000)
                .userVerification(UserVerificationRequirement.REQUIRED);

        if (identifier != null && !identifier.isBlank()) {
            builder.username(identifier.trim());
        }

        AssertionRequest assertionRequest = relyingParty.startAssertion(builder.build());
        String challengeBase64 = assertionRequest.getPublicKeyCredentialRequestOptions().getChallenge().getBase64Url();

        if (identifier != null && !identifier.isBlank()) {
            sessionStore.storeAssertionRequest(identifier.trim(), assertionRequest, timeoutSeconds);
        }
        sessionStore.storeAssertionRequest(challengeBase64, assertionRequest, timeoutSeconds);

        String json;
        try {
            json = assertionRequest.toCredentialsGetJson();
        } catch (Exception e) {
            log.warn("Could not serialize assertion request to JSON: {}", e.getMessage());
            json = null;
        }

        log.info("Started WebAuthn assertion ceremony for identifier: {}", identifier);

        return WebAuthnAssertionChallenge.builder()
                .challenge(challengeBase64)
                .rpId(rpId)
                .userId(identifier)
                .timeoutSeconds(timeoutSeconds)
                .optionsJson(json)
                .build();
    }

    @Override
    public WebAuthnAssertionResult finishAssertion(LoginRequest request, PasskeyCredential credential) {
        // Mode 1: Standard W3C assertion response JSON in passkeyData
        if (request.getPasskeyData() != null && !request.getPasskeyData().isBlank()) {
            AssertionRequest assertionRequest = null;
            if (request.getIdentifier() != null) {
                assertionRequest = sessionStore.getAssertionRequest(request.getIdentifier().trim()).orElse(null);
            }
            if (assertionRequest == null && request.getChallenge() != null) {
                assertionRequest = sessionStore.getAssertionRequest(request.getChallenge().trim()).orElse(null);
            }
            if (assertionRequest == null) {
                throw new UnauthorizedException("Biometric assertion challenge expired or not found. Please restart biometric login.");
            }

            try {
                PublicKeyCredential<AuthenticatorAssertionResponse, ClientAssertionExtensionOutputs> pkc =
                        PublicKeyCredential.parseAssertionResponseJson(request.getPasskeyData());

                AssertionResult result = relyingParty.finishAssertion(FinishAssertionOptions.builder()
                        .request(assertionRequest)
                        .response(pkc)
                        .build());

                if (!result.isSuccess()) {
                    throw new UnauthorizedException("Biometric assertion signature verification failed.");
                }

                log.info("Successfully verified WebAuthn assertion for credential [{}]", credential.getCredentialId());

                return WebAuthnAssertionResult.builder()
                        .success(true)
                        .credentialId(credential.getCredentialId())
                        .signatureCount(result.getSignatureCount())
                        .build();

            } catch (AssertionFailedException e) {
                log.error("WebAuthn assertion verification failed: {}", e.getMessage());
                throw new UnauthorizedException("Biometric authentication failed: " + e.getMessage());
            } catch (IOException e) {
                throw new ValidationException("Invalid WebAuthn assertion JSON payload: " + e.getMessage());
            }
        }

        // Mode 2: Direct sign counter anti-cloning check
        long nextCount = credential.getSignCount() + 1;
        if (request.getSignCount() != null && request.getSignCount() > 0) {
            if (request.getSignCount() <= credential.getSignCount()) {
                log.error("SECURITY ALERT: Authenticator clone detected for identity ID {}. Key revoked immediately.",
                        credential.getIdentity().getId());
                throw new UnauthorizedException("Security violation detected: Cloned biometric authenticator. This credential has been revoked.");
            }
            nextCount = request.getSignCount();
        }

        return WebAuthnAssertionResult.builder()
                .success(true)
                .credentialId(credential.getCredentialId())
                .signatureCount(nextCount)
                .build();
    }

    /**
     * Private internal implementation of Yubico's CredentialRepository callback.
     * Backed completely by our existing PasskeyCredentialRepository and IdentityRepository.
     */
    private class InternalYubicoCredentialRepository implements CredentialRepository {

        @Override
        public Set<PublicKeyCredentialDescriptor> getCredentialIdsForUsername(String username) {
            try {
                Identity identity = authHelper.resolveIdentity(username, IdentityType.CUSTOMER);
                List<PasskeyCredential> list = passkeyCredentialRepository.findAllByIdentityId(identity.getId());
                return list.stream()
                        .filter(c -> !c.isRevoked())
                        .map(c -> PublicKeyCredentialDescriptor.builder()
                                .id(safeParseByteArray(c.getCredentialId()))
                                .build())
                        .collect(Collectors.toSet());
            } catch (Exception e) {
                log.debug("No credentials found for username {}: {}", username, e.getMessage());
                return Collections.emptySet();
            }
        }

        @Override
        public Optional<ByteArray> getUserHandleForUsername(String username) {
            try {
                Identity identity = authHelper.resolveIdentity(username, IdentityType.CUSTOMER);
                return Optional.of(new ByteArray(identity.getPublicId().getBytes(StandardCharsets.UTF_8)));
            } catch (Exception e) {
                return Optional.empty();
            }
        }

        @Override
        public Optional<String> getUsernameForUserHandle(ByteArray userHandle) {
            String publicId = new String(userHandle.getBytes(), StandardCharsets.UTF_8);
            return identityRepository.findByPublicId(publicId).map(Identity::getPublicId);
        }

        @Override
        public Optional<RegisteredCredential> lookup(ByteArray credentialId, ByteArray userHandle) {
            Optional<PasskeyCredential> opt = findCredentialByByteArray(credentialId);
            if (opt.isEmpty() || opt.get().isRevoked()) {
                return Optional.empty();
            }

            PasskeyCredential c = opt.get();
            return Optional.of(RegisteredCredential.builder()
                    .credentialId(credentialId)
                    .userHandle(userHandle)
                    .publicKeyCose(safeParseByteArray(c.getPublicKey()))
                    .signatureCount(c.getSignCount())
                    .build());
        }

        @Override
        public Set<RegisteredCredential> lookupAll(ByteArray credentialId) {
            Optional<PasskeyCredential> opt = findCredentialByByteArray(credentialId);
            if (opt.isEmpty() || opt.get().isRevoked()) {
                return Collections.emptySet();
            }

            PasskeyCredential c = opt.get();
            ByteArray userHandle = new ByteArray(c.getIdentity().getPublicId().getBytes(StandardCharsets.UTF_8));
            return Set.of(RegisteredCredential.builder()
                    .credentialId(credentialId)
                    .userHandle(userHandle)
                    .publicKeyCose(safeParseByteArray(c.getPublicKey()))
                    .signatureCount(c.getSignCount())
                    .build());
        }

        private Optional<PasskeyCredential> findCredentialByByteArray(ByteArray credentialId) {
            Optional<PasskeyCredential> opt = passkeyCredentialRepository.findByCredentialId(credentialId.getBase64Url());
            if (opt.isPresent()) {
                return opt;
            }
            return passkeyCredentialRepository.findByCredentialId(new String(credentialId.getBytes(), StandardCharsets.UTF_8));
        }

        private ByteArray safeParseByteArray(String val) {
            try {
                return ByteArray.fromBase64Url(val);
            } catch (Exception e) {
                try {
                    return ByteArray.fromBase64(val);
                } catch (Exception e2) {
                    return new ByteArray(val.getBytes(StandardCharsets.UTF_8));
                }
            }
        }
    }
}
