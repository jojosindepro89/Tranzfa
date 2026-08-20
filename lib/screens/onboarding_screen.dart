import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/banking_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/speed_gauge_painter.dart';
import '../widgets/security_badge_footer.dart';
import '../widgets/login_register_modal.dart';
import 'dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'titleLine1': 'Move Money at the',
      'titleGold': 'Speed of Life',
      'subtitle': 'Experience lightning-fast global transfers with institutional-grade security and elite wealth tools.',
    },
    {
      'titleLine1': 'Institutional-Grade',
      'titleGold': 'Security & Vaults',
      'subtitle': 'ISO 27001 certified encryption, multi-sig vaults, and real-time fraud monitoring.',
    },
    {
      'titleLine1': 'Multi-Currency &',
      'titleGold': 'Stablecoin Engine',
      'subtitle': 'Hold 40+ fiat currencies and instant stablecoin auto-converts with zero hidden fees.',
    },
  ];

  void _onSkip() {
    // Navigate straight to Dashboard
    final bankService = Provider.of<BankingService>(context, listen: false);
    bankService.login("Alex Sterling", "alex@tranzfa.io");
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  void _openAuthModal({required bool isLogin}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LoginRegisterModal(isLoginInitial: isLogin),
    ).then((_) {
      final bankService = Provider.of<BankingService>(context, listen: false);
      if (bankService.isLoggedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.obsidianBg,
      body: SafeArea(
        child: Column(
          children: [
            // TOP HEADER: Logo, Brand & Skip Button (Matches Screenshot)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo Icon + Tranzfa Brand
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF032B1E),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.emeraldAccent, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.emeraldAccent.withOpacity(0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.diamond,
                          color: AppTheme.goldPrimary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Tranzfa',
                        style: TextStyle(
                          color: AppTheme.goldPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  // Skip Button
                  GestureDetector(
                    onTap: _onSkip,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: AppTheme.textMuted.withOpacity(0.8),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // MAIN CONTENT BODY
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // CENTER CARD: Glassmorphic Container with Speed Gauge (Matches Screenshot)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: GlassCard(
                        borderRadius: 28,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        borderColor: AppTheme.emeraldAccent.withOpacity(0.2),
                        backgroundColor: const Color(0xFF092017).withOpacity(0.7),
                        child: Center(
                          child: SpeedGaugeWidget(
                            value: 0.78 + (_currentPage * 0.10), // Animated gauge based on slide
                            width: 240,
                            height: 170,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // CAROUSEL PAGEVIEW FOR HEADLINES & SUBTITLE
                    SizedBox(
                      height: 140,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemCount: _slides.length,
                        itemBuilder: (context, index) {
                          final slide = _slides[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Headline Line 1
                                Text(
                                  slide['titleLine1']!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                // Headline Line 2 (Glowing Gold)
                                Text(
                                  slide['titleGold']!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppTheme.goldPrimary,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                    shadows: [
                                      Shadow(
                                        color: Color(0x66F3B728),
                                        blurRadius: 16,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Subtitle Copy
                                Text(
                                  slide['subtitle']!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppTheme.textSecondary.withOpacity(0.85),
                                    fontSize: 13,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 8),

                    // CAROUSEL INDICATOR DOTS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slides.length, (index) {
                        final isActive = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 32 : 8,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isActive ? AppTheme.goldPrimary : AppTheme.emeraldDark.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: AppTheme.goldPrimary.withOpacity(0.6),
                                      blurRadius: 6,
                                    ),
                                  ]
                                : null,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // BOTTOM ACTION SECTION (Matches Screenshot)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  // Create Account Button (Filled Emerald Green Pill)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _openAuthModal(isLogin: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF025839),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 4,
                        shadowColor: AppTheme.emeraldAccent.withOpacity(0.4),
                      ),
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Already have an account? Log In
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: AppTheme.textSecondary.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _openAuthModal(isLogin: true),
                        child: const Text(
                          'Log In',
                          style: TextStyle(
                            color: AppTheme.goldPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // TRUST BADGES FOOTER (Matches Screenshot ISO 27001 CERTIFIED)
            const SecurityBadgeFooter(),
          ],
        ),
      ),
    );
  }
}
