import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/constants/app_images.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';

class DeviceNotConnectedCard extends StatelessWidget {
  const DeviceNotConnectedCard({super.key, required this.onUploadPressed});

  final VoidCallback onUploadPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: const ShapeDecoration(
            color: AppColors.neutralSurface,
            shape: OvalBorder(),
          ),
          child: Image.asset(AppImages.bluetoothOff, width: 22, height: 22),
          // child: const Icon(Icons.wifi_off, color: AppColors.tealP, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          'Device not connected',
          textAlign: TextAlign.center,
          style: AppTextStyles.deviceNotConnectedTitle20Bold,
        ),
        const SizedBox(height: 6),
        Text(
          "Your health monitor isn't currently connected, so we can't analyze your signals or predict your current condition.\nPlease reconnect your smartwatch or you can predict manually",
          textAlign: TextAlign.center,
          style: AppTextStyles.deviceNotConnectedBody14Regular,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: onUploadPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.tealP,
            foregroundColor: AppColors.tealSurface,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            elevation: 4,
            shadowColor: AppColors.shadowBlack25,
          ),
          child: Text(
            'Upload data',
            style: AppTextStyles.buttonTextTealSurface15ExtraBold,
          ),
        ),

        SizedBox(height: 65),
      ],
    );
  }
}
