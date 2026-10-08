package io.tranzfa.core.auth.strategy;

import io.tranzfa.core.auth.dto.AuthTokenResponse;
import io.tranzfa.core.auth.dto.LoginRequest;
import io.tranzfa.core.auth.model.entity.Identity;
import io.tranzfa.core.auth.model.entity.PasswordCredential;
import io.tranzfa.core.auth.model.enums.LoginMethod;
import io.tranzfa.core.auth.repository.PasswordCredentialRepository;
import io.tranzfa.core.auth.service.AuthHelper;
import io.tranzfa.core.common.exception.UnauthorizedException;
import io.tranzfa.core.common.exception.ValidationException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;
import java.time.temporal.ChronoUnit;

@Slf4j
@Component
@RequiredArgsConstructor
public class PasswordLoginStrategy implements LoginStrategy {

    private static final int MAX_FAILED_ATTEMPTS = 5;
    private static final int LOCKOUT_MINUTES = 15;

    private final AuthHelper authHelper;
    private final PasswordCredentialRepository passwordCredentialRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public LoginMethod getSupportedMethod() {
        return LoginMethod.PASSWORD;
    }

    @Override
    @Transactional
    public AuthTokenResponse authenticate(LoginRequest request) {
        if (request.getPassword() == null || request.getPassword().isBlank()) {
            throw new ValidationException("Password is required for password login.");
        }

        Identity identity = authHelper.resolveIdentity(request.getIdentifier(), request.getUserType());

        PasswordCredential credential = passwordCredentialRepository.findByIdentityId(identity.getId())
                .orElseThrow(() -> new UnauthorizedException("No password credentials configured for this account."));

        if (credential.isLocked()) {
            long remainingMins = Duration.between(Instant.now(), credential.getLockedUntil()).toMinutes() + 1;
            throw new UnauthorizedException(
                    String.format("Account is temporarily locked due to consecutive failed password attempts. Try again in %d minute(s).", remainingMins));
        }

        boolean matches = passwordEncoder.matches(request.getPassword(), credential.getPassword());
        if (!matches) {
            int attempts = credential.getFailedAttempts() + 1;
            credential.setFailedAttempts(attempts);

            if (attempts >= MAX_FAILED_ATTEMPTS) {
                credential.setLockedUntil(Instant.now().plus(LOCKOUT_MINUTES, ChronoUnit.MINUTES));
                passwordCredentialRepository.save(credential);
                throw new UnauthorizedException(
                        String.format("Invalid credentials. Maximum attempts reached. Account locked for %d minutes.", LOCKOUT_MINUTES));
            } else {
                passwordCredentialRepository.save(credential);
                throw new UnauthorizedException(
                        String.format("Invalid credentials. %d attempt(s) remaining.", (MAX_FAILED_ATTEMPTS - attempts)));
            }
        }

        // Reset failed attempts on success
        credential.setFailedAttempts(0);
        credential.setLockedUntil(null);
        credential.setLastLoginOn(Instant.now());
        passwordCredentialRepository.save(credential);

        // New Device Step-Up Verification: Check if device is unrecognized
        if (authHelper.isNewDevice(identity, request.getDeviceId())) {
            return authHelper.triggerNewDeviceVerification(identity, request.getDeviceId(), request.getDeviceName());
        }

        return authHelper.issueTokensAndCreateSession(
                identity,
                request.getDeviceId(),
                request.getDeviceName(),
                null,
                null);
    }
}
