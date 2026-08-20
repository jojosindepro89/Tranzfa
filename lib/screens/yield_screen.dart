import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/banking_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class YieldScreen extends StatefulWidget {
  const YieldScreen({super.key});

  @override
  State<YieldScreen> createState() => _YieldScreenState();
}

class _YieldScreenState extends State<YieldScreen> {
  double _depositSlider = 15000.0;

  @override
  Widget build(BuildContext context) {
    final bankService = Provider.of<BankingService>(context);
    final annualYield = (_depositSlider * 0.085).toStringAsFixed(2);
    final monthlyYield = ((_depositSlider * 0.085) / 12).toStringAsFixed(2);

    return Scaffold(
      backgroundColor: AppTheme.obsidianBg,
      appBar: AppBar(
        title: const Text('Tranzfa APY Yield Vaults', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner Card
              GlassCard(
                borderColor: AppTheme.goldBorder,
                backgroundColor: const Color(0xFF0C2B1E).withOpacity(0.8),
                child: Column(
                  children: [
                    const Icon(Icons.pie_chart, color: AppTheme.goldPrimary, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      '8.50% APY USDC Vault',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Daily compounding interest paid directly in USDC with instant liquidity.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Active Vaults
              const Text('Active Yield Balances', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),

              ...bankService.yieldVaults.map((vault) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(vault.assetName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('Earned: +${vault.totalEarnedInterest.toStringAsFixed(2)} ${vault.symbol}', style: const TextStyle(color: AppTheme.emeraldAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${vault.depositedAmount.toStringAsFixed(2)} ${vault.symbol}', style: const TextStyle(color: AppTheme.goldPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('${vault.apy}% APY', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 20),

              // Interactive Yield Calculator
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Yield Growth Projection', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Deposit Amount:', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                        Text('\$${_depositSlider.toStringAsFixed(0)} USDC', style: const TextStyle(color: AppTheme.goldPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    Slider(
                      value: _depositSlider,
                      min: 1000,
                      max: 100000,
                      divisions: 99,
                      activeColor: AppTheme.goldPrimary,
                      inactiveColor: AppTheme.emeraldDark,
                      onChanged: (val) => setState(() => _depositSlider = val),
                    ),
                    const Divider(color: Colors.white12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Est. Monthly Earnings:', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                        Text('+\$$monthlyYield USDC', style: const TextStyle(color: AppTheme.emeraldAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Est. Annual Earnings:', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                        Text('+\$$annualYield USDC', style: const TextStyle(color: AppTheme.goldPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Deposited to 8.5% Yield Vault!')),
                    );
                  },
                  child: const Text('Deposit Funds to Yield Vault'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
