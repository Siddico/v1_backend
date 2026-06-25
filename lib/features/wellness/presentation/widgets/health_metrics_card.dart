// ignore_for_file: unnecessary_string_interpolations, duplicate_ignore

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class HealthMetricsCard extends StatelessWidget {
  const HealthMetricsCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.status,
    required this.statusColor,
    required this.description,
    required this.circleColor,
    this.borderColor = AppColors.tealP,
  });

  final String title;
  final String value;
  final String unit;
  final String status;
  final Color statusColor;
  final String description;
  final Color circleColor;
  final Color borderColor;
  final double oxygenLevel = 90.0;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: borderColor),
          borderRadius: BorderRadius.circular(9),
        ),
        shadows: [
          BoxShadow(
            color: AppColors.shadowBlack25,
            blurRadius: 4,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.metricCardTitleTealDarker16ExtraBold,
              ),
            ],
          ),
          Row(
            spacing: 12,
            children: [
              // Circular metric display
              Stack(
                children: [
                  Positioned(
                    top: 0,
                    right: 0,
                    bottom: 0,
                    left: 0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Oxygen'.tr(context),
                          style: AppTextStyles.metricLabelNeutral600_12SemiBold,
                        ),
                        Text(
                          '$value',
                          style: AppTextStyles.metricValueNeutral850_24SemiBold,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: PieChart(
                      PieChartData(
                        startDegreeOffset:
                            0, // Starts the "progress" from the top
                        sectionsSpace: 0,
                        centerSpaceRadius: 50, // Creates the "donut" hole
                        sections: [
                          // Completed Progress (Teal)
                          PieChartSectionData(
                            value: oxygenLevel,
                            color: AppColors.tealPrimaryLight,
                            radius: 12, // Thickness of the ring
                            showTitle: false,
                          ),
                          // Remaining Progress (Light Grey/Lavender)
                          PieChartSectionData(
                            value: 100 - oxygenLevel,
                            color: AppColors.blueGrayLight,
                            radius: 12,
                            showTitle: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ), // Status and Description
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Text(
                      status,
                      style: AppTextStyles.metricStatusPoppins24SemiBold
                          .copyWith(color: statusColor),
                    ),

                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'More than '.tr(context),
                            style: AppTextStyles.metricDescNeutral600_14Bold,
                          ),
                          TextSpan(
                            // ignore: unnecessary_brace_in_string_interps, unnecessary_string_interpolations
                            text: '${value}',
                            style: AppTextStyles.metricDescTeal14Bold,
                          ),
                          TextSpan(
                            text: ' $description ',
                            style: AppTextStyles.metricDescNeutral600_14Bold,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
