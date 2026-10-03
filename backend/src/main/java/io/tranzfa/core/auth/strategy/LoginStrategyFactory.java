package io.tranzfa.core.auth.strategy;

import io.tranzfa.core.auth.model.enums.LoginMethod;
import io.tranzfa.core.common.exception.ValidationException;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Component
public class LoginStrategyFactory {

    private final Map<LoginMethod, LoginStrategy> strategies;

    public LoginStrategyFactory(List<LoginStrategy> strategyList) {
        this.strategies = strategyList.stream()
                .collect(Collectors.toMap(LoginStrategy::getSupportedMethod, Function.identity()));
    }

    public LoginStrategy getStrategy(LoginMethod method) {
        LoginMethod key = method != null ? method : LoginMethod.PASSWORD;
        LoginStrategy strategy = strategies.get(key);
        if (strategy == null) {
            throw new ValidationException("Unsupported login method: " + key);
        }
        return strategy;
    }
}
