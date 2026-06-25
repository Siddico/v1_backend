import 'package:flutter/material.dart';
import 'dart:math';
import 'package:grad_imp_1/core/localization/app_localizations.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/theme/app_radius.dart';
import 'package:grad_imp_1/core/theme/app_shadows.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';

class StabilityIndexCard extends StatelessWidget {
  const StabilityIndexCard({
    super.key,
    required this.percentage,
    required this.description,
    this.backgroundColor = AppColors.tealP,
    this.riskColor = AppColors.redDeep,
    this.widthofGraph = 220,
  });

  final double percentage; // 0 - 100
  final String description;
  final Color backgroundColor;
  final Color riskColor;
  final double widthofGraph;
  final double percenttext = 70;
  @override
  Widget build(BuildContext context) {
    String derivedStatus;
    if (percentage >= 70) {
      derivedStatus = 'stable';
    } else if (percentage <= 40) {
      derivedStatus = 'critical';
    } else {
      derivedStatus = 'warning';
    }

    Color foregroundColor = derivedStatus == 'critical'
        ? AppColors.redDeep
        : derivedStatus == 'stable'
        ? AppColors.tealP
        : Colors.orange;

    String statusText = derivedStatus == 'critical'
        ? 'Critical'.tr(context)
        : derivedStatus == 'stable'
        ? 'Normal'.tr(context)
        : 'Warning'.tr(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            strokeAlign: BorderSide.strokeAlignOutside,
            color: AppColors.white,
          ),
          borderRadius: AppRadius.radiusSM,
        ),
        shadows: AppShadows.mediumShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          // Header Row (Title + Connected Status)
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   crossAxisAlignment: CrossAxisAlignment.center,
          //   children: [
          //     Text(
          //       'Stability Index',
          //       style: AppTextStyles.riskStrokeTitle16SemiBold,
          //     ),
          //   ],
          // ),
          const SizedBox(height: 10),
          // Content Section (Circle + Description)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 16,
            children: [
              // Circular Risk Display
              SizedBox(
                width: 220,
                height: 130,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(220, 130),
                      painter: _HalfCirclePainter(
                        percentage,
                        40.0,
                        foregroundColor,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          statusText,
                          style: AppTextStyles.riskLabelNeutral600,
                        ),
                        Text(
                          "${percentage.toInt()}%",
                          style: AppTextStyles.riskPercentRedSoft24Bold
                              .copyWith(color: foregroundColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Description Text
              SizedBox(
                width: double.infinity,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'More than '.tr(context),
                        style: AppTextStyles.metricDescNeutral600_14Bold,
                      ),
                      TextSpan(
                        text: '$percenttext%',
                        style: AppTextStyles.metricDescTeal14Bold,
                      ),
                      TextSpan(
                        text: ' $description',
                        style: AppTextStyles.metricDescNeutral600_14Bold,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HalfCirclePainter extends CustomPainter {
  final double percentage;
  final double strokeWidth;
  final Color foregroundColor;

  _HalfCirclePainter(this.percentage, this.strokeWidth, this.foregroundColor);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.width);

    /// Background arc
    final backgroundPaint = Paint()
      ..color = AppColors.lavenderLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    /// Foreground arc
    final foregroundPaint = Paint()
      ..color = foregroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw background (full half circle)
    canvas.drawArc(
      rect,
      pi, // start from left
      pi, // 180 degrees
      false,
      backgroundPaint,
    );

    // Draw percentage arc
    canvas.drawArc(
      rect,
      pi,
      pi * (percentage / 100), // percentage of half circle
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
