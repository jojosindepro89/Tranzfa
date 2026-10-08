package io.tranzfa.core.auth.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.tranzfa.core.auth.dto.AuthTokenResponse;
import io.tranzfa.core.auth.dto.InitiatePhoneRequest;
import io.tranzfa.core.auth.dto.InitiatePhoneResponse;
import io.tranzfa.core.auth.dto.LoginRequest;
import io.tranzfa.core.auth.dto.PasskeyChallengeResponse;
import io.tranzfa.core.auth.dto.PasskeyDeviceResponse;
import io.tranzfa.core.auth.dto.PasskeyRegisterRequest;
import io.tranzfa.core.auth.dto.PersonalDetailsRequest;
import io.tranzfa.core.auth.dto.RefreshTokenRequest;
import io.tranzfa.core.auth.dto.SetPinRequest;
import io.tranzfa.core.auth.dto.UploadDocumentRequest;
import io.tranzfa.core.auth.dto.UserProfileResponse;
import io.tranzfa.core.auth.dto.VerifyOtpRequest;
import io.tranzfa.core.auth.dto.VerifyOtpResponse;
import io.tranzfa.core.auth.dto.VerifyPinRequest;
import io.tranzfa.core.auth.model.entity.Identity;
import io.tranzfa.core.auth.service.AuthService;
import io.tranzfa.core.auth.service.PasskeyService;
import io.tranzfa.core.auth.service.PinService;
import io.tranzfa.core.common.dto.ApiResponse;
import io.tranzfa.core.common.util.SecurityUtil;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication & Onboarding", description = "FinTech 3FA authentication, phone verification, retail onboarding, and session management")
public class AuthController {

    private final AuthService authService;
    private final PinService pinService;
    private final PasskeyService passkeyService;
    private final SecurityUtil securityUtil;

    @PostMapping("/initiate-phone")
    @Operation(summary = "Step 1: Initiate phone number onboarding", description = "Validates phone uniqueness and dispatches a 6-digit OTP via SMS")
    public ResponseEntity<ApiResponse<InitiatePhoneResponse>> initiatePhone(@Valid @RequestBody InitiatePhoneRequest request) {
        InitiatePhoneResponse response = authService.initiatePhone(request);
        return ResponseEntity.ok(ApiResponse.success("Verification code sent successfully", response));
    }

    @PostMapping("/otp/verify")
    @Operation(summary = "Step 2: Unified OTP Verification",
            description = "Single unified endpoint for verifying OTPs across all channels and purposes (REGISTRATION, LOGIN_2FA, PASSWORD_RESET, PIN_RESET, TRANSFER_AUTHORIZATION)")
    public ResponseEntity<ApiResponse<VerifyOtpResponse>> verifyOtp(@Valid @RequestBody VerifyOtpRequest request) {
        VerifyOtpResponse response = authService.verifyOtp(request);
        return ResponseEntity.ok(ApiResponse.success(response.getMessage(), response));
    }

    @PostMapping("/personal-details")
    @Operation(summary = "Step 3: Complete personal details and account creation",
            description = "Creates customer identity, saves password, provisions checking account and BaaS mapping, and issues auth tokens")
    public ResponseEntity<ApiResponse<AuthTokenResponse>> registerPersonalDetails(@Valid @RequestBody PersonalDetailsRequest request) {
        AuthTokenResponse response = authService.registerPersonalDetails(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success("Account created successfully", response));
    }

    @PostMapping("/upload-document")
    @SecurityRequirement(name = "BearerAuth")
    @Operation(summary = "Step 4: Upload identity verification document", description = "Uploads government ID to upgrade KYC compliance to Tier 3")
    public ResponseEntity<ApiResponse<UserProfileResponse>> uploadDocument(@Valid @RequestBody UploadDocumentRequest request) {
        Identity identity = securityUtil.getAuthenticatedIdentity();
        UserProfileResponse updatedProfile = authService.uploadDocument(identity, request);
        return ResponseEntity.ok(ApiResponse.success("Document uploaded and KYC updated", updatedProfile));
    }

    @PostMapping("/login")
    @Operation(summary = "Unified Login (Password, PIN, Passkey, OTP)",
            description = "Authenticates customer or staff by identifier with 4-digit PIN, Password, Biometric Passkey, or OTP. Enforces CBN single-device and 24-hour limit cooldown.")
    public ResponseEntity<ApiResponse<AuthTokenResponse>> login(@Valid @RequestBody LoginRequest request) {
        AuthTokenResponse response = authService.login(request);
        return ResponseEntity.ok(ApiResponse.success("Authentication evaluated", response));
    }

    @PostMapping("/pin/set")
    @SecurityRequirement(name = "BearerAuth")
    @Operation(summary = "Set 4-digit transaction PIN (Factor 3)",
            description = "Configures customer 4-digit PIN for high-value funds movement and card actions")
    public ResponseEntity<ApiResponse<String>> setPin(@Valid @RequestBody SetPinRequest request) {
        Identity identity = securityUtil.getAuthenticatedIdentity();
        pinService.setPin(identity, request.getPin(), request.getConfirmPin());
        return ResponseEntity.ok(ApiResponse.success("Transaction PIN set successfully"));
    }

