package io.tranzfa.core.auth.provider.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WebAuthnRegistrationResult {

    private String credentialId;
    private String publicKey;
    private long signCount;
    private String deviceId;
    private String deviceName;
}
