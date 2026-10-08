package io.tranzfa.core.auth.provider.config;

import io.tranzfa.core.auth.provider.WebAuthnProvider;
import io.tranzfa.core.auth.provider.adapter.MockWebAuthnProvider;
import io.tranzfa.core.auth.provider.adapter.YubicoWebAuthnProvider;
import io.tranzfa.core.config.AppProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

/**
 * Pluggable Spring Configuration for WebAuthn Provider.
 * Allows seamless switching between Yubico production adapter and Mock testing adapter.
 */
@Configuration
public class WebAuthnProviderConfiguration {

    @Bean
    @Primary
    public WebAuthnProvider webAuthnProvider(
            AppProperties appProperties,
            YubicoWebAuthnProvider yubicoWebAuthnProvider,
            MockWebAuthnProvider mockWebAuthnProvider) {

        if (appProperties.passkey() != null && appProperties.passkey().mockMode()) {
            return mockWebAuthnProvider;
        }
        return yubicoWebAuthnProvider;
    }
}
