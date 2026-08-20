import 'dart:async';
import 'package:flutter/material.dart';
import '../models/banking_models.dart';
import 'core_banking_service.dart';

enum AppThemePreference { system, dark, light }

class BankingService extends ChangeNotifier {
  // Theme Preference State
  AppThemePreference _themePreference = AppThemePreference.system;

  AppThemePreference get themePreference => _themePreference;

  ThemeMode get themeMode {
    switch (_themePreference) {
      case AppThemePreference.dark:
        return ThemeMode.dark;
      case AppThemePreference.light:
        return ThemeMode.light;
      case AppThemePreference.system:
      default:
        return ThemeMode.system;
    }
  }

  void setThemePreference(AppThemePreference pref) {
    _themePreference = pref;
    notifyListeners();
  }

  // User Session State
  bool _isLoggedIn = false;
  String _userFullName = "Sarah Okonjo";
  String _userFirstName = "Sarah";
  String _userTag = "@sarahokonjo";
  String _userEmail = "sarah.okonjo@tranzfa.io";
  String _userAvatar = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150";

  bool get isLoggedIn => _isLoggedIn;
  String get userFullName => _userFullName;
  String get userFirstName => _userFirstName;
  String get userTag => _userTag;
  String get userEmail => _userEmail;
  String get userAvatar => _userAvatar;

  // Selected Active Currency for Balance Toggle
  String _selectedCurrencyCode = "NGN";
  String get selectedCurrencyCode => _selectedCurrencyCode;

  // Live Multi-Currency Accounts
  final List<CurrencyAccount> _accounts = [
    CurrencyAccount(
      id: 'acc_ngn',
      code: 'NGN',
      name: 'Nigerian Naira',
      symbol: '₦',
      flag: '🇳🇬',
      balance: 1240500.00,
      type: AccountType.fiat,
      accountNumber: '0123 4567 89',
      routingOrIban: '044000012',
    ),
    CurrencyAccount(
      id: 'acc_usd',
      code: 'USD',
      name: 'United States Dollar',
      symbol: '\$',
      flag: '🇺🇸',
      balance: 48920.50,
      type: AccountType.fiat,
      accountNumber: '9876 5432 10',
      routingOrIban: '021000021',
    ),
    CurrencyAccount(
      id: 'acc_eur',
      code: 'EUR',
      name: 'Euro Vault',
      symbol: '€',
      flag: '🇪🇺',
      balance: 12450.00,
      type: AccountType.fiat,
      accountNumber: 'DE89 3704 0044 0532 0130 00',
      routingOrIban: 'DBKDEFDF',
    ),
    CurrencyAccount(
      id: 'acc_gbp',
      code: 'GBP',
      name: 'British Pound',
      symbol: '£',
      flag: '🇬🇧',
      balance: 8350.25,
      type: AccountType.fiat,
      accountNumber: 'UK64 1234 5678 9012 34',
      routingOrIban: 'BARC2234',
    ),
    CurrencyAccount(
      id: 'acc_usdc',
      code: 'USDC',
      name: 'USD Coin Stablecoin',
      symbol: '\$',
      flag: '🌐',
      balance: 15420.80,
      type: AccountType.crypto,
      accountNumber: '0x71C...39A2',
      routingOrIban: '0x71C...39A2',
    ),
    CurrencyAccount(
      id: 'acc_usdt',
      code: 'USDT',
      name: 'Tether USD Stablecoin',
      symbol: '\$',
      flag: '₮',
      balance: 8240.50,
      type: AccountType.crypto,
      accountNumber: '0x71C...39A2',
      routingOrIban: '0x71C...39A2',
    ),
    CurrencyAccount(
      id: 'acc_usde',
      code: 'USDe',
      name: 'Ethena USDe Synthetic USD',
      symbol: '\$',
      flag: '💵',
      balance: 4500.00,
      type: AccountType.crypto,
      accountNumber: '0x71C...39A2',
      routingOrIban: '0x71C...39A2',
    ),
    CurrencyAccount(
      id: 'acc_btc',
      code: 'BTC',
      name: 'Bitcoin Vault',
      symbol: '₿',
      flag: '₿',
      balance: 0.45,
      type: AccountType.crypto,
      accountNumber: 'bc1q...982x',
      routingOrIban: 'bc1q...982x',
    ),
    CurrencyAccount(
      id: 'acc_eth',
      code: 'ETH',
      name: 'Ethereum Vault',
      symbol: 'Ξ',
      flag: 'Ξ',
      balance: 3.82,
      type: AccountType.crypto,
      accountNumber: '0x71C...39A2',
      routingOrIban: '0x71C...39A2',
    ),
    CurrencyAccount(
      id: 'acc_sol',
      code: 'SOL',
      name: 'Solana Wallet',
      symbol: '◎',
      flag: '◎',
      balance: 42.50,
      type: AccountType.crypto,
      accountNumber: '9x8K...22pL',
      routingOrIban: '9x8K...22pL',
    ),
  ];

