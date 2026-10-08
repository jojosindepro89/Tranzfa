package io.tranzfa.core.kyc.dto;

import io.tranzfa.core.auth.model.enums.KycTier;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class KycReviewResponse {

    private Long verificationId;
    private Long customerId;
    private String customerName;
    private String documentType;
    private String status;
    private KycTier updatedKycTier;
    private String rejectionReason;
    private Instant reviewedAt;
}
