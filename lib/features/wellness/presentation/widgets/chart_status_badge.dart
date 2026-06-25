import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';

class ChartStatusBadge extends StatelessWidget {
  const ChartStatusBadge({
    super.key,
    required this.label,
    required this.status,
    this.labelColor = AppColors.indigoDark,
    this.statusColor = AppColors.tealP,
    this.backgroundColor = AppColors.tealSurface,
  });

  final String label;
  final String status;
  final Color labelColor;
  final Color statusColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.chartStatusLabel14SemiBold.copyWith(
              color: labelColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          status,
          textAlign: TextAlign.center,
          style: AppTextStyles.chartStatusValue10ExtraBold.copyWith(
            color: statusColor,
          ),
        ),
      ],
    );
  }
}
