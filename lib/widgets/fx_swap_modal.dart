import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/banking_service.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class FxSwapModal extends StatefulWidget {
  const FxSwapModal({super.key});

  @override
  State<FxSwapModal> createState() => _FxSwapModalState();
}

class _FxSwapModalState extends State<FxSwapModal> {
  String _fromAsset = "USDC";
  String _toAsset = "USD";
  final _amountController = TextEditingController(text: "100");
  bool _isSwapping = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bankService = Provider.of<BankingService>(context);
    final fromAmount = double.tryParse(_amountController.text) ?? 0.0;
    final rate = bankService.getExchangeRate(_fromAsset, _toAsset);
    final calculatedReceive = (fromAmount * rate).toStringAsFixed(2);

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
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.swap_horizontal_circle, color: AppTheme.goldPrimary, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Tranzfa Auto-Convert & Swap',
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

          // Pay From Card
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('You Pay', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    DropdownButton<String>(
                      value: _fromAsset,
                      dropdownColor: AppTheme.darkEmeraldCard,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'USDC', child: Text('₮ USDC')),
                        DropdownMenuItem(value: 'BTC', child: Text('₿ BTC')),
                        DropdownMenuItem(value: 'USD', child: Text(' USD')),
                        DropdownMenuItem(value: 'EUR', child: Text(' EUR')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _fromAsset = val);
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        decoration: const InputDecoration(border: InputBorder.none, hintText: '0.00'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Swap Arrow Button
          GestureDetector(
            onTap: () {
              setState(() {
                final temp = _fromAsset;
                _fromAsset = _toAsset;
                _toAsset = temp;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.emeraldPrimary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppTheme.emeraldAccent.withOpacity(0.4), blurRadius: 10),
                ],
              ),
              child: const Icon(Icons.swap_vert, color: Colors.white, size: 24),
            ),
          ),

          // Receive Card
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('You Receive (Estimated)', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton<String>(
                      value: _toAsset,
                      dropdownColor: AppTheme.darkEmeraldCard,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'USD', child: Text(' USD')),
                        DropdownMenuItem(value: 'EUR', child: Text(' EUR')),
                        DropdownMenuItem(value: 'GBP', child: Text(' GBP')),
                        DropdownMenuItem(value: 'USDC', child: Text('₮ USDC')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _toAsset = val);
                      },
                    ),
                    Text(
                      calculatedReceive,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.goldPrimary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Guaranteed Exchange Rate', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              Text('1 $_fromAsset = $rate $_toAsset', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSwapping
                  ? null
                  : () async {
                      setState(() => _isSwapping = true);
                      final success = await bankService.executeCryptoSwap(
                        fromCode: _fromAsset,
                        toCode: _toAsset,
                        fromAmount: fromAmount,
                      );
                      setState(() => _isSwapping = false);
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'Swap Executed! Received $calculatedReceive $_toAsset'
                                  : 'Swap failed. Check balance.',
                            ),
                          ),
                        );
                      }
                    },
              child: _isSwapping
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Confirm Instant Swap'),
            ),
          ),
        ],
      ),
    );
  }
}
