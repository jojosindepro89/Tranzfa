package io.tranzfa.core.common.util;

import java.security.SecureRandom;
import java.time.Instant;
import java.time.format.DateTimeFormatter;

public final class CodeGenerationUtil {

    private static final SecureRandom RANDOM = new SecureRandom();

    private CodeGenerationUtil() {
    }

    /**
     * Generates a 6-digit numeric OTP code.
     */
    public static String generate6DigitOtp() {
        int code = 100_000 + RANDOM.nextInt(900_000);
        return String.valueOf(code);
    }

    /**
     * Generates a unique transaction reference (e.g. TZ-1726928192-8921).
     */
    public static String generateTransactionReference() {
        long timestamp = Instant.now().getEpochSecond();
        int rand = 1000 + RANDOM.nextInt(9000);
        return "TZ-" + timestamp + "-" + rand;
    }

    /**
     * Generates a 30-digit NIBSS NIP Session ID formatted per CBN specification:
     * BankCode (6 digits) + YYMMDDHHmmss (12 digits) + UniqueSequence (12 digits)
     */
    public static String generateNipSessionId(String bankCode) {
        String paddedBankCode = String.format("%06d", Integer.parseInt(bankCode.replaceAll("\\D", "")));
        String timestampStr = DateTimeFormatter.ofPattern("yyMMddHHmmss")
                .withZone(java.time.ZoneOffset.UTC)
                .format(Instant.now());
        long seq = 100000000000L + (long) (RANDOM.nextDouble() * 899999999999L);
        return paddedBankCode + timestampStr + seq;
    }

    /**
     * Generates a simulated 10-digit NUBAN account number starting with 02 or 20.
     */
    public static String generateNubanAccountNumber() {
        int base = 10_000_000 + RANDOM.nextInt(89_999_999);
        return "20" + base;
    }

    /**
     * Generates a unique SafeHaven client request idempotency key.
     */
    public static String generateIdempotencyKey() {
        return "tranzfa_sh_" + System.currentTimeMillis() + "_" + RANDOM.nextInt(10000);
    }

    /**
     * Generates a numeric string of specified length.
     */
    public static String generateNumericString(int length) {
        StringBuilder sb = new StringBuilder(length);
        for (int i = 0; i < length; i++) {
            sb.append(RANDOM.nextInt(10));
        }
        return sb.toString();
    }

    /**
     * Generates a numeric OTP code of specified length.
     */
    public static String generateOtp(int length) {
        return generateNumericString(length);
    }

    /**
     * Generates a public UUID-based ID with prefix (e.g. id_cust_...).
     */
    public static String generatePublicId(String prefix) {
        return prefix + java.util.UUID.randomUUID().toString().replace("-", "");
    }
}
