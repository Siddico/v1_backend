import 'package:flutter/material.dart';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/controllers/auth_providers.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../shared/presentation/widgets/app_toast.dart';
import '../../../../core/localization/app_localizations.dart';

import '../../../../core/constants/app_images.dart';
import '../../../../core/theme/app_text_styles.dart';

class MessageComposerBar extends ConsumerStatefulWidget {
  const MessageComposerBar({
    super.key,
    this.hintText = 'Aa',
    this.onSend,
    this.onSendMessage,
    this.accentColor = AppColors.tealP,
    this.backgroundColor,
    this.inputBackgroundColor,
    this.iconTintColor,
    this.hintColor = AppColors.neutral550,
  });

  final String hintText;
  final ValueChanged<String>? onSend;

  /// Callback to send messages with type and optional attachment URL.
  final void Function({
    required String messageType,
    String? content,
    String? attachmentUrl,
  })? onSendMessage;
  final Color accentColor;
  final Color? backgroundColor;
  final Color? inputBackgroundColor;
  final Color? iconTintColor;
  final Color hintColor;

  @override
  ConsumerState<MessageComposerBar> createState() => _MessageComposerBarState();
}

class _MessageComposerBarState extends ConsumerState<MessageComposerBar> {
  final TextEditingController _controller = TextEditingController();
  bool _showEmojiPicker = false;
  File? _selectedImage;
  PlatformFile? _selectedFile; // for PDF / other files
  bool _isUploading = false;

