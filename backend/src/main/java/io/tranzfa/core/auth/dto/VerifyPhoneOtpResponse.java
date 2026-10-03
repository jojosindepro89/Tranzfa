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
public class VerifyPhoneOtpResponse {

    @Schema(description = "Phone number verified", example = "+2348012345678")
    private String phone;

    @Schema(description = "Indicates if phone verification succeeded", example = "true")
    private boolean phoneVerified;

    @Schema(description = "Temporary signed verification token to present when submitting personal details")
    private String verificationToken;

    @Schema(description = "Guidance message", example = "Phone verified successfully. Please complete personal details.")
    private String message;
}
