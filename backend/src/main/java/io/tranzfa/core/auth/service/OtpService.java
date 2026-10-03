package io.tranzfa.core.auth.service;

import io.tranzfa.core.auth.model.entity.Identity;
import io.tranzfa.core.auth.model.entity.OtpToken;
import io.tranzfa.core.auth.model.enums.OtpChannel;
import io.tranzfa.core.auth.model.enums.OtpPurpose;

public interface OtpService {

    OtpToken generateAndSendOtp(String recipient, OtpPurpose purpose, OtpChannel channel, Identity identity);

    boolean verifyOtp(String recipient, String otpCode, OtpPurpose purpose);
}
