package io.tranzfa.core.auth.provider.config;

import io.tranzfa.core.auth.provider.WebAuthnProvider;
import io.tranzfa.core.auth.provider.adapter.MockWebAuthnProvider;
import io.tranzfa.core.auth.provider.adapter.YubicoWebAuthnProvider;
import io.tranzfa.core.config.AppProperties;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Set;

import static org.assertj.core.api.Assertions.assertThat;

@ExtendWith(MockitoExtension.class)
class WebAuthnProviderConfigurationTest {

    @Mock
    private YubicoWebAuthnProvider yubicoWebAuthnProvider;

    @Mock
    private MockWebAuthnProvider mockWebAuthnProvider;

    private final WebAuthnProviderConfiguration configuration = new WebAuthnProviderConfiguration();

    @Test
    @DisplayName("Should select MockWebAuthnProvider when mock-mode is enabled")
    void shouldSelectMockProviderWhenMockModeEnabled() {
        AppProperties.Passkey passkey = new AppProperties.Passkey("tranzfa.io", "Tranzfa", Set.of(), true, 300L);
        AppProperties appProperties = new AppProperties(null, null, null, null, null, null, null, passkey);

        WebAuthnProvider provider = configuration.webAuthnProvider(appProperties, yubicoWebAuthnProvider, mockWebAuthnProvider);

        assertThat(provider).isSameAs(mockWebAuthnProvider);
    }

    @Test
    @DisplayName("Should select YubicoWebAuthnProvider when mock-mode is disabled")
    void shouldSelectYubicoProviderWhenMockModeDisabled() {
        AppProperties.Passkey passkey = new AppProperties.Passkey("tranzfa.io", "Tranzfa", Set.of(), false, 300L);
        AppProperties appProperties = new AppProperties(null, null, null, null, null, null, null, passkey);

        WebAuthnProvider provider = configuration.webAuthnProvider(appProperties, yubicoWebAuthnProvider, mockWebAuthnProvider);

        assertThat(provider).isSameAs(yubicoWebAuthnProvider);
    }
}
