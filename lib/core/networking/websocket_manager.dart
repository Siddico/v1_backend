import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

/// WebSocket manager for real-time streaming
class WebSocketManager {
  WebSocketChannel? _channel;
  final SharedPreferences _prefs;
  String? _token;

  WebSocketManager({required SharedPreferences prefs}) : _prefs = prefs;

  /// Connect to WebSocket for predictions streaming
  Future<void> connectToRealTimePredictions(String userId) async {
    try {
      _token = _prefs.getString('auth_token');
      
      final wsUrl = Uri.parse(
        '${ApiConfig.webSocketUrl}${ApiConfig.predictionsStreamEndpoint}/$userId?token=$_token',
      );
      
      _channel = WebSocketChannel.connect(wsUrl);
      
      // Listen for connection establishment
      await _channel!.ready;
    } catch (e) {
      debugPrint('WebSocket Connection Error: $e');
      rethrow;
    }
  }

  /// Connect to WebSocket for health signals streaming
  Future<void> connectToHealthSignalsStream(String userId) async {
    try {
      _token = _prefs.getString('auth_token');
      
      final wsUrl = Uri.parse(
        '${ApiConfig.webSocketUrl}${ApiConfig.healthSignalsStreamEndpoint}/$userId?token=$_token',
      );
      
      _channel = WebSocketChannel.connect(wsUrl);
      await _channel!.ready;
    } catch (e) {
      debugPrint('WebSocket Connection Error: $e');
      rethrow;
    }
  }

  /// Send message through WebSocket
  void sendMessage(dynamic message) {
    if (_channel != null) {
      _channel!.sink.add(message);
    }
  }

  /// Stream for receiving messages
  Stream<dynamic> get stream => _channel?.stream ?? Stream.empty();

  /// Disconnect WebSocket
  Future<void> disconnect() async {
    await _channel?.sink.close();
    _channel = null;
  }

  /// Check if connected
  bool get isConnected => _channel != null;
}
