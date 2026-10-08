package io.tranzfa.core.auth.service;

import io.tranzfa.core.auth.model.entity.OtpToken;
import io.tranzfa.core.auth.model.enums.OtpChannel;
import io.tranzfa.core.auth.model.enums.OtpPurpose;
import io.tranzfa.core.auth.repository.OtpTokenRepository;
import io.tranzfa.core.auth.service.impl.MockOtpServiceImpl;
import io.tranzfa.core.common.exception.UnauthorizedException;
import io.tranzfa.core.config.AppProperties;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class MockOtpServiceTest {

    @Mock
    private OtpTokenRepository otpTokenRepository;

    private AppProperties appProperties;
    private MockOtpServiceImpl mockOtpService;

    @BeforeEach
    void setUp() {
        appProperties = new AppProperties(
                null, null, null,
                new AppProperties.Otp(10, true),
                null, null, null, null
        );
        mockOtpService = new MockOtpServiceImpl(otpTokenRepository, appProperties);
    }

    @Test
    @DisplayName("generateAndSendOtp should allocate 123456 as the OTP code in mock mode")
    void shouldGenerateMockOtpCode123456() {
        when(otpTokenRepository.save(any(OtpToken.class))).thenAnswer(invocation -> invocation.getArgument(0));

        OtpToken result = mockOtpService.generateAndSendOtp("+2348012345678", OtpPurpose.REGISTRATION, OtpChannel.SMS, null);

        assertThat(result.getOtpCode()).isEqualTo("123456");
        assertThat(result.getRecipient()).isEqualTo("+2348012345678");
        assertThat(result.getPurpose()).isEqualTo(OtpPurpose.REGISTRATION);
        assertThat(result.isVerified()).isFalse();

        ArgumentCaptor<OtpToken> captor = ArgumentCaptor.forClass(OtpToken.class);
        verify(otpTokenRepository).save(captor.capture());
        assertThat(captor.getValue().getOtpCode()).isEqualTo("123456");
    }

    @Test
    @DisplayName("verifyOtp should successfully verify when provided code is 123456")
    void shouldVerifySuccessfullyWith123456() {
        OtpToken token = OtpToken.builder()
                .recipient("+2348012345678")
                .otpCode("123456")
                .purpose(OtpPurpose.REGISTRATION)
                .expiryTime(Instant.now().plus(5, ChronoUnit.MINUTES))
                .isVerified(false)
                .build();

        when(otpTokenRepository.findTopByRecipientAndPurposeAndIsVerifiedFalseOrderByCreatedOnDesc(
                "+2348012345678", OtpPurpose.REGISTRATION)).thenReturn(Optional.of(token));

        boolean verified = mockOtpService.verifyOtp("+2348012345678", "123456", OtpPurpose.REGISTRATION);

        assertThat(verified).isTrue();
        assertThat(token.isVerified()).isTrue();
        verify(otpTokenRepository).save(token);
    }

    @Test
    @DisplayName("verifyOtp should throw UnauthorizedException when code is not 123456")
    void shouldRejectInvalidMockCode() {
        assertThatThrownBy(() -> mockOtpService.verifyOtp("+2348012345678", "999999", OtpPurpose.REGISTRATION))
                .isInstanceOf(UnauthorizedException.class)
                .hasMessageContaining("Invalid verification code");
    }

    @Test
    @DisplayName("verifyOtp should throw UnauthorizedException when mock token is expired")
    void shouldRejectExpiredToken() {
        OtpToken expiredToken = OtpToken.builder()
                .recipient("+2348012345678")
                .otpCode("123456")
                .purpose(OtpPurpose.REGISTRATION)
                .expiryTime(Instant.now().minus(1, ChronoUnit.MINUTES))
                .isVerified(false)
                .build();

        when(otpTokenRepository.findTopByRecipientAndPurposeAndIsVerifiedFalseOrderByCreatedOnDesc(
                "+2348012345678", OtpPurpose.REGISTRATION)).thenReturn(Optional.of(expiredToken));

        assertThatThrownBy(() -> mockOtpService.verifyOtp("+2348012345678", "123456", OtpPurpose.REGISTRATION))
                .isInstanceOf(UnauthorizedException.class)
                .hasMessageContaining("expired");
    }
}
