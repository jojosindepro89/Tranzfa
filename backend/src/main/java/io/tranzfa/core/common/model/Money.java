package io.tranzfa.core.common.model;

import io.tranzfa.core.common.exception.ValidationException;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;

/**
 * Immutable Domain Value Object representing monetary amounts in minor units (e.g. kobo, cents).
 * Eliminates floating-point rounding errors and database precision mismatches across FinTech services.
 */
public record Money(long minorUnits, String currency) implements Comparable<Money> {

    public static final String DEFAULT_CURRENCY = "NGN";

    private static final Map<String, Integer> CURRENCY_DECIMALS = Map.of(
            "NGN", 2,
            "USD", 2,
            "EUR", 2,
            "GBP", 2,
            "KES", 2,
            "GHS", 2,
            "JPY", 0
    );

    private static final Map<String, String> CURRENCY_SYMBOLS = Map.of(
            "NGN", "₦",
            "USD", "$",
            "EUR", "€",
            "GBP", "£",
            "KES", "KSh",
            "GHS", "GH₵",
            "JPY", "¥"
    );

    public Money {
        currency = (currency == null || currency.isBlank()) ? DEFAULT_CURRENCY : currency.trim().toUpperCase();
    }

    // --- FACTORY METHODS ---

    public static Money ofKobo(long kobo) {
        return new Money(kobo, DEFAULT_CURRENCY);
    }

    public static Money ofNaira(BigDecimal naira) {
        if (naira == null) {
            return zeroNgn();
        }
        long kobo = naira.setScale(2, RoundingMode.HALF_UP)
                .multiply(BigDecimal.valueOf(100))
                .longValueExact();
        return new Money(kobo, DEFAULT_CURRENCY);
    }

    public static Money ofNaira(long naira) {
        return new Money(Math.multiplyExact(naira, 100L), DEFAULT_CURRENCY);
    }

    public static Money ofMinor(long minorUnits, String currency) {
        return new Money(minorUnits, currency);
    }

    public static Money zero(String currency) {
        return new Money(0L, currency);
    }

    public static Money zeroNgn() {
        return new Money(0L, DEFAULT_CURRENCY);
    }

    // --- CONVERSIONS ---

    public int getDecimals() {
        return CURRENCY_DECIMALS.getOrDefault(currency, 2);
    }

    public BigDecimal toMajorUnits() {
        int decimals = getDecimals();
        return BigDecimal.valueOf(minorUnits, decimals);
    }

    public String getSymbol() {
        return CURRENCY_SYMBOLS.getOrDefault(currency, currency + " ");
    }

    public String formatDisplay() {
        BigDecimal major = toMajorUnits();
        DecimalFormatSymbols symbols = new DecimalFormatSymbols(Locale.US);
        DecimalFormat formatter = new DecimalFormat("#,##0.00", symbols);
        return getSymbol() + formatter.format(major);
    }

    // --- ARITHMETIC ---

    public Money add(Money other) {
        validateSameCurrency(other);
        return new Money(Math.addExact(this.minorUnits, other.minorUnits), this.currency);
    }

    public Money subtract(Money other) {
        validateSameCurrency(other);
        return new Money(Math.subtractExact(this.minorUnits, other.minorUnits), this.currency);
    }

    public boolean isPositive() {
        return minorUnits > 0;
    }

    public boolean isZero() {
        return minorUnits == 0;
    }

    public boolean isNegative() {
        return minorUnits < 0;
    }

    public boolean isGreaterThanOrEqual(Money other) {
        validateSameCurrency(other);
        return this.minorUnits >= other.minorUnits;
    }

    public boolean isLessThan(Money other) {
        validateSameCurrency(other);
        return this.minorUnits < other.minorUnits;
    }

    private void validateSameCurrency(Money other) {
        Objects.requireNonNull(other, "Cannot perform monetary operations with null Money");
        if (!this.currency.equalsIgnoreCase(other.currency)) {
            throw new ValidationException(String.format(
                    "Currency mismatch: cannot operate between %s and %s without an FX rate",
                    this.currency, other.currency));
        }
    }

    @Override
    public int compareTo(Money o) {
        validateSameCurrency(o);
        return Long.compare(this.minorUnits, o.minorUnits);
    }

    @Override
    public String toString() {
        return formatDisplay() + " (" + minorUnits + " " + currency + " minor units)";
    }
}
