package io.tranzfa.core.banking.provider;

public interface CoreBankingProvider {

    String getProviderName();

    CreateAccountResponse createAccount(CreateAccountRequest request);
}
