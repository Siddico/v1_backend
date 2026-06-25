// No Internet State Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class NoInternetStateWidget extends StatelessWidget {
  final VoidCallback onRefresh;

  const NoInternetStateWidget({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 21,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const ShapeDecoration(
                  color: AppColors.tealA,
                  shape: OvalBorder(),
                ),
                child: const Icon(
                  Icons.wifi_off,
                  color: AppColors.white,
                  size: 35,
                ),
              ),
              Text(
                'No Internet Connection',
                textAlign: TextAlign.center,
                style: AppTextStyles.emptyStateTitleDark22Bold,
              ),
              Text(
                'Please check your internet connection\nor try again later.',
                textAlign: TextAlign.center,
                style: AppTextStyles.emptyStateBodyGray17Regular,
              ),
              GestureDetector(
                onTap: onRefresh,
                child: Text(
                  'Refresh',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.actionLinkTeal15SemiBold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
