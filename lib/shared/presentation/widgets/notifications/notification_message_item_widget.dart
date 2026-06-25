// New notification message item widget
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../features/auth/presentation/controllers/auth_providers.dart';
import '../../../../features/doctor/presentation/pages/doctor_chat_page.dart';
import '../../../../features/patient/presentation/pages/patient_messages_page.dart';
import '../../controllers/notification_providers.dart';
import '../../../domain/entities/notification_entity.dart';
import '../../../../core/localization/app_localizations.dart';

class NotificationMessageItem extends ConsumerWidget {
  final NotificationEntity notification;

  const NotificationMessageItem({super.key, required this.notification});

  UserRole _getUserRole(WidgetRef ref) {
    final user =
        ref.read(authControllerProvider).valueOrNull ??
        ref.read(authStateProvider).valueOrNull;
    return user?.role ?? UserRole.patient;
  }

  Color _getPrimaryColor(UserRole role) {
    return role == UserRole.doctor ? const Color(0xFFE77E8C) : AppColors.tealP;
  }

  Map<String, dynamic> _getNotificationConfig(UserRole role) {
    final title = notification.title.toLowerCase();

    if (title.contains('risk') ||
        title.contains('warning') ||
        title.contains('high') ||
        title.contains('خطر')) {
      return {
        'icon': Icons.warning_amber_rounded,
        'color': AppColors.redBright,
        'bg': AppColors.redBright.withValues(alpha: 0.1),
        'isImage': false,
      };
    } else if (title.contains('welcome') ||
        title.contains('success') ||
        title.contains('مرحبا')) {
      return {
        'icon': Icons.verified_rounded,
        'color': AppColors.successGreen,
        'bg': AppColors.successGreen.withValues(alpha: 0.1),
        'isImage': false,
      };
    } else if (title.contains('medication') ||
        title.contains('pill') ||
        title.contains('دواء')) {
      return {
        'icon': Icons.medication_rounded,
        'color': Colors.orangeAccent.shade700,
        'bg': Colors.orangeAccent.shade100.withValues(alpha: 0.3),
        'isImage': false,
      };
    } else if (title.contains('appointment') ||
        title.contains('schedule') ||
        title.contains('موعد')) {
      return {
        'icon': Icons.calendar_month_rounded,
        'color': Colors.blueAccent,
        'bg': Colors.blueAccent.withValues(alpha: 0.1),
        'isImage': false,
      };
    } else if (title.contains('message') || title.contains('رسالة')) {
      return {
        'icon': Icons.chat_bubble_outline_rounded,
        'color': _getPrimaryColor(role),
        'bg': _getPrimaryColor(role).withValues(alpha: 0.1),
        'isImage': true,
      };
    } else if (title.contains('prediction') ||
        title.contains('ai') ||
        title.contains('توقع')) {
      return {
        'icon': Icons.analytics_outlined,
        'color': Colors.purpleAccent,
        'bg': Colors.purpleAccent.withValues(alpha: 0.1),
        'isImage': false,
      };
    } else {
      return {
        'icon': Icons.notifications_active_rounded,
        'color': _getPrimaryColor(role),
        'bg': _getPrimaryColor(role).withValues(alpha: 0.1),
        'isImage': false,
      };
    }
  }

  void _handleTap(BuildContext context, WidgetRef ref) {
    if (notification.isUnread) {
      ref.read(notificationRepositoryProvider).markAsRead(notification.id);
    }

    final title = notification.title.toLowerCase();

    // Route for Messages
    if ((title.contains('message') || title.contains('رسالة')) &&
        notification.conversationId != null) {
      final role = _getUserRole(ref);
      if (role == UserRole.doctor) {
        String contactName = 'Patient';
        if (notification.title.startsWith('New Message from ')) {
          contactName = notification.title.replaceAll('New Message from ', '');
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorChatPage(
              contactName: contactName,
              contactImage: notification.senderImage ?? AppImages.patientImage,
              conversationId: notification.conversationId!,
              otherId: notification.senderId ?? '',
            ),
          ),
        );
      } else {
        String contactName = 'Doctor';
        if (notification.title.startsWith('New Message from ')) {
          contactName = notification.title.replaceAll('New Message from ', '');
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
    // Route for Medications / Appointments -> profile tab 3
    else if (title.contains('medication') ||
        title.contains('دواء') ||
        title.contains('appointment') ||
        title.contains('موعد')) {
      final role = _getUserRole(ref);
      if (role == UserRole.patient) {
        context.go(
          AppConstants.routeHome,
          extra: 3,
        ); // Profile tab index 3 usually
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = _getUserRole(ref);
    final config = _getNotificationConfig(role);
    final primaryThemeColor = _getPrimaryColor(role);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref
            .read(notificationRepositoryProvider)
            .removeNotification(notification.id);
      },
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 20),
        decoration: BoxDecoration(
          color: AppColors.redBright,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: notification.isUnread
              ? primaryThemeColor.withValues(alpha: 0.04)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isUnread
                ? primaryThemeColor.withValues(alpha: 0.3)
                : AppColors.tealBorderLight.withValues(alpha: 0.4),
            width: notification.isUnread ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight11.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _handleTap(context, ref),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon or Avatar Section
                  _buildIconOrAvatar(config),
                  const SizedBox(width: 16),

                  // Content Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                notification.title.tr(context),
                                style: AppTextStyles
                                    .notificationTitleGray14Regular
                                    .copyWith(
                                      fontWeight: notification.isUnread
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: notification.isUnread
                                          ? AppColors.tealPrimaryDark
                                          : AppColors.textSecondary,
                                      fontSize: 15,
                                    ),
                              ),
                            ),
                            if (notification.isUnread)
                              Container(
                                margin: const EdgeInsetsDirectional.only(
                                  start: 8,
                                  top: 4,
                                ),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: primaryThemeColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notification.subtitle.tr(context),
                          style: AppTextStyles.notificationSubtitleDark14Medium
                              .copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: AppColors.textSecondary.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              notification.time.tr(context),
                              style: AppTextStyles.notificationTimeGray12Regular
                                  .copyWith(
                                    color: AppColors.textSecondary.withValues(alpha: 
                                      0.8,
                                    ),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
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
        ),
      ),
    );
  }

  Widget _buildIconOrAvatar(Map<String, dynamic> config) {
    if (config['isImage'] == true) {
      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: config['color'], width: 2),
          boxShadow: [
            BoxShadow(
              color: config['color'].withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipOval(
          child:
              (notification.senderImage != null &&
                  notification.senderImage!.isNotEmpty)
              ? Image.network(
                  notification.senderImage!,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      AppImages.makramImage,
                      fit: BoxFit.cover,
                    );
                  },
                )
              : Image.asset(AppImages.makramImage, fit: BoxFit.cover),
        ),
      );
    } else {
      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: config['bg'],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: config['color'].withValues(alpha: 0.3), width: 1),
        ),
        child: Center(
          child: Icon(config['icon'], color: config['color'], size: 26),
        ),
      );
    }
  }
}

