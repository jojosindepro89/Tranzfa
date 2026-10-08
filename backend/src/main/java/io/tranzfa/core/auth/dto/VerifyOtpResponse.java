package io.tranzfa.core.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import io.tranzfa.core.auth.model.enums.OtpPurpose;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VerifyOtpResponse {

    @Schema(description = "Whether the OTP was verified successfully", example = "true")
    private boolean verified;

    @Schema(description = "The OTP purpose evaluated", example = "REGISTRATION")
    private OtpPurpose purpose;

    @Schema(description = "Informational outcome message")
    private String message;

    @Schema(description = "Registration / Password reset token if purpose requires follow-up (e.g. REGISTRATION)")
    private String verificationToken;

    @Schema(description = "Full authentication tokens and session payload if purpose was LOGIN_2FA")
    private AuthTokenResponse authTokens;
}
