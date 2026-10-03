package io.tranzfa.core.auth.model.entity;

import io.tranzfa.core.auth.model.enums.OtpChannel;
import io.tranzfa.core.auth.model.enums.OtpPurpose;
import io.tranzfa.core.common.model.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;

@Entity
@Table(name = "otp_tokens")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OtpToken extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "identity_id")
    private Identity identity;

    @Column(name = "recipient", nullable = false)
    private String recipient;

    @Column(name = "otp_code", nullable = false, length = 16)
    private String otpCode;

    @Enumerated(EnumType.STRING)
    @Column(name = "purpose", nullable = false, length = 64)
    @Builder.Default
    private OtpPurpose purpose = OtpPurpose.LOGIN_2FA;

    @Enumerated(EnumType.STRING)
    @Column(name = "channel", nullable = false, length = 32)
    @Builder.Default
    private OtpChannel channel = OtpChannel.SMS;

    @Column(name = "expiry_time", nullable = false)
    private Instant expiryTime;

    @Column(name = "is_verified", nullable = false)
    @Builder.Default
    private boolean isVerified = false;

    public boolean isExpired() {
        return Instant.now().isAfter(expiryTime);
    }
}
