enum AccountType { fiat, crypto, stablecoin }
enum RailType { speedRail, swift, sepa, p2pTag, interbankNip }
enum TransactionStatus { completed, inTransit, pending, declined }

class CurrencyAccount {
  final String id;
  final String code;
  final String name;
  final String symbol;
  final String flag;
  double balance;
  final AccountType type;
  final String accountNumber;
  final String routingOrIban;

  CurrencyAccount({
    required this.id,
    required this.code,
    required this.name,
    required this.symbol,
    required this.flag,
    required this.balance,
    required this.type,
    required this.accountNumber,
    required this.routingOrIban,
  });
}

class TransactionItem {
  final String id;
  final String recipientName;
  final String recipientTagOrIban;
  final double amount;
  final String currencyCode;
  final String currencySymbol;
  final DateTime timestamp;
  final bool isIncome;
  final RailType rail;
  final TransactionStatus status;
  final String speedMetric; // e.g. "1.2 sec" or "ISO20022"
  final String category;

  TransactionItem({
    required this.id,
    required this.recipientName,
    required this.recipientTagOrIban,
    required this.amount,
    required this.currencyCode,
    required this.currencySymbol,
    required this.timestamp,
    required this.isIncome,
    required this.rail,
    required this.status,
    required this.speedMetric,
    this.category = "General",
  });
}

class TranzfaCard {
  final String id;
  final String cardHolderName;
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final String cardType; // "VIP Obsidian Emerald" or "VIP Pure Gold"
  final bool isGoldTier;
  bool isFrozen;
  double monthlyLimit;
  double currentSpent;
  double cashbackEarnedUsdc;

  TranzfaCard({
    required this.id,
    required this.cardHolderName,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.cardType,
    required this.isGoldTier,
    this.isFrozen = false,
    required this.monthlyLimit,
    required this.currentSpent,
    required this.cashbackEarnedUsdc,
  });
}

class YieldVault {
  final String assetName;
  final String symbol;
  final double apy;
  double depositedAmount;
  double totalEarnedInterest;

  YieldVault({
    required this.assetName,
    required this.symbol,
    required this.apy,
    required this.depositedAmount,
    required this.totalEarnedInterest,
  });
}

class GlobalBankDetails {
  final String usdAccountNumber;
  final String usdRoutingNumber;
  final String usdBankName;
  final String usdSwiftCode;
  final String eurIban;
  final String eurBicSwift;
  final String eurBankName;
  final String beneficiaryName;

  GlobalBankDetails({
    required this.usdAccountNumber,
    required this.usdRoutingNumber,
    required this.usdBankName,
    required this.usdSwiftCode,
    required this.eurIban,
    required this.eurBicSwift,
    required this.eurBankName,
    required this.beneficiaryName,
  });
}

