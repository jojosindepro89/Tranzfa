package io.tranzfa.core.account.service;

import io.tranzfa.core.account.model.entity.Account;
import io.tranzfa.core.account.model.entity.ExternalAccountMapping;
import io.tranzfa.core.account.model.enums.AccountStatus;
import io.tranzfa.core.account.model.enums.AccountType;
import io.tranzfa.core.account.repository.AccountRepository;
import io.tranzfa.core.account.repository.ExternalAccountMappingRepository;
import io.tranzfa.core.account.service.impl.AccountServiceImpl;
import io.tranzfa.core.auth.model.entity.Customer;
import io.tranzfa.core.auth.model.entity.Identity;
import io.tranzfa.core.auth.model.enums.IdentityType;
import io.tranzfa.core.auth.model.enums.KycTier;
import io.tranzfa.core.banking.provider.CoreBankingProvider;
import io.tranzfa.core.banking.provider.CreateAccountRequest;
import io.tranzfa.core.banking.provider.CreateAccountResponse;
import io.tranzfa.core.banking.provider.exception.IdentityVerificationFailedException;
import io.tranzfa.core.kyc.model.entity.KycVerification;
import io.tranzfa.core.kyc.repository.KycVerificationRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AccountServiceTest {

    @Mock
    private CoreBankingProvider bankingProvider;
    @Mock
    private AccountRepository accountRepository;
    @Mock
    private ExternalAccountMappingRepository externalAccountMappingRepository;
    @Mock
    private KycVerificationRepository kycVerificationRepository;

    private AccountService accountService;

    @BeforeEach
    void setUp() {
        accountService = new AccountServiceImpl(
                bankingProvider,
                accountRepository,
                externalAccountMappingRepository,
                kycVerificationRepository
        );
    }

    @Test
    @DisplayName("Should create SAVINGS account with authentic NUBAN and Tier 2 daily limit when BVN is verified")
    void shouldCreateSavingsAccountWithAuthenticNubanAndTier2Limit() {
        Identity identity = Identity.builder()
                .publicId("id_cust_1")
                .identityType(IdentityType.CUSTOMER)
                .build();
        identity.setId(1L);

        Customer customer = Customer.builder()
                .identity(identity)
                .firstName("Sarah")
                .middleName("Chinyere")
                .lastName("Okonjo")
                .email("sarah.okonjo@example.com")
                .phone("+2348012345678")
                .kycTier(KycTier.TIER_2)
                .build();
        customer.setId(10L);

        CreateAccountResponse providerResponse = CreateAccountResponse.builder()
                .accountNumber("2048591823")
                .bankCode("090286")
                .bankName("Safe Haven Microfinance Bank")
                .externalAccountId("sh_acct_8829103948")
                .externalCustomerId("sh_cust_99201928")
                .identityId("sh_id_772635418293")
                .tierLevel(2)
                .metadataJson("{\"status\":\"active\"}")
                .build();

        when(bankingProvider.getProviderName()).thenReturn("SAFEHAVEN");
        when(bankingProvider.createAccount(any(CreateAccountRequest.class))).thenReturn(providerResponse);

        Account savedAccount = Account.builder()
                .customer(customer)
                .accountNumber("2048591823")
                .accountName("Sarah Chinyere Okonjo")
                .currency("NGN")
                .accountType(AccountType.SAVINGS)
                .status(AccountStatus.ACTIVE)
                .availableBalance(0L)
                .ledgerBalance(0L)
                .dailyLimit(20_000_000L)
                .build();
        savedAccount.setId(100L);
        when(accountRepository.save(any(Account.class))).thenReturn(savedAccount);

        Account result = accountService.createAccount(customer, "1998-05-12", "22233344455");

        assertThat(result.getAccountNumber()).isEqualTo("2048591823");
        assertThat(result.getAccountType()).isEqualTo(AccountType.SAVINGS);

        ArgumentCaptor<Account> accountCaptor = ArgumentCaptor.forClass(Account.class);
        verify(accountRepository).save(accountCaptor.capture());
        Account capturedAccount = accountCaptor.getValue();
        assertThat(capturedAccount.getAccountNumber()).isEqualTo("2048591823");
        assertThat(capturedAccount.getAccountType()).isEqualTo(AccountType.SAVINGS);
        assertThat(capturedAccount.getDailyLimit()).isEqualTo(20_000_000L); // ₦200,000.00 Tier 2
        assertThat(capturedAccount.getAvailableBalance()).isEqualTo(0L);

        ArgumentCaptor<ExternalAccountMapping> mappingCaptor = ArgumentCaptor.forClass(ExternalAccountMapping.class);
        verify(externalAccountMappingRepository).save(mappingCaptor.capture());
        ExternalAccountMapping capturedMapping = mappingCaptor.getValue();
        assertThat(capturedMapping.getProvider()).isEqualTo("SAFEHAVEN");
        assertThat(capturedMapping.getBankCode()).isEqualTo("090286");
        assertThat(capturedMapping.getBankName()).isEqualTo("Safe Haven Microfinance Bank");
        assertThat(capturedMapping.getExternalAccountId()).isEqualTo("sh_acct_8829103948");

        ArgumentCaptor<KycVerification> kycCaptor = ArgumentCaptor.forClass(KycVerification.class);
        verify(kycVerificationRepository).save(kycCaptor.capture());
        KycVerification capturedKyc = kycCaptor.getValue();
        assertThat(capturedKyc.getTierLevel()).isEqualTo(2);
        assertThat(capturedKyc.getBvnMasked()).isEqualTo("222******55");
    }

    @Test
    @DisplayName("Should halt account creation and not save account if banking provider throws IdentityVerificationFailedException")
    void shouldHaltWhenIdentityVerificationFails() {
        Customer customer = Customer.builder()
                .firstName("Sarah")
                .lastName("Okonjo")
                .email("sarah.okonjo@example.com")
                .phone("+2348012345678")
                .kycTier(KycTier.TIER_2)
                .build();
        customer.setId(10L);

        when(bankingProvider.createAccount(any(CreateAccountRequest.class)))
                .thenThrow(new IdentityVerificationFailedException("BVN verification failed: Date of birth mismatch"));

        assertThatThrownBy(() -> accountService.createAccount(customer, "1998-05-12", "22233344455"))
                .isInstanceOf(IdentityVerificationFailedException.class)
                .hasMessageContaining("BVN verification failed");

        verify(accountRepository, never()).save(any());
        verify(externalAccountMappingRepository, never()).save(any());
        verify(kycVerificationRepository, never()).save(any());
    }

    @Test
    @DisplayName("Should update account daily limits when user upgrades to Tier 3")
    void shouldUpdateDailyLimits() {
        Account account = Account.builder()
                .accountNumber("2048591823")
                .dailyLimit(20_000_000L)
                .build();
        account.setId(50L);

        when(accountRepository.findAllByCustomerId(10L)).thenReturn(List.of(account));

        accountService.updateDailyLimits(10L, KycTier.TIER_3);

        ArgumentCaptor<Account> captor = ArgumentCaptor.forClass(Account.class);
        verify(accountRepository).save(captor.capture());
        assertThat(captor.getValue().getDailyLimit()).isEqualTo(1_000_000_000L); // ₦10,000,000.00
    }
}
