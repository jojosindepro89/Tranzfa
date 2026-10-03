package io.tranzfa.core.filter;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import io.tranzfa.core.common.constant.SecurityConstants;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.AuthorityUtils;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.web.servlet.HandlerExceptionResolver;

import javax.crypto.SecretKey;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Collection;
import java.util.Collections;
import java.util.Set;
import java.util.stream.Collectors;

@Slf4j
public class JwtVerificationFilter extends OncePerRequestFilter {

    private final HandlerExceptionResolver exceptionResolver;

    public JwtVerificationFilter(HandlerExceptionResolver exceptionResolver) {
        this.exceptionResolver = exceptionResolver;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        String jwtHeader = request.getHeader(SecurityConstants.JWT_HEADER);

        if (StringUtils.isNotBlank(jwtHeader) && jwtHeader.startsWith(SecurityConstants.JWT_PREFIX)) {
            String jwt = jwtHeader.substring(SecurityConstants.JWT_PREFIX.length()).trim();
            try {
                String jwtKey = getEnvironment().getProperty(
                        SecurityConstants.JWT_SECRET_CONFIG_KEY,
                        SecurityConstants.JWT_SECRET_DEFAULT_VALUE);
                SecretKey key = Keys.hmacShaKeyFor(jwtKey.getBytes(StandardCharsets.UTF_8));

                Claims claims = Jwts.parser()
                        .verifyWith(key)
                        .build()
                        .parseSignedClaims(jwt)
                        .getPayload();

                String username = claims.get(SecurityConstants.USERNAME_CLAIM, String.class);
                if (username == null) {
                    username = claims.getSubject();
                }

                Object rawAuthorities = claims.get(SecurityConstants.AUTHORITY_CLAIM);
                Set<String> authorities = Collections.emptySet();
                if (rawAuthorities instanceof Collection<?> authList) {
                    authorities = authList.stream()
                            .map(Object::toString)
                            .collect(Collectors.toSet());
                }

                Object userId = claims.get(SecurityConstants.USER_ID_CLAIM);
                Authentication auth = new UsernamePasswordAuthenticationToken(
                        username,
                        userId,
                        AuthorityUtils.createAuthorityList(authorities.toArray(new String[0])));

                SecurityContextHolder.getContext().setAuthentication(auth);
            } catch (Exception e) {
                log.error("JWT token validation error: {}", e.getMessage());
                exceptionResolver.resolveException(
                        request,
                        response,
                        null,
                        new BadCredentialsException(SecurityConstants.INVALID_TOKEN_MSG));
                return;
            }
        }
        filterChain.doFilter(request, response);
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getServletPath();
        return path.startsWith("/api/v1/auth/login")
                || path.startsWith("/api/v1/auth/initiate-phone")
                || path.startsWith("/api/v1/auth/verify-phone-otp")
                || path.startsWith("/api/v1/auth/personal-details")
                || path.startsWith("/api/v1/auth/refresh-token")
                || path.startsWith("/api/v1/auth/verify-otp")
                || path.startsWith("/api/v1/auth/resend-otp")
                || path.startsWith("/api/v1/webhooks/")
                || path.startsWith("/v3/api-docs")
                || path.startsWith("/swagger-ui")
                || path.startsWith("/actuator");
    }
}
