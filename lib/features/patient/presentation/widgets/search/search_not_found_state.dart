import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grad_imp_1/core/localization/app_localizations.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/constants/app_images.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:grad_imp_1/core/constants/app_constants.dart';

class SearchNotFoundState extends StatelessWidget {
  const SearchNotFoundState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 361,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 59.59,
              height: 59.59,
              decoration: const ShapeDecoration(
                color: AppColors.neutralSurface,
                shape: OvalBorder(),
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppImages.searchUnselectedSvg,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Oops! No this data is founded'.tr(context),
              textAlign: TextAlign.center,
              style: AppTextStyles.emptyBellTitle20SemiBold,
            ),
            const SizedBox(height: 8),
            Text(
              'Try typing the doctor\'s exact name, their specialty, or pick from the available suggestions below.'.tr(context),
              textAlign: TextAlign.center,
              style: AppTextStyles.emptyBellBody15Regular,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.push(AppConstants.routeScanQr);
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: Text('Scan Doctor QR'.tr(context)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tealP,
                foregroundColor: Colors.white,
                textStyle: TextStyle(
                  fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
