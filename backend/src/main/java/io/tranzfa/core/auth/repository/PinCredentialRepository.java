package io.tranzfa.core.auth.repository;

import io.tranzfa.core.auth.model.entity.PinCredential;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PinCredentialRepository extends JpaRepository<PinCredential, Long> {

    Optional<PinCredential> findByIdentityId(Long identityId);
}
