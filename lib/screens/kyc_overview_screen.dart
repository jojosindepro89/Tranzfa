import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../models/banking_models.dart';
import '../services/banking_service.dart';
import 'kyc_verification_screen.dart';

class KycOverviewScreen extends StatefulWidget {
  const KycOverviewScreen({super.key});

  @override
  State<KycOverviewScreen> createState() => _KycOverviewScreenState();
}

class _KycOverviewScreenState extends State<KycOverviewScreen> {
  String _formatCurrency(double amount) {
    if (amount < 0) return 'Unlimited';
    final intVal = amount.toInt();
    return '₦${intVal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    final bankService = Provider.of<BankingService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF060E0A) : const Color(0xFFF6F8F7);
    final cardBg = isDark ? const Color(0xFF0D1E17) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0B1F17);
    final sub = isDark ? const Color(0xFF7A9489) : const Color(0xFF6B7E76);
    final divColor = isDark ? const Color(0xFF183327) : const Color(0xFFE2EDE8);
    const green = Color(0xFF00C88C);

    final activeTierInfo = bankService.activeKycTierInfo;
    final double todaySpent = bankService.todaySpentNgn;
    final double dailyLimit = activeTierInfo.dailyLimit;
    final double progress = dailyLimit > 0 ? (todaySpent / dailyLimit).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'KYC & Account Limits',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── CURRENT TIER HERO CARD ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0xFF073827), const Color(0xFF032419)]
                        : [const Color(0xFF044D35), const Color(0xFF022B1E)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFF0E6347), width: 1.2),
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
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: green.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.shield_outlined, color: green, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'CURRENT VERIFICATION',
                                  style: TextStyle(
                                    color: Color(0xFFB0C4BC),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  activeTierInfo.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'VERIFIED',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // DAILY LIMIT USAGE PROGRESS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Daily Spent Limit Used',
                          style: TextStyle(color: Color(0xFFB0C4BC), fontSize: 13),
                        ),
                        Text(
                          '${_formatCurrency(todaySpent)} / ${_formatCurrency(dailyLimit)}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: const Color(0xFF082E21),
                        valueColor: const AlwaysStoppedAnimation<Color>(green),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // LIMIT SUMMARY CHIPS
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Single Transfer', style: TextStyle(color: Color(0xFF8BAAA0), fontSize: 11)),
                                const SizedBox(height: 4),
                                Text(_formatCurrency(activeTierInfo.singleLimit), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Max Balance', style: TextStyle(color: Color(0xFF8BAAA0), fontSize: 11)),
                                const SizedBox(height: 4),
                                Text(_formatCurrency(activeTierInfo.maxBalance), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'ACCOUNT TIERS & LIMITS',
                style: TextStyle(color: sub, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),

              const SizedBox(height: 14),

              // LIST OF TIER CARDS
              ...bankService.allKycTiers.map((tier) {
                return _buildTierCard(
                  tier: tier,
                  activeTier: bankService.currentKycTier,
                  cardBg: cardBg,
                  textColor: textColor,
                  sub: sub,
                  divColor: divColor,
                  green: green,
                  onUpgrade: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => KycVerificationScreen(targetTier: tier.level),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTierCard({
    required KycTierInfo tier,
    required KycTierLevel activeTier,
    required Color cardBg,
    required Color textColor,
    required Color sub,
    required Color divColor,
    required Color green,
    required VoidCallback onUpgrade,
  }) {
    final bool isCurrent = tier.level == activeTier;
    final bool isLower = tier.level.index < activeTier.index;
    final bool canUpgrade = tier.level.index > activeTier.index;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCurrent ? green : divColor,
          width: isCurrent ? 1.8 : 1.0,
        ),
        boxShadow: isCurrent
            ? [BoxShadow(color: green.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 6))]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TIER TITLE & BADGE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isCurrent ? green.withOpacity(0.15) : divColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      tier.level == KycTierLevel.tier3
                          ? Iconsax.crown
                          : tier.level == KycTierLevel.tier2
                              ? Iconsax.security_safe
                              : Iconsax.user_tick,
                      color: isCurrent ? green : sub,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tier.title,
                        style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(tier.badgeText, style: TextStyle(color: sub, fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),

              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: green, width: 1),
                  ),
                  child: Text(
                    'ACTIVE TIER',
                    style: TextStyle(color: green, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                )
              else if (isLower)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: sub.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'UNLOCKED',
                    style: TextStyle(color: sub, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),
          Text(tier.description, style: TextStyle(color: sub, fontSize: 13, height: 1.35)),

          const SizedBox(height: 16),
          Divider(height: 1, color: divColor),
          const SizedBox(height: 16),

          // LIMITS GRID
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _limitStat('Daily Limit', _formatCurrency(tier.dailyLimit), textColor, sub),
              _limitStat('Single Transfer', _formatCurrency(tier.singleLimit), textColor, sub),
              _limitStat('Max Balance', _formatCurrency(tier.maxBalance), textColor, sub),
            ],
          ),

          const SizedBox(height: 16),

          // PERKS LIST
          Text('UNLOCKED FEATURES & PERKS', style: TextStyle(color: sub, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          const SizedBox(height: 8),
          ...tier.perks.map((perk) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: green, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(perk, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w500))),
                  ],
                ),
              )),

          const SizedBox(height: 12),

          // REQUIREMENTS LIST
          Text('REQUIREMENTS', style: TextStyle(color: sub, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          const SizedBox(height: 8),
          ...tier.requirements.map((req) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(Iconsax.document_text, color: sub, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(req, style: TextStyle(color: sub, fontSize: 12))),
                  ],
                ),
              )),


          const SizedBox(height: 18),

          // UPGRADE BUTTON
          if (canUpgrade)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onUpgrade,
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text('Upgrade to ${tier.badgeText}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: null,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: divColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                ),
                child: Text(
                  isCurrent ? 'Current Active Tier' : 'Tier Unlocked',
                  style: TextStyle(color: sub, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _limitStat(String label, String value, Color textColor, Color sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: sub, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
