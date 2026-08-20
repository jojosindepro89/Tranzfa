import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/banking_service.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'ai_assistant_screen.dart';
import 'cards_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _biometricsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final bankService = Provider.of<BankingService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF040E0A) : const Color(0xFFF4F7F5);
    final cardBgColor = isDark ? const Color(0xFF0B1F17) : Colors.white;
    final borderColor = isDark ? const Color(0xFF143024) : const Color(0xFFE0E8E4);
    final textColor = isDark ? Colors.white : const Color(0xFF0B1F17);
    final subtextColor = isDark ? const Color(0xFF8E9E98) : const Color(0xFF5A7067);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          },
        ),
        title: Text(
          'Settings',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: textColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
              child: Column(
                children: [
                  // USER AVATAR & NAME HEADER
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF00C88C), width: 2.5),
                              ),
                              child: CircleAvatar(
                                radius: 46,
                                backgroundColor: isDark ? const Color(0xFF1E3A2F) : const Color(0xFFC0EADA),
                                child: Icon(Icons.person, size: 54, color: isDark ? Colors.white : const Color(0xFF0B1F17)),
                              ),
                            ),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00C88C),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: bgColor, width: 2),
                                ),
                                child: const Icon(Icons.edit, color: Colors.black, size: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              bankService.userFullName,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00C88C).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF00C88C).withOpacity(0.4)),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.check_circle, color: Color(0xFF00C88C), size: 12),
                                  SizedBox(width: 4),
                                  Text(
                                    'VERIFIED',
                                    style: TextStyle(
                                      color: Color(0xFF00C88C),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${bankService.userTag} • ID: 98234102',
                          style: TextStyle(color: subtextColor, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // SECTION 1: THEME & DISPLAY PREFERENCE (DARK / LIGHT / SYSTEM)
                  _buildSectionHeader('THEME & DISPLAY', subtextColor),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'App Appearance',
                          style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Select Dark, Light, or follow your OS System theme.',
                          style: TextStyle(color: subtextColor, fontSize: 12),
                        ),
                        const SizedBox(height: 16),

                        // Segmented Control Row
                        Row(
                          children: [
                            _buildThemeOption(
                              label: 'Dark',
                              icon: Icons.dark_mode_outlined,
                              pref: AppThemePreference.dark,
                              currentPref: bankService.themePreference,
                              onSelect: () => bankService.setThemePreference(AppThemePreference.dark),
                              isDark: isDark,
                            ),
                            const SizedBox(width: 8),
                            _buildThemeOption(
                              label: 'Light',
                              icon: Icons.light_mode_outlined,
                              pref: AppThemePreference.light,
                              currentPref: bankService.themePreference,
                              onSelect: () => bankService.setThemePreference(AppThemePreference.light),
                              isDark: isDark,
                            ),
                            const SizedBox(width: 8),
                            _buildThemeOption(
                              label: 'System',
                              icon: Icons.settings_brightness_outlined,
                              pref: AppThemePreference.system,
                              currentPref: bankService.themePreference,
                              onSelect: () => bankService.setThemePreference(AppThemePreference.system),
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // SECTION 2: SECURITY & PRIVACY
                  _buildSectionHeader('SECURITY & PRIVACY', subtextColor),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        _buildSettingTile(
                          icon: Icons.lock_outline_rounded,
                          title: 'Change Password',
                          subtitle: 'Last updated 3 months ago',
                          hasChevron: true,
                          isDark: isDark,
                          textColor: textColor,
                          subtextColor: subtextColor,
                        ),
                        Divider(color: borderColor, height: 1),
                        _buildSettingTile(
                          icon: Icons.fingerprint_rounded,
                          title: 'Biometric Login',
                          subtitle: 'FaceID or Fingerprint',
                          isDark: isDark,
                          textColor: textColor,
                          subtextColor: subtextColor,
                          trailing: Switch(
                            value: _biometricsEnabled,
                            activeColor: const Color(0xFF00C88C),
                            onChanged: (val) => setState(() => _biometricsEnabled = val),
                          ),
                        ),
                        Divider(color: borderColor, height: 1),
                        _buildSettingTile(
                          icon: Icons.security_rounded,
                          title: 'Two-Factor Auth',
                          subtitle: 'Enabled (SMS & Email)',
                          hasChevron: true,
                          isDark: isDark,
                          textColor: textColor,
                          subtextColor: subtextColor,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // SECTION 3: APP PREFERENCES
                  _buildSectionHeader('APP PREFERENCES', subtextColor),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        _buildSettingTile(
                          icon: Icons.translate_rounded,
                          title: 'Language',
                          subtitle: 'English (US)',
                          hasChevron: true,
                          isDark: isDark,
                          textColor: textColor,
                          subtextColor: subtextColor,
                        ),
                        Divider(color: borderColor, height: 1),
                        _buildSettingTile(
                          icon: Icons.notifications_none_rounded,
                          title: 'Notifications',
                          subtitle: 'Push, Email, SMS',
                          hasChevron: true,
                          isDark: isDark,
                          textColor: textColor,
                          subtextColor: subtextColor,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // LOG OUT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () {
                        bankService.logout();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE53935), width: 1.2),
                        backgroundColor: isDark ? const Color(0xFF0F1714) : const Color(0xFFFFEBEE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.logout_rounded, color: Color(0xFFFF4D4D), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Log Out',
                            style: TextStyle(
                              color: Color(0xFFFF4D4D),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // BOTTOM NAVIGATION BAR
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
                      isActive: true,
                      subtextColor: subtextColor,
                      onTap: () {},
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

  Widget _buildThemeOption({
    required String label,
    required IconData icon,
    required AppThemePreference pref,
    required AppThemePreference currentPref,
    required VoidCallback onSelect,
    required bool isDark,
  }) {
    final isSelected = pref == currentPref;

    return Expanded(
      child: GestureDetector(
        onTap: onSelect,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF00C88C)
                : (isDark ? const Color(0xFF07241A) : const Color(0xFFE2EDE8)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF00C88C) : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.black : (isDark ? Colors.white70 : const Color(0xFF0B1F17)),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black : (isDark ? Colors.white : const Color(0xFF0B1F17)),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color subtextColor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          color: subtextColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required Color textColor,
    required Color subtextColor,
    bool hasChevron = false,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF07241A) : const Color(0xFFE2EDE8),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.security_outlined, color: Color(0xFF00C88C), size: 20),
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
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: subtextColor, fontSize: 12),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
          if (hasChevron)
            Icon(Icons.chevron_right_rounded, color: subtextColor, size: 22),
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
