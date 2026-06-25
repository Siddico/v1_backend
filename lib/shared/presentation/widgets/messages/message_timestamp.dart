import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

class MessageTimestamp extends StatelessWidget {
  const MessageTimestamp({
    super.key,
    required this.text,
    this.verticalPadding = 8,
  });

  final String text;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyles.messageTimestampShadowBlack30_12Medium,
      ),
    );
  }
}
