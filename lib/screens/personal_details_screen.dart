import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../services/banking_service.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _nokNameController;
  late TextEditingController _nokRelController;
  late TextEditingController _nokPhoneController;

  bool _showBvn = false;
  bool _showNin = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final service = Provider.of<BankingService>(context, listen: false);
    _fullNameController = TextEditingController(text: service.userFullName);
    _emailController = TextEditingController(text: service.userEmail);
    _phoneController = TextEditingController(text: service.userPhone);
    _addressController = TextEditingController(text: service.userAddress);
    _nokNameController = TextEditingController(text: service.nextOfKinName);
    _nokRelController = TextEditingController(text: service.nextOfKinRelationship);
    _nokPhoneController = TextEditingController(text: service.nextOfKinPhone);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _nokNameController.dispose();
    _nokRelController.dispose();
    _nokPhoneController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    setState(() => _isSaving = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final bankService = Provider.of<BankingService>(context, listen: false);
      bankService.updatePersonalDetails(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        nextOfKinName: _nokNameController.text.trim(),
        nextOfKinRelationship: _nokRelController.text.trim(),
        nextOfKinPhone: _nokPhoneController.text.trim(),
      );

      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: Color(0xFF00C88C)),
              SizedBox(width: 10),
              Text('Personal Details successfully updated!'),
            ],
          ),
          backgroundColor: const Color(0xFF0D281E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bankService = Provider.of<BankingService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF060E0A) : const Color(0xFFF6F8F7);
    final cardBg = isDark ? const Color(0xFF0D1E17) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0B1F17);
    final sub = isDark ? const Color(0xFF7A9489) : const Color(0xFF6B7E76);
    final border = isDark ? const Color(0xFF183327) : const Color(0xFFE0ECE6);
    const green = Color(0xFF00C88C);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Personal Details',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── USER PROFILE HEADER ──
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: isDark ? const Color(0xFF1A3A2C) : const Color(0xFFCCE9DC),
                          child: Text(
                            bankService.userFullName.isNotEmpty ? bankService.userFullName[0] : 'S',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: green),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: green,
                              shape: BoxShape.circle,
                              border: Border.all(color: bg, width: 2),
                            ),
                            child: const Icon(Iconsax.camera, color: Colors.black, size: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(bankService.userFullName, style: TextStyle(color: textColor, fontSize: 19, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(bankService.userTag, style: TextStyle(color: sub, fontSize: 13)),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── SECTION 1: BASIC INFORMATION ──
              _sectionTitle('BASIC INFORMATION', sub),
              const SizedBox(height: 12),
              _formCard(cardBg, border, [
                _inputField('FULL LEGAL NAME', _fullNameController, Iconsax.user, textColor, sub, border, green),
                const SizedBox(height: 16),
                _inputField('EMAIL ADDRESS', _emailController, Iconsax.sms, textColor, sub, border, green, isVerified: true),
                const SizedBox(height: 16),
                _inputField('PHONE NUMBER', _phoneController, Iconsax.call, textColor, sub, border, green, isVerified: true),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _readOnlyField('DATE OF BIRTH', bankService.userDob, Iconsax.calendar_1, textColor, sub, border)),
                    const SizedBox(width: 12),
                    Expanded(child: _readOnlyField('GENDER', bankService.userGender, Iconsax.user_search, textColor, sub, border)),
                  ],
                ),
              ]),

              const SizedBox(height: 24),

              // ── SECTION 2: RESIDENTIAL ADDRESS ──
              _sectionTitle('RESIDENTIAL ADDRESS', sub),
              const SizedBox(height: 12),
              _formCard(cardBg, border, [
                _inputField('HOME ADDRESS', _addressController, Iconsax.location, textColor, sub, border, green, maxLines: 2),
                const SizedBox(height: 16),
                _readOnlyField('NATIONALITY / COUNTRY', 'Nigeria 🇳🇬', Iconsax.global, textColor, sub, border),
              ]),

              const SizedBox(height: 24),

              // ── SECTION 3: LEGAL IDENTIFICATION (GOVERNMENT VERIFIED) ──
              _sectionTitle('GOVERNMENT IDENTIFICATION', sub),
              const SizedBox(height: 12),
              _formCard(cardBg, border, [
                _sensitiveIdTile(
                  title: 'Bank Verification Number (BVN)',
                  value: bankService.userBvn,
                  isVisible: _showBvn,
                  onToggle: () => setState(() => _showBvn = !_showBvn),
                  textColor: textColor,
                  sub: sub,
                  border: border,
                  green: green,
                ),
                const SizedBox(height: 14),
                _sensitiveIdTile(
                  title: 'National Identification Number (NIN)',
                  value: bankService.userNin,
                  isVisible: _showNin,
                  onToggle: () => setState(() => _showNin = !_showNin),
                  textColor: textColor,
                  sub: sub,
                  border: border,
                  green: green,
                ),
              ]),

              const SizedBox(height: 24),

              // ── SECTION 4: NEXT OF KIN ──
              _sectionTitle('NEXT OF KIN INFORMATION', sub),
              const SizedBox(height: 12),
              _formCard(cardBg, border, [
                _inputField('NEXT OF KIN NAME', _nokNameController, Iconsax.user_tag, textColor, sub, border, green),
                const SizedBox(height: 16),
                _inputField('RELATIONSHIP', _nokRelController, Iconsax.heart, textColor, sub, border, green),
                const SizedBox(height: 16),
                _inputField('NEXT OF KIN PHONE', _nokPhoneController, Iconsax.call, textColor, sub, border, green),
              ]),

              const SizedBox(height: 32),

              // ── SAVE BUTTON ──
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5))
                      : const Text('Save Profile Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, Color sub) {
    return Text(title, style: TextStyle(color: sub, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1));
  }

  Widget _formCard(Color cardBg, Color border, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller,
    IconData icon,
    Color textColor,
    Color sub,
    Color border,
    Color green, {
    bool isVerified = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: sub, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
            if (isVerified)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: green.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                child: const Text('VERIFIED', style: TextStyle(color: Color(0xFF00C88C), fontSize: 9, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            prefixIcon: Icon(icon, color: green, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: green, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _readOnlyField(String label, String value, IconData icon, Color textColor, Color sub, Color border) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: sub, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: border.withOpacity(0.3),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Icon(icon, color: sub, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(value, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 13))),
              Icon(Icons.lock_outline_rounded, color: sub, size: 14),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sensitiveIdTile({
    required String title,
    required String value,
    required bool isVisible,
    required VoidCallback onToggle,
    required Color textColor,
    required Color sub,
    required Color border,
    required Color green,
  }) {
    final masked = '${value.substring(0, 4)} •••• ${value.substring(value.length - 4)}';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: border.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.shield_rounded, color: green, size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: sub, fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(isVisible ? value : masked, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.0)),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: onToggle,
            icon: Icon(isVisible ? Iconsax.eye : Iconsax.eye_slash, color: sub, size: 18),
          ),
        ],
      ),
    );
  }
}
