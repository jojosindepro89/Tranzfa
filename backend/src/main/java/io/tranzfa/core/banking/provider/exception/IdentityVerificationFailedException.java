package io.tranzfa.core.banking.provider.exception;

import io.tranzfa.core.common.exception.ValidationException;

public class IdentityVerificationFailedException extends ValidationException {

    public IdentityVerificationFailedException(String message) {
        super(message);
    }
}
