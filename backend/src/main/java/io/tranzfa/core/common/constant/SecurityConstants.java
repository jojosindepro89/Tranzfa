package io.tranzfa.core.common.constant;

public final class SecurityConstants {

    private SecurityConstants() {
    }

    public static final String JWT_HEADER = "Authorization";
    public static final String JWT_PREFIX = "Bearer ";
    public static final String JWT_SECRET_CONFIG_KEY = "app.jwt.secret";
    public static final String JWT_SECRET_DEFAULT_VALUE = "tranzfa_super_secret_jwt_key_2026_fintech_production_signature_key_min_256_bits!";

    public static final String USERNAME_CLAIM = "username";
    public static final String USER_ID_CLAIM = "userId";
    public static final String EMAIL_CLAIM = "email";
    public static final String ACCOUNT_NUMBER_CLAIM = "accountNumber";
    public static final String AUTHORITY_CLAIM = "authorities";
    public static final String KYC_TIER_CLAIM = "kycTier";

    public static final String INVALID_TOKEN_MSG = "Invalid or expired JWT authorization token.";
    public static final String ACCESS_DENIED_MSG = "Access denied: insufficient permissions.";
    public static final String FACTOR_3_REQUIRED_MSG = "Factor 3 Transaction Security PIN required for this monetary operation.";
}
