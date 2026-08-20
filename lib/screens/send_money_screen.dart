import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/banking_service.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'transaction_receipt_screen.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  String _amountDigits = "150000";
  int _selectedContactIndex = 0;

  final List<Map<String, String>> _contacts = [
    {
      'name': 'Oluwaseun',
      'fullName': 'Oluwaseun Adeyemi',
      'bank': 'GT Bank',
      'accountNo': '0123456789',
      'badge': 'GT',
      'badgeColor': '0xFF1976D2',
    },
    {
      'name': 'Chidi O.',
      'fullName': 'Chidi Okafor',
      'bank': 'Zenith Bank',
      'accountNo': '2081920148',
      'badge': 'ZN',
      'badgeColor': '0xFFD32F2F',
    },
    {
      'name': 'Amaka',
      'fullName': 'Amaka Eze',
      'bank': 'Access Bank',
      'accountNo': '0049210482',
      'badge': 'AC',
      'badgeColor': '0xFFE65100',
    },
    {
      'name': 'Tunde',
      'fullName': 'Tunde Bakare',
      'bank': 'First Bank',
      'accountNo': '3049182049',
      'badge': 'FB',
      'badgeColor': '0xFF0288D1',
    },
  ];

  void _onKeyPress(String key) {
    if (key == 'backspace') {
      if (_amountDigits.isNotEmpty) {
        setState(() {
          _amountDigits = _amountDigits.substring(0, _amountDigits.length - 1);
        });
      }
    } else {
      if (_amountDigits.length < 9) {
        if (_amountDigits == "0") {
          setState(() {
            _amountDigits = key;
          });
        } else {
          setState(() {
            _amountDigits += key;
          });
        }
      }
    }
  }

  String _formatAmount(String digits) {
    if (digits.isEmpty) return "0";
    final doubleVal = double.tryParse(digits) ?? 0;
    final parts = doubleVal.toStringAsFixed(digits.contains('.') ? 2 : 0).split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return parts.length > 1 ? '$integerPart.${parts[1]}' : integerPart;
  }

  void _handleTransfer() async {
    final doubleVal = double.tryParse(_amountDigits) ?? 0;
    if (doubleVal <= 0) return;
    final selected = _contacts[_selectedContactIndex];

    final pinController = TextEditingController(text: "1234");
    bool isProcessing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF0C1713),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                border: Border(top: BorderSide(color: Color(0xFF00C88C), width: 1.5)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C88C).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_outline_rounded, color: Color(0xFF00C88C), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Authorize Transfer (3FA)',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Sending ₦${_formatAmount(_amountDigits)} to ${selected['fullName']}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 10, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: const Color(0xFF14241E),
                      hintText: '••••',
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 24, letterSpacing: 10),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF1E3A2F)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF00C88C), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isProcessing
                          ? null
                          : () async {
                              setModalState(() => isProcessing = true);

                              final bankService = Provider.of<BankingService>(context, listen: false);
                              final res = await bankService.executeNipInterbankTransfer(
                                accountNumber: selected['accountNo']!,
                                bankCode: '058',
                                bankName: selected['bank']!,
                                recipientName: selected['fullName']!,
                                amount: doubleVal,
                                narration: 'Interbank NIP transfer via Tranzfa Core Banking',
                              );

                              await ApiService.executeTransfer(
                                recipientName: selected['fullName']!,
                                bankName: selected['bank']!,
                                accountNumber: selected['accountNo']!,
                                amount: doubleVal,
                                pin: pinController.text,
                              );

                              setModalState(() => isProcessing = false);
                              Navigator.of(modalContext).pop();

                              if (!mounted) return;

                              if (res.success) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => TransactionReceiptScreen(
                                      recipientName: selected['fullName']!,
                                      bankName: selected['bank']!,
                                      bankLogoText: selected['badge'] ?? 'GT',
                                      bankLogoColor: const Color(0xFF00C88C),
                                      amount: doubleVal,
                                      currencySymbol: '₦',
                                      transactionRef: res.reference,
                                      dateTimeText: 'Oct 24, 2023, 14:20',
                                      transactionFee: '₦10.00',
                                      statusText: 'SUCCESSFUL',
                                    ),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C88C),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: isProcessing
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text(
                              'Confirm & Send 💸',
                              style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  int _transferTab = 0; // 0: NIP Local Bank, 1: Crypto / Stablecoin

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkBg : AppTheme.lightBg;
    final cardBgColor = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final borderColor = isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder;
    final textColor = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final subtextColor = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    final activeContact = _contacts[_selectedContactIndex];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Send Money',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0B1F17) : const Color(0xFFE2EDE8),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '?',
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // DUAL-TAB SELECTOR (LOCAL BANK VS KAST CRYPTO / STABLECOINS)
                    Container(
                      height: 46,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _transferTab = 0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _transferTab == 0 ? const Color(0xFF00C88C) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    '🏛️ Local Bank (NIP)',
                                    style: TextStyle(
                                      color: _transferTab == 0 ? Colors.black : subtextColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _transferTab = 1),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _transferTab == 1 ? const Color(0xFF00C88C) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    '🌐 Crypto / Stablecoins',
                                    style: TextStyle(
                                      color: _transferTab == 1 ? Colors.black : subtextColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // SEARCH CONTACTS BAR
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search_rounded, color: subtextColor, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              style: TextStyle(color: textColor, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: _transferTab == 0
                                    ? 'Search contacts, @usernames, or bank'
                                    : 'Enter @tag, USDC/USDT address, or Solana/ETH wallet',
                                hintStyle: TextStyle(color: subtextColor, fontSize: 13),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // QUICK SEND HEADER
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'QUICK SEND',
                        style: TextStyle(
                          color: subtextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // QUICK SEND CONTACTS AVATAR CAROUSEL
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(_contacts.length, (index) {
                          final isSelected = _selectedContactIndex == index;
                          final contact = _contacts[index];

                          return GestureDetector(
                            onTap: () => setState(() => _selectedContactIndex = index),
                            child: Container(
                              margin: const EdgeInsets.only(right: 16),
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected ? const Color(0xFF00C88C) : Colors.transparent,
                                            width: 2.5,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 28,
                                          backgroundColor: const Color(0xFF0E3A2C),
                                          child: Text(
                                            contact['name']![0],
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Color(int.parse(contact['badgeColor']!)),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: bgColor, width: 1.5),
                                          ),
                                          child: Text(
                                            contact['badge']!,
                                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    contact['name']!,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // AMOUNT TO SEND DISPLAY
                    Text(
                      'Amount to Send',
                      style: TextStyle(color: subtextColor, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          '₦',
                          style: TextStyle(
                            color: Color(0xFF00C88C),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatAmount(_amountDigits),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.0,
                          ),
                        ),
                        Container(
                          width: 3,
                          height: 34,
                          margin: const EdgeInsets.only(left: 4),
                          color: const Color(0xFF00C88C),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Balance Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF051C14) : const Color(0xFFE2EDE8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Balance: ₦250,000.00',
                        style: TextStyle(
                          color: Color(0xFF00C88C),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // SELECTED RECIPIENT CARD
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: const Color(0xFF00C88C),
                            child: Text(
                              activeContact['name']!.substring(0, 2).toUpperCase(),
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activeContact['fullName']!,
                                  style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${activeContact['bank']} • ${activeContact['accountNo']}',
                                  style: TextStyle(color: subtextColor, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            'Change',
                            style: TextStyle(color: Color(0xFF00C88C), fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // NUMERIC KEYPAD GRID
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              color: isDark ? const Color(0xFF03140C) : const Color(0xFFEAF2EE),
              child: Column(
                children: [
                  _buildKeypadRow(['1', '2', '3'], textColor, subtextColor),
                  const SizedBox(height: 12),
                  _buildKeypadRow(['4', '5', '6'], textColor, subtextColor),
                  const SizedBox(height: 12),
                  _buildKeypadRow(['7', '8', '9'], textColor, subtextColor),
                  const SizedBox(height: 12),
                  _buildKeypadRow(['.', '0', 'backspace'], textColor, subtextColor),
                ],
              ),
            ),

            // CONTINUE BUTTON
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _handleTransfer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF025839),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Continue',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys, Color textColor, Color subtextColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: keys.map((key) {
        return GestureDetector(
          onTap: () => _onKeyPress(key),
          child: Container(
            width: 80,
            height: 44,
            alignment: Alignment.center,
            child: key == 'backspace'
                ? Icon(Icons.backspace_outlined, color: subtextColor, size: 22)
                : Text(
                    key,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      }).toList(),
    );
  }
}
