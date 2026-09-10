import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../services/banking_service.dart';
import 'transaction_receipt_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedFilter = 0;

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '0',
      'title': '🚨 Transfer Held for Compliance Review',
      'body': 'Your interbank transfer of ₦500,000.00 is held under the 30-minute CBN Anti-Fraud & APP Dispute protection window. Identity verification required.',
      'time': 'Just now',
      'type': 'security',
      'icon': Iconsax.shield_cross,
      'iconColor': const Color(0xFFF59E0B),
      'bgColor': const Color(0xFF332004),
      'isRead': false,
    },
    {
      'id': '1',
      'title': 'Transfer Received',
      'body': 'You received ₦50,000.00 from Sarah Okonjo into your NGN Wallet.',
      'time': '2 mins ago',
      'type': 'transfer',
      'icon': Iconsax.arrow_down_1,
      'iconColor': const Color(0xFF00C88C),
      'bgColor': const Color(0xFF0C2B1E),
      'isRead': false,
    },
    {
      'id': '2',
      'title': 'Security Login Alert',
      'body': 'New successful login detected from Pixel 9 Pro XL (Lagos, NG).',
      'time': '1 hour ago',
      'type': 'security',
      'icon': Iconsax.shield_tick,
      'iconColor': const Color(0xFF42A5F5),
      'bgColor': const Color(0xFF0D2533),
      'isRead': false,
    },
    {
      'id': '3',
      'title': 'Yield Interest Paid',
      'body': 'Your Tranzfa Yield Vault paid out +₦1,240.50 daily compounding interest.',
      'time': '3 hours ago',
      'type': 'yield',
      'icon': Iconsax.trend_up,
      'iconColor': const Color(0xFFE5B800),
      'bgColor': const Color(0xFF332B0A),
      'isRead': true,
    },
    {
      'id': '4',
      'title': 'USDC Cashback Earned',
      'body': 'You earned 2% USDC Cashback (₦90.00 equivalent) on Netflix Subscription.',
      'time': 'Yesterday • 10:45 AM',
      'type': 'card',
      'icon': Iconsax.card,
      'iconColor': const Color(0xFFAB47BC),
      'bgColor': const Color(0xFF271333),
      'isRead': true,
    },
    {
      'id': '5',
      'title': 'Electricity Token Generated',
      'body': 'IKEDC Token: 4928-1029-8831-9920. Units: 45.2 kWh for ₦10,000.00.',
      'time': '21 Oct, 2023',
      'type': 'bills',
      'icon': Iconsax.flash_1,
      'iconColor': const Color(0xFF00C88C),
      'bgColor': const Color(0xFF0C2B1E),
      'isRead': true,
    },
    {
      'id': '6',
      'title': 'Savings Milestone Reached',
      'body': 'Congratulations! You reached 85% of your Emergency Fund vault goal.',
      'time': '19 Oct, 2023',
      'type': 'savings',
      'icon': Iconsax.cup,
      'iconColor': const Color(0xFFFFB300),
      'bgColor': const Color(0xFF33290A),
      'isRead': true,
    },
  ];

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF060E0A) : const Color(0xFFF4F7F5);
    final cardBg = isDark ? const Color(0xFF0D1E17) : Colors.white;
    final borderColor = isDark ? const Color(0xFF162E24) : const Color(0xFFE2EDE8);
    final textColor = isDark ? Colors.white : const Color(0xFF0B1F17);
    final subtextColor = isDark ? const Color(0xFF7A9489) : const Color(0xFF6B7E76);
    const green = Color(0xFF00C88C);

    List<Map<String, dynamic>> filteredList = _notifications;
    if (_selectedFilter == 1) {
      filteredList = _notifications.where((n) => n['type'] == 'transfer' || n['type'] == 'bills').toList();
    } else if (_selectedFilter == 2) {
      filteredList = _notifications.where((n) => n['type'] == 'security').toList();
    } else if (_selectedFilter == 3) {
      filteredList = _notifications.where((n) => n['type'] == 'yield' || n['type'] == 'card').toList();
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text(
              'Mark all read',
              style: TextStyle(color: green, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ── FILTER TABS (All, Transactions, Security, Rewards) ──
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildFilterTab('All', 0, isDark, textColor, subtextColor, green),
                  const SizedBox(width: 8),
                  _buildFilterTab('Transactions', 1, isDark, textColor, subtextColor, green),
                  const SizedBox(width: 8),
                  _buildFilterTab('Security', 2, isDark, textColor, subtextColor, green),
                  const SizedBox(width: 8),
                  _buildFilterTab('Rewards & Yield', 3, isDark, textColor, subtextColor, green),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── NOTIFICATIONS FEED LIST ──
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                itemCount: filteredList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = filteredList[index];
                  final isRead = item['isRead'] == true;

                  return GestureDetector(
                    onTap: () {
                      setState(() => item['isRead'] = true);
                      if (item['id'] == '0' || item['type'] == 'security') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TransactionReceiptScreen(
                              recipientName: 'Sarah Okonjo',
                              bankName: 'Tranzfa Bank',
                              amount: 500000.00,
                              currencySymbol: '₦',
                              transactionRef: 'NIP_HELD_30MIN_CBN',
                              dateTimeText: 'Just Now',
                              transactionFee: '₦10.00',
                              statusText: 'HELD_FOR_REVIEW',
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isRead ? cardBg : (isDark ? const Color(0xFF0F2C20) : const Color(0xFFE8F5F0)),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isRead ? borderColor : green.withOpacity(0.4),
                          width: isRead ? 1 : 1.2,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: item['bgColor'],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(item['icon'], color: item['iconColor'], size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item['title'],
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 15,
                                          fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (!isRead)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: green,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['body'],
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFFD0DCD6) : const Color(0xFF2C4037),
                                    fontSize: 13,
                                    height: 1.35,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item['time'],
                                  style: TextStyle(
                                    color: subtextColor,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(
    String label,
    int index,
    bool isDark,
    Color textColor,
    Color subtextColor,
    Color green,
  ) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? green : (isDark ? const Color(0xFF0E1F18) : const Color(0xFFE2EDE8)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : subtextColor,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
