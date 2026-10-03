package io.tranzfa.core.auth.service;

import io.tranzfa.core.auth.model.entity.Identity;
import io.tranzfa.core.auth.model.entity.PinCredential;
import io.tranzfa.core.auth.model.enums.IdentityType;
import io.tranzfa.core.auth.repository.PinCredentialRepository;
import io.tranzfa.core.auth.service.impl.PinServiceImpl;
import io.tranzfa.core.common.exception.InvalidPinException;
import io.tranzfa.core.common.exception.ValidationException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class PinServiceTest {

    @Mock
    private PinCredentialRepository pinCredentialRepository;

    private PasswordEncoder passwordEncoder;
    private PinService pinService;
    private Identity sampleIdentity;

    @BeforeEach
    void setUp() {
        passwordEncoder = new BCryptPasswordEncoder();
        pinService = new PinServiceImpl(pinCredentialRepository, passwordEncoder);

        sampleIdentity = Identity.builder()
                .publicId("id_cust_123")
                .identityType(IdentityType.CUSTOMER)
                .status("ACTIVE")
                .build();
        sampleIdentity.setId(100L);
    }

    @Test
    @DisplayName("Should successfully set 4-digit PIN")
    void shouldSetPinSuccessfully() {
        when(pinCredentialRepository.findByIdentityId(100L)).thenReturn(Optional.empty());

        pinService.setPin(sampleIdentity, "4921", "4921");

        ArgumentCaptor<PinCredential> captor = ArgumentCaptor.forClass(PinCredential.class);
        verify(pinCredentialRepository).save(captor.capture());

        PinCredential saved = captor.getValue();
        assertThat(saved.isSet()).isTrue();
        assertThat(saved.getFailedAttempts()).isZero();
        assertThat(saved.getLockedUntil()).isNull();
        assertThat(passwordEncoder.matches("4921", saved.getPin())).isTrue();
    }

    @Test
    @DisplayName("Should reject PIN if confirmation does not match")
    void shouldRejectMismatchedConfirmationPin() {
        assertThatThrownBy(() -> pinService.setPin(sampleIdentity, "1234", "5678"))
                .isInstanceOf(ValidationException.class)
                .hasMessageContaining("do not match");
    }

    @Test
    @DisplayName("Should reject invalid non-4-digit PIN")
    void shouldRejectInvalidLengthPin() {
        assertThatThrownBy(() -> pinService.setPin(sampleIdentity, "123", "123"))
                .isInstanceOf(ValidationException.class)
                .hasMessageContaining("exactly 4 numeric digits");
    }

    @Test
    @DisplayName("Should verify correct PIN and reset failed attempts counter")
    void shouldVerifyCorrectPin() {
        String encodedPin = passwordEncoder.encode("8821");
        PinCredential credential = PinCredential.builder()
                .identity(sampleIdentity)
                .pin(encodedPin)
                .isSet(true)
                .failedAttempts(1)
                .build();

        when(pinCredentialRepository.findByIdentityId(100L)).thenReturn(Optional.of(credential));

        boolean verified = pinService.verifyPin(sampleIdentity, "8821");

        assertThat(verified).isTrue();
        assertThat(credential.getFailedAttempts()).isZero();
        verify(pinCredentialRepository).save(credential);
    }

    @Test
    @DisplayName("Should increment failed attempts on wrong PIN")
    void shouldTrackFailedAttemptsOnWrongPin() {
        String encodedPin = passwordEncoder.encode("8821");
        PinCredential credential = PinCredential.builder()
                .identity(sampleIdentity)
                .pin(encodedPin)
                .isSet(true)
                .failedAttempts(0)
                .build();

        when(pinCredentialRepository.findByIdentityId(100L)).thenReturn(Optional.of(credential));

        assertThatThrownBy(() -> pinService.verifyPin(sampleIdentity, "1111"))
                .isInstanceOf(InvalidPinException.class)
                .hasMessageContaining("2 attempt(s) remaining");

        assertThat(credential.getFailedAttempts()).isEqualTo(1);
    }

    @Test
    @DisplayName("Should lock PIN for 15 minutes after 3 consecutive failed attempts")
    void shouldLockPinAfterThreeFailedAttempts() {
        String encodedPin = passwordEncoder.encode("8821");
        PinCredential credential = PinCredential.builder()
                .identity(sampleIdentity)
                .pin(encodedPin)
                .isSet(true)
                .failedAttempts(2)
                .build();

        when(pinCredentialRepository.findByIdentityId(100L)).thenReturn(Optional.of(credential));

        assertThatThrownBy(() -> pinService.verifyPin(sampleIdentity, "0000"))
                .isInstanceOf(InvalidPinException.class)
                .hasMessageContaining("locked for 15 minutes");

        assertThat(credential.getFailedAttempts()).isEqualTo(3);
        assertThat(credential.isLocked()).isTrue();
    }

    @Test
    @DisplayName("Should block verification while PIN is locked")
    void shouldBlockVerificationWhenLocked() {
        PinCredential credential = PinCredential.builder()
                .identity(sampleIdentity)
                .pin("some_hash")
                .isSet(true)
                .failedAttempts(3)
                .lockedUntil(Instant.now().plus(10, ChronoUnit.MINUTES))
                .build();

        when(pinCredentialRepository.findByIdentityId(100L)).thenReturn(Optional.of(credential));

        assertThatThrownBy(() -> pinService.verifyPin(sampleIdentity, "8821"))
                .isInstanceOf(InvalidPinException.class)
                .hasMessageContaining("temporarily locked");
    }
}
