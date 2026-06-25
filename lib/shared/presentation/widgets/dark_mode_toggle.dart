import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/constants/app_images.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/shared/presentation/widgets/app_toast.dart';

/// Dark mode toggle button
class DarkModeToggle extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onTap;
  final Color? lightColor; // Color when light mode is active (sun showing)
  final Color? darkColor; // Color when dark mode is active (moon showing)

  const DarkModeToggle({
    super.key,
    this.lightColor,
    this.darkColor,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppToast.show(context, 'Coming soon!');
        onTap();
      },
      child: Container(
        width: 45,
        height: 43,
        padding: const EdgeInsets.all(10),
        decoration: ShapeDecoration(
          color: isDarkMode
              ? (darkColor ?? AppColors.tealP)
              : (lightColor ?? AppColors.tealP),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(333),
          ),
          shadows: [
            BoxShadow(
              color: AppColors.shadowBlack25,
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Image.asset(
          isDarkMode ? AppImages.darkTheme : AppImages.lightTheme,
          width: 24,
          height: 24,
        ),
      ),
    );
  }
}
