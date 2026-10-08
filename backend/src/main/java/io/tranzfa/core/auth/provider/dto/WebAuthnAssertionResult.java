package io.tranzfa.core.auth.provider.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WebAuthnAssertionResult {

    private boolean success;
    private String credentialId;
    private long signatureCount;
}
