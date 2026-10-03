package io.tranzfa.core.banking.provider.adapter;

import io.tranzfa.core.banking.provider.CoreBankingProvider;
import io.tranzfa.core.banking.provider.CreateAccountRequest;
import io.tranzfa.core.banking.provider.CreateAccountResponse;
import io.tranzfa.core.banking.provider.exception.IdentityVerificationFailedException;
import io.tranzfa.core.common.util.CodeGenerationUtil;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Component;

import java.time.Instant;

@Slf4j
@Component("mockBankingProvider")
public class MockBankingProvider implements CoreBankingProvider {

    public static final String PROVIDER_NAME = "MOCK";
    public static final String DEFAULT_BANK_CODE = "090286";
    public static final String DEFAULT_BANK_NAME = "Safe Haven Microfinance Bank";

    @Override
    public String getProviderName() {
        return PROVIDER_NAME;
    }

    @Override
    public CreateAccountResponse createAccount(CreateAccountRequest request) {
        log.info("[MOCK-BANK] Creating account for customer: {} ({})",
                request.getFullName(), request.email());

        String identityId = null;
        int tierLevel = 1;

        if (StringUtils.isNotBlank(request.bvnOrNin())) {
            String bvnOrNin = request.bvnOrNin().trim();

            if (!bvnOrNin.matches("^\\d{11}$")) {
                log.warn("[MOCK-BANK] BVN/NIN format validation failed for number: {}", bvnOrNin);
                throw new IdentityVerificationFailedException("Invalid BVN/NIN format: must be exactly 11 digits.");
            }

            if ("00000000000".equals(bvnOrNin) || "FailVerification".equalsIgnoreCase(request.lastName())) {
                log.warn("[MOCK-BANK] Identity verification rejected: BVN details mismatch simulated.");
                throw new IdentityVerificationFailedException(
                        "Identity verification failed: BVN details do not match provided customer name or date of birth.");
            }

            identityId = "mock_identity_" + CodeGenerationUtil.generateNumericString(12);
            tierLevel = 2;
            log.info("[MOCK-BANK] Identity verified successfully. Allocated mock identityId: {}", identityId);
        }

        String allocatedNuban = "20" + CodeGenerationUtil.generateNumericString(8);
        String externalAccountId = "mock_acct_" + CodeGenerationUtil.generateNumericString(10);
        String externalCustomerId = "mock_cust_" + CodeGenerationUtil.generateNumericString(8);
        String metadataJson = String.format("{\"mode\":\"MOCK\",\"allocatedAt\":\"%s\"}", Instant.now());

        log.info("[MOCK-BANK] NUBAN allocated: {} [{}] under Bank Code: {}",
                allocatedNuban, DEFAULT_BANK_NAME, DEFAULT_BANK_CODE);

        return CreateAccountResponse.builder()
                .accountNumber(allocatedNuban)
                .bankCode(DEFAULT_BANK_CODE)
                .bankName(DEFAULT_BANK_NAME)
                .externalAccountId(externalAccountId)
                .externalCustomerId(externalCustomerId)
                .identityId(identityId)
                .tierLevel(tierLevel)
                .metadataJson(metadataJson)
                .build();
    }
}
