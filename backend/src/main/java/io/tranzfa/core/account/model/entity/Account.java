package io.tranzfa.core.account.model.entity;

import io.tranzfa.core.account.model.enums.AccountStatus;
import io.tranzfa.core.account.model.enums.AccountType;
import io.tranzfa.core.auth.model.entity.Customer;
import io.tranzfa.core.common.model.Money;
import io.tranzfa.core.common.model.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.Version;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "accounts")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Account extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "customer_id", nullable = false)
    private Customer customer;

    @Column(name = "account_number", nullable = false, unique = true, length = 32)
    private String accountNumber;

    @Column(name = "account_name", nullable = false)
    private String accountName;

    @Column(name = "currency", nullable = false, length = 8)
    @Builder.Default
    private String currency = "NGN";

    @Enumerated(EnumType.STRING)
    @Column(name = "account_type", nullable = false, length = 32)
    @Builder.Default
    private AccountType accountType = AccountType.SAVINGS;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 32)
    @Builder.Default
    private AccountStatus status = AccountStatus.ACTIVE;

    /**
     * Available balance in minor units (e.g. 50050 = ₦500.50).
     * Fast cache/projection of authoritative double-entry ledger.
     */
    @Column(name = "available_balance", nullable = false)
    @Builder.Default
    private Long availableBalance = 0L;

    /**
     * Settled ledger balance in minor units.
     */
    @Column(name = "ledger_balance", nullable = false)
    @Builder.Default
    private Long ledgerBalance = 0L;

    /**
     * Daily transaction limit in minor units (defaults to KYC Tier 1 limit: 5,000,000 kobo = ₦50,000.00).
     */
    @Column(name = "daily_limit", nullable = false)
    @Builder.Default
    private Long dailyLimit = 5_000_000L;

    @Version
    @Column(name = "version", nullable = false)
    @Builder.Default
    private Long version = 0L;

    // --- DOMAIN HELPER METHODS ---

    public Money getAvailableMoney() {
        return Money.ofMinor(availableBalance, currency);
    }

    public Money getLedgerMoney() {
        return Money.ofMinor(ledgerBalance, currency);
    }

    public Money getDailyLimitMoney() {
        return Money.ofMinor(dailyLimit, currency);
    }
}
