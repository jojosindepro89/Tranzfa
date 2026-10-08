package io.tranzfa.core.auth.provider.adapter;

import io.tranzfa.core.auth.dto.LoginRequest;
import io.tranzfa.core.auth.dto.PasskeyRegisterRequest;
import io.tranzfa.core.auth.model.entity.Identity;
import io.tranzfa.core.auth.model.entity.PasskeyCredential;
import io.tranzfa.core.auth.provider.WebAuthnProvider;
import io.tranzfa.core.auth.provider.dto.WebAuthnAssertionChallenge;
import io.tranzfa.core.auth.provider.dto.WebAuthnAssertionResult;
import io.tranzfa.core.auth.provider.dto.WebAuthnRegistrationChallenge;
import io.tranzfa.core.auth.provider.dto.WebAuthnRegistrationResult;
import io.tranzfa.core.common.exception.UnauthorizedException;
import io.tranzfa.core.common.exception.ValidationException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.security.SecureRandom;
import java.util.Base64;

/**
 * Mock WebAuthn Provider for CI/CD test automation and local dev environments
 * without physical hardware authenticators.
 */
@Slf4j
@Component
public class MockWebAuthnProvider implements WebAuthnProvider {

    private static final String RP_ID = "tranzfa.io";
    private static final String RP_NAME = "Tranzfa Core Banking (Mock)";
    private static final long TIMEOUT_SECONDS = 300L;
    private final SecureRandom secureRandom = new SecureRandom();

    @Override
    public WebAuthnRegistrationChallenge startRegistration(Identity identity) {
        String challenge = generateNonce();
        String username = identity.getPublicId();

        log.info("[MOCK] Generated passkey registration challenge for identity: {}", identity.getPublicId());

        return WebAuthnRegistrationChallenge.builder()
                .challenge(challenge)
                .rpId(RP_ID)
                .rpName(RP_NAME)
                .userId(identity.getPublicId())
                .username(username)
                .timeoutSeconds(TIMEOUT_SECONDS)
                .optionsJson("{\"challenge\":\"" + challenge + "\",\"rp\":{\"id\":\"" + RP_ID + "\",\"name\":\"" + RP_NAME + "\"}}")
                .build();
    }

    @Override
    public WebAuthnRegistrationResult finishRegistration(Identity identity, PasskeyRegisterRequest request) {
        String credId = request.getCredentialId() != null && !request.getCredentialId().isBlank()
                ? request.getCredentialId().trim()
                : "mock_cred_" + generateNonce().substring(0, 12);

        String pubKey = request.getPublicKey() != null && !request.getPublicKey().isBlank()
                ? request.getPublicKey().trim()
                : "mock_public_key_" + generateNonce();

        log.info("[MOCK] Completed passkey registration for credential ID: {}", credId);

        return WebAuthnRegistrationResult.builder()
                .credentialId(credId)
                .publicKey(pubKey)
                .signCount(0L)
                .deviceId(request.getDeviceId())
                .deviceName(request.getDeviceName() != null ? request.getDeviceName() : "Mock Device")
                .build();
    }

    @Override
    public WebAuthnAssertionChallenge startAssertion(String identifier) {
        String challenge = generateNonce();

        log.info("[MOCK] Generated passkey login challenge for identifier: {}", identifier);

        return WebAuthnAssertionChallenge.builder()
                .challenge(challenge)
                .rpId(RP_ID)
                .userId(identifier)
                .timeoutSeconds(TIMEOUT_SECONDS)
                .optionsJson("{\"challenge\":\"" + challenge + "\",\"rpId\":\"" + RP_ID + "\"}")
                .build();
    }

    @Override
    public WebAuthnAssertionResult finishAssertion(LoginRequest request, PasskeyCredential credential) {
        long nextCount = credential.getSignCount() + 1;
        if (request.getSignCount() != null && request.getSignCount() > 0) {
            if (request.getSignCount() <= credential.getSignCount()) {
                log.error("[MOCK] SECURITY ALERT: Authenticator clone detected for identity ID {}.",
                        credential.getIdentity().getId());
                throw new UnauthorizedException("Security violation detected: Cloned biometric authenticator. This credential has been revoked.");
            }
            nextCount = request.getSignCount();
        }

        log.info("[MOCK] Biometric assertion verified for credential [{}]", credential.getCredentialId());

        return WebAuthnAssertionResult.builder()
                .success(true)
                .credentialId(credential.getCredentialId())
                .signatureCount(nextCount)
                .build();
    }

    private String generateNonce() {
        byte[] bytes = new byte[32];
        secureRandom.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }
}
