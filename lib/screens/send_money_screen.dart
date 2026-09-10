import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../services/banking_service.dart';
import '../services/api_service.dart';
import '../services/core_banking_service.dart';
import '../theme/app_theme.dart';
import 'transaction_receipt_screen.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  int _transferTab = 0; // 0: To Tranzfa User, 1: To Other Banks, 2: Crypto / Global
  String _amountDigits = "150000";

  // Tranzfa User Fields
  final TextEditingController _tranzfaUserInput = TextEditingController(text: "@sarah_okonjo");
  String _resolvedTranzfaName = "Sarah Okonjo • @sarah_okonjo";

  // Other Bank Fields
  final TextEditingController _accountNumberController = TextEditingController(text: "0123456789");
  String _selectedBank = "GT Bank";
  String _resolvedBankName = "Oluwaseun Adeyemi";

  final List<String> _nigerianBanks = [
    'GT Bank',
    'Access Bank',
    'Zenith Bank',
    'Kuda Bank',
    'OPay',
    'PalmPay',
    'First Bank',
    'United Bank for Africa (UBA)',
    'Sterling Bank',
    'FCMB',
    'Stanbic IBTC',
  ];

  int _selectedContactIndex = 0;

  final List<Map<String, String>> _contacts = [
    {
      'name': 'Sarah O.',
      'fullName': 'Sarah Okonjo',
      'bank': 'Tranzfa Bank',
      'accountNo': '@sarah_okonjo',
      'badge': 'TZ',
      'badgeColor': '0xFF00C88C',
      'isTranzfa': 'true',
    },
    {
      'name': 'Oluwaseun',
      'fullName': 'Oluwaseun Adeyemi',
      'bank': 'GT Bank',
      'accountNo': '0123456789',
      'badge': 'GT',
      'badgeColor': '0xFF1976D2',
      'isTranzfa': 'false',
    },
    {
      'name': 'Chidi O.',
      'fullName': 'Chidi Okafor',
      'bank': 'Zenith Bank',
      'accountNo': '2081920148',
      'badge': 'ZN',
      'badgeColor': '0xFFD32F2F',
      'isTranzfa': 'false',
    },
    {
      'name': 'Amaka',
      'fullName': 'Amaka Eze',
      'bank': 'Tranzfa Bank',
      'accountNo': '@amaka_eze',
      'badge': 'TZ',
      'badgeColor': '0xFF00C88C',
      'isTranzfa': 'true',
    },
    {
      'name': 'Tunde',
      'fullName': 'Tunde Bakare',
      'bank': 'First Bank',
      'accountNo': '3049182049',
      'badge': 'FB',
      'badgeColor': '0xFF0288D1',
      'isTranzfa': 'false',
    },
  ];

  @override
  void dispose() {
    _tranzfaUserInput.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

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

    final recipientName = _transferTab == 0
        ? _resolvedTranzfaName
        : (_transferTab == 1 ? '$_resolvedBankName ($_selectedBank)' : 'Crypto Wallet');

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
                              'Sending ₦${_formatAmount(_amountDigits)} to $recipientName',
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
                                accountNumber: _transferTab == 0 ? _tranzfaUserInput.text : _accountNumberController.text,
                                bankCode: _transferTab == 0 ? 'TRZ' : '058',
                                bankName: _transferTab == 0 ? 'Tranzfa Direct' : _selectedBank,
                                recipientName: recipientName,
                                amount: doubleVal,
                                narration: _transferTab == 0
                                    ? 'Instant Tranzfa-to-Tranzfa Transfer'
                                    : 'NIP Interbank Transfer',
                              );

                              if (mounted) {
                                Navigator.pop(modalContext);

                                final isPending = res.status == 'HELD_FOR_REVIEW' ||
                                    res.status == 'PENDING_VERIFICATION' ||
                                    res.status.contains('HOLD') ||
                                    res.status.contains('PENDING') ||
                                    res.message.toLowerCase().contains('hold') ||
                                    res.message.toLowerCase().contains('review') ||
                                    res.message.toLowerCase().contains('fraud') ||
                                    res.message.toLowerCase().contains('dispute') ||
                                    res.message.toLowerCase().contains('pending');

                                if (isPending) {
                                  _showPendingVerificationModal(
                                    context: context,
                                    res: res,
                                    amount: doubleVal,
                                    recipientName: recipientName,
                                    bankName: _transferTab == 0 ? 'Tranzfa Bank' : _selectedBank,
                                  );
                                } else {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => TransactionReceiptScreen(
                                        transactionRef: res.reference.isNotEmpty ? res.reference : 'TX_${DateTime.now().millisecondsSinceEpoch}',
                                        amount: doubleVal,
                                        recipientName: recipientName,
                                        bankName: _transferTab == 0 ? 'Tranzfa Bank' : _selectedBank,
                                        dateTimeText: DateTime.now().toString().substring(0, 16),
                                        transactionFee: _transferTab == 0 ? 'FREE' : '₦10.00',
                                        statusText: res.status,
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C88C),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: isProcessing
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : const Text('Confirm Transfer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  void _showPendingVerificationModal({
    required BuildContext context,
    required TransferExecutionResult res,
    required double amount,
    required String recipientName,
    required String bankName,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        bool isVerifying = false;
        bool isVerified = false;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF140D04),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
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

                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          color: Color(0xFFB45309),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isVerified ? Icons.check_circle_rounded : Icons.shield_outlined,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    isVerified ? 'Verification Complete!' : 'Transaction Pending Verification',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'CBN Anti-Fraud & APP Dispute Protection Window',
                    style: TextStyle(
                      color: Color(0xFFF59E0B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF261904),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.5)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'TRANSFER HAS NOT BEEN RELEASED',
                                style: TextStyle(
                                  color: Color(0xFFF59E0B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isVerified
                              ? 'Your identity has been verified. Compliance clearance in progress.'
                              : 'Your transfer of ₦${_formatAmount(amount.toStringAsFixed(0))} to $recipientName ($bankName) has NOT completed. It is currently PENDING due to mandatory fraud analysis and high-risk recipient evaluation. Identity verification must be completed to release funds.',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1408),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow('Hold Reference', res.reference.isNotEmpty ? res.reference : 'HOLD_${DateTime.now().millisecondsSinceEpoch}'),
                        const Divider(color: Colors.white12, height: 16),
                        _buildSummaryRow('Recipient', recipientName),
                        const Divider(color: Colors.white12, height: 16),
                        _buildSummaryRow('Destination Bank', bankName),
                        const Divider(color: Colors.white12, height: 16),
                        _buildSummaryRow('Amount', '₦${_formatAmount(amount.toStringAsFixed(0))}'),
                        const Divider(color: Colors.white12, height: 16),
                        _buildSummaryRow('Review Status', isVerified ? 'VERIFIED • PENDING RELEASE' : 'PENDING COMPLIANCE VERIFICATION', valueColor: isVerified ? const Color(0xFF00C88C) : const Color(0xFFF59E0B)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (!isVerified) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: isVerifying
                            ? null
                            : () async {
                                setSheetState(() => isVerifying = true);
                                await Future.delayed(const Duration(seconds: 2));
                                if (mounted) {
                                  final bankService = Provider.of<BankingService>(context, listen: false);
                                  bankService.resolvePendingTransaction(res.reference, approved: true);
                                  setSheetState(() {
                                    isVerifying = false;
                                    isVerified = true;
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: isVerifying
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                              )
                            : const Icon(Icons.verified_user_rounded, size: 20, color: Colors.black),
                        label: Text(
                          isVerifying ? 'Verifying Identity & Risk...' : 'Perform Biometric / 3FA Verification',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // CANCEL & REFUND BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final bankService = Provider.of<BankingService>(context, listen: false);
                          bankService.resolvePendingTransaction(res.reference, approved: false);
                          Navigator.pop(sheetContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Transfer Canceled! ₦${_formatAmount(amount.toStringAsFixed(0))} has been refunded to your account balance.',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: const Color(0xFFE53935),
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFEF5350), width: 1.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.cancel_outlined, color: Color(0xFFEF5350), size: 18),
                        label: const Text(
                          'Cancel & Refund Money to Balance',
                          style: TextStyle(color: Color(0xFFEF5350), fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => TransactionReceiptScreen(
                              transactionRef: res.reference.isNotEmpty ? res.reference : 'TX_${DateTime.now().millisecondsSinceEpoch}',
                              amount: amount,
                              recipientName: recipientName,
                              bankName: bankName,
                              dateTimeText: DateTime.now().toString().substring(0, 16),
                              transactionFee: '₦10.00',
                              statusText: isVerified ? 'VERIFIED' : 'HELD_FOR_REVIEW',
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        isVerified ? 'View Transaction Receipt' : 'Track Status on Receipt & Dashboard',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

  Widget _buildSummaryRow(String label, String value, {Color valueColor = Colors.white}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        Flexible(
          child: Text(
            value,
            style: TextStyle(color: valueColor, fontSize: 12, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bankService = Provider.of<BankingService>(context);
    final activeAcc = bankService.activeAccount;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF060D09) : const Color(0xFFF4F7F5);
    final textColor = isDark ? Colors.white : const Color(0xFF0B1F17);
    final subtextColor = isDark ? const Color(0xFF7A9489) : const Color(0xFF6B7E76);
    final cardBgColor = isDark ? const Color(0xFF0D1E17) : Colors.white;
    final borderColor = isDark ? const Color(0xFF162E24) : const Color(0xFFE2EDE8);
    const green = Color(0xFF00C88C);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Send Money',
          style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
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
                    // ── SEGMENTED TRANSFER TYPE TAB SELECTOR ──
                    Container(
                      height: 48,
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
                                  color: _transferTab == 0 ? green : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Iconsax.flash_1, size: 14, color: _transferTab == 0 ? Colors.black : green),
                                      const SizedBox(width: 4),
                                      Text(
                                        'To Tranzfa User',
                                        style: TextStyle(
                                          color: _transferTab == 0 ? Colors.black : textColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
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
                                  color: _transferTab == 1 ? green : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Iconsax.bank, size: 14, color: _transferTab == 1 ? Colors.black : subtextColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        'To Other Banks',
                                        style: TextStyle(
                                          color: _transferTab == 1 ? Colors.black : textColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _transferTab = 2),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _transferTab == 2 ? green : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    'Crypto / Global',
                                    style: TextStyle(
                                      color: _transferTab == 2 ? Colors.black : subtextColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── TAB 0: TRANSFER TO TRANZFA USER ──
                    if (_transferTab == 0) ...[
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Tranzfa Tag or Phone Number',
                                  style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: green.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    '⚡ Free & Instant',
                                    style: TextStyle(color: green, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _tranzfaUserInput,
                              style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
                              onChanged: (val) {
                                setState(() {
                                  _resolvedTranzfaName = val.isNotEmpty ? '$val • Verified Tranzfa User ✓' : 'Sarah Okonjo';
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Enter @username, Tag or 080...',
                                hintStyle: TextStyle(color: subtextColor, fontSize: 14),
                                border: InputBorder.none,
                              ),
                            ),
                            const Divider(color: Colors.white12),
                            Row(
                              children: [
                                const Icon(Icons.check_circle, color: green, size: 16),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _resolvedTranzfaName,
                                    style: const TextStyle(color: green, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    // ── TAB 1: TRANSFER TO OTHER BANKS ──
                    if (_transferTab == 1) ...[
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
                            const Text(
                              'Select Destination Bank',
                              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),

                            // Bank Dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedBank,
                              dropdownColor: const Color(0xFF0D1E17),
                              style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              items: _nigerianBanks.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedBank = val);
                              },
                            ),

                            const SizedBox(height: 14),

                            const Text(
                              '10-Digit Account Number (NUBAN)',
                              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),

                            TextField(
                              controller: _accountNumberController,
                              keyboardType: TextInputType.number,
                              maxLength: 10,
                              style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                              onChanged: (val) {
                                if (val.length == 10) {
                                  setState(() => _resolvedBankName = 'Oluwaseun Adeyemi');
                                }
                              },
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: '0123456789',
                                hintStyle: TextStyle(color: subtextColor, fontSize: 14),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),

                            const SizedBox(height: 10),

                            Row(
                              children: [
                                const Icon(Icons.check_circle, color: green, size: 16),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Account Name: $_resolvedBankName',
                                    style: const TextStyle(color: green, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    // ── TAB 2: CRYPTO / GLOBAL TRANSFERS ──
                    if (_transferTab == 2) ...[
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
                            const Text(
                              'Crypto Address or Global IBAN',
                              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              style: TextStyle(color: textColor, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Enter USDC/USDT address or ACH / SEPA IBAN',
                                hintStyle: TextStyle(color: subtextColor, fontSize: 13),
                                border: InputBorder.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // ── QUICK RECENT CONTACTS AVATAR CAROUSEL ──
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'RECENT RECIPIENTS',
                        style: TextStyle(
                          color: subtextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(_contacts.length, (index) {
                          final isSelected = _selectedContactIndex == index;
                          final contact = _contacts[index];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedContactIndex = index;
                                if (contact['isTranzfa'] == 'true') {
                                  _transferTab = 0;
                                  _tranzfaUserInput.text = contact['accountNo']!;
                                  _resolvedTranzfaName = '${contact['fullName']} • ${contact['accountNo']}';
                                } else {
                                  _transferTab = 1;
                                  _selectedBank = contact['bank']!;
                                  _accountNumberController.text = contact['accountNo']!;
                                  _resolvedBankName = contact['fullName']!;
                                }
                              });
                            },
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
                                            color: isSelected ? green : Colors.transparent,
                                            width: 2.5,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 26,
                                          backgroundColor: const Color(0xFF0E3A2C),
                                          child: Text(
                                            contact['name']![0],
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
                                            style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
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

                    const SizedBox(height: 24),

                    // ── AMOUNT TO SEND DISPLAY ──
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
                            color: green,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatAmount(_amountDigits),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.0,
                          ),
                        ),
                        Container(
                          width: 3,
                          height: 32,
                          margin: const EdgeInsets.only(left: 4),
                          color: green,
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Balance Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF051C14) : const Color(0xFFE2EDE8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Balance: ${activeAcc.symbol}${_formatAmount(activeAcc.balance.toStringAsFixed(0))}',
                        style: const TextStyle(
                          color: green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // NUMERIC KEYPAD GRID
            Container(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
              color: isDark ? const Color(0xFF03140C) : const Color(0xFFEAF2EE),
              child: Column(
                children: [
                  _buildKeypadRow(['1', '2', '3'], textColor, subtextColor),
                  const SizedBox(height: 10),
                  _buildKeypadRow(['4', '5', '6'], textColor, subtextColor),
                  const SizedBox(height: 10),
                  _buildKeypadRow(['7', '8', '9'], textColor, subtextColor),
                  const SizedBox(height: 10),
                  _buildKeypadRow(['.', '0', 'backspace'], textColor, subtextColor),
                ],
              ),
            ),

            // CONTINUE BUTTON
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
              child: SizedBox(
                width: double.infinity,
                height: 52,
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
            height: 40,
            alignment: Alignment.center,
            child: key == 'backspace'
                ? Icon(Icons.backspace_outlined, color: subtextColor, size: 22)
                : Text(
                    key,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      }).toList(),
    );
  }
}
