package io.tranzfa.core.auth.provider.adapter;

import io.tranzfa.core.auth.dto.LoginRequest;
import io.tranzfa.core.auth.dto.PasskeyRegisterRequest;
import io.tranzfa.core.auth.model.entity.Identity;
import io.tranzfa.core.auth.model.entity.PasskeyCredential;
import io.tranzfa.core.auth.model.enums.IdentityType;
import io.tranzfa.core.auth.provider.dto.WebAuthnAssertionChallenge;
import io.tranzfa.core.auth.provider.dto.WebAuthnAssertionResult;
import io.tranzfa.core.auth.provider.dto.WebAuthnRegistrationChallenge;
import io.tranzfa.core.auth.provider.dto.WebAuthnRegistrationResult;
import io.tranzfa.core.auth.provider.store.InMemoryWebAuthnSessionStore;
import io.tranzfa.core.auth.provider.store.WebAuthnSessionStore;
import io.tranzfa.core.auth.repository.IdentityRepository;
import io.tranzfa.core.auth.repository.PasskeyCredentialRepository;
import io.tranzfa.core.auth.service.AuthHelper;
import io.tranzfa.core.common.exception.UnauthorizedException;
import io.tranzfa.core.config.AppProperties;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Set;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@ExtendWith(MockitoExtension.class)
class YubicoWebAuthnProviderTest {

    @Mock
    private PasskeyCredentialRepository passkeyCredentialRepository;

    @Mock
    private IdentityRepository identityRepository;

    @Mock
    private AuthHelper authHelper;

    private WebAuthnSessionStore sessionStore;
    private YubicoWebAuthnProvider provider;
    private Identity sampleIdentity;

    @BeforeEach
    void setUp() {
        sessionStore = new InMemoryWebAuthnSessionStore();

        AppProperties.Passkey passkeyConfig = new AppProperties.Passkey(
                "tranzfa.io",
                "Tranzfa FinTech",
                Set.of("https://tranzfa.io", "https://app.tranzfa.io"),
                false,
                300L);
        AppProperties appProperties = new AppProperties(null, null, null, null, null, null, null, passkeyConfig);

        provider = new YubicoWebAuthnProvider(
                appProperties,
                sessionStore,
                passkeyCredentialRepository,
                identityRepository,
                authHelper);

        sampleIdentity = Identity.builder()
                .publicId("id_cust_9988")
                .identityType(IdentityType.CUSTOMER)
                .status("ACTIVE")
                .build();
        sampleIdentity.setId(10L);
    }

    @Test
    @DisplayName("Should generate valid WebAuthn registration challenge and W3C options JSON via Yubico")
    void shouldGenerateRegistrationChallenge() {
        WebAuthnRegistrationChallenge challenge = provider.startRegistration(sampleIdentity);

        assertThat(challenge).isNotNull();
        assertThat(challenge.getChallenge()).isNotBlank();
        assertThat(challenge.getRpId()).isEqualTo("tranzfa.io");
        assertThat(challenge.getRpName()).isEqualTo("Tranzfa FinTech");
        assertThat(challenge.getUserId()).isEqualTo("id_cust_9988");
        assertThat(challenge.getOptionsJson()).isNotBlank();
        assertThat(challenge.getOptionsJson()).contains("tranzfa.io");

        assertThat(sessionStore.getRegistrationRequest("id_cust_9988")).isPresent();
    }

    @Test
    @DisplayName("Should generate valid WebAuthn assertion challenge and W3C request options JSON via Yubico")
    void shouldGenerateAssertionChallenge() {
        WebAuthnAssertionChallenge challenge = provider.startAssertion("+2348011223344");

        assertThat(challenge).isNotNull();
        assertThat(challenge.getChallenge()).isNotBlank();
        assertThat(challenge.getRpId()).isEqualTo("tranzfa.io");
        assertThat(challenge.getOptionsJson()).isNotBlank();

        assertThat(sessionStore.getAssertionRequest("+2348011223344")).isPresent();
    }

    @Test
    @DisplayName("Should complete direct passkey registration")
    void shouldCompleteDirectRegistration() {
        PasskeyRegisterRequest request = PasskeyRegisterRequest.builder()
                .credentialId("cred_hardware_123")
                .publicKey("sample_cose_public_key")
                .deviceId("dev_pixel_9")
                .deviceName("Google Pixel 9")
                .build();

        WebAuthnRegistrationResult result = provider.finishRegistration(sampleIdentity, request);

        assertThat(result).isNotNull();
        assertThat(result.getCredentialId()).isEqualTo("cred_hardware_123");
        assertThat(result.getPublicKey()).isEqualTo("sample_cose_public_key");
        assertThat(result.getSignCount()).isZero();
        assertThat(result.getDeviceId()).isEqualTo("dev_pixel_9");
    }

    @Test
    @DisplayName("Should verify assertion and advance sign count")
    void shouldVerifyAssertionAndAdvanceSignCount() {
        PasskeyCredential credential = PasskeyCredential.builder()
                .identity(sampleIdentity)
                .credentialId("cred_hardware_123")
                .publicKey("sample_cose_key")
                .signCount(5L)
                .build();

        LoginRequest request = LoginRequest.builder()
                .credentialId("cred_hardware_123")
                .signCount(6L)
                .build();

        WebAuthnAssertionResult result = provider.finishAssertion(request, credential);

        assertThat(result).isNotNull();
        assertThat(result.isSuccess()).isTrue();
        assertThat(result.getSignatureCount()).isEqualTo(6L);
    }

    @Test
    @DisplayName("Should detect cloned authenticator when signCount does not strictly increase")
    void shouldDetectClonedAuthenticatorOnReplay() {
        PasskeyCredential credential = PasskeyCredential.builder()
                .identity(sampleIdentity)
                .credentialId("cred_hardware_123")
                .signCount(15L)
                .build();

        LoginRequest request = LoginRequest.builder()
                .credentialId("cred_hardware_123")
                .signCount(15L)
                .build();

        assertThatThrownBy(() -> provider.finishAssertion(request, credential))
                .isInstanceOf(UnauthorizedException.class)
                .hasMessageContaining("Cloned biometric authenticator");
    }
}
