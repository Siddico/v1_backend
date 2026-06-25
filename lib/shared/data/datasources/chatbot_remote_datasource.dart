import 'package:flutter/foundation.dart';
import 'package:grad_imp_1/core/networking/api_constants.dart';
import 'package:grad_imp_1/core/networking/dio_factory.dart';

class ChatbotRemoteDataSource {
  /// Fetch all chatbot sessions for a patient
  static Future<List<Map<String, dynamic>>> getSessions() async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get(
        '${ApiConstants.baseUrl}/patient/chatbot/sessions',
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('Error fetching chatbot sessions: $e');
      rethrow;
    }
  }

  /// Create a new chatbot session
  static Future<String> createSession(String title) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.post(
        '${ApiConstants.baseUrl}/patient/chatbot/sessions',
        data: {'title': title},
      );
      return response.data['data']['id']?.toString() ?? '';
    } catch (e) {
      debugPrint('Error creating chatbot session: $e');
      rethrow;
    }
  }

  /// Fetch messages for a specific session
  static Future<List<Map<String, dynamic>>> getMessages(
    String sessionId,
  ) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get(
        '${ApiConstants.baseUrl}/patient/chatbot/sessions/$sessionId/messages',
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('Error fetching chatbot messages: $e');
      rethrow;
    }
  }

  /// Send a message to the chatbot
  static Future<void> sendMessage(String sessionId, String content) async {
    try {
      final dio = await DioFactory.getDio();
      await dio.post(
        '${ApiConstants.baseUrl}/patient/chatbot/sessions/$sessionId/messages',
        data: {'content': content},
      );
    } catch (e) {
      debugPrint('Error sending chatbot message: $e');
      rethrow;
    }
  }
}
