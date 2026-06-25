import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';

class CallIdentityPanel extends StatelessWidget {
  const CallIdentityPanel({
    super.key,
    required this.name,
    required this.status,
    required this.avatar,
    this.statusOpacity = 0.75,
  });

  final String name;
  final String status;
  final ImageProvider avatar;
  final double statusOpacity;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final avatarSize = (width * 0.22).clamp(82.0, 108.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: avatar, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          name,
          textAlign: TextAlign.center,
          style: AppTextStyles.callIdentityNameWhite24Bold,
        ),
        const SizedBox(height: 8),
        Text(
          status,
          textAlign: TextAlign.center,
          style: AppTextStyles.callIdentityStatusWhite17(statusOpacity),
        ),
      ],
    );
  }
}
