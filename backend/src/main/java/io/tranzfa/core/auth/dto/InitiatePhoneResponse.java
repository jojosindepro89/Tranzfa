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
public class InitiatePhoneResponse {

    @Schema(description = "Phone number that received OTP", example = "+2348012345678")
    private String phone;

    @Schema(description = "User instruction message", example = "Verification OTP has been sent successfully.")
    private String message;

    @Schema(description = "OTP expiration window in seconds", example = "600")
    private long expiresInSeconds;
}
