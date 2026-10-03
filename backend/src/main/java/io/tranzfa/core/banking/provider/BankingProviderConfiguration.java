package io.tranzfa.core.banking.provider;

import io.tranzfa.core.banking.provider.adapter.MockBankingProvider;
import io.tranzfa.core.banking.provider.adapter.SafeHavenBankingProvider;
import io.tranzfa.core.config.AppProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

@Configuration
public class BankingProviderConfiguration {

    @Bean
    @Primary
    public CoreBankingProvider coreBankingProvider(
            AppProperties appProperties,
            SafeHavenBankingProvider safeHavenBankingProvider,
            MockBankingProvider mockBankingProvider) {

        if (appProperties.safeHaven() != null && appProperties.safeHaven().mockMode()) {
            return mockBankingProvider;
        }
        return safeHavenBankingProvider;
    }
}
