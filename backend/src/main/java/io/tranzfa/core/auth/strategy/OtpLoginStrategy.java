package io.tranzfa.core.auth.strategy;

import io.tranzfa.core.auth.dto.AuthTokenResponse;
import io.tranzfa.core.auth.dto.LoginRequest;
import io.tranzfa.core.auth.dto.UserProfileResponse;
import io.tranzfa.core.auth.model.entity.Identity;
import io.tranzfa.core.auth.model.enums.LoginMethod;
import io.tranzfa.core.auth.model.enums.OtpChannel;
import io.tranzfa.core.auth.model.enums.OtpPurpose;
import io.tranzfa.core.auth.service.AuthHelper;
import io.tranzfa.core.auth.service.JwtTokenProvider;
import io.tranzfa.core.auth.service.OtpService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Component
@RequiredArgsConstructor
public class OtpLoginStrategy implements LoginStrategy {

    private final AuthHelper authHelper;
    private final OtpService otpService;
    private final JwtTokenProvider jwtTokenProvider;

    @Override
    public LoginMethod getSupportedMethod() {
        return LoginMethod.OTP;
    }

    @Override
    @Transactional
    public AuthTokenResponse authenticate(LoginRequest request) {
        Identity identity = authHelper.resolveIdentity(request.getIdentifier(), request.getUserType());
        UserProfileResponse profile = authHelper.buildUserProfile(identity);

        String recipient = profile.getPhone() != null ? profile.getPhone() : profile.getEmail();
        otpService.generateAndSendOtp(recipient, OtpPurpose.LOGIN_2FA, OtpChannel.SMS, identity);

        String masked = maskRecipient(recipient);
        String challengeToken = jwtTokenProvider.generateVerificationToken(recipient);

        return AuthTokenResponse.builder()
                .requiresOtp(true)
                .otpRecipientMasked(masked)
                .challengeToken(challengeToken)
                .tokenType("Bearer")
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
