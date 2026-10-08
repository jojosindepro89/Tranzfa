package io.tranzfa.core.auth.provider.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WebAuthnAssertionChallenge {

    private String challenge;
    private String rpId;
    private String userId;
    private long timeoutSeconds;
    private String optionsJson;
}
