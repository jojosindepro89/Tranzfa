package io.tranzfa.core.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SetPinRequest {

    @NotBlank(message = "PIN is required")
    @Pattern(regexp = "^[0-9]{4}$", message = "Transaction PIN must be exactly 4 digits")
    @Schema(description = "4-digit transaction authorization PIN", example = "1234")
    private String pin;

    @NotBlank(message = "Confirmation PIN is required")
    @Pattern(regexp = "^[0-9]{4}$", message = "Confirmation PIN must be exactly 4 digits")
    @Schema(description = "Confirm 4-digit transaction authorization PIN", example = "1234")
    private String confirmPin;
}
