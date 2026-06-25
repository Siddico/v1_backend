import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class RoleDetailCard extends StatelessWidget {
  final String roleTitle;
  final String roleDescription;
  final Color titleColor;
  final double? titleFontSize;

  const RoleDetailCard({
    super.key,
    required this.roleTitle,
    required this.roleDescription,
    required this.titleColor,
    this.titleFontSize = 27,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 11,
      children: [
        Container(
          height: 55,
          width: 201,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadiusDirectional.only(
              topEnd: Radius.circular(25),
              bottomEnd: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowBlack10,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                roleTitle,
                style: AppTextStyles.roleCardTitleInter(
                  titleColor,
                  titleFontSize,
                ),
              ),
              const Spacer(),
              SvgPicture.asset(
                'assets/images/arrow.svg',
                // ignore: deprecated_member_use
                color: titleColor,
                width: 16,
                height: 16,
              ),
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Text(
            roleDescription,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.roleCardDescription12Light,
          ),
        ),
      ],
    );
  }
}
