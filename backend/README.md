# Tranzfa Core Banking Service

Tranzfa Core Banking is a high-throughput, secure financial technology backend service engineered for retail banking, identity management, and Banking-as-a-Service (BaaS) infrastructure. It is built with Java 21 and Spring Boot, implementing Nigerian FinTech compliance, multi-factor authentication (3FA), and pluggable provider adapters.

---

## Architecture Overview

The system is organized into modular domain components:

- **Authentication & Identity (`io.tranzfa.core.auth`)**: 3-Factor Authentication (3FA) framework combining Password, 4-digit Transaction PIN, SMS/TOTP OTP, and hardware-backed FIDO2 WebAuthn biometric passkeys (Apple Secure Enclave and Android Keystore).
- **Core Banking & BaaS (`io.tranzfa.core.banking`)**: Pluggable BaaS integration with SafeHaven Microfinance Bank supporting NUBAN generation, BVN/NIN identity verification, and multi-currency sub-accounts.
- **Account & Ledger Management (`io.tranzfa.core.account`)**: Retail savings accounts, balance tracking, and tiered transaction limit enforcement.
- **KYC & Compliance (`io.tranzfa.core.kyc`)**: Tiered Know Your Customer pipeline with automated BVN validation and compliance review workflows for Tier 3 document verification.
- **Common & Infrastructure (`io.tranzfa.core.common`, `io.tranzfa.core.config`)**: Standardized API responses, global exception mapping, Liquibase migrations, and security filters.

---

## Key Capabilities and Regulatory Controls

### 1. Central Bank of Nigeria (CBN) Compliance
- **Single Active Device Policy**: Each customer identity is strictly bound to a single active hardware device (`current_device_id`). Attempting to authenticate from an unrecognized device triggers an immediate step-up challenge requiring OTP verification.
- **Device Switch Cooldown**: Upon switching devices, daily transfer limits are temporarily capped at NGN 20,000 for a 24-hour security cooldown window to prevent account takeovers.

### 2. Tiered KYC Limits
- **Tier 1**: Phone verification. Daily transfer limit: NGN 50,000. Maximum cumulative balance: NGN 300,000.
- **Tier 2**: Verified Bank Verification Number (BVN) / National Identity Number (NIN). Daily transfer limit: NGN 200,000. Maximum cumulative balance: NGN 500,000.
- **Tier 3**: Verified Government ID document (National ID, International Passport, Voter's Card, or Driver's License) + Proof of Address. Daily transfer limit: NGN 10,000,000. Unlimited balance.

### 3. Anti-Brute Force and Lockout Protection
- **Password Credential**: 5 consecutive failed attempts trigger a 15-minute account lockout.
- **Transaction PIN (Factor 3)**: 3 consecutive failed attempts trigger an independent 15-minute PIN lockout, preventing unauthorized funds movement.

---

## Pluggable Provider Architecture

The application uses Spring conditional bean loading (`@ConditionalOnProperty`) to decouple domain logic from third-party vendor integrations. Domain services never contain inline provider checks.

| Subsystem | Configuration Key | Mock Provider (`true`) | Live Provider (`false`) |
| :--- | :--- | :--- | :--- |
| **OTP Service** | `app.otp.mock-mode` | `MockOtpServiceImpl` (emits and accepts static code `123456`) | `OtpServiceImpl` (generates random TOTP, dispatches SMS via gateway) |
| **BaaS Banking** | `app.safe-haven.mock-mode` | `MockBankingProvider` (generates valid test NUBANs, validates BVN format) | `SafeHavenBankingProvider` (calls SafeHaven MFB REST API) |
| **FIDO2 Passkeys** | `app.passkey.mock-mode` | `MockWebAuthnProvider` (simulates attestation & assertion signatures) | `YubicoWebAuthnProvider` (validates CBOR, COSE keys, and sign counters) |

---

## Technology Stack

- **Runtime**: Java 21 (OpenJDK / Eclipse Temurin)
- **Framework**: Spring Boot 3.3+
- **Database**: PostgreSQL 16
- **Schema Management**: Liquibase
- **Security**: Spring Security 6, JJWT (HMAC-SHA256), BCrypt
- **WebAuthn**: Yubico java-webauthn-server
- **Documentation**: SpringDoc OpenAPI 2.5 / Swagger UI
- **Build System**: Maven Wrapper (`./mvnw`)

---

## Prerequisites and Environment Setup

### Prerequisites
- JDK 21 installed and configured on PATH
- Docker and Docker Compose (for PostgreSQL)
- Maven 3.9+ (or use included `./mvnw`)

### 1. Database Setup
Start the local PostgreSQL container:

```bash
docker run --name tranzfa-db -e POSTGRES_DB=tranzfa_local -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres:16-alpine
```

### 2. Configuration Profiles
Configuration settings reside in:
- `src/main/resources/application.properties` (base production defaults)
- `src/main/resources/application-local.properties` (local development profile with mock modes enabled)

To select the local profile, set:
```properties
spring.profiles.active=local
```

### 3. Build and Test
Run the full test suite (56 tests covering domain logic, auth strategies, and providers):

```bash
./mvnw clean test
```

### 4. Run the Application
Start the Spring Boot service:

```bash
./mvnw spring-boot:run
```

The service will start on port `8080`.

- Swagger UI: `http://localhost:8080/swagger-ui.html`
- OpenAPI Specification: `http://localhost:8080/v3/api-docs`
- Health Endpoint: `http://localhost:8080/actuator/health`

---

## API Reference and Authentication Flows

### 1. Customer Onboarding Flow
1. **Initiate Phone Onboarding**: `POST /api/v1/auth/initiate-phone`
   - Request: `{"phone": "+2348012345678"}`
   - Action: Validates uniqueness and sends a 6-digit OTP.
