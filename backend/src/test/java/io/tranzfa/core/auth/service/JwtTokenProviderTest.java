package io.tranzfa.core.auth.service;

import io.jsonwebtoken.Claims;
import io.tranzfa.core.auth.model.entity.Identity;
import io.tranzfa.core.auth.model.enums.IdentityType;
import io.tranzfa.core.auth.model.enums.KycTier;
import io.tranzfa.core.common.constant.SecurityConstants;
import io.tranzfa.core.config.AppProperties;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class JwtTokenProviderTest {

    private JwtTokenProvider jwtTokenProvider;
    private Identity sampleIdentity;

    @BeforeEach
    void setUp() {
        AppProperties.Jwt jwtProps = new AppProperties.Jwt(
                "tranzfa_super_secret_jwt_key_2026_fintech_production_signature_key_min_256_bits!",
                3600000L,
                86400000L,
                432000000L,
                86400000L
        );
        AppProperties appProperties = new AppProperties(null, null, null, null, jwtProps, null, null, null);
        jwtTokenProvider = new JwtTokenProvider(appProperties);

        sampleIdentity = Identity.builder()
                .publicId("id_cust_999")
                .identityType(IdentityType.CUSTOMER)
                .status("ACTIVE")
                .build();
        sampleIdentity.setId(42L);
    }

    @Test
    @DisplayName("Should generate valid Access Token with complete claims")
    void shouldGenerateValidAccessToken() {
        String token = jwtTokenProvider.generateAccessToken(
                sampleIdentity,
                "sarah@example.com",
                List.of("ROLE_CUSTOMER"),
                KycTier.TIER_1,
                "2001928374"
        );

        assertThat(token).isNotBlank();
        assertThat(jwtTokenProvider.validateToken(token)).isTrue();

        Claims claims = jwtTokenProvider.getClaims(token);
        assertThat(claims.getSubject()).isEqualTo("sarah@example.com");
        assertThat(claims.get("publicId")).isEqualTo("id_cust_999");
        assertThat(claims.get("userType")).isEqualTo("CUSTOMER");
        assertThat(claims.get(SecurityConstants.ACCOUNT_NUMBER_CLAIM)).isEqualTo("2001928374");
        assertThat(claims.get(SecurityConstants.KYC_TIER_CLAIM)).isEqualTo("TIER_1");
    }

    @Test
    @DisplayName("Should generate and validate phone verification token")
    void shouldGenerateAndValidatePhoneVerificationToken() {
        String token = jwtTokenProvider.generateVerificationToken("+2348012345678");

        assertThat(token).isNotBlank();
        assertThat(jwtTokenProvider.validateToken(token)).isTrue();

        // Validating with matching phone should succeed without throwing
        jwtTokenProvider.validateVerificationToken(token, "+2348012345678");
    }
}
