package io.tranzfa.core.account.service.impl;

import io.tranzfa.core.account.model.entity.Account;
import io.tranzfa.core.account.model.entity.ExternalAccountMapping;
import io.tranzfa.core.account.model.enums.AccountStatus;
import io.tranzfa.core.account.model.enums.AccountType;
import io.tranzfa.core.account.repository.AccountRepository;
import io.tranzfa.core.account.repository.ExternalAccountMappingRepository;
import io.tranzfa.core.account.service.AccountService;
import io.tranzfa.core.auth.model.entity.Customer;
import io.tranzfa.core.auth.model.enums.KycTier;
import io.tranzfa.core.banking.provider.CoreBankingProvider;
import io.tranzfa.core.banking.provider.CreateAccountRequest;
import io.tranzfa.core.banking.provider.CreateAccountResponse;
import io.tranzfa.core.kyc.model.entity.KycVerification;
import io.tranzfa.core.kyc.repository.KycVerificationRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class AccountServiceImpl implements AccountService {

    private final CoreBankingProvider bankingProvider;
    private final AccountRepository accountRepository;
    private final ExternalAccountMappingRepository externalAccountMappingRepository;
    private final KycVerificationRepository kycVerificationRepository;

    @Override
    @Transactional
    public Account createAccount(Customer customer, String dateOfBirth, String bvnOrNin) {
        log.info("Creating retail savings account for customer ID: {}", customer.getId());

        // 1. Build provider-agnostic request
        CreateAccountRequest request = CreateAccountRequest.builder()
                .firstName(customer.getFirstName())
                .middleName(customer.getMiddleName())
                .lastName(customer.getLastName())
                .dateOfBirth(dateOfBirth)
                .phone(customer.getPhone())
                .email(customer.getEmail())
                .bvnOrNin(bvnOrNin)
                .currency("NGN")
                .build();

        // 2. Delegate to the active core banking provider
        // (Provider encapsulates identity verification against BVN/NIN and authentic NUBAN allocation)
        CreateAccountResponse response = bankingProvider.createAccount(request);

        // 3. Determine tier daily limit
        KycTier tier = customer.getKycTier() != null ? customer.getKycTier() : KycTier.TIER_1;
        long dailyLimitMinor = tier.getDefaultDailyLimitMinor();

        // 4. Persist Account entity with authentic NUBAN from banking provider
        Account account = Account.builder()
                .customer(customer)
                .accountNumber(response.accountNumber())
                .accountName(customer.getFullName())
                .currency("NGN")
                .accountType(AccountType.SAVINGS)
                .status(AccountStatus.ACTIVE)
                .availableBalance(0L)
                .ledgerBalance(0L)
                .dailyLimit(dailyLimitMinor)
                .build();
        Account savedAccount = accountRepository.save(account);

        // 5. Persist External BaaS Account Mapping
        ExternalAccountMapping mapping = ExternalAccountMapping.builder()
                .account(savedAccount)
                .provider(bankingProvider.getProviderName())
                .externalAccountId(response.externalAccountId())
                .externalCustomerId(response.externalCustomerId())
                .bankCode(response.bankCode())
                .bankName(response.bankName())
                .isPrimary(true)
                .status("ACTIVE")
                .metadataJson(response.metadataJson())
                .build();
        externalAccountMappingRepository.save(mapping);

        // 6. If BVN/NIN was verified, record KYC verification
        if (StringUtils.isNotBlank(bvnOrNin)) {
            String masked = maskIdentifier(bvnOrNin.trim());
            KycVerification kycVerification = KycVerification.builder()
                    .customer(customer)
                    .tierLevel(response.tierLevel() > 0 ? response.tierLevel() : 2)
                    .bvnMasked(masked)
                    .ninMasked(masked)
                    .status("APPROVED")
                    .externalVerificationId(response.identityId() != null ? response.identityId() : "v_bvn_" + response.accountNumber())
                    .build();
            kycVerificationRepository.save(kycVerification);
        }

        log.info("Successfully created {} account [{}] for customer ID {} via banking provider [{}]",
                savedAccount.getAccountType(), savedAccount.getAccountNumber(), customer.getId(), bankingProvider.getProviderName());

        return savedAccount;
    }

    @Override
    @Transactional
    public void updateDailyLimits(Long customerId, KycTier newTier) {
        long newLimitMinor = newTier.getDefaultDailyLimitMinor();
        List<Account> accounts = accountRepository.findAllByCustomerId(customerId);
        for (Account account : accounts) {
            account.setDailyLimit(newLimitMinor);
            accountRepository.save(account);
        }
        log.info("Updated daily limits for customer ID {} accounts to {} minor units", customerId, newLimitMinor);
    }

    private String maskIdentifier(String value) {
        if (value.length() < 6) {
            return "***";
        }
        return value.substring(0, 3) + "******" + value.substring(value.length() - 2);
    }
}
