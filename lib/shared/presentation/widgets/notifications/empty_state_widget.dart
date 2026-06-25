// Empty State Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 12,
            children: [
              Container(
                width: 59.59,
                height: 59.59,
                decoration: const ShapeDecoration(
                  color: AppColors.neutralSurface,
                  shape: OvalBorder(),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/Icon_bell_ofnotification_patient.png',
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Text(
                'Oops! No notifications yet'.tr(context),
                textAlign: TextAlign.center,
                style: AppTextStyles.emptyBellTitle20SemiBold,
              ),
              Text(
                'It seems that you\'re you got a blank state. We\'ll let you know when updates arrive!'.tr(context),
                textAlign: TextAlign.center,
                style: AppTextStyles.emptyBellBody15Regular,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
