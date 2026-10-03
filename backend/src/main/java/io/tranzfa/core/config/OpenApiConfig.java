package io.tranzfa.core.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class OpenApiConfig {

    private static final String SECURITY_SCHEME_NAME = "BearerAuthentication";

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Tranzfa FinTech Core Banking Service API")
                        .version("1.0.0")
                        .description("Production Core Banking API for Tranzfa Digital Bank powered by SafeHaven MFB BaaS. " +
                                "Supports 3-Factor Multi-Factor Authentication (3FA), dedicated NUBAN account generation, " +
                                "NIBSS instant transfers, double-entry financial ledger accounting, VTU utility payments, " +
                                "FX stablecoin swaps, virtual cards, and high-yield savings vaults.")
                        .contact(new Contact()
                                .name("Tranzfa Engineering Team")
                                .email("engineering@tranzfa.io")
                                .url("https://tranzfa.io"))
                        .license(new License()
                                .name("Proprietary")
                                .url("https://tranzfa.io/terms")))
                .servers(List.of(
                        new Server().url("http://localhost:8080").description("Local Development Server"),
                        new Server().url("https://api.tranzfa.io").description("Production Gateway")))
                .addSecurityItem(new SecurityRequirement().addList(SECURITY_SCHEME_NAME))
                .components(new Components()
                        .addSecuritySchemes(SECURITY_SCHEME_NAME, new SecurityScheme()
                                .name(SECURITY_SCHEME_NAME)
                                .type(SecurityScheme.Type.HTTP)
                                .scheme("bearer")
                                .bearerFormat("JWT")
                                .description("Provide the JWT Bearer token issued upon completing Factor 2 OTP verification.")));
    }
}
