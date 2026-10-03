package io.tranzfa.core.auth.repository;

import io.tranzfa.core.auth.model.entity.Identity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface IdentityRepository extends JpaRepository<Identity, Long> {

    Optional<Identity> findByPublicId(String publicId);

    boolean existsByPublicId(String publicId);
}
