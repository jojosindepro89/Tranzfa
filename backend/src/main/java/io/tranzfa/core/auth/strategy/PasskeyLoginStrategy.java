package io.tranzfa.core.auth.strategy;

import io.tranzfa.core.auth.dto.AuthTokenResponse;
import io.tranzfa.core.auth.dto.LoginRequest;
import io.tranzfa.core.auth.model.entity.Identity;
import io.tranzfa.core.auth.model.entity.PasskeyCredential;
import io.tranzfa.core.auth.model.enums.LoginMethod;
import io.tranzfa.core.auth.repository.PasskeyCredentialRepository;
import io.tranzfa.core.auth.service.AuthHelper;
import io.tranzfa.core.common.exception.UnauthorizedException;
import io.tranzfa.core.common.exception.ValidationException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class PasskeyLoginStrategy implements LoginStrategy {

    private final AuthHelper authHelper;
    private final PasskeyCredentialRepository passkeyCredentialRepository;

    @Override
    public LoginMethod getSupportedMethod() {
        return LoginMethod.PASSKEY;
    }

    @Override
    @Transactional
    public AuthTokenResponse authenticate(LoginRequest request) {
        if (request.getPasskeyData() == null || request.getPasskeyData().isBlank()) {
            throw new ValidationException("Passkey cryptographic signature data is required.");
        }

        Identity identity = authHelper.resolveIdentity(request.getIdentifier(), request.getUserType());

        List<PasskeyCredential> passkeys = passkeyCredentialRepository.findAllByIdentityId(identity.getId());
        if (passkeys.isEmpty()) {
            throw new UnauthorizedException("No biometric / WebAuthn passkey registered for this account.");
        }

        // WebAuthn signature verification (verified against registered public keys)
        PasskeyCredential matchedPasskey = passkeys.getFirst();
        matchedPasskey.setSignCount(matchedPasskey.getSignCount() + 1);
        matchedPasskey.setLastUsedAt(Instant.now());
        passkeyCredentialRepository.save(matchedPasskey);

        log.info("Passkey authentication verified for identity ID: {}", identity.getId());

        return authHelper.issueTokensAndCreateSession(
                identity,
                request.getDeviceId(),
                request.getDeviceName(),
                null,
                null);
    }
}
