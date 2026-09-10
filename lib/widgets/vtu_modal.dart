import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/banking_service.dart';
import '../services/vtu_service.dart';

class VtuPurchaseModal extends StatefulWidget {
  final VtuCategory initialCategory;

  const VtuPurchaseModal({
    super.key,
    this.initialCategory = VtuCategory.airtime,
  });

  @override
  State<VtuPurchaseModal> createState() => _VtuPurchaseModalState();
}

class _VtuPurchaseModalState extends State<VtuPurchaseModal> {
  late VtuCategory _selectedCategory;
  late String _selectedProviderCode;
  String? _selectedPackageId;

  final TextEditingController _phoneOrMeterController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  bool _isValidating = false;
  VtuValidationResult? _validationResult;
  bool _isProcessing = false;
  VtuTransactionResult? _transactionResult;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _updateProvidersForCategory();
    _phoneOrMeterController.text = "08031234567";
  }

  void _updateProvidersForCategory() {
    switch (_selectedCategory) {
      case VtuCategory.airtime:
        _selectedProviderCode = VtuService.getAirtimeProviders().first.code;
        _amountController.text = "1000";
        _selectedPackageId = null;
        break;
      case VtuCategory.data:
        _selectedProviderCode = VtuService.getAirtimeProviders().first.code;
        final plans = VtuService.getDataPlans(_selectedProviderCode);
        _selectedPackageId = plans.first.planId;
        _amountController.text = plans.first.price.toStringAsFixed(0);
        break;
      case VtuCategory.electricity:
        _selectedProviderCode = VtuService.getElectricityDiscos().first.code;
        _amountController.text = "5000";
        _phoneOrMeterController.text = "45019283741";
        _selectedPackageId = null;
        break;
      case VtuCategory.cableTv:
        _selectedProviderCode = VtuService.getCableProviders().first.code;
        final packages = VtuService.getCablePackages(_selectedProviderCode);
        _selectedPackageId = packages.first.planId;
        _amountController.text = packages.first.price.toStringAsFixed(0);
        _phoneOrMeterController.text = "7019284019";
        break;
    }
    _validationResult = null;
    _errorMessage = null;
  }

  @override
  void dispose() {
    _phoneOrMeterController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _validateAccount() async {
    final number = _phoneOrMeterController.text.trim();
    if (number.isEmpty) return;

    setState(() {
      _isValidating = true;
      _errorMessage = null;
    });

    final res = await VtuService.validateCustomerAccount(
      serviceCode: _selectedProviderCode,
      accountNumber: number,
      type: _selectedCategory == VtuCategory.electricity ? 'prepaid' : 'smartcard',
    );

    setState(() {
      _isValidating = false;
      _validationResult = res;
      if (!res.isValid) {
        _errorMessage = res.errorMessage ?? 'Validation failed';
      }
    });
  }

  Future<void> _processPurchase() async {
    final targetNumber = _phoneOrMeterController.text.trim();
    final amountText = _amountController.text.trim();
    final double? amount = double.tryParse(amountText);

    if (targetNumber.isEmpty || amount == null || amount <= 0) {
      setState(() => _errorMessage = "Please enter valid number and amount.");
      return;
    }

    final bankService = Provider.of<BankingService>(context, listen: false);
    if (bankService.activeAccount.balance < amount) {
      setState(() => _errorMessage = "Insufficient account balance.");
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    VtuTransactionResult result;
    String title = "";
    String subtitle = "";

    VtuProvider provider;
    if (_selectedCategory == VtuCategory.airtime || _selectedCategory == VtuCategory.data) {
      provider = VtuService.getAirtimeProviders().firstWhere((p) => p.code == _selectedProviderCode);
    } else if (_selectedCategory == VtuCategory.electricity) {
      provider = VtuService.getElectricityDiscos().firstWhere((p) => p.code == _selectedProviderCode);
    } else {
      provider = VtuService.getCableProviders().firstWhere((p) => p.code == _selectedProviderCode);
    }

    if (_selectedCategory == VtuCategory.airtime) {
      title = '${provider.name} Airtime';
      subtitle = '080...${targetNumber.length > 4 ? targetNumber.substring(targetNumber.length - 4) : targetNumber}';
      result = await VtuService.purchaseAirtime(
        phone: targetNumber,
        networkCode: _selectedProviderCode,
        amount: amount,
      );
    } else if (_selectedCategory == VtuCategory.data) {
      final plans = VtuService.getDataPlans(_selectedProviderCode);
      final pkg = plans.firstWhere((p) => p.planId == _selectedPackageId, orElse: () => plans.first);
      title = '${provider.name} Data';
      subtitle = pkg.name;
      result = await VtuService.purchaseDataBundle(
        phone: targetNumber,
        networkCode: _selectedProviderCode,
        planId: pkg.planId,
        planName: pkg.name,
        amount: amount,
      );
    } else if (_selectedCategory == VtuCategory.electricity) {
      title = '${provider.name} Electric';
      subtitle = 'Meter #$targetNumber';
      result = await VtuService.payElectricityBill(
        discoCode: _selectedProviderCode,
        meterNumber: targetNumber,
        meterType: 'prepaid',
        amount: amount,
        customerPhone: '08031234567',
      );
    } else {
      final packages = VtuService.getCablePackages(_selectedProviderCode);
      final pkg = packages.firstWhere((p) => p.planId == _selectedPackageId, orElse: () => packages.first);
      title = '${provider.name} Subscription';
      subtitle = pkg.name;
      result = await VtuService.payCableTvSubscription(
        tvProviderCode: _selectedProviderCode,
        smartcardNo: targetNumber,
        planId: pkg.planId,
        planName: pkg.name,
        amount: amount,
      );
    }

    if (result.success) {
      await bankService.executeVtuPayment(
        title: title,
        subtitle: subtitle,
        amount: amount,
        currencyCode: bankService.selectedCurrencyCode,
        category: _selectedCategory.name.toUpperCase(),
      );
    }

    setState(() {
      _isProcessing = false;
      _transactionResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? const Color(0xFF0B1713) : Colors.white;
    final borderColor = isDark ? const Color(0xFF142B22) : const Color(0xFFE0E8E4);
    final textColor = isDark ? Colors.white : const Color(0xFF0B1F17);
    final subtextColor = isDark ? const Color(0xFF8E9B95) : const Color(0xFF5A7067);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF040E0A) : const Color(0xFFF4F7F5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'VTU Services & Bills',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: subtextColor),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Transaction Result View (Success Receipt)
            if (_transactionResult != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF00C88C), width: 1.5),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF00C88C), size: 54),
                    const SizedBox(height: 12),
                    Text(
                      'VTU Top-Up Successful!',
                      style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _transactionResult!.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: subtextColor, fontSize: 13),
                    ),
                    if (_transactionResult!.token != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C88C).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF00C88C).withOpacity(0.4)),
                        ),
                        child: Column(
                          children: [
                            const Text('ELECTRICITY TOKEN', style: TextStyle(color: Color(0xFF00C88C), fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              _transactionResult!.token!,
                              style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text('Ref: ${_transactionResult!.reference}', style: TextStyle(color: subtextColor, fontSize: 11)),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C88C),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Done', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Category Tab Selector
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip(VtuCategory.airtime, ' Airtime', isDark, textColor),
                    _buildCategoryChip(VtuCategory.data, ' Data', isDark, textColor),
                    _buildCategoryChip(VtuCategory.electricity, ' Electricity', isDark, textColor),
                    _buildCategoryChip(VtuCategory.cableTv, ' Cable TV', isDark, textColor),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Provider Selector
              Text('Select Provider / Biller', style: TextStyle(color: subtextColor, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _buildProviderDropdown(isDark, cardBgColor, borderColor, textColor),
              const SizedBox(height: 16),

              // Package Selector (if Data or Cable TV)
              if (_selectedCategory == VtuCategory.data || _selectedCategory == VtuCategory.cableTv) ...[
                Text('Select Plan Package', style: TextStyle(color: subtextColor, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _buildPackageDropdown(isDark, cardBgColor, borderColor, textColor),
                const SizedBox(height: 16),
              ],

              // Phone / Meter / SmartCard Input Field
              Text(
                _selectedCategory == VtuCategory.electricity
                    ? 'Meter Number'
                    : (_selectedCategory == VtuCategory.cableTv ? 'SmartCard / IUC Number' : 'Recipient Phone Number'),
                style: TextStyle(color: subtextColor, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _phoneOrMeterController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: cardBgColor,
                        hintText: 'Enter number',
                        hintStyle: TextStyle(color: subtextColor.withOpacity(0.6)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF00C88C))),
                      ),
                    ),
                  ),
                  if (_selectedCategory == VtuCategory.electricity || _selectedCategory == VtuCategory.cableTv) ...[
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0E4735),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _isValidating ? null : _validateAccount,
                      child: _isValidating
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00E676)))
                          : const Text('Verify', style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
              if (_validationResult != null && _validationResult!.isValid) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: Color(0xFF00C88C), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Verified: ${_validationResult!.customerName}',
                      style: const TextStyle(color: Color(0xFF00C88C), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),

              // Amount Input Field
              Text('Amount (₦)', style: TextStyle(color: subtextColor, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                readOnly: _selectedCategory == VtuCategory.data || _selectedCategory == VtuCategory.cableTv,
                style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixText: '₦ ',
                  prefixStyle: const TextStyle(color: Color(0xFF00C88C), fontSize: 18, fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: cardBgColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderColor)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF00C88C))),
                ),
              ),
              const SizedBox(height: 16),

              if (_errorMessage != null) ...[
                Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
              ],

              // Pay Now CTA Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C88C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isProcessing ? null : _processPurchase,
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(
                          'Pay ₦${_amountController.text} Now',
                          style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(VtuCategory category, String label, bool isDark, Color textColor) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
          _updateProvidersForCategory();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00C88C) : (isDark ? const Color(0xFF0B1713) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF00C88C) : (isDark ? const Color(0xFF142B22) : const Color(0xFFE0E8E4))),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : textColor,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildProviderDropdown(bool isDark, Color cardBgColor, Color borderColor, Color textColor) {
    List<VtuProvider> providers = [];
    if (_selectedCategory == VtuCategory.airtime || _selectedCategory == VtuCategory.data) {
      providers = VtuService.getAirtimeProviders();
    } else if (_selectedCategory == VtuCategory.electricity) {
      providers = VtuService.getElectricityDiscos();
    } else {
      providers = VtuService.getCableProviders();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedProviderCode,
          isExpanded: true,
          dropdownColor: cardBgColor,
          items: providers.map((p) {
            return DropdownMenuItem<String>(
              value: p.code,
              child: Row(
                children: [
                  Text(p.iconAsset, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Text(p.name, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedProviderCode = val;
                if (_selectedCategory == VtuCategory.data) {
                  final plans = VtuService.getDataPlans(val);
                  _selectedPackageId = plans.first.planId;
                  _amountController.text = plans.first.price.toStringAsFixed(0);
                } else if (_selectedCategory == VtuCategory.cableTv) {
                  final packages = VtuService.getCablePackages(val);
                  _selectedPackageId = packages.first.planId;
                  _amountController.text = packages.first.price.toStringAsFixed(0);
                }
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildPackageDropdown(bool isDark, Color cardBgColor, Color borderColor, Color textColor) {
    List<VtuPackage> packages = [];
    if (_selectedCategory == VtuCategory.data) {
      packages = VtuService.getDataPlans(_selectedProviderCode);
    } else if (_selectedCategory == VtuCategory.cableTv) {
      packages = VtuService.getCablePackages(_selectedProviderCode);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPackageId,
          isExpanded: true,
          dropdownColor: cardBgColor,
          items: packages.map((pkg) {
            return DropdownMenuItem<String>(
              value: pkg.planId,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(pkg.name, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 13)),
                  Text('₦${pkg.price.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF00C88C), fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              final pkg = packages.firstWhere((p) => p.planId == val);
              setState(() {
                _selectedPackageId = val;
                _amountController.text = pkg.price.toStringAsFixed(0);
              });
            }
          },
        ),
      ),
    );
  }
}
