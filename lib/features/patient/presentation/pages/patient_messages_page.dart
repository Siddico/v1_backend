import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/presentation/widgets/messages/message_layout.dart';

class PatientChatArgs {
  final String contactName;
  final String contactImage;
  final String conversationId;
  final String otherId;

  const PatientChatArgs({
    required this.contactName,
    required this.contactImage,
    required this.conversationId,
    required this.otherId,
  });
}

class PatientMessagesPage extends StatelessWidget {
  final String contactName;
  final String contactImage;
  final String conversationId;
  final String otherId;

  const PatientMessagesPage({
    super.key,
    required this.contactName,
    required this.contactImage,
    required this.conversationId,
    required this.otherId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: MessagesLayout(
        contactName: contactName,
        contactImage: contactImage,
        conversationId: conversationId,
        otherId: otherId,
      ),
    );
  }
}

