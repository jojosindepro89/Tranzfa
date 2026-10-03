package io.tranzfa.core.auth.service.impl;

import io.tranzfa.core.account.model.entity.Account;
import io.tranzfa.core.account.service.AccountService;
import io.tranzfa.core.auth.dto.AuthTokenResponse;
import io.tranzfa.core.auth.dto.InitiatePhoneRequest;
import io.tranzfa.core.auth.dto.InitiatePhoneResponse;
import io.tranzfa.core.auth.dto.LoginRequest;
import io.tranzfa.core.auth.dto.PersonalDetailsRequest;
import io.tranzfa.core.auth.dto.RefreshTokenRequest;
import io.tranzfa.core.auth.dto.UploadDocumentRequest;
import io.tranzfa.core.auth.dto.UserProfileResponse;
import io.tranzfa.core.auth.dto.VerifyLoginOtpRequest;
import io.tranzfa.core.auth.dto.VerifyPhoneOtpRequest;
import io.tranzfa.core.auth.dto.VerifyPhoneOtpResponse;
import io.tranzfa.core.auth.model.entity.Customer;
import io.tranzfa.core.auth.model.entity.Identity;
import io.tranzfa.core.auth.model.entity.PasswordCredential;
import io.tranzfa.core.auth.model.entity.Session;
import io.tranzfa.core.auth.model.enums.IdentityType;
import io.tranzfa.core.auth.model.enums.KycTier;
import io.tranzfa.core.auth.model.enums.OtpPurpose;
import io.tranzfa.core.auth.repository.CustomerRepository;
import io.tranzfa.core.auth.repository.IdentityRepository;
import io.tranzfa.core.auth.repository.PasswordCredentialRepository;
import io.tranzfa.core.auth.repository.SessionRepository;
import io.tranzfa.core.auth.service.AuthHelper;
import io.tranzfa.core.auth.service.AuthService;
import io.tranzfa.core.auth.service.JwtTokenProvider;
import io.tranzfa.core.auth.service.OtpService;
import io.tranzfa.core.auth.service.PinService;
import io.tranzfa.core.auth.strategy.LoginStrategyFactory;
import io.tranzfa.core.common.exception.ConflictException;
import io.tranzfa.core.common.exception.ResourceNotFoundException;
import io.tranzfa.core.common.exception.UnauthorizedException;
import io.tranzfa.core.common.util.CodeGenerationUtil;
import io.tranzfa.core.config.AppProperties;
import io.tranzfa.core.kyc.model.entity.KycVerification;
import io.tranzfa.core.kyc.repository.KycVerificationRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.codec.digest.DigestUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final IdentityRepository identityRepository;
    private final CustomerRepository customerRepository;
    private final PasswordCredentialRepository passwordCredentialRepository;
    private final AccountService accountService;
    private final KycVerificationRepository kycVerificationRepository;
    private final SessionRepository sessionRepository;
    private final OtpService otpService;
    private final PinService pinService;
    private final JwtTokenProvider jwtTokenProvider;
    private final AuthHelper authHelper;
    private final LoginStrategyFactory loginStrategyFactory;
    private final PasswordEncoder passwordEncoder;
    private final AppProperties appProperties;

    @Override
    @Transactional
    public InitiatePhoneResponse initiatePhone(InitiatePhoneRequest request) {
        String phone = request.getPhone().trim();
        if (customerRepository.existsByPhone(phone)) {
            throw new ConflictException("An account is already registered with phone number: " + phone);
        }

        otpService.generateAndSendOtp(phone, OtpPurpose.REGISTRATION, request.getChannel(), null);

        int expiryMins = appProperties.otp() != null && appProperties.otp().expiryMinutes() > 0
                ? appProperties.otp().expiryMinutes()
                : 10;

        return InitiatePhoneResponse.builder()
                .phone(phone)
                .message("Verification OTP has been sent successfully.")
                .expiresInSeconds((long) expiryMins * 60)
                .build();
    }

    @Override
    @Transactional
    public VerifyPhoneOtpResponse verifyPhoneOtp(VerifyPhoneOtpRequest request) {
        String phone = request.getPhone().trim();
        otpService.verifyOtp(phone, request.getOtpCode().trim(), OtpPurpose.REGISTRATION);

        String token = jwtTokenProvider.generateVerificationToken(phone);

        return VerifyPhoneOtpResponse.builder()
                .phone(phone)
                .phoneVerified(true)
                .verificationToken(token)
                .message("Phone number verified successfully. Please continue to submit personal details.")
                .build();
    }

    @Override
    @Transactional
    public AuthTokenResponse registerPersonalDetails(PersonalDetailsRequest request) {
        String phone = request.getPhone().trim();
        String email = request.getEmail().trim().toLowerCase();

        if (request.getVerificationToken() != null && !request.getVerificationToken().isBlank()) {
            jwtTokenProvider.validateVerificationToken(request.getVerificationToken(), phone);
        }

        if (customerRepository.existsByPhone(phone)) {
            throw new ConflictException("Phone number already registered.");
        }
        if (customerRepository.existsByEmail(email)) {
            throw new ConflictException("Email address already registered.");
        }

        // 1. Create Identity Root
        Identity identity = Identity.builder()
                .publicId(CodeGenerationUtil.generatePublicId("id_"))
                .identityType(IdentityType.CUSTOMER)
                .status("ACTIVE")
                .build();
        Identity savedIdentity = identityRepository.save(identity);

        // Determine initial KYC Tier based on BVN/NIN presence
        boolean hasBvnOrNin = StringUtils.isNotBlank(request.getBvnOrNin());
        KycTier initialTier = hasBvnOrNin ? KycTier.TIER_2 : KycTier.TIER_1;

        // 2. Create Customer Profile
        Customer customer = Customer.builder()
                .identity(savedIdentity)
                .firstName(request.getFirstName().trim())
                .middleName(StringUtils.trimToNull(request.getMiddleName()))
                .lastName(request.getLastName().trim())
                .email(email)
                .phone(phone)
                .kycTier(initialTier)
                .build();
        Customer savedCustomer = customerRepository.save(customer);

        // 3. Create Password Credential (BCrypt)
        PasswordCredential passwordCredential = PasswordCredential.builder()
                .identity(savedIdentity)
                .password(passwordEncoder.encode(request.getPassword()))
                .failedAttempts(0)
                .build();
        passwordCredentialRepository.save(passwordCredential);

        // 4. Delegate core banking account opening and identity verification to decoupled service
        Account savedAccount = accountService.createAccount(
                savedCustomer,
                request.getDateOfBirth(),
                request.getBvnOrNin());

        log.info("New customer successfully onboarded: {} ({}) with authentic NUBAN: {}",
                savedCustomer.getFullName(), savedCustomer.getEmail(), savedAccount.getAccountNumber());

        return authHelper.issueTokensAndCreateSession(savedIdentity, null, null, null, null);
    }

    @Override
    @Transactional
    public UserProfileResponse uploadDocument(Identity identity, UploadDocumentRequest request) {
        Customer customer = customerRepository.findByIdentityId(identity.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Customer profile not found."));

        KycVerification kyc = KycVerification.builder()
                .customer(customer)
                .tierLevel(3)
                .documentType(request.getDocumentType())
                .documentUrl(request.getDocumentUrl())
                .status("APPROVED")
                .externalVerificationId("v_doc_" + CodeGenerationUtil.generateNumericString(8))
                .build();
        kycVerificationRepository.save(kyc);

        customer.setKycTier(KycTier.TIER_3);
        customerRepository.save(customer);

        // Dynamically upgrade account daily limit to Tier 3 limit
        accountService.updateDailyLimits(customer.getId(), KycTier.TIER_3);

        log.info("Customer ID {} upgraded to KYC Tier 3 via document upload. Daily limits elevated.", customer.getId());
        return authHelper.buildUserProfile(identity);
    }

    @Override
    @Transactional
    public AuthTokenResponse login(LoginRequest request) {
        var strategy = loginStrategyFactory.getStrategy(request.getLoginMethod());
        return strategy.authenticate(request);
    }

    @Override
    @Transactional
    public AuthTokenResponse verifyLoginOtp(VerifyLoginOtpRequest request) {
        String identifier = request.getIdentifier().trim();
        otpService.verifyOtp(identifier, request.getOtpCode().trim(), OtpPurpose.LOGIN_2FA);

        Identity identity = authHelper.resolveIdentity(identifier, IdentityType.CUSTOMER);
        return authHelper.issueTokensAndCreateSession(
                identity,
                request.getDeviceId(),
                request.getDeviceName(),
                null,
                null);
    }

    @Override
    @Transactional
    public AuthTokenResponse refreshToken(RefreshTokenRequest request) {
        String hash = DigestUtils.sha256Hex(request.getRefreshToken().trim());

        Session session = sessionRepository.findByRefreshTokenAndRevokedAtIsNull(hash)
                .orElseThrow(() -> new UnauthorizedException("Invalid or revoked refresh token. Please sign in again."));

        if (session.isExpired()) {
            throw new UnauthorizedException("Session has expired. Please sign in again.");
        }

        // Revoke current session
        session.setRevokedAt(Instant.now());
        sessionRepository.save(session);

        // Issue new token and session
        return authHelper.issueTokensAndCreateSession(
                session.getIdentity(),
                session.getDeviceId(),
                session.getDeviceName(),
                session.getIpAddress(),
                session.getUserAgent());
    }

    @Override
    @Transactional
    public void logout(Identity identity, String refreshToken) {
        if (StringUtils.isNotBlank(refreshToken)) {
            String hash = DigestUtils.sha256Hex(refreshToken.trim());
            sessionRepository.findByRefreshTokenAndRevokedAtIsNull(hash)
                    .ifPresent(s -> {
                        s.setRevokedAt(Instant.now());
                        sessionRepository.save(s);
                    });
        } else {
            List<Session> activeSessions = sessionRepository.findAllByIdentityIdAndRevokedAtIsNull(identity.getId());
            activeSessions.forEach(s -> s.setRevokedAt(Instant.now()));
            sessionRepository.saveAll(activeSessions);
        }
        log.info("Logged out session(s) for identity ID: {}", identity.getId());
    }

    @Override
    @Transactional(readOnly = true)
    public UserProfileResponse getCurrentUserProfile(Identity identity) {
        return authHelper.buildUserProfile(identity);
    }
}
