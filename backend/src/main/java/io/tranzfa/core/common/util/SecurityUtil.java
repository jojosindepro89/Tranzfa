package io.tranzfa.core.common.util;

import io.tranzfa.core.auth.model.entity.Customer;
import io.tranzfa.core.auth.model.entity.Identity;
import io.tranzfa.core.auth.repository.CustomerRepository;
import io.tranzfa.core.auth.repository.IdentityRepository;
import io.tranzfa.core.common.exception.ResourceNotFoundException;
import io.tranzfa.core.common.exception.UnauthorizedException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class SecurityUtil {

    private final IdentityRepository identityRepository;
    private final CustomerRepository customerRepository;

    public Identity getAuthenticatedIdentity() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated() || "anonymousUser".equals(authentication.getPrincipal())) {
            throw new UnauthorizedException("User is not authenticated.");
        }

        // Check if userId is present in credentials
        Object creds = authentication.getCredentials();
        if (creds != null) {
            Long userId = null;
            if (creds instanceof Number number) {
                userId = number.longValue();
            } else {
                try {
                    userId = Long.parseLong(creds.toString());
                } catch (NumberFormatException ignored) {
                }
            }
            if (userId != null) {
                return identityRepository.findById(userId)
                        .orElseThrow(() -> new UnauthorizedException("Authenticated identity not found for ID: " + creds));
            }
        }

        // Fallback to principal name lookup
        String principal = authentication.getName();
        return customerRepository.findByIdentifier(principal)
                .map(Customer::getIdentity)
                .orElseGet(() -> identityRepository.findByPublicId(principal)
                        .orElseThrow(() -> new UnauthorizedException("Authenticated identity not found for principal: " + principal)));
    }

    public Customer getAuthenticatedCustomer() {
        Identity identity = getAuthenticatedIdentity();
        return customerRepository.findByIdentityId(identity.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Customer profile not found for authenticated user."));
    }
}
