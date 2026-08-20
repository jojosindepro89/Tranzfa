import 'package:flutter/material.dart';
import '../models/banking_models.dart';
import '../services/banking_service.dart';
import 'transaction_receipt_screen.dart';
import 'dashboard_screen.dart';
import 'cards_screen.dart';
import 'profile_screen.dart';
import 'send_money_screen.dart';

class TransactionHistoryItemModel {
  final String id;
  final String title;
  final String time;
  final String dateGroup; // 'TODAY', 'YESTERDAY', 'OCTOBER 23, 2023'
  final String category;
  final double amount;
  final bool isIncome;
  final TransactionStatus status;
  final IconData icon;
  final Color iconBgColor;
  final Color categoryBgColor;
  final Color categoryTextColor;

  TransactionHistoryItemModel({
    required this.id,
    required this.title,
    required this.time,
    required this.dateGroup,
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.status,
    required this.icon,
    required this.iconBgColor,
    required this.categoryBgColor,
    required this.categoryTextColor,
  });
}

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _selectedPeriod = 'Last 30 days';
  String _selectedCategoryFilter = 'All';
  String _searchQuery = '';
  bool _isSearching = false;

  final List<TransactionHistoryItemModel> _allHistory = [
    // TODAY
    TransactionHistoryItemModel(
      id: 'tx_hist_01',
      title: 'Starbucks Coffee',
      time: '2:30 PM',
      dateGroup: 'TODAY',
      category: 'Food',
      amount: 12.50,
      isIncome: false,
      status: TransactionStatus.completed,
      icon: Icons.coffee_rounded,
      iconBgColor: const Color(0xFF4A3418),
      categoryBgColor: const Color(0xFF0F3B2C),
      categoryTextColor: const Color(0xFF53D49F),
    ),
    TransactionHistoryItemModel(
      id: 'tx_hist_02',
      title: 'Uber Trip',
      time: '11:15 AM',
      dateGroup: 'TODAY',
      category: 'Transport',
      amount: 24.00,
      isIncome: false,
      status: TransactionStatus.completed,
      icon: Icons.directions_car_filled_rounded,
      iconBgColor: const Color(0xFF153B54),
      categoryBgColor: const Color(0xFF0F3244),
      categoryTextColor: const Color(0xFF48A6E0),
    ),
    TransactionHistoryItemModel(
      id: 'tx_hist_03',
      title: 'Salary Deposit',
      time: '09:00 AM',
      dateGroup: 'TODAY',
      category: 'INCOME',
      amount: 3450.00,
      isIncome: true,
      status: TransactionStatus.completed,
      icon: Icons.account_balance_wallet_rounded,
      iconBgColor: const Color(0xFF0A4432),
      categoryBgColor: const Color(0xFF005A3E),
      categoryTextColor: const Color(0xFF00FFB2),
    ),

    // YESTERDAY
    TransactionHistoryItemModel(
      id: 'tx_hist_04',
      title: 'Netflix Subscription',
      time: 'Oct 24, 8:20 PM',
      dateGroup: 'YESTERDAY',
      category: 'Entertainment',
      amount: 15.99,
      isIncome: false,
      status: TransactionStatus.completed,
      icon: Icons.play_circle_fill_rounded,
      iconBgColor: const Color(0xFF332345),
      categoryBgColor: const Color(0xFF261936),
      categoryTextColor: const Color(0xFFA67CE8),
    ),
    TransactionHistoryItemModel(
      id: 'tx_hist_05',
      title: 'Apple Store',
      time: 'Oct 24, 2:45 PM',
      dateGroup: 'YESTERDAY',
      category: 'Shopping',
      amount: 199.00,
      isIncome: false,
      status: TransactionStatus.declined,
      icon: Icons.shopping_bag_rounded,
      iconBgColor: const Color(0xFF4D2424),
      categoryBgColor: const Color(0xFF381A1A),
      categoryTextColor: const Color(0xFFE56969),
    ),
    TransactionHistoryItemModel(
      id: 'tx_hist_06',
      title: 'Electricity Bill',
      time: 'Oct 24, 10:00 AM',
      dateGroup: 'YESTERDAY',
      category: 'Bills',
      amount: 84.50,
      isIncome: false,
      status: TransactionStatus.completed,
      icon: Icons.receipt_rounded,
      iconBgColor: const Color(0xFF0E4237),
      categoryBgColor: const Color(0xFF092C24),
      categoryTextColor: const Color(0xFF00C88C),
    ),
  ];

  void _showFilterModal(String filterType) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    List<String> options = [];

    if (filterType == 'Period') {
      options = ['Last 7 days', 'Last 30 days', 'This Month', 'All Time'];
    } else if (filterType == 'Category') {
      options = ['All', 'Food', 'Transport', 'INCOME', 'Entertainment', 'Shopping', 'Bills'];
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF081C15) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Filter by $filterType',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0B1F17),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              ...options.map((opt) {
                final isSelected = filterType == 'Period'
                    ? _selectedPeriod == opt
                    : _selectedCategoryFilter == opt;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    opt,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF00C88C)
                          : (isDark ? Colors.white : Colors.black87),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFF00C88C))
                      : null,
                  onTap: () {
                    setState(() {
                      if (filterType == 'Period') {
                        _selectedPeriod = opt;
                      } else {
                        _selectedCategoryFilter = opt;
                      }
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _openTransactionReceipt(TransactionHistoryItemModel item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TransactionReceiptScreen(
          recipientName: item.title,
          bankName: item.category == 'INCOME' ? 'Employer Payroll' : 'Tranzfa Pay',
          bankLogoText: item.title[0],
          amount: item.amount,
          currencySymbol: '\$',
          transactionRef: 'TZ-${item.id.toUpperCase()}',
          dateTimeText: item.time,
          transactionFee: item.isIncome ? '\$0.00' : '\$0.25',
          statusText: item.status == TransactionStatus.declined ? 'DECLINED' : 'SUCCESSFUL',
        ),
      ),
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

    // Filter items
    final filteredHistory = _allHistory.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategoryFilter == 'All' ||
          item.category.toLowerCase() == _selectedCategoryFilter.toLowerCase();
      return matchesSearch && matchesCategory;
    }).toList();

    // Group items by dateGroup
    final Map<String, List<TransactionHistoryItemModel>> grouped = {};
    for (var item in filteredHistory) {
      grouped.putIfAbsent(item.dateGroup, () => []).add(item);
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: textColor, size: 20),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                );
              }
            },
          ),
        ),
        title: _isSearching
            ? TextField(
                autofocus: true,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  hintStyle: TextStyle(color: subtextColor),
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              )
            : Text(
                'Tranzfa History',
                style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
              ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search_rounded, color: textColor, size: 20),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) _searchQuery = '';
                });
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TOTAL SPENDING HERO CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [const Color(0xFF063D2E), const Color(0xFF032219)]
                            : [const Color(0xFF084F3B), const Color(0xFF042B20)],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFF0F5441), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Total Spending (Oct)',
                              style: TextStyle(color: Color(0xFF8DA89C), fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '\$1,240.00',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.show_chart_rounded, color: Color(0xFF00C88C), size: 22),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // FILTER CHIPS ROW
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          icon: Icons.calendar_today_rounded,
                          label: _selectedPeriod,
                          isSelected: true,
                          isDark: isDark,
                          onTap: () => _showFilterModal('Period'),
                        ),
                        const SizedBox(width: 10),
                        _buildFilterChip(
                          icon: Icons.category_rounded,
                          label: _selectedCategoryFilter == 'All' ? 'Category' : _selectedCategoryFilter,
                          isSelected: _selectedCategoryFilter != 'All',
                          isDark: isDark,
                          onTap: () => _showFilterModal('Category'),
                        ),
                        const SizedBox(width: 10),
                        _buildFilterChip(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Amount',
                          isSelected: false,
                          isDark: isDark,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // GROUPED TRANSACTIONS LIST
                  if (grouped.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          'No transactions found',
                          style: TextStyle(color: subtextColor, fontSize: 14),
                        ),
                      ),
                    )
                  else
                    ...grouped.entries.map((entry) {
                      final groupTitle = entry.key;
                      final items = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            groupTitle,
                            style: TextStyle(
                              color: subtextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...items.map((item) => _buildTransactionCard(
                                item,
                                cardBgColor,
                                borderColor,
                                textColor,
                                subtextColor,
                              )),
                          const SizedBox(height: 20),
                        ],
                      );
                    }),
                ],
              ),
            ),
          ),

          // BOTTOM NAV BAR WITH CENTER FAB (+)
          _buildBottomNavBar(isDark, subtextColor),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required IconData icon,
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF084534) : const Color(0xFF0E634C))
              : (isDark ? const Color(0xFF0B211A) : const Color(0xFFE4ECE8)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF00C88C) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? const Color(0xFF00C88C) : (isDark ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : (isDark ? Colors.white.withOpacity(0.87) : Colors.black87),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: isSelected ? const Color(0xFF00C88C) : (isDark ? Colors.white54 : Colors.black45),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
    TransactionHistoryItemModel item,
    Color cardBgColor,
    Color borderColor,
    Color textColor,
    Color subtextColor,
  ) {
    final isDeclined = item.status == TransactionStatus.declined;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openTransactionReceipt(item),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1.1),
            ),
            child: Row(
              children: [
                // Icon Circle
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: item.iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),

                // Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            item.time,
                            style: TextStyle(color: subtextColor, fontSize: 12),
                          ),
                          const SizedBox(width: 6),
                          Text('•', style: TextStyle(color: subtextColor, fontSize: 12)),
                          const SizedBox(width: 6),

                          // Category Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: item.categoryBgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.category,
                              style: TextStyle(
                                color: item.categoryTextColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Amount & Status Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.isIncome ? '+' : '-'}\$${item.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: item.isIncome ? const Color(0xFF00C88C) : textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isDeclined) ...[
                      const SizedBox(height: 2),
                      const Text(
                        'Declined',
                        style: TextStyle(
                          color: Color(0xFFE55353),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(bool isDark, Color subtextColor) {
    final navBg = isDark ? const Color(0xFF04140F) : Colors.white;
    final navBorder = isDark ? const Color(0xFF0D2D23) : const Color(0xFFE0ECE7);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: navBg,
        border: Border(top: BorderSide(color: navBorder, width: 1)),
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
            icon: Icons.history_rounded,
            label: 'History',
            isActive: true,
            subtextColor: subtextColor,
            onTap: () {},
          ),

          // CENTER FLOATING (+) ACTION BUTTON
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SendMoneyScreen()),
              );
            },
            child: Container(
              width: 52,
              height: 52,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF007A54),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF007A54).withOpacity(0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),

          _buildNavItem(
            icon: Icons.credit_card_rounded,
            label: 'Cards',
            isActive: false,
            subtextColor: subtextColor,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CardsScreen()),
              );
            },
          ),
          _buildNavItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            isActive: false,
            subtextColor: subtextColor,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
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
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF00C88C) : subtextColor,
            size: 22,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFF00C88C) : subtextColor,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
