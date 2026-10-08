package io.tranzfa.core.auth.service;

import io.tranzfa.core.account.model.entity.Account;
import io.tranzfa.core.account.model.enums.AccountStatus;
import io.tranzfa.core.account.model.enums.AccountType;
import io.tranzfa.core.account.service.AccountService;
import io.tranzfa.core.auth.dto.AuthTokenResponse;
import io.tranzfa.core.auth.dto.InitiatePhoneRequest;
import io.tranzfa.core.auth.dto.InitiatePhoneResponse;
import io.tranzfa.core.auth.dto.PersonalDetailsRequest;
import io.tranzfa.core.auth.dto.UploadDocumentRequest;
import io.tranzfa.core.auth.dto.UserProfileResponse;
import io.tranzfa.core.auth.dto.VerifyOtpRequest;
import io.tranzfa.core.auth.dto.VerifyOtpResponse;
import io.tranzfa.core.auth.model.entity.Customer;
import io.tranzfa.core.auth.model.entity.Identity;
import io.tranzfa.core.auth.model.entity.PasswordCredential;
import io.tranzfa.core.auth.model.enums.IdentityType;
import io.tranzfa.core.auth.model.enums.KycTier;
import io.tranzfa.core.auth.model.enums.OtpPurpose;
import io.tranzfa.core.auth.repository.CustomerRepository;
import io.tranzfa.core.auth.repository.IdentityRepository;
import io.tranzfa.core.auth.repository.PasswordCredentialRepository;
import io.tranzfa.core.auth.repository.SessionRepository;
import io.tranzfa.core.auth.strategy.LoginStrategyFactory;
import io.tranzfa.core.banking.provider.exception.IdentityVerificationFailedException;
import io.tranzfa.core.common.exception.ConflictException;
import io.tranzfa.core.config.AppProperties;
import io.tranzfa.core.kyc.model.entity.KycVerification;
import io.tranzfa.core.kyc.repository.KycVerificationRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private IdentityRepository identityRepository;
    @Mock
    private CustomerRepository customerRepository;
    @Mock
    private PasswordCredentialRepository passwordCredentialRepository;
    @Mock
    private AccountService accountService;
    @Mock
    private KycVerificationRepository kycVerificationRepository;
    @Mock
    private SessionRepository sessionRepository;
    @Mock
    private OtpService otpService;
    @Mock
    private PinService pinService;
    @Mock
    private JwtTokenProvider jwtTokenProvider;
    @Mock
    private AuthHelper authHelper;
    @Mock
    private LoginStrategyFactory loginStrategyFactory;

    private PasswordEncoder passwordEncoder;
    private AuthService authService;

    @BeforeEach
    void setUp() {
        passwordEncoder = new BCryptPasswordEncoder();
        AppProperties.Otp otpProps = new AppProperties.Otp(10, true);
        AppProperties.SafeHaven shProps = new AppProperties.SafeHaven(
                "https://api.sandbox.safehavenmfb.com", "cid", "assert", "sec", "acct", "wh", true, "090286", "Safe Haven Microfinance Bank");
        AppProperties appProperties = new AppProperties(shProps, null, null, otpProps, null, null, null, null);

        authService = new io.tranzfa.core.auth.service.impl.AuthServiceImpl(
                identityRepository,
                customerRepository,
                passwordCredentialRepository,
                accountService,
                kycVerificationRepository,
                sessionRepository,
                otpService,
                pinService,
                jwtTokenProvider,
                authHelper,
                loginStrategyFactory,
                passwordEncoder,
                appProperties
        );
    }

    @Test
    @DisplayName("Should successfully initiate phone onboarding and dispatch OTP")
    void shouldInitiatePhoneOnboarding() {
        InitiatePhoneRequest request = InitiatePhoneRequest.builder()
                .phone("+2348012345678")
                .build();

        when(customerRepository.existsByPhone("+2348012345678")).thenReturn(false);

        InitiatePhoneResponse response = authService.initiatePhone(request);

        assertThat(response.getPhone()).isEqualTo("+2348012345678");
        assertThat(response.getExpiresInSeconds()).isEqualTo(600);
        verify(otpService).generateAndSendOtp(eq("+2348012345678"), eq(OtpPurpose.REGISTRATION), any(), any());
    }

    @Test
    @DisplayName("Should reject phone onboarding if phone number already registered")
    void shouldRejectDuplicatePhone() {
        InitiatePhoneRequest request = InitiatePhoneRequest.builder()
                .phone("+2348012345678")
                .build();

        when(customerRepository.existsByPhone("+2348012345678")).thenReturn(true);

        assertThatThrownBy(() -> authService.initiatePhone(request))
                .isInstanceOf(ConflictException.class)
                .hasMessageContaining("already registered");
    }

    @Test
    @DisplayName("Should register personal details, delegate account provisioning, and return tokens")
    void shouldRegisterPersonalDetailsSuccessfully() {
        PersonalDetailsRequest request = PersonalDetailsRequest.builder()
                .phone("+2348012345678")
                .firstName("Sarah")
                .middleName("Chinyere")
                .lastName("Okonjo")
                .email("sarah.okonjo@example.com")
                .password("Password123!")
                .dateOfBirth("1998-05-12")
                .bvnOrNin("22233344455")
                .build();

        when(customerRepository.existsByPhone("+2348012345678")).thenReturn(false);
        when(customerRepository.existsByEmail("sarah.okonjo@example.com")).thenReturn(false);

        Identity savedIdentity = Identity.builder()
                .publicId("id_cust_1")
                .identityType(IdentityType.CUSTOMER)
                .status("ACTIVE")
                .build();
        savedIdentity.setId(1L);
        when(identityRepository.save(any(Identity.class))).thenReturn(savedIdentity);

        Customer savedCustomer = Customer.builder()
                .identity(savedIdentity)
                .firstName("Sarah")
                .middleName("Chinyere")
                .lastName("Okonjo")
                .email("sarah.okonjo@example.com")
                .phone("+2348012345678")
                .kycTier(KycTier.TIER_2)
                .build();
        savedCustomer.setId(10L);
        when(customerRepository.save(any(Customer.class))).thenReturn(savedCustomer);

        Account savedAccount = Account.builder()
                .customer(savedCustomer)
                .accountNumber("2001928374")
                .accountName("Sarah Chinyere Okonjo")
                .currency("NGN")
                .accountType(AccountType.SAVINGS)
                .status(AccountStatus.ACTIVE)
                .availableBalance(0L)
                .ledgerBalance(0L)
                .dailyLimit(20_000_000L)
                .build();
        savedAccount.setId(50L);
        when(accountService.createAccount(eq(savedCustomer), eq("1998-05-12"), eq("22233344455")))
                .thenReturn(savedAccount);

        AuthTokenResponse mockResponse = AuthTokenResponse.builder()
                .accessToken("access-token-abc")
                .refreshToken("refresh-token-xyz")
                .user(UserProfileResponse.builder()
                        .fullName("Sarah Chinyere Okonjo")
                        .email("sarah.okonjo@example.com")
                        .primaryAccountNumber("2001928374")
                        .primaryBankCode("090286")
                        .primaryBankName("Safe Haven Microfinance Bank")
                        .isPinSet(false)
                        .build())
                .build();
        when(authHelper.issueTokensAndCreateSession(eq(savedIdentity), any(), any(), any(), any()))
                .thenReturn(mockResponse);

        AuthTokenResponse response = authService.registerPersonalDetails(request);

        assertThat(response.getAccessToken()).isEqualTo("access-token-abc");
        assertThat(response.getUser().getFullName()).isEqualTo("Sarah Chinyere Okonjo");
        assertThat(response.getUser().isPinSet()).isFalse();

        verify(passwordCredentialRepository).save(any(PasswordCredential.class));
        verify(accountService).createAccount(eq(savedCustomer), eq("1998-05-12"), eq("22233344455"));
    }

    @Test
    @DisplayName("Should halt onboarding immediately when banking rail provider rejects identity verification")
    void shouldHaltOnboardingWhenIdentityVerificationFails() {
        PersonalDetailsRequest request = PersonalDetailsRequest.builder()
                .phone("+2348012345678")
                .firstName("Sarah")
                .lastName("Okonjo")
                .email("sarah.okonjo@example.com")
                .password("Password123!")
                .dateOfBirth("1998-05-12")
                .bvnOrNin("00000000000")
                .build();

        when(customerRepository.existsByPhone("+2348012345678")).thenReturn(false);
        when(customerRepository.existsByEmail("sarah.okonjo@example.com")).thenReturn(false);

        Identity savedIdentity = Identity.builder()
                .publicId("id_cust_1")
                .identityType(IdentityType.CUSTOMER)
                .status("ACTIVE")
                .build();
        savedIdentity.setId(1L);
        when(identityRepository.save(any(Identity.class))).thenReturn(savedIdentity);

        Customer savedCustomer = Customer.builder()
                .identity(savedIdentity)
                .firstName("Sarah")
                .lastName("Okonjo")
                .email("sarah.okonjo@example.com")
                .phone("+2348012345678")
                .kycTier(KycTier.TIER_2)
                .build();
        savedCustomer.setId(10L);
        when(customerRepository.save(any(Customer.class))).thenReturn(savedCustomer);

        when(accountService.createAccount(eq(savedCustomer), eq("1998-05-12"), eq("00000000000")))
                .thenThrow(new IdentityVerificationFailedException("Identity verification failed: BVN details do not match provider records."));

        assertThatThrownBy(() -> authService.registerPersonalDetails(request))
                .isInstanceOf(IdentityVerificationFailedException.class)
                .hasMessageContaining("BVN details do not match");

        // Verify tokens are never issued
        verify(authHelper, never()).issueTokensAndCreateSession(any(), any(), any(), any(), any());
    }

    @Test
    @DisplayName("Should verify OTP via unified endpoint for REGISTRATION purpose")
    void shouldVerifyOtpUnifiedForRegistration() {
        VerifyOtpRequest request = VerifyOtpRequest.builder()
                .identifier("+2348012345678")
                .otpCode("654321")
                .purpose(OtpPurpose.REGISTRATION)
                .build();

        when(otpService.verifyOtp("+2348012345678", "654321", OtpPurpose.REGISTRATION)).thenReturn(true);
        when(jwtTokenProvider.generateVerificationToken("+2348012345678")).thenReturn("mock-reg-token");

        VerifyOtpResponse response = authService.verifyOtp(request);

        assertThat(response.isVerified()).isTrue();
        assertThat(response.getPurpose()).isEqualTo(OtpPurpose.REGISTRATION);
        assertThat(response.getVerificationToken()).isEqualTo("mock-reg-token");
    }

    @Test
    @DisplayName("Should verify OTP via unified endpoint for LOGIN_2FA and return session tokens")
    void shouldVerifyOtpUnifiedForLogin2FA() {
        VerifyOtpRequest request = VerifyOtpRequest.builder()
                .identifier("+2348012345678")
                .otpCode("987654")
                .purpose(OtpPurpose.LOGIN_2FA)
                .deviceId("dev-iphone-15")
                .deviceName("iPhone 15 Pro")
                .build();

        Identity sampleIdentity = Identity.builder()
                .publicId("id_cust_123")
                .identityType(IdentityType.CUSTOMER)
                .build();

        AuthTokenResponse mockTokens = AuthTokenResponse.builder()
                .accessToken("mock-access-token")
                .refreshToken("mock-refresh-token")
                .build();

        when(otpService.verifyOtp("+2348012345678", "987654", OtpPurpose.LOGIN_2FA)).thenReturn(true);
        when(authHelper.resolveIdentity("+2348012345678", IdentityType.CUSTOMER)).thenReturn(sampleIdentity);
        when(authHelper.issueTokensAndCreateSession(sampleIdentity, "dev-iphone-15", "iPhone 15 Pro", null, null))
                .thenReturn(mockTokens);

        VerifyOtpResponse response = authService.verifyOtp(request);

        assertThat(response.isVerified()).isTrue();
        assertThat(response.getPurpose()).isEqualTo(OtpPurpose.LOGIN_2FA);
        assertThat(response.getAuthTokens()).isNotNull();
        assertThat(response.getAuthTokens().getAccessToken()).isEqualTo("mock-access-token");
    }

    @Test
    @DisplayName("Should record uploaded document as PENDING_REVIEW without elevating tier prematurely")
    void shouldUploadDocumentAndSetPendingReviewWithoutPrematureTierElevation() {
        Identity identity = Identity.builder().publicId("id_cust_10").identityType(IdentityType.CUSTOMER).build();
        identity.setId(10L);

        Customer customer = Customer.builder()
                .identity(identity)
                .firstName("Sarah")
                .lastName("Okonjo")
                .kycTier(KycTier.TIER_2)
                .build();
        customer.setId(10L);

        UploadDocumentRequest request = UploadDocumentRequest.builder()
                .documentType("PASSPORT")
                .documentUrl("https://storage.tranzfa.io/kyc/passport_10.jpg")
                .build();

        when(customerRepository.findByIdentityId(10L)).thenReturn(java.util.Optional.of(customer));
        when(authHelper.buildUserProfile(identity)).thenReturn(UserProfileResponse.builder()
                .customerId(10L)
                .kycTier(KycTier.TIER_2)
                .build());

        UserProfileResponse response = authService.uploadDocument(identity, request);

        // Verify tier remains TIER_2 (NOT TIER_3)
        assertThat(response.getKycTier()).isEqualTo(KycTier.TIER_2);

        // Verify KycVerification was saved with status PENDING_REVIEW
        org.mockito.ArgumentCaptor<KycVerification> captor = org.mockito.ArgumentCaptor.forClass(KycVerification.class);
        verify(kycVerificationRepository).save(captor.capture());
        KycVerification savedKyc = captor.getValue();
        assertThat(savedKyc.getStatus()).isEqualTo("PENDING_REVIEW");
        assertThat(savedKyc.getDocumentType()).isEqualTo("PASSPORT");

        // Verify accountService.updateDailyLimits was NEVER called prematurely
        verify(accountService, never()).updateDailyLimits(any(), any());
    }
}
