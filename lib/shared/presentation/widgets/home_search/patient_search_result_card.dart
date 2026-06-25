import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/constants/app_images.dart';
import 'package:grad_imp_1/shared/presentation/widgets/home_search/critical_status_badge.dart';
import 'package:grad_imp_1/shared/presentation/widgets/home_search/doctor_search_patient_item.dart';

class PatientSearchResultCard extends StatelessWidget {
  const PatientSearchResultCard({super.key, required this.data, required this.onTap});

  final DoctorSearchPatientItem data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            begin: Alignment(0.66, 1.04),
            end: Alignment(0.43, -0.00),
            colors: [AppColors.redSurface, Colors.white],
          ),
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 0.5,
              color: AppColors.redSoft,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          shadows: const [
            BoxShadow(
              color: AppColors.shadowBlack25,
              blurRadius: 20,
              offset: Offset(-5, 5),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: ShapeDecoration(
                image: DecorationImage(
                  image: data.image.isNotEmpty
                      ? (data.image.startsWith('http')
                          ? NetworkImage(data.image)
                          : AssetImage(data.image)) as ImageProvider
                      : const AssetImage(AppImages.onboardingBackground),
                  fit: BoxFit.cover,
                ),
                shape: const OvalBorder(
                  side: BorderSide(width: 1.5, color: AppColors.redDeep),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackNeutral,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.medical_services_outlined,
                        size: 16,
                        color: AppColors.redDeep,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          data.diagnosis,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.tag, size: 16, color: AppColors.redDeep),
                      const SizedBox(width: 6),
                      Text(
                        data.patientId,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CriticalStatusBadge(text: data.status),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.redDeep,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
