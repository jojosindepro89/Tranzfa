import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/banking_service.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';
import 'signup_flow_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _credentialsController = TextEditingController(text: "sarah.okonjo@tranzfa.io");
  final TextEditingController _passwordController = TextEditingController(text: "••••••••");
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _credentialsController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    final res = await ApiService.loginFactor1(
      email: _credentialsController.text,
      password: _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (res['success'] == true) {
      // Prompt Factor 2 OTP Modal Sheet
      _showFactor2OtpModal(res['email'] ?? _credentialsController.text, res['otpDemoCode'] ?? '123456');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Authentication failed')),
      );
    }
  }

  // FACTOR 2: 6-DIGIT OTP VERIFICATION MODAL SHEET
  void _showFactor2OtpModal(String email, String demoOtp) {
    final otpControllers = List.generate(6, (_) => TextEditingController());
    bool isVerifyingOtp = false;

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
                        child: const Icon(Icons.security_rounded, color: Color(0xFF00C88C), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Factor 2 Authentication (2FA)',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Enter 6-digit OTP code sent to $email',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 6-DIGIT INPUT BOXES
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 44,
                        height: 52,
                        child: TextField(
                          controller: otpControllers[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: const Color(0xFF14241E),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF1E3A2F)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF00C88C), width: 2),
                            ),
                          ),
                          onChanged: (val) {
                            if (val.isNotEmpty && index < 5) {
                              FocusScope.of(context).nextFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isVerifyingOtp
                          ? null
                          : () async {
                              final otpCode = otpControllers.map((c) => c.text).join();
                              final codeToUse = otpCode.length == 6 ? otpCode : demoOtp;

                              setModalState(() => isVerifyingOtp = true);

                              final res = await ApiService.verifyFactor2Otp(
                                email: email,
                                otp: codeToUse,
                              );

                              setModalState(() => isVerifyingOtp = false);

                              if (res['success'] == true) {
                                Navigator.of(modalContext).pop();
                                // Proceed to Factor 3 PIN Verification
                                _showFactor3PinModal();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(res['message'] ?? 'OTP Verification Failed')),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C88C),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: isVerifyingOtp
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text(
                              'Verify OTP (2FA)',
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

  // FACTOR 3: BIOMETRIC / 4-DIGIT SECURITY PIN MODAL SHEET
  void _showFactor3PinModal() {
    final pinController = TextEditingController(text: "1234");
    bool isVerifyingPin = false;

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
                border: Border(top: BorderSide(color: Color(0xFFE5B800), width: 1.5)),
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
                          color: const Color(0xFFE5B800).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.fingerprint_rounded, color: Color(0xFFE5B800), size: 28),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Factor 3 Security PIN (3FA)',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Enter 4-digit PIN or use Biometric FaceID',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // PIN INPUT FIELD
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
                        borderSide: const BorderSide(color: Color(0xFFE5B800), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isVerifyingPin
                          ? null
                          : () async {
                              setModalState(() => isVerifyingPin = true);

                              final res = await ApiService.verifyFactor3Pin(
                                pin: pinController.text.isNotEmpty ? pinController.text : "1234",
                              );

                              setModalState(() => isVerifyingPin = false);

                              if (res['success'] == true) {
                                Navigator.of(modalContext).pop();

                                if (!mounted) return;
                                final bankService = Provider.of<BankingService>(context, listen: false);
                                bankService.login("Sarah Okonjo", _credentialsController.text);

                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(res['message'] ?? 'Invalid Transaction PIN')),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE5B800),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: isVerifyingPin
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text(
                              'Complete 3FA Login ',
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

  // BIOMETRIC LOGIN HANDLER (FINGERPRINT / FACE ID)
  void _handleBiometricLogin() {
    bool isScanning = true;
    bool isSuccess = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Trigger quick biometric scan simulation
            if (isScanning && !isSuccess) {
              Future.delayed(const Duration(milliseconds: 1400), () {
                if (modalContext.mounted) {
                  setModalState(() {
                    isScanning = false;
                    isSuccess = true;
                  });

                  Future.delayed(const Duration(milliseconds: 600), () {
                    if (modalContext.mounted) {
                      Navigator.of(modalContext).pop();

                      if (!mounted) return;
                      final bankService = Provider.of<BankingService>(context, listen: false);
                      bankService.login("Sarah Okonjo", _credentialsController.text);

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const DashboardScreen()),
                      );
                    }
                  });
                }
              });
            }

            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF0C1713),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                border: Border(top: BorderSide(color: Color(0xFFE5B800), width: 2)),
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
                  const SizedBox(height: 24),

                  // BIOMETRIC ICON RING WITH GLOW
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: const Color(0xFF14241E),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSuccess ? const Color(0xFF00C88C) : const Color(0xFFE5B800),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isSuccess ? const Color(0xFF00C88C) : const Color(0xFFE5B800)).withOpacity(0.3),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        isSuccess ? Icons.check_circle_rounded : Icons.fingerprint_rounded,
                        color: isSuccess ? const Color(0xFF00C88C) : const Color(0xFFE5B800),
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    isSuccess ? 'Biometrics Authenticated!' : 'Biometric Security Check',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    isSuccess
                        ? 'Welcome back, Sarah. Access granted.'
                        : 'Touch sensor or look at screen for Face ID & Fingerprint auth',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSuccess ? const Color(0xFF00C88C) : const Color(0xFF8E9E98),
                      fontSize: 13,
                      fontWeight: isSuccess ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 28),

                  if (isScanning)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Color(0xFFE5B800), strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Verifying Face ID & Touch ID...',
                          style: TextStyle(color: Color(0xFFE5B800), fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    )
                  else
                    const Text(
                      'Redirecting to secure dashboard...',
                      style: TextStyle(color: Color(0xFF00C88C), fontSize: 13, fontWeight: FontWeight.bold),
                    ),

                  const SizedBox(height: 20),

                  // FALLBACK TO PIN
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(modalContext).pop();
                      _showFactor3PinModal();
                    },
                    icon: const Icon(Icons.dialpad_rounded, color: Colors.white70, size: 16),
                    label: const Text(
                      'Use 4-Digit Security PIN Instead',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
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

  // PIN LOGIN HANDLER
  void _handlePinLogin() {
    _showFactor3PinModal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060B0E),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.9),
              radius: 1.2,
              colors: [
                Color(0xFF0A3326), // Top dark emerald radial glow
                Color(0xFF060D12), // Blending to dark obsidian
              ],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),

                      // LOGO & APP BRANDING
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C241B),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF1E4D3B), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEF531D).withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Color(0xFFEF531D),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Tranzfa',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // WELCOME BACK HEADING
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Securely access your premium assets',
                        style: TextStyle(
                          color: Color(0xFF8E9E98),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // FORM FIELDS
                      // Field 1: Phone Number or Email
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PHONE NUMBER OR EMAIL',
                            style: TextStyle(
                              color: Color(0xFF7E928A),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _credentialsController,
                              style: const TextStyle(
                                color: Color(0xFF0F1E19),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Enter your credentials',
                                hintStyle: TextStyle(
                                  color: Color(0xFF909E97),
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Field 2: Password + Forgot Password
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'PASSWORD',
                                style: TextStyle(
                                  color: Color(0xFF7E928A),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Color(0xFFEF531D),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              style: const TextStyle(
                                color: Color(0xFF0F1E19),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF909E97),
                                  fontSize: 15,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                border: InputBorder.none,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: const Color(0xFF5E7068),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // LOG IN MAIN BUTTON (ORANGE PILL)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF531D),
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shadowColor: const Color(0xFFEF531D).withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      'Log In',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // DIVIDER: OR SECURE ACCESS VIA
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: const Color(0xFF1B2C24),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14.0),
                            child: Text(
                              'OR SECURE ACCESS VIA',
                              style: TextStyle(
                                color: Color(0xFF6B7E76),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: const Color(0xFF1B2C24),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // BIOMETRICS & PIN ACCESS CARDS
                      Row(
                        children: [
                          // Biometrics Option
                          Expanded(
                            child: GestureDetector(
                              onTap: _handleBiometricLogin,
                              child: Container(
                                height: 96,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0C1713),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: const Color(0xFF00C88C).withOpacity(0.5), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00C88C).withOpacity(0.1),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.fingerprint,
                                      color: Color(0xFFE5B800),
                                      size: 36,
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'BIOMETRICS',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 14),

                          // Sign In with PIN Option
                          Expanded(
                            child: GestureDetector(
                              onTap: _handlePinLogin,
                              child: Container(
                                height: 96,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0C1713),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: const Color(0xFF172B23), width: 1.2),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.dialpad_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'SIGN IN WITH PIN',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 36),

                      // SIGN UP FOOTER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              color: Color(0xFF8E9E98),
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const SignupFlowScreen()),
                              );
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Color(0xFFEF531D),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),

              // ENCRYPTED SECURITY BADGE AT BOTTOM
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.shield_outlined, color: Color(0xFF5A6B64), size: 14),
                    SizedBox(width: 6),
                    Text(
                      '256-BIT ENCRYPTED SECURITY',
                      style: TextStyle(
                        color: Color(0xFF5A6B64),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
