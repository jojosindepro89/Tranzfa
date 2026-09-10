import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'bills_screen.dart';
import 'ai_assistant_screen.dart';
import 'transaction_history_screen.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  bool _isFrozen = false;
  bool _isInternationalActive = true;
  bool _showDetails = false;

  //  LIMITS STATE 
  double _dailyLimit = 500000;
  double _monthlyLimit = 2000000;
  double _atmLimit = 150000;
  double _onlineLimit = 300000;

  //  SECURITY STATE 
  bool _biometricEnabled = true;
  bool _onlineTxnEnabled = true;
  bool _atmEnabled = true;
  bool _contactlessEnabled = true;
  bool _twoFAEnabled = false;

  //  COLOUR HELPERS 
  static const _green = Color(0xFF00C88C);
  static const _darkBg = Color(0xFF0B1713);
  static const _cardDark = Color(0xFF0F1C17);

  String _formatAmount(double v) {
    if (v >= 1000000) return '₦${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '₦${(v / 1000).toStringAsFixed(0)}K';
    return '₦${v.toStringAsFixed(0)}';
  }

  // 
  // RESET PIN MODAL
  // 
  void _showResetPinModal() {
    final List<String> newPin = [];
    final List<String> confirmPin = [];
    bool isConfirmStep = false;
    bool pinError = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModal) {
          final List<String> activePin = isConfirmStep ? confirmPin : newPin;
          final title = isConfirmStep ? 'Confirm New PIN' : 'Enter New PIN';
          final subtitle = isConfirmStep
              ? 'Re-enter your 4-digit PIN to confirm'
              : 'Choose a secure 4-digit PIN for your card';

          void onKey(String digit) {
            if (activePin.length < 4) {
              setModal(() {
                activePin.add(digit);
                pinError = false;
              });
              if (activePin.length == 4) {
                if (!isConfirmStep) {
                  Future.delayed(const Duration(milliseconds: 200), () {
                    setModal(() => isConfirmStep = true);
                  });
                } else {
                  // Validate
                  Future.delayed(const Duration(milliseconds: 200), () {
                    if (newPin.join() == confirmPin.join()) {
                      Navigator.pop(ctx);
                      _showSuccessSnack('PIN reset successfully! ');
                    } else {
                      setModal(() {
                        confirmPin.clear();
                        pinError = true;
                      });
                    }
                  });
                }
              }
            }
          }

          void onDelete() {
            if (activePin.isNotEmpty) {
              setModal(() {
                activePin.removeLast();
                pinError = false;
              });
            }
          }

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: _darkBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(top: BorderSide(color: _green, width: 2)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 13), textAlign: TextAlign.center),
                  const SizedBox(height: 28),

                  // PIN Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) {
                      final filled = i < activePin.length;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: filled ? 18 : 16,
                        height: filled ? 18 : 16,
                        decoration: BoxDecoration(
                          color: pinError
                              ? const Color(0xFFFF5252)
                              : (filled ? _green : Colors.white24),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),

                  if (pinError) ...[
                    const SizedBox(height: 12),
                    const Text('PINs do not match. Try again.',
                        style: TextStyle(color: Color(0xFFFF5252), fontSize: 13)),
                  ],

                  const SizedBox(height: 28),

                  // Keypad
                  for (var row in [
                    ['1', '2', '3'],
                    ['4', '5', '6'],
                    ['7', '8', '9'],
                    ['', '0', ''],
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: row.map((k) {
                          if (k.isEmpty) return const SizedBox(width: 80, height: 56);
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              if (k == '') {
                                onDelete();
                              } else {
                                onKey(k);
                              }
                            },
                            child: Container(
                              width: 80,
                              height: 56,
                              decoration: BoxDecoration(
                                color: k == ''
                                    ? Colors.white10
                                    : const Color(0xFF14241E),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white10),
                              ),
                              alignment: Alignment.center,
                              child: k == ''
                                  ? const Icon(Iconsax.back_square, color: Colors.white70, size: 22)
                                  : Text(k, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  // Step indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(2, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: (isConfirmStep ? i == 1 : i == 0) ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: (isConfirmStep ? i == 1 : i == 0) ? _green : Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  // 
  // SPENDING LIMITS MODAL
  // 
  void _showLimitsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModal) {
          Widget limitRow(String label, double value, double max, Function(double) onChanged) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                      Text(
                        _formatAmount(value),
                        style: const TextStyle(color: _green, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: _green,
                      inactiveTrackColor: Colors.white10,
                      thumbColor: _green,
                      overlayColor: _green.withOpacity(0.15),
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                    ),
                    child: Slider(
                      value: value,
                      min: 0,
                      max: max,
                      divisions: 20,
                      onChanged: (v) => setModal(() => onChanged(v)),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₦0', style: TextStyle(color: Colors.white38, fontSize: 11)),
                      Text(_formatAmount(max), style: TextStyle(color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            );
          }

          return DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.6,
            maxChildSize: 0.95,
            builder: (_, sc) => Container(
              decoration: const BoxDecoration(
                color: _darkBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(top: BorderSide(color: _green, width: 2)),
              ),
              child: SingleChildScrollView(
                controller: sc,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 20),

                    const Text('Spending Limits', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    const Text('Set limits for each spend category', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 28),

                    limitRow('Daily Limit', _dailyLimit, 1000000, (v) => _dailyLimit = v),
                    limitRow('Monthly Limit', _monthlyLimit, 5000000, (v) => _monthlyLimit = v),
                    limitRow('ATM Withdrawal', _atmLimit, 500000, (v) => _atmLimit = v),
                    limitRow('Online Purchases', _onlineLimit, 1000000, (v) => _onlineLimit = v),

                    // Info note
                    Text(
                      'Limits reset at 12:00 AM daily / 1st of each month.',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {}); // persist to parent state
                          Navigator.pop(ctx);
                          _showSuccessSnack('Spending limits updated ');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                        ),
                        child: const Text('Save Limits', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  // 
  // REPLACE CARD MODAL
  // 
  void _showReplaceCardModal() {
    int selectedReason = -1;
    bool confirmed = false;

    const reasons = [
      {'icon': '', 'title': 'Card Lost', 'sub': 'I can\'t find my card'},
      {'icon': '', 'title': 'Card Stolen', 'sub': 'My card was stolen'},
      {'icon': '', 'title': 'Card Damaged', 'sub': 'My card is physically damaged'},
      {'icon': '', 'title': 'Suspicious Activity', 'sub': 'Unrecognised transactions'},
      {'icon': '', 'title': 'Upgrade Card', 'sub': 'Get the latest card design'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModal) {
          return DraggableScrollableSheet(
            initialChildSize: confirmed ? 0.55 : 0.82,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, sc) => Container(
              decoration: const BoxDecoration(
                color: _darkBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(top: BorderSide(color: Color(0xFFFF5252), width: 2)),
              ),
              child: SingleChildScrollView(
                controller: sc,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: confirmed
                    //  Confirmation screen 
                    ? Column(
                        children: [
                          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
                          const SizedBox(height: 24),
                          const Text('Replace Your Card?', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          const Text(
                            'Your current card will be permanently blocked. A new card will be delivered within 5–7 business days to your registered address.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.5),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: const Color(0xFF14241E), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                              Text('Delivery Address', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w600)),
                              SizedBox(height: 4),
                              Text('45 Marina Street, Lagos Island, Lagos State', style: TextStyle(color: Colors.white, fontSize: 13)),
                            ]),
                          ),
                          const SizedBox(height: 24),
                          Row(children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => setModal(() => confirmed = false),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white24),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                                ),
                                child: const Text('Go Back', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  _showSuccessSnack('Card replacement requested!  Arrives in 5–7 days.');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF5252),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                                ),
                                child: const Text('Confirm Replace', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ]),
                        ],
                      )
                    //  Reason selection screen 
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
                          const SizedBox(height: 20),
                          const Text('Replace Card', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          const Text('Select a reason below', style: TextStyle(color: Colors.white54, fontSize: 12)),
                          const SizedBox(height: 24),
                          ...List.generate(reasons.length, (i) {
                            final r = reasons[i];
                            final selected = selectedReason == i;
                            return GestureDetector(
                              onTap: () => setModal(() => selectedReason = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: selected ? const Color(0xFF1A0B0B) : const Color(0xFF14241E),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: selected ? const Color(0xFFFF5252) : Colors.white10, width: selected ? 1.5 : 1),
                                ),
                                child: Row(children: [
                                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(r['title']!, style: TextStyle(color: selected ? const Color(0xFFFF5252) : Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    Text(r['sub']!, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                  ])),
                                  if (selected) const Icon(Icons.check, color: Color(0xFFFF5252), size: 18),
                                ]),
                              ),
                            );
                          }),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: selectedReason >= 0
                                  ? () => setModal(() => confirmed = true)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedReason >= 0 ? const Color(0xFFFF5252) : Colors.white12,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                              ),
                              child: Text(
                                'Continue',
                                style: TextStyle(
                                  color: selectedReason >= 0 ? Colors.white : Colors.white38,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        });
      },
    );
  }

  // 
  // SECURITY MODAL
  // 
  void _showSecurityModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModal) {
          Widget secToggle({
            required IconData icon,
            required Color iconColor,
            required Color iconBg,
            required String title,
            required String subtitle,
            required bool value,
            required Function(bool) onChanged,
          }) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ])),
                Switch(
                  value: value,
                  activeColor: _green,
                  inactiveThumbColor: Colors.white38,
                  inactiveTrackColor: Colors.white10,
                  onChanged: (v) {
                    setModal(() => onChanged(v));
                    setState(() => onChanged(v));
                  },
                ),
              ]),
            );
          }

          return DraggableScrollableSheet(
            initialChildSize: 0.88,
            minChildSize: 0.6,
            maxChildSize: 0.96,
            builder: (_, sc) => Container(
              decoration: const BoxDecoration(
                color: _darkBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(top: BorderSide(color: _green, width: 2)),
              ),
              child: SingleChildScrollView(
                controller: sc,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 20),
                    const Text('Card Security', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    const Text('Manage your card security preferences', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 24),

                    // Security score bar
                    _buildSecurityScore(),
                    const SizedBox(height: 24),

                    const Text('AUTHENTICATION', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 12),

                    secToggle(icon: Iconsax.finger_cricle, iconColor: _green, iconBg: _green.withOpacity(0.15),
                      title: 'Biometric Auth', subtitle: 'Use fingerprint or Face ID to confirm payments',
                      value: _biometricEnabled, onChanged: (v) => _biometricEnabled = v),
                    secToggle(icon: Iconsax.lock_1, iconColor: _green, iconBg: _green.withOpacity(0.15),
                      title: 'Two-Factor Auth (2FA)', subtitle: 'Require OTP for all card transactions',
                      value: _twoFAEnabled, onChanged: (v) => _twoFAEnabled = v),

                    const SizedBox(height: 8),
                    const Text('Transaction Controls', style: TextStyle(color: Colors.white38, fontSize: 12)),
                    const SizedBox(height: 12),

                    secToggle(icon: Iconsax.buy_crypto, iconColor: _green, iconBg: _green.withOpacity(0.15),
                      title: 'Online Transactions', subtitle: 'Allow e-commerce payments',
                      value: _onlineTxnEnabled, onChanged: (v) => _onlineTxnEnabled = v),
                    secToggle(icon: Iconsax.money_recive, iconColor: _green, iconBg: _green.withOpacity(0.15),
                      title: 'ATM Withdrawals', subtitle: 'Allow cash withdrawals at ATMs',
                      value: _atmEnabled, onChanged: (v) => _atmEnabled = v),
                    secToggle(icon: Iconsax.wifi, iconColor: _green, iconBg: _green.withOpacity(0.15),
                      title: 'Contactless Payments', subtitle: 'Enable NFC tap-to-pay at terminals',
                      value: _contactlessEnabled, onChanged: (v) => _contactlessEnabled = v),

                    const SizedBox(height: 20),

                    // Report fraud CTA
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _showSuccessSnack('Fraud report submitted. Our team will contact you shortly.');
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(children: const [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Report Fraud / Dispute', style: TextStyle(color: Color(0xFFFF5252), fontSize: 15, fontWeight: FontWeight.w600)),
                            SizedBox(height: 2),
                            Text('Report suspicious activity on your card', style: TextStyle(color: Colors.white54, fontSize: 12)),
                          ])),
                          Icon(Icons.chevron_right, color: Color(0xFFFF5252), size: 20),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showSuccessSnack('Security settings saved ');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                        ),
                        child: const Text('Save Settings', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildSecurityScore() {
    int score = 0;
    if (_biometricEnabled) score += 25;
    if (_twoFAEnabled) score += 35;
    if (_onlineTxnEnabled) score -= 5;
    if (!_atmEnabled) score += 10;
    if (!_contactlessEnabled) score += 5;
    score = score.clamp(20, 95);

    Color scoreColor;
    String scoreLabel;
    if (score >= 80) { scoreColor = _green; scoreLabel = 'Excellent'; }
    else if (score >= 60) { scoreColor = const Color(0xFFE5B800); scoreLabel = 'Good'; }
    else { scoreColor = const Color(0xFFFF5252); scoreLabel = 'Needs Improvement'; }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14241E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _green.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Security Score', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
          Text('$score/100 • $scoreLabel', style: TextStyle(color: scoreColor, fontSize: 13, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
            minHeight: 8,
          ),
        ),
      ]),
    );
  }

  void _showSuccessSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: const Color(0xFF14291F),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ));
  }

  // 
  // BUILD
  // 
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
        title: Text('Your Cards', style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0B1F17) : const Color(0xFFE2EDE8),
              shape: BoxShape.circle,
              border: Border.all(color: borderColor),
            ),
            child: Icon(Iconsax.add, color: textColor, size: 22),
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

                  //  MAIN CARD PREVIEW 
                  Container(
                    width: double.infinity,
                    height: 210,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _isFrozen
                            ? [const Color(0xFF0D1A2A), const Color(0xFF081020)]
                            : (isDark
                                ? [const Color(0xFF0F3024), const Color(0xFF071F17)]
                                : [const Color(0xFF0C4231), const Color(0xFF06291E)]),
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: _isFrozen ? const Color(0xFF1E3A5F) : const Color(0xFF16523D),
                        width: 1.2,
                      ),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8))],
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                                  Text('VIRTUAL CARD', style: TextStyle(color: Color(0xFF8BA398), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                                  SizedBox(height: 2),
                                  Text('Tranzfa Premium', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                ]),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                                  child: const Text('VISA', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: 1.2)),
                                ),
                              ],
                            ),
                            Row(children: [
                              Text(
                                _showDetails ? '4920   8819   3014   ' : '• • • •   • • • •   • • • •   ',
                                style: const TextStyle(color: Colors.white70, fontSize: 18, letterSpacing: 2, fontWeight: FontWeight.bold),
                              ),
                              const Text('8 8 4 2', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2)),
                            ]),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                                    Text('EXPIRY', style: TextStyle(color: Color(0xFF6E857B), fontSize: 9, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 2),
                                    Text('12/28', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                  ]),
                                  const SizedBox(width: 24),
                                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    const Text('CVV', style: TextStyle(color: Color(0xFF6E857B), fontSize: 9, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 2),
                                    Text(_showDetails ? '849' : '•••', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                  ]),
                                ]),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                                  child: const Icon(Iconsax.wifi, color: Colors.white, size: 18),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Frozen overlay
                        if (_isFrozen)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Iconsax.pause_circle, color: Colors.white70, size: 32),
                                    SizedBox(height: 8),
                                    Text('CARD FROZEN', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  //  VIEW CARD DETAILS BUTTON 
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => setState(() => _showDetails = !_showDetails),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF02472E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_showDetails ? Iconsax.eye_slash : Iconsax.eye, size: 20),
                          const SizedBox(width: 8),
                          Text(_showDetails ? 'Hide Card Details' : 'View Card Details', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  //  CASHBACK CHIP 
                  Row(children: [
                    const Icon(Iconsax.medal_star, color: Color(0xFFE5B800), size: 16),
                    const SizedBox(width: 6),
                    Text('2.5% USDC cashback active', style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF2B4239), fontSize: 13)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: _green.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                      child: const Text('\$1,250.80 earned', style: TextStyle(color: _green, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ]),

                  const SizedBox(height: 20),

                  //  APPLE/GOOGLE PAY 
                  Row(children: [
                    Expanded(child: OutlinedButton.icon(
                      onPressed: () => _showWalletModal(isApple: true),
                      icon: Icon(Icons.apple, color: isDark ? Colors.white : Colors.black, size: 18),
                      label: Text('Apple Wallet', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: isDark ? Colors.white24 : Colors.black26),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: OutlinedButton.icon(
                      onPressed: () => _showWalletModal(isApple: false),
                      icon: const Icon(Iconsax.wallet_3, color: _green, size: 16),
                      label: const Text('Google Pay', style: TextStyle(color: _green, fontSize: 13, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: _green, width: 0.8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    )),
                  ]),

                  const SizedBox(height: 20),

                  //  FREEZE / INTERNATIONAL TOGGLES 
                  Row(children: [
                    Expanded(child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: _isFrozen ? const Color(0xFF60A5FA).withOpacity(0.4) : borderColor),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Icon(Iconsax.pause_circle, color: _isFrozen ? const Color(0xFF60A5FA) : _green, size: 22),
                          Switch(value: _isFrozen, activeColor: const Color(0xFF60A5FA), onChanged: (val) => setState(() => _isFrozen = val)),
                        ]),
                        const SizedBox(height: 8),
                        Text('Freeze Card', style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(_isFrozen ? 'Card is frozen' : 'Disable all transactions', style: const TextStyle(color: Color(0xFF8E9E98), fontSize: 11)),
                      ]),
                    )),
                    const SizedBox(width: 14),
                    Expanded(child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const Icon(Iconsax.global, color: _green, size: 22),
                          Switch(value: _isInternationalActive, activeColor: _green, onChanged: (val) => setState(() => _isInternationalActive = val)),
                        ]),
                        const SizedBox(height: 8),
                        Text('International', style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(_isInternationalActive ? 'Global spending active' : 'Local only', style: const TextStyle(color: Color(0xFF8E9E98), fontSize: 11)),
                      ]),
                    )),
                  ]),

                  const SizedBox(height: 24),

                  //  CARD MANAGEMENT SECTION 
                  Text('Manage', style: TextStyle(color: subtextColor, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildManagementOption(label: 'Reset PIN', isDark: isDark, textColor: textColor, onTap: _showResetPinModal),
                      _buildManagementOption(label: 'Limits', isDark: isDark, textColor: textColor, onTap: _showLimitsModal),
                      _buildManagementOption(label: 'Replace', isDark: isDark, textColor: textColor, onTap: _showReplaceCardModal, isDestructive: true),
                      _buildManagementOption(label: 'Security', isDark: isDark, textColor: textColor, onTap: _showSecurityModal),
                    ],
                  ),

                  const SizedBox(height: 24),

                  //  RECENT ACTIVITY 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent activity', style: TextStyle(color: subtextColor, fontSize: 13, fontWeight: FontWeight.w600)),
                      const Text('View all', style: TextStyle(color: _green, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _buildActivityRow(
                    icon: Iconsax.bag_2,
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
                    icon: Iconsax.coffee,
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

            //  FLOATING BOTTOM NAV 
            Positioned(
              left: 20, right: 20, bottom: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0B1713).withOpacity(0.95) : Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(color: borderColor, width: 1.2),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(icon: Iconsax.home_2, activeIcon: Iconsax.home_2, label: 'Home', isActive: false, subtextColor: subtextColor,
                      onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const DashboardScreen()))),
                    _buildNavItem(icon: Iconsax.card, activeIcon: Iconsax.card, label: 'Cards', isActive: true, subtextColor: subtextColor, onTap: () {}),
                    _buildNavItem(icon: Iconsax.receipt_text, activeIcon: Iconsax.receipt_text, label: 'Bills', isActive: false, subtextColor: subtextColor,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BillsScreen()))),
                    _buildNavItem(icon: Iconsax.chart_21, activeIcon: Iconsax.chart_21, label: 'Insights', isActive: false, subtextColor: subtextColor,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AiAssistantScreen()))),
                    _buildNavItem(icon: Iconsax.user, activeIcon: Iconsax.user, label: 'Profile', isActive: false, subtextColor: subtextColor,
                      onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ProfileScreen()))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWalletModal({required bool isApple}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B1713),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isApple ? Icons.apple : Iconsax.wallet_3, color: isApple ? Colors.white : _green, size: 48),
            const SizedBox(height: 12),
            Text(isApple ? 'Added to Apple Wallet! ' : 'Added to Google Pay! ',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(isApple
                ? 'Your Tranzfa Visa Virtual Card is ready for contactless tap-to-pay globally.'
                : 'Your Tranzfa Visa Virtual Card has been connected to Google Pay.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: _green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Text('Done', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementOption({
    required String label,
    required bool isDark,
    required Color textColor,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? const Color(0xFFFF5252) : textColor;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0D201A) : const Color(0xFFEEF5F1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
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
      decoration: BoxDecoration(color: cardBgColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor)),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: isDark ? const Color(0xFF0A2B20) : const Color(0xFFE2EDE8), shape: BoxShape.circle),
          child: Icon(icon, color: _green, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(color: Color(0xFF8E9E98), fontSize: 12)),
        ])),
        Text(amount, style: const TextStyle(color: Color(0xFFFF5252), fontSize: 15, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(isActive ? 9 : 4),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF0E4735) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(isActive ? activeIcon : icon, color: isActive ? _green : subtextColor, size: 22),
          ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(color: isActive ? _green : subtextColor, fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}
