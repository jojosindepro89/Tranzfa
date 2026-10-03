package io.tranzfa.core.auth.service;

import io.tranzfa.core.auth.model.entity.Identity;

public interface PinService {

    void setPin(Identity identity, String pin, String confirmPin);

    boolean verifyPin(Identity identity, String rawPin);

    boolean isPinSet(Identity identity);
}
