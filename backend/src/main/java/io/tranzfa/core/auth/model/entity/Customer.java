package io.tranzfa.core.auth.model.entity;

import io.tranzfa.core.auth.model.enums.KycTier;
import io.tranzfa.core.common.model.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.apache.commons.lang3.StringUtils;

import java.time.Instant;

@Entity
@Table(name = "customers")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Customer extends BaseEntity {

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "identity_id", nullable = false, unique = true)
    private Identity identity;

    @Column(name = "first_name", nullable = false, length = 100)
    private String firstName;

    @Column(name = "middle_name", length = 100)
    private String middleName;

    @Column(name = "last_name", nullable = false, length = 100)
    private String lastName;

    @Column(name = "email", nullable = false, unique = true)
    private String email;

    @Column(name = "phone", nullable = false, unique = true, length = 32)
    private String phone;

    @Column(name = "avatar_url", length = 512)
    private String avatarUrl;

    @Enumerated(EnumType.STRING)
    @Column(name = "kyc_tier", nullable = false, length = 32)
    @Builder.Default
    private KycTier kycTier = KycTier.TIER_1;

    @Column(name = "current_device_id", length = 128)
    private String currentDeviceId;

    @Column(name = "last_device_switch_at")
    private Instant lastDeviceSwitchAt;

    /**
     * Dynamically formats full name from first, middle, and last name without duplicate DB columns.
     */
    public String getFullName() {
        if (StringUtils.isNotBlank(middleName)) {
            return firstName + " " + middleName.trim() + " " + lastName;
        }
        return firstName + " " + lastName;
    }
}
