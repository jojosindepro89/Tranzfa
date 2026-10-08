package io.tranzfa.core.kyc.service;

import io.tranzfa.core.kyc.dto.KycReviewRequest;
import io.tranzfa.core.kyc.dto.KycReviewResponse;

public interface KycService {

    KycReviewResponse reviewKycVerification(Long verificationId, KycReviewRequest request);
}