  List<CurrencyAccount> get accounts => _accounts;

  final GlobalBankDetails _globalBankDetails = GlobalBankDetails(
    usdAccountNumber: '49201938102',
    usdRoutingNumber: '021000021',
    usdBankName: 'Choice Bank & Trust (USA)',
    usdSwiftCode: 'CHUSUS33',
    eurIban: 'DE89 3704 0044 0532 0130 00',
    eurBicSwift: 'DBKDEFDF',
    eurBankName: 'Deutsche Handelsbank (Germany)',
    beneficiaryName: 'Sarah Okonjo / Tranzfa Global',
  );

  GlobalBankDetails get globalBankDetails => _globalBankDetails;

  CurrencyAccount get activeAccount {
    return _accounts.firstWhere(
      (acc) => acc.code == _selectedCurrencyCode,
      orElse: () => _accounts.first,
    );
  }

  // Virtual Cards
  final List<TranzfaCard> _cards = [
    TranzfaCard(
      id: 'card_01',
      cardNumber: '4920 8819 3014 8842',
      expiryDate: '12/28',
      cvv: '849',
      cardHolderName: 'Sarah Okonjo',
      cardType: 'VIRTUAL PREMIUM',
      isGoldTier: true,
      isFrozen: false,
      monthlyLimit: 5000000.00,
      currentSpent: 420500.00,
      cashbackEarnedUsdc: 1250.80,
    ),
    TranzfaCard(
      id: 'card_02',
      cardNumber: '5399 4102 8841 9821',
      expiryDate: '09/26',
      cvv: '312',
      cardHolderName: 'Sarah Okonjo',
      cardType: 'BLACK CARD',
      isGoldTier: true,
      isFrozen: false,
      monthlyLimit: 1000000.00,
      currentSpent: 120000.00,
      cashbackEarnedUsdc: 420.50,
    ),
  ];

  List<TranzfaCard> get cards => _cards;

  // Yield Vaults
  final List<YieldVault> _yieldVaults = [
    YieldVault(
      assetName: 'USDC High Yield Vault',
      symbol: 'USDC',
      apy: 8.50,
      depositedAmount: 15000.00,
      totalEarnedInterest: 382.40,
    ),
    YieldVault(
      assetName: 'USDT Flex Vault',
      symbol: 'USDT',
      apy: 6.10,
      depositedAmount: 8000.00,
      totalEarnedInterest: 194.20,
    ),
    YieldVault(
      assetName: 'USDe Synthetic Yield',
      symbol: 'USDe',
      apy: 9.20,
      depositedAmount: 4500.00,
      totalEarnedInterest: 210.80,
    ),
    YieldVault(
      assetName: 'EUR Yield Vault',
      symbol: 'EUR',
      apy: 5.20,
      depositedAmount: 5000.00,
      totalEarnedInterest: 84.10,
    ),
  ];

  List<YieldVault> get yieldVaults => _yieldVaults;

