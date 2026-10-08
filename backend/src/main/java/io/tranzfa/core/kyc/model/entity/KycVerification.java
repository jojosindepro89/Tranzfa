package io.tranzfa.core.kyc.model.entity;

import io.tranzfa.core.auth.model.entity.Customer;
import io.tranzfa.core.common.model.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "kyc_verifications")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class KycVerification extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "customer_id", nullable = false)
    private Customer customer;

    @Column(name = "tier_level", nullable = false)
    private int tierLevel;

    @Column(name = "bvn_masked", length = 32)
    private String bvnMasked;

    @Column(name = "nin_masked", length = 32)
    private String ninMasked;

    @Column(name = "document_type", length = 64)
    private String documentType;

    @Column(name = "document_url", length = 512)
    private String documentUrl;

    @Column(name = "status", nullable = false, length = 32)
    @Builder.Default
    private String status = "PENDING_REVIEW";

    @Column(name = "external_verification_id", length = 128)
    private String externalVerificationId;

    @Column(name = "rejection_reason", length = 512)
    private String rejectionReason;

    @Column(name = "reviewed_at")
    private java.time.Instant reviewedAt;
}
