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
public class AuthTokenResponse {

    @Schema(description = "Access token for authorization in Bearer header")
    private String accessToken;

    @Schema(description = "Refresh token for issuing new access tokens")
    private String refreshToken;

    @Builder.Default
    @Schema(description = "Token type", example = "Bearer")
    private String tokenType = "Bearer";

    @Schema(description = "Access token expiry time in seconds", example = "86400")
    private long expiresIn;

    @Schema(description = "Indicates if 2FA verification is required before full authentication", example = "false")
    private boolean requiresOtp;

    @Schema(description = "Indicates if a new device was detected and requires authorization", example = "false")
    private boolean requiresDeviceVerification;

    @Schema(description = "User-facing message (e.g., instructions on device verification)", example = "New device detected. Enter OTP to authorize.")
    private String message;

    @Schema(description = "Masked recipient if OTP is required", example = "+23480******78")
    private String otpRecipientMasked;

    @Schema(description = "Temporary challenge token required when submitting OTP")
    private String challengeToken;

    @Schema(description = "Authenticated user profile details")
    private UserProfileResponse user;
}
