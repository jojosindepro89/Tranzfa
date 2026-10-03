package io.tranzfa.core.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.web.client.RestClient;

import java.time.Duration;

@Configuration
public class RestClientConfig {

    private final AppProperties appProperties;

    public RestClientConfig(AppProperties appProperties) {
        this.appProperties = appProperties;
    }

    @Bean
    public RestClient safeHavenRestClient() {
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(Duration.ofSeconds(10));
        factory.setReadTimeout(Duration.ofSeconds(20));

        String baseUrl = (appProperties.safeHaven() != null && appProperties.safeHaven().baseUrl() != null)
                ? appProperties.safeHaven().baseUrl()
                : "https://api.sandbox.safehavenmfb.com";

        return RestClient.builder()
                .baseUrl(baseUrl)
                .requestFactory(factory)
                .defaultHeader("Accept", "application/json")
                .defaultHeader("Content-Type", "application/json")
                .build();
    }
}