  // Cloudinary cloud name now loaded from environment variables
  String get _cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static const _uploadPreset = 'grad_storage';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendText() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    widget.onSend?.call(value);
    _controller.clear();
    setState(() {});
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
          _selectedFile = null; // clear any pending file
        });
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          source == ImageSource.camera
              ? 'Camera access denied or unavailable'.tr(context)
              : 'Gallery access denied or unavailable'.tr(context),
          type: AppToastType.error,
        );
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xlsx', 'xls', 'ppt', 'pptx'],
        withData: false,
        withReadStream: true,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
          _selectedImage = null; // clear any pending image
        });
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          'Files access denied or unavailable'.tr(context),
          type: AppToastType.error,
        );
      }
    }
  }

  /// Upload a file to Cloudinary. Returns the secure URL or null on failure.
  Future<String?> _uploadToCloudinary({
    required File file,
    required String publicId,
    required bool isImage,
  }) async {
    final resourceType = isImage ? 'image' : 'raw';
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/$resourceType/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['public_id'] = publicId;
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body)['secure_url'] as String?;
    }
    return null;
  }

  Future<void> _sendImage() async {
    if (_selectedImage == null || _isUploading) return;
    final uid = ref.read(authStateProvider).valueOrNull?.id ?? '';
    setState(() => _isUploading = true);

    try {
      String? downloadUrl;
      if (uid.isNotEmpty) {
        downloadUrl = await _uploadToCloudinary(
          file: _selectedImage!,
          publicId: 'users/$uid/messages/img_${DateTime.now().millisecondsSinceEpoch}',
          isImage: true,
        );
      }
      if (downloadUrl == null) {
        throw Exception('Cloudinary upload returned null');
      }
      widget.onSendMessage?.call(
        messageType: 'image',
        attachmentUrl: downloadUrl,
      );
    } catch (e) {
      if (mounted) {
        AppToast.show(context, 'Failed to upload image'.tr(context), type: AppToastType.error);
      }
    } finally {
      if (mounted) setState(() { _selectedImage = null; _isUploading = false; });
    }
  }

  Future<void> _sendFile() async {
    if (_selectedFile == null || _isUploading) return;
    final path = _selectedFile!.path;
    if (path == null) return;

    final uid = ref.read(authStateProvider).valueOrNull?.id ?? '';
    setState(() => _isUploading = true);

    try {
      final file = File(path);
      final fileName = _selectedFile!.name;
      final sanitizedName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9.]'), '_');
      final isPdf = fileName.toLowerCase().endsWith('.pdf');
      String? downloadUrl;

      if (uid.isNotEmpty) {
        downloadUrl = await _uploadToCloudinary(
          file: file,
          publicId: 'users/$uid/messages/file_${DateTime.now().millisecondsSinceEpoch}_$sanitizedName',
          isImage: isPdf,
        );
      }
      if (downloadUrl == null) {
        throw Exception('Cloudinary upload returned null');
      }
      widget.onSendMessage?.call(
        messageType: 'file',
        content: fileName,
        attachmentUrl: downloadUrl,
      );
    } catch (e) {
      if (mounted) {
        AppToast.show(context, 'Failed to upload file'.tr(context), type: AppToastType.error);
      }
    } finally {
      if (mounted) setState(() { _selectedFile = null; _isUploading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.trim().isNotEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Image preview ──────────────────────────────────────────────────
        if (_selectedImage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedImage!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image_rounded, color: Colors.grey),
                      );
                    },
                  ),
                ),
                const Spacer(),
                if (_isUploading)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else ...[
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.green),
                    onPressed: _sendImage,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => setState(() => _selectedImage = null),
                  ),
                ],
              ],
            ),
          ),

        // ── File preview ───────────────────────────────────────────────────
        if (_selectedFile != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.black.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedFile!.name.toLowerCase().endsWith('.pdf')
                        ? Icons.picture_as_pdf_rounded
                        : Icons.insert_drive_file_rounded,
                    color: _selectedFile!.name.toLowerCase().endsWith('.pdf')
                        ? Colors.red[700]
                        : Colors.blue[700],
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedFile!.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                  if (_isUploading)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else ...[
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.green),
                      onPressed: _sendFile,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => setState(() => _selectedFile = null),
                    ),
                  ],
                ],
              ),
            ),
          ),

        // ── Composer bar ───────────────────────────────────────────────────
        Container(
          color: widget.backgroundColor ?? AppColors.white.withValues(alpha: 0.96),
          padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 14, 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _showEmojiPicker = !_showEmojiPicker),
                child: _circleIcon(AppImages.moreIcon),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _pickImage(ImageSource.camera),
                child: _circleIcon(AppImages.cameraIcon),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _pickImage(ImageSource.gallery),
                child: _circleIcon(AppImages.pictureIcon),
              ),
              const SizedBox(width: 8),
              // File attachment button
              GestureDetector(
                onTap: _pickFile,
                child: _circleIconMaterial(Icons.attach_file_rounded),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: widget.inputBackgroundColor ??
                        AppColors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _controller,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _sendText(),
                    textInputAction: TextInputAction.send,
                    style: AppTextStyles.messageComposerInputNeutral900_16Regular,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                      hintText: widget.hintText,
                      hintStyle: AppTextStyles.messageComposerHint(widget.hintColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: hasText
                    ? _sendText
                    : () => AppToast.show(
                          context,
                          'Emojis coming soon!'.tr(context),
                          type: AppToastType.info,
                        ),
                child: hasText
                    ? Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.accentColor.withValues(alpha: 0.18),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.send,
                            size: 18,
                            color: widget.iconTintColor ?? widget.accentColor,
                          ),
                        ),
                      )
                    : _circleIcon(AppImages.emojiIcon),
              ),
            ],
          ),
        ),
        _emojiPicker(),
      ],
    );
  }

  Widget _circleIcon(String icon, {bool active = false}) {
    final iconTint = widget.iconTintColor ?? widget.accentColor;
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? widget.accentColor.withValues(alpha: 0.18)
            : widget.accentColor.withValues(alpha: 0.10),
      ),
      child: Center(
        child: SvgPicture.asset(
          icon,
          width: 18,
          height: 18,
          colorFilter: ColorFilter.mode(iconTint, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget _circleIconMaterial(IconData iconData, {bool active = false}) {
    final iconTint = widget.iconTintColor ?? widget.accentColor;
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? widget.accentColor.withValues(alpha: 0.18)
            : widget.accentColor.withValues(alpha: 0.10),
      ),
      child: Center(
        child: Icon(iconData, size: 18, color: iconTint),
      ),
    );
  }

  Widget _emojiPicker() {
    return Offstage(
      offstage: !_showEmojiPicker,
      child: SizedBox(
        height: 250,
        child: EmojiPicker(
          onEmojiSelected: (category, emoji) {
            _controller.text += emoji.emoji;
            setState(() {});
          },
          config: const Config(
            emojiViewConfig: EmojiViewConfig(columns: 7, emojiSizeMax: 32),
          ),
        ),
      ),
    );
  }
}
