# 🚀 Tranzfa Digital Bank - Vercel API Deployment Guide

This directory contains the production-ready Node.js Express serverless backend for **Tranzfa Digital Bank**, engineered for 1-click deployment to **Vercel**.

---

## ⚡ Deployment to Vercel (2 Minutes)

### Option 1: Via Vercel CLI
1. Open terminal inside the `backend` directory:
   ```bash
   cd backend
   ```
2. Run Vercel deployment:
   ```bash
   npx vercel
   ```
3. Follow the prompts to deploy. Your live API endpoint will be generated (e.g. `https://tranzfa-bank-api.vercel.app`).

---

### Option 2: Via GitHub Repository
1. Push this repository to GitHub.
2. Go to your [Vercel Dashboard](https://vercel.com/dashboard) and click **"Add New Project"**.
3. Import your repository and set Root Directory to `backend`.
4. Click **Deploy**. Vercel will automatically build and expose the REST endpoints.

---

## 🔐 Multi-Factor Security (2FA / 3FA) Endpoints

| Endpoint | Method | Description |
| :--- | :--- | :--- |
| `/api/auth/login` | `POST` | **Factor 1**: Email & Password validation. Generates 6-digit OTP code. |
| `/api/auth/verify-otp` | `POST` | **Factor 2**: 6-digit OTP code verification. Issues JWT access token. |
| `/api/auth/verify-pin` | `POST` | **Factor 3**: 4-digit Transaction Security PIN verification. |
| `/api/transactions/transfer` | `POST` | Real-time bank transfer with 3FA PIN check. |
| `/api/bills/pay` | `POST` | Electricity, Data, Airtime VTU bill payment network. |
| `/api/health` | `GET` | API status and server health. |

---

## 📱 Connecting Flutter Client to Vercel

In `lib/services/api_service.dart`, update the `baseUrl`:
```dart
static const String baseUrl = "https://your-vercel-app.vercel.app/api";
```
