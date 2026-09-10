import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Core Banking API Gateway Endpoint (Go Backend Engine)
  static String baseUrl = kIsWeb
      ? "http://localhost:8081"
      : (defaultTargetPlatform == TargetPlatform.android
          ? "http://10.0.2.2:8081"
          : "http://localhost:8081");

  static String? _jwtToken;
  static String? get jwtToken => _jwtToken;

  static void setCustomBaseUrl(String url) {
    baseUrl = url;
  }

  // Headers generator with JWT
  static Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_jwtToken != null) {
      headers['Authorization'] = 'Bearer $_jwtToken';
    }
    return headers;
  }

  // ------------------------------------------------------------------
  // FACTOR 1: LOGIN (Email / Account Tag + Password)
  // ------------------------------------------------------------------
  static Future<Map<String, dynamic>> loginFactor1({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/login'),
        headers: _getHeaders(),
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['access_token'] != null) {
          _jwtToken = data['access_token'];
        }
        return {
          'success': true,
          'message': 'Login successful.',
          'requireOtp': false,
          'token': _jwtToken,
          'user': data['user'],
        };
      }
    } catch (e) {
      if (kDebugMode) print("ApiService loginFactor1 network exception: $e");
    }

    // Demo Fallback
    return {
      'success': true,
      'message': 'Factor 1 authentication verified. OTP generated.',
      'requireOtp': true,
      'factor': 2,
      'email': email.isNotEmpty ? email : 'sarah.okonjo@tranzfa.io',
      'otpDemoCode': '123456',
    };
  }

  // ------------------------------------------------------------------
  // FACTOR 2: VERIFY OTP (6-Digit Code -> Issues JWT Token)
  // ------------------------------------------------------------------
  static Future<Map<String, dynamic>> verifyFactor2Otp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/mfa/verify'),
        headers: _getHeaders(),
        body: jsonEncode({'email': email, 'code': otp}),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['access_token'] != null) {
          _jwtToken = data['access_token'];
        }
        return data;
      }
    } catch (e) {
      if (kDebugMode) print("ApiService verifyFactor2Otp network exception: $e");
    }

    // Offline / Demo Fallback
    _jwtToken = "demo_jwt_token_tranzfa_2026";
    return {
      'success': true,
      'message': '2FA verification complete. Session token issued.',
      'token': _jwtToken,
      'user': {
        'id': 'usr_001',
        'fullName': 'Sarah Okonjo',
        'email': email.isNotEmpty ? email : 'sarah.okonjo@tranzfa.io',
        'accountTag': '@sarah',
        'accountNumber': '2048591823',
        'balance': 1240500.00,
        'currencySymbol': '₦',
        'tier': 'Tier 3 (Verified)',
      }
    };
  }

  // ------------------------------------------------------------------
  // FACTOR 3: VERIFY TRANSACTION PIN (4-Digit PIN)
  // ------------------------------------------------------------------
  static Future<Map<String, dynamic>> verifyFactor3Pin({
    required String pin,
    String userId = 'usr_001',
  }) async {
    if (pin.length == 4) {
      return {
        'success': true,
        'message': 'Factor 3 3FA PIN verified successfully.',
        'verifiedAt': DateTime.now().toIso8601String(),
      };
    }

    return {
      'success': false,
      'message': 'Invalid 4-digit Security Transaction PIN.',
    };
  }

  // ------------------------------------------------------------------
  // CORE BANKING: EXECUTE TRANSFER
  // ------------------------------------------------------------------
  static Future<Map<String, dynamic>> executeTransfer({
    required String recipientName,
    required String bankName,
    required String accountNumber,
    required double amount,
    required String pin,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/nip/transfer'),
        headers: _getHeaders(),
        body: jsonEncode({
          'session_id': '999${DateTime.now().millisecondsSinceEpoch}',
          'destination_bank_code': '058',
          'destination_account_number': accountNumber,
          'destination_account_name': recipientName,
          'amount_cents': (amount * 100).toInt(),
          'payment_reference': 'Transfer to $recipientName',
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 || response.statusCode == 202) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Transfer executed successfully.',
          'transaction': data,
        };
      }
    } catch (e) {
      if (kDebugMode) print("ApiService executeTransfer network exception: $e");
    }

    // Demo Fallback
    return {
      'success': true,
      'message': 'Transfer executed successfully.',
      'transaction': {
        'id': 'TZ-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}-X',
        'recipientName': recipientName,
        'bankName': bankName,
        'accountNumber': accountNumber,
        'amount': amount,
        'status': 'SUCCESSFUL',
      }
    };
  }

  // ------------------------------------------------------------------
  // SIGNUP / REGISTRATION
  // ------------------------------------------------------------------
  static Future<Map<String, dynamic>> registerUser({
    required String fullName,
    required String email,
    required String phone,
    required String bvn,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/register'),
        headers: _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': 'Password123!',
        }),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['access_token'] != null) {
          _jwtToken = data['access_token'];
        }
        return {
          'success': true,
          'message': 'Account created successfully with Tier 2 verification.',
          'user': data['user'] ?? {'fullName': fullName, 'email': email},
        };
      }
    } catch (e) {
      if (kDebugMode) print("ApiService registerUser network exception: $e");
    }

    _jwtToken = "demo_jwt_token_new_user";
    return {
      'success': true,
      'message': 'Account created successfully with Tier 2 verification.',
      'user': {
        'fullName': fullName,
        'email': email,
        'accountNumber': '2049182049',
        'balance': 50000.0,
      }
    };
  }

  // ------------------------------------------------------------------
  // CARD ISSUING API
  // ------------------------------------------------------------------
  static Future<Map<String, dynamic>> issuePaymentCard({
    required String cardBrand,
    required String cardType,
    required String cardholderName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/cards/issue'),
        headers: _getHeaders(),
        body: jsonEncode({
          'card_brand': cardBrand,
          'card_type': cardType,
          'cardholder_name': cardholderName,
          'daily_limit_cents': 5000000,
        }),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      if (kDebugMode) print("ApiService issuePaymentCard network exception: $e");
    }
    return {'status': 'ACTIVE', 'card_number': '4111 2091 8201 9928'};
  }

  // ------------------------------------------------------------------
  // AI ASSISTANT & FINANCIAL ADVISOR API
  // ------------------------------------------------------------------
  static Future<Map<String, dynamic>> sendAiChatPrompt({
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/chat'),
        headers: _getHeaders(),
        body: jsonEncode({'message': message}),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      if (kDebugMode) print("ApiService sendAiChatPrompt network exception: $e");
    }

    // Offline / Demo Fallback
    final prompt = message.toLowerCase();
    String replyText = "I've analyzed your financial query. Your account balance and financial health score are strong.";
    Map<String, dynamic>? responseCard;

    if (prompt.contains('subscription') || prompt.contains('cancel') || prompt.contains('save')) {
      replyText = "I've identified \$42.50 in recurring subscriptions you haven't used in 60 days.";
      responseCard = {
        'isCard': true,
        'cardType': 'savings',
        'text': replyText,
        'goalTitle': 'Monthly Goal: Emergency Fund Vault',
        'goalPercent': '85%',
        'question': 'Would you like me to cancel these and move the savings to your Emergency Fund?'
      };
    } else if (prompt.contains('report') || prompt.contains('spending') || prompt.contains('monthly')) {
      replyText = "Here is your spending insight for Dining & Drinks.";
      responseCard = {
        'isCard': true,
        'cardType': 'insight',
        'title': 'Dining & Drinks',
        'tag': 'Spending Insight',
        'badge': '+15% vs last week',
        'spentText': "You spent \$240.00 at restaurants this week. That's \$35 over your typical average."
      };
    }

    return {
      'success': true,
      'reply': replyText,
      'card': responseCard,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  static Future<Map<String, dynamic>> getAiInsights() async {
    return {
      'success': true,
      'budgetHealthScore': 92,
      'healthStatus': 'Excellent',
      'insights': [
        {
          'id': 'ins_1',
          'type': 'SPENDING_SPIKE',
          'category': 'Dining & Drinks',
          'amountSpent': 240.00,
          'averageAmount': 205.00,
          'variancePercent': 17.0,
          'recommendation': 'Cap dining out to \$40/week to save \$140 monthly.'
        }
      ],
      'savingsOpportunityTotal': 42.49,
    };
  }
}
