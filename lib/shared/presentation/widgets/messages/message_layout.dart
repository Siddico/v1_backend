import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grad_imp_1/shared/presentation/widgets/messages/message_layout_state.dart';

class MessagesLayout extends ConsumerStatefulWidget {
  final String contactName;
  final String contactImage;
  final String conversationId;
  final String otherId;

  const MessagesLayout({
    super.key,
    required this.contactName,
    required this.contactImage,
    required this.conversationId,
    required this.otherId,
  });

  @override
  ConsumerState<MessagesLayout> createState() => MessagesLayoutState();
}
