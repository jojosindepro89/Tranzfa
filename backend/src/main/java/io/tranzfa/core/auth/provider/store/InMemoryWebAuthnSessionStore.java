package io.tranzfa.core.auth.provider.store;

import com.yubico.webauthn.AssertionRequest;
import com.yubico.webauthn.data.PublicKeyCredentialCreationOptions;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class InMemoryWebAuthnSessionStore implements WebAuthnSessionStore {

    private record CachedItem<T>(T item, Instant expiresAt) {
        boolean isExpired() {
            return Instant.now().isAfter(expiresAt);
        }
    }

    private final Map<String, CachedItem<PublicKeyCredentialCreationOptions>> registrationStore = new ConcurrentHashMap<>();
    private final Map<String, CachedItem<AssertionRequest>> assertionStore = new ConcurrentHashMap<>();

    @Override
    public void storeRegistrationRequest(String key, PublicKeyCredentialCreationOptions request, long ttlSeconds) {
        cleanExpiredRegistrations();
        registrationStore.put(key, new CachedItem<>(request, Instant.now().plusSeconds(ttlSeconds)));
    }

    @Override
    public Optional<PublicKeyCredentialCreationOptions> getRegistrationRequest(String key) {
        CachedItem<PublicKeyCredentialCreationOptions> cached = registrationStore.get(key);
        if (cached == null || cached.isExpired()) {
            registrationStore.remove(key);
            return Optional.empty();
        }
        return Optional.of(cached.item());
    }

    @Override
    public void removeRegistrationRequest(String key) {
        registrationStore.remove(key);
    }

    @Override
    public void storeAssertionRequest(String key, AssertionRequest request, long ttlSeconds) {
        cleanExpiredAssertions();
        assertionStore.put(key, new CachedItem<>(request, Instant.now().plusSeconds(ttlSeconds)));
    }

    @Override
    public Optional<AssertionRequest> getAssertionRequest(String key) {
        CachedItem<AssertionRequest> cached = assertionStore.get(key);
        if (cached == null || cached.isExpired()) {
            assertionStore.remove(key);
            return Optional.empty();
        }
        return Optional.of(cached.item());
    }

    @Override
    public void removeAssertionRequest(String key) {
        assertionStore.remove(key);
    }

    private void cleanExpiredRegistrations() {
        registrationStore.entrySet().removeIf(entry -> entry.getValue().isExpired());
    }

    private void cleanExpiredAssertions() {
        assertionStore.entrySet().removeIf(entry -> entry.getValue().isExpired());
    }
}
