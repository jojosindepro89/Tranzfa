package io.tranzfa.core.auth.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.tranzfa.core.auth.dto.AuthTokenResponse;
import io.tranzfa.core.auth.dto.InitiatePhoneRequest;
import io.tranzfa.core.auth.dto.InitiatePhoneResponse;
import io.tranzfa.core.auth.dto.LoginRequest;
import io.tranzfa.core.auth.dto.PersonalDetailsRequest;
import io.tranzfa.core.auth.dto.RefreshTokenRequest;
import io.tranzfa.core.auth.dto.SetPinRequest;
import io.tranzfa.core.auth.dto.UploadDocumentRequest;
import io.tranzfa.core.auth.dto.UserProfileResponse;
import io.tranzfa.core.auth.dto.VerifyLoginOtpRequest;
import io.tranzfa.core.auth.dto.VerifyPhoneOtpRequest;
import io.tranzfa.core.auth.dto.VerifyPhoneOtpResponse;
import io.tranzfa.core.auth.dto.VerifyPinRequest;
import io.tranzfa.core.auth.model.entity.Identity;
import io.tranzfa.core.auth.service.AuthService;
import io.tranzfa.core.auth.service.PinService;
import io.tranzfa.core.common.dto.ApiResponse;
import io.tranzfa.core.common.util.SecurityUtil;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication & Onboarding", description = "FinTech 3FA authentication, phone verification, retail onboarding, and session management")
public class AuthController {

    private final AuthService authService;
    private final PinService pinService;
    private final SecurityUtil securityUtil;

    @PostMapping("/initiate-phone")
    @Operation(summary = "Step 1: Initiate phone number onboarding", description = "Validates phone uniqueness and dispatches a 6-digit OTP via SMS")
    public ResponseEntity<ApiResponse<InitiatePhoneResponse>> initiatePhone(@Valid @RequestBody InitiatePhoneRequest request) {
        InitiatePhoneResponse response = authService.initiatePhone(request);
        return ResponseEntity.ok(ApiResponse.success("Verification code sent successfully", response));
    }

    @PostMapping("/verify-phone-otp")
    @Operation(summary = "Step 2: Verify phone OTP", description = "Validates 6-digit OTP code and returns an authorized registration token")
    public ResponseEntity<ApiResponse<VerifyPhoneOtpResponse>> verifyPhoneOtp(@Valid @RequestBody VerifyPhoneOtpRequest request) {
        VerifyPhoneOtpResponse response = authService.verifyPhoneOtp(request);
        return ResponseEntity.ok(ApiResponse.success("Phone verified successfully", response));
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
    @Operation(summary = "Unified Login (Password, Passkey, OTP)",
            description = "Authenticates customer or staff by identifier (phone, email, @tag, or employee ID)")
    public ResponseEntity<ApiResponse<AuthTokenResponse>> login(@Valid @RequestBody LoginRequest request) {
        AuthTokenResponse response = authService.login(request);
        return ResponseEntity.ok(ApiResponse.success("Authentication evaluated", response));
    }

    @PostMapping("/verify-otp")
    @Operation(summary = "Verify 2FA login challenge OTP", description = "Completes 2-Factor Authentication login")
    public ResponseEntity<ApiResponse<AuthTokenResponse>> verifyLoginOtp(@Valid @RequestBody VerifyLoginOtpRequest request) {
        AuthTokenResponse response = authService.verifyLoginOtp(request);
        return ResponseEntity.ok(ApiResponse.success("2FA verified successfully", response));
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
}
