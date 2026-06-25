import re
import os

filepath = 'lib/shared/presentation/pages/chatbot_page.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    code = f.read()

# 1. Imports
code = code.replace("import 'package:cloud_firestore/cloud_firestore.dart';", 
"""import 'dart:async';
import 'package:dio/dio.dart';
import '../../../core/networking/api_constants.dart';
import '../../../core/networking/dio_factory.dart';""")

# 2. State variables
code = code.replace("Stream<QuerySnapshot>? _chatStream;\n  List<DocumentSnapshot> _chatSessions = [];", 
"""Timer? _pollingTimer;
  List<Map<String, dynamic>> _currentMessages = [];
  bool _isLoadingMessages = false;
  List<Map<String, dynamic>> _chatSessions = [];""")

# 3. Dispose
code = code.replace("super.dispose();", "_pollingTimer?.cancel();\n    super.dispose();")

# 4. _loadSessionsAndSetStream & _setSession & _startNewSession
old_methods = """  void _loadSessionsAndSetStream() async {
    final uid = ref.read(authStateProvider).valueOrNull?.id ?? '';
    if (uid.isEmpty) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('chat_sessions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          if (mounted) {
            setState(() {
              _chatSessions = snapshot.docs;
            });
          }
        });

    final lastSessionSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('chat_sessions')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (lastSessionSnapshot.docs.isNotEmpty) {
      _setSession(lastSessionSnapshot.docs.first.id);
    } else {
      _startNewSession();
    }
  }

  void _setSession(String sessionId) {
    final uid = ref.read(authStateProvider).valueOrNull?.id ?? '';
    setState(() {
      _currentSessionId = sessionId;
      _chatStream = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('chat_sessions')
          .doc(sessionId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots();
    });
  }

  void _startNewSession() {
    setState(() {
      _currentSessionId = null;
      _chatStream = null;
    });
  }"""

new_methods = """  Future<void> _loadSessionsAndSetStream() async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get(ApiConstants.chatbotSessions);
      if (response.statusCode == 200 && response.data['success'] == true) {
        if (mounted) {
          setState(() {
            _chatSessions = List<Map<String, dynamic>>.from(response.data['data']['sessions'] ?? []);
          });
          if (_chatSessions.isNotEmpty) {
             _setSession(_chatSessions.first['id'].toString());
          } else {
             _startNewSession();
          }
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
      final dio = await DioFactory.getDio();
      final response = await dio.get('${ApiConstants.chatbotSessions}/$_currentSessionId/messages');
      if (response.statusCode == 200 && response.data['success'] == true) {
        if (mounted) {
           final newMessages = List<Map<String, dynamic>>.from(response.data['data']['messages'] ?? []);
           bool shouldScroll = false;
           if (newMessages.length > _currentMessages.length) {
             shouldScroll = true;
           }
           setState(() {
             _currentMessages = newMessages;
             _isLoadingMessages = false;
           });
           if (shouldScroll && !silent) {
              WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
           }
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
  }"""

code = code.replace(old_methods, new_methods)

# 5. format time
code = code.replace("String _formatTime(Timestamp? timestamp) {", "String _formatTime(dynamic timestamp) {")
code = code.replace("if (timestamp == null) return '';\n    final time = timestamp.toDate();", 
"""if (timestamp == null) return '';
    DateTime time;
    if (timestamp is DateTime) {
      time = timestamp;
    } else if (timestamp is String) {
      time = DateTime.tryParse(timestamp) ?? DateTime.now();
    } else {
      time = DateTime.now();
    }""")

# 6. build sessions sidebar
code = code.replace("itemCount: _chatSessions.length,", "itemCount: _chatSessions.length,")
code = code.replace("final sessionDoc = _chatSessions[index];", "final sessionDoc = _chatSessions[index];")
code = code.replace("final isSelected = sessionDoc.id == _currentSessionId;", "final isSelected = sessionDoc['id'].toString() == _currentSessionId;")
code = code.replace("_setSession(sessionDoc.id);", "_setSession(sessionDoc['id'].toString());")
code = code.replace("final sessionData = sessionDoc.data() as Map<String, dynamic>;", "final sessionData = sessionDoc;")
code = code.replace("_deleteChatSession(sessionDoc.id, primaryColor)", "_deleteChatSession(sessionDoc['id'].toString(), primaryColor)")

