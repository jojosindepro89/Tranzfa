package io.tranzfa.core.account.service;

import io.tranzfa.core.account.model.entity.Account;
import io.tranzfa.core.auth.model.entity.Customer;
import io.tranzfa.core.auth.model.enums.KycTier;

public interface AccountService {

    Account createAccount(Customer customer, String dateOfBirth, String bvnOrNin);

    void updateDailyLimits(Long customerId, KycTier newTier);
}
