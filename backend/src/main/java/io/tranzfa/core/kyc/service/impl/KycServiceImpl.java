package io.tranzfa.core.kyc.service.impl;

import io.tranzfa.core.account.service.AccountService;
import io.tranzfa.core.auth.model.entity.Customer;
import io.tranzfa.core.auth.model.enums.KycTier;
import io.tranzfa.core.auth.repository.CustomerRepository;
import io.tranzfa.core.common.exception.ResourceNotFoundException;
import io.tranzfa.core.kyc.dto.KycReviewRequest;
import io.tranzfa.core.kyc.dto.KycReviewResponse;
import io.tranzfa.core.kyc.model.entity.KycVerification;
import io.tranzfa.core.kyc.model.enums.KycReviewAction;
import io.tranzfa.core.kyc.repository.KycVerificationRepository;
import io.tranzfa.core.kyc.service.KycService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;

@Slf4j
@Service
@RequiredArgsConstructor
public class KycServiceImpl implements KycService {

    private final KycVerificationRepository kycVerificationRepository;
    private final CustomerRepository customerRepository;
    private final AccountService accountService;

    @Override
    @Transactional
    public KycReviewResponse reviewKycVerification(Long verificationId, KycReviewRequest request) {
        KycVerification kyc = kycVerificationRepository.findById(verificationId)
                .orElseThrow(() -> new ResourceNotFoundException("KYC verification record not found: " + verificationId));

        Customer customer = kyc.getCustomer();

        if (request.getAction() == KycReviewAction.APPROVE) {
            kyc.setStatus("APPROVED");
            kyc.setReviewedAt(Instant.now());
            kycVerificationRepository.save(kyc);

            customer.setKycTier(KycTier.TIER_3);
            customerRepository.save(customer);

            // Elevate daily transaction limit to Tier 3 limit
            accountService.updateDailyLimits(customer.getId(), KycTier.TIER_3);
            log.info("Compliance APPROVED KYC verification ID {} for Customer ID {}. Tier upgraded to TIER_3.",
                    verificationId, customer.getId());
        } else {
            kyc.setStatus("REJECTED");
            kyc.setRejectionReason(request.getRejectionReason() != null ? request.getRejectionReason().trim() : "Rejected by compliance review");
            kyc.setReviewedAt(Instant.now());
            kycVerificationRepository.save(kyc);

            log.info("Compliance REJECTED KYC verification ID {} for Customer ID {}. Reason: {}",
                    verificationId, customer.getId(), kyc.getRejectionReason());
        }

        return KycReviewResponse.builder()
                .verificationId(kyc.getId())
                .customerId(customer.getId())
                .customerName(customer.getFullName())
                .documentType(kyc.getDocumentType())
                .status(kyc.getStatus())
                .updatedKycTier(customer.getKycTier())
                .rejectionReason(kyc.getRejectionReason())
                .reviewedAt(kyc.getReviewedAt())
                .build();
    }
}
