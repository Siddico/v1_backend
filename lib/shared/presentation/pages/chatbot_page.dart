import 'dart:io';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../data/datasources/chatbot_remote_datasource.dart';
// Removed firebase_auth import
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/enums/user_role.dart';
import '../../../features/auth/presentation/controllers/auth_providers.dart';
import '../widgets/circular_loading_indicator.dart';

class ChatbotPage extends ConsumerStatefulWidget {
  const ChatbotPage({super.key});

  @override
  ConsumerState<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends ConsumerState<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final ImagePicker _imagePicker = ImagePicker();

  bool _isUploading = false;
  bool _isAiTyping = false;
  String? _attachedFileUrl;
  String? _attachedFileName;
  // ignore: unused_field
  String? _attachedLocalFilePath;
  bool _isAttachedImage = false;
  // ignore: unused_field
  File? _lastLocalImageFile;

  String? _currentSessionId;
  Timer? _pollingTimer;
  List<Map<String, dynamic>> _currentMessages = [];
  bool _isLoadingMessages = false;
  List<Map<String, dynamic>> _chatSessions = [];

  @override
  void initState() {
    super.initState();
    _loadSessionsAndSetStream();
  }

  Future<void> _loadSessionsAndSetStream() async {
    try {
      final sessions = await ChatbotRemoteDataSource.getSessions();
      if (mounted) {
        setState(() {
          _chatSessions = sessions;
        });
        if (_chatSessions.isNotEmpty) {
          _setSession(_chatSessions.first['id'].toString());
        } else {
          _startNewSession();
        }
      }
    } catch (e) {
      debugPrint('Error loading sessions: $e');
    }
  }

