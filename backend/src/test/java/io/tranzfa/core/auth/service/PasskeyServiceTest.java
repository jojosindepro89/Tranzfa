package io.tranzfa.core.auth.service;

import io.tranzfa.core.auth.dto.PasskeyChallengeResponse;
import io.tranzfa.core.auth.dto.PasskeyDeviceResponse;
import io.tranzfa.core.auth.dto.PasskeyRegisterRequest;
import io.tranzfa.core.auth.model.entity.Identity;
import io.tranzfa.core.auth.model.entity.PasskeyCredential;
import io.tranzfa.core.auth.model.enums.IdentityType;
import io.tranzfa.core.auth.provider.WebAuthnProvider;
import io.tranzfa.core.auth.provider.adapter.MockWebAuthnProvider;
import io.tranzfa.core.auth.repository.PasskeyCredentialRepository;
import io.tranzfa.core.auth.service.impl.PasskeyServiceImpl;
import io.tranzfa.core.common.exception.ConflictException;
import io.tranzfa.core.common.exception.ResourceNotFoundException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class PasskeyServiceTest {

    @Mock
    private PasskeyCredentialRepository passkeyCredentialRepository;

    private WebAuthnProvider webAuthnProvider;
    private PasskeyService passkeyService;
    private Identity sampleIdentity;

    @BeforeEach
    void setUp() {
        webAuthnProvider = new MockWebAuthnProvider();
        passkeyService = new PasskeyServiceImpl(passkeyCredentialRepository, webAuthnProvider);

        sampleIdentity = Identity.builder()
                .publicId("id_cust_983742")
                .identityType(IdentityType.CUSTOMER)
                .status("ACTIVE")
                .build();
        sampleIdentity.setId(100L);
    }

    @Test
    @DisplayName("Should generate valid FIDO2 registration challenge")
    void shouldGenerateValidRegisterChallenge() {
        PasskeyChallengeResponse response = passkeyService.generateRegisterChallenge(sampleIdentity);

        assertThat(response).isNotNull();
        assertThat(response.getChallenge()).isNotBlank();
        assertThat(response.getRpId()).isEqualTo("tranzfa.io");
        assertThat(response.getUserId()).isEqualTo("id_cust_983742");
        assertThat(response.getTimeoutSeconds()).isEqualTo(300);
    }

    @Test
    @DisplayName("Should register biometric passkey hardware public key successfully")
    void shouldRegisterPasskeySuccessfully() {
        PasskeyRegisterRequest request = PasskeyRegisterRequest.builder()
                .credentialId("cred_ios_f81729")
                .publicKey("MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...")
                .deviceId("dev-ios-a918f-2831")
                .deviceName("iPhone 15 Pro")
                .build();

        when(passkeyCredentialRepository.findByCredentialId("cred_ios_f81729")).thenReturn(Optional.empty());
        when(passkeyCredentialRepository.save(any(PasskeyCredential.class))).thenAnswer(invocation -> invocation.getArgument(0));

        PasskeyDeviceResponse response = passkeyService.registerPasskey(sampleIdentity, request);

        assertThat(response).isNotNull();
        assertThat(response.getCredentialId()).isEqualTo("cred_ios_f81729");
        assertThat(response.getDeviceId()).isEqualTo("dev-ios-a918f-2831");
        assertThat(response.getDeviceName()).isEqualTo("iPhone 15 Pro");

        ArgumentCaptor<PasskeyCredential> captor = ArgumentCaptor.forClass(PasskeyCredential.class);
        verify(passkeyCredentialRepository).save(captor.capture());
        PasskeyCredential saved = captor.getValue();
        assertThat(saved.getPublicKey()).isEqualTo("MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...");
        assertThat(saved.getSignCount()).isZero();
    }

    @Test
    @DisplayName("Should reject duplicate passkey credential ID")
    void shouldRejectDuplicateCredentialId() {
        PasskeyRegisterRequest request = PasskeyRegisterRequest.builder()
                .credentialId("cred_existing_123")
                .publicKey("sample-key")
                .build();

        when(passkeyCredentialRepository.findByCredentialId("cred_existing_123"))
                .thenReturn(Optional.of(PasskeyCredential.builder().build()));

        assertThatThrownBy(() -> passkeyService.registerPasskey(sampleIdentity, request))
                .isInstanceOf(ConflictException.class)
                .hasMessageContaining("already registered");
    }

    @Test
    @DisplayName("Should revoke passkey successfully")
    void shouldRevokePasskeySuccessfully() {
        PasskeyCredential credential = PasskeyCredential.builder()
                .identity(sampleIdentity)
                .credentialId("cred_ios_f81729")
                .build();

        when(passkeyCredentialRepository.findByCredentialId("cred_ios_f81729")).thenReturn(Optional.of(credential));

        passkeyService.revokePasskey(sampleIdentity, "cred_ios_f81729");

        assertThat(credential.isRevoked()).isTrue();
        assertThat(credential.getRevokedAt()).isNotNull();
        verify(passkeyCredentialRepository).save(credential);
    }
}
