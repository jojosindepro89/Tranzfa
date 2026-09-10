import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'cards_screen.dart';
import 'bills_screen.dart';
import 'yield_screen.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _inputController = TextEditingController();
  bool _isLoading = false;
  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text': "Good morning, Julian. I've finished auditing your transactions from the last 24 hours. You're doing great on your \"New Car\" goal!",
    },
    {
      'isUser': false,
      'isCard': true,
      'cardType': 'insight',
      'title': 'Dining & Drinks',
      'tag': 'Spending Insight',
      'badge': '+15% vs last week',
      'spentText': 'You spent \$240.00 at restaurants this week. That\'s \$35 over your typical average.',
    },
    {
      'isUser': true,
      'text': "Can you suggest where I can save some money to make up for it?",
    },
    {
      'isUser': false,
      'isCard': true,
      'cardType': 'savings',
      'text': "I've identified \$42.50 in recurring subscriptions you haven't used in 60 days.",
      'goalTitle': 'Monthly Goal: Emergency Fund',
      'goalPercent': '85%',
      'question': 'Would you like me to cancel these and move the savings to your Emergency Fund?',
    },
  ];

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;
    final userPrompt = text.trim();
    setState(() {
      _messages.add({
        'isUser': true,
        'text': userPrompt,
      });
      _inputController.clear();
      _isLoading = true;
    });

    final res = await ApiService.sendAiChatPrompt(message: userPrompt);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res['reply'] != null) {
          _messages.add({
            'isUser': false,
            'text': res['reply'],
          });
        }
        if (res['card'] != null && res['card'] is Map<String, dynamic>) {
          _messages.add(res['card']);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF040E0A) : const Color(0xFFF4F7F5);
    final cardBgColor = isDark ? const Color(0xFF07261C) : Colors.white;
    final borderColor = isDark ? const Color(0xFF104735) : const Color(0xFFE0E8E4);
    final textColor = isDark ? Colors.white : const Color(0xFF0B1F17);
    final subtextColor = isDark ? const Color(0xFF8E9E98) : const Color(0xFF5A7067);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF06150F) : Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF09291E) : const Color(0xFFE2EDE8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFFE5B800), size: 22),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tranzfa AI',
                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Text(
                  'PREMIUM ASSISTANT',
                  style: TextStyle(
                    color: Color(0xFFE5B800),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.show_chart_rounded, color: textColor),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const YieldScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert_rounded, color: textColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // TODAY CHAT DATE BADGE
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF072118) : const Color(0xFFE2EDE8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'TODAY',
                        style: TextStyle(
                          color: subtextColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),

                // CHAT FEED LIST
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isUser = msg['isUser'] == true;

                      if (msg['isCard'] == true) {
                        if (msg['cardType'] == 'insight') {
                          return _buildInsightCard(msg, isDark, cardBgColor, borderColor, textColor, subtextColor);
                        } else if (msg['cardType'] == 'savings') {
                          return _buildSavingsGoalCard(msg, isDark, cardBgColor, borderColor, textColor, subtextColor);
                        }
                      }

                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.78,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                            children: [
                              if (!isUser) ...[
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  margin: const EdgeInsets.only(right: 8, top: 4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF00C88C),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.smart_toy_rounded, color: Colors.black, size: 14),
                                ),
                              ],
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isUser
                                        ? const Color(0xFF063B29)
                                        : (isDark ? const Color(0xFF082118) : Colors.white),
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(20),
                                      topRight: const Radius.circular(20),
                                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                                      bottomRight: Radius.circular(isUser ? 4 : 20),
                                    ),
                                    border: Border.all(
                                      color: isUser
                                          ? const Color(0xFF0C543A)
                                          : (isDark ? const Color(0xFF103628) : const Color(0xFFE0E8E4)),
                                    ),
                                  ),
                                  child: Text(
                                    msg['text'],
                                    style: TextStyle(
                                      color: isUser ? Colors.white : textColor,
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // QUICK SUGGESTION CHIPS ROW
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _buildChip('Show subscriptions', () => _sendMessage('Show subscriptions'), isDark, textColor),
                      const SizedBox(width: 8),
                      _buildChip('Monthly report', () => _sendMessage('Monthly report'), isDark, textColor),
                      const SizedBox(width: 8),
                      _buildChip('Set budget', () => _sendMessage('Set budget'), isDark, textColor),
                    ],
                  ),
                ),

                // INPUT BAR & SEND BUTTON
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF072118) : Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _inputController,
                                  style: TextStyle(color: textColor, fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: 'Ask Tranzfa anything...',
                                    hintStyle: TextStyle(color: subtextColor, fontSize: 14),
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: _sendMessage,
                                ),
                              ),
                              Icon(Icons.mic_none_rounded, color: subtextColor, size: 22),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _sendMessage(_inputController.text),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE5B800),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.send_rounded, color: Color(0xFF041710), size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                      icon: Iconsax.home_2,
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
                      icon: Iconsax.card,
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
                      icon: Iconsax.receipt_text,
                      label: 'Bills',
                      isActive: false,
                      subtextColor: subtextColor,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const BillsScreen()),
                        );
                      },
                    ),
                    _buildNavItem(
                      icon: Iconsax.chart_21,
                      label: 'Insights',
                      isActive: true,
                      subtextColor: subtextColor,
                      onTap: () {},
                    ),
                    _buildNavItem(
                      icon: Iconsax.user,
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

  // Insight Spending Card Bubble
  Widget _buildInsightCard(
    Map<String, dynamic> msg,
    bool isDark,
    Color cardBgColor,
    Color borderColor,
    Color textColor,
    Color subtextColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 32),
      padding: const EdgeInsets.all(20),
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
              Text(
                msg['tag'],
                style: TextStyle(color: subtextColor, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A1C1D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  msg['badge'],
                  style: const TextStyle(color: Color(0xFFFF5252), fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            msg['title'],
            style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // BAR CHART GRAPHIC
          Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(30, false, isDark),
                _buildBar(45, false, isDark),
                _buildBar(25, false, isDark),
                _buildBar(40, false, isDark),
                _buildBar(70, true, isDark),
                _buildBar(55, true, isDark, isSecondary: true),
                _buildBar(20, false, isDark),
              ],
            ),
          ),

          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: TextStyle(color: subtextColor, fontSize: 13, height: 1.4),
              children: const [
                TextSpan(text: 'You spent '),
                TextSpan(text: '\$240.00', style: TextStyle(color: Color(0xFFE5B800), fontWeight: FontWeight.bold)),
                TextSpan(text: ' at restaurants this week. That\'s \$35 over your typical average.'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF025839),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('View Transactions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double height, bool isHighlight, bool isDark, {bool isSecondary = false}) {
    return Container(
      width: 22,
      height: height,
      decoration: BoxDecoration(
        color: isHighlight
            ? (isSecondary ? const Color(0xFF9E841D) : const Color(0xFFE5B800))
            : (isDark ? const Color(0xFF0A3C2A) : const Color(0xFFD0E5DC)),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // Savings & Goals Suggestion Card Bubble
  Widget _buildSavingsGoalCard(
    Map<String, dynamic> msg,
    bool isDark,
    Color cardBgColor,
    Color borderColor,
    Color textColor,
    Color subtextColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(color: textColor, fontSize: 14, height: 1.4),
              children: const [
                TextSpan(text: "I've identified "),
                TextSpan(text: "\$42.50", style: TextStyle(color: Color(0xFFE5B800), fontWeight: FontWeight.bold)),
                TextSpan(text: " in recurring subscriptions you haven't used in 60 days."),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Goal Progress Widget Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF051D15) : const Color(0xFFE2EDE8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? const Color(0xFF0C3D2E) : const Color(0xFFCBE0D7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      msg['goalTitle'],
                      style: TextStyle(color: subtextColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      msg['goalPercent'],
                      style: const TextStyle(color: Color(0xFFE5B800), fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 0.85,
                    minHeight: 8,
                    backgroundColor: Color(0xFF0B2B20),
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE5B800)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Text(
            msg['question'],
            style: TextStyle(color: textColor, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, VoidCallback onTap, bool isDark, Color textColor) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF072118) : const Color(0xFFE2EDE8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? const Color(0xFF103D2E) : const Color(0xFFCBE0D7)),
        ),
        child: Text(
          label,
          style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
        ),
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
    const green = Color(0xFF00C88C);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
