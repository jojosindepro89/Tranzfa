package io.tranzfa.core.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import io.tranzfa.core.auth.model.enums.IdentityType;
import io.tranzfa.core.auth.model.enums.LoginMethod;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LoginRequest {

    @NotBlank(message = "Login identifier is required (phone number, email, or @tag)")
    @Schema(description = "Customer phone number (+23480...), email address, or @tag. Also accepts employee ID for staff.", example = "+2348012345678")
    private String identifier;

    @Schema(description = "Password (required if loginMethod is PASSWORD)", example = "Password123!")
    private String password;

    @Schema(description = "4-digit numeric transaction/login PIN (required if loginMethod is PIN)", example = "4321")
    private String pin;

    @Schema(description = "Passkey WebAuthn signed assertion JSON (optional raw JSON)")
    private String passkeyData;

    @Schema(description = "Passkey Credential ID registered on this device (required if loginMethod is PASSKEY)", example = "cred_ios_f81729")
    private String credentialId;

    @Schema(description = "Cryptographic challenge nonce that was signed by FaceID / Secure Enclave")
    private String challenge;

    @Schema(description = "Cryptographic signature produced by FaceID private key")
    private String signature;

    @Schema(description = "Hardware authenticator sign counter to prevent cloned authenticators", example = "42")
    private Long signCount;

    @Builder.Default
    @Schema(description = "Login authentication method", example = "PASSWORD")
    private LoginMethod loginMethod = LoginMethod.PASSWORD;

    @Builder.Default
    @Schema(description = "Target user account type (CUSTOMER or STAFF)", example = "CUSTOMER")
    private IdentityType userType = IdentityType.CUSTOMER;

    @Schema(description = "Device UUID / fingerprint", example = "dev-ios-a918f-2831")
    private String deviceId;

    @Schema(description = "Device friendly name", example = "iPhone 15 Pro")
    private String deviceName;
}