    @PostMapping("/pin/verify")
    @SecurityRequirement(name = "BearerAuth")
    @Operation(summary = "Verify 4-digit transaction PIN",
            description = "Validates 4-digit transaction PIN with independent 3-attempt lockout protection")
    public ResponseEntity<ApiResponse<String>> verifyPin(@Valid @RequestBody VerifyPinRequest request) {
        Identity identity = securityUtil.getAuthenticatedIdentity();
        pinService.verifyPin(identity, request.getPin());
        return ResponseEntity.ok(ApiResponse.success("Transaction PIN verified successfully"));
    }

    @PostMapping("/refresh-token")
    @Operation(summary = "Rotate refresh token", description = "Exchanges valid refresh token for a new access token and rotated refresh token")
    public ResponseEntity<ApiResponse<AuthTokenResponse>> refreshToken(@Valid @RequestBody RefreshTokenRequest request) {
        AuthTokenResponse response = authService.refreshToken(request);
        return ResponseEntity.ok(ApiResponse.success("Token refreshed successfully", response));
    }

    @GetMapping("/me")
    @SecurityRequirement(name = "BearerAuth")
    @Operation(summary = "Get current authenticated profile", description = "Fetches identity details, primary account balance, and KYC tier")
    public ResponseEntity<ApiResponse<UserProfileResponse>> getCurrentUser() {
        Identity identity = securityUtil.getAuthenticatedIdentity();
        UserProfileResponse profile = authService.getCurrentUserProfile(identity);
        return ResponseEntity.ok(ApiResponse.success("Profile retrieved successfully", profile));
    }

    @PostMapping("/logout")
    @SecurityRequirement(name = "BearerAuth")
    @Operation(summary = "Revoke active session", description = "Logs out and revokes refresh token session")
    public ResponseEntity<ApiResponse<String>> logout(@RequestHeader(value = "X-Refresh-Token", required = false) String refreshToken) {
        Identity identity = securityUtil.getAuthenticatedIdentity();
        authService.logout(identity, refreshToken);
        return ResponseEntity.ok(ApiResponse.success("Logged out successfully"));
    }

    @PostMapping("/passkey/register-challenge")
    @SecurityRequirement(name = "BearerAuth")
    @Operation(summary = "Generate FIDO2 biometric registration challenge",
            description = "Issues cryptographic random nonce for Apple Secure Enclave / Android Keystore passkey creation")
    public ResponseEntity<ApiResponse<PasskeyChallengeResponse>> generatePasskeyRegisterChallenge() {
        Identity identity = securityUtil.getAuthenticatedIdentity();
        PasskeyChallengeResponse response = passkeyService.generateRegisterChallenge(identity);
        return ResponseEntity.ok(ApiResponse.success("Passkey registration challenge issued", response));
    }

    @PostMapping("/passkey/register")
    @SecurityRequirement(name = "BearerAuth")
    @Operation(summary = "Register biometric passkey hardware public key",
            description = "Stores device public key from Apple Secure Enclave or Android Keystore")
    public ResponseEntity<ApiResponse<PasskeyDeviceResponse>> registerPasskey(@Valid @RequestBody PasskeyRegisterRequest request) {
        Identity identity = securityUtil.getAuthenticatedIdentity();
        PasskeyDeviceResponse response = passkeyService.registerPasskey(identity, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success("Biometric passkey registered successfully", response));
    }

    @PostMapping("/passkey/login-challenge")
    @Operation(summary = "Generate FIDO2 biometric login challenge",
            description = "Returns cryptographic nonce to be signed by device FaceID / TouchID hardware key")
    public ResponseEntity<ApiResponse<PasskeyChallengeResponse>> generatePasskeyLoginChallenge(@RequestParam String identifier) {
        PasskeyChallengeResponse response = passkeyService.generateLoginChallenge(identifier);
        return ResponseEntity.ok(ApiResponse.success("Passkey login challenge issued", response));
    }

    @GetMapping("/passkey/devices")
    @SecurityRequirement(name = "BearerAuth")
    @Operation(summary = "List registered biometric passkey devices",
            description = "Retrieves all hardware devices registered for biometric login by this customer")
    public ResponseEntity<ApiResponse<List<PasskeyDeviceResponse>>> listPasskeyDevices() {
        Identity identity = securityUtil.getAuthenticatedIdentity();
        List<PasskeyDeviceResponse> devices = passkeyService.listDevices(identity);
        return ResponseEntity.ok(ApiResponse.success("Passkey devices retrieved", devices));
    }

    @DeleteMapping("/passkey/{credentialId}")
    @SecurityRequirement(name = "BearerAuth")
    @Operation(summary = "Revoke biometric passkey device",
            description = "Revokes a registered biometric passkey device to disable FaceID login from it")
    public ResponseEntity<ApiResponse<String>> revokePasskey(@PathVariable String credentialId) {
        Identity identity = securityUtil.getAuthenticatedIdentity();
        passkeyService.revokePasskey(identity, credentialId);
        return ResponseEntity.ok(ApiResponse.success("Biometric passkey revoked successfully"));
    }
}
