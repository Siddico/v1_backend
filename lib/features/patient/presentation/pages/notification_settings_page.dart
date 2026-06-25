import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/presentation/widgets/app_bar_controls.dart';
import '../../../../shared/presentation/widgets/bottom_background_circles.dart';
import '../../../../core/localization/app_localizations.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _isDarkMode = false;

  // Push notification toggles
  bool _strokeAlerts = true;
  bool _criticalAlerts = true;
  bool _appointmentReminders = true;
  bool _messageNotifications = true;
  bool _reportReady = true;

  // Sound & Vibration
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _doNotDisturb = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 110, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Notification Settings'.tr(context),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleTeal22BoldShadow,
                  ),
                  const SizedBox(height: 32),

                  // ── Health Alerts ─────────────────────────────────────────
                  _SectionCard(
                    title: 'Health Alerts',
                    children: [
                      _NotifTile(
                        icon: Icons.warning_amber_rounded,
                        iconColor: Colors.red[700]!,
                        title: 'Critical Stroke Alerts',
                        subtitle: 'Notify when AI detects high-risk prediction',
                        value: _criticalAlerts,
                        onChanged: (v) => setState(() => _criticalAlerts = v),
                        isHighPriority: true,
                      ),
                      const Divider(height: 1),
                      _NotifTile(
                        icon: Icons.monitor_heart_rounded,
                        iconColor: AppColors.tealP,
                        title: 'Stroke Risk Updates',
                        subtitle: 'Receive updates on your stroke risk level',
                        value: _strokeAlerts,
                        onChanged: (v) => setState(() => _strokeAlerts = v),
                      ),
                      const Divider(height: 1),
                      _NotifTile(
                        icon: Icons.assignment_rounded,
                        iconColor: AppColors.tealP,
                        title: 'Report Ready',
                        subtitle: 'When a new analysis report is available',
                        value: _reportReady,
                        onChanged: (v) => setState(() => _reportReady = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── General ───────────────────────────────────────────────
                  _SectionCard(
                    title: 'General',
                    children: [
                      _NotifTile(
                        icon: Icons.calendar_month_rounded,
                        iconColor: AppColors.tealP,
                        title: 'Appointment Reminders',
                        subtitle: 'Reminders for upcoming appointments',
                        value: _appointmentReminders,
                        onChanged: (v) => setState(() => _appointmentReminders = v),
                      ),
                      const Divider(height: 1),
                      _NotifTile(
                        icon: Icons.chat_bubble_outline_rounded,
                        iconColor: AppColors.tealP,
                        title: 'Messages',
                        subtitle: 'New messages from your doctor',
                        value: _messageNotifications,
                        onChanged: (v) => setState(() => _messageNotifications = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Sound & Vibration ─────────────────────────────────────
                  _SectionCard(
                    title: 'Sound & Vibration',
                    children: [
                      _NotifTile(
                        icon: Icons.volume_up_rounded,
                        iconColor: AppColors.tealP,
                        title: 'Sound',
                        subtitle: 'Play sound for notifications',
                        value: _soundEnabled,
                        onChanged: (v) => setState(() => _soundEnabled = v),
                      ),
                      const Divider(height: 1),
                      _NotifTile(
                        icon: Icons.vibration_rounded,
                        iconColor: AppColors.tealP,
                        title: 'Vibration',
                        subtitle: 'Vibrate for notifications',
                        value: _vibrationEnabled,
                        onChanged: (v) => setState(() => _vibrationEnabled = v),
                      ),
                      const Divider(height: 1),
                      _NotifTile(
                        icon: Icons.do_not_disturb_on_rounded,
                        iconColor: Colors.orange[700]!,
                        title: 'Do Not Disturb',
                        subtitle: 'Silence all notifications (except critical alerts)',
                        value: _doNotDisturb,
                        onChanged: (v) => setState(() => _doNotDisturb = v),
                      ),
                    ],
                  ),

                  // Note about critical alerts
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: Colors.red[700], size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Critical stroke alerts will always be delivered even in Do Not Disturb mode.'.tr(context),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(child: BottomBackgroundCircles()),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBarControls(
              isDarkMode: _isDarkMode,
              onDarkModeToggle: () => setState(() => _isDarkMode = !_isDarkMode),
              onLanguageSelect: () {},
              darkModeToggleLightColor: AppColors.tealBorderLight,
              darkModeToggleDarkColor: AppColors.tealP,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.tr(context).toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.tealP,
              letterSpacing: 1.2,
              fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.tealBorderLight),
            boxShadow: [
              BoxShadow(
                color: AppColors.tealP.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isHighPriority = false,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isHighPriority;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title.tr(context),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral900,
                        fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
                      ),
                    ),
                    if (isHighPriority) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red[700],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'PRIORITY'.tr(context),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle.tr(context),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.neutral500,
                    fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.tealP,
          ),
        ],
      ),
    );
  }
}
