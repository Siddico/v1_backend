import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/theme/app_text_styles.dart';

class PatientGreetingHeader extends StatelessWidget {
  const PatientGreetingHeader({
    super.key,
    required this.userName,
    this.profileImageUrl,
    this.borderColor = AppColors.tealSurface,
  });

  final String userName;
  final String? profileImageUrl;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        // Profile Image
        Container(
          width: 56,
          height: 56,
          decoration: ShapeDecoration(
            image: DecorationImage(
              image: (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                  ? NetworkImage(profileImageUrl!) as ImageProvider
                  : const AssetImage(AppImages.onboardingBackground),
              fit: BoxFit.fill,
            ),
            shape: CircleBorder(side: BorderSide(width: 1, color: borderColor)),
            shadows: [
              BoxShadow(
                color: AppColors.shadowBlack25,
                blurRadius: 4,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
        ),
        // Greeting Text
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back',
                style: AppTextStyles.greetingAladin38TealDark,
              ),
              Text(
                userName,
                style: AppTextStyles.greetingUserName12MediumBlack.copyWith(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
