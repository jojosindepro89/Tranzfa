import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/banking_service.dart';
import '../theme/app_theme.dart';
import '../widgets/vtu_modal.dart';
import '../services/vtu_service.dart';
import 'cards_screen.dart';
import 'yield_screen.dart';
import 'bills_screen.dart';
import 'ai_assistant_screen.dart';
import 'profile_screen.dart';
import 'send_money_screen.dart';
import 'transaction_receipt_screen.dart';
import 'savings_goals_screen.dart';
import 'transaction_history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0;
  bool _isBalanceVisible = true;

  String _formatAmount(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '$integerPart.${parts[1]}';
  }

  void _openSendMoney() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SendMoneyScreen()),
    );
  }

  void _openBills() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BillsScreen()),
    );
  }

  void _openVtu(VtuCategory category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VtuPurchaseModal(initialCategory: category),
    );
  }

  void _showGlobalAccountsModal(BuildContext context) {
    final bankService = Provider.of<BankingService>(context, listen: false);
    final details = bankService.globalBankDetails;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF0B1713),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: Color(0xFF00C88C), width: 2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C88C).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.public_rounded, color: Color(0xFF00C88C), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Global USD & EUR Accounts',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Receive remote salary & wire transfers directly into stablecoins',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // USD ACH / FEDWIRE CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF14241E),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF1E3A2F)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('🇺🇸 USD Account (Fedwire / ACH)', style: TextStyle(color: Color(0xFF00C88C), fontWeight: FontWeight.bold, fontSize: 14)),
                        Icon(Icons.verified_user_rounded, color: Color(0xFF00C88C), size: 18),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Bank Name: ${details.usdBankName}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('Routing Number: ${details.usdRoutingNumber}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Account Number: ${details.usdAccountNumber}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Beneficiary: ${details.beneficiaryName}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // EUR SEPA IBAN CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF14241E),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF1E3A2F)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('🇪🇺 EUR IBAN (SEPA / SWIFT)', style: TextStyle(color: Color(0xFF00C88C), fontWeight: FontWeight.bold, fontSize: 14)),
                        Icon(Icons.verified_user_rounded, color: Color(0xFF00C88C), size: 18),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Bank Name: ${details.eurBankName}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('IBAN: ${details.eurIban}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('BIC / SWIFT: ${details.eurBicSwift}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Global USD & EUR account details copied to clipboard! 📋')),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, color: Colors.black, size: 20),
                  label: const Text('Copy Account Details', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C88C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bankService = Provider.of<BankingService>(context);
    final activeAcc = bankService.activeAccount;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkBg : AppTheme.lightBg;
    final cardBgColor = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final borderColor = isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder;
    final textColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final subtextColor = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            // MAIN DASHBOARD SCROLLABLE CONTENT
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER (USER AVATAR, WELCOME TEXT, NOTIFICATION BELL)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF00C88C), width: 2),
                                ),
                                child: const CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Color(0xFFD4A373),
                                  child: Icon(Icons.person, color: Colors.white, size: 26),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'WELCOME BACK',
                                  style: TextStyle(
                                    color: subtextColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Good Morning, ${bankService.userFirstName}',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Notification Bell Icon Button
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()),
                            );
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F1A15) : const Color(0xFFE2EDE8),
                              shape: BoxShape.circle,
                              border: Border.all(color: borderColor),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(Icons.notifications_none_rounded, color: textColor, size: 22),
                                Positioned(
                                  top: 11,
                                  right: 12,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE5B800),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // MULTI-ASSET WALLET SELECTOR BAR (KAST MULTI-CURRENCY HUB)
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: bankService.accounts.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final acc = bankService.accounts[index];
                          final isSelected = acc.code == activeAcc.code;
                          return GestureDetector(
                            onTap: () {
                              bankService.setSelectedCurrency(acc.code);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF00C88C)
                                    : (isDark ? const Color(0xFF0E1C17) : const Color(0xFFE0EAE5)),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF00C88C)
                                      : (isDark ? const Color(0xFF1E382E) : const Color(0xFFCBDCD5)),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(acc.flag, style: const TextStyle(fontSize: 14)),
                                  const SizedBox(width: 6),
                                  Text(
                                    acc.code,
                                    style: TextStyle(
                                      color: isSelected ? Colors.black : textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // TOTAL BALANCE CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [const Color(0xFF043324), const Color(0xFF022117)]
                              : [const Color(0xFF034A34), const Color(0xFF022B1E)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFF0B523B), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Balance',
                                style: TextStyle(
                                  color: Color(0xFFB0C4BC),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isBalanceVisible = !_isBalanceVisible;
                                  });
                                },
                                child: Icon(
                                  _isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: const Color(0xFFB0C4BC),
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Large Balance Number
                          Text(
                            _isBalanceVisible
                                ? '${activeAcc.symbol}${_formatAmount(activeAcc.balance)}'
                                : '••••••••',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Top Up and Analytics Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _openSendMoney,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF043324),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.add_circle, size: 18, color: Color(0xFF043324)),
                                      SizedBox(width: 8),
                                      Text(
                                        'Top Up',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const SavingsGoalsScreen()),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFF1E5240), width: 1.5),
                                    backgroundColor: const Color(0xFF07241A).withOpacity(0.5),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.history_toggle_off_rounded, size: 18, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(
                                        'Analytics',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // GLOBAL ACCOUNTS BANNER (KAST USD ACH / EUR IBAN)
                    GestureDetector(
                      onTap: () => _showGlobalAccountsModal(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0A1C16) : const Color(0xFFE4F2EC),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF00C88C).withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00C88C).withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.public_rounded, color: Color(0xFF00C88C), size: 20),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Global Bank Details (USD / EUR)',
                                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'ACH Routing: 021000021 • SEPA IBAN',
                                      style: TextStyle(color: Color(0xFF00C88C), fontSize: 11, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Icon(Icons.chevron_right_rounded, color: Color(0xFF00C88C), size: 22),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // CONSOLIDATED QUICK ACTION UTILITY GRID (Send, Transfer, Electric, WiFi, Bills, Airtime)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActionButton(
                          icon: Icons.near_me_rounded,
                          label: 'Send',
                          isHighlight: true,
                          isDark: isDark,
                          subtextColor: subtextColor,
                          onTap: _openSendMoney,
                        ),
                        _buildActionButton(
                          icon: Icons.swap_horiz_rounded,
                          label: 'Transfer',
                          isHighlight: false,
                          isDark: isDark,
                          subtextColor: subtextColor,
                          onTap: _openSendMoney,
                        ),
                        _buildActionButton(
                          icon: Icons.bolt_rounded,
                          label: 'Electric',
                          isHighlight: false,
                          isDark: isDark,
                          subtextColor: subtextColor,
                          onTap: () => _openVtu(VtuCategory.electricity),
                        ),
                        _buildActionButton(
                          icon: Icons.wifi_rounded,
                          label: 'WiFi',
                          isHighlight: false,
                          isDark: isDark,
                          subtextColor: subtextColor,
                          onTap: () => _openVtu(VtuCategory.data),
                        ),
                        _buildActionButton(
                          icon: Icons.savings_outlined,
                          label: 'Savings',
                          isHighlight: false,
                          isDark: isDark,
                          subtextColor: subtextColor,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SavingsGoalsScreen()),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // SMART INSIGHT CARD
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SavingsGoalsScreen()),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF051711) : const Color(0xFFE5F5EF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isDark ? const Color(0xFF0D3D2D) : const Color(0xFFBBE5D5), width: 1.2),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0A3326) : const Color(0xFFC0EADA),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.auto_awesome, color: Color(0xFF00C88C), size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'SMART INSIGHT',
                                    style: TextStyle(
                                      color: Color(0xFF00C88C),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        color: isDark ? const Color(0xFFD0DCD6) : const Color(0xFF1E3A2F),
                                        fontSize: 13,
                                        height: 1.35,
                                      ),
                                      children: [
                                        const TextSpan(text: 'You spent '),
                                        TextSpan(
                                          text: '₦45,000',
                                          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                                        ),
                                        const TextSpan(text: ' on food this week. That’s '),
                                        const TextSpan(
                                          text: '12% more',
                                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE5B800)),
                                        ),
                                        const TextSpan(text: ' than last week.'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // MY CARDS SECTION HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Cards',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const CardsScreen()),
                            );
                          },
                          child: const Text(
                            'See All',
                            style: TextStyle(
                              color: Color(0xFF00C88C),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // MY CARDS CAROUSEL ITEM
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      child: Row(
                        children: [
                          // Main Emerald Debit Card
                          Container(
                            width: MediaQuery.of(context).size.width * 0.82,
                            height: 200,
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF063B29),
                                  Color(0xFF03261A),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFF0C543A), width: 1.2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Card Header (Brand & Contactless)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'TRANZFA',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                            fontStyle: FontStyle.italic,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        Text(
                                          'PLATINUM DEBIT',
                                          style: TextStyle(
                                            color: Color(0xFF8BA398),
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Icon(Icons.wifi_rounded, color: Color(0xFF8BA398), size: 24),
                                  ],
                                ),

                                // Masked Card Number
                                Row(
                                  children: const [
                                    Text(
                                      '∗ ∗ ∗ ∗   ∗ ∗ ∗ ∗   ∗ ∗ ∗ ∗   ',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 18,
                                        letterSpacing: 2,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '8 8 2 1',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ],
                                ),

                                // Card Bottom (Holder & Mastercard logo)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'CARD HOLDER',
                                          style: TextStyle(
                                            color: Color(0xFF6E857B),
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          bankService.userFullName.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Mastercard Red & Yellow overlapping circles
                                    SizedBox(
                                      width: 44,
                                      height: 28,
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 26,
                                            height: 26,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFEB001B),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          Positioned(
                                            left: 14,
                                            child: Container(
                                              width: 26,
                                              height: 26,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF79E1B).withOpacity(0.9),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 14),

                          // Peeking Second Card (Dark Blue / Black Card)
                          Container(
                            width: MediaQuery.of(context).size.width * 0.18,
                            height: 200,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0F1A30), Color(0xFF090E1A)],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFF1E2D4A)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // RECENT ACTIVITY HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Activity',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F1A15) : const Color(0xFFE2EDE8),
                              shape: BoxShape.circle,
                              border: Border.all(color: borderColor),
                            ),
                            child: Icon(Icons.tune_rounded, color: textColor, size: 18),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // RECENT TRANSACTIONS FEED LIST
                    Column(
                      children: [
                        _buildTransactionRow(
                          icon: Icons.movie_outlined,
                          iconBgColor: const Color(0xFF331518),
                          iconColor: const Color(0xFFFF4D4D),
                          title: 'Netflix Subscription',
                          subtitle: '24 Oct, 2023 • 10:45 AM',
                          amountText: '-₦4,500.00',
                          isDebit: true,
                          cardBgColor: cardBgColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          subtextColor: subtextColor,
                        ),
                        _buildTransactionRow(
                          icon: Icons.person_outline_rounded,
                          iconBgColor: const Color(0xFF0A2B20),
                          iconColor: const Color(0xFF00C88C),
                          title: 'Transfer to Sarah',
                          subtitle: '23 Oct, 2023 • 08:12 PM',
                          amountText: '-₦120,000.00',
                          isDebit: true,
                          cardBgColor: cardBgColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          subtextColor: subtextColor,
                        ),
                        _buildTransactionRow(
                          icon: Icons.local_cafe_outlined,
                          iconBgColor: const Color(0xFF2E2611),
                          iconColor: const Color(0xFFE5B800),
                          title: 'Starbucks Coffee',
                          subtitle: '23 Oct, 2023 • 09:30 AM',
                          amountText: '-₦2,450.00',
                          isDebit: true,
                          cardBgColor: cardBgColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          subtextColor: subtextColor,
                        ),
                        _buildTransactionRow(
                          icon: Icons.account_balance_wallet_outlined,
                          iconBgColor: const Color(0xFF0A2B20),
                          iconColor: const Color(0xFF00C88C),
                          title: 'Wallet Top-up',
                          subtitle: '22 Oct, 2023 • 02:15 PM',
                          amountText: '+₦50,000.00',
                          isDebit: false,
                          cardBgColor: cardBgColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          subtextColor: subtextColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // FLOATING BOTTOM NAVIGATION BAR
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0B1713).withOpacity(0.95) : Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(color: borderColor, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      index: 0,
                      icon: Icons.home_filled,
                      label: 'Home',
                      isActive: _currentNavIndex == 0,
                      subtextColor: subtextColor,
                      onTap: () => setState(() => _currentNavIndex = 0),
                    ),
                    _buildNavItem(
                      index: 1,
                      icon: Icons.credit_card_rounded,
                      label: 'Cards',
                      isActive: _currentNavIndex == 1,
                      subtextColor: subtextColor,
                      onTap: () {
                        setState(() => _currentNavIndex = 1);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CardsScreen()),
                        );
                      },
                    ),
                    _buildNavItem(
                      index: 2,
                      icon: Icons.history_rounded,
                      label: 'History',
                      isActive: _currentNavIndex == 2,
                      subtextColor: subtextColor,
                      onTap: () {
                        setState(() => _currentNavIndex = 2);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()),
                        );
                      },
                    ),
                    _buildNavItem(
                      index: 3,
                      icon: Icons.person_outline_rounded,
                      label: 'Profile',
                      isActive: _currentNavIndex == 3,
                      subtextColor: subtextColor,
                      onTap: () {
                        setState(() => _currentNavIndex = 3);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ProfileScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Quick Action Round Icon Button
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isHighlight,
    required bool isDark,
    required Color subtextColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: isHighlight
                  ? const Color(0xFF0F4735)
                  : (isDark ? const Color(0xFF0F1A15) : const Color(0xFFE2EDE8)),
              shape: BoxShape.circle,
              border: Border.all(
                color: isHighlight ? const Color(0xFF00C88C) : (isDark ? const Color(0xFF1A2E24) : const Color(0xFFCBE0D7)),
                width: 1.2,
              ),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF00C88C),
              size: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: subtextColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Recent Activity Row Item
  Widget _buildTransactionRow({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amountText,
    required bool isDebit,
    required Color cardBgColor,
    required Color borderColor,
    required Color textColor,
    required Color subtextColor,
  }) {
    return GestureDetector(
      onTap: () {
        final amtRaw = double.tryParse(amountText.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 150000.0;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TransactionReceiptScreen(
              recipientName: title.contains('Transfer') ? 'Oluwaseun Adeyemi' : title,
              bankName: 'Kuda Bank',
              bankLogoText: 'K',
              bankLogoColor: const Color(0xFF00C88C),
              amount: amtRaw,
              currencySymbol: '₦',
              transactionRef: 'TZ-9948201-X',
              dateTimeText: subtitle.isNotEmpty ? subtitle : 'Oct 24, 2023, 14:20',
              transactionFee: '₦10.00',
              statusText: 'SUCCESSFUL',
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: subtextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amountText,
            style: TextStyle(
              color: isDebit ? const Color(0xFFFF5252) : const Color(0xFF00E676),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

  // Bottom Navigation Bar Item
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
    required Color subtextColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isActive ? 8 : 4),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF0E4735) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? const Color(0xFF00E676) : subtextColor,
              size: 22,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFF00E676) : subtextColor,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