  // Transaction Ledger Feed
  final List<TransactionItem> _transactions = [
    TransactionItem(
      id: 'tx_001',
      recipientName: 'Netflix Subscription',
      recipientTagOrIban: '24 Oct, 2023 • 10:45 AM',
      amount: 4500.00,
      currencyCode: 'NGN',
      currencySymbol: '₦',
      timestamp: DateTime(2023, 10, 24, 10, 45),
      isIncome: false,
      rail: RailType.speedRail,
      status: TransactionStatus.completed,
      speedMetric: 'Subscription',
    ),
    TransactionItem(
      id: 'tx_002',
      recipientName: 'Transfer to Sarah',
      recipientTagOrIban: '23 Oct, 2023 • 08:12 PM',
      amount: 120000.00,
      currencyCode: 'NGN',
      currencySymbol: '₦',
      timestamp: DateTime(2023, 10, 23, 20, 12),
      isIncome: false,
      rail: RailType.speedRail,
      status: TransactionStatus.completed,
      speedMetric: 'Instant Transfer',
    ),
    TransactionItem(
      id: 'tx_003',
      recipientName: 'Starbucks Coffee',
      recipientTagOrIban: '23 Oct, 2023 • 09:30 AM',
      amount: 2450.00,
      currencyCode: 'NGN',
      currencySymbol: '₦',
      timestamp: DateTime(2023, 10, 23, 9, 30),
      isIncome: false,
      rail: RailType.speedRail,
      status: TransactionStatus.completed,
      speedMetric: 'Card Payment',
    ),
    TransactionItem(
      id: 'tx_004',
      recipientName: 'Wallet Top-up',
      recipientTagOrIban: '22 Oct, 2023 • 02:15 PM',
      amount: 50000.00,
      currencyCode: 'NGN',
      currencySymbol: '₦',
      timestamp: DateTime(2023, 10, 22, 14, 15),
      isIncome: true,
      rail: RailType.speedRail,
      status: TransactionStatus.completed,
      speedMetric: 'Top Up',
    ),
  ];

  List<TransactionItem> get transactions => _transactions;

  // Exchange Rates Matrix
  double getExchangeRate(String from, String to) {
    if (from == to) return 1.0;
    if (from == 'USD' && to == 'EUR') return 0.915;
    if (from == 'EUR' && to == 'USD') return 1.093;
    if (from == 'USD' && to == 'GBP') return 0.785;
    if (from == 'GBP' && to == 'USD') return 1.274;
    if (from == 'USD' && to == 'USDC') return 1.00;
    if (from == 'USDC' && to == 'USD') return 1.00;
    if (from == 'BTC' && to == 'USD') return 64200.00;
    if (from == 'USD' && to == 'BTC') return 1 / 64200.00;
    return 1.0;
  }

  // Set Currency
  void setSelectedCurrency(String code) {
    _selectedCurrencyCode = code;
    notifyListeners();
  }

