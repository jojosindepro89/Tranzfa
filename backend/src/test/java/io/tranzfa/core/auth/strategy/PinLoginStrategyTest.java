package io.tranzfa.core.auth.strategy;

import io.tranzfa.core.auth.dto.AuthTokenResponse;
import io.tranzfa.core.auth.dto.LoginRequest;
import io.tranzfa.core.auth.model.entity.Identity;
import io.tranzfa.core.auth.model.entity.PinCredential;
import io.tranzfa.core.auth.model.enums.IdentityType;
import io.tranzfa.core.auth.model.enums.LoginMethod;
import io.tranzfa.core.auth.repository.PinCredentialRepository;
import io.tranzfa.core.auth.service.AuthHelper;
import io.tranzfa.core.common.exception.InvalidPinException;
import io.tranzfa.core.common.exception.UnauthorizedException;
import io.tranzfa.core.common.exception.ValidationException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
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
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class PinLoginStrategyTest {

    @Mock
    private AuthHelper authHelper;

    @Mock
    private PinCredentialRepository pinCredentialRepository;

    private PasswordEncoder passwordEncoder;
    private PinLoginStrategy pinLoginStrategy;
    private Identity sampleIdentity;
    private PinCredential sampleCredential;

    @BeforeEach
    void setUp() {
        passwordEncoder = new BCryptPasswordEncoder();
        pinLoginStrategy = new PinLoginStrategy(authHelper, pinCredentialRepository, passwordEncoder);

        sampleIdentity = Identity.builder()
                .publicId("id_cust_123")
                .identityType(IdentityType.CUSTOMER)
                .status("ACTIVE")
                .build();
        sampleIdentity.setId(100L);

        sampleCredential = PinCredential.builder()
                .identity(sampleIdentity)
                .pin(passwordEncoder.encode("4321"))
                .isSet(true)
                .failedAttempts(0)
                .build();
    }

    @Test
    @DisplayName("Should authenticate successfully with valid PIN on recognized device")
    void shouldAuthenticateSuccessfullyWithValidPinOnRecognizedDevice() {
        LoginRequest request = LoginRequest.builder()
                .identifier("+2348012345678")
                .pin("4321")
                .loginMethod(LoginMethod.PIN)
                .deviceId("dev-recognized-1")
                .deviceName("Primary iPhone")
                .build();

        AuthTokenResponse expectedResponse = AuthTokenResponse.builder()
                .accessToken("mock-access-token")
                .refreshToken("mock-refresh-token")
                .build();

        when(authHelper.resolveIdentity("+2348012345678", IdentityType.CUSTOMER)).thenReturn(sampleIdentity);
        when(pinCredentialRepository.findByIdentityId(100L)).thenReturn(Optional.of(sampleCredential));
        when(authHelper.isNewDevice(sampleIdentity, "dev-recognized-1")).thenReturn(false);
        when(authHelper.issueTokensAndCreateSession(sampleIdentity, "dev-recognized-1", "Primary iPhone", null, null))
                .thenReturn(expectedResponse);

        AuthTokenResponse response = pinLoginStrategy.authenticate(request);

        assertThat(response).isNotNull();
        assertThat(response.getAccessToken()).isEqualTo("mock-access-token");
        assertThat(sampleCredential.getFailedAttempts()).isZero();
        verify(pinCredentialRepository).save(sampleCredential);
    }

    @Test
    @DisplayName("Should trigger step-up OTP challenge when logging in from new unrecognized device")
    void shouldTriggerNewDeviceVerificationWhenDeviceIsUnrecognized() {
        LoginRequest request = LoginRequest.builder()
                .identifier("+2348012345678")
                .pin("4321")
                .loginMethod(LoginMethod.PIN)
                .deviceId("dev-new-samsung")
                .deviceName("Samsung Galaxy S24")
                .build();

        AuthTokenResponse challengeResponse = AuthTokenResponse.builder()
                .requiresOtp(true)
                .requiresDeviceVerification(true)
                .challengeToken("mock-challenge-token")
                .otpRecipientMasked("+23480******78")
                .message("New device detected.")
                .build();

        when(authHelper.resolveIdentity("+2348012345678", IdentityType.CUSTOMER)).thenReturn(sampleIdentity);
        when(pinCredentialRepository.findByIdentityId(100L)).thenReturn(Optional.of(sampleCredential));
        when(authHelper.isNewDevice(sampleIdentity, "dev-new-samsung")).thenReturn(true);
        when(authHelper.triggerNewDeviceVerification(sampleIdentity, "dev-new-samsung", "Samsung Galaxy S24"))
                .thenReturn(challengeResponse);

        AuthTokenResponse response = pinLoginStrategy.authenticate(request);

        assertThat(response).isNotNull();
        assertThat(response.isRequiresOtp()).isTrue();
        assertThat(response.isRequiresDeviceVerification()).isTrue();
        assertThat(response.getMessage()).contains("New device detected");
    }

    @Test
    @DisplayName("Should reject invalid PIN and increment failed attempts")
    void shouldRejectInvalidPinAndIncrementAttempts() {
        LoginRequest request = LoginRequest.builder()
                .identifier("+2348012345678")
                .pin("9999")
                .loginMethod(LoginMethod.PIN)
                .deviceId("dev-1")
                .build();

        when(authHelper.resolveIdentity("+2348012345678", IdentityType.CUSTOMER)).thenReturn(sampleIdentity);
        when(pinCredentialRepository.findByIdentityId(100L)).thenReturn(Optional.of(sampleCredential));

        assertThatThrownBy(() -> pinLoginStrategy.authenticate(request))
                .isInstanceOf(InvalidPinException.class)
                .hasMessageContaining("2 attempt(s) remaining");

        assertThat(sampleCredential.getFailedAttempts()).isEqualTo(1);
        verify(pinCredentialRepository).save(sampleCredential);
    }

    @Test
    @DisplayName("Should lock account for 15 minutes after 3 consecutive failed PIN attempts")
    void shouldLockAccountAfter3FailedAttempts() {
        sampleCredential.setFailedAttempts(2);

        LoginRequest request = LoginRequest.builder()
                .identifier("+2348012345678")
                .pin("9999")
                .loginMethod(LoginMethod.PIN)
                .deviceId("dev-1")
                .build();

        when(authHelper.resolveIdentity("+2348012345678", IdentityType.CUSTOMER)).thenReturn(sampleIdentity);
        when(pinCredentialRepository.findByIdentityId(100L)).thenReturn(Optional.of(sampleCredential));

        assertThatThrownBy(() -> pinLoginStrategy.authenticate(request))
                .isInstanceOf(InvalidPinException.class)
                .hasMessageContaining("Maximum attempts reached. Your PIN has been locked for 15 minutes");

        assertThat(sampleCredential.getFailedAttempts()).isEqualTo(3);
        assertThat(sampleCredential.getLockedUntil()).isNotNull();
        verify(pinCredentialRepository).save(sampleCredential);
    }

    @Test
    @DisplayName("Should reject login when PIN is currently locked")
    void shouldRejectWhenPinIsCurrentlyLocked() {
        sampleCredential.setLockedUntil(Instant.now().plus(10, ChronoUnit.MINUTES));

        LoginRequest request = LoginRequest.builder()
                .identifier("+2348012345678")
                .pin("4321")
                .loginMethod(LoginMethod.PIN)
                .deviceId("dev-1")
                .build();

        when(authHelper.resolveIdentity("+2348012345678", IdentityType.CUSTOMER)).thenReturn(sampleIdentity);
        when(pinCredentialRepository.findByIdentityId(100L)).thenReturn(Optional.of(sampleCredential));

        assertThatThrownBy(() -> pinLoginStrategy.authenticate(request))
                .isInstanceOf(InvalidPinException.class)
                .hasMessageContaining("PIN is temporarily locked");
    }

    @Test
    @DisplayName("Should reject invalid PIN format (non 4-digit)")
    void shouldRejectNonFourDigitPin() {
        LoginRequest request = LoginRequest.builder()
                .identifier("+2348012345678")
                .pin("12")
                .loginMethod(LoginMethod.PIN)
                .build();

        assertThatThrownBy(() -> pinLoginStrategy.authenticate(request))
                .isInstanceOf(ValidationException.class)
                .hasMessageContaining("A valid 4-digit numeric PIN is required");
    }
}
