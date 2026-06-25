import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';
import 'package:grad_imp_1/core/localization/app_localizations.dart';
import 'package:grad_imp_1/core/utils/status_mapper.dart';
import 'package:grad_imp_1/features/patient/domain/entities/prediction_result_entity.dart';
import 'package:grad_imp_1/features/patient/presentation/controllers/health_monitoring_providers.dart';
import 'package:grad_imp_1/shared/presentation/widgets/circular_loading_indicator.dart';
import 'package:grad_imp_1/core/utils/stroke_prediction_logic.dart';

class PredictionHistorySection extends ConsumerWidget {
  final String patientId;
  final bool isDoctor;

  const PredictionHistorySection({
    super.key,
    required this.patientId,
    this.isDoctor = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(predictionHistoryProvider(patientId));

    return historyAsync.when(
      loading: () => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: CircularLoadingIndicator(
            size: 36,
            color: isDoctor ? AppColors.redDeep : AppColors.tealP,
          ),
        ),
      ),
      error: (error, stackTrace) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 44,
              color: isDoctor ? AppColors.redMaroon : AppColors.tealP,
            ),
            const SizedBox(height: 12),
            Text(
              'Error loading history'.tr(context),
              style: TextStyle(
                fontSize: 14,
                fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
                fontWeight: FontWeight.w600,
                color: AppColors.neutral700,
              ),
            ),
            if (error.toString().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ],
        ),
      ),
      data: (predictions) {
        if (predictions.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.neutral200),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.history_toggle_off_rounded,
                  size: 44,
                  color: AppColors.neutral450.withValues(alpha: 0.8),
                ),
                const SizedBox(height: 12),
                Text(
                  'No prediction history found'.tr(context),
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'When an AI prediction is made, it will appear here.'.tr(
                    context,
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: predictions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final prediction = predictions[index];
            return PredictionHistoryCard(
              prediction: prediction,
              isDoctor: isDoctor,
            );
          },
        );
      },
    );
  }
}

class PredictionHistoryCard extends StatefulWidget {
  final PredictionResult prediction;
  final bool isDoctor;

  const PredictionHistoryCard({
    super.key,
    required this.prediction,
    required this.isDoctor,
  });

  @override
  State<PredictionHistoryCard> createState() => _PredictionHistoryCardState();
}

class _PredictionHistoryCardState extends State<PredictionHistoryCard> {
  bool _isExpanded = false;

