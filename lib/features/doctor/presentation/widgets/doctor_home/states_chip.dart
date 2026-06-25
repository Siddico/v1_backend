import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (text.toLowerCase()) {
      case 'stable':
      case 'nsr':
        bg = AppColors.greenMintLight;
        fg = AppColors.greenDark;
        break;
      case 'critical':
      case 'af':
        bg = AppColors.redSurface;
        fg = AppColors.redAlert;
        break;
      case 'pac':
        bg = Colors.orange.withValues(alpha: 0.2);
        fg = Colors.deepOrange;
        break;
      case 'needs':
        bg = AppColors.yellowPale;
        fg = AppColors.yellowMustard;
        break;
      default:
        bg = AppColors.neutral100;
        fg = AppColors.neutral500;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        text,
        style: AppTextStyles.chartStatusValue10ExtraBold.copyWith(color: fg),
      ),
    );
  }
}

