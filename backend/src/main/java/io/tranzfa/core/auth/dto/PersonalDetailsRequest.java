package io.tranzfa.core.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PersonalDetailsRequest {

    @NotBlank(message = "Phone number is required")
    @Schema(description = "Phone number verified in previous step", example = "+2348012345678")
    private String phone;

    @NotBlank(message = "First name is required")
    @Size(max = 100, message = "First name cannot exceed 100 characters")
    @Schema(description = "Customer legal first name", example = "Sarah")
    private String firstName;

    @Size(max = 100, message = "Middle name cannot exceed 100 characters")
    @Schema(description = "Customer legal middle name (optional)", example = "Chinyere")
    private String middleName;

    @NotBlank(message = "Last name is required")
    @Size(max = 100, message = "Last name cannot exceed 100 characters")
    @Schema(description = "Customer legal last name", example = "Okonjo")
    private String lastName;

    @NotBlank(message = "Email address is required")
    @Email(message = "Please provide a valid email address")
    @Schema(description = "Customer primary email address", example = "sarah.okonjo@example.com")
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 8, max = 64, message = "Password must be between 8 and 64 characters")
    @Schema(description = "Account login password (Factor 1)", example = "Password123!")
    private String password;


    @Schema(description = "Date of Birth (YYYY-MM-DD)", example = "1998-05-12")
    private String dateOfBirth;

    @Schema(description = "11-digit Bank Verification Number (BVN) or National Identity Number (NIN)", example = "22233344455")
    private String bvnOrNin;

    @Schema(description = "Temporary verification token from phone OTP step")
    private String verificationToken;
}