# 7. deleteChatSession
code = code.replace("""  Future<void> _deleteChatSession(String sessionId, Color primaryColor) async {
    final uid = ref.read(authStateProvider).valueOrNull?.id;
    if (uid == null) return;

    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('chat_sessions')
          .doc(sessionId);

      await docRef.delete();

      if (_currentSessionId == sessionId) {
        _startNewSession();
      }
    } catch (e) {
      debugPrint('Failed to delete chat session: $e');
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Failed to delete chat session'.tr(context),
          backgroundColor: primaryColor,
          textColor: Colors.white,
        );
      }
    }
  }""", 
  """  Future<void> _deleteChatSession(String sessionId, Color primaryColor) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.delete('${ApiConstants.chatbotSessions}/$sessionId');
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (_currentSessionId == sessionId) {
          _startNewSession();
        }
        _loadSessionsAndSetStream();
      }
    } catch (e) {
      debugPrint('Failed to delete chat session: $e');
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Failed to delete chat session'.tr(context),
          backgroundColor: primaryColor,
          textColor: Colors.white,
        );
      }
    }
  }""")

# 8. sendMessage
import re
def replace_send_message(match):
    # This replaces the whole _sendMessage body. We will write it simpler.
    return """Future<void> _sendMessage() async {
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
    
    final fileUrl = _attachedFileUrl;
    final fileName = _attachedFileName;
    final isImage = _isAttachedImage;

    setState(() {
      _attachedFileUrl = null;
      _attachedFileName = null;
      _attachedLocalFilePath = null;
      _isAttachedImage = false;
      _lastLocalImageFile = null;
    });

    try {
      final dio = await DioFactory.getDio();
      if (_currentSessionId == null) {
         final newSessionResp = await dio.post(ApiConstants.chatbotSessions, data: {'title': text.isNotEmpty ? text : 'New Chat'});
         if (newSessionResp.statusCode == 200 && newSessionResp.data['success'] == true) {
             _currentSessionId = newSessionResp.data['data']['session']['id'].toString();
             _loadSessionsAndSetStream(); // refresh sidebar
         }
      }
      if (_currentSessionId != null) {
         await dio.post('${ApiConstants.chatbotSessions}/$_currentSessionId/messages', data: {
             'content': userMsgText,
             'attachmentUrl': fileUrl,
             'attachmentName': fileName,
             'isImageAttachment': isImage,
         });
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
  }"""

code = re.sub(r'Future<void> _sendMessage\(\) async \{.*?(?=\n  @override\n  Widget build)', replace_send_message, code, flags=re.DOTALL)

# 9. build (stream builder)
stream_builder_old = """Expanded(
                child: _chatStream == null
                    ? _buildEmptyState(primaryColor)
                    : StreamBuilder<QuerySnapshot>(
                        stream: _chatStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularLoadingIndicator(
                                size: 32,
                                color: primaryColor,
                              ),
                            );
                          }

                          final docs = snapshot.data?.docs ?? [];

                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) => _scrollToBottom(),
                          );

                          if (docs.isEmpty && !_isAiTyping) {
                            return _buildEmptyState(primaryColor);
                          }

                          return ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 20,
                            ),
                            itemCount: docs.length + (_isAiTyping ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == docs.length && _isAiTyping) {
                                return _buildTypingIndicator(primaryColor);
                              }

                              final data =
                                  docs[index].data() as Map<String, dynamic>;
                              final isUser = data['sender'] == 'user';
                              final text = data['text'] ?? '';
                              final attachmentUrl = data['attachmentUrl'];
                              final attachmentName = data['attachmentName'];
                              final isImageAttachment =
                                  data['isImageAttachment'] ?? false;
                              final timestamp = data['timestamp'] as Timestamp?;"""

stream_builder_new = """Expanded(
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
                                itemCount: _currentMessages.length + (_isAiTyping ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == _currentMessages.length && _isAiTyping) {
                                    return _buildTypingIndicator(primaryColor);
                                  }

                                  final data = _currentMessages[index];
                                  final isUser = data['sender'] == 'user';
                                  final text = data['text'] ?? data['content'] ?? '';
                                  final attachmentUrl = data['attachmentUrl'];
                                  final attachmentName = data['attachmentName'];
                                  final isImageAttachment = data['isImageAttachment'] ?? false;
                                  final timestamp = data['timestamp'] ?? data['created_at'];"""

code = code.replace(stream_builder_old, stream_builder_new)


with open(filepath, 'w', encoding='utf-8') as f:
    f.write(code)

print("Done")
