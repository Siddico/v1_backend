import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/localization/locale_provider.dart';
import 'package:grad_imp_1/shared/presentation/widgets/app_toast.dart';

/// Language selector button with flag
class LanguageSelector extends ConsumerWidget {
  final VoidCallback? onTap;
  final Color? textColor;

  const LanguageSelector({super.key, this.onTap, this.textColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isArabic = locale.languageCode == 'ar';

    return GestureDetector(
      onTap: () {
        ref.read(localeProvider.notifier).toggleLocale();

        // Determine target language toast text immediately to avoid build cycle race conditions
        final targetIsArabic = !isArabic;
        final toastMsg = targetIsArabic
            ? 'تم تغيير لغة التطبيق بنجاح'
            : 'Language switched successfully';

        AppToast.show(
          context,
          toastMsg,
          type: AppToastType.success,
          translate: false,
        );

        if (onTap != null) {
          onTap!();
        }
      },
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: ShapeDecoration(
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          shadows: [
            BoxShadow(
              color: AppColors.shadowBlack25,
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isArabic ? 'English' : 'عربي',
              style: TextStyle(
                fontFamily: isArabic ? 'Poppins' : 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: textColor ?? AppColors.tealP,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.keyboard_arrow_down_outlined,
              size: 20,
              color: AppColors.black,
            ),
          ],
        ),
      ),
    );
  }
}
