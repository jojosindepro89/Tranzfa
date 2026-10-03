package io.tranzfa.core.auth.repository;

import io.tranzfa.core.auth.model.entity.StaffUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface StaffUserRepository extends JpaRepository<StaffUser, Long> {

    Optional<StaffUser> findByCorporateEmail(String corporateEmail);

    Optional<StaffUser> findByEmployeeId(String employeeId);

    Optional<StaffUser> findByIdentityId(Long identityId);

    @Query("SELECT s FROM StaffUser s WHERE s.corporateEmail = :identifier OR s.employeeId = :identifier OR s.phone = :identifier")
    Optional<StaffUser> findByIdentifier(@Param("identifier") String identifier);

    boolean existsByCorporateEmail(String corporateEmail);

    boolean existsByEmployeeId(String employeeId);
}
