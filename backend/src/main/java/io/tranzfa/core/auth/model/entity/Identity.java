package io.tranzfa.core.auth.model.entity;

import io.tranzfa.core.auth.model.enums.IdentityType;
import io.tranzfa.core.common.model.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "identities")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Identity extends BaseEntity {

    @Column(name = "public_id", nullable = false, unique = true, length = 64)
    private String publicId;

    @Enumerated(EnumType.STRING)
    @Column(name = "identity_type", nullable = false, length = 32)
    private IdentityType identityType;

    @Column(name = "status", nullable = false, length = 32)
    @Builder.Default
    private String status = "ACTIVE";
}
