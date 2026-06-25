import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/enums/user_role.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/localization/app_localizations.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';

enum AppToastType { success, error, warning, info }

class AppToast {
  AppToast._();

  static void show(
    BuildContext context,
    String message, {
    AppToastType type = AppToastType.info,
    UserRole? role,
    bool translate = true,
  }) {
    final overlay = Overlay.of(context);
    final finalMessage = translate ? message.tr(context) : message;

    final colors = _ToastColors.from(type: type, role: role);
    late OverlayEntry entry;
    bool removed = false;

    void safeRemove() {
      if (!removed && entry.mounted) {
        removed = true;
        entry.remove();
      }
    }

    entry = OverlayEntry(
      builder: (context) => Positioned(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 24,
        child: _ToastBanner(
          message: finalMessage,
          colors: colors,
          onDismissed: safeRemove,
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), safeRemove);
  }
}

class _ToastBanner extends StatefulWidget {
  const _ToastBanner({
    required this.message,
    required this.colors,
    required this.onDismissed,
  });

  final String message;
  final _ToastColors colors;
  final VoidCallback onDismissed;

  @override
  State<_ToastBanner> createState() => _ToastBannerState();
}

class _ToastBannerState extends State<_ToastBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  double _dragOffset = 0;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..forward();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (_dismissed) return;
    _dismissed = true;
    _controller.reverse().then((_) => widget.onDismissed());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (_dismissed) return;
        setState(() => _dragOffset += details.delta.dx);
      },
      onHorizontalDragEnd: (details) {
        if (_dismissed) return;
        final velocity = details.velocity.pixelsPerSecond.dx.abs();
        // Dismiss if dragged > 60px or flung fast enough
        if (_dragOffset.abs() > 60 || velocity > 400) {
          _dismiss();
        } else {
          // Snap back
          setState(() => _dragOffset = 0);
        }
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: Opacity(
              opacity:
                  (1.0 - (_dragOffset.abs() / 200)).clamp(0.0, 1.0) *
                  _animation.value,
              child: child,
            ),
          );
        },
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.22),
            end: Offset.zero,
          ).animate(_animation),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: widget.colors.background,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: widget.colors.border),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowBlack25,
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: widget.colors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: widget.colors.foreground,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _dismiss,
                    child: Icon(
                      Icons.close,
                      color: widget.colors.foreground,
                      size: 18,
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
}

class _ToastColors {
  const _ToastColors({
    required this.background,
    required this.foreground,
    required this.border,
    required this.accent,
  });

  final Color background;
  final Color foreground;
  final Color border;
  final Color accent;

  factory _ToastColors.from({required AppToastType type, UserRole? role}) {
    switch (type) {
      case AppToastType.success:
        if (role == UserRole.doctor) {
          return _ToastColors(
            background: const Color(0xFFFDF1F2),
            foreground: AppColors.redDeep,
            border: const Color(0xFFFCD3D9),
            accent: AppColors.redDeep,
          );
        } else if (role == UserRole.researcher) {
          return _ToastColors(
            background: const Color(0xFFF0F5FA),
            foreground: AppColors.bluePrimary,
            border: const Color(0xFFD2E1ED),
            accent: AppColors.blueSecondary,
          );
        } else if (role == UserRole.patient) {
          return _ToastColors(
            background: const Color(0xFFEBF8F9),
            foreground: AppColors.tealPrimaryDark,
            border: const Color(0xFFBFE6EA),
            accent: AppColors.tealP,
          );
        }
        return _ToastColors(
          background: const Color(0xFFE8F8EF),
          foreground: AppColors.greenDark,
          border: const Color(0xFFBEE8D0),
          accent: AppColors.successGreen,
        );
      case AppToastType.warning:
        return _ToastColors(
          background: const Color(0xFFFFF7E0),
          foreground: AppColors.yellowMustard,
          border: const Color(0xFFFFE09A),
          accent: AppColors.warningYellow,
        );
      case AppToastType.error:
        return _ToastColors(
          background: const Color(0xFFFFECEE),
          foreground: AppColors.redAlert,
          border: const Color(0xFFF2C1C6),
          accent: AppColors.redAlert,
        );
      case AppToastType.info:
        if (role == UserRole.doctor) {
          return _ToastColors(
            background: const Color(0xFFFFEEF1),
            foreground: AppColors.redDeep,
            border: const Color(0xFFF4C7CD),
            accent: AppColors.redDeep,
          );
        } else if (role == UserRole.researcher) {
          return _ToastColors(
            background: const Color(0xFFF0F5FA),
            foreground: AppColors.bluePrimary,
            border: const Color(0xFFD2E1ED),
            accent: AppColors.blueSecondary,
          );
        }
        return _ToastColors(
          background: const Color(0xFFE9F7F8),
          foreground: AppColors.tealPrimaryDark,
          border: const Color(0xFFBFE6EA),
          accent: AppColors.tealP,
        );
    }
  }
}
