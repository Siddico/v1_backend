import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/localization/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/presentation/widgets/app_bar_controls.dart';

class DoctorHomeHeader extends StatelessWidget {
  const DoctorHomeHeader({super.key, 
    required this.isDarkMode,
    required this.onDarkModeToggle,
    required this.doctorName,
    this.doctorImage,
  });

  final bool isDarkMode;
  final VoidCallback onDarkModeToggle;
  final String doctorName;
  final String? doctorImage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -100,
            top: -280,
            child: Container(
              width: 560,
              height: 540,
              decoration: const ShapeDecoration(
                color: AppColors.redSoft,
                shape: OvalBorder(),
                shadows: [
                  BoxShadow(
                    color: AppColors.redVivid,
                    blurRadius: 111,
                    offset: Offset(11, 22),
                    spreadRadius: 11,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: -100,
            top: -280,
            child: Container(
              width: 560,
              height: 540,
              decoration: const ShapeDecoration(
                color: AppColors.white,
                shape: OvalBorder(),
                shadows: [
                  BoxShadow(
                    color: AppColors.shadowBlack25,
                    blurRadius: 111,
                    offset: Offset(11, 22),
                    spreadRadius: 11,
                  ),
                ],
              ),
            ),
          ),

          AppBarControls(
            isDarkMode: isDarkMode,
            onDarkModeToggle: onDarkModeToggle,
            onLanguageSelect: () {},
            darkModeToggleLightColor: AppColors.pinkLight,
            darkModeToggleDarkColor: AppColors.redDeep,
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(22, 120, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Welcome $doctorName',
                      style: AppTextStyles.doctorWelcomeTitleBlack30CroissantRegular,
                    ),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12),
                        color: Colors.grey[200],
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: doctorImage != null && doctorImage!.isNotEmpty
                          ? (doctorImage!.startsWith('http')
                                ? Image.network(
                                    doctorImage!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.person,
                                              color: Colors.grey,
                                            ),
                                  )
                                : Image.asset(
                                    doctorImage!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.person,
                                              color: Colors.grey,
                                            ),
                                  ))
                          : const Icon(Icons.person, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  'Are you ready to access your dashboard to manage patients and analyze results?'
                      .tr(context),
                  style: AppTextStyles.doctorWelcomeDescriptionNeutral550_17
                      .copyWith(
                        fontFamily: AppTextStyles.isArabic
                            ? 'Cairo'
                            : 'Poppins',
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
