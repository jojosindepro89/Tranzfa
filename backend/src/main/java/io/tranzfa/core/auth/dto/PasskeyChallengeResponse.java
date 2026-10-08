package io.tranzfa.core.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PasskeyChallengeResponse {

    @Schema(description = "Cryptographic random challenge nonce (Base64URL encoded)", example = "dGhpcy1pcy1hLXJhbmRvbS1jaGFsbGVuZ2Utbm9uY2U")
    private String challenge;

    @Schema(description = "Relying Party ID (domain of Tranzfa)", example = "tranzfa.io")
    private String rpId;

    @Schema(description = "User identifier handle for authenticator", example = "id_cust_983742")
    private String userId;

    @Schema(description = "Validity duration in seconds", example = "300")
    private long timeoutSeconds;

    @Schema(description = "Complete W3C WebAuthn creation/request options JSON for navigator.credentials")
    private String optionsJson;
}
