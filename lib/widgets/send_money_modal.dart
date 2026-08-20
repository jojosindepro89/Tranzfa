import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/banking_models.dart';
import '../services/banking_service.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class SendMoneyModal extends StatefulWidget {
  const SendMoneyModal({super.key});

  @override
  State<SendMoneyModal> createState() => _SendMoneyModalState();
}

class _SendMoneyModalState extends State<SendMoneyModal> {
  int _step = 1; // 1: Recipient, 2: Amount & Rail, 3: PIN Verification, 4: Receipt
  final _recipientController = TextEditingController(text: "@elena_r");
  final _amountController = TextEditingController(text: "500");
  String _selectedCurrency = "USD";
  RailType _selectedRail = RailType.speedRail;

  String _pin = "";
  bool _isProcessing = false;
  int _rateLockSeconds = 60;
  Timer? _rateTimer;
  String _speedSettled = "0.7 sec";

  @override
  void initState() {
    super.initState();
    _startRateLockTimer();
  }

  void _startRateLockTimer() {
    _rateTimer?.cancel();
    _rateLockSeconds = 60;
    _rateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_rateLockSeconds > 0) {
        if (mounted) setState(() => _rateLockSeconds--);
      } else {
        _rateLockSeconds = 60; // Auto renew
      }
    });
  }

  @override
  void dispose() {
    _rateTimer?.cancel();
    _recipientController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onPinDigit(String digit) {
    if (_pin.length < 4) {
      setState(() {
        _pin += digit;
      });
      if (_pin.length == 4) {
        _submitTransfer();
      }
    }
  }

  void _onPinDelete() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  Future<void> _submitTransfer() async {
    setState(() => _isProcessing = true);
    final bankService = Provider.of<BankingService>(context, listen: false);

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final success = await bankService.executeSpeedTransfer(
      recipientName: _recipientController.text.replaceAll('@', '').toUpperCase(),
      recipientTag: _recipientController.text,
      amount: amount,
      currencyCode: _selectedCurrency,
      rail: _selectedRail,
    );

    await Future.delayed(const Duration(milliseconds: 1200)); // Visual rail speed simulation

    if (mounted) {
      setState(() {
        _isProcessing = false;
        if (success) {
          _step = 4; // Show Receipt
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Insufficient account balance.')),
          );
          _pin = "";
          _step = 2;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 24,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.obsidianBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle Header
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.bolt_rounded, color: AppTheme.goldPrimary, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Speed Transfer',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_step == 1) _buildStep1Recipient(),
          if (_step == 2) _buildStep2AmountAndRail(),
          if (_step == 3) _buildStep3PinVerification(),
          if (_step == 4) _buildStep4Receipt(),
        ],
      ),
    );
  }

  // STEP 1: Recipient Selection
  Widget _buildStep1Recipient() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Recipient Tag or IBAN',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _recipientController,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: '@username, IBAN, or Solana/BTC address',
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: const Icon(Icons.search, color: AppTheme.emeraldAccent),
            filled: true,
            fillColor: AppTheme.darkEmeraldCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.goldBorder),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Quick Contacts',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildQuickContact('@elena_r', 'Elena Rostova', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100'),
              _buildQuickContact('@marcus_v', 'Marcus Vance', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100'),
              _buildQuickContact('@sophia_k', 'Sophia Chen', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => setState(() => _step = 2),
            child: const Text('Continue to Amount'),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickContact(String tag, String name, String avatar) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _recipientController.text = tag;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: AppTheme.glassBoxDecoration(
          borderRadius: BorderRadius.circular(16),
          borderCol: _recipientController.text == tag ? AppTheme.goldPrimary : AppTheme.glassBorder,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(avatar),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                Text(tag, style: const TextStyle(color: AppTheme.goldPrimary, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // STEP 2: Amount & Speed Rail
  Widget _buildStep2AmountAndRail() {
    return Column(
      children: [
        // Rate Lock Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.goldPrimary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.goldPrimary.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer, color: AppTheme.goldPrimary, size: 14),
              const SizedBox(width: 6),
              Text(
                'Rate Locked: 0% Fee • ${_rateLockSeconds}s remaining',
                style: const TextStyle(color: AppTheme.goldPrimary, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Amount Input Field
        GlassCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(
                    value: _selectedCurrency,
                    dropdownColor: AppTheme.darkEmeraldCard,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'USD', child: Text('🇺🇸 USD')),
                      DropdownMenuItem(value: 'EUR', child: Text('🇪🇺 EUR')),
                      DropdownMenuItem(value: 'GBP', child: Text('🇬🇧 GBP')),
                      DropdownMenuItem(value: 'USDC', child: Text('₮ USDC')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCurrency = val);
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.goldPrimary,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '0.00',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Speed Rail Selector
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Transfer Rail Speed',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        const SizedBox(height: 10),
        _buildRailOption(
          RailType.speedRail,
          '⚡ Lightning Rail (<2 sec)',
          'Instant Settlement via Tranzfa Global Core',
          'Free',
        ),
        const SizedBox(height: 8),
        _buildRailOption(
          RailType.swift,
          '🏦 SWIFT / Fedwire (ISO 20022)',
          'Standard Global Institutional Bank Wire',
          '\$2.50',
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => setState(() => _step = 3),
            child: const Text('Review & Enter PIN'),
          ),
        ),
      ],
    );
  }

  Widget _buildRailOption(RailType rail, String title, String subtitle, String fee) {
    final isSelected = _selectedRail == rail;
    return GestureDetector(
      onTap: () => setState(() => _selectedRail = rail),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppTheme.glassBoxDecoration(
          borderRadius: BorderRadius.circular(16),
          borderCol: isSelected ? AppTheme.goldPrimary : AppTheme.glassBorder,
          bgCol: isSelected ? AppTheme.emeraldDark.withOpacity(0.4) : AppTheme.darkEmeraldCard.withOpacity(0.5),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppTheme.goldPrimary : AppTheme.textMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                ],
              ),
            ),
            Text(fee, style: const TextStyle(color: AppTheme.emeraldAccent, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // STEP 3: Security PIN Verification
  Widget _buildStep3PinVerification() {
    return Column(
      children: [
        const Icon(Icons.security, color: AppTheme.emeraldAccent, size: 48),
        const SizedBox(height: 12),
        const Text(
          'Security Verification',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Enter 4-Digit Security PIN to confirm ${_amountController.text} $_selectedCurrency to ${_recipientController.text}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 20),

        // PIN Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            final isFilled = index < _pin.length;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled ? AppTheme.goldPrimary : Colors.transparent,
                border: Border.all(
                  color: isFilled ? AppTheme.goldPrimary : Colors.white38,
                  width: 2,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),

        if (_isProcessing)
          Column(
            children: const [
              CircularProgressIndicator(color: AppTheme.goldPrimary),
              SizedBox(height: 12),
              Text(
                'Routing through ⚡ Lightning Speed Rail...',
                style: TextStyle(color: AppTheme.goldPrimary, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          )
        else
          // Keypad 0-9
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.2,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              if (index == 9) return const SizedBox();
              if (index == 10) return _buildKeypadButton('0', () => _onPinDigit('0'));
              if (index == 11) return _buildKeypadButton('⌫', _onPinDelete);
              final digit = (index + 1).toString();
              return _buildKeypadButton(digit, () => _onPinDigit(digit));
            },
          ),
      ],
    );
  }

  Widget _buildKeypadButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // STEP 4: Success Receipt
  Widget _buildStep4Receipt() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.emeraldAccent.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, color: AppTheme.emeraldAccent, size: 64),
        ),
        const SizedBox(height: 16),
        const Text(
          'Transfer Settled!',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bolt, color: AppTheme.goldPrimary, size: 16),
            const SizedBox(width: 4),
            Text(
              'Speed Settled in $_speedSettled',
              style: const TextStyle(color: AppTheme.goldPrimary, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 20),

        GlassCard(
          child: Column(
            children: [
              _buildReceiptRow('Amount Sent', '${_amountController.text} $_selectedCurrency'),
              const Divider(color: Colors.white12),
              _buildReceiptRow('Recipient', _recipientController.text),
              const Divider(color: Colors.white12),
              _buildReceiptRow('Rail Network', '⚡ Tranzfa Lightning Rail'),
              const Divider(color: Colors.white12),
              _buildReceiptRow('Transaction ID', 'TX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}'),
            ],
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Dashboard'),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
