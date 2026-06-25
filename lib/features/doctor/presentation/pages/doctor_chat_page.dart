import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/presentation/widgets/app_toast.dart';
import '../../../../shared/presentation/widgets/messages/message_bubble.dart';
import '../../../../shared/presentation/widgets/circular_loading_indicator.dart';
import '../../../../shared/presentation/widgets/messages/message_composer_bar.dart';
import '../../../../shared/presentation/widgets/messages/messages_header.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../../../shared/presentation/providers/chat_providers.dart';
import '../../../../core/localization/app_localizations.dart';

class DoctorChatPage extends ConsumerStatefulWidget {
  const DoctorChatPage({
    super.key,
    required this.contactName,
    required this.contactImage,
    required this.conversationId,
    required this.otherId,
  });

  final String contactName;
  final String contactImage;
  final String conversationId;
  final String otherId;

  @override
  ConsumerState<DoctorChatPage> createState() => _DoctorChatPageState();
}

class _DoctorChatPageState extends ConsumerState<DoctorChatPage> {
  static const Color _doctorPrimary = AppColors.redDeep;
  // static const Color _doctorOutgoing = AppColors.redSoft;
  // static const Color _doctorIncomingText = AppColors.redCrimson;

  bool _isDarkMode = false;

  void _sendMessage(String value) {
    if (value.trim().isEmpty) return;
    final currentUserId = ref.read(authStateProvider).valueOrNull?.id ?? '';
    ref
        .read(chatRemoteDataSourceProvider)
        .sendMessage(
          conversationId: widget.conversationId,
          senderId: currentUserId,
          recipientId: widget.otherId,
          content: value.trim(),
        );
  }

  void _sendMessageWithAttachment({
    required String messageType,
    String? content,
    String? attachmentUrl,
  }) {
    final currentUserId = ref.read(authStateProvider).valueOrNull?.id ?? '';
    ref
        .read(chatRemoteDataSourceProvider)
        .sendMessage(
          conversationId: widget.conversationId,
          senderId: currentUserId,
          recipientId: widget.otherId,
          content: content ?? '',
          messageType: messageType,
          attachmentUrl: attachmentUrl,
        );
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(
      chatMessagesProvider(widget.conversationId),
    );
    final currentUserId = ref.watch(authStateProvider).valueOrNull?.id ?? '';

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          MessagesHeader(
            contactName: widget.contactName,
            subtitle: 'Messenger'.tr(context),
            contactImage: widget.contactImage,
            primaryColor: _doctorPrimary,
            iconColor: _doctorPrimary,
            darkModeToggleLightColor: AppColors.pinkLight,
            darkModeToggleDarkColor: _doctorPrimary,
            isDarkMode: _isDarkMode,
            onDarkModeToggle: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
            onLanguageSelect: () {},
            onAudioCallTap: () async {
              AppToast.show(
                context,
                'Coming soon!'.tr(context),
                type: AppToastType.info,
                role: UserRole.doctor,
              );
            },
            onVideoCallTap: () async {
              AppToast.show(
                context,
                'Coming soon!'.tr(context),
                type: AppToastType.info,
                role: UserRole.doctor,
              );
            },
          ),
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet. Send a message to start!'.tr(context),
                      style: TextStyle(
                        fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Inter',
                        color: Colors.grey.shade500,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 14, 14),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final content = msg['content']?.toString() ?? '';
                    final senderId = msg['sender_id']?.toString() ?? '';
                    final isMe = senderId == currentUserId;
                    final msgType = msg['message_type']?.toString() ?? 'text';
                    final attUrl = msg['attachment_url']?.toString();

                    return Padding(
                      padding: const EdgeInsetsDirectional.only(bottom: 10),
                      child: MessageBubble(
                        text: content,
                        isMe: isMe,
                        style: isMe
                            ? MessageBubbleStyle.outgoingTail
                            : MessageBubbleStyle.incomingTail,
                        maxWidth: 0.72,
                        outgoingColor: AppColors.redDeep.withValues(alpha: 0.5),
                        textSize: 16,
                        messageType: msgType,
                        attachmentUrl: attUrl,
                        createdAt: msg['created_at'],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularLoadingIndicator(
                  size: 32,
                  color: AppColors.redDeep,
                ),
              ),
              error: (err, _) => Center(child: Text('${'Error: '.tr(context)}$err')),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 10),
              child: MessageComposerBar(
                hintText: 'Aa',
                onSend: _sendMessage,
                onSendMessage: _sendMessageWithAttachment,
                accentColor: _doctorPrimary,
                iconTintColor: _doctorPrimary,
                hintColor: AppColors.neutral550,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

