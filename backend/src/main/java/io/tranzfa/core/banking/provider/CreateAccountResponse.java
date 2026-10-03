package io.tranzfa.core.banking.provider;

import lombok.Builder;

@Builder
public record CreateAccountResponse(
        String accountNumber,
        String bankCode,
        String bankName,
        String externalAccountId,
        String externalCustomerId,
        String identityId,
        int tierLevel,
        String metadataJson
) {}
