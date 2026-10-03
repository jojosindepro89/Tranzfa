package io.tranzfa.core.auth.repository;

import io.tranzfa.core.auth.model.entity.Customer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CustomerRepository extends JpaRepository<Customer, Long> {

    Optional<Customer> findByEmail(String email);

    Optional<Customer> findByPhone(String phone);

    Optional<Customer> findByIdentityId(Long identityId);

    @Query("SELECT c FROM Customer c WHERE c.phone = :identifier OR c.email = :identifier")
    Optional<Customer> findByIdentifier(@Param("identifier") String identifier);

    boolean existsByEmail(String email);

    boolean existsByPhone(String phone);
}