2. **Verify Phone OTP**: `POST /api/v1/auth/otp/verify`
   - Request: `{"identifier": "+2348012345678", "otpCode": "123456", "purpose": "REGISTRATION"}`
   - Action: Validates code and issues a signed JWT `verificationToken`.
3. **Register Personal Details**: `POST /api/v1/auth/personal-details`
   - Request includes `phone`, `verificationToken`, names, BVN/NIN, date of birth, address, and device metadata.
   - Action: Creates customer identity, provisions a 10-digit NUBAN savings account, binds the device, and issues `accessToken` and `refreshToken`.
4. **Upload KYC Document**: `POST /api/v1/auth/upload-document` (Bearer Auth)
   - Request includes document type, ID number, and image URLs.
   - Action: Submits document for Tier 3 compliance review.

### 2. Dedicated Login Endpoints

Tranzfa supports 4 distinct login methods through `POST /api/v1/auth/login`:

#### Method A: Password Login
```json
{
  "identifier": "+2348012345678",
  "loginMethod": "PASSWORD",
  "password": "Password123!",
  "userType": "CUSTOMER",
  "deviceId": "dev-ios-a918f-2831",
  "deviceName": "iPhone 15 Pro"
}
```

#### Method B: 4-Digit PIN Login (Factor 3)
```json
{
  "identifier": "+2348012345678",
  "loginMethod": "PIN",
  "pin": "1234",
  "userType": "CUSTOMER",
  "deviceId": "dev-ios-a918f-2831",
  "deviceName": "iPhone 15 Pro"
}
```

#### Method C: Biometric Passkey Login (FIDO2)
- Step 1: `POST /api/v1/auth/passkey/login-challenge?identifier=+2348012345678` returns a cryptographic nonce.
- Step 2: Device authenticates via FaceID/TouchID and submits the signed assertion:
```json
{
  "identifier": "+2348012345678",
  "loginMethod": "PASSKEY",
  "credentialId": "cred_ios_f81729",
  "challenge": "challenge_nonce_from_step_1",
  "signature": "authenticator_signature",
  "signCount": 1,
  "userType": "CUSTOMER",
  "deviceId": "dev-ios-a918f-2831",
  "deviceName": "iPhone 15 Pro"
}
```

#### Method D: OTP Login
- Step 1: `POST /api/v1/auth/login` with `loginMethod: "OTP"`. Returns `requiresOtp: true` and a `challengeToken`.
- Step 2: `POST /api/v1/auth/otp/verify` with `purpose: "LOGIN_2FA"` and `otpCode: "123456"`. Issues `accessToken` and `refreshToken`.

### 3. Transaction PIN Management
- `POST /api/v1/auth/pin/set`: Sets the 4-digit PIN (requires `BearerAuth`).
- `POST /api/v1/auth/pin/verify`: Verifies the 4-digit PIN (requires `BearerAuth`).

### 4. FIDO2 Biometric Hardware Key Management
- `POST /api/v1/auth/passkey/register-challenge`: Generates challenge for WebAuthn credential creation.
- `POST /api/v1/auth/passkey/register`: Stores public key and credential ID from hardware keystore.
- `GET /api/v1/auth/passkey/devices`: Lists registered biometric authenticators.
- `DELETE /api/v1/auth/passkey/{credentialId}`: Revokes an authenticator.

### 5. Session & Token Management
- `GET /api/v1/auth/me`: Retrieves authenticated customer profile and primary account details.
- `POST /api/v1/auth/refresh-token`: Rotates access and refresh tokens.
- `POST /api/v1/auth/logout`: Revokes active refresh token session.

### 6. Back-Office Compliance Operations
- `POST /api/v1/compliance/kyc/{verificationId}/review`: Approves or rejects submitted KYC documents, upgrading customer to Tier 3 on approval.

---

## Postman Collection

A complete Postman collection is included in the repository at:

```
backend/postman/Tranzfa_Core_Banking_Auth.postman_collection.json
```

### Import Instructions
1. Open Postman.
2. Click **Import** in the upper left corner.
3. Select `backend/postman/Tranzfa_Core_Banking_Auth.postman_collection.json`.
4. The collection includes pre-configured collection variables (`baseUrl`, `testPhone`, `testPassword`, `testPin`, `deviceId`, etc.).
5. Test scripts automatically extract and chain tokens across requests (`verificationToken`, `accessToken`, `refreshToken`, `passkeyChallenge`), enabling seamless end-to-end execution without manual copy-pasting.

---

## Exception Handling and HTTP Status Codes

The application uses a centralized exception resolver (`GlobalExceptionHandler`) to ensure all errors return structured JSON envelopes with standard HTTP status codes:

- **400 Bad Request**: Input validation failures, missing parameters, malformed JSON bodies.
- **401 Unauthorized**: Invalid credentials, incorrect PIN, expired or mismatched OTP, revoked tokens.
- **403 Forbidden**: Access denied, insufficient roles or permissions.
- **404 Not Found**: Customer, identity, or account records not found.
- **405 Method Not Allowed**: Unsupported HTTP methods.
- **409 Conflict**: Duplicate phone, email, or database constraint violations.
- **502 Bad Gateway**: Third-party provider API failures (SafeHaven MFB, SMS aggregators).
- **500 Internal Server Error**: Unexpected application errors.

Standard error response envelope:
```json
{
  "status": "error",
  "message": "Detailed description of error condition",
  "data": null,
  "errors": {
    "fieldName": "Validation constraint message"
  },
  "timestamp": "2026-10-08T12:00:00Z"
}
```

---

## License

Proprietary and confidential. Copyright (c) 2026 RD Group / Tranzfa. All rights reserved.
