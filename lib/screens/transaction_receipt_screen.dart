import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dashboard_screen.dart';

class TransactionReceiptScreen extends StatelessWidget {
  final String recipientName;
  final String bankName;
  final String bankLogoText;
  final Color bankLogoColor;
  final double amount;
  final String currencySymbol;
  final String transactionRef;
  final String dateTimeText;
  final String transactionFee;
  final String statusText;

  const TransactionReceiptScreen({
    super.key,
    this.recipientName = 'Oluwaseun Adeyemi',
    this.bankName = 'Kuda Bank',
    this.bankLogoText = 'K',
    this.bankLogoColor = const Color(0xFF00C88C),
    this.amount = 150000.00,
    this.currencySymbol = '₦',
    this.transactionRef = 'TZ-9948201-X',
    this.dateTimeText = 'Oct 24, 2023, 14:20',
    this.transactionFee = '₦10.00',
    this.statusText = 'SUCCESSFUL',
  });

  String _formatAmount(double amt) {
    final parts = amt.toStringAsFixed(2).split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '$integerPart.${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF081C15) : const Color(0xFFF4F7F5);
    final cardBgColor = isDark ? const Color(0xFF0B261D) : Colors.white;
    final borderColor = isDark ? const Color(0xFF144534) : const Color(0xFFE0E8E4);
    final textColor = isDark ? Colors.white : const Color(0xFF0B1F17);
    final subtextColor = isDark ? const Color(0xFF8E9E98) : const Color(0xFF5A7067);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: textColor, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          'Receipt',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: const Icon(
              Icons.verified_rounded,
              color: Color(0xFFE5B800),
              size: 26,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // Big Hero Check Circle Icon
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: const Color(0xFF00C88C).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFF005238),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // SUCCESSFUL Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF132F24) : const Color(0xFFE0F2EB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusText,
                style: const TextStyle(
                  color: Color(0xFFE5B800),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Amount Display
            Text(
              '$currencySymbol${_formatAmount(amount)}',
              style: TextStyle(
                color: textColor,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),

            // Sent to Subtitle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Sent to ',
                  style: TextStyle(color: subtextColor, fontSize: 14),
                ),
                Text(
                  recipientName,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Main Receipt Details Card Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Row 1: Recipient Name
                  _buildDetailRow(
                    label: 'Recipient Name',
                    valueWidget: Text(
                      recipientName,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtextColor: subtextColor,
                  ),
                  const SizedBox(height: 18),

                  // Row 2: Bank Name
                  _buildDetailRow(
                    label: 'Bank Name',
                    valueWidget: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: bankLogoColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              bankLogoText,
                              style: TextStyle(
                                color: bankLogoColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          bankName,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    subtextColor: subtextColor,
                  ),
                  const SizedBox(height: 18),

                  // Row 3: Transaction Ref (with copy icon)
                  _buildDetailRow(
                    label: 'Transaction Ref',
                    valueWidget: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          transactionRef,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: transactionRef));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Transaction Ref copied!'),
                                backgroundColor: Color(0xFF00C88C),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.copy_rounded,
                            color: Color(0xFFE5B800),
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    subtextColor: subtextColor,
                  ),
                  const SizedBox(height: 18),

                  // Row 4: Date & Time
                  _buildDetailRow(
                    label: 'Date & Time',
                    valueWidget: Text(
                      dateTimeText,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtextColor: subtextColor,
                  ),
                  const SizedBox(height: 18),

                  // Row 5: Transaction Fee
                  _buildDetailRow(
                    label: 'Transaction Fee',
                    valueWidget: Text(
                      transactionFee,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtextColor: subtextColor,
                  ),
                  const SizedBox(height: 22),

                  // Card Footer Badge Watermark
                  Container(
                    padding: const EdgeInsets.only(top: 14),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: isDark ? Colors.white10 : Colors.black12,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.circle,
                              color: Color(0xFFE5B800),
                              size: 8,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'TRANZFA PREMIUM',
                              style: TextStyle(
                                color: Color(0xFFE5B800),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.more_horiz_rounded,
                          color: subtextColor.withOpacity(0.5),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Share Receipt CTA Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005238),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sharing transaction receipt...'),
                      backgroundColor: Color(0xFF00C88C),
                    ),
                  );
                },
                icon: const Icon(Icons.share_outlined, color: Colors.white, size: 20),
                label: const Text(
                  'Share Receipt',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Back to Home Outlined CTA Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isDark ? const Color(0xFF144534) : const Color(0xFFC4D6CD)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                    (route) => false,
                  );
                },
                icon: Icon(Icons.home_outlined, color: textColor, size: 20),
                label: Text(
                  'Back to Home',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Generated Footer Tagline
            Text(
              'Generated by Tranzfa Secure Banking',
              style: TextStyle(color: subtextColor, fontSize: 12),
            ),
            const SizedBox(height: 4),
            const Text(
              'MEMBER OF THE PREMIUM FINTECH GROUP',
              style: TextStyle(
                color: Color(0xFFE5B800),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required Widget valueWidget,
    required Color subtextColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: subtextColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        valueWidget,
      ],
    );
  }
}