  String _getStatusLabel(BuildContext context, String statusString) {
    switch (statusString.toLowerCase()) {
      case 'af':
      case 'critical':
      case 'high':
        return 'Critical'.tr(context);
      case 'pac':
      case 'warning':
      case 'medium':
        return 'Warning'.tr(context);
      case 'nsr':
      case 'stable':
      case 'low':
      default:
        return 'Stable'.tr(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusString = StatusMapper.mapPredictionToStatus(widget.prediction);
    final color = StatusMapper.getColorForStatus(statusString);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Formatting date safely
    String dateStr = 'Unknown'.tr(context);
    final date = widget.prediction.predictionTimestamp;
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    dateStr =
        '${date.day} ${months[date.month - 1].tr(context)} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    final label = _getStatusLabel(context, statusString);

    // Check if we have vitals/model output details
    final modelOutput = widget.prediction.modelOutput;
    final hasDetails = modelOutput != null && modelOutput.isNotEmpty;
    
    String? explanation = widget.prediction.message;
    if (hasDetails) {
      final generated = StrokePredictionLogic.generateExplanationAndAdvice(
        age: (modelOutput['age'] as num?)?.toDouble() ?? 0.0,
        hypertension: modelOutput['hypertension'] == 1,
        heartDisease: modelOutput['heart_disease'] == 1,
        avgGlucoseLevel: (modelOutput['avg_glucose_level'] as num?)?.toDouble() ?? 0.0,
        bmi: (modelOutput['bmi'] as num?)?.toDouble() ?? 0.0,
        smokingStatus: modelOutput['smoking_status']?.toString() ?? '',
        chestPain: modelOutput['chest_pain'] == 1,
        irregularHeartbeat: modelOutput['irregular_heartbeat'] == 1,
        shortnessOfBreath: modelOutput['shortness_of_breath'] == 1,
        fatigueWeakness: modelOutput['fatigue_weakness'] == 1,
        dizziness: modelOutput['dizziness'] == 1,
        swellingEdema: modelOutput['swelling_edema'] == 1,
        neckJawPain: modelOutput['neck_jaw_pain'] == 1,
        excessiveSweating: modelOutput['excessive_sweating'] == 1,
        persistentCough: modelOutput['persistent_cough'] == 1,
        nauseaVomiting: modelOutput['nausea_vomiting'] == 1,
        chestDiscomfort: modelOutput['chest_discomfort'] == 1,
        coldHandsFeet: modelOutput['cold_hands_feet'] == 1,
        snoringSleepApnea: modelOutput['snoring_sleep_apnea'] == 1,
        anxietyDoom: modelOutput['anxiety_doom'] == 1,
        languageCode: isArabic ? 'ar' : 'en',
      );
      explanation = generated['explanation'] as String?;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left color accent bar
            Container(width: 5, color: color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Main Header Row (Status Icon, Label, Risk Percentage)
                    InkWell(
                      onTap:
                          hasDetails ||
                              (explanation != null && explanation.isNotEmpty)
                          ? () => setState(() => _isExpanded = !_isExpanded)
                          : null,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              statusString.toLowerCase() == 'af' ||
                                      statusString.toLowerCase() == 'critical'
                                  ? Icons.gpp_bad_rounded
                                  : statusString.toLowerCase() == 'pac' ||
                                        statusString.toLowerCase() == 'warning'
                                  ? Icons.gpp_maybe_rounded
                                  : Icons.gpp_good_rounded,
                              color: color,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: isArabic
                                            ? 'Cairo'
                                            : 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Risk Score Pill Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                      ),
                                      child: Text(
                                        '${(widget.prediction.riskScore <= 1.0 ? widget.prediction.riskScore * 100 : widget.prediction.riskScore).toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontFamily: isArabic
                                              ? 'Cairo'
                                              : 'Poppins',
                                          fontWeight: FontWeight.bold,
                                          color: color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dateStr,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: isArabic ? 'Cairo' : 'Poppins',
                                    color: AppColors.neutral500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (hasDetails ||
                              (explanation != null && explanation.isNotEmpty))
                            Icon(
                              _isExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: AppColors.neutral450,
                              size: 22,
                            ),
                        ],
                      ),
                    ),
                    // Expandable Section
                    if (hasDetails ||
                        (explanation != null && explanation.isNotEmpty))
                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            const Divider(
                              color: AppColors.neutral100,
                              height: 1,
                            ),
                            const SizedBox(height: 12),

                            // Vitals/Parameters Grid/Details if present
                            if (hasDetails) ...[
                              Text(
                                'Vitals & Parameters'.tr(context),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: isArabic ? 'Cairo' : 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.neutral700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (modelOutput['age'] != null)
                                    _buildDetailChip(
                                      context,
                                      Icons.calendar_today_rounded,
                                      '${(modelOutput['age'] as num).toInt()} ${'years'.tr(context)}',
                                    ),
                                  if (modelOutput['weight'] != null &&
                                      (modelOutput['weight'] as num) > 0)
                                    _buildDetailChip(
                                      context,
                                      Icons.scale_rounded,
                                      '${(modelOutput['weight'] as num).toStringAsFixed(0)} ${'kg'.tr(context)}',
                                    ),
                                  if (modelOutput['height'] != null &&
                                      (modelOutput['height'] as num) > 0)
                                    _buildDetailChip(
                                      context,
                                      Icons.height_rounded,
                                      '${(modelOutput['height'] as num).toStringAsFixed(0)} ${'cm'.tr(context)}',
                                    ),
                                  if (modelOutput['bmi'] != null &&
                                      (modelOutput['bmi'] as num) > 0)
                                    _buildDetailChip(
                                      context,
                                      Icons.monitor_weight_outlined,
                                      'BMI: ${(modelOutput['bmi'] as num).toStringAsFixed(1)}',
                                    ),
                                  if (modelOutput['avg_glucose_level'] != null)
                                    _buildDetailChip(
                                      context,
                                      Icons.opacity_rounded,
                                      '${(modelOutput['avg_glucose_level'] as num).toStringAsFixed(1)} mg/dL',
                                    ),
                                  if (modelOutput['smoking_status'] != null)
                                    _buildDetailChip(
                                      context,
                                      Icons.smoke_free_rounded,
                                      modelOutput['smoking_status']
                                          .toString()
                                          .tr(context),
                                    ),
                                  if (modelOutput['hypertension'] == 1)
                                    _buildDetailChip(
                                      context,
                                      Icons.favorite_rounded,
                                      'Hypertension'.tr(context),
                                      isCritical: true,
                                    ),
                                  if (modelOutput['heart_disease'] == 1)
                                    _buildDetailChip(
                                      context,
                                      Icons.monitor_heart_rounded,
                                      'Heart Disease'.tr(context),
                                      isCritical: true,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Explanation / Analysis if present
                            if (explanation != null &&
                                explanation.isNotEmpty) ...[
                              Text(
                                'Explanation'.tr(context),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: isArabic ? 'Cairo' : 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.neutral700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.tealSurface.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  explanation,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontFamily: isArabic ? 'Cairo' : 'Poppins',
                                    color: AppColors.neutral700,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        crossFadeState: _isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 250),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(
    BuildContext context,
    IconData icon,
    String label, {
    bool isCritical = false,
  }) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: isCritical
            ? AppColors.redDeep.withValues(alpha: 0.08)
            : AppColors.tealSurface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCritical
              ? AppColors.redDeep.withValues(alpha: 0.15)
              : AppColors.tealBorderLight.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: isCritical ? AppColors.redDeep : AppColors.tealPrimaryDark,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontFamily: isArabic ? 'Cairo' : 'Poppins',
              fontWeight: FontWeight.w600,
              color: isCritical ? AppColors.redDeep : AppColors.tealPrimaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

