package io.tranzfa.core.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import io.tranzfa.core.auth.model.enums.OtpPurpose;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VerifyOtpRequest {

    @NotBlank(message = "Identifier (phone number, email, or username) is required")
    @Schema(description = "Customer phone number, email, or login identifier", example = "+2348012345678")
    private String identifier;

    @NotBlank(message = "OTP code is required")
    @Schema(description = "6-digit OTP code received via SMS/Email", example = "123456")
    private String otpCode;

    @NotNull(message = "OTP purpose is required (REGISTRATION, LOGIN_2FA, PASSWORD_RESET, PIN_RESET, TRANSFER_AUTHORIZATION)")
    @Schema(description = "Purpose of the OTP verification", example = "REGISTRATION")
    private OtpPurpose purpose;

    @Schema(description = "Hardware device identifier (applicable for LOGIN_2FA)", example = "dev-ios-a918f-2831")
    private String deviceId;

    @Schema(description = "Hardware device friendly name", example = "iPhone 15 Pro")
    private String deviceName;
}
