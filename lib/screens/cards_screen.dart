import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'bills_screen.dart';
import 'ai_assistant_screen.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  bool _isFrozen = false;
  bool _isInternationalActive = true;
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkBg : AppTheme.lightBg;
    final cardBgColor = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final borderColor = isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder;
    final textColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final subtextColor = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Your Cards',
          style: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0B1F17) : const Color(0xFFE2EDE8),
              shape: BoxShape.circle,
              border: Border.all(color: borderColor),
            ),
            child: Icon(Icons.add, color: textColor, size: 22),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // MAIN CARD PREVIEW
                  Container(
                    width: double.infinity,
                    height: 210,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [const Color(0xFF0F3024), const Color(0xFF071F17)]
                            : [const Color(0xFF0C4231), const Color(0xFF06291E)],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFF16523D), width: 1.2),
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
                        // Card Header (Label & VISA Logo)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'VIRTUAL CARD',
                                  style: TextStyle(
                                    color: Color(0xFF8BA398),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Tranzfa Premium',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            // VISA Logo
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'VISA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  fontStyle: FontStyle.italic,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Masked Card Number
                        Row(
                          children: [
                            Text(
                              _showDetails
                                  ? '4920   8819   3014   '
                                  : '• • • •   • • • •   • • • •   ',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                                letterSpacing: 2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              '8 8 4 2',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),

                        // Expiry, CVV & Contactless Icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'EXPIRY',
                                      style: TextStyle(color: Color(0xFF6E857B), fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      '12/28',
                                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 24),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'CVV',
                                      style: TextStyle(color: Color(0xFF6E857B), fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _showDetails ? '849' : '•••',
                                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.wifi_rounded, color: Colors.white, size: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // VIEW CARD DETAILS BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => setState(() => _showDetails = !_showDetails),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF02472E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_showDetails ? Icons.visibility_off : Icons.visibility, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _showDetails ? 'Hide Card Details' : 'View Card Details',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // KAST 2.5% USDC CASHBACK REWARDS TRACKER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF14291F) : const Color(0xFFE5F5EF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF00C88C).withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5B800).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.stars_rounded, color: Color(0xFFE5B800), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  '2.5% USDC Cashback Active 🌟',
                                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Total Earned: \$1,250.80 USDC',
                                  style: TextStyle(color: Color(0xFF00C88C), fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C88C),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('AUTO REWARD', style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // APPLE WALLET & GOOGLE PAY DIGITAL WALLET BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: const Color(0xFF0B1713),
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                              builder: (_) => Container(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.apple, color: Colors.white, size: 48),
                                    const SizedBox(height: 12),
                                    const Text('Added to Apple Wallet! ', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    const Text('Your Tranzfa Visa Virtual Card is ready for contactless tap-to-pay globally.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 13)),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C88C), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                                      child: const Text('Done', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.apple, color: Colors.white, size: 20),
                          label: const Text('Apple Wallet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: Colors.white24)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: const Color(0xFF0B1713),
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                              builder: (_) => Container(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.account_balance_wallet, color: Color(0xFF00C88C), size: 48),
                                    const SizedBox(height: 12),
                                    const Text('Added to Google Pay! 💳', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    const Text('Your Tranzfa Visa Virtual Card has been connected to Google Pay.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 13)),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C88C), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                                      child: const Text('Done', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF00C88C), size: 18),
                          label: const Text('Google Pay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D241C),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: Color(0xFF1E4234))),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // CONTROL TOGGLES ROW (Freeze Card & International)
                  Row(
                    children: [
                      // Freeze Card Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Icon(Icons.ac_unit_rounded, color: Color(0xFF00C88C), size: 22),
                                  Switch(
                                    value: _isFrozen,
                                    activeColor: const Color(0xFF00C88C),
                                    onChanged: (val) => setState(() => _isFrozen = val),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Freeze Card',
                                style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Disable all transactions',
                                style: TextStyle(color: Color(0xFF8E9E98), fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      // International Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Icon(Icons.public_rounded, color: Color(0xFF00C88C), size: 22),
                                  Switch(
                                    value: _isInternationalActive,
                                    activeColor: const Color(0xFF00C88C),
                                    onChanged: (val) => setState(() => _isInternationalActive = val),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'International',
                                style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Global spending active',
                                style: TextStyle(color: Color(0xFF8E9E98), fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // CARD MANAGEMENT SECTION HEADER & 4 BUTTONS
                  Text(
                    'CARD MANAGEMENT',
                    style: TextStyle(
                      color: subtextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildManagementOption(
                        icon: Icons.password_rounded,
                        label: 'Reset PIN',
                        isDark: isDark,
                        textColor: textColor,
                      ),
                      _buildManagementOption(
                        icon: Icons.insert_chart_outlined_rounded,
                        label: 'Limits',
                        isDark: isDark,
                        textColor: textColor,
                      ),
                      _buildManagementOption(
                        icon: Icons.credit_card_off_rounded,
                        label: 'Replace',
                        isDark: isDark,
                        textColor: textColor,
                      ),
                      _buildManagementOption(
                        icon: Icons.shield_outlined,
                        label: 'Security',
                        isDark: isDark,
                        textColor: textColor,
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // RECENT ACTIVITY SECTION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'RECENT ACTIVITY',
                        style: TextStyle(
                          color: subtextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'View all',
                        style: TextStyle(
                          color: const Color(0xFF00C88C),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  _buildActivityRow(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Apple Store',
                    subtitle: 'Today, 2:45 PM',
                    amount: '-\$1,299.00',
                    isDark: isDark,
                    cardBgColor: cardBgColor,
                    borderColor: borderColor,
                    textColor: textColor,
                  ),
                  const SizedBox(height: 10),
                  _buildActivityRow(
                    icon: Icons.local_cafe_outlined,
                    title: 'Starbucks Coffee',
                    subtitle: 'Yesterday, 9:12 AM',
                    amount: '-\$6.45',
                    isDark: isDark,
                    cardBgColor: cardBgColor,
                    borderColor: borderColor,
                    textColor: textColor,
                  ),
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
                      isActive: true,
                      subtextColor: subtextColor,
                      onTap: () {},
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

  Widget _buildManagementOption({
    required IconData icon,
    required String label,
    required bool isDark,
    required Color textColor,
  }) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0A261C) : const Color(0xFFE2EDE8),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF00C88C), size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildActivityRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required bool isDark,
    required Color cardBgColor,
    required Color borderColor,
    required Color textColor,
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0A2B20) : const Color(0xFFE2EDE8),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF00C88C), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF8E9E98), fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: Color(0xFFFF5252),
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
