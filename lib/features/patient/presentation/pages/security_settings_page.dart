import 'package:grad_imp_1/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/presentation/widgets/app_bar_controls.dart';
import '../../../../shared/presentation/widgets/app_toast.dart';
import '../../../../shared/presentation/widgets/bottom_background_circles.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';

class SecuritySettingsPage extends ConsumerStatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  ConsumerState<SecuritySettingsPage> createState() =>
      _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends ConsumerState<SecuritySettingsPage> {
  bool _biometricEnabled = false;
  bool _twoFactorEnabled = false;
  bool _isDarkMode = false;
  bool _isChangingPassword = false;

  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      AppToast.show(context, 'Passwords do not match'.tr(context), type: AppToastType.error);
      return;
    }
    if (_newPassCtrl.text.length < 6) {
      AppToast.show(context, 'Password must be at least 6 characters'.tr(context), type: AppToastType.error);
      return;
    }
    try {
      await ref.read(authControllerProvider.notifier).changePassword(
            currentPassword: _currentPassCtrl.text,
            newPassword: _newPassCtrl.text,
          );
      if (mounted) {
        setState(() => _isChangingPassword = false);
        _currentPassCtrl.clear();
        _newPassCtrl.clear();
        _confirmPassCtrl.clear();
        AppToast.show(context, 'Password changed successfully'.tr(context), type: AppToastType.success);
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(context, 'Failed to change password: $e', type: AppToastType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 110, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Security Settings'.tr(context),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleTeal22BoldShadow,
                  ),
                  const SizedBox(height: 32),

                  // ── Toggles section ──────────────────────────────────────
                  _SectionCard(
                    title: 'Authentication'.tr(context),
                    children: [
                      _ToggleTile(
                        icon: Icons.fingerprint_rounded,
                        iconColor: AppColors.tealP,
                        title: 'Biometric Login'.tr(context),
                        subtitle: 'Use fingerprint or face ID to sign in'.tr(context),
                        value: _biometricEnabled,
                        onChanged: (v) => setState(() => _biometricEnabled = v),
                      ),
                      const Divider(height: 1),
                      _ToggleTile(
                        icon: Icons.security_rounded,
                        iconColor: AppColors.tealP,
                        title: 'Two-Factor Authentication'.tr(context),
                        subtitle: 'Extra layer of security for your account'.tr(context),
                        value: _twoFactorEnabled,
                        onChanged: (v) => setState(() => _twoFactorEnabled = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Change Password section ───────────────────────────────
                  _SectionCard(
                    title: 'Password'.tr(context),
                    children: [
                      if (!_isChangingPassword)
                        _ActionTile(
                          icon: Icons.lock_outline_rounded,
                          iconColor: AppColors.tealP,
                          title: 'Change Password'.tr(context),
                          subtitle: 'Update your account password'.tr(context),
                          onTap: () => setState(() => _isChangingPassword = true),
                        )
                      else ...[
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
                          child: Column(
                            children: [
                              _PassField(
                                controller: _currentPassCtrl,
                                label: 'Current Password'.tr(context),
                                obscure: _obscureCurrent,
                                onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                              ),
                              const SizedBox(height: 12),
                              _PassField(
                                controller: _newPassCtrl,
                                label: 'New Password'.tr(context),
                                obscure: _obscureNew,
                                onToggle: () => setState(() => _obscureNew = !_obscureNew),
                              ),
                              const SizedBox(height: 12),
                              _PassField(
                                controller: _confirmPassCtrl,
                                label: 'Confirm New Password'.tr(context),
                                obscure: _obscureConfirm,
                                onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.tealP,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                      ),
                                      onPressed: _changePassword,
                                      child: Text('Save Password'.tr(context)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.tealP,
                                        side: const BorderSide(color: AppColors.tealP),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                      ),
                                      onPressed: () => setState(() => _isChangingPassword = false),
                                      child: Text('Cancel'.tr(context)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Privacy section ──────────────────────────────────────
                  _SectionCard(
                    title: 'Privacy'.tr(context),
                    children: [
                      _ActionTile(
                        icon: Icons.visibility_off_rounded,
                        iconColor: AppColors.tealP,
                        title: 'Data Privacy'.tr(context),
                        subtitle: 'Manage how your data is used'.tr(context),
                        onTap: () => AppToast.show(
                          context, 'Coming soon!'.tr(context),
                          type: AppToastType.info,
                          role: UserRole.patient,
                        ),
                      ),
                      const Divider(height: 1),
                      _ActionTile(
                        icon: Icons.delete_outline_rounded,
                        iconColor: Colors.red[700]!,
                        title: 'Delete Account'.tr(context),
                        subtitle: 'Permanently remove your account and data'.tr(context),
                        onTap: () => AppToast.show(
                          context, 'Coming soon!'.tr(context),
                          type: AppToastType.warning,
                          role: UserRole.patient,
                        ),
                      ),
                    ],
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

// ─── Helper widgets ──────────────────────────────────────────────────────────

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
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.tealP,
              letterSpacing: 1.2,
              fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Inter',
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

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

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
                Text(title, style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: AppColors.neutral900,
                  fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Inter',
                )),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(
                  fontSize: 12,
                  color: AppColors.neutral500,
                  fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Inter',
                )),
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

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
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
                  Text(title, style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                    fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Inter',
                  )),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(
                    fontSize: 12,
                    color: AppColors.neutral500,
                    fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Inter',
                  )),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.neutral500, size: 20),
          ],
        ),
      ),
    );
  }
}

class _PassField extends StatelessWidget {
  const _PassField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
  });
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(
        fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Inter',
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.neutral500,
          fontSize: 14,
          fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Inter',
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.tealP, width: 1.5),
        ),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: AppColors.neutral500),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
