package io.tranzfa.core.banking.provider.exception;

public class BankingProviderException extends RuntimeException {

    public BankingProviderException(String message) {
        super(message);
    }

    public BankingProviderException(String message, Throwable cause) {
        super(message, cause);
    }
}
