import 'package:flutter/material.dart';
import 'dart:math';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';

class RiskStrokeCard extends StatelessWidget {
  const RiskStrokeCard({
    super.key,
    required this.percentage,
    required this.description,
    this.status = 'unknown',
    this.backgroundColor = AppColors.tealP,
    this.riskColor = AppColors.redDeep,
    this.widthofGraph = 220,
    this.isAssessed = true,
  });

  final double percentage; // 0 - 100
  final String description;
  final String status;
  final Color backgroundColor;
  final Color riskColor;
  final double widthofGraph;
  final double percenttext = 50;
  final bool isAssessed;

  @override
  Widget build(BuildContext context) {
    final isArabic = AppTextStyles.isArabic;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            strokeAlign: BorderSide.strokeAlignOutside,
            color: AppColors.tealP,
          ),
          borderRadius: AppRadius.radiusSM,
        ),
        shadows: AppShadows.mediumShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Risk stroke rate '.tr(context),
                style: AppTextStyles.riskStrokeTitle16SemiBold.copyWith(
                  fontFamily: isArabic ? 'Cairo' : null,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  Text(
                    'connected'.tr(context),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.connectedLabelTealDarker11Regular.copyWith(
                      fontFamily: isArabic ? 'Cairo' : null,
                    ),
                  ),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: const ShapeDecoration(
                      color: AppColors.tealA,
                      shape: OvalBorder(),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Content Section (Circle + Description)
          if (isAssessed)
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
                        painter: _HalfCirclePainter(percentage, 18.0, status),
                      ),

                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Risk'.tr(context),
                            style: AppTextStyles.riskLabelNeutral600.copyWith(
                              fontFamily: isArabic ? 'Cairo' : null,
                            ),
                          ),
                          Text(
                            "${percentage.toInt()}%",
                            style: AppTextStyles.riskPercentRedSoft24Bold.copyWith(
                              color: status.toLowerCase() == 'critical'
                                  ? AppColors.redDeep
                                  : status.toLowerCase() == 'stable'
                                      ? AppColors.tealP
                                      : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Description Text
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    description,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.metricDescNeutral600_14Bold.copyWith(
                      fontFamily: isArabic ? 'Cairo' : null,
                    ),
                  ),
                ),
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 12,
                children: [
                  Icon(
                    Icons.assignment_ind_outlined,
                    size: 48,
                    color: AppColors.tealPrimaryDark,
                  ),
                  Text(
                    isArabic
                        ? 'لم يتم التقييم المبدئي بعد!'
                        : 'Initial Assessment Not Completed!',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.riskStrokeTitle16SemiBold.copyWith(
                      fontFamily: isArabic ? 'Cairo' : null,
                      color: AppColors.tealPrimaryDark,
                    ),
                  ),
                  Text(
                    isArabic
                        ? 'اضغط هنا لإجراء تقييم الذكاء الاصطناعي الخاص بك'
                        : 'Tap here to take your AI risk assessment',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.metricDescNeutral600_14Bold.copyWith(
                      fontFamily: isArabic ? 'Cairo' : null,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _HalfCirclePainter extends CustomPainter {
  final double percentage;
  final double strokeWidth;
  final String status;

  _HalfCirclePainter(this.percentage, this.strokeWidth, this.status);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      0,
      0,
      size.width,
      size.width, // important for proper circle
    );

    /// Background arc
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    /// Foreground arc
    final foregroundPaint = Paint()
      ..color = status.toLowerCase() == 'critical'
          ? AppColors.redDeep
          : status.toLowerCase() == 'stable'
              ? AppColors.tealP
              : Colors.orange
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
