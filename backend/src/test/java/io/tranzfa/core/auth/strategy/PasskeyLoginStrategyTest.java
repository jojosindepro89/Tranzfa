package io.tranzfa.core.auth.strategy;

import io.tranzfa.core.auth.dto.AuthTokenResponse;
import io.tranzfa.core.auth.dto.LoginRequest;
import io.tranzfa.core.auth.model.entity.Identity;
import io.tranzfa.core.auth.model.entity.PasskeyCredential;
import io.tranzfa.core.auth.model.enums.IdentityType;
import io.tranzfa.core.auth.model.enums.LoginMethod;
import io.tranzfa.core.auth.provider.WebAuthnProvider;
import io.tranzfa.core.auth.provider.adapter.MockWebAuthnProvider;
import io.tranzfa.core.auth.repository.PasskeyCredentialRepository;
import io.tranzfa.core.auth.service.AuthHelper;
import io.tranzfa.core.common.exception.UnauthorizedException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Instant;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class PasskeyLoginStrategyTest {

    @Mock
    private AuthHelper authHelper;

    @Mock
    private PasskeyCredentialRepository passkeyCredentialRepository;

    private WebAuthnProvider webAuthnProvider;
    private PasskeyLoginStrategy passkeyLoginStrategy;
    private Identity sampleIdentity;
    private PasskeyCredential samplePasskey;

    @BeforeEach
    void setUp() {
        webAuthnProvider = new MockWebAuthnProvider();
        passkeyLoginStrategy = new PasskeyLoginStrategy(authHelper, passkeyCredentialRepository, webAuthnProvider);

        sampleIdentity = Identity.builder()
                .publicId("id_cust_123")
                .identityType(IdentityType.CUSTOMER)
                .status("ACTIVE")
                .build();
        sampleIdentity.setId(100L);

        samplePasskey = PasskeyCredential.builder()
                .identity(sampleIdentity)
                .credentialId("cred_ios_f81729")
                .publicKey("sample-public-key")
                .deviceId("dev-recognized-1")
                .deviceName("iPhone 15 Pro")
                .signCount(10)
                .build();
    }

    @Test
    @DisplayName("Should authenticate successfully with valid passkey on recognized device")
    void shouldAuthenticateSuccessfullyOnRecognizedDevice() {
        LoginRequest request = LoginRequest.builder()
                .credentialId("cred_ios_f81729")
                .loginMethod(LoginMethod.PASSKEY)
                .deviceId("dev-recognized-1")
                .deviceName("iPhone 15 Pro")
                .signCount(11L)
                .build();

        AuthTokenResponse expectedResponse = AuthTokenResponse.builder()
                .accessToken("mock-access-token")
                .refreshToken("mock-refresh-token")
                .build();

        when(passkeyCredentialRepository.findByCredentialId("cred_ios_f81729")).thenReturn(Optional.of(samplePasskey));
        when(authHelper.isNewDevice(sampleIdentity, "dev-recognized-1")).thenReturn(false);
        when(authHelper.issueTokensAndCreateSession(sampleIdentity, "dev-recognized-1", "iPhone 15 Pro", null, null))
                .thenReturn(expectedResponse);

        AuthTokenResponse response = passkeyLoginStrategy.authenticate(request);

        assertThat(response).isNotNull();
        assertThat(response.getAccessToken()).isEqualTo("mock-access-token");
        assertThat(samplePasskey.getSignCount()).isEqualTo(11L);
        assertThat(samplePasskey.getLastUsedAt()).isNotNull();
        verify(passkeyCredentialRepository).save(samplePasskey);
    }

    @Test
    @DisplayName("Should trigger step-up verification when logging in with passkey on new device")
    void shouldTriggerNewDeviceVerificationWhenPasskeyUsedOnNewDevice() {
        LoginRequest request = LoginRequest.builder()
                .credentialId("cred_ios_f81729")
                .loginMethod(LoginMethod.PASSKEY)
                .deviceId("dev-new-ipad")
                .deviceName("iPad Air")
                .signCount(12L)
                .build();

        AuthTokenResponse challengeResponse = AuthTokenResponse.builder()
                .requiresOtp(true)
                .requiresDeviceVerification(true)
                .challengeToken("mock-challenge-token")
                .message("New device detected.")
                .build();

        when(passkeyCredentialRepository.findByCredentialId("cred_ios_f81729")).thenReturn(Optional.of(samplePasskey));
        when(authHelper.isNewDevice(sampleIdentity, "dev-new-ipad")).thenReturn(true);
        when(authHelper.triggerNewDeviceVerification(sampleIdentity, "dev-new-ipad", "iPad Air"))
                .thenReturn(challengeResponse);

        AuthTokenResponse response = passkeyLoginStrategy.authenticate(request);

        assertThat(response).isNotNull();
        assertThat(response.isRequiresOtp()).isTrue();
        assertThat(response.isRequiresDeviceVerification()).isTrue();
    }

    @Test
    @DisplayName("Should reject revoked passkey credential")
    void shouldRejectRevokedPasskey() {
        samplePasskey.setRevokedAt(Instant.now());

        LoginRequest request = LoginRequest.builder()
                .credentialId("cred_ios_f81729")
                .loginMethod(LoginMethod.PASSKEY)
                .build();

        when(passkeyCredentialRepository.findByCredentialId("cred_ios_f81729")).thenReturn(Optional.of(samplePasskey));

        assertThatThrownBy(() -> passkeyLoginStrategy.authenticate(request))
                .isInstanceOf(UnauthorizedException.class)
                .hasMessageContaining("revoked");
    }

    @Test
    @DisplayName("Should detect cloned authenticator, revoke passkey, and reject login")
    void shouldDetectClonedAuthenticatorAndRevoke() {
        // Stored signCount is 10, incoming signCount is 10 or less (replay / cloned key)
        LoginRequest request = LoginRequest.builder()
                .credentialId("cred_ios_f81729")
                .loginMethod(LoginMethod.PASSKEY)
                .signCount(9L)
                .build();

        when(passkeyCredentialRepository.findByCredentialId("cred_ios_f81729")).thenReturn(Optional.of(samplePasskey));

        assertThatThrownBy(() -> passkeyLoginStrategy.authenticate(request))
                .isInstanceOf(UnauthorizedException.class)
                .hasMessageContaining("Cloned biometric authenticator");

        assertThat(samplePasskey.isRevoked()).isTrue();
        assertThat(samplePasskey.getRevokedAt()).isNotNull();
        verify(passkeyCredentialRepository).save(samplePasskey);
    }
}
