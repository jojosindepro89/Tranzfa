package io.tranzfa.core.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UploadDocumentRequest {

    @NotBlank(message = "Document type is required")
    @Schema(description = "Government ID type (e.g. NATIONAL_ID, PASSPORT, DRIVERS_LICENSE, VOTERS_CARD)", example = "NATIONAL_ID")
    private String documentType;

    @Schema(description = "ID Document number", example = "A12345678")
    private String documentNumber;

    @NotBlank(message = "Document image or URL is required")
    @Schema(description = "Secure document URL or Base64 data URI", example = "https://storage.tranzfa.io/kyc/doc_987654.jpg")
    private String documentUrl;
}
