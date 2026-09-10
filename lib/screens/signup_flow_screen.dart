import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/banking_service.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';

class SignupFlowScreen extends StatefulWidget {
  const SignupFlowScreen({super.key});

  @override
  State<SignupFlowScreen> createState() => _SignupFlowScreenState();
}

class _SignupFlowScreenState extends State<SignupFlowScreen> {
  int _currentStep = 1; // Steps 1 to 4

  // STEP 1 State: Mobile Number
  String _phoneNumber = "";
  String _countryCode = "+1";
  String _countryFlag = "";

  // STEP 2 State: Personal Details
  final TextEditingController _fullNameController = TextEditingController(text: "Johnathan Doe");
  final TextEditingController _dobController = TextEditingController(text: "05/14/1995");
  final TextEditingController _bvnController = TextEditingController(text: "22384910482");
  bool _isBvnObscured = true;

  // STEP 3 State: ID Type Selection
  int _selectedIdTypeIndex = 0;
  final List<Map<String, String>> _idOptions = [
    {
      'title': 'International Passport',
      'subtitle': 'Requires a valid expiration date',
      'icon': 'globe',
    },
    {
      'title': 'National ID (NIN)',
      'subtitle': 'Use your 11-digit NIN',
      'icon': 'fingerprint',
    },
    {
      'title': 'Driver\'s License',
      'subtitle': 'Plastic or digital copy',
      'icon': 'car',
    },
    {
      'title': 'Voter\'s Card',
      'subtitle': 'Standard permanent voter\'s card',
      'icon': 'voter',
    },
  ];

