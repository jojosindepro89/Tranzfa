import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SecurityBadgeFooter extends StatelessWidget {
  const SecurityBadgeFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon 1: Shield
          Icon(
            Icons.shield_outlined,
            size: 14,
            color: AppTheme.textMuted,
          ),
          const SizedBox(width: 12),
          // Icon 2: Check Circle
          Icon(
            Icons.verified_user_outlined,
            size: 14,
            color: AppTheme.textMuted,
          ),
          const SizedBox(width: 12),
          // Icon 3: Lock Shield
          Icon(
            Icons.lock_outline,
            size: 14,
            color: AppTheme.textMuted,
          ),
          const SizedBox(width: 14),
          // Text
          Text(
            'ISO 27001 CERTIFIED',
            style: TextStyle(
              color: AppTheme.textMuted.withOpacity(0.7),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
