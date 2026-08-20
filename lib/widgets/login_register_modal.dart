import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/banking_service.dart';
import '../theme/app_theme.dart';

class LoginRegisterModal extends StatefulWidget {
  final bool isLoginInitial;
  const LoginRegisterModal({super.key, this.isLoginInitial = false});

  @override
  State<LoginRegisterModal> createState() => _LoginRegisterModalState();
}

class _LoginRegisterModalState extends State<LoginRegisterModal> {
  late bool _isLoginMode;
  final _nameController = TextEditingController(text: "Alex Sterling");
  final _emailController = TextEditingController(text: "alex.sterling@tranzfa.io");
  final _passwordController = TextEditingController(text: "••••••••");
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isLoginMode = widget.isLoginInitial;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bankService = Provider.of<BankingService>(context, listen: false);

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: AppTheme.emeraldDark, shape: BoxShape.circle),
                    child: const Icon(Icons.diamond_outlined, color: AppTheme.goldPrimary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _isLoginMode ? 'Welcome Back to Tranzfa' : 'Create Tranzfa Account',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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

          if (!_isLoginMode) ...[
            const Text('Full Name', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Alex Sterling',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: AppTheme.darkEmeraldCard,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 12),
          ],

          const Text('Email Address', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 6),
          TextField(
            controller: _emailController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'alex.sterling@tranzfa.io',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: AppTheme.darkEmeraldCard,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 12),

          const Text('Passcode', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 6),
          TextField(
            controller: _passwordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: AppTheme.darkEmeraldCard,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 20),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() => _isLoading = true);
                      await Future.delayed(const Duration(milliseconds: 800));
                      bankService.login(_nameController.text, _emailController.text);
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(_isLoginMode ? 'Log In' : 'Create Vault & Account'),
            ),
          ),
          const SizedBox(height: 12),

          // Toggle Mode
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _isLoginMode = !_isLoginMode;
                });
              },
              child: Text(
                _isLoginMode ? "Don't have an account? Sign Up" : "Already have an account? Log In",
                style: const TextStyle(color: AppTheme.goldPrimary, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
