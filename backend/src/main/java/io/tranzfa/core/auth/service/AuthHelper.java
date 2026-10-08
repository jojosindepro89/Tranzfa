package io.tranzfa.core.auth.service;

import io.tranzfa.core.account.model.entity.Account;
import io.tranzfa.core.account.repository.AccountRepository;
import io.tranzfa.core.account.repository.ExternalAccountMappingRepository;
import io.tranzfa.core.auth.dto.AuthTokenResponse;
import io.tranzfa.core.auth.dto.UserProfileResponse;
import io.tranzfa.core.auth.model.entity.Customer;
import io.tranzfa.core.auth.model.entity.Identity;
import io.tranzfa.core.auth.model.entity.Session;
import io.tranzfa.core.auth.model.entity.StaffUser;
import io.tranzfa.core.auth.model.enums.IdentityType;
import io.tranzfa.core.auth.model.enums.OtpChannel;
import io.tranzfa.core.auth.model.enums.OtpPurpose;
import io.tranzfa.core.auth.repository.CustomerRepository;
import io.tranzfa.core.auth.repository.IdentityRepository;
import io.tranzfa.core.auth.repository.SessionRepository;
import io.tranzfa.core.auth.repository.StaffUserRepository;
import io.tranzfa.core.common.exception.ResourceNotFoundException;
import io.tranzfa.core.config.AppProperties;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.codec.digest.DigestUtils;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Collections;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class AuthHelper {

    private final IdentityRepository identityRepository;
    private final CustomerRepository customerRepository;
    private final StaffUserRepository staffUserRepository;
    private final AccountRepository accountRepository;
    private final ExternalAccountMappingRepository externalAccountMappingRepository;
    private final SessionRepository sessionRepository;
    private final JwtTokenProvider jwtTokenProvider;
    private final PinService pinService;
    private final OtpService otpService;
    private final AppProperties appProperties;

    @Transactional(readOnly = true)
    public Identity resolveIdentity(String identifier, IdentityType userType) {
        if (identifier == null || identifier.isBlank()) {
            throw new ResourceNotFoundException("Identifier cannot be empty.");
        }
        String cleanId = identifier.trim();

        if (userType == null || userType == IdentityType.CUSTOMER) {
            return customerRepository.findByIdentifier(cleanId)
                    .map(Customer::getIdentity)
                    .orElseThrow(() -> new ResourceNotFoundException("No customer found matching identifier: " + identifier));
        } else {
            return staffUserRepository.findByIdentifier(cleanId)
                    .map(StaffUser::getIdentity)
                    .orElseThrow(() -> new ResourceNotFoundException("No staff user found matching identifier: " + identifier));
        }
    }

    @Transactional(readOnly = true)
    public UserProfileResponse buildUserProfile(Identity identity) {
        if (identity.getIdentityType() == IdentityType.CUSTOMER) {
            Customer customer = customerRepository.findByIdentityId(identity.getId())
                    .orElseThrow(() -> new ResourceNotFoundException("Customer profile not found for identity ID: " + identity.getId()));

            Account primaryAccount = accountRepository.findAllByCustomerId(customer.getId())
                    .stream()
                    .findFirst()
                    .orElse(null);

            String bankCode = null;
            String bankName = null;
            if (primaryAccount != null) {
                var mappingOpt = externalAccountMappingRepository.findByAccountIdAndIsPrimaryTrue(primaryAccount.getId());
                if (mappingOpt.isPresent()) {
                    bankCode = mappingOpt.get().getBankCode();
                    bankName = mappingOpt.get().getBankName();
                }
            }

            boolean isPinSet = pinService.isPinSet(identity);
            io.tranzfa.core.common.model.Money availableMoney = primaryAccount != null
                    ? primaryAccount.getAvailableMoney()
                    : io.tranzfa.core.common.model.Money.zeroNgn();

            boolean isCooldownActive = false;
            BigDecimal effectiveLimit = customer.getKycTier().getDefaultDailyLimitMoney().toMajorUnits();

            if (appProperties.banking() != null && customer.getLastDeviceSwitchAt() != null) {
                int cooldownHours = appProperties.banking().deviceSwitchCooldownHours();
                double cooldownLimitNgn = appProperties.banking().deviceSwitchCooldownLimitNgn();
                long hoursSinceSwitch = Duration.between(customer.getLastDeviceSwitchAt(), Instant.now()).toHours();
                if (hoursSinceSwitch < cooldownHours) {
                    isCooldownActive = true;
                    BigDecimal cbnCap = BigDecimal.valueOf(cooldownLimitNgn);
                    effectiveLimit = effectiveLimit.min(cbnCap);
                }
            }

            return UserProfileResponse.builder()
                    .identityId(identity.getId())
                    .publicId(identity.getPublicId())
                    .userType(identity.getIdentityType())
                    .customerId(customer.getId())
                    .firstName(customer.getFirstName())
                    .middleName(customer.getMiddleName())
                    .lastName(customer.getLastName())
                    .fullName(customer.getFullName())
                    .email(customer.getEmail())
                    .phone(customer.getPhone())
                    .avatarUrl(customer.getAvatarUrl())
                    .kycTier(customer.getKycTier())
                    .primaryAccountNumber(primaryAccount != null ? primaryAccount.getAccountNumber() : null)
                    .primaryBankCode(primaryAccount != null ? bankCode : null)
                    .primaryBankName(primaryAccount != null ? bankName : null)
                    .primaryAccountBalance(availableMoney.toMajorUnits())
                    .primaryAccountBalanceMinor(availableMoney.minorUnits())
                    .primaryAccountBalanceFormatted(availableMoney.formatDisplay())
                    .primaryCurrency(availableMoney.currency())
                    .isPinSet(isPinSet)
                    .currentDeviceId(customer.getCurrentDeviceId())
                    .isDeviceCooldownActive(isCooldownActive)
                    .effectiveDailyLimit(effectiveLimit)
                    .build();
        } else {
            StaffUser staff = staffUserRepository.findByIdentityId(identity.getId())
                    .orElseThrow(() -> new ResourceNotFoundException("Staff profile not found for identity ID: " + identity.getId()));

            return UserProfileResponse.builder()
                    .identityId(identity.getId())
                    .publicId(identity.getPublicId())
                    .userType(identity.getIdentityType())
                    .firstName(staff.getFirstName())
                    .lastName(staff.getLastName())
                    .fullName(staff.getFirstName() + " " + staff.getLastName())
                    .email(staff.getCorporateEmail())
                    .phone(staff.getPhone())
                    .isPinSet(false)
                    .build();
        }
    }

    @Transactional
    public AuthTokenResponse issueTokensAndCreateSession(
            Identity identity,
            String deviceId,
            String deviceName,
            String ipAddress,
            String userAgent) {

        // 1. CBN Single Active Device Rule: Revoke all existing active sessions for this identity
        List<Session> activeSessions = sessionRepository.findAllByIdentityIdAndRevokedAtIsNull(identity.getId());
        if (!activeSessions.isEmpty()) {
            Instant now = Instant.now();
            activeSessions.forEach(s -> s.setRevokedAt(now));
            sessionRepository.saveAll(activeSessions);
            log.info("Revoked {} previous active session(s) for identity ID: {} (CBN Single Active Device Rule)",
                    activeSessions.size(), identity.getId());
        }

        // 2. Customer device binding & device switch detection
        if (identity.getIdentityType() == IdentityType.CUSTOMER && deviceId != null && !deviceId.isBlank()) {
            customerRepository.findByIdentityId(identity.getId()).ifPresent(c -> {
                if (c.getCurrentDeviceId() != null && !deviceId.equals(c.getCurrentDeviceId())) {
                    c.setLastDeviceSwitchAt(Instant.now());
                    if (appProperties.banking() != null) {
                        int hours = appProperties.banking().deviceSwitchCooldownHours();
                        double limit = appProperties.banking().deviceSwitchCooldownLimitNgn();
                        log.warn("Device switch detected for customer ID: {} (Old: {}, New: {}). CBN {}h limit cooldown of ₦{} activated.",
                                c.getId(), c.getCurrentDeviceId(), deviceId, hours, limit);
                    }
                }
                c.setCurrentDeviceId(deviceId);
                customerRepository.save(c);
            });
        }

        UserProfileResponse profile = buildUserProfile(identity);
        String username = profile.getEmail() != null ? profile.getEmail() : profile.getPhone();
        List<String> authorities = identity.getIdentityType() == IdentityType.STAFF
                ? List.of("ROLE_STAFF")
                : List.of("ROLE_CUSTOMER");

        String accessToken = jwtTokenProvider.generateAccessToken(
                identity,
                username,
                authorities,
                profile.getKycTier(),
                profile.getPrimaryAccountNumber());

        String refreshToken = jwtTokenProvider.generateRefreshToken(identity);

        // Store hashed refresh token in sessions table for device tracking and revocation
        String hashedToken = DigestUtils.sha256Hex(refreshToken);
        Session session = Session.builder()
                .identity(identity)
                .refreshToken(hashedToken)
                .deviceId(deviceId)
                .deviceName(deviceName)
                .ipAddress(ipAddress)
                .userAgent(userAgent)
                .expiresAt(Instant.now().plus(30, ChronoUnit.DAYS))
                .build();

        sessionRepository.save(session);

        return AuthTokenResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn(jwtTokenProvider.getAccessTokenExpirationSeconds())
                .requiresOtp(false)
                .user(profile)
                .build();
    }

    @Transactional(readOnly = true)
    public boolean isNewDevice(Identity identity, String deviceId) {
        if (identity.getIdentityType() != IdentityType.CUSTOMER || deviceId == null || deviceId.isBlank()) {
            return false;
        }
        return customerRepository.findByIdentityId(identity.getId())
                .map(c -> c.getCurrentDeviceId() != null && !deviceId.equals(c.getCurrentDeviceId()))
                .orElse(false);
    }

    @Transactional
    public AuthTokenResponse triggerNewDeviceVerification(Identity identity, String deviceId, String deviceName) {
        Customer customer = customerRepository.findByIdentityId(identity.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Customer profile not found for identity ID: " + identity.getId()));
        String phone = customer.getPhone();
        otpService.generateAndSendOtp(phone, OtpPurpose.LOGIN_2FA, OtpChannel.SMS, identity);
        String challengeToken = jwtTokenProvider.generateVerificationToken(phone);
        String masked = maskRecipient(phone);

        log.warn("New device authorization challenge triggered for customer ID: {} on device: {}", customer.getId(), deviceId);

        return AuthTokenResponse.builder()
                .requiresOtp(true)
                .requiresDeviceVerification(true)
                .otpRecipientMasked(masked)
                .challengeToken(challengeToken)
                .tokenType("Bearer")
                .message("New device detected (" + (deviceName != null ? deviceName : deviceId) +
                        "). A 6-digit verification code has been sent to your registered phone number to authorize this device.")
                .build();
    }

    private String maskRecipient(String recipient) {
        if (recipient == null || recipient.length() < 6) {
            return "***";
        }
        int len = recipient.length();
        return recipient.substring(0, 4) + "******" + recipient.substring(len - 2);
    }
}
