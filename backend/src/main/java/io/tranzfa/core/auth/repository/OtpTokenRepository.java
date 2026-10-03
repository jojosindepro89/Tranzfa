package io.tranzfa.core.auth.repository;

import io.tranzfa.core.auth.model.entity.OtpToken;
import io.tranzfa.core.auth.model.enums.OtpPurpose;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface OtpTokenRepository extends JpaRepository<OtpToken, Long> {

    Optional<OtpToken> findTopByRecipientAndPurposeAndIsVerifiedFalseOrderByCreatedOnDesc(
            String recipient,
            OtpPurpose purpose
    );

    Optional<OtpToken> findTopByRecipientAndOtpCodeAndPurposeAndIsVerifiedFalseOrderByCreatedOnDesc(
            String recipient,
            String otpCode,
            OtpPurpose purpose
    );
}
