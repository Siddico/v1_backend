import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app_bar_controls.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/theme/app_text_styles.dart';

class MessagesHeader extends StatelessWidget {
  const MessagesHeader({
    super.key,
    required this.contactName,
    required this.subtitle,
    this.contactImage = AppImages.makramImage,
    this.primaryColor = AppColors.tealAccentMuted,
    this.iconColor = AppColors.tealBlue,
    this.darkModeToggleLightColor = AppColors.tealBorderLight,
    this.darkModeToggleDarkColor = AppColors.tealP,
    this.backgroundAlpha = 0.92,
    this.isDarkMode = true,
    this.onDarkModeToggle,
    this.onLanguageSelect,
    this.onAudioCallTap,
    this.onVideoCallTap,
  });

  final String contactName;
  final String subtitle;
  final String contactImage;
  final Color primaryColor;
  final Color iconColor;
  final Color darkModeToggleLightColor;
  final Color darkModeToggleDarkColor;
  final double backgroundAlpha;
  final bool isDarkMode;
  final VoidCallback? onDarkModeToggle;
  final VoidCallback? onLanguageSelect;
  final VoidCallback? onAudioCallTap;
  final VoidCallback? onVideoCallTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white.withValues(alpha: backgroundAlpha),
      child: Column(
        children: [
          AppBarControls(
            isDarkMode: isDarkMode,
            onDarkModeToggle: onDarkModeToggle ?? () {},
            onLanguageSelect: onLanguageSelect ?? () {},
            darkModeToggleLightColor: darkModeToggleLightColor,
            darkModeToggleDarkColor: darkModeToggleDarkColor,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: (contactImage.startsWith('http://') || contactImage.startsWith('https://'))
    ? NetworkImage(contactImage)
    : AssetImage(contactImage) as ImageProvider,

                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contactName,
                      style: AppTextStyles.messagesHeaderName(primaryColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style:
                          AppTextStyles.messagesHeaderSubtitleBlack35_13Medium,
                    ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onAudioCallTap,
                  child: SvgPicture.asset(
                    AppImages.callIcon,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: onVideoCallTap,
                  child: SvgPicture.asset(
                    AppImages.videoCallIcon,
                    width: 28,
                    height: 16,
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
