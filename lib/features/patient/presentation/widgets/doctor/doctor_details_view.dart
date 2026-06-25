import 'package:grad_imp_1/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/constants/app_images.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';
import 'package:grad_imp_1/features/patient/presentation/widgets/doctor/stat_card.dart';

class DoctorHeaderCard extends StatelessWidget {
  const DoctorHeaderCard({super.key, 
    required this.name,
    required this.specialty,
    this.photoUrl,
    this.yearsExperience,
    this.patientsCount,
    this.licenseNumber,
  });
  final String name;
  final String specialty;
  final String? photoUrl;
  final String? yearsExperience;
  final String? patientsCount;
  final String? licenseNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: (photoUrl != null && photoUrl!.isNotEmpty)
                    ? NetworkImage(photoUrl!) as ImageProvider
                    : const AssetImage(AppImages.makramImage),
                fit: BoxFit.cover,
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowBlack25,
                  blurRadius: 33,
                  offset: Offset(-11, 5),
                  spreadRadius: 11,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            textAlign: TextAlign.center,
            style: AppTextStyles.doctorNameTeal20SemiBold,
          ),
          const SizedBox(height: 4),
          Text(
            '$specialty • Consultant',
            textAlign: TextAlign.center,
            style: AppTextStyles.doctorMetaTeal16Regular,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  value: (yearsExperience != null && yearsExperience!.isNotEmpty)
                      ? yearsExperience!
                      : '--',
                  label: 'Experience Years'.tr(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  value: (patientsCount != null && patientsCount!.isNotEmpty)
                      ? patientsCount!
                      : '--',
                  label: 'Patients'.tr(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  value: (licenseNumber != null && licenseNumber!.isNotEmpty)
                      ? licenseNumber!
                      : '--',
                  label: 'License Number'.tr(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
