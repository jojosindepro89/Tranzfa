import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../services/banking_service.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'cards_screen.dart';
import 'bills_screen.dart';
import 'ai_assistant_screen.dart';
import 'transaction_history_screen.dart';
import 'kyc_overview_screen.dart';
import 'personal_details_screen.dart';

class ProfileScreen extends StatefulWidget {

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}


class _ProfileScreenState extends State<ProfileScreen> {
  bool _biometricsEnabled = true;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final bankService = Provider.of<BankingService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF060E0A) : const Color(0xFFF6F8F7);
    final cardBg = isDark ? const Color(0xFF0D1E17) : Colors.white;
    final divColor = isDark ? const Color(0xFF1A2E24) : const Color(0xFFECF0EE);
    final textColor = isDark ? Colors.white : const Color(0xFF0B1F17);
    final sub = isDark ? const Color(0xFF7A9489) : const Color(0xFF6B7E76);
    const green = Color(0xFF00C88C);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 18),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          ),
        ),
        title: Text('Profile', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 17)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
              child: Column(
                children: [
                  // AVATAR
                  const SizedBox(height: 16),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: isDark ? const Color(0xFF1A3A2C) : const Color(0xFFCCE9DC),
                        child: Text(
                          bankService.userFullName.isNotEmpty ? bankService.userFullName[0] : 'S',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: green,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: green,
                            shape: BoxShape.circle,
                            border: Border.all(color: bg, width: 2),
                          ),
                          child: const Icon(Icons.edit, color: Colors.black, size: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(bankService.userFullName, style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(color: green.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                        child: const Text('VERIFIED', style: TextStyle(color: green, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(bankService.userTag, style: TextStyle(color: sub, fontSize: 13)),

                  const SizedBox(height: 32),

                  // ACCOUNT SETTINGS
                  _sectionHeader('ACCOUNT', sub),
                  const SizedBox(height: 10),
                  _cardContainer(cardBg, divColor, [
                    _tile(
                      Icons.person_outline_rounded,
                      'Personal Details',
                      bankService.userEmail,
                      textColor,
                      sub,
                      green,
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PersonalDetailsScreen()),
                        );
                      },
                    ),
                    _divider(divColor),

                    _tile(Icons.account_balance_outlined, 'Bank Account Details', 'NUBAN: 0123456789', textColor, sub, green, () {}),
                    _divider(divColor),
                    _tile(
                      Icons.verified_user_outlined,
                      'KYC & Limits',
                      bankService.activeKycTierInfo.badgeText,
                      textColor,
                      sub,
                      green,
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const KycOverviewScreen()),
                        );
                      },
                    ),
                  ]),


                  const SizedBox(height: 24),

                  // APPEARANCE & THEME MODE
                  _sectionHeader('APPEARANCE', sub),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: divColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Icon(Icons.palette_outlined, color: sub, size: 20),
                          const SizedBox(width: 14),
                          Text('Theme Mode', style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold)),
                        ]),
                        Row(children: [
                          _themePill('System', AppThemePreference.system, bankService, textColor, isDark),
                          const SizedBox(width: 6),
                          _themePill('Dark', AppThemePreference.dark, bankService, textColor, isDark),
                          const SizedBox(width: 6),
                          _themePill('Light', AppThemePreference.light, bankService, textColor, isDark),
                        ]),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // SECURITY
                  _sectionHeader('SECURITY', sub),
                  const SizedBox(height: 10),
                  _cardContainer(cardBg, divColor, [
                    _switchTile(Icons.fingerprint_rounded, 'Biometrics / Face ID', _biometricsEnabled, textColor, sub, green, (v) => setState(() => _biometricsEnabled = v)),
                    _divider(divColor),
                    _switchTile(Icons.notifications_outlined, 'Push Notifications', _notificationsEnabled, textColor, sub, green, (v) => setState(() => _notificationsEnabled = v)),
                    _divider(divColor),
                    _tile(Icons.lock_outline_rounded, 'Change Transaction PIN', '••••', textColor, sub, green, () {}),
                  ]),

                  const SizedBox(height: 24),

                  // LOGOUT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD32F2F), width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                      ),
                      onPressed: () {
                        bankService.logout();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout_rounded, color: Color(0xFFD32F2F), size: 18),
                      label: const Text('Log Out', style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // FLOATING BOTTOM NAV BAR
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: _navBar(isDark: isDark, divColor: divColor, sub: sub, context: context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, Color sub) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(color: sub, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  Widget _cardContainer(Color cardBg, Color divColor, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: divColor),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider(Color divColor) => Divider(height: 1, color: divColor, indent: 48);

  Widget _tile(IconData icon, String title, String subtitle, Color textColor, Color sub, Color green, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: sub, size: 20),
      title: Text(title, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(color: sub, fontSize: 12)),
      trailing: Icon(Icons.chevron_right_rounded, color: sub, size: 20),
    );
  }

  Widget _switchTile(IconData icon, String title, bool value, Color textColor, Color sub, Color green, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: green,
      secondary: Icon(icon, color: sub, size: 20),
      title: Text(title, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }

  Widget _themePill(String label, AppThemePreference pref, BankingService service, Color textColor, bool isDark) {
    const green = Color(0xFF00C88C);
    final selected = service.themePreference == pref;
    return GestureDetector(
      onTap: () => service.setThemePreference(pref),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? green : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? green : Colors.transparent),
        ),
        child: Text(label, style: TextStyle(
          color: selected ? Colors.black : textColor,
          fontSize: 12,
          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
        )),
      ),
    );
  }

  Widget _navBar({required bool isDark, required Color divColor, required Color sub, required BuildContext context}) {
    const green = Color(0xFF00C88C);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1713).withOpacity(0.97) : Colors.white.withOpacity(0.97),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: divColor, width: 1.2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Iconsax.home_2, 'Home', false, sub, green, () =>
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const DashboardScreen()))),
          _navItem(Iconsax.card, 'Cards', false, sub, green, () =>
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const CardsScreen()))),
          _navItem(Iconsax.receipt_text, 'Bills', false, sub, green, () =>
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BillsScreen()))),
          _navItem(Iconsax.chart_21, 'Insights', false, sub, green, () =>
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AiAssistantScreen()))),
          _navItem(Iconsax.user, 'Profile', true, sub, green, () {}),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active, Color sub, Color green, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: active ? green : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: active ? Colors.black : sub, size: 20),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: active ? green : sub, fontSize: 10, fontWeight: active ? FontWeight.bold : FontWeight.w500)),
      ]),
    );
  }
}
