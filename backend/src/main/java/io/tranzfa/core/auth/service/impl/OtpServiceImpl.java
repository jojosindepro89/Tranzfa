package io.tranzfa.core.auth.service.impl;

import io.tranzfa.core.auth.model.entity.Identity;
import io.tranzfa.core.auth.model.entity.OtpToken;
import io.tranzfa.core.auth.model.enums.OtpChannel;
import io.tranzfa.core.auth.model.enums.OtpPurpose;
import io.tranzfa.core.auth.repository.OtpTokenRepository;
import io.tranzfa.core.auth.service.OtpService;
import io.tranzfa.core.common.exception.UnauthorizedException;
import io.tranzfa.core.common.util.CodeGenerationUtil;
import io.tranzfa.core.config.AppProperties;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.temporal.ChronoUnit;

@Slf4j
@Service
@RequiredArgsConstructor
@ConditionalOnProperty(name = "app.otp.mock-mode", havingValue = "false", matchIfMissing = true)
public class OtpServiceImpl implements OtpService {

    private final OtpTokenRepository otpTokenRepository;
    private final AppProperties appProperties;

    @Override
    @Transactional
    public OtpToken generateAndSendOtp(String recipient, OtpPurpose purpose, OtpChannel channel, Identity identity) {
        int expiryMinutes = appProperties.otp() != null && appProperties.otp().expiryMinutes() > 0
                ? appProperties.otp().expiryMinutes()
                : 10;

        String code = CodeGenerationUtil.generateOtp(6);

        OtpToken otpToken = OtpToken.builder()
                .identity(identity)
                .recipient(recipient)
                .otpCode(code)
                .purpose(purpose)
                .channel(channel != null ? channel : OtpChannel.SMS)
                .expiryTime(Instant.now().plus(expiryMinutes, ChronoUnit.MINUTES))
                .isVerified(false)
                .build();

        OtpToken saved = otpTokenRepository.save(otpToken);

        // Simulated SMS / Push notification dispatch
        log.info("=================================================================");
        log.info(">> [OTP DISPATCH] Recipient: {}, Purpose: {}, Channel: {}, Code: {}",
                recipient, purpose, channel, code);
        log.info("=================================================================");

        return saved;
    }

    @Override
    @Transactional
    public boolean verifyOtp(String recipient, String otpCode, OtpPurpose purpose) {
        OtpToken otpToken = otpTokenRepository
                .findTopByRecipientAndOtpCodeAndPurposeAndIsVerifiedFalseOrderByCreatedOnDesc(recipient, otpCode, purpose)
                .orElseThrow(() -> new UnauthorizedException("Invalid verification code. Please check and try again."));

        if (otpToken.isExpired()) {
            throw new UnauthorizedException("Verification code has expired. Please request a new code.");
        }

        otpToken.setVerified(true);
        otpTokenRepository.save(otpToken);
        log.info("OTP successfully verified for recipient: {} (purpose: {})", recipient, purpose);
        return true;
    }
}
