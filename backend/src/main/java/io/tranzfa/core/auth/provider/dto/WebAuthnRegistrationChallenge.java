package io.tranzfa.core.auth.provider.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WebAuthnRegistrationChallenge {

    private String challenge;
    private String rpId;
    private String rpName;
    private String userId;
    private String username;
    private long timeoutSeconds;
    private String optionsJson;
}
