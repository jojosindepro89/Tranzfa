package io.tranzfa.core.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PasskeyDeviceResponse {

    @Schema(description = "Database ID", example = "1")
    private Long id;

    @Schema(description = "Credential identifier", example = "cred_ios_f81729")
    private String credentialId;

    @Schema(description = "Device UUID", example = "dev-ios-a918f-2831")
    private String deviceId;

    @Schema(description = "Device friendly name", example = "iPhone 15 Pro")
    private String deviceName;

    @Schema(description = "Date and time registered")
    private Instant createdOn;

    @Schema(description = "Date and time last used for biometric login")
    private Instant lastUsedAt;

    @Schema(description = "Whether the passkey has been revoked", example = "false")
    private boolean isRevoked;
}
