package io.tranzfa.core.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "app")
public record AppProperties(
        SafeHaven safeHaven,
        Security security,
        Totp totp,
        Otp otp,
        Jwt jwt,
        Banking banking,
        Async async) {

    public record SafeHaven(
            String baseUrl,
            String clientId,
            String clientAssertion,
            String clientSecret,
            String accountId,
            String webhookSecret,
            boolean mockMode,
            String defaultBankCode,
            String defaultBankName) {
    }

    public record Security(
            int maxFailedAttempts,
            int lockDurationMinutes,
            int pinHistorySize,
            int passwordHistorySize) {
    }

    public record Totp(
            int digits,
            long periodSeconds,
            String algorithm) {
    }

    public record Otp(
            int expiryMinutes,
            boolean mockMode) {
    }

    public record Jwt(
            String secret,
            long accessTokenExpirationMs,
            long refreshTokenExpirationMs,
            long mobileTtl,
            long webTtl) {
    }

    public record Banking(
            double cbnAntiFraudThresholdNgn,
            double tier1DailyLimitNgn,
            double tier2DailyLimitNgn,
            double tier3DailyLimitNgn,
            double interbankTransferFeeNgn) {
    }

    public record Async(
            int corePoolSize,
            int maxPoolSize,
            int queueCapacity,
            String threadNamePrefix) {
    }
}