  void _setSession(String sessionId) {
    _pollingTimer?.cancel();
    setState(() {
      _currentSessionId = sessionId;
      _currentMessages = [];
      _isLoadingMessages = true;
    });
    _fetchMessages();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) _fetchMessages(silent: true);
    });
  }

  void _startNewSession() {
    _pollingTimer?.cancel();
    setState(() {
      _currentSessionId = null;
      _currentMessages = [];
      _isLoadingMessages = false;
    });
  }

  Future<void> _fetchMessages({bool silent = false}) async {
    if (_currentSessionId == null) return;
    try {
      final newMessages = await ChatbotRemoteDataSource.getMessages(
        _currentSessionId!,
      );
      if (mounted) {
        bool shouldScroll = newMessages.length > _currentMessages.length;
        setState(() {
          _currentMessages = newMessages;
          _isLoadingMessages = false;
        });
        if (shouldScroll && !silent) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _scrollToBottom(),
          );
        }
      }
    } catch (e) {
      if (mounted && !silent) {
        setState(() {
          _isLoadingMessages = false;
        });
      }
      debugPrint('Error fetching messages: $e');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    DateTime time;
    if (timestamp is DateTime) {
      time = timestamp;
    } else if (timestamp is String) {
      time = DateTime.tryParse(timestamp) ?? DateTime.now();
    } else {
      time = DateTime.now();
    }
    final hour = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    final min = time.minute.toString().padLeft(2, '0');
    final ampm = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$min $ampm';
  }

  Future<String?> _uploadToCloudinary(
    File file,
    String uid,
    bool isImage,
  ) async {
    try {
      final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
      const String uploadPreset = 'grad_storage';
      final type = isImage ? 'image' : 'raw';
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/$type/upload',
      );
      final request = http.MultipartRequest('POST', uri);

      request.fields['upload_preset'] = uploadPreset;
      request.fields['public_id'] =
          'chatbot_${uid}_${DateTime.now().millisecondsSinceEpoch}';

      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['secure_url'] as String;
      }
    } catch (e) {
      debugPrint('Cloudinary upload error: $e');
    }
    return null;
  }

  Future<void> _pickImage(ImageSource source) async {
    final uid = ref.read(authStateProvider).valueOrNull?.id ?? '';
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (pickedFile == null) return;

      setState(() {
        _isUploading = true;
      });

      final file = File(pickedFile.path);
      final url = await _uploadToCloudinary(file, uid, true);
      if (url != null) {
        setState(() {
          _attachedFileUrl = url;
          _attachedFileName = pickedFile.name;
          _attachedLocalFilePath = pickedFile.path;
          _isAttachedImage = true;
          _lastLocalImageFile = file;
        });
        if (mounted) {
          Fluttertoast.showToast(
            msg: 'Image attached successfully'.tr(context),
            backgroundColor: AppColors.tealP,
            textColor: Colors.white,
            gravity: ToastGravity.BOTTOM,
          );
        }
      }
    } catch (e) {
      debugPrint('Image pick/upload error: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _pickFile() async {
    final uid = ref.read(authStateProvider).valueOrNull?.id ?? '';
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'csv', 'txt'],
      );
      if (result == null || result.files.isEmpty) return;

      final path = result.files.first.path;
      if (path == null) return;

      setState(() {
        _isUploading = true;
      });

      final file = File(path);
      final url = await _uploadToCloudinary(file, uid, false);
      if (url != null) {
        setState(() {
          _attachedFileUrl = url;
          _attachedFileName = result.files.first.name;
          _attachedLocalFilePath = path;
          _isAttachedImage = false;
          _lastLocalImageFile = null;
        });
        if (mounted) {
          Fluttertoast.showToast(
            msg: 'File attached successfully'.tr(context),
            backgroundColor: AppColors.tealP,
            textColor: Colors.white,
            gravity: ToastGravity.BOTTOM,
          );
        }
      }
    } catch (e) {
      debugPrint('File pick/upload error: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  bool _isArabicText(String text) {
    return text.codeUnits.any((char) => char >= 0x0600 && char <= 0x06FF);
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && _attachedFileUrl == null) return;

    final userMsgText = text.isNotEmpty
        ? text
        : '${'Sent an attachment:'.tr(context)} $_attachedFileName';

    _messageController.clear();
    setState(() {
      _isAiTyping = true;
      // Optimistically add user message
      _currentMessages.add({
        'sender': 'user',
        'text': userMsgText,
        'attachmentUrl': _attachedFileUrl,
        'attachmentName': _attachedFileName,
        'isImageAttachment': _isAttachedImage,
        'timestamp': DateTime.now().toIso8601String(),
      });
    });
    _scrollToBottom();

    setState(() {
      _attachedFileUrl = null;
      _attachedFileName = null;
      _attachedLocalFilePath = null;
      _isAttachedImage = false;
      _lastLocalImageFile = null;
    });

    try {
      if (_currentSessionId == null) {
        final newId = await ChatbotRemoteDataSource.createSession(
          text.isNotEmpty ? text : 'New Chat',
        );
        if (newId.isNotEmpty) {
          _currentSessionId = newId;
          _loadSessionsAndSetStream(); // refresh sidebar
        }
      }
      if (_currentSessionId != null) {
        await ChatbotRemoteDataSource.sendMessage(
          _currentSessionId!,
          userMsgText,
        );
        await _fetchMessages(silent: false);
      }
    } catch (e) {
      debugPrint('Failed to send chatbot message: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isAiTyping = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;
    final role = user?.role ?? UserRole.patient;

    final bool isDoctor = role == UserRole.doctor;
    final primaryColor = isDoctor ? AppColors.redButton : AppColors.tealP;
    final gradientColors = isDoctor
        ? const [AppColors.redButton, AppColors.redDeep]
        : const [AppColors.tealP, AppColors.tealPrimaryDark];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main Chat Area
          Column(
            children: [
              const SizedBox(
                height: kToolbarHeight + 40,
              ), // Space for floating app bar
              Expanded(
                child: _currentSessionId == null
                    ? _buildEmptyState(primaryColor)
                    : _isLoadingMessages
                    ? Center(
                        child: CircularLoadingIndicator(
                          size: 32,
                          color: primaryColor,
                        ),
                      )
                    : _currentMessages.isEmpty && !_isAiTyping
                    ? _buildEmptyState(primaryColor)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 20,
                        ),
                        itemCount:
                            _currentMessages.length + (_isAiTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _currentMessages.length && _isAiTyping) {
                            return _buildTypingIndicator(primaryColor);
                          }

                          final data = _currentMessages[index];
                          final isUser = data['sender'] == 'user';
                          final text = data['text'] ?? data['content'] ?? '';
                          final attachmentUrl = data['attachmentUrl'];
                          final attachmentName = data['attachmentName'];
                          final isImageAttachment =
                              data['isImageAttachment'] ?? false;
                          final timestamp =
                              data['timestamp'] ?? data['created_at'];

                          final isArabicText = _isArabicText(text);

                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.80,
                              ),
                              child: Column(
                                crossAxisAlignment: isUser
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: isUser
                                          ? LinearGradient(
                                              colors: gradientColors,
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                          : null,
                                      color: isUser ? null : Colors.grey[100],
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(24),
                                        topRight: const Radius.circular(24),
                                        bottomLeft: isUser
                                            ? const Radius.circular(24)
                                            : const Radius.circular(4),
                                        bottomRight: isUser
                                            ? const Radius.circular(4)
                                            : const Radius.circular(24),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              (isUser
                                                      ? primaryColor
                                                      : Colors.black)
                                                  // ignore: deprecated_member_use
                                                  .withOpacity(0.08),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                      border: isUser
                                          ? null
                                          : Border.all(
                                              color: Colors.grey[300]!,
                                              width: 1,
                                            ),
                                    ),
                                    child: Directionality(
                                      textDirection: isArabicText
                                          ? TextDirection.rtl
                                          : TextDirection.ltr,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (attachmentUrl != null) ...[
                                            if (isImageAttachment)
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                child: Image.network(
                                                  attachmentUrl,
                                                  height: 200,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            else
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isUser
                                                      ? Colors.white
                                                        // ignore: deprecated_member_use
                                                        .withOpacity(0.25)
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.insert_drive_file,
                                                      color: isUser
                                                          ? Colors.white
                                                          : primaryColor,
                                                      size: 24,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Flexible(
                                                      child: Text(
                                                        attachmentName ??
                                                            'Attachment'.tr(
                                                              context,
                                                            ),
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: isUser
                                                              ? Colors.white
                                                              : Colors.black87,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            const SizedBox(height: 10),
                                          ],
                                          if (text.isNotEmpty)
                                            isUser
                                                ? Text(
                                                    text,
                                                    textAlign: isArabicText
                                                        ? TextAlign.right
                                                        : TextAlign.left,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white,
                                                      fontFamily:
                                                          AppTextStyles.isArabic
                                                          ? 'Cairo'
                                                          : 'Poppins',
                                                      height: 1.5,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  )
                                                : MarkdownBody(
                                                    data: text,
                                                    selectable: true,
                                                    styleSheet:
                                                        MarkdownStyleSheet(
                                                          p: TextStyle(
                                                            fontSize: 15,
                                                            color:
                                                                Colors.black87,
                                                            fontFamily:
                                                                AppTextStyles
                                                                    .isArabic
                                                                ? 'Cairo'
                                                                : 'Poppins',
                                                            height: 1.5,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                          strong: TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.black,
                                                            fontFamily:
                                                                AppTextStyles
                                                                    .isArabic
                                                                ? 'Cairo'
                                                                : 'Poppins',
                                                            height: 1.5,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                  ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (timestamp != null)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        _formatTime(timestamp),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[500],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              if (_attachedFileUrl != null)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isAttachedImage
                              ? Icons.image
                              : Icons.insert_drive_file,
                          color: primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _attachedFileName ?? 'Attached file'.tr(context),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _attachedFileUrl = null;
                            _attachedFileName = null;
                            _attachedLocalFilePath = null;
                            _isAttachedImage = false;
                            _lastLocalImageFile = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              _buildInputComposer(primaryColor),
            ],
          ),

          // Floating Glassmorphism AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 10,
                    bottom: 15,
                    left: 20,
                    right: 20,
                  ),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.7),
                    border: Border(
                      bottom: BorderSide(
                        // ignore: deprecated_member_use
                        color: Colors.grey[200]!.withOpacity(0.5),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 18,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'AI Assistant'.tr(context),
                            style: TextStyle(
                              fontFamily: AppTextStyles.isArabic
                                  ? 'Cairo'
                                  : 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _showChatHistoryBottomSheet(primaryColor),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.history,
                            size: 22,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 60,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'How can I help you today?'.tr(context),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask anything, I am here to assist.'.tr(context),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(Color primaryColor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                color: primaryColor,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'AI is typing...'.tr(context),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputComposer(Color primaryColor) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom
            : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 4),
                      IconButton(
                        icon: Icon(
                          Icons.add_photo_alternate_rounded,
                          color: primaryColor,
                          size: 24,
                        ),
                        onPressed: _isUploading
                            ? null
                            : () => _pickImage(ImageSource.gallery),
                        padding: const EdgeInsets.all(10),
                        constraints: const BoxConstraints(),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.attach_file_rounded,
                          color: primaryColor,
                          size: 24,
                        ),
                        onPressed: _isUploading ? null : _pickFile,
                        padding: const EdgeInsets.all(10),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  Expanded(
                    child: _isUploading
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 14.0),
                            child: SizedBox(
                              height: 20,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: primaryColor,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : TextField(
                            controller: _messageController,
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: AppTextStyles.isArabic
                                  ? 'Cairo'
                                  : 'Poppins',
                            ),
                            minLines: 1,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: 'Type a message...'.tr(context),
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(
                                top: 14,
                                bottom: 14,
                                right: 16,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _isUploading ? null : _sendMessage,
            child: Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  // ignore: deprecated_member_use
                  colors: [primaryColor, primaryColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: primaryColor.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteChatSession(String sessionId, Color primaryColor) async {
    try {
      await ChatbotRemoteDataSource.deleteSession(sessionId);
      if (_currentSessionId == sessionId) {
        _startNewSession();
      }
      _loadSessionsAndSetStream();
    } catch (e) {
      debugPrint('Error deleting chat: $e');
    }
  }

  void _showChatHistoryBottomSheet(Color primaryColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (_, scrollController) {
                return Column(
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 20),
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Icon(Icons.history, color: primaryColor, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            'Chat History'.tr(context),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontFamily: AppTextStyles.isArabic
                                  ? 'Cairo'
                                  : 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context); // Close bottom sheet
                            _startNewSession();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.add, size: 20),
                          label: Text(
                            'New Chat'.tr(context),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: AppTextStyles.isArabic
                                  ? 'Cairo'
                                  : 'Poppins',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    Expanded(
                      child: _chatSessions.isEmpty
                          ? Center(
                              child: Text(
                                'No recent chats'.tr(context),
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            )
                          : ListView.separated(
                              controller: scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: _chatSessions.length,
                              // ignore: unnecessary_underscores
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final session = _chatSessions[index];
                                final data = session;
                                final title = data['title'] ?? 'Chat Session';
                                final isActive =
                                    _currentSessionId ==
                                    session['id'].toString();

                                return Material(
                                  color: isActive
                                      // ignore: deprecated_member_use
                                      ? primaryColor.withOpacity(0.1)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  elevation: isActive ? 0 : 2,
                                  // ignore: deprecated_member_use
                                  shadowColor: Colors.black.withOpacity(0.1),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _setSession(session['id'].toString());
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: isActive
                                                  ? primaryColor
                                                  : Colors.grey[100],
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              isActive
                                                  ? Icons.chat_bubble
                                                  : Icons.chat_bubble_outline,
                                              color: isActive
                                                  ? Colors.white
                                                  : Colors.grey[600],
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: isActive
                                                    ? FontWeight.bold
                                                    : FontWeight.w600,
                                                color: isActive
                                                    ? primaryColor
                                                    : Colors.black87,
                                                fontFamily:
                                                    AppTextStyles.isArabic
                                                    ? 'Cairo'
                                                    : 'Poppins',
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.redAccent,
                                              size: 24,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () async {
                                              await _deleteChatSession(
                                                session['id'].toString(),
                                                primaryColor,
                                              );
                                              // Ensure the bottom sheet updates
                                              setModalState(() {});
                                              if (mounted) setState(() {});
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