  // STEP 4 State: Document Scan
  bool _isFlashOn = false;
  bool _isCapturing = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _bvnController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
    } else {
      _completeSignup();
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void _completeSignup() async {
    setState(() {
      _isCapturing = true;
    });

    final name = _fullNameController.text.isNotEmpty ? _fullNameController.text : "Sarah Okonjo";
    
    await ApiService.registerUser(
      fullName: name,
      email: "sarah.okonjo@tranzfa.io",
      phone: _phoneNumber.isNotEmpty ? _phoneNumber : "5551234567",
      bvn: _bvnController.text,
    );

    if (!mounted) return;
    final bankService = Provider.of<BankingService>(context, listen: false);
    bankService.login(name, "sarah.okonjo@tranzfa.io");

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
      (route) => false,
    );
  }

  // Keypad Tap Handler for Step 1
  void _onKeyPress(String key) {
    if (key == 'backspace') {
      if (_phoneNumber.isNotEmpty) {
        setState(() {
          _phoneNumber = _phoneNumber.substring(0, _phoneNumber.length - 1);
        });
      }
    } else {
      if (_phoneNumber.length < 10) {
        setState(() {
          _phoneNumber += key;
        });
      }
    }
  }

  String _formatPhoneNumber(String digits) {
    if (digits.isEmpty) return "(555) 000-0000";
    String res = "";
    if (digits.isNotEmpty) {
      res += "(${digits.substring(0, digits.length >= 3 ? 3 : digits.length)}";
      if (digits.length >= 3) res += ") ";
    }
    if (digits.length > 3) {
      res += digits.substring(3, digits.length >= 6 ? 6 : digits.length);
      if (digits.length >= 6) res += "-";
    }
    if (digits.length > 6) {
      res += digits.substring(6, digits.length >= 10 ? 10 : digits.length);
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF040E0A),
      body: SafeArea(
        child: Column(
          children: [
            // TOP NAVIGATION & STEP PROGRESS BAR
            _buildTopStepHeader(),

            // DYNAMIC STEP CONTENT BODY
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentStepView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header with back arrow and progress bar
  Widget _buildTopStepHeader() {
    double progress = _currentStep / 4.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
                onPressed: _previousStep,
              ),
              Text(
                _currentStep == 3 ? 'Step 2 of 3' : 'STEP $_currentStep OF 4',
                style: const TextStyle(
                  color: Color(0xFFE5B800),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              _currentStep == 4
                  ? Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE5B800),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '?',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar track
          Container(
            height: 3,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF0C2B1E),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: _currentStep == 3 || _currentStep == 4 ? const Color(0xFFE5B800) : const Color(0xFF00C88C),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 1:
        return _buildStep1MobileNumber();
      case 2:
        return _buildStep2PersonalDetails();
      case 3:
        return _buildStep3IdTypeSelection();
      case 4:
        return _buildStep4DocumentScan();
      default:
        return _buildStep1MobileNumber();
    }
  }

  // ==========================================
  // STEP 1: Enter Mobile Number + Custom Keypad
  // ==========================================
  Widget _buildStep1MobileNumber() {
    return KeyedSubtree(
      key: const ValueKey(1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter your mobile\nnumber',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "We'll send a code to verify your identity.",
                  style: TextStyle(
                    color: Color(0xFF8E9E98),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 28),

                // Mobile Number Input Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF062319),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF0D4733), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      // Country Flag & Code Dropdown
                      Row(
                        children: [
                          Text(_countryFlag, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 6),
                          Text(
                            _countryCode,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down, color: Color(0xFF8E9E98), size: 18),
                        ],
                      ),
                      Container(
                        height: 28,
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 14),
                        color: const Color(0xFF134231),
                      ),

                      // Formatted Number & Vertical Cursor
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              _formatPhoneNumber(_phoneNumber),
                              style: TextStyle(
                                color: _phoneNumber.isEmpty ? const Color(0xFF4C665C) : Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Container(
                              width: 2,
                              height: 22,
                              margin: const EdgeInsets.only(left: 4),
                              color: const Color(0xFFE5B800),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'SECURE VERIFICATION',
                  style: TextStyle(
                    color: Color(0xFF526D62),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Continue Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _phoneNumber.length >= 7 ? _nextStep : _nextStep, // Demo allows proceeding
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF025839),
                  foregroundColor: Colors.white,
                  elevation: 0,
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

          const SizedBox(height: 20),

          // Custom Numeric Keypad Grid
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: const BoxDecoration(
              color: Color(0xFF031A12),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                _buildKeypadRow(['1', '2', '3']),
                const SizedBox(height: 16),
                _buildKeypadRow(['4', '5', '6']),
                const SizedBox(height: 16),
                _buildKeypadRow(['7', '8', '9']),
                const SizedBox(height: 16),
                _buildKeypadRow(['', '0', 'backspace']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: keys.map((key) {
        if (key.isEmpty) {
          return const SizedBox(width: 80, height: 48);
        }
        return GestureDetector(
          onTap: () => _onKeyPress(key),
          child: Container(
            width: 80,
            height: 48,
            alignment: Alignment.center,
            child: key == 'backspace'
                ? const Icon(Icons.backspace_outlined, color: Color(0xFF8E9E98), size: 22)
                : Text(
                    key,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      }).toList(),
    );
  }

  // ==========================================
  // STEP 2: Tell us a bit about yourself
  // ==========================================
  Widget _buildStep2PersonalDetails() {
    return KeyedSubtree(
      key: const ValueKey(2),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tell us a bit about yourself',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please provide your legal details as they appear on your official documents. This helps us verify your identity.',
              style: TextStyle(
                color: Color(0xFF8E9E98),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),

            // Field 1: Full Legal Name
            const Text(
              'Full Legal Name',
              style: TextStyle(color: Color(0xFFB0C4BC), fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _buildInputField(
              controller: _fullNameController,
              hintText: 'Johnathan Doe',
              icon: Icons.person_outline_rounded,
            ),

            const SizedBox(height: 20),

            // Field 2: Date of Birth
            const Text(
              'Date of Birth',
              style: TextStyle(color: Color(0xFFB0C4BC), fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _buildInputField(
              controller: _dobController,
              hintText: 'mm/dd/yyyy',
              icon: Icons.calendar_today_outlined,
            ),

            const SizedBox(height: 20),

            // Field 3: BVN
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'BVN (Bank Verification Number)',
                  style: TextStyle(color: Color(0xFFB0C4BC), fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: const [
                    Text(
                      'Why we need this?',
                      style: TextStyle(color: Color(0xFF00C88C), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.info_outline, color: Color(0xFF00C88C), size: 13),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInputField(
              controller: _bvnController,
              hintText: '•••••••••••',
              obscureText: _isBvnObscured,
              suffixIcon: IconButton(
                icon: Icon(
                  _isBvnObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: const Color(0xFF5A7067),
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _isBvnObscured = !_isBvnObscured;
                  });
                },
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'ENTER 11-DIGIT VERIFICATION NUMBER',
              style: TextStyle(color: Color(0xFF526D62), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
            ),

            const SizedBox(height: 36),

            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF025839),
                  foregroundColor: Colors.white,
                  elevation: 0,
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

            const SizedBox(height: 28),

            // Footer security notice
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.shield_moon_outlined, color: Color(0xFFE5B800), size: 16),
                SizedBox(width: 8),
                Text(
                  'Your data is secured with institutional-grade encryption',
                  style: TextStyle(color: Color(0xFF8E9E98), fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    IconData? icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF062319),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF0D4733), width: 1.2),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF4C665C), fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          suffixIcon: suffixIcon ?? (icon != null ? Icon(icon, color: const Color(0xFF00C88C).withOpacity(0.5), size: 20) : null),
        ),
      ),
    );
  }

  // ==========================================
  // STEP 3: Identity Verification (ID Type Selection)
  // ==========================================
  Widget _buildStep3IdTypeSelection() {
    return KeyedSubtree(
      key: const ValueKey(3),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'TRANZFA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Identity Verification',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select an ID type to upload',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Please ensure your document is valid and clearly legible.',
              style: TextStyle(
                color: Color(0xFF8E9E98),
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 24),

            // Radio Option List Cards
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _idOptions.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedIdTypeIndex == index;
                final opt = _idOptions[index];

                IconData getOptionIcon(String type) {
                  if (type == 'globe') return Icons.public_rounded;
                  if (type == 'fingerprint') return Icons.fingerprint_rounded;
                  if (type == 'car') return Icons.directions_car_rounded;
                  return Icons.recent_actors_rounded;
                }

                return GestureDetector(
                  onTap: () => setState(() => _selectedIdTypeIndex = index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0A3326) : const Color(0xFF062319),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFE5B800) : const Color(0xFF0D4733),
                        width: isSelected ? 1.8 : 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0E4735),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(getOptionIcon(opt['icon']!), color: const Color(0xFF00C88C), size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                opt['title']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                opt['subtitle']!,
                                style: const TextStyle(
                                  color: Color(0xFF8E9E98),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Radio Button Indicator
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? const Color(0xFFE5B800) : const Color(0xFF4C665C),
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE5B800),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Why is this needed Callout Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF062319).withOpacity(0.6),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF0D3D2D)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_rounded, color: Color(0xFFE5B800), size: 22),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Why is this needed?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'To increase your transaction limits and secure your account. We use bank-grade encryption to protect your data.',
                          style: TextStyle(
                            color: Color(0xFF8E9E98),
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'LEARN MORE  →',
                          style: TextStyle(
                            color: Color(0xFFE5B800),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Solid Gold Continue Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE5B800),
                  foregroundColor: const Color(0xFF041710),
                  elevation: 6,
                  shadowColor: const Color(0xFFE5B800).withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // STEP 4: Upload ID Document (Camera Scan)
  // ==========================================
  Widget _buildStep4DocumentScan() {
    final selectedDocName = _idOptions[_selectedIdTypeIndex]['title']!;

    return KeyedSubtree(
      key: const ValueKey(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Upload your ID Document',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(color: Color(0xFF8E9E98), fontSize: 13, height: 1.35),
                children: [
                  const TextSpan(text: 'Please take a clear photo of the front of your '),
                  TextSpan(
                    text: selectedDocName,
                    style: const TextStyle(color: Color(0xFF00C88C), fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // CAMERA SCANNING FRAME VIEWPORT
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1A17),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xFF2E2924)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Mock Passport Camera Image Graphic inside viewport
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt_outlined, color: Colors.white24, size: 80),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE5B800).withOpacity(0.5)),
                          ),
                          child: const Text(
                            'ALIGN PASSPORT HERE',
                            style: TextStyle(
                              color: Color(0xFFE5B800),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Gold Alignment Bracket Curves
                    Positioned(
                      left: 20,
                      child: Container(
                        width: 24,
                        height: 90,
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(color: Color(0xFFE5B800), width: 3),
                            top: BorderSide(color: Color(0xFFE5B800), width: 3),
                            bottom: BorderSide(color: Color(0xFFE5B800), width: 3),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      child: Container(
                        width: 24,
                        height: 90,
                        decoration: const BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Color(0xFFE5B800), width: 3),
                            top: BorderSide(color: Color(0xFFE5B800), width: 3),
                            bottom: BorderSide(color: Color(0xFFE5B800), width: 3),
                          ),
                        ),
                      ),
                    ),

                    // Tips Floating Pills at Bottom of Viewport
                    Positioned(
                      bottom: 18,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F1814).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF1E332A)),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.wb_sunny_outlined, color: Color(0xFFE5B800), size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'Avoid Glare',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F1814).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF1E332A)),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.remove_red_eye_outlined, color: Color(0xFFE5B800), size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'Text Readable',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // CAMERA SHUTTER & CONTROLS ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Gallery Button
                Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Color(0xFF062319),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.image_outlined, color: Color(0xFF00C88C), size: 22),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'GALLERY',
                      style: TextStyle(color: Color(0xFF8E9E98), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                // Large Main Shutter Button
                GestureDetector(
                  onTap: _completeSignup,
                  child: Container(
                    width: 72,
                    height: 72,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF062319),
                        shape: BoxShape.circle,
                      ),
                      child: _isCapturing
                          ? const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Color(0xFF00C88C), strokeWidth: 2),
                              ),
                            )
                          : const Icon(Icons.camera_alt, color: Color(0xFF00C88C), size: 28),
                    ),
                  ),
                ),

                // Flash Button
                GestureDetector(
                  onTap: () => setState(() => _isFlashOn = !_isFlashOn),
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: _isFlashOn ? const Color(0xFF0E4735) : const Color(0xFF062319),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isFlashOn ? Icons.flash_on : Icons.flash_on_outlined,
                          color: _isFlashOn ? const Color(0xFFE5B800) : const Color(0xFF00C88C),
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'FLASH',
                        style: TextStyle(color: Color(0xFF8E9E98), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Text(
              'Trouble scanning? Try another document',
              style: TextStyle(
                color: Color(0xFF00C88C),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            // Footer Notice
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF062319).withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.check_circle_outline, color: Color(0xFF00C88C), size: 14),
                  SizedBox(width: 6),
                  Text(
                    'End-to-end encrypted & secure',
                    style: TextStyle(color: Color(0xFF8E9E98), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
