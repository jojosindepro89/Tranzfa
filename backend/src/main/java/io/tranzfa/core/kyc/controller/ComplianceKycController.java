package io.tranzfa.core.kyc.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.tranzfa.core.common.dto.ApiResponse;
import io.tranzfa.core.kyc.dto.KycReviewRequest;
import io.tranzfa.core.kyc.dto.KycReviewResponse;
import io.tranzfa.core.kyc.service.KycService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/compliance/kyc")
@RequiredArgsConstructor
@Tag(name = "Compliance & KYC Management", description = "Back-office compliance operations for reviewing customer identity documents and Tier upgrades")
public class ComplianceKycController {

    private final KycService kycService;

    @PostMapping("/{verificationId}/review")
    @SecurityRequirement(name = "BearerAuth")
    @Operation(summary = "Unified KYC Document Decision (Approve or Reject)",
            description = "Allows compliance officers to approve or reject submitted KYC documents. Approving elevates customer to Tier 3 and raises transaction limits.")
    public ResponseEntity<ApiResponse<KycReviewResponse>> reviewKyc(
            @PathVariable Long verificationId,
            @Valid @RequestBody KycReviewRequest request) {

        KycReviewResponse response = kycService.reviewKycVerification(verificationId, request);
        String message = "APPROVE".equalsIgnoreCase(request.getAction().name())
                ? "KYC verification approved successfully. Customer upgraded to Tier 3."
                : "KYC verification rejected.";

        return ResponseEntity.ok(ApiResponse.success(message, response));
    }
}
