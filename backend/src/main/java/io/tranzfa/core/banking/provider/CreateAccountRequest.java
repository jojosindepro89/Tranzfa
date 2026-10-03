package io.tranzfa.core.banking.provider;

import lombok.Builder;

@Builder
public record CreateAccountRequest(
        String firstName,
        String middleName,
        String lastName,
        String dateOfBirth,
        String phone,
        String email,
        String bvnOrNin,
        String currency
) {
    public String getFullName() {
        if (middleName != null && !middleName.isBlank()) {
            return firstName + " " + middleName.trim() + " " + lastName;
        }
        return firstName + " " + lastName;
    }
}
