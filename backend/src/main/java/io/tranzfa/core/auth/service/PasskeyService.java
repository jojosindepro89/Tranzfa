package io.tranzfa.core.auth.service;

import io.tranzfa.core.auth.dto.PasskeyChallengeResponse;
import io.tranzfa.core.auth.dto.PasskeyDeviceResponse;
import io.tranzfa.core.auth.dto.PasskeyRegisterRequest;
import io.tranzfa.core.auth.model.entity.Identity;

import java.util.List;

public interface PasskeyService {

    PasskeyChallengeResponse generateRegisterChallenge(Identity identity);

    PasskeyDeviceResponse registerPasskey(Identity identity, PasskeyRegisterRequest request);

    PasskeyChallengeResponse generateLoginChallenge(String identifier);

    List<PasskeyDeviceResponse> listDevices(Identity identity);

    void revokePasskey(Identity identity, String credentialId);
}