  // Authentication Toggle
  void login(String name, String email) {
    _isLoggedIn = true;
    _userFullName = name;
    _userEmail = email;
    _userTag = "@${name.toLowerCase().replaceAll(' ', '')}";
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  // Card Freeze Toggle
  void toggleCardFreeze(String cardId) {
    final index = _cards.indexWhere((c) => c.id == cardId);
    if (index != -1) {
      _cards[index].isFrozen = !_cards[index].isFrozen;
      notifyListeners();
    }
  }

  // Send Money Execution
  Future<bool> executeSpeedTransfer({
    required String recipientName,
    required String recipientTag,
    required double amount,
    required String currencyCode,
    required RailType rail,
  }) async {
    final accountIndex = _accounts.indexWhere((a) => a.code == currencyCode);
    if (accountIndex == -1 || _accounts[accountIndex].balance < amount) {
      return false;
    }

    // Deduct Balance
    _accounts[accountIndex].balance -= amount;

    // Add Transaction
    _transactions.insert(
      0,
      TransactionItem(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        recipientName: recipientName,
        recipientTagOrIban: recipientTag,
        amount: amount,
        currencyCode: currencyCode,
        currencySymbol: _accounts[accountIndex].symbol,
        timestamp: DateTime.now(),
        isIncome: false,
        rail: rail,
        status: TransactionStatus.completed,
        speedMetric: '0.4s Speed Rail',
      ),
    );

    notifyListeners();
    return true;
  }

  // Execute NIBSS NIP Interbank Transfer
  Future<TransferExecutionResult> executeNipInterbankTransfer({
    required String accountNumber,
    required String bankCode,
    required String bankName,
    required String recipientName,
    required double amount,
    String? narration,
  }) async {
    final accountIndex = _accounts.indexWhere((a) => a.code == 'NGN');
    const double fee = 10.75;
    final totalDeduction = amount + fee;

    if (accountIndex == -1 || _accounts[accountIndex].balance < totalDeduction) {
      return TransferExecutionResult(
        success: false,
        reference: '',
        sessionId: '',
        amount: amount,
        fee: fee,
        recipientName: recipientName,
        bankName: bankName,
        accountNumber: accountNumber,
        status: 'FAILED',
        message: 'Insufficient account balance for NIP transfer + fee.',
        timestamp: DateTime.now(),
      );
    }

    final result = await CoreBankingService.executeInterbankTransfer(
      accountNumber: accountNumber,
      bankCode: bankCode,
      bankName: bankName,
      recipientName: recipientName,
      amount: amount,
      narration: narration,
    );

    if (result.success) {
      _accounts[accountIndex].balance -= totalDeduction;

      _transactions.insert(
        0,
        TransactionItem(
          id: result.reference,
          recipientName: recipientName,
          recipientTagOrIban: '$accountNumber • $bankName',
          amount: amount,
          currencyCode: 'NGN',
          currencySymbol: '₦',
          timestamp: DateTime.now(),
          isIncome: false,
          rail: RailType.interbankNip,
          status: TransactionStatus.completed,
          speedMetric: 'NIBSS NIP 0.4s',
        ),
      );

      notifyListeners();
    }

    return result;
  }

  // FX / Crypto Swap Execution
  Future<bool> executeCryptoSwap({
    String? fromCode,
    String? fromAsset,
    String? toCode,
    String? toAsset,
    required double fromAmount,
    double? toAmount,
  }) async {
    final srcCode = fromCode ?? fromAsset ?? 'USD';
    final destCode = toCode ?? toAsset ?? 'EUR';
    final destAmount = toAmount ?? (fromAmount * getExchangeRate(srcCode, destCode));

    final fromIndex = _accounts.indexWhere((a) => a.code == srcCode);
    final toIndex = _accounts.indexWhere((a) => a.code == destCode);

    if (fromIndex == -1 || _accounts[fromIndex].balance < fromAmount) {
      return false;
    }

    _accounts[fromIndex].balance -= fromAmount;
    if (toIndex != -1) {
      _accounts[toIndex].balance += destAmount;
    }

    notifyListeners();
    return true;
  }

  // Execute VTU Payment (Airtime, Data, Electricity, Cable TV)
  Future<bool> executeVtuPayment({
    required String title,
    required String subtitle,
    required double amount,
    required String currencyCode,
    required String category,
  }) async {
    final accountIndex = _accounts.indexWhere((a) => a.code == currencyCode);
    if (accountIndex == -1 || _accounts[accountIndex].balance < amount) {
      return false;
    }

    // Deduct Balance
    _accounts[accountIndex].balance -= amount;

    // Insert Transaction
    _transactions.insert(
      0,
      TransactionItem(
        id: 'vtu_${DateTime.now().millisecondsSinceEpoch}',
        recipientName: title,
        recipientTagOrIban: subtitle,
        amount: amount,
        currencyCode: currencyCode,
        currencySymbol: _accounts[accountIndex].symbol,
        timestamp: DateTime.now(),
        isIncome: false,
        rail: RailType.speedRail,
        status: TransactionStatus.completed,
        speedMetric: '$category VTU',
      ),
    );

    notifyListeners();
    return true;
  }
}
