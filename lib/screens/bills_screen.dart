import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/banking_service.dart';
import '../widgets/vtu_modal.dart';
import '../services/vtu_service.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'ai_assistant_screen.dart';
import 'cards_screen.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCategoryTap(String category) {
    VtuCategory vtuCat = VtuCategory.electricity;
    final lower = category.toLowerCase();
    if (lower.contains('airtime') || lower.contains('mobile')) {
      vtuCat = VtuCategory.airtime;
    } else if (lower.contains('data') || lower.contains('wifi') || lower.contains('internet')) {
      vtuCat = VtuCategory.data;
    } else if (lower.contains('tv') || lower.contains('cable') || lower.contains('dstv')) {
      vtuCat = VtuCategory.cableTv;
    } else {
      vtuCat = VtuCategory.electricity;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VtuPurchaseModal(initialCategory: vtuCat),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bankService = Provider.of<BankingService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF040E0A) : const Color(0xFFF4F7F5);
    final cardBgColor = isDark ? const Color(0xFF081C15) : Colors.white;
    final borderColor = isDark ? const Color(0xFF10362A) : const Color(0xFFE0E8E4);
    final textColor = isDark ? Colors.white : const Color(0xFF0B1F17);
    final subtextColor = isDark ? const Color(0xFF6E857B) : const Color(0xFF5A7067);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER: WALLET BALANCE & NOTIFICATION BELL
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF072B20) : const Color(0xFFE2EDE8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF00C88C), size: 22),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TRANZFA WALLET',
                                style: TextStyle(
                                  color: subtextColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${bankService.activeAccount.symbol}${bankService.activeAccount.balance.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Notification Bell
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0B1F17) : const Color(0xFFE2EDE8),
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor),
                        ),
                        child: Icon(Icons.notifications_none_rounded, color: textColor, size: 22),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // SEARCH BAR
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF071F17) : Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, color: subtextColor, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: TextStyle(color: textColor, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Search bills or providers...',
                              hintStyle: TextStyle(color: subtextColor, fontSize: 14),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ESSENTIAL SERVICES HEADER & GRID
                  Text(
                    'ESSENTIAL SERVICES',
                    style: TextStyle(
                      color: subtextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _buildServiceCard(
                          icon: Icons.bolt_rounded,
                          iconBgColor: const Color(0xFFE5B800),
                          label: 'Electricity',
                          isDark: isDark,
                          cardBgColor: cardBgColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          onTap: () => _onCategoryTap('Electricity'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildServiceCard(
                          icon: Icons.water_drop_rounded,
                          iconBgColor: const Color(0xFF2979FF),
                          label: 'Water',
                          isDark: isDark,
                          cardBgColor: cardBgColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          onTap: () => _onCategoryTap('Water'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildServiceCard(
                          icon: Icons.wifi_rounded,
                          iconBgColor: const Color(0xFF00E5FF),
                          label: 'Internet',
                          isDark: isDark,
                          cardBgColor: cardBgColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          onTap: () => _onCategoryTap('Internet'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildServiceCard(
                          icon: Icons.phone_android_rounded,
                          iconBgColor: const Color(0xFF00C88C),
                          label: 'Airtime',
                          isDark: isDark,
                          cardBgColor: cardBgColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          onTap: () => _onCategoryTap('Airtime & Data'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // LIFESTYLE & ENTERTAINMENT HEADER & GRID
                  Text(
                    'LIFESTYLE & ENTERTAINMENT',
                    style: TextStyle(
                      color: subtextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _buildServiceCard(
                          icon: Icons.tv_rounded,
                          iconBgColor: const Color(0xFFAA00FF),
                          label: 'Cable TV',
                          isDark: isDark,
                          cardBgColor: cardBgColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          onTap: () => _onCategoryTap('Cable TV'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildServiceCard(
                          icon: Icons.school_rounded,
                          iconBgColor: const Color(0xFFFF6D00),
                          label: 'Education',
                          isDark: isDark,
                          cardBgColor: cardBgColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          onTap: () => _onCategoryTap('Education'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildServiceCard(
                          icon: Icons.casino_rounded,
                          iconBgColor: const Color(0xFFFF1744),
                          label: 'Betting',
                          isDark: isDark,
                          cardBgColor: cardBgColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          onTap: () => _onCategoryTap('Betting'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildServiceCard(
                          icon: Icons.movie_creation_rounded,
                          iconBgColor: const Color(0xFFE91E63),
                          label: 'Streams',
                          isDark: isDark,
                          cardBgColor: cardBgColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          onTap: () => _onCategoryTap('Streaming'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // GOVERNMENT & UTILITIES HEADER & GRID
                  Text(
                    'GOVERNMENT & PUBLIC SERVICES',
                    style: TextStyle(
                      color: subtextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _buildServiceCard(
                          icon: Icons.solar_power_rounded,
                          iconBgColor: const Color(0xFFF57C00),
                          label: 'Solar',
                          isDark: isDark,
                          cardBgColor: cardBgColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          onTap: () => _onCategoryTap('Solar Energy'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildServiceCard(
                          icon: Icons.delete_outline_rounded,
                          iconBgColor: const Color(0xFF388E3C),
                          label: 'Waste',
                          isDark: isDark,
                          cardBgColor: cardBgColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          onTap: () => _onCategoryTap('Waste Management'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildServiceCard(
                          icon: Icons.alt_route_rounded,
                          iconBgColor: const Color(0xFF7B1FA2),
                          label: 'Toll & Tax',
                          isDark: isDark,
                          cardBgColor: cardBgColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          onTap: () => _onCategoryTap('Toll & Taxes'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildServiceCard(
                          icon: Icons.more_horiz_rounded,
                          iconBgColor: const Color(0xFF455A64),
                          label: 'More',
                          isDark: isDark,
                          cardBgColor: cardBgColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          onTap: () => _onCategoryTap('Other Utilities'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // SCHEDULED AUTO-BILLS SECTION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SCHEDULED AUTO-BILLS',
                        style: TextStyle(
                          color: subtextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C88C).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '2 ACTIVE',
                          style: TextStyle(
                            color: Color(0xFF00C88C),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Scheduled Item 1
                  _buildScheduledBillItem(
                    title: 'Ikeja Electric Prepaid (Meter #0129)',
                    dueText: 'Auto-debit in 5 days (Aug 23)',
                    amount: '₦15,000.00',
                    icon: Icons.bolt_rounded,
                    iconBg: const Color(0xFFE5B800),
                    isDark: isDark,
                    cardBgColor: cardBgColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    subtextColor: subtextColor,
                  ),

                  const SizedBox(height: 12),

                  // Scheduled Item 2
                  _buildScheduledBillItem(
                    title: 'Spectranet Unlimited 4G',
                    dueText: 'Auto-debit in 12 days (Aug 30)',
                    amount: '₦25,000.00',
                    icon: Icons.wifi_rounded,
                    iconBg: const Color(0xFF00E5FF),
                    isDark: isDark,
                    cardBgColor: cardBgColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    subtextColor: subtextColor,
                  ),

                  const SizedBox(height: 32),

                  // UTILITY PROMO BANNER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF043828), const Color(0xFF02261B)]
                            : [const Color(0xFF025839), const Color(0xFF013B26)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF0B523B)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Utility Promo & Cashbacks',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Get 5% instant cashback on all electricity & data recharge payments this weekend.',
                                style: TextStyle(
                                  color: Color(0xFFB0C4BC),
                                  fontSize: 12,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: const BoxDecoration(
                            color: Color(0xFF084733),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.card_giftcard_rounded, color: Color(0xFF00C88C), size: 28),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // RECENT UTILITY HISTORY HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'RECENT UTILITY HISTORY',
                        style: TextStyle(
                          color: subtextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'View All',
                        style: TextStyle(
                          color: const Color(0xFF00C88C),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Recent Item 1
                  _buildHistoryRow(
                    icon: Icons.bolt_rounded,
                    iconBg: const Color(0xFFFFF8E1),
                    iconColor: const Color(0xFFF57F17),
                    title: 'EKEDC Electricity Purchase',
                    subtitle: '18 Aug 2026 • Token: 8492-1029',
                    amount: '-₦12,500.00',
                    isDark: isDark,
                    cardBgColor: cardBgColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    subtextColor: subtextColor,
                  ),

                  // Recent Item 2
                  _buildHistoryRow(
                    icon: Icons.tv_rounded,
                    iconBg: const Color(0xFFF3E5F5),
                    iconColor: const Color(0xFF7B1FA2),
                    title: 'DSTV Premium Subscription',
                    subtitle: '15 Aug 2026 • SmartCard #49281',
                    amount: '-₦29,500.00',
                    isDark: isDark,
                    cardBgColor: cardBgColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    subtextColor: subtextColor,
                  ),

                  // Recent Item 3
                  _buildHistoryRow(
                    icon: Icons.wifi_rounded,
                    iconBg: const Color(0xFFE0F7FA),
                    iconColor: const Color(0xFF0097A7),
                    title: 'Spectranet Fiber Broadband',
                    subtitle: '10 Aug 2026 • Account #88201',
                    amount: '-₦25,000.00',
                    isDark: isDark,
                    cardBgColor: cardBgColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    subtextColor: subtextColor,
                  ),

                  // Recent Item 4
                  _buildHistoryRow(
                    icon: Icons.phone_android_rounded,
                    iconBg: const Color(0xFFE8F5E9),
                    iconColor: const Color(0xFF2E7D32),
                    title: 'MTN Airtime & Data Bundle',
                    subtitle: '05 Aug 2026 • +234 803 123 4567',
                    amount: '-₦5,000.00',
                    isDark: isDark,
                    cardBgColor: cardBgColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    subtextColor: subtextColor,
                  ),

                  const SizedBox(height: 40),
                ],
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
                      icon: Icons.home_filled,
                      label: 'Home',
                      isActive: false,
                      subtextColor: subtextColor,
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const DashboardScreen()),
                        );
                      },
                    ),
                    _buildNavItem(
                      icon: Icons.credit_card_rounded,
                      label: 'Cards',
                      isActive: false,
                      subtextColor: subtextColor,
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const CardsScreen()),
                        );
                      },
                    ),
                    _buildNavItem(
                      icon: Icons.insights_rounded,
                      label: 'Insights',
                      isActive: false,
                      subtextColor: subtextColor,
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
                        );
                      },
                    ),
                    _buildNavItem(
                      icon: Icons.person_rounded,
                      label: 'Profile',
                      isActive: false,
                      subtextColor: subtextColor,
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

  Widget _buildServiceCard({
    required IconData icon,
    required Color iconBgColor,
    required String label,
    required bool isDark,
    required Color cardBgColor,
    required Color borderColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: iconBgColor.withOpacity(0.4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduledBillItem({
    required String title,
    required String dueText,
    required String amount,
    required IconData icon,
    required Color iconBg,
    required bool isDark,
    required Color cardBgColor,
    required Color borderColor,
    required Color textColor,
    required Color subtextColor,
  }) {
    return Container(
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
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.black87, size: 22),
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
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  dueText,
                  style: TextStyle(
                    color: subtextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.check_circle_rounded, color: Color(0xFF00C88C), size: 12),
                  SizedBox(width: 4),
                  Text(
                    'Auto-Pay',
                    style: TextStyle(
                      color: Color(0xFF00C88C),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
    required bool isDark,
    required Color cardBgColor,
    required Color borderColor,
    required Color textColor,
    required Color subtextColor,
  }) {
    return Container(
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
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
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
                    fontSize: 14,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  color: Color(0xFFFF5252),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C88C).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Completed',
                  style: TextStyle(
                    color: Color(0xFF00C88C),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color subtextColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
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
