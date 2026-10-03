package io.tranzfa.core.kyc.repository;

import io.tranzfa.core.kyc.model.entity.KycVerification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface KycVerificationRepository extends JpaRepository<KycVerification, Long> {

    List<KycVerification> findAllByCustomerId(Long customerId);

    Optional<KycVerification> findTopByCustomerIdOrderByTierLevelDesc(Long customerId);
}
