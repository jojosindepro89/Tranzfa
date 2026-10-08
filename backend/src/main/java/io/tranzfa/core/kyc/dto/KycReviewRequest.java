package io.tranzfa.core.kyc.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import io.tranzfa.core.kyc.model.enums.KycReviewAction;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class KycReviewRequest {

    @NotNull(message = "Review action is required (APPROVE or REJECT)")
    @Schema(description = "Compliance review action (APPROVE or REJECT)", example = "APPROVE")
    private KycReviewAction action;

    @Schema(description = "Reason or reviewer notes (required if REJECT)", example = "Valid government ID verified")
    private String rejectionReason;
}
