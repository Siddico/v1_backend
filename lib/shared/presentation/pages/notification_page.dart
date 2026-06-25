import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/domain/entities/notification_entity.dart';
import '../../../../shared/presentation/controllers/notification_providers.dart';
import '../../../../shared/presentation/widgets/circular_loading_indicator.dart';
import '../../../../features/auth/presentation/controllers/auth_providers.dart';
import '../../../../features/doctor/presentation/pages/doctor_chat_page.dart';
import '../../../../features/patient/presentation/pages/patient_messages_page.dart';
import '../../../../core/localization/app_localizations.dart';

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4BBFCB), Colors.white],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Top Header Area
              SizedBox(
                height: 140,
                child: Stack(
                  children: [
                    Positioned(
                      right: 24,
                      top: 12,
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.close,
                            color: Color(0xFF0C1523),
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 226,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 1.5,

                              color: Color(0xFF1B808E),
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x1C000000),
                              blurRadius: 11,
                              offset: Offset(3, 4),
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          'Notification'.tr(context),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF1B808E),
                            fontSize: 22,
                            fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Inter',
                            fontWeight: FontWeight.w600,
                            height: 1.10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Floating White Card
              Container(
                height: size.height * 0.58,
                width: double.infinity,
                margin: const EdgeInsetsDirectional.only(start: 22, end: 22, bottom: 20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                clipBehavior: Clip.antiAlias,
                decoration: const ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusDirectional.only(
                      topStart: Radius.circular(32),
                      topEnd: Radius.circular(32),
                      bottomStart: Radius.circular(0),
                      bottomEnd: Radius.circular(0),
                    ),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Color(0x1C000000),
                      blurRadius: 11,
                      offset: Offset(3, 4),
                      spreadRadius: 11,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                                color: Color(0xFF1B808E),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Sort By'.tr(context),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF166771),
                                  fontSize: 12,
                                  fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Inter',
                                  fontWeight: FontWeight.w500,
                                  height: 1.60,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                size: 18,
                                color: Color(0xFF1B808E),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Expanded(child: _buildContent(notificationsAsync, ref)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    AsyncValue<List<NotificationEntity>> state,
    WidgetRef ref,
  ) {
    return state.when(
      loading: () =>
          const CircularLoadingIndicator(size: 72, color: AppColors.tealP),
      error: (err, _) => _NotificationError(
        message: err.toString(),
        onRetry: () => ref.invalidate(notificationsProvider),
      ),
      data: (notifications) {
        if (notifications.isEmpty) {
          return const _NotificationEmpty();
        }
        return _NotificationList(notifications: notifications);
      },
    );
  }
}

class _NotificationList extends StatelessWidget {
  const _NotificationList({required this.notifications});

  final List<NotificationEntity> notifications;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: notifications.length,
      separatorBuilder: (_, index) =>
          const Divider(height: 24, thickness: 1, color: Color(0xFFF0F1F3)),
      itemBuilder: (_, index) =>
          _NotificationItem(notification: notifications[index]),
    );
  }
}

class _NotificationItem extends ConsumerWidget {
  const _NotificationItem({required this.notification});

  final NotificationEntity notification;

  Color _statusColor() {
    final title = notification.title.toLowerCase();
    if (title.contains('risk') ||
        title.contains('alert') ||
        title.contains('high')) {
      return const Color(0xFFFF3939); // Red
    }
    if (title.contains('welcome')) {
      return const Color(0xFF24BD83); // Green
    }
    return const Color(0xFFFFCC00); // Yellow/Orange default
  }

  void _handleTap(BuildContext context, WidgetRef ref) {
    if (notification.isUnread) {
      ref.read(notificationRepositoryProvider).markAsRead(notification.id);
    }

    if (notification.title.toLowerCase().contains('message') &&
        notification.conversationId != null) {
      final user =
          ref.read(authControllerProvider).valueOrNull ??
          ref.read(authStateProvider).valueOrNull;
      if (user != null) {
        if (user.role == UserRole.doctor) {
          String contactName = 'Patient';
          if (notification.title.startsWith('New Message from ')) {
            contactName = notification.title.replaceAll(
              'New Message from ',
              '',
            );
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorChatPage(
                contactName: contactName,
                contactImage:
                    notification.senderImage ?? AppImages.patientImage,
                conversationId: notification.conversationId!,
                otherId: notification.senderId ?? '',
              ),
            ),
          );
        } else {
          String contactName = 'Doctor';
          if (notification.title.startsWith('New Message from ')) {
            contactName = notification.title.replaceAll(
              'New Message from ',
              '',
            );
          }
          context.push(
            AppConstants.routeMessages,
            extra: PatientChatArgs(
              contactName: contactName,
              contactImage: notification.senderImage ?? AppImages.makramImage,
              conversationId: notification.conversationId!,
              otherId: notification.senderId ?? '',
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      child: InkWell(
        onTap: () => _handleTap(context, ref),
        child: Container(
          color: notification.isUnread
              ? AppColors.tealPrimaryLight.withValues(alpha: 0.05)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(13),
                decoration: ShapeDecoration(
                  color: const Color(0xFFF0F1F3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(44),
                        ),
                      ),
                      child: ClipOval(
                        child:
                            (notification.senderImage != null &&
                                notification.senderImage!.isNotEmpty)
                            ? Image.network(
                                notification.senderImage!,
                                width: 22,
                                height: 22,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(
                                      AppImages.makramImage,
                                      width: 22,
                                      height: 22,
                                      fit: BoxFit.cover,
                                    ),
                              )
                            : Image.asset(
                                AppImages.makramImage,
                                width: 22,
                                height: 22,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    if (notification.isUnread)
                      Positioned(
                        left: 24,
                        // right: 24,
                        top: -10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: ShapeDecoration(
                            color: _statusColor(),
                            shape: const OvalBorder(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title.tr(context),
                      style: TextStyle(
                        color: const Color(0xFF667085),
                        fontSize: 14,
                        fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Inter',
                        fontWeight: notification.isUnread
                            ? FontWeight.w600
                            : FontWeight.w400,
                        height: 1.60,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.subtitle.tr(context),
                      style: TextStyle(
                        color: const Color(0xFF0C1523),
                        fontSize: 14,
                        fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Inter',
                        fontWeight: notification.isUnread
                            ? FontWeight.w700
                            : FontWeight.w500,
                        height: 1.60,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.time.tr(context),
                      style: TextStyle(
                        color: const Color(0xFF667085),
                        fontSize: 12,
                        fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.60,
                      ),
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

class _NotificationEmpty extends StatelessWidget {
  const _NotificationEmpty();

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
                  color: AppColors.tealSurface,
                  shape: OvalBorder(),
                ),
                child: Center(
                  child: Image.asset(
                    "assets/images/Icon_bell_ofnotification_patient.png",
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'No notifications yet'.tr(context),
                textAlign: TextAlign.center,
                style: AppTextStyles
                    .doctorNotificationEmptyTitleGray900_20SemiBold,
              ),
              const SizedBox(height: 8),
              Text(
                'Patient updates and reminders will appear here once they arrive.'.tr(context),
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

class _NotificationError extends StatelessWidget {
  const _NotificationError({required this.message, required this.onRetry});

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
                  color: AppColors.tealPrimaryLight,
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
                  style: AppTextStyles.doctorScanAgainRedDeep14Medium.copyWith(
                    color: AppColors.tealPrimaryDark,
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
