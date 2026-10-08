package io.tranzfa.core.auth.service.impl;

import io.tranzfa.core.auth.model.entity.Identity;
import io.tranzfa.core.auth.model.entity.OtpToken;
import io.tranzfa.core.auth.model.enums.OtpChannel;
import io.tranzfa.core.auth.model.enums.OtpPurpose;
import io.tranzfa.core.auth.repository.OtpTokenRepository;
import io.tranzfa.core.auth.service.OtpService;
import io.tranzfa.core.common.exception.UnauthorizedException;
import io.tranzfa.core.config.AppProperties;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.temporal.ChronoUnit;

@Slf4j
@Service
@RequiredArgsConstructor
@ConditionalOnProperty(name = "app.otp.mock-mode", havingValue = "true")
public class MockOtpServiceImpl implements OtpService {

    public static final String DEFAULT_MOCK_OTP = "123456";

    private final OtpTokenRepository otpTokenRepository;
    private final AppProperties appProperties;

    @Override
    @Transactional
    public OtpToken generateAndSendOtp(String recipient, OtpPurpose purpose, OtpChannel channel, Identity identity) {
        int expiryMinutes = appProperties.otp() != null && appProperties.otp().expiryMinutes() > 0
                ? appProperties.otp().expiryMinutes()
                : 10;

        OtpToken otpToken = OtpToken.builder()
                .identity(identity)
                .recipient(recipient)
                .otpCode(DEFAULT_MOCK_OTP)
                .purpose(purpose)
                .channel(channel != null ? channel : OtpChannel.SMS)
                .expiryTime(Instant.now().plus(expiryMinutes, ChronoUnit.MINUTES))
                .isVerified(false)
                .build();

        OtpToken saved = otpTokenRepository.save(otpToken);

        log.info("=================================================================");
        log.info("[MOCK OTP] Initiating OTP for recipient: {}, purpose: {}, channel: {}", recipient, purpose, channel);
        log.info("[MOCK OTP] USE THIS CODE FOR VERIFICATION: {}", DEFAULT_MOCK_OTP);
        log.info("=================================================================");

        return saved;
    }

    @Override
    @Transactional
    public boolean verifyOtp(String recipient, String otpCode, OtpPurpose purpose) {
        log.info("[MOCK OTP] Verifying OTP: {} for recipient: {}, purpose: {}", otpCode, recipient, purpose);

        if (!DEFAULT_MOCK_OTP.equals(otpCode)) {
            throw new UnauthorizedException("Invalid verification code. Please check and try again.");
        }

        OtpToken otpToken = otpTokenRepository
                .findTopByRecipientAndPurposeAndIsVerifiedFalseOrderByCreatedOnDesc(recipient, purpose)
                .orElse(null);

        if (otpToken != null) {
            if (otpToken.isExpired()) {
                throw new UnauthorizedException("Verification code has expired. Please request a new code.");
            }
            otpToken.setVerified(true);
            otpTokenRepository.save(otpToken);
        }

        log.info("[MOCK OTP] Verification successful for recipient: {} (purpose: {})", recipient, purpose);
        return true;
    }
}
