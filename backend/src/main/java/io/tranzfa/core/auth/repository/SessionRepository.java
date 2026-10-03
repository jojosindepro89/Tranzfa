package io.tranzfa.core.auth.repository;

import io.tranzfa.core.auth.model.entity.Session;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SessionRepository extends JpaRepository<Session, Long> {

    Optional<Session> findByRefreshTokenAndRevokedAtIsNull(String refreshToken);

    List<Session> findAllByIdentityIdAndRevokedAtIsNull(Long identityId);
}
