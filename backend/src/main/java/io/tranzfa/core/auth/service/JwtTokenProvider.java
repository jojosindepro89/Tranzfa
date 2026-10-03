package io.tranzfa.core.auth.service;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import io.tranzfa.core.auth.model.entity.Identity;
import io.tranzfa.core.auth.model.enums.KycTier;
import io.tranzfa.core.common.constant.SecurityConstants;
import io.tranzfa.core.common.exception.UnauthorizedException;
import io.tranzfa.core.config.AppProperties;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;
import java.util.List;

@Slf4j
@Component
public class JwtTokenProvider {

    private final SecretKey key;
    private final long accessTokenExpirationMs;
    private final long refreshTokenExpirationMs;

    public JwtTokenProvider(AppProperties appProperties) {
        String secret = appProperties.jwt() != null && appProperties.jwt().secret() != null
                ? appProperties.jwt().secret()
                : SecurityConstants.JWT_SECRET_DEFAULT_VALUE;
        this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.accessTokenExpirationMs = appProperties.jwt() != null && appProperties.jwt().accessTokenExpirationMs() > 0
                ? appProperties.jwt().accessTokenExpirationMs()
                : 86400000L; // 24 hours fallback
        this.refreshTokenExpirationMs = appProperties.jwt() != null && appProperties.jwt().refreshTokenExpirationMs() > 0
                ? appProperties.jwt().refreshTokenExpirationMs()
                : 604800000L; // 7 days fallback
    }

    public String generateAccessToken(
            Identity identity,
            String username,
            List<String> authorities,
            KycTier kycTier,
            String accountNumber) {
        Instant now = Instant.now();
        Instant expiry = now.plusMillis(accessTokenExpirationMs);

        var builder = Jwts.builder()
                .subject(username)
                .claim(SecurityConstants.USER_ID_CLAIM, identity.getId())
                .claim("publicId", identity.getPublicId())
                .claim("userType", identity.getIdentityType().name())
                .claim(SecurityConstants.USERNAME_CLAIM, username)
                .claim(SecurityConstants.AUTHORITY_CLAIM, authorities)
                .issuedAt(Date.from(now))
                .expiration(Date.from(expiry))
                .signWith(key);

        if (kycTier != null) {
            builder.claim(SecurityConstants.KYC_TIER_CLAIM, kycTier.name());
        }
        if (accountNumber != null) {
            builder.claim(SecurityConstants.ACCOUNT_NUMBER_CLAIM, accountNumber);
        }

        return builder.compact();
    }

    public String generateRefreshToken(Identity identity) {
        Instant now = Instant.now();
        Instant expiry = now.plusMillis(refreshTokenExpirationMs);

        return Jwts.builder()
                .subject(identity.getId().toString())
                .claim("publicId", identity.getPublicId())
                .claim("tokenType", "REFRESH")
                .issuedAt(Date.from(now))
                .expiration(Date.from(expiry))
                .signWith(key)
                .compact();
    }

    public String generateVerificationToken(String phone) {
        Instant now = Instant.now();
        Instant expiry = now.plusSeconds(900); // 15 minutes

        return Jwts.builder()
                .subject(phone)
                .claim("purpose", "PHONE_VERIFIED")
                .issuedAt(Date.from(now))
                .expiration(Date.from(expiry))
                .signWith(key)
                .compact();
    }

    public void validateVerificationToken(String token, String expectedPhone) {
        try {
            Claims claims = getClaims(token);
            if (!"PHONE_VERIFIED".equals(claims.get("purpose", String.class))) {
                throw new UnauthorizedException("Invalid token purpose.");
            }
            if (!expectedPhone.equals(claims.getSubject())) {
                throw new UnauthorizedException("Token phone number does not match registration phone number.");
            }
        } catch (JwtException | IllegalArgumentException e) {
            throw new UnauthorizedException("Phone verification token has expired or is invalid. Please verify phone again.");
        }
    }

    public Claims getClaims(String token) {
        return Jwts.parser()
                .verifyWith(key)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    public boolean validateToken(String token) {
        try {
            getClaims(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            log.warn("Invalid JWT token: {}", e.getMessage());
            return false;
        }
    }

    public long getAccessTokenExpirationSeconds() {
        return accessTokenExpirationMs / 1000;
    }
}
