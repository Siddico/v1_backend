import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../shared/presentation/widgets/app_bar_controls.dart';
import '../../../../shared/presentation/widgets/bottom_background_circles.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../widgets/profile_components/prediction_history_section.dart';

class MedicalHistoryPage extends ConsumerStatefulWidget {
  const MedicalHistoryPage({super.key});

  @override
  ConsumerState<MedicalHistoryPage> createState() => _MedicalHistoryPageState();
}

class _MedicalHistoryPageState extends ConsumerState<MedicalHistoryPage> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    final size = MediaQuery.of(context).size;
    final maxContentWidth = size.width > 440 ? 420.0 : size.width - 24;

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background circles first (bottom of Z-order)
          const Positioned.fill(
            child: IgnorePointer(child: BottomBackgroundCircles()),
          ),

          // Main content
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.only(top: 125, bottom: 100),
              child: SizedBox(
                width: maxContentWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    Text(
                      'Medical History'.tr(context),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleTeal22BoldShadow,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your AI stroke risk prediction history'.tr(context),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.neutral500,
                        fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Inter',
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Prediction history list
                    PredictionHistorySection(
                      patientId: user?.id ?? '',
                      isDoctor: false,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Top controls last (top of Z-order to receive touch inputs)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBarControls(
              isDarkMode: _isDarkMode,
              onDarkModeToggle: () => setState(() => _isDarkMode = !_isDarkMode),
              onLanguageSelect: () {},
              darkModeToggleLightColor: AppColors.tealBorderLight,
              darkModeToggleDarkColor: AppColors.tealP,
            ),
          ),
        ],
      ),
    );
  }
}
