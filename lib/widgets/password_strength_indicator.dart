import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../services/validation_service.dart';

/// Widget qui affiche la force d'un mot de passe en temps réel
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    Key? key,
    required this.password,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    final strengthData = ValidationService.getPasswordStrength(password);
    final strength = strengthData['strength'] as int;
    final label = strengthData['label'] as String;
    final suggestions = strengthData['suggestions'] as List<String>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        
        // Barre de progression
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: strength / 6,
                  minHeight: 6,
                  backgroundColor: BatteColors.muted,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getStrengthColor(strength),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getStrengthColor(strength),
              ),
            ),
          ],
        ),
        
        // Suggestions
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...suggestions.take(2).map((suggestion) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 12,
                  color: BatteColors.mutedForeground,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    suggestion,
                    style: const TextStyle(
                      fontSize: 11,
                      color: BatteColors.mutedForeground,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ],
    );
  }

  Color _getStrengthColor(int strength) {
    if (strength <= 2) {
      return Colors.red;
    } else if (strength <= 3) {
      return Colors.orange;
    } else if (strength <= 4) {
      return Colors.amber;
    } else if (strength <= 5) {
      return Colors.lightGreen;
    } else {
      return Colors.green;
    }
  }
}

