package io.tranzfa.core.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VerifyLoginOtpRequest {

    @NotBlank(message = "Identifier is required")
    @Schema(description = "Phone number or email", example = "+2348012345678")
    private String identifier;

    @NotBlank(message = "OTP code is required")
    @Pattern(regexp = "^[0-9]{6}$", message = "OTP code must be a 6-digit numeric token")
    @Schema(description = "6-digit OTP code received via SMS/Email", example = "123456")
    private String otpCode;

    @Schema(description = "Temporary authentication challenge token from login response")
    private String challengeToken;

    @Schema(description = "Device ID", example = "dev-ios-a918f-2831")
    private String deviceId;

    @Schema(description = "Device friendly name", example = "iPhone 15 Pro")
    private String deviceName;
}
