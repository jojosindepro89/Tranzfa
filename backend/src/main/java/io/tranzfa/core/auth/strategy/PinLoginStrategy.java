package io.tranzfa.core.auth.strategy;

import io.tranzfa.core.auth.dto.AuthTokenResponse;
import io.tranzfa.core.auth.dto.LoginRequest;
import io.tranzfa.core.auth.model.entity.Identity;
import io.tranzfa.core.auth.model.entity.PinCredential;
import io.tranzfa.core.auth.model.enums.LoginMethod;
import io.tranzfa.core.auth.repository.PinCredentialRepository;
import io.tranzfa.core.auth.service.AuthHelper;
import io.tranzfa.core.common.exception.InvalidPinException;
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
public class PinLoginStrategy implements LoginStrategy {

    private static final int MAX_FAILED_ATTEMPTS = 3;
    private static final int LOCKOUT_MINUTES = 15;

    private final AuthHelper authHelper;
    private final PinCredentialRepository pinCredentialRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public LoginMethod getSupportedMethod() {
        return LoginMethod.PIN;
    }

    @Override
    @Transactional
    public AuthTokenResponse authenticate(LoginRequest request) {
        if (request.getPin() == null || !request.getPin().matches("^[0-9]{4}$")) {
            throw new ValidationException("A valid 4-digit numeric PIN is required for PIN login.");
        }

        Identity identity = authHelper.resolveIdentity(request.getIdentifier(), request.getUserType());

        PinCredential credential = pinCredentialRepository.findByIdentityId(identity.getId())
                .orElseThrow(() -> new UnauthorizedException("No transaction/login PIN configured for this account."));

        if (!credential.isSet()) {
            throw new UnauthorizedException("PIN has not been configured yet. Please log in with password and set your 4-digit PIN first.");
        }

        if (credential.isLocked()) {
            long remainingMins = Duration.between(Instant.now(), credential.getLockedUntil()).toMinutes() + 1;
            throw new InvalidPinException(String.format(
                    "PIN is temporarily locked due to consecutive failed attempts. Try again in %d minute(s).", remainingMins));
        }

        boolean matches = passwordEncoder.matches(request.getPin(), credential.getPin());
        if (!matches) {
            int attempts = credential.getFailedAttempts() + 1;
            credential.setFailedAttempts(attempts);

            if (attempts >= MAX_FAILED_ATTEMPTS) {
                credential.setLockedUntil(Instant.now().plus(LOCKOUT_MINUTES, ChronoUnit.MINUTES));
                pinCredentialRepository.save(credential);
                log.warn("Identity ID {} PIN locked after {} failed attempts during PIN login.", identity.getId(), attempts);
                throw new InvalidPinException(String.format(
                        "Incorrect PIN. Maximum attempts reached. Your PIN has been locked for %d minutes.", LOCKOUT_MINUTES));
            } else {
                pinCredentialRepository.save(credential);
                int remaining = MAX_FAILED_ATTEMPTS - attempts;
                throw new InvalidPinException(String.format(
                        "Incorrect PIN. %d attempt(s) remaining before lockout.", remaining));
            }
        }

        // Reset failed counter upon successful verification
        credential.setFailedAttempts(0);
        credential.setLockedUntil(null);
        pinCredentialRepository.save(credential);

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
