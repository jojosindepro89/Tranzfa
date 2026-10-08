package io.tranzfa.core.auth.provider;

import io.tranzfa.core.auth.dto.LoginRequest;
import io.tranzfa.core.auth.dto.PasskeyRegisterRequest;
import io.tranzfa.core.auth.model.entity.Identity;
import io.tranzfa.core.auth.model.entity.PasskeyCredential;
import io.tranzfa.core.auth.provider.dto.WebAuthnAssertionChallenge;
import io.tranzfa.core.auth.provider.dto.WebAuthnAssertionResult;
import io.tranzfa.core.auth.provider.dto.WebAuthnRegistrationChallenge;
import io.tranzfa.core.auth.provider.dto.WebAuthnRegistrationResult;

/**
 * Port interface for WebAuthn / FIDO2 authentication providers.
 * Decouples the core banking domain from the underlying WebAuthn implementation library (e.g. Yubico).
 */
public interface WebAuthnProvider {

    /**
     * Initiates a FIDO2 passkey registration ceremony.
     *
     * @param identity The authenticating user identity
     * @return Registration challenge parameters and W3C options JSON
     */
    WebAuthnRegistrationChallenge startRegistration(Identity identity);

    /**
     * Completes a FIDO2 passkey registration ceremony by validating the device attestation.
     *
     * @param identity The authenticating user identity
     * @param request  The client registration payload
     * @return Validated registration credentials
     */
    WebAuthnRegistrationResult finishRegistration(Identity identity, PasskeyRegisterRequest request);

    /**
     * Initiates a FIDO2 passkey assertion ceremony for authentication / login.
     *
     * @param identifier The user phone number, email, or username handle
     * @return Assertion challenge parameters and W3C request options JSON
     */
    WebAuthnAssertionChallenge startAssertion(String identifier);

    /**
     * Completes a FIDO2 passkey assertion ceremony by verifying signature and anti-cloning counter.
     *
     * @param request    The login authentication request
     * @param credential The stored passkey credential record
     * @return Assertion verification result
     */
    WebAuthnAssertionResult finishAssertion(LoginRequest request, PasskeyCredential credential);
}
