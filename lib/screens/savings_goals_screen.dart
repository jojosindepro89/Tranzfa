import 'package:flutter/material.dart';
import '../models/banking_models.dart';
import '../services/banking_service.dart';
import 'dashboard_screen.dart';
import 'ai_assistant_screen.dart';
import 'profile_screen.dart';

class SavingsGoalItem {
  final String id;
  final String title;
  final String subtitle;
  final double currentAmount;
  final double targetAmount;
  final String targetFormatted;
  final int percentage;
  final String imageUrl;
  final String category;

  SavingsGoalItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.currentAmount,
    required this.targetAmount,
    required this.targetFormatted,
    required this.percentage,
    required this.imageUrl,
    required this.category,
  });
}

class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({super.key});

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen> {
  final List<SavingsGoalItem> _goals = [
    SavingsGoalItem(
      id: 'goal_car',
      title: 'New Car',
      subtitle: 'PORSCHE 911 FUND',
      currentAmount: 13000.0,
      targetAmount: 20000.0,
      targetFormatted: 'Target \$20k',
      percentage: 65,
      imageUrl: 'https://images.unsplash.com/photo-1614162692292-7ac56d7f7f1e?w=800',
      category: 'Vehicle',
    ),
    SavingsGoalItem(
      id: 'goal_vacation',
      title: 'Vacation',
      subtitle: 'MALDIVES GETAWAY',
      currentAmount: 1000.0,
      targetAmount: 5000.0,
      targetFormatted: 'Target \$5k',
      percentage: 20,
      imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
      category: 'Travel',
    ),
    SavingsGoalItem(
      id: 'goal_emergency',
      title: 'Emergency Fund',
      subtitle: 'FINANCIAL SAFETY NET',
      currentAmount: 9000.0,
      targetAmount: 10000.0,
      targetFormatted: 'Almost there!',
      percentage: 90,
      imageUrl: 'https://images.unsplash.com/photo-1579621970563-ebec7560ff3e?w=800',
      category: 'Safety',
    ),
  ];

  String _formatAmount(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '$integerPart.${parts[1]}';
  }

  void _openCreateGoalModal() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
            left: 20,
            right: 20,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF081C15) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Create New Savings Goal ',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0B1F17),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: titleController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'Goal Title (e.g. Dream House, Laptop)',
                  labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0D291F) : const Color(0xFFF4F7F5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'Target Amount (\$)',
                  labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0D291F) : const Color(0xFFF4F7F5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C88C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  ),
                  onPressed: () {
                    final title = titleController.text.trim();
                    final target = double.tryParse(amountController.text) ?? 5000.0;
                    if (title.isNotEmpty) {
                      setState(() {
                        _goals.add(
                          SavingsGoalItem(
                            id: 'goal_${DateTime.now().millisecondsSinceEpoch}',
                            title: title,
                            subtitle: title.toUpperCase(),
                            currentAmount: 0.0,
                            targetAmount: target,
                            targetFormatted: 'Target \$${(target/1000).toStringAsFixed(0)}k',
                            percentage: 0,
                            imageUrl: 'https://images.unsplash.com/photo-1579621970563-ebec7560ff3e?w=800',
                            category: 'Custom',
                          ),
                        );
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Created "$title" Savings Goal!'),
                          backgroundColor: const Color(0xFF00C88C),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Create Goal',
                    style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF06120E) : const Color(0xFFF4F7F5);
    final cardBgColor = isDark ? const Color(0xFF0B211A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF123B2F) : const Color(0xFFE0E8E4);
    final textColor = isDark ? Colors.white : const Color(0xFF0B1F17);
    final subtextColor = isDark ? const Color(0xFF8E9E98) : const Color(0xFF5A7067);

    double totalSaved = 0.0;
    for (var goal in _goals) {
      totalSaved += goal.currentAmount;
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: textColor, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          'Savings Goals',
          style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0B261D) : const Color(0xFFE2EDE8),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_active_rounded, color: Color(0xFFE5B800), size: 20),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TOTAL SAVED ACROSS GOALS HERO CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF09291E), const Color(0xFF041711)]
                          : [const Color(0xFF0F4734), const Color(0xFF07291E)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFF13523E), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Saved Across Goals',
                        style: TextStyle(color: Color(0xFF8BA398), fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '\$ ',
                            style: TextStyle(
                              color: Color(0xFFE5B800),
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _formatAmount(totalSaved),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C88C).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF00C88C).withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.trending_up, color: Color(0xFF00C88C), size: 14),
                            SizedBox(width: 6),
                            Text(
                              '+2.4% this month',
                              style: TextStyle(
                                color: Color(0xFF00C88C),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // SMART SAVINGS SECTION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SMART SAVINGS',
                      style: TextStyle(
                        color: subtextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Icon(Icons.auto_awesome, color: Color(0xFFE5B800), size: 18),
                  ],
                ),
                const SizedBox(height: 12),

                // AI RECOMMENDATION CARD (WITH GOLD LEFT ARC ACCENT)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor, width: 1.2),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: -16,
                        top: -16,
                        bottom: -16,
                        child: Container(
                          width: 4,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE5B800),
                            borderRadius: BorderRadius.horizontal(left: Radius.circular(4)),
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFF103D2E),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFE5B800).withOpacity(0.5)),
                            ),
                            child: const Icon(Icons.restaurant, color: Color(0xFFE5B800), size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI Recommendation',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(color: subtextColor, fontSize: 13, height: 1.35),
                                    children: const [
                                      TextSpan(text: 'Based on your dining habits, you could save '),
                                      TextSpan(
                                        text: '\$200/mo ',
                                        style: TextStyle(color: Color(0xFFE5B800), fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(text: "for a 'Gourmet Travel' goal."),
                                    ],
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
                const SizedBox(height: 28),

                // ACTIVE GOALS HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ACTIVE GOALS',
                      style: TextStyle(
                        color: subtextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          color: Color(0xFFE5B800),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // GOALS LIST
                ..._goals.map((goal) => _buildGoalCard(goal, cardBgColor, borderColor, textColor, subtextColor)),

                const SizedBox(height: 80),
              ],
            ),
          ),

          // FLOATING (+) ADD BUTTON OVERLAY
          Positioned(
            right: 20,
            bottom: 30,
            child: GestureDetector(
              onTap: _openCreateGoalModal,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF006B48),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF006B48).withOpacity(0.5),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(
    SavingsGoalItem goal,
    Color cardBgColor,
    Color borderColor,
    Color textColor,
    Color subtextColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Header with Percentage Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(23)),
                child: Image.network(
                  goal.imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 150,
                    color: const Color(0xFF0B261D),
                    child: const Center(child: Icon(Icons.savings, color: Color(0xFF00C88C), size: 48)),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF292312).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5B800).withOpacity(0.6)),
                  ),
                  child: Text(
                    '${goal.percentage}%',
                    style: const TextStyle(
                      color: Color(0xFFE5B800),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Details Body
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  goal.subtitle,
                  style: TextStyle(
                    color: subtextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 14),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: goal.percentage / 100.0,
                    minHeight: 6,
                    backgroundColor: const Color(0xFF143026),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00C88C)),
                  ),
                ),
                const SizedBox(height: 14),

                // Amounts Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${goal.currentAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      goal.targetFormatted,
                      style: TextStyle(
                        color: goal.targetFormatted.contains('Almost')
                            ? const Color(0xFFE5B800)
                            : subtextColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
