import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/domain/entities/notification_entity.dart';
import '../../../../shared/presentation/controllers/notification_providers.dart';
import '../../../../shared/presentation/widgets/circular_loading_indicator.dart';
import '../../../../core/localization/app_localizations.dart';
import 'patient_detail_page.dart';

class DoctorNotificationView extends ConsumerWidget {
  const DoctorNotificationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final size = MediaQuery.of(context).size;
    final cardWidth = size.width > 400 ? 358.0 : size.width - 40;
    final cardHeight = size.height - 228.0;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          // Background decoration circles (from user design)
          Positioned(
            left: (size.width - 540) / 2,
            top: -312,
            child: SizedBox(
              width: 540,
              height: 540,
              child: Stack(
                children: [
                  Positioned(
                    left: 37,
                    top: 0,
                    child: Container(
                      width: 468,
                      height: 468,
                      decoration: const ShapeDecoration(
                        color: Color(0xFFE77E8C),
                        shape: OvalBorder(),
                        shadows: [
                          BoxShadow(
                            color: Color(0xFFCE1126),
                            blurRadius: 111,
                            offset: Offset(11, 22),
                            spreadRadius: 11,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 37,
                    top: 0,
                    child: Container(
                      width: 500,
                      height: 468,
                      decoration: const ShapeDecoration(
                        color: Colors.white,
                        shape: OvalBorder(),
                        shadows: [
                          BoxShadow(
                            color: Color(0x3F000000),
                            blurRadius: 111,
                            offset: Offset(11, 22),
                            spreadRadius: 11,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 199,
                    top: 15,
                    child: Container(
                      width: 166,
                      height: 152,
                      decoration: const ShapeDecoration(
                        color: Color(0xFFEFA9B3),
                        shape: OvalBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main content container
          Positioned(
            left: (size.width - cardWidth) / 2,
            top: 198,
            width: cardWidth,
            height: cardHeight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusDirectional.only(
                    topStart: Radius.circular(32),
                    topEnd: Radius.circular(32),
                  ),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: _buildContent(notificationsAsync, ref, context),
            ),
          ),

          // Floating close button
          SafeArea(
            child: Align(
              alignment: AlignmentDirectional.topEnd,
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  margin: const EdgeInsetsDirectional.only(top: 20, end: 24),
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x1F000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 24,
                    color: Color(0xFF0C1523),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    AsyncValue<List<NotificationEntity>> state,
    WidgetRef ref,
    BuildContext context,
  ) {
    return state.when(
      loading: () => const Center(
        child: CircularLoadingIndicator(size: 48, color: Color(0xFFE77E8C)),
      ),
      error: (err, _) => _DoctorNotificationError(
        message: err.toString(),
        onRetry: () => ref.invalidate(notificationsProvider),
      ),
      data: (notifications) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24,
          children: [
            // Header Row
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10,
                children: [
                  Text(
                    'Latest notification'.tr(context),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF0C1523),
                      fontSize: 16,
                      fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Inter',
                      fontWeight: FontWeight.w500,
                      height: 1.60,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 1,
                          color: Color(0xFFF0F1F3),
                        ),
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
                          style: TextStyle(
                            color: const Color(0xFF0C1523),
                            fontSize: 12,
                            fontFamily: AppTextStyles.isArabic
                                ? 'Cairo'
                                : 'Inter',
                            fontWeight: FontWeight.w500,
                            height: 1.60,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: Color(0xFF0C1523),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // List of notifications
            Expanded(
              child: notifications.isEmpty
                  ? const _DoctorNotificationEmpty()
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: notifications.length,
                      // ignore: unnecessary_underscores
                      separatorBuilder: (_, __) => const Divider(
                        height: 24,
                        thickness: 1,
                        color: Color(0xFFF0F1F3),
                      ),
                      itemBuilder: (context, index) {
                        return _DoctorNotificationItem(
                          notification: notifications[index],
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _DoctorNotificationItem extends ConsumerWidget {
  const _DoctorNotificationItem({required this.notification});

  final NotificationEntity notification;

  Color _statusColor() {
    final combined = '${notification.title} ${notification.subtitle}'
        .toLowerCase();
    if (combined.contains('risk') ||
        combined.contains('critical') ||
        combined.contains('urgent') ||
        combined.contains('alert') ||
        combined.contains('danger')) {
      return const Color(0xFFFF3939); // Red
    }
    if (combined.contains('welcome') ||
        combined.contains('success') ||
        combined.contains('connected') ||
        combined.contains('approved') ||
        combined.contains('stable')) {
      return const Color(0xFF24BD83); // Green
    }
    return const Color(0xFFFFCC00); // Yellow
  }

  String _getSenderName(BuildContext context) {
    final title = notification.title.toLowerCase();
    final subtitle = notification.subtitle.toLowerCase();

    if (title.contains('risk') || subtitle.contains('risk')) {
      if (subtitle.contains('patient ')) {
        final startIndex = subtitle.indexOf('patient ') + 8;
        final endIndex = subtitle.indexOf(' —', startIndex);
        if (endIndex != -1) {
          return notification.subtitle.substring(startIndex, endIndex);
        }
        final endIndexAlt = subtitle.indexOf(' ', startIndex);
        if (endIndexAlt != -1) {
          return notification.subtitle.substring(startIndex, endIndexAlt);
        }
      }
      return 'Patient Alert'.tr(context);
    }

    if (title.contains('request') || subtitle.contains('request')) {
      return 'Connection Request'.tr(context);
    }

    return 'System'.tr(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = notification.title.toLowerCase();
    final subtitle = notification.subtitle.toLowerCase();
    final isRequest = title.contains('request') || subtitle.contains('request');
    final isPrediction =
        title.contains('prediction') ||
        title.contains('risk') ||
        subtitle.contains('prediction') ||
        subtitle.contains('risk');

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      movementDuration: const Duration(milliseconds: 100),
      resizeDuration: const Duration(milliseconds: 100),
      dismissThresholds: const {DismissDirection.endToStart: 0.3},
      onDismissed: (_) {
        ref
            .read(notificationRepositoryProvider)
            .removeNotification(notification.id);
      },
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 20),
        color: AppColors.redBright,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (notification.isUnread) {
            ref
                .read(notificationRepositoryProvider)
                .markAsRead(notification.id);
          }
          if (isRequest) {
            context.push(AppConstants.routeDoctorRequests);
          } else if (isPrediction && notification.senderId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    PatientDetailPage(patientId: notification.senderId!),
              ),
            );
          }
        },
        child: Container(
          width: double.infinity,
          color: notification.isUnread
              ? const Color(0xFFEFA9B3).withValues(alpha: 0.1)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              // Avatar Stack
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFF0F1F3).withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: ClipOval(
                      child:
                          (notification.senderImage != null &&
                              notification.senderImage!.isNotEmpty)
                          ? Image.network(
                              notification.senderImage!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  AppImages.patientImage,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : Image.asset(
                              AppImages.patientImage,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  if (notification.isUnread)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: ShapeDecoration(
                          color: _statusColor(),
                          shape: const OvalBorder(
                            side: BorderSide(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Content Column
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Text(
                            notification.title.tr(context),
                            style: TextStyle(
                              color: const Color(0xFF667085),
                              fontSize: 14,
                              fontFamily: AppTextStyles.isArabic
                                  ? 'Cairo'
                                  : 'Inter',
                              fontWeight: notification.isUnread
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              height: 1.60,
                            ),
                          ),
                          Text(
                            notification.subtitle.tr(context),
                            style: TextStyle(
                              color: const Color(0xFF0C1523),
                              fontSize: 14,
                              fontFamily: AppTextStyles.isArabic
                                  ? 'Cairo'
                                  : 'Inter',
                              fontWeight: notification.isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              height: 1.60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getSenderName(context),
                          style: TextStyle(
                            color: const Color(0xFF667085),
                            fontSize: 12,
                            fontFamily: AppTextStyles.isArabic
                                ? 'Cairo'
                                : 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.60,
                          ),
                        ),
                        Text(
                          notification.time.tr(context),
                          style: TextStyle(
                            color: Color(0xFF667085),
                            fontSize: 12,
                            fontFamily: AppTextStyles.isArabic
                                ? 'Cairo'
                                : 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.60,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorNotificationEmpty extends StatelessWidget {
  const _DoctorNotificationEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const ShapeDecoration(
                  color: AppColors.redSurface,
                  shape: OvalBorder(),
                ),
                child: Image.asset(
                  AppImages.bellNotifications,
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'No doctor notifications yet'.tr(context),
                textAlign: TextAlign.center,
                style: AppTextStyles
                    .doctorNotificationEmptyTitleGray900_20SemiBold,
              ),
              const SizedBox(height: 8),
              Text(
                'You will see patient alerts and updates here once they arrive.'
                    .tr(context),
                textAlign: TextAlign.center,
                style: AppTextStyles
                    .doctorNotificationEmptyBodyNeutralMid15Regular,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorNotificationError extends StatelessWidget {
  const _DoctorNotificationError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 20),
              Text(
                'Unable to load notifications'.tr(context),
                textAlign: TextAlign.center,
                style:
                    AppTextStyles.doctorNotificationFallbackTitleGray900_20Bold,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles
                    .doctorNotificationFallbackBodyNeutralMid15Regular,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: onRetry,
                child: Text(
                  'Retry'.tr(context),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.doctorScanAgainRedDeep14Medium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
