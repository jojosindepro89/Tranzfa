package io.tranzfa.core.banking.provider.adapter;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.tranzfa.core.banking.provider.CoreBankingProvider;
import io.tranzfa.core.banking.provider.CreateAccountRequest;
import io.tranzfa.core.banking.provider.CreateAccountResponse;
import io.tranzfa.core.banking.provider.exception.BankingProviderException;
import io.tranzfa.core.banking.provider.exception.IdentityVerificationFailedException;
import io.tranzfa.core.config.AppProperties;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.util.LinkedHashMap;
import java.util.Map;

@Slf4j
@Component("safeHavenBankingProvider")
@RequiredArgsConstructor
public class SafeHavenBankingProvider implements CoreBankingProvider {

    public static final String PROVIDER_NAME = "SAFEHAVEN";
    public static final String DEFAULT_BANK_CODE = "090286";
    public static final String DEFAULT_BANK_NAME = "Safe Haven Microfinance Bank";

    private final AppProperties appProperties;
    private final RestClient safeHavenRestClient;
    private final MockBankingProvider mockBankingProvider;
    private final ObjectMapper objectMapper;

    @Override
    public String getProviderName() {
        return PROVIDER_NAME;
    }

    @Override
    public CreateAccountResponse createAccount(CreateAccountRequest request) {
        boolean isMock = appProperties.safeHaven() == null || appProperties.safeHaven().mockMode();

        if (isMock) {
            log.info("[SAFEHAVEN-PROVIDER] Mock mode active. Delegating to simulated SafeHaven provider.");
            CreateAccountResponse mockResult = mockBankingProvider.createAccount(request);
            return CreateAccountResponse.builder()
                    .accountNumber(mockResult.accountNumber())
                    .bankCode(getBankCode())
                    .bankName(getBankName())
                    .externalAccountId(mockResult.externalAccountId())
                    .externalCustomerId(mockResult.externalCustomerId())
                    .identityId(mockResult.identityId())
                    .tierLevel(mockResult.tierLevel())
                    .metadataJson(mockResult.metadataJson())
                    .build();
        }

        log.info("[SAFEHAVEN-PROVIDER] Initiating live SafeHaven API calls for: {} ({})",
                request.getFullName(), request.email());

        // Step 1: Encapsulated Identity Verification (POST /identity/v2)
        String identityId = null;
        int tierLevel = 1;

        if (StringUtils.isNotBlank(request.bvnOrNin())) {
            identityId = verifyIdentityWithSafeHaven(request);
            tierLevel = 2;
        }

        // Step 2: Virtual Sub-Account Allocation (POST /accounts/v2/sub-account)
        return createSubAccountWithSafeHaven(request, identityId, tierLevel);
    }

    private String verifyIdentityWithSafeHaven(CreateAccountRequest request) {
        log.info("[SAFEHAVEN-PROVIDER] Calling SafeHaven POST /identity/v2 for BVN/NIN verification");

        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("type", "BVN");
        payload.put("number", request.bvnOrNin().trim());
        payload.put("firstName", request.firstName());
        payload.put("lastName", request.lastName());
        if (StringUtils.isNotBlank(request.dateOfBirth())) {
            payload.put("dateOfBirth", request.dateOfBirth());
        }

        try {
            String responseStr = safeHavenRestClient.post()
                    .uri("/identity/v2")
                    .contentType(MediaType.APPLICATION_JSON)
                    .header("ClientID", appProperties.safeHaven().clientId())
                    .body(payload)
                    .retrieve()
                    .onStatus(HttpStatusCode::is4xxClientError, (req, resp) -> {
                        String body = new String(resp.getBody().readAllBytes());
                        log.warn("[SAFEHAVEN-PROVIDER] SafeHaven identity verification 4xx error: {}", body);
                        throw new IdentityVerificationFailedException(
                                "Identity verification failed: BVN details do not match provider records.");
                    })
                    .onStatus(HttpStatusCode::is5xxServerError, (req, resp) -> {
                        String body = new String(resp.getBody().readAllBytes());
                        log.error("[SAFEHAVEN-PROVIDER] SafeHaven identity service 5xx failure: {}", body);
                        throw new BankingProviderException("SafeHaven identity verification service temporarily unavailable.");
                    })
                    .body(String.class);

            JsonNode root = objectMapper.readTree(responseStr);
            JsonNode dataNode = root.has("data") ? root.get("data") : root;

            if (dataNode.has("_id")) {
                return dataNode.get("_id").asText();
            } else if (dataNode.has("id")) {
                return dataNode.get("id").asText();
            } else if (dataNode.has("identityId")) {
                return dataNode.get("identityId").asText();
            }

            log.warn("[SAFEHAVEN-PROVIDER] Identity response missing ID: {}", responseStr);
            throw new IdentityVerificationFailedException(
                    "Identity verification could not be validated by banking provider.");
        } catch (IdentityVerificationFailedException e) {
            throw e;
        } catch (Exception e) {
            log.error("[SAFEHAVEN-PROVIDER] Error calling SafeHaven identity API", e);
            throw new BankingProviderException("Failed to verify customer identity with SafeHaven: " + e.getMessage(), e);
        }
    }

