import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grad_imp_1/shared/presentation/widgets/circular_loading_indicator.dart';
import 'package:flutter_svg/svg.dart';

import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/constants/app_images.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';
import 'package:grad_imp_1/core/enums/user_role.dart';
import 'package:grad_imp_1/shared/domain/entities/user_entity.dart';
import 'package:grad_imp_1/shared/presentation/providers/chat_providers.dart';
import 'package:grad_imp_1/shared/presentation/widgets/app_toast.dart';
import 'package:grad_imp_1/features/doctor/presentation/pages/doctor_chat_page.dart';
import 'package:grad_imp_1/features/auth/presentation/controllers/auth_providers.dart';

class ChatQuickButton extends ConsumerWidget {
  final UserEntity patient;

  const ChatQuickButton({super.key, required this.patient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showQuickActionsSheet(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
        child: Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const ShapeDecoration(
                color: AppColors.redCoral,
                shape: OvalBorder(
                  side: BorderSide(width: 1, color: AppColors.neutral250),
                ),
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppImages.messageLogoSvg,
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Chat',
              textAlign: TextAlign.center,
              style: AppTextStyles.patientDetailChatLabelGray800Alt12Regular,
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickActionsSheet(BuildContext context, WidgetRef ref) {
    final pageContext = context;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Contact ${patient.name}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.redDeep,
                ),
              ),
              const SizedBox(height: 20),
              
              // ── Option 1: Send Message ──
              _buildOptionCard(
                context: sheetCtx,
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Send Message',
                description: 'Open a chat and send text messages.',
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  
                  // Show loading spinner on page context
                  showDialog(
                    context: pageContext,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularLoadingIndicator(size: 24, color: AppColors.tealP),
                    ),
                  );

                  try {
                    final currentUserId = ref.read(authControllerProvider).valueOrNull?.id ??
                        ref.read(authStateProvider).valueOrNull?.id ??
                        '';
                    final chatDS = ref.read(chatRemoteDataSourceProvider);
                    final conversationId = await chatDS.getOrCreateConversation(
                      currentUserId,
                      patient.id,
                    );

                    if (pageContext.mounted) {
                      Navigator.pop(pageContext); // dismiss loading spinner
                      Navigator.push(
                        pageContext,
                        MaterialPageRoute(
                          builder: (context) => DoctorChatPage(
                            contactName: patient.name,
                            contactImage: patient.photoUrl ?? AppImages.patientImage,
                            conversationId: conversationId,
                            otherId: patient.id,
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (pageContext.mounted) {
                      Navigator.pop(pageContext); // dismiss spinner
                      AppToast.show(
                        pageContext,
                        'Failed to open conversation: $e',
                        type: AppToastType.error,
                        role: UserRole.doctor,
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 12),

              // ── Option 2: Audio Call ──
              _buildOptionCard(
                context: sheetCtx,
                icon: Icons.phone_in_talk_outlined,
                title: 'Audio Call',
                description: 'Start a voice call directly with notification.',
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  AppToast.show(
                    pageContext,
                    'comming soon!! Feture Work',
                    type: AppToastType.info,
                    role: UserRole.doctor,
                  );
                },
              ),
              const SizedBox(height: 12),

              // ── Option 3: Video Call ──
              _buildOptionCard(
                context: sheetCtx,
                icon: Icons.videocam_outlined,
                title: 'Video Call',
                description: 'Start a video call with notifications.',
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  AppToast.show(
                    pageContext,
                    'comming soon!! Feture Work',
                    type: AppToastType.info,
                    role: UserRole.doctor,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.redSurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.redDeep, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
