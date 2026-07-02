import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grad_imp_1/features/patient/presentation/controllers/health_monitoring_providers.dart';
import 'package:grad_imp_1/features/patient/presentation/controllers/patient_profile_providers.dart';
import 'package:grad_imp_1/core/localization/app_localizations.dart';
import 'package:grad_imp_1/features/patient/presentation/widgets/profile_components/stroke_risk_panel.dart';
import 'package:grad_imp_1/shared/presentation/widgets/ecg_chart.dart';
import 'package:grad_imp_1/shared/presentation/widgets/ppg_chart.dart';
import 'package:grad_imp_1/features/doctor/presentation/widgets/patient_uploaded_files_section.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';
import 'package:grad_imp_1/core/utils/status_mapper.dart';
import 'package:grad_imp_1/features/patient/presentation/widgets/profile_components/prediction_history_section.dart';
import 'package:grad_imp_1/features/doctor/presentation/widgets/doctor_followup_section.dart';

class MedicalDashboardSection extends ConsumerStatefulWidget {
  final String patientId;
  const MedicalDashboardSection({super.key, required this.patientId});

  @override
  ConsumerState<MedicalDashboardSection> createState() =>
      _MedicalDashboardSectionState();
}

class _MedicalDashboardSectionState
    extends ConsumerState<MedicalDashboardSection> {
  bool _strokeRiskExpanded = true;
  bool _ecgExpanded = false;
  bool _ppgExpanded = false;
  bool _uploadsExpanded = false;
  bool _historyExpanded = false;
  bool _followUpExpanded = false;

  Widget _buildToggleHeader({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: isExpanded
            ? const EdgeInsets.symmetric(vertical: 12)
            : const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isExpanded ? Colors.transparent : null,
          gradient: !isExpanded
              ? const LinearGradient(
                  colors: [Color(0xFFFFF2F2), Colors.white],
                  begin: AlignmentDirectional.centerStart,
                  end: AlignmentDirectional.centerEnd,
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          border: !isExpanded
              ? Border.all(
                  color: AppColors.redMaroon.withValues(alpha: 0.15),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles
                    .patientDoctorDetailSectionTitleBlackNeutral20ExtraBold,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isExpanded ? AppColors.black : AppColors.redDeep,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final healthState = ref.watch(
      healthMonitoringControllerProviderFamily(widget.patientId),
    );
    final patientState = ref.watch(patientDetailsProvider(widget.patientId));
    final patient = patientState.valueOrNull;

    final aiRiskScore = patient?.aiRiskStrokeRate?.toDouble();
    final riskScore =
        aiRiskScore ??
        healthState.currentPrediction?.riskScore ??
        healthState.averageRiskScore;

    final statusString = StatusMapper.resolveStatus(
      prediction: healthState.currentPrediction,
      patientStatus:
          patient?.status ?? patient?.patientProfile?['status']?.toString(),
      riskScore: riskScore,
    );
    final Color chartColor = StatusMapper.getColorForStatus(statusString);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildToggleHeader(
          title: 'Stroke risk'.tr(context),
          isExpanded: _strokeRiskExpanded,
          onTap: () {
            setState(() {
              _strokeRiskExpanded = !_strokeRiskExpanded;
            });
          },
        ),
        const SizedBox(height: 8),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: [
              const SizedBox(height: 10),
              StrokeRiskPanel(patientId: widget.patientId),
              const SizedBox(height: 24),
            ],
          ),
          crossFadeState: _strokeRiskExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),

        _buildToggleHeader(
          title: 'ECG signals'.tr(context),
          isExpanded: _ecgExpanded,
          onTap: () {
            setState(() {
              _ecgExpanded = !_ecgExpanded;
            });
          },
        ),
        const SizedBox(height: 8),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                decoration: ShapeDecoration(
                  color: AppColors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 1,
                      color: AppColors.redMaroon,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: AppColors.shadowBlack25,
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: SizedBox(
                  height: 170,
                  child: ECGChart(lineColor: chartColor),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
          crossFadeState: _ecgExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),

        _buildToggleHeader(
          title: 'PPG signals'.tr(context),
          isExpanded: _ppgExpanded,
          onTap: () {
            setState(() {
              _ppgExpanded = !_ppgExpanded;
            });
          },
        ),
        const SizedBox(height: 8),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                decoration: ShapeDecoration(
                  color: AppColors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 1,
                      color: AppColors.redMaroon,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: AppColors.shadowBlack25,
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: SizedBox(
                  height: 170,
                  child: PPGChart(lineColor: chartColor),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
          crossFadeState: _ppgExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),

        _buildToggleHeader(
          title: 'Uploaded Documents & Reports'.tr(context),
          isExpanded: _uploadsExpanded,
          onTap: () {
            setState(() {
              _uploadsExpanded = !_uploadsExpanded;
            });
          },
        ),
        const SizedBox(height: 8),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: [
              const SizedBox(height: 10),
              PatientUploadedFilesSection(patientId: widget.patientId),
              const SizedBox(height: 24),
            ],
          ),
          crossFadeState: _uploadsExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),

        _buildToggleHeader(
          title: 'Prediction History'.tr(context),
          isExpanded: _historyExpanded,
          onTap: () {
            setState(() {
              _historyExpanded = !_historyExpanded;
            });
          },
        ),
        const SizedBox(height: 8),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: [
              const SizedBox(height: 10),
              PredictionHistorySection(patientId: widget.patientId, isDoctor: true),
              const SizedBox(height: 24),
            ],
          ),
          crossFadeState: _historyExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),

        _buildToggleHeader(
          title: 'Follow-ups & Recommendations'.tr(context),
          isExpanded: _followUpExpanded,
          onTap: () {
            setState(() {
              _followUpExpanded = !_followUpExpanded;
            });
          },
        ),
        const SizedBox(height: 8),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: [
              const SizedBox(height: 10),
              DoctorFollowUpSection(patientId: widget.patientId),
              const SizedBox(height: 24),
            ],
          ),
          crossFadeState: _followUpExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
      ],
    );
  }
}

