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
public class VerifyPhoneOtpRequest {

    @NotBlank(message = "Phone number is required")
    @Schema(description = "Customer phone number", example = "+2348012345678")
    private String phone;

    @NotBlank(message = "OTP code is required")
    @Pattern(regexp = "^[0-9]{6}$", message = "OTP code must be a 6-digit numeric token")
    @Schema(description = "6-digit verification code", example = "123456")
    private String otpCode;
}
