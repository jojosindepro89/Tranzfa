package io.tranzfa.core.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import io.tranzfa.core.auth.model.enums.OtpChannel;
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
public class InitiatePhoneRequest {

    @NotBlank(message = "Phone number is required")
    @Pattern(regexp = "^\\+?[0-9]{10,15}$", message = "Phone number must be a valid international format (e.g. +2348012345678)")
    @Schema(description = "Customer phone number in international format", example = "+2348012345678")
    private String phone;

    @Builder.Default
    @Schema(description = "OTP delivery channel", example = "SMS")
    private OtpChannel channel = OtpChannel.SMS;
}
