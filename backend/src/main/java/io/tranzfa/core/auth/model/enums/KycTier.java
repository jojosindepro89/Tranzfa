package io.tranzfa.core.auth.model.enums;

import io.tranzfa.core.common.model.Money;

/**
 * CBN Regulatory KYC Tiers and associated daily transaction limits in minor units.
 */
public enum KycTier {

    /**
     * Tier 1 (Phone Verified): ₦50,000.00 daily limit (5,000,000 kobo).
     */
    TIER_1(5_000_000L),

    /**
     * Tier 2 (BVN/NIN Linked): ₦200,000.00 daily limit (20,000,000 kobo).
     */
    TIER_2(20_000_000L),

    /**
     * Tier 3 (Government ID & Address Verified): ₦10,000,000.00 daily limit (1,000,000,000 kobo).
     */
    TIER_3(1_000_000_000L);

    private final long defaultDailyLimitMinor;

    KycTier(long defaultDailyLimitMinor) {
        this.defaultDailyLimitMinor = defaultDailyLimitMinor;
    }

    public long getDefaultDailyLimitMinor() {
        return defaultDailyLimitMinor;
    }

    public Money getDefaultDailyLimitMoney() {
        return Money.ofKobo(defaultDailyLimitMinor);
    }
}
