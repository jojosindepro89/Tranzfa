package io.tranzfa.core.common.model;

import io.tranzfa.core.common.exception.ValidationException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class MoneyTest {

    @Test
    @DisplayName("Should create Money from Kobo and convert correctly to major units")
    void shouldConvertFromKoboToNaira() {
        Money money = Money.ofKobo(50050L);

        assertThat(money.minorUnits()).isEqualTo(50050L);
        assertThat(money.currency()).isEqualTo("NGN");
        assertThat(money.toMajorUnits()).isEqualByComparingTo(new BigDecimal("500.50"));
        assertThat(money.formatDisplay()).isEqualTo("₦500.50");
    }

    @Test
    @DisplayName("Should create Money from Naira BigDecimal and convert to minor units")
    void shouldConvertFromNairaToKobo() {
        Money money = Money.ofNaira(new BigDecimal("1240500.75"));

        assertThat(money.minorUnits()).isEqualTo(124050075L);
        assertThat(money.toMajorUnits()).isEqualByComparingTo(new BigDecimal("1240500.75"));
        assertThat(money.formatDisplay()).isEqualTo("₦1,240,500.75");
    }

    @Test
    @DisplayName("Should perform exact addition and subtraction in minor units")
    void shouldPerformArithmetic() {
        Money balance = Money.ofKobo(100000L); // ₦1,000.00
        Money transfer = Money.ofKobo(25050L); // ₦250.50
        Money fee = Money.ofKobo(1075L);       // ₦10.75

        Money remaining = balance.subtract(transfer).subtract(fee);

        assertThat(remaining.minorUnits()).isEqualTo(73875L); // ₦738.75
        assertThat(remaining.toMajorUnits()).isEqualByComparingTo(new BigDecimal("738.75"));
    }

    @Test
    @DisplayName("Should prevent monetary operations across mismatched currencies")
    void shouldRejectCurrencyMismatch() {
        Money ngn = Money.ofKobo(10000L);
        Money usd = Money.ofMinor(10000L, "USD");

        assertThatThrownBy(() -> ngn.add(usd))
                .isInstanceOf(ValidationException.class)
                .hasMessageContaining("Currency mismatch");
    }

    @Test
    @DisplayName("Should correctly compare monetary amounts")
    void shouldCompareMonetaryAmounts() {
        Money dailyLimit = Money.ofKobo(100_000_000L); // ₦1,000,000.00
        Money requested = Money.ofKobo(50_000_000L);   // ₦500,000.00

        assertThat(dailyLimit.isGreaterThanOrEqual(requested)).isTrue();
        assertThat(requested.isLessThan(dailyLimit)).isTrue();
        assertThat(dailyLimit.isPositive()).isTrue();
        assertThat(Money.zeroNgn().isZero()).isTrue();
    }
}
