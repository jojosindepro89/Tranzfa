import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../models/banking_models.dart';
import '../services/banking_service.dart';
import '../widgets/vtu_modal.dart';
import '../services/vtu_service.dart';
import 'cards_screen.dart';
import 'bills_screen.dart';
import 'profile_screen.dart';
import 'send_money_screen.dart';
import 'transaction_history_screen.dart';
import 'transaction_receipt_screen.dart';
import 'savings_goals_screen.dart';
import 'ai_assistant_screen.dart';
import 'notifications_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isBalanceVisible = true;

  String _formatAmount(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '$integerPart.${parts[1]}';
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _openSendMoney() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SendMoneyScreen()),
    );
  }

  void _openVtu(VtuCategory cat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VtuPurchaseModal(initialCategory: cat),
    );
  }

  void _openAiAnalysis() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bankService = Provider.of<BankingService>(context);
    final activeAcc = bankService.activeAccount;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF060D09) : const Color(0xFFF4F7F5);
    final textColor = isDark ? Colors.white : const Color(0xFF0B1F17);
    final subtextColor = isDark ? const Color(0xFF7A9489) : const Color(0xFF6B7E76);
    final cardBgColor = isDark ? const Color(0xFF0D1E17) : Colors.white;
    final borderColor = isDark ? const Color(0xFF162E24) : const Color(0xFFE2EDE8);
    const green = Color(0xFF00C88C);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            // MAIN DASHBOARD SCROLLABLE CONTENT
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── HEADER (USER AVATAR, WELCOME TEXT, AI SPARKLE BUTTON, NOTIFICATION BELL) ──
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
                                  border: Border.all(color: green, width: 1.5),
                                ),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: isDark ? const Color(0xFF1A3328) : const Color(0xFFD0EAE0),
                                  child: Text(
                                    bankService.userFirstName.isNotEmpty ? bankService.userFirstName[0] : 'S',
                                    style: const TextStyle(color: green, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
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
                                  '${_greeting()}, ${bankService.userFirstName}',
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

                        // Action Buttons: AI Analysis Sparkle + Notification Bell
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _openAiAnalysis,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0D281E) : const Color(0xFFE2EDE8),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: green.withOpacity(0.4)),
                                ),
                                child: const Icon(Iconsax.magic_star, color: green, size: 20),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                                );
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0F1A15) : const Color(0xFFE2EDE8),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: borderColor),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(Iconsax.notification, color: textColor, size: 20),
                                    Positioned(
                                      top: 9,
                                      right: 10,
                                      child: Container(
                                        width: 7,
                                        height: 7,
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
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── PENDING COMPLIANCE / FRAUD HELD ALERT BANNER ──
                    if (bankService.transactions.any((tx) => tx.status == TransactionStatus.pending)) ...[
                      Builder(builder: (context) {
                        final pendingTx = bankService.transactions.firstWhere((tx) => tx.status == TransactionStatus.pending);
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TransactionReceiptScreen(
                                  transactionRef: pendingTx.id,
                                  amount: pendingTx.amount,
                                  recipientName: pendingTx.recipientName,
                                  bankName: pendingTx.recipientTagOrIban,
                                  dateTimeText: 'Just Now',
                                  transactionFee: '₦10.00',
                                  statusText: 'HELD_FOR_REVIEW',
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF261904),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFF59E0B), width: 1.2),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF59E0B).withOpacity(0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B).withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.security_rounded, color: Color(0xFFF59E0B), size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'ACTION REQUIRED • CBN FRAUD HOLD',
                                        style: TextStyle(
                                          color: Color(0xFFF59E0B),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Transfer of ₦${_formatAmount(pendingTx.amount)} is held under review.',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Tap to perform identity verification',
                                        style: TextStyle(color: Colors.white70, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFF59E0B), size: 14),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],

                    // ── TOTAL BALANCE CARD ──
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
                                  _isBalanceVisible ? Iconsax.eye : Iconsax.eye_slash,
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

                          // Top Up & Analytics Buttons
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
                                      Icon(Iconsax.add_circle, size: 18, color: Color(0xFF043324)),
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
                                  onPressed: _openAiAnalysis,
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
                                      Icon(Iconsax.chart_2, size: 18, color: Colors.white),
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

                    const SizedBox(height: 28),

                    // ── QUICK ACTION ICONS ROW (Send, Request, Bills, Airtime) ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickAction(
                          icon: Iconsax.send_2,
                          label: 'Send',
                          isDark: isDark,
                          subtextColor: subtextColor,
                          onTap: _openSendMoney,
                        ),
                        _buildQuickAction(
                          icon: Iconsax.document_text,
                          label: 'Request',
                          isDark: isDark,
                          subtextColor: subtextColor,
                          onTap: _openSendMoney,
                        ),
                        _buildQuickAction(
                          icon: Iconsax.receipt_text,
                          label: 'Bills',
                          isDark: isDark,
                          subtextColor: subtextColor,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const BillsScreen()),
                          ),
                        ),
                        _buildQuickAction(
                          icon: Iconsax.mobile,
                          label: 'Airtime',
                          isDark: isDark,
                          subtextColor: subtextColor,
                          onTap: () => _openVtu(VtuCategory.airtime),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── SMART INSIGHT CARD (OPENS AI ANALYSIS SCREEN) ──
                    GestureDetector(
                      onTap: _openAiAnalysis,
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
                              child: const Icon(Iconsax.magic_star, color: green, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text(
                                        'SMART INSIGHT',
                                        style: TextStyle(
                                          color: green,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      Icon(Iconsax.arrow_right_3, color: green, size: 14),
                                    ],
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
                                          text: '${activeAcc.symbol}45,000',
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

                    const SizedBox(height: 28),

                    // ── MY CARDS SECTION HEADER ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Cards',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
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
                              color: green,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Horizontal Bank Cards Scroll
                    SizedBox(
                      height: 190,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildBankCard(
                            cardName: 'TRANZFA',
                            cardType: 'PLATINUM DEBIT',
                            cardNumber: '8 8 2 1',
                            holderName: 'SARAH OKONJO',
                            bgGradient: const [Color(0xFF043324), Color(0xFF022117)],
                            borderColor: const Color(0xFF0B523B),
                          ),
                          const SizedBox(width: 14),
                          _buildBankCard(
                            cardName: 'TRANZFA',
                            cardType: 'BLACK VIP',
                            cardNumber: '4 5 2 1',
                            holderName: 'SARAH OKONJO',
                            bgGradient: const [Color(0xFF141F2B), Color(0xFF080D13)],
                            borderColor: const Color(0xFF23364A),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── RECENT ACTIVITY SECTION ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Activity',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()),
                            );
                          },
                          child: Icon(Iconsax.setting_4, color: subtextColor, size: 20),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Dynamic Transaction Items
                    ...bankService.transactions.map((tx) {
                      final isPending = tx.status == TransactionStatus.pending;
                      final isIncome = tx.isIncome;
                      final icon = isPending
                          ? Icons.security_rounded
                          : (isIncome ? Iconsax.wallet_3 : Iconsax.send_2);
                      final iconBg = isPending
                          ? const Color(0xFF3B2503)
                          : (isIncome ? const Color(0xFF0A3326) : const Color(0xFF142E24));
                      final iconColor = isPending
                          ? const Color(0xFFF59E0B)
                          : (isIncome ? green : const Color(0xFF00C88C));
                      final subtitleText = isPending
                          ? '${tx.recipientTagOrIban} • PENDING VERIFICATION'
                          : tx.recipientTagOrIban;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TransactionReceiptScreen(
                                  transactionRef: tx.id,
                                  amount: tx.amount,
                                  recipientName: tx.recipientName,
                                  bankName: tx.recipientTagOrIban,
                                  dateTimeText: 'Recent',
                                  transactionFee: '₦10.00',
                                  statusText: isPending ? 'HELD_FOR_REVIEW' : 'SUCCESSFUL',
                                ),
                              ),
                            );
                          },
                          child: _buildTransactionCard(
                            icon: icon,
                            iconBg: iconBg,
                            iconColor: iconColor,
                            title: tx.recipientName,
                            subtitle: subtitleText,
                            amount: '${isIncome ? '+' : '-'}${activeAcc.symbol}${_formatAmount(tx.amount)}',
                            isNegative: !isIncome,
                            cardBgColor: cardBgColor,
                            borderColor: isPending ? const Color(0xFFF59E0B).withOpacity(0.5) : borderColor,
                            textColor: textColor,
                            subtextColor: isPending ? const Color(0xFFF59E0B) : subtextColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

            // ── FLOATING BOTTOM NAV BAR ──
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0B1713) : Colors.white,
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(color: borderColor, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      icon: Iconsax.home_2,
                      label: 'Home',
                      isActive: true,
                      isDark: isDark,
                      subtextColor: subtextColor,
                      green: green,
                      onTap: () {},
                    ),
                    _buildNavItem(
                      icon: Iconsax.card,
                      label: 'Cards',
                      isActive: false,
                      isDark: isDark,
                      subtextColor: subtextColor,
                      green: green,
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const CardsScreen()),
                        );
                      },
                    ),
                    _buildNavItem(
                      icon: Iconsax.receipt_text,
                      label: 'Bills',
                      isActive: false,
                      isDark: isDark,
                      subtextColor: subtextColor,
                      green: green,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const BillsScreen()),
                        );
                      },
                    ),
                    _buildNavItem(
                      icon: Iconsax.chart_21,
                      label: 'Insights',
                      isActive: false,
                      isDark: isDark,
                      subtextColor: subtextColor,
                      green: green,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
                        );
                      },
                    ),
                    _buildNavItem(
                      icon: Iconsax.user,
                      label: 'Profile',
                      isActive: false,
                      isDark: isDark,
                      subtextColor: subtextColor,
                      green: green,
                      onTap: () {
                        Navigator.of(context).pushReplacement(
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

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required bool isDark,
    required Color subtextColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F241C) : const Color(0xFFE2EDE8),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF00C88C), size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF0B1F17),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankCard({
    required String cardName,
    required String cardType,
    required String cardNumber,
    required String holderName,
    required List<Color> bgGradient,
    required Color borderColor,
  }) {
    return Container(
      width: 290,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: bgGradient,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cardName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    cardType,
                    style: const TextStyle(
                      color: Color(0xFF7A9489),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.wifi_tethering, color: Colors.white60, size: 22),
            ],
          ),

          // Masked card number
          Row(
            children: [
              const Text(
                '••••   ••••   ••••   ',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                cardNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),

          // Bottom card holder & Mastercard logo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CARD HOLDER',
                    style: TextStyle(
                      color: Color(0xFF7A9489),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    holderName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),

              // Mastercard Circles
              SizedBox(
                width: 36,
                height: 22,
                child: Stack(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEB001B),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Positioned(
                      left: 14,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF79E1B),
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
    );
  }

  Widget _buildTransactionCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
    required bool isNegative,
    required Color cardBgColor,
    required Color borderColor,
    required Color textColor,
    required Color subtextColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              color: iconBg,
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
            amount,
            style: TextStyle(
              color: isNegative ? const Color(0xFFFF5252) : const Color(0xFF00C88C),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isDark,
    required Color subtextColor,
    required Color green,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? green : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.black : subtextColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isActive ? green : subtextColor,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
