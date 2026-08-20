import 'package:flutter/material.dart';
import '../models/banking_models.dart';
import '../theme/app_theme.dart';

class VirtualCardWidget extends StatefulWidget {
  final TranzfaCard card;
  final VoidCallback onToggleFreeze;

  const VirtualCardWidget({
    super.key,
    required this.card,
    required this.onToggleFreeze,
  });

  @override
  State<VirtualCardWidget> createState() => _VirtualCardWidgetState();
}

class _VirtualCardWidgetState extends State<VirtualCardWidget> {
  bool _showCvv = false;

  @override
  Widget build(BuildContext context) {
    final isGold = widget.card.isGoldTier;

    return Container(
      width: double.infinity,
      height: 220,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isGold
              ? const [
                  Color(0xFFF7D070),
                  Color(0xFFD49B28),
                  Color(0xFF8F6308),
                ]
              : const [
                  Color(0xFF07A267),
                  Color(0xFF034A2F),
                  Color(0xFF021B11),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: (isGold ? AppTheme.goldPrimary : AppTheme.emeraldAccent).withOpacity(0.35),
            blurRadius: 20,
            spreadRadius: -2,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isGold ? Colors.white.withOpacity(0.4) : AppTheme.emeraldAccent.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          // Background Watermark / Diamond Pattern
          Positioned(
            right: -20,
            bottom: -30,
            child: Icon(
              Icons.diamond_outlined,
              size: 180,
              color: Colors.white.withOpacity(0.08),
            ),
          ),

          // Frozen Overlay if Frozen
          if (widget.card.isFrozen)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.ac_unit, color: Colors.cyanAccent, size: 36),
                      SizedBox(height: 8),
                      Text(
                        'CARD FROZEN',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row: Brand & Contactless
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.diamond_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'TRANZFA VIP',
                        style: TextStyle(
                          color: isGold ? const Color(0xFF2C1E03) : Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.contactless,
                        color: isGold ? const Color(0xFF2C1E03) : Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: widget.onToggleFreeze,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                widget.card.isFrozen ? Icons.lock_open : Icons.lock_outline,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.card.isFrozen ? 'Unfreeze' : 'Freeze',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Middle: Chip & Card Number
              Row(
                children: [
                  // Gold EMV Chip
                  Container(
                    width: 42,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5C158),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.black.withOpacity(0.2)),
                    ),
                    child: Center(
                      child: Container(
                        width: 24,
                        height: 18,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    widget.card.cardNumber,
                    style: TextStyle(
                      color: isGold ? const Color(0xFF1E1502) : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontFamily: 'Courier',
                    ),
                  ),
                ],
              ),

              // Bottom Row: Name, Expiry, CVV & Apple Pay Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CARDHOLDER',
                        style: TextStyle(
                          color: (isGold ? Colors.black : Colors.white).withOpacity(0.6),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.card.cardHolderName,
                        style: TextStyle(
                          color: isGold ? const Color(0xFF1E1502) : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EXPIRES',
                        style: TextStyle(
                          color: (isGold ? Colors.black : Colors.white).withOpacity(0.6),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.card.expiryDate,
                        style: TextStyle(
                          color: isGold ? const Color(0xFF1E1502) : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showCvv = !_showCvv;
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CVV',
                          style: TextStyle(
                            color: (isGold ? Colors.black : Colors.white).withOpacity(0.6),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              _showCvv ? widget.card.cvv : '•••',
                              style: TextStyle(
                                color: isGold ? const Color(0xFF1E1502) : Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _showCvv ? Icons.visibility_off : Icons.visibility,
                              size: 12,
                              color: isGold ? const Color(0xFF1E1502) : Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Apple Pay Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.apple, color: Colors.white, size: 14),
                        SizedBox(width: 2),
                        Text(
                          'Pay',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
