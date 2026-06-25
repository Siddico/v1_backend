// Notification List Widget
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'notification_message_item_widget.dart';
import '../../../../core/localization/app_localizations.dart';

class NotificationListWidget extends StatelessWidget {
  final List notifications;

  const NotificationListWidget({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardWidth = size.width > 460 ? 420.0 : size.width - 32;
    final cardHeight = size.height * 0.62;

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsetsDirectional.only(top: 190),
          width: cardWidth,
          height: cardHeight,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusDirectional.only(
                topStart: Radius.circular(32),
                topEnd: Radius.circular(32),
              ),
            ),
            shadows: [
              BoxShadow(
                color: AppColors.shadowLight11,
                blurRadius: 11,
                offset: Offset(3, 4),
                spreadRadius: 11,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 24,
            children: [
              // Header with title and sort button
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Latest notification'.tr(context),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.notificationSectionHeader16Medium,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1, color: AppColors.tealP),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 6,
                      children: [
                        Text(
                          'Sort By'.tr(context),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.sortButtonText12Medium,
                        ),
                        SvgPicture.asset(
                          'assets/images/arrow-down.svg',
                          height: 18,
                          width: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Notifications list
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 12,
                    children: [
                      for (int i = 0; i < notifications.length; i++) ...[
                        NotificationMessageItem(notification: notifications[i]),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
