// Error State Widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorStateWidget({super.key, required this.message, required this.onRetry});

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
                  color: AppColors.redLight,
                  shape: OvalBorder(),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              Text(
                'Something went wrong',
                textAlign: TextAlign.center,
                style: AppTextStyles.errorTitle22Bold,
              ),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.errorBody17Regular,
              ),
              GestureDetector(
                onTap: onRetry,
                child: Text(
                  'Try Again',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.sfProActionLink15SemiBold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
