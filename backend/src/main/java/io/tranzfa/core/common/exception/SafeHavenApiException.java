package io.tranzfa.core.common.exception;

import lombok.Getter;

@Getter
public class SafeHavenApiException extends RuntimeException {

    private final Integer statusCode;
    private final String responseBody;

    public SafeHavenApiException(String message) {
        super(message);
        this.statusCode = null;
        this.responseBody = null;
    }

    public SafeHavenApiException(String message, Integer statusCode, String responseBody) {
        super(message);
        this.statusCode = statusCode;
        this.responseBody = responseBody;
    }

    public SafeHavenApiException(String message, Throwable cause) {
        super(message, cause);
        this.statusCode = null;
        this.responseBody = null;
    }
}
