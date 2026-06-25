import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

import '../../../../core/localization/app_localizations.dart';

class HeartRateChart extends StatelessWidget {
  const HeartRateChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: AppColors.white),
          borderRadius: BorderRadius.circular(8),
        ),
        shadows: [
          BoxShadow(
            color: AppColors.shadowBlack25,
            blurRadius: 5,
            offset: const Offset(0, 5),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 20,
        children: [
          // Header with Title and More button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Heart rate'.tr(context),
                style: AppTextStyles.chartCardTitleTealDarker20ExtraBold,
              ),
              SizedBox(
                width: 78,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            color: AppColors.emeraldGreen,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        SizedBox(width: 2.5),
                        Text(
                          'Normal'.tr(context),
                          style: AppTextStyles.chartLegendLabelNeutral350_12,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            color: AppColors.redLight,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        SizedBox(width: 2.5),
                        Text(
                          'Unnormal'.tr(context),
                          style: AppTextStyles.chartLegendLabelNeutral350_12,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(
            height: 250,
            child: AspectRatio(
              aspectRatio: 1.8,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 120,
                  minY: 40,
                  // 1. Grid Styling (Horizontal Dashed Lines)
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withValues(alpha: 0.2),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
                  ),
                  // 2. Remove Border
                  borderData: FlBorderData(show: false),
                  // 3. Axis Titles
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: AppTextStyles.chartAxisLabel9ExtraBold,
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final days = ['Mon'.tr(context), 'Tues'.tr(context), 'wed'.tr(context), 'Thurs'.tr(context)];
                          return Padding(
                            padding: const EdgeInsetsDirectional.only(top: 8.0),
                            child: Text(
                              days[value.toInt()],
                              style: AppTextStyles.chartAxisLabel9Regular,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // 4. Bar Data
                  barGroups: [
                    _makeGroupData(0, 78, AppColors.emeraldGreen), // Mon
                    _makeGroupData(1, 82, AppColors.emeraldGreen), // Tues
                    _makeGroupData(2, 98, AppColors.redLight), // Wed
                    _makeGroupData(
                      3,
                      105,
                      AppColors.redLight,
                      // showHalo: true,
                    ), // Thurs
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(
    int x,
    double y,
    Color color, {
    bool showHalo = false,
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 20,
          // This creates the "Pill" shape
          borderRadius: BorderRadius.circular(10),
          // This creates the "Halo" / Glow effect on the background
          backDrawRodData: BackgroundBarChartRodData(
            show: showHalo,
            toY: y + 5,
            fromY: 35, // Starts slightly below the bar
            color: color.withValues(alpha: 0.15),
          ),
        ),
      ],
    );
  }
}

