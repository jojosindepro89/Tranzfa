package io.tranzfa.core.kyc.service;

import io.tranzfa.core.account.service.AccountService;
import io.tranzfa.core.auth.model.entity.Customer;
import io.tranzfa.core.auth.model.enums.KycTier;
import io.tranzfa.core.auth.repository.CustomerRepository;
import io.tranzfa.core.kyc.dto.KycReviewRequest;
import io.tranzfa.core.kyc.dto.KycReviewResponse;
import io.tranzfa.core.kyc.model.entity.KycVerification;
import io.tranzfa.core.kyc.model.enums.KycReviewAction;
import io.tranzfa.core.kyc.repository.KycVerificationRepository;
import io.tranzfa.core.kyc.service.impl.KycServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class KycServiceImplTest {

    @Mock
    private KycVerificationRepository kycVerificationRepository;

    @Mock
    private CustomerRepository customerRepository;

    @Mock
    private AccountService accountService;

    private KycService kycService;
    private Customer sampleCustomer;
    private KycVerification sampleKyc;

    @BeforeEach
    void setUp() {
        kycService = new KycServiceImpl(kycVerificationRepository, customerRepository, accountService);

        sampleCustomer = Customer.builder()
                .firstName("Emeka")
                .lastName("Okafor")
                .kycTier(KycTier.TIER_2)
                .build();
        sampleCustomer.setId(55L);

        sampleKyc = KycVerification.builder()
                .customer(sampleCustomer)
                .tierLevel(3)
                .documentType("INTERNATIONAL_PASSPORT")
                .documentUrl("https://storage.tranzfa.io/kyc/passport_55.jpg")
                .status("PENDING_REVIEW")
                .build();
        sampleKyc.setId(101L);
    }

    @Test
    @DisplayName("Should approve KYC verification, upgrade customer to Tier 3, and elevate daily limits")
    void shouldApproveKycVerificationAndElevateTierToTier3() {
        KycReviewRequest request = KycReviewRequest.builder()
                .action(KycReviewAction.APPROVE)
                .rejectionReason("Government database match confirmed")
                .build();

        when(kycVerificationRepository.findById(101L)).thenReturn(Optional.of(sampleKyc));

        KycReviewResponse response = kycService.reviewKycVerification(101L, request);

        assertThat(response.getStatus()).isEqualTo("APPROVED");
        assertThat(response.getUpdatedKycTier()).isEqualTo(KycTier.TIER_3);
        assertThat(sampleCustomer.getKycTier()).isEqualTo(KycTier.TIER_3);

        verify(kycVerificationRepository).save(sampleKyc);
        verify(customerRepository).save(sampleCustomer);
        verify(accountService).updateDailyLimits(55L, KycTier.TIER_3);
    }

    @Test
    @DisplayName("Should reject KYC verification, record reason, and preserve existing customer tier")
    void shouldRejectKycVerificationAndKeepTierUnchanged() {
        KycReviewRequest request = KycReviewRequest.builder()
                .action(KycReviewAction.REJECT)
                .rejectionReason("Document image is expired")
                .build();

        when(kycVerificationRepository.findById(101L)).thenReturn(Optional.of(sampleKyc));

        KycReviewResponse response = kycService.reviewKycVerification(101L, request);

        assertThat(response.getStatus()).isEqualTo("REJECTED");
        assertThat(response.getRejectionReason()).isEqualTo("Document image is expired");
        assertThat(response.getUpdatedKycTier()).isEqualTo(KycTier.TIER_2);
        assertThat(sampleCustomer.getKycTier()).isEqualTo(KycTier.TIER_2);

        verify(kycVerificationRepository).save(sampleKyc);
        verify(customerRepository, never()).save(any());
        verify(accountService, never()).updateDailyLimits(any(), any());
    }
}
