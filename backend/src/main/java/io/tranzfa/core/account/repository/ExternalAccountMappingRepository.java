package io.tranzfa.core.account.repository;

import io.tranzfa.core.account.model.entity.ExternalAccountMapping;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ExternalAccountMappingRepository extends JpaRepository<ExternalAccountMapping, Long> {

    List<ExternalAccountMapping> findAllByAccountId(Long accountId);

    Optional<ExternalAccountMapping> findByAccountIdAndIsPrimaryTrue(Long accountId);

    Optional<ExternalAccountMapping> findByProviderAndExternalAccountId(String provider, String externalAccountId);
}
