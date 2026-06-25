import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'full_screen_image_viewer.dart';
import '../../pages/pdf_viewer_page.dart';

enum MessageBubbleStyle { rounded, incomingTail, outgoingTail }

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.text,
    required this.isMe,
    this.style = MessageBubbleStyle.rounded,
    this.maxWidth = 0.74,
    this.textSize = 16,
    this.outgoingColor,
    this.incomingColor,
    this.outgoingTextColor,
    this.incomingTextColor,
    this.messageType,
    this.attachmentUrl,
    this.createdAt,
  });

  final String text;
  final bool isMe;
  final MessageBubbleStyle style;
  final double maxWidth;
  final double textSize;
  final Color? outgoingColor;
  final Color? incomingColor;
  final Color? outgoingTextColor;
  final Color? incomingTextColor;
  final String? messageType; // 'text', 'image', 'file'
  final String? attachmentUrl;
  final dynamic createdAt;

  @override
  Widget build(BuildContext context) {
    final color = isMe
        ? (outgoingColor ?? AppColors.tealPrimarySoft)
        : (incomingColor ?? AppColors.shadowBlack05);
    final textColor = isMe
        ? (outgoingTextColor ?? AppColors.white)
        : (incomingTextColor ?? AppColors.tealAccentMuted);

    Widget contentWidget;

    if (messageType == 'image' && attachmentUrl != null) {
      // ─── Image card 100×100 ────────────────────────────────────────────────
      final isLocal =
          !attachmentUrl!.startsWith('http://') &&
          !attachmentUrl!.startsWith('https://');
      contentWidget = GestureDetector(
        onTap: () => FullScreenImageViewer.show(context, attachmentUrl!),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: isLocal
              ? Image.file(
                  File(attachmentUrl!),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox(
                    width: 100,
                    height: 100,
                    child: Icon(Icons.broken_image_rounded, size: 36),
                  ),
                )
              : Image.network(
                  attachmentUrl!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return SizedBox(
                      width: 100,
                      height: 100,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                                    progress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                          color: isMe ? Colors.white70 : AppColors.tealP,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, _, _) => const SizedBox(
                    width: 100,
                    height: 100,
                    child: Icon(Icons.broken_image_rounded, size: 36),
                  ),
                ),
        ),
      );
    } else if (messageType == 'file' && attachmentUrl != null) {
      // ─── Professional File card (PDF or other) ────────────────────────────
      final fileName = _extractFileName(attachmentUrl!);
      final isPdf = fileName.toLowerCase().endsWith('.pdf');

      // Colour scheme based on file type
      final cardAccent = isPdf
          ? const Color(0xFFD32F2F)
          : const Color(0xFF1565C0);
      final cardAccent2 = isPdf
          ? const Color(0xFFFF7043)
          : const Color(0xFF0288D1);
      final cardBg = isPdf ? const Color(0xFFFFF5F5) : const Color(0xFFF0F6FF);
      final cardBorder = isPdf
          ? const Color(0xFFFFCDD2)
          : const Color(0xFFBBDEFB);

      contentWidget = GestureDetector(
        onTap: () {
          if (isPdf) {
            PdfViewerPage.show(context, attachmentUrl!, title: fileName);
          } else {
            _openUrl(context, attachmentUrl!);
          }
        },
        child: Container(
          width: 240,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cardBorder, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: cardAccent.withValues(alpha: 0.10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Gradient header strip ────────────────────────────────────
              Container(
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cardAccent, cardAccent2],
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                  ),
                  borderRadius: const BorderRadiusDirectional.only(
                    topStart: Radius.circular(13),
                    topEnd: Radius.circular(13),
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      right: -16,
                      top: -16,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 14,
                      bottom: -10,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    // File icon centered
                    Center(
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isPdf
                              ? Icons.picture_as_pdf_rounded
                              : Icons.insert_drive_file_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── File info ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 4),
                child: Text(
                  fileName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.neutral900,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
                child: Text(
                  isPdf ? 'PDF Document' : 'File Attachment',
                  style: TextStyle(
                    color: cardAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // ── Divider ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Divider(height: 1, thickness: 1, color: cardBorder),
              ),

              // ── Open button ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 12),
                child: Row(
                  children: [
                    Icon(
                      isPdf
                          ? Icons.open_in_full_rounded
                          : Icons.download_rounded,
                      size: 14,
                      color: cardAccent,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isPdf ? 'Open PDF' : 'Open File',
                      style: TextStyle(
                        color: cardAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [cardAccent, cardAccent2],
                          begin: AlignmentDirectional.topStart,
                          end: AlignmentDirectional.bottomEnd,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else if (messageType == 'audio' && attachmentUrl != null) {
      contentWidget = Container(
        width: 200,
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            const Icon(Icons.play_arrow),
            const SizedBox(width: 8),
            Text('Audio'.tr(context)),
          ],
        ),
      );
    } else {
      contentWidget = Text(
        text,
        style: AppTextStyles.messageBubbleText(textColor, textSize),
      );
    }

    final timeStr = _formatMessageTime(createdAt);

    final bubbleWidget = messageType == 'file' && attachmentUrl != null
        ? contentWidget
        : FractionallySizedBox(
            widthFactor: maxWidth,
            alignment: isMe
                ? AlignmentDirectional.centerEnd
                : AlignmentDirectional.centerStart,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: _radiusFor(style, isMe),
              ),
              child: contentWidget,
            ),
          );

    return Align(
      alignment: isMe
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          bubbleWidget,
          if (timeStr != null) ...[
            const SizedBox(height: 3),
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: isMe ? 0 : 8,
                end: isMe ? 8 : 0,
              ),
              child: Text(
                timeStr,
                style: const TextStyle(
                  color: AppColors.neutral500,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String? _formatMessageTime(dynamic createdAt) {
    if (createdAt == null) return null;
    DateTime? dateTime;

    if (createdAt is Timestamp) {
      dateTime = createdAt.toDate();
    } else if (createdAt is String) {
      dateTime = DateTime.tryParse(createdAt);
    } else if (createdAt is DateTime) {
      dateTime = createdAt;
    }

    if (dateTime == null) return null;

    final localDateTime = dateTime.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      localDateTime.year,
      localDateTime.month,
      localDateTime.day,
    );
    final difference = today.difference(messageDate).inDays;

    String dayStr;
    if (difference == 0) {
      dayStr = 'Today';
    } else if (difference == 1) {
      dayStr = 'Yesterday';
    } else if (difference > 1 && difference < 7) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      dayStr = weekdays[localDateTime.weekday - 1];
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      dayStr = '${months[localDateTime.month - 1]} ${localDateTime.day}';
    }

    final hour = localDateTime.hour;
    final minute = localDateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour == 0
        ? 12
        : hour > 12
        ? hour - 12
        : hour;

    return '$dayStr, $formattedHour:$minute $period';
  }

  String _extractFileName(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        final raw = segments.last;
        // Cloudinary URLs may have transformations - take last segment after /
        return Uri.decodeComponent(raw.split('/').last);
      }
    } catch (_) {}
    return 'file';
  }

  void _openUrl(BuildContext context, String url) {
    // Show a toast - for non-PDF files we don't have an in-app viewer
    Fluttertoast.showToast(msg: 'Cannot preview this file type in-app.');
  }

  BorderRadiusGeometry _radiusFor(MessageBubbleStyle style, bool isMe) {
    if (style == MessageBubbleStyle.rounded) {
      return BorderRadius.circular(18);
    }
    if (style == MessageBubbleStyle.incomingTail) {
      return const BorderRadiusDirectional.only(
        topStart: Radius.circular(18),
        topEnd: Radius.circular(18),
        bottomStart: Radius.circular(6),
        bottomEnd: Radius.circular(18),
      );
    }
    return const BorderRadiusDirectional.only(
      topStart: Radius.circular(18),
      topEnd: Radius.circular(18),
      bottomStart: Radius.circular(18),
      bottomEnd: Radius.circular(6),
    );
  }
}

