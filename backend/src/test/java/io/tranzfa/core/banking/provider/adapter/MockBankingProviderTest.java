package io.tranzfa.core.banking.provider.adapter;

import io.tranzfa.core.banking.provider.CreateAccountRequest;
import io.tranzfa.core.banking.provider.CreateAccountResponse;
import io.tranzfa.core.banking.provider.exception.IdentityVerificationFailedException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class MockBankingProviderTest {

    private MockBankingProvider mockBankingProvider;

    @BeforeEach
    void setUp() {
        mockBankingProvider = new MockBankingProvider();
    }

    @Test
    @DisplayName("Should successfully allocate 10-digit NUBAN and verify identity for valid 11-digit BVN")
    void shouldCreateAccountWithValidBvn() {
        CreateAccountRequest request = CreateAccountRequest.builder()
                .firstName("Sarah")
                .middleName("Chinyere")
                .lastName("Okonjo")
                .dateOfBirth("1998-05-12")
                .phone("+2348012345678")
                .email("sarah.okonjo@example.com")
                .bvnOrNin("22233344455")
                .currency("NGN")
                .build();

        CreateAccountResponse response = mockBankingProvider.createAccount(request);

        assertThat(response.accountNumber()).matches("^20\\d{8}$");
        assertThat(response.bankCode()).isEqualTo("090286");
        assertThat(response.bankName()).isEqualTo("Safe Haven Microfinance Bank");
        assertThat(response.tierLevel()).isEqualTo(2);
        assertThat(response.identityId()).startsWith("mock_identity_");
        assertThat(response.externalAccountId()).startsWith("mock_acct_");
    }

    @Test
    @DisplayName("Should reject invalid BVN format that is not 11 numeric digits")
    void shouldRejectInvalidBvnFormat() {
        CreateAccountRequest request = CreateAccountRequest.builder()
                .firstName("Sarah")
                .lastName("Okonjo")
                .phone("+2348012345678")
                .email("sarah.okonjo@example.com")
                .bvnOrNin("12345") // Only 5 digits
                .build();

        assertThatThrownBy(() -> mockBankingProvider.createAccount(request))
                .isInstanceOf(IdentityVerificationFailedException.class)
                .hasMessageContaining("Invalid BVN/NIN format");
    }

    @Test
    @DisplayName("Should reject simulated mismatch BVN for testing failure gating")
    void shouldRejectSimulatedMismatchBvn() {
        CreateAccountRequest request = CreateAccountRequest.builder()
                .firstName("Sarah")
                .lastName("Okonjo")
                .phone("+2348012345678")
                .email("sarah.okonjo@example.com")
                .bvnOrNin("00000000000") // Trigger test failure
                .build();

        assertThatThrownBy(() -> mockBankingProvider.createAccount(request))
                .isInstanceOf(IdentityVerificationFailedException.class)
                .hasMessageContaining("Identity verification failed");
    }

    @Test
    @DisplayName("Should create Tier 1 account when no BVN or NIN is supplied")
    void shouldCreateTier1WhenNoBvnSupplied() {
        CreateAccountRequest request = CreateAccountRequest.builder()
                .firstName("Sarah")
                .lastName("Okonjo")
                .phone("+2348012345678")
                .email("sarah.okonjo@example.com")
                .bvnOrNin(null)
                .build();

        CreateAccountResponse response = mockBankingProvider.createAccount(request);

        assertThat(response.accountNumber()).matches("^20\\d{8}$");
        assertThat(response.tierLevel()).isEqualTo(1);
        assertThat(response.identityId()).isNull();
    }
}
