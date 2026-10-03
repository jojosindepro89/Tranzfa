package io.tranzfa.core.auth.strategy;

import io.tranzfa.core.auth.dto.AuthTokenResponse;
import io.tranzfa.core.auth.dto.LoginRequest;
import io.tranzfa.core.auth.model.enums.LoginMethod;

public interface LoginStrategy {

    LoginMethod getSupportedMethod();

    AuthTokenResponse authenticate(LoginRequest request);
}
