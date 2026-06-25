import 'package:flutter/material.dart';
import 'package:grad_imp_1/shared/presentation/widgets/circular_loading_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grad_imp_1/shared/presentation/widgets/messages/message_bubble.dart';
import 'package:grad_imp_1/shared/presentation/widgets/messages/message_composer_bar.dart';
import 'package:grad_imp_1/shared/presentation/widgets/messages/message_layout.dart';
import 'package:grad_imp_1/shared/presentation/widgets/messages/messages_header.dart';
import 'package:grad_imp_1/shared/presentation/widgets/app_toast.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../features/auth/presentation/controllers/auth_providers.dart';
import '../../providers/chat_providers.dart';

class MessagesLayoutState extends ConsumerState<MessagesLayout> {
  void _handleSend(String message) {
    if (message.trim().isEmpty) return;
    final currentUserId = ref.read(authStateProvider).valueOrNull?.id ?? '';
    ref
        .read(chatRemoteDataSourceProvider)
        .sendMessage(
          conversationId: widget.conversationId,
          senderId: currentUserId,
          recipientId: widget.otherId,
          content: message.trim(),
        );
  }

  void _handleSendMessage({
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

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            MessagesHeader(
              contactName: widget.contactName,
              subtitle: 'Messenger'.tr(context),
              contactImage: widget.contactImage,
              onAudioCallTap: () async {
                AppToast.show(
                  context,
                  'Coming soon!! Future Work'.tr(context),
                  type: AppToastType.info,
                );
              },
              onVideoCallTap: () async {
                AppToast.show(
                  context,
                  'Coming soon!! Future Work'.tr(context),
                  type: AppToastType.info,
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
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      16,
                      12,
                      16,
                      16,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final content = msg['content']?.toString() ?? msg['message']?.toString() ?? '';
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
                          messageType: msgType,
                          attachmentUrl: attUrl,
                          createdAt: msg['created_at'],
                        ),
                      );
                    },
                  );
                },
                loading: () =>
                    const Center(child: CircularLoadingIndicator(size: 24)),
                error: (err, _) =>
                    Center(child: Text('${'Error: '.tr(context)}$err')),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: MessageComposerBar(
                hintText: 'Aa',
                onSend: _handleSend,
                onSendMessage: _handleSendMessage,
              ),
            ),
          ],
        );
      },
    );
  }
}
