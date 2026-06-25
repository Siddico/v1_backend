import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/constants/app_images.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';
import 'package:grad_imp_1/shared/domain/entities/user_entity.dart';
import 'package:grad_imp_1/shared/presentation/widgets/user_qr_widget.dart';
import 'package:grad_imp_1/core/localization/app_localizations.dart';

class PatientHeader extends StatelessWidget {
  final UserEntity patient;

  const PatientHeader({super.key, required this.patient});

  String _calculateAge(String? dobString, BuildContext context) {
    if (dobString == null || dobString.isEmpty) return 'N/A'.tr(context);
    try {
      final dob = DateTime.parse(dobString);
      final today = DateTime.now();
      var age = today.year - dob.year;
      if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
        age--;
      }
      return '$age ${'Year'.tr(context)}';
    } catch (_) {
      return 'N/A'.tr(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = patient.status ?? patient.patientProfile?['status']?.toString() ?? 'Unknown';
    final isCritical = status.toLowerCase() == 'critical';
    final isStable = status.toLowerCase() == 'stable';
    
    Color statusBgColor = AppColors.neutral100;
    if (isCritical) {
      statusBgColor = AppColors.redSurface;
    } else if (isStable) {
      statusBgColor = AppColors.tealA.withValues(alpha: 0.2);
    } else if (status.toLowerCase() != 'unknown') {
      statusBgColor = Colors.orange.withValues(alpha: 0.2);
    }

    final dob = (patient.dateOfBirth != null && patient.dateOfBirth!.isNotEmpty) ? patient.dateOfBirth : patient.patientProfile?['date_of_birth']?.toString();
    final ageText = _calculateAge(dob, context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 71,
          height: 72,
          decoration: ShapeDecoration(
            image: DecorationImage(
              image: (patient.photoUrl != null && patient.photoUrl!.isNotEmpty)
                  ? NetworkImage(patient.photoUrl!) as ImageProvider
                  : const AssetImage(AppImages.onboardingBackground), // Assuming we have some generic placeholder
              fit: BoxFit.cover,
            ),
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: AppColors.neutral250),
              borderRadius: BorderRadius.circular(35.50),
            ),
            shadows: const [
              BoxShadow(
                color: AppColors.shadowBlack25,
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                patient.name.isEmpty ? 'Patient' : patient.name,
                style: AppTextStyles.patientDetailNameBlack18ExtraBold,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Status'.tr(context),
                    style: AppTextStyles.patientDetailLabelBlack14SemiBold.copyWith(
                      fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: ShapeDecoration(
                      color: statusBgColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        status.isNotEmpty 
                            ? '${status[0].toUpperCase()}${status.substring(1).toLowerCase()}'.tr(context).toUpperCase()
                            : status,
                        style: AppTextStyles.chartStatusValue10ExtraBold
                            .copyWith(
                              color: AppColors.neutralBlack,
                              fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
                            ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                ageText,
                style: AppTextStyles.patientDetailMetaBlack14Medium.copyWith(
                  fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.tealP.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const UserQrWidget(
            size: 72,
            qrColor: AppColors.redDeep,
          ),
        ),
      ],
    );
  }
}