    private CreateAccountResponse createSubAccountWithSafeHaven(
            CreateAccountRequest request,
            String identityId,
            int tierLevel) {

        log.info("[SAFEHAVEN-PROVIDER] Calling SafeHaven POST /accounts/v2/sub-account for NUBAN allocation");

        Map<String, Object> payload = new LinkedHashMap<>();
        if (identityId != null) {
            payload.put("identityId", identityId);
        }
        payload.put("phoneNumber", request.phone());
        payload.put("emailAddress", request.email());
        payload.put("currencyCode", request.currency() != null ? request.currency() : "NGN");
        payload.put("autoSweep", false);

        try {
            String responseStr = safeHavenRestClient.post()
                    .uri("/accounts/v2/sub-account")
                    .contentType(MediaType.APPLICATION_JSON)
                    .header("ClientID", appProperties.safeHaven().clientId())
                    .body(payload)
                    .retrieve()
                    .onStatus(HttpStatusCode::isError, (req, resp) -> {
                        String body = new String(resp.getBody().readAllBytes());
                        log.error("[SAFEHAVEN-PROVIDER] SafeHaven sub-account allocation error: {}", body);
                        throw new BankingProviderException("Failed to allocate account from SafeHaven: " + body);
                    })
                    .body(String.class);

            JsonNode root = objectMapper.readTree(responseStr);
            JsonNode dataNode = root.has("data") ? root.get("data") : root;

            String allocatedNuban = dataNode.has("accountNumber") ? dataNode.get("accountNumber").asText() : null;
            String externalAcctId = dataNode.has("_id") ? dataNode.get("_id").asText() : null;
            String externalCustId = dataNode.has("customerId") ? dataNode.get("customerId").asText() : null;

            if (allocatedNuban == null || allocatedNuban.isBlank()) {
                throw new BankingProviderException("SafeHaven returned empty NUBAN account number.");
            }

            return CreateAccountResponse.builder()
                    .accountNumber(allocatedNuban)
                    .bankCode(getBankCode())
                    .bankName(getBankName())
                    .externalAccountId(externalAcctId)
                    .externalCustomerId(externalCustId)
                    .identityId(identityId)
                    .tierLevel(tierLevel)
                    .metadataJson(responseStr)
                    .build();
        } catch (BankingProviderException e) {
            throw e;
        } catch (Exception e) {
            log.error("[SAFEHAVEN-PROVIDER] Exception during SafeHaven sub-account allocation", e);
            throw new BankingProviderException("Error communicating with SafeHaven banking provider: " + e.getMessage(), e);
        }
    }

    private String getBankCode() {
        return (appProperties.safeHaven() != null && appProperties.safeHaven().defaultBankCode() != null)
                ? appProperties.safeHaven().defaultBankCode()
                : DEFAULT_BANK_CODE;
    }

    private String getBankName() {
        return (appProperties.safeHaven() != null && appProperties.safeHaven().defaultBankName() != null)
                ? appProperties.safeHaven().defaultBankName()
                : DEFAULT_BANK_NAME;
    }
}
