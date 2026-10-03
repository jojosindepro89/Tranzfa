package io.tranzfa.core.auth.repository;

import io.tranzfa.core.auth.model.entity.PasskeyCredential;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PasskeyCredentialRepository extends JpaRepository<PasskeyCredential, Long> {

    List<PasskeyCredential> findAllByIdentityId(Long identityId);

    Optional<PasskeyCredential> findByCredentialId(String credentialId);
}
