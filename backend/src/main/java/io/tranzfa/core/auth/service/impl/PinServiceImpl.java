package io.tranzfa.core.auth.service.impl;

import io.tranzfa.core.auth.model.entity.Identity;
import io.tranzfa.core.auth.model.entity.PinCredential;
import io.tranzfa.core.auth.repository.PinCredentialRepository;
import io.tranzfa.core.auth.service.PinService;
import io.tranzfa.core.common.exception.InvalidPinException;
import io.tranzfa.core.common.exception.ValidationException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;
import java.time.temporal.ChronoUnit;

@Slf4j
@Service
@RequiredArgsConstructor
public class PinServiceImpl implements PinService {

    private static final int MAX_FAILED_ATTEMPTS = 3;
    private static final int LOCKOUT_DURATION_MINUTES = 15;

    private final PinCredentialRepository pinCredentialRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    @Transactional
    public void setPin(Identity identity, String pin, String confirmPin) {
        if (pin == null || !pin.matches("^[0-9]{4}$")) {
            throw new ValidationException("PIN must be exactly 4 numeric digits.");
        }
        if (!pin.equals(confirmPin)) {
            throw new ValidationException("PIN and confirmation PIN do not match.");
        }

        // Prevent overly trivial sequence like "0000"
        if ("0000".equals(pin)) {
            throw new ValidationException("PIN cannot be 0000 for security reasons.");
        }

        PinCredential credential = pinCredentialRepository.findByIdentityId(identity.getId())
                .orElseGet(() -> PinCredential.builder()
                        .identity(identity)
                        .build());

        credential.setPin(passwordEncoder.encode(pin));
        credential.setSet(true);
        credential.setFailedAttempts(0);
        credential.setLockedUntil(null);

        pinCredentialRepository.save(credential);
        log.info("Transaction PIN successfully set for identity ID: {}", identity.getId());
    }

    @Override
    @Transactional
    public boolean verifyPin(Identity identity, String rawPin) {
        if (rawPin == null || !rawPin.matches("^[0-9]{4}$")) {
            throw new InvalidPinException("Transaction PIN must be exactly 4 digits.");
        }

        PinCredential credential = pinCredentialRepository.findByIdentityId(identity.getId())
                .orElseThrow(() -> new InvalidPinException("Transaction PIN has not been set yet. Please set your 4-digit PIN first."));

        if (!credential.isSet()) {
            throw new InvalidPinException("Transaction PIN has not been set yet. Please set your 4-digit PIN first.");
        }

        if (credential.isLocked()) {
            long remainingMins = Duration.between(Instant.now(), credential.getLockedUntil()).toMinutes() + 1;
            throw new InvalidPinException(
                    String.format("Transaction PIN is temporarily locked due to 3 consecutive failed attempts. Please try again in %d minute(s).",
                            remainingMins));
        }

        boolean matches = passwordEncoder.matches(rawPin, credential.getPin());
        if (!matches) {
            int attempts = credential.getFailedAttempts() + 1;
            credential.setFailedAttempts(attempts);

            if (attempts >= MAX_FAILED_ATTEMPTS) {
                credential.setLockedUntil(Instant.now().plus(LOCKOUT_DURATION_MINUTES, ChronoUnit.MINUTES));
                pinCredentialRepository.save(credential);
                throw new InvalidPinException(
                        String.format("Incorrect transaction PIN. Maximum attempts reached. Your PIN has been locked for %d minutes.",
                                LOCKOUT_DURATION_MINUTES));
            } else {
                pinCredentialRepository.save(credential);
                int remaining = MAX_FAILED_ATTEMPTS - attempts;
                throw new InvalidPinException(
                        String.format("Incorrect transaction PIN. %d attempt(s) remaining before lockout.", remaining));
            }
        }

        if (credential.getFailedAttempts() > 0) {
            credential.setFailedAttempts(0);
            credential.setLockedUntil(null);
            pinCredentialRepository.save(credential);
        }

        return true;
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isPinSet(Identity identity) {
        return pinCredentialRepository.findByIdentityId(identity.getId())
                .map(PinCredential::isSet)
                .orElse(false);
    }
}
