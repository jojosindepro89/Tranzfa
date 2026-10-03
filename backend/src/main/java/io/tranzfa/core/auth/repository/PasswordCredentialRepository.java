package io.tranzfa.core.auth.repository;

import io.tranzfa.core.auth.model.entity.PasswordCredential;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PasswordCredentialRepository extends JpaRepository<PasswordCredential, Long> {

    Optional<PasswordCredential> findByIdentityId(Long identityId);
}
