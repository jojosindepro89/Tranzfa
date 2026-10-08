package io.tranzfa.core.config;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(classes = AppPropertiesBindingTest.TestConfig.class)
@TestPropertySource(properties = {
        "app.safe-haven.base-url=https://api.sandbox.safehavenmfb.com",
        "app.safe-haven.client-id=sh_test_client",
        "app.safe-haven.client-assertion=assertion",
        "app.safe-haven.client-secret=secret",
        "app.safe-haven.account-id=acct_001",
        "app.safe-haven.webhook-secret=whsec_test",
        "app.safe-haven.mock-mode=true",
        "app.safe-haven.default-bank-code=090286",
        "app.safe-haven.default-bank-name=Safe Haven Microfinance Bank",
        "app.security.max-failed-attempts=3",
        "app.security.lock-duration-minutes=15",
        "app.security.pin-history-size=3",
        "app.security.password-history-size=5",
        "app.totp.digits=6",
        "app.totp.period-seconds=300",
        "app.totp.algorithm=SHA1",
        "app.otp.expiry-minutes=5",
        "app.otp.mock-mode=true",
        "app.jwt.secret=tranzfa_super_secret_jwt_key_2026_fintech_production_signature_key_min_256_bits!",
        "app.jwt.access-token-expiration-ms=900000",
        "app.jwt.refresh-token-expiration-ms=604800000",
        "app.jwt.mobile-ttl=432000000",
        "app.jwt.web-ttl=86400000",
        "app.banking.cbn-anti-fraud-threshold-ngn=500000.0",
        "app.banking.tier1-daily-limit-ngn=50000.0",
        "app.banking.tier2-daily-limit-ngn=200000.0",
        "app.banking.tier3-daily-limit-ngn=10000000.0",
        "app.banking.interbank-transfer-fee-ngn=10.75",
        "app.banking.device-switch-cooldown-limit-ngn=20000.0",
        "app.banking.device-switch-cooldown-hours=24",
        "app.async.core-pool-size=4",
        "app.async.max-pool-size=10",
        "app.async.queue-capacity=50",
        "app.async.thread-name-prefix=TranzfaAsync-",
        "app.passkey.rp-id=tranzfa.io",
        "app.passkey.rp-name=Tranzfa Core Banking",
        "app.passkey.origins=https://tranzfa.io,https://app.tranzfa.io",
        "app.passkey.mock-mode=true",
        "app.passkey.timeout-seconds=300"
})
class AppPropertiesBindingTest {

    @EnableConfigurationProperties(AppProperties.class)
    static class TestConfig {
    }

    @Autowired
    private AppProperties appProperties;

    @Test
    @DisplayName("Should successfully bind AppProperties record from Spring properties via constructor binding")
    void shouldBindAppPropertiesSuccessfully() {
        assertThat(appProperties).isNotNull();
        assertThat(appProperties.safeHaven().mockMode()).isTrue();
        assertThat(appProperties.otp().mockMode()).isTrue();
        assertThat(appProperties.passkey().mockMode()).isTrue();
        assertThat(appProperties.passkey().rpId()).isEqualTo("tranzfa.io");
        assertThat(appProperties.banking().tier3DailyLimitNgn()).isEqualTo(10000000.0);
    }
}
