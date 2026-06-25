import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/utils/status_mapper.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';
import 'package:grad_imp_1/features/patient/presentation/controllers/patient_profile_providers.dart';
import 'package:grad_imp_1/features/patient/presentation/widgets/profile_components/metric_inline.dart';
import 'package:grad_imp_1/features/patient/presentation/controllers/health_monitoring_providers.dart';
import 'package:grad_imp_1/core/localization/app_localizations.dart';

class StrokeRiskPanel extends ConsumerWidget {
  final String patientId;
  const StrokeRiskPanel({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthState = ref.watch(
      healthMonitoringControllerProviderFamily(patientId),
    );
    final patientState = ref.watch(patientDetailsProvider(patientId));
    final patient = patientState.valueOrNull;

    // Read directly from the updated UserEntity, fallback to healthState if missing
    final aiRiskScore = patient?.aiRiskStrokeRate?.toDouble();
    final rawRiskScore =
        aiRiskScore ??
        healthState.currentPrediction?.riskScore ??
        healthState.averageRiskScore;
    final riskScore = rawRiskScore <= 1.0 ? rawRiskScore * 100 : rawRiskScore;

    // Resolve status and color dynamically
    final statusString = StatusMapper.resolveStatus(
      prediction: healthState.currentPrediction,
      patientStatus: patient?.status ?? patient?.patientProfile?['status']?.toString(),
      riskScore: riskScore,
    );
    final Color chartColor = StatusMapper.getColorForStatus(statusString);

    // Convert to percentage (0 to 100). Assuming riskScore is between 0 and 100.
    final int riskPercentage = riskScore.clamp(0.0, 100.0).round();

    // Heart rate mapping
    final heartRate =
        healthState.currentSignal?.heartRate.round() ??
        (healthState.averageHeartRate > 0
            ? healthState.averageHeartRate.round()
            : 78);
    final hrv =
        (healthState.currentSignal?.additionalData?['hrv'] as num?)?.round() ??
        60; // Assuming 60 if null

    // Determine color based on prediction label (already defined above)
    // Using chartColor from earlier declaration

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Center(
        //   child: Text(
        //     'Stroke risk',
        //     style:
        //         AppTextStyles.patientDetailStrokeRiskTitleBlack75_20ExtraBold,
        //   ),
        // ),
        // const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  MetricInline(label: 'HR'.tr(context), value: '$heartRate ${'bpm'.tr(context)}'),
                  const SizedBox(height: 16),
                  MetricInline(label: 'HRV'.tr(context), value: '$hrv% ${'ms'.tr(context)}'),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  bottom: 0,
                  left: 0,
                  child: SizedBox(
                    width: 140,
                    height: 140,
                    child: Center(
                      child: Text(
                        '$riskPercentage%',
                        style: AppTextStyles.metricValueNeutral850_24SemiBold
                            .copyWith(
                              fontSize: 33,
                              color: chartColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
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
                          value: riskPercentage.toDouble(),
                          color: chartColor,
                          radius: 12, // Thickness of the ring
                          showTitle: false,
                        ),
                        // Remaining Progress (Light Grey/Lavender)
                        PieChartSectionData(
                          value: (100 - riskPercentage).toDouble(),
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
          ],
        ),
      ],
    );
  }
}
