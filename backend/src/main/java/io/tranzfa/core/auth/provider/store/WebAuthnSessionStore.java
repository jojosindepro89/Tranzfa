package io.tranzfa.core.auth.provider.store;

import com.yubico.webauthn.AssertionRequest;
import com.yubico.webauthn.data.PublicKeyCredentialCreationOptions;

import java.util.Optional;

public interface WebAuthnSessionStore {

    void storeRegistrationRequest(String key, PublicKeyCredentialCreationOptions request, long ttlSeconds);

    Optional<PublicKeyCredentialCreationOptions> getRegistrationRequest(String key);

    void removeRegistrationRequest(String key);

    void storeAssertionRequest(String key, AssertionRequest request, long ttlSeconds);

    Optional<AssertionRequest> getAssertionRequest(String key);

    void removeAssertionRequest(String key);
}
