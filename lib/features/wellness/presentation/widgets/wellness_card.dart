import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/theme/app_radius.dart';

class WellnessCard extends StatelessWidget {
  const WellnessCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final String unit;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: AppRadius.card,
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodySmall),
                const SizedBox(height: 4),
                Text('$value $unit', style: theme.textTheme.titleMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

