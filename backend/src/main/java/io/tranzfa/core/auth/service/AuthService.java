package io.tranzfa.core.auth.service;

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
import io.tranzfa.core.auth.model.entity.Identity;

public interface AuthService {

    InitiatePhoneResponse initiatePhone(InitiatePhoneRequest request);

    VerifyPhoneOtpResponse verifyPhoneOtp(VerifyPhoneOtpRequest request);

    AuthTokenResponse registerPersonalDetails(PersonalDetailsRequest request);

    UserProfileResponse uploadDocument(Identity identity, UploadDocumentRequest request);

    AuthTokenResponse login(LoginRequest request);

    AuthTokenResponse verifyLoginOtp(VerifyLoginOtpRequest request);

    AuthTokenResponse refreshToken(RefreshTokenRequest request);

    void logout(Identity identity, String refreshToken);

    UserProfileResponse getCurrentUserProfile(Identity identity);
}
