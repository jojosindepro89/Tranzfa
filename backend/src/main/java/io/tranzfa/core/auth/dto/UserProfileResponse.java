package io.tranzfa.core.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import io.tranzfa.core.auth.model.enums.IdentityType;
import io.tranzfa.core.auth.model.enums.KycTier;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserProfileResponse {

    @Schema(description = "Identity Root Database ID", example = "1")
    private Long identityId;

    @Schema(description = "Identity Public UUID", example = "id_cust_983742")
    private String publicId;

    @Schema(description = "Type of identity", example = "CUSTOMER")
    private IdentityType userType;

    @Schema(description = "Customer Profile ID (if retail customer)", example = "1")
    private Long customerId;

    @Schema(description = "Customer legal first name", example = "Sarah")
    private String firstName;

    @Schema(description = "Customer legal middle name", example = "Chinyere")
    private String middleName;

    @Schema(description = "Customer legal last name", example = "Okonjo")
    private String lastName;

    @Schema(description = "Computed full legal name", example = "Sarah Chinyere Okonjo")
    private String fullName;

    @Schema(description = "Primary email", example = "sarah.okonjo@example.com")
    private String email;

    @Schema(description = "Primary phone", example = "+2348012345678")
    private String phone;

    @Schema(description = "Avatar photo URL", example = "https://images.unsplash.com/photo-1534528741775-53994a69daeb")
    private String avatarUrl;

    @Schema(description = "Primary Bank 6-digit CBN/NIP Code", example = "090286")
    private String primaryBankCode;

    @Schema(description = "Primary Bank Name", example = "Safe Haven Microfinance Bank")
    private String primaryBankName;

    @Schema(description = "Customer KYC Verification Tier", example = "TIER_1")
    private KycTier kycTier;

    @Schema(description = "Primary NGN 10-digit NIP Account Number", example = "2001928374")
    private String primaryAccountNumber;

    @Schema(description = "Current available balance in major currency units (e.g. Naira)", example = "450250.00")
    private BigDecimal primaryAccountBalance;

    @Schema(description = "Current available balance in integer minor units (e.g. Kobo)", example = "45025000")
    private Long primaryAccountBalanceMinor;

    @Schema(description = "Formatted balance with currency symbol for direct UI rendering", example = "₦450,250.00")
    private String primaryAccountBalanceFormatted;

    @Schema(description = "Currency code", example = "NGN")
    private String primaryCurrency;

    @Schema(description = "Whether the user has set their 4-digit transaction PIN", example = "false")
    private boolean isPinSet;

    @Schema(description = "Currently active/bound device UUID", example = "dev-ios-a918f-2831")
    private String currentDeviceId;

    @Schema(description = "Whether the CBN 24-hour device switch limit cooldown is currently active", example = "false")
    private boolean isDeviceCooldownActive;

    @Schema(description = "Effective daily transaction limit in major currency units (Naira), accounting for CBN device cooldown", example = "20000.00")
    private BigDecimal effectiveDailyLimit;
}
