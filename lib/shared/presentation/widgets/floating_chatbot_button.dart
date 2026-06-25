import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../features/auth/presentation/controllers/auth_providers.dart';
import 'package:go_router/go_router.dart';

class FloatingChatbotButton extends ConsumerWidget {
  final double left;
  final double bottom;

  const FloatingChatbotButton({
    super.key,
    this.left = 25,
    this.bottom = 5,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;
    final role = user?.role;

    // Default color is Teal (for patient/researcher), Red for doctor
    final Color buttonColor = (role == UserRole.doctor) ? AppColors.redButton : AppColors.tealP;

    return Positioned(
      left: left,
      bottom: bottom,
      child: GestureDetector(
        onTap: () {
          context.push('/chatbot');
        },
        child: Container(
          width: 62, // Matches Notification Button dimensions
          height: 62,
          decoration: BoxDecoration(
            color: buttonColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.forum_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}

