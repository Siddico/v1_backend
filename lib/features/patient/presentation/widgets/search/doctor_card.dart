import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/constants/app_images.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';

/// Doctor card widget
class DoctorCard extends StatelessWidget {
  const DoctorCard({super.key, 
    required this.name,
    required this.specialty,
    required this.onTap,
    this.photoUrl,
  });

  final String name;
  final String specialty;
  final VoidCallback onTap;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            begin: Alignment(0.66, 1.04),
            end: Alignment(0.43, -0.00),
            colors: [AppColors.tealIconActive, Colors.white],
          ),
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 0.5,
              color: AppColors.tealPrimaryDarker,
            ),
            borderRadius: const BorderRadiusDirectional.only(
              bottomStart: Radius.circular(7),
              bottomEnd: Radius.circular(7),
            ),
          ),
          shadows: const [
            BoxShadow(
              color: AppColors.shadowBlack25,
              blurRadius: 26,
              offset: Offset(-11, 11),
              spreadRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: ShapeDecoration(
                image: DecorationImage(
                  image: (photoUrl != null && photoUrl!.isNotEmpty)
                      ? NetworkImage(photoUrl!) as ImageProvider
                      : const AssetImage(AppImages.onboardingBackground),
                  fit: BoxFit.cover,
                ),
                shape: const OvalBorder(
                  side: BorderSide(width: 1, color: AppColors.tealP),
                ),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTextStyles.doctorNameTealDark22Bold),
                  const SizedBox(height: 5),
                  Text(
                    specialty,
                    style: AppTextStyles.doctorSpecialtyTealIcon12Bold,
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              AppImages.personSvg,
              width: 32,
              height: 32,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
