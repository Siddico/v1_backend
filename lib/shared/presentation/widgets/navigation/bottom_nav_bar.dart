import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grad_imp_1/core/constants/app_images.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.labels,
    this.selectedIcons,
    this.unselectedIcons,
    this.activeColor = AppColors.tealIconActive,
    this.inactiveColor = AppColors.tealA,
    this.centerButtonColor = AppColors.tealPrimaryLight,
    this.centerButtonBorderColor = AppColors.tealBorderLight,
    this.centerButtonIcon = AppImages.uploadSvg,
    this.centerButtonOnTap,
    this.centerButtonKey,
    this.chartsTabKey,
    this.profileTabKey,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<String>? labels;
  final List<String>? selectedIcons;
  final List<String>? unselectedIcons;
  final Color activeColor;
  final Color inactiveColor;
  final Color centerButtonColor;
  final Color centerButtonBorderColor;
  final String centerButtonIcon;
  final VoidCallback? centerButtonOnTap;
  final Key? centerButtonKey;
  final Key? chartsTabKey;
  final Key? profileTabKey;

  @override
  Widget build(BuildContext context) {
    final navLabels = labels ?? const ['Home', 'Search', 'Charts', 'Profile'];
    final selectedAssets =
        selectedIcons ??
        const [
          AppImages.homeSelectedSvg,
          AppImages.searchSelectedSvg,
          AppImages.chartsSelectedSvg,
          AppImages.profileSelectedSvg,
        ];
    final unselectedAssets =
        unselectedIcons ??
        const [
          AppImages.homeUnselectedSvg,
          AppImages.searchUnselectedSvg,
          AppImages.chartsUnselectedSvg,
          AppImages.profileUnselectedSvg,
        ];

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final compact = screenWidth < 370;
    final navHeight = (screenHeight * 0.11).clamp(78.0, 98.0);
    final centerButtonSize = compact ? screenWidth * 0.18 : screenWidth * 0.20;
    final horizontalInset = compact ? 8.0 : 14.0;
    final centerGap = centerButtonSize * (compact ? 0.72 : 0.82);
    final itemWidth = ((screenWidth - (horizontalInset * 2) - centerGap) / 4)
        .clamp(56.0, 84.0);

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: navHeight,
          padding: EdgeInsets.symmetric(horizontal: horizontalInset),
          clipBehavior: Clip.none,
          decoration: ShapeDecoration(
            color: AppColors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadiusDirectional.only(
                topStart: Radius.circular(32),
                topEnd: Radius.circular(32),
              ),
            ),
            shadows: [
              BoxShadow(
                color: AppColors.shadowBlack25,
                blurRadius: 22,
                offset: const Offset(0, -11),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Left and Right Navigation Items
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left items (Home, Search)
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(
                          context: context,
                          index: 0,
                          selectedSvgAsset: selectedAssets[0],
                          unselectedSvgAsset: unselectedAssets[0],
                          label: navLabels[0],
                          isSelected: currentIndex == 0,
                          compact: compact,
                          width: itemWidth,
                        ),
                        _buildNavItem(
                          context: context,
                          index: 1,
                          selectedSvgAsset: selectedAssets[1],
                          unselectedSvgAsset: unselectedAssets[1],
                          label: navLabels[1],
                          isSelected: currentIndex == 1,
                          compact: compact,
                          width: itemWidth,
                        ),
                      ],
                    ),
                  ),

                  // Central spacing
                  SizedBox(width: centerGap),

                  // Right items (Charts, Profile)
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(
                          context: context,
                          index: 2,
                          selectedSvgAsset: selectedAssets[2],
                          unselectedSvgAsset: unselectedAssets[2],
                          label: navLabels[2],
                          isSelected: currentIndex == 2,
                          compact: compact,
                          width: itemWidth,
                          key: chartsTabKey,
                        ),
                        _buildNavItem(
                          context: context,
                          index: 3,
                          selectedSvgAsset: selectedAssets[3],
                          unselectedSvgAsset: unselectedAssets[3],
                          label: navLabels[3],
                          isSelected: currentIndex == 3,
                          compact: compact,
                          width: itemWidth,
                          key: profileTabKey,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Floating Center Button
              Positioned(
                left: 0,
                right: 0,
                top: compact ? -screenHeight * 0.03 : -screenHeight * 0.04,
                child: Center(
                  child: GestureDetector(
                    key: centerButtonKey,
                    onTap: centerButtonOnTap ?? () => onTap(2),
                    child: Container(
                      clipBehavior: Clip.none,
                      width: centerButtonSize,
                      height: centerButtonSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowBlack25,
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Container(
                        clipBehavior: Clip.none,
                        margin: EdgeInsets.all(screenWidth * 0.01),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: centerButtonColor,
                          border: Border.all(
                            color: centerButtonBorderColor,
                            width: screenWidth * 0.01,
                          ),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            centerButtonIcon,
                            width: compact ? 22 : screenWidth * 0.07,
                            height: compact ? 22 : screenWidth * 0.07,
                            colorFilter: const ColorFilter.mode(
                              AppColors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required String selectedSvgAsset,
    required String unselectedSvgAsset,
    required String label,
    required bool isSelected,
    required bool compact,
    required double width,
    Key? key,
  }) {
    final iconColor = isSelected ? activeColor : inactiveColor;
    final iconAsset = isSelected ? selectedSvgAsset : unselectedSvgAsset;

    return GestureDetector(
      key: key,
      onTap: () => onTap(index),
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 4 : 6,
          vertical: compact ? 9 : 12.5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: compact ? 6 : 10,
          children: [
            SvgPicture.asset(
              iconAsset,
              width: compact ? 20 : 24,
              height: compact ? 20 : 24,
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
            Text(
              label,
              style: AppTextStyles.navItemLabel12(
                isSelected ? activeColor : inactiveColor,
                isSelected,
              ).copyWith(fontSize: compact ? 10 : 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
