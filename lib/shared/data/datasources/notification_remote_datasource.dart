import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:grad_imp_1/core/networking/api_constants.dart';
import 'package:grad_imp_1/core/networking/api_response_parser.dart';
import 'package:grad_imp_1/core/networking/dio_factory.dart';
import 'package:grad_imp_1/core/networking/local_storage.dart';
import 'package:grad_imp_1/core/enums/user_role.dart';

abstract class NotificationRemoteDataSource {
  Stream<List<Map<String, dynamic>>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> removeNotification(String id);
  Future<void> clearAll();
}

class BackendNotificationDataSource implements NotificationRemoteDataSource {
  BackendNotificationDataSource({required String userId, required LocalStorage storage}) 
      : _userId = userId, _storage = storage;

  final String _userId;
  final LocalStorage _storage;

  String get _notificationEndpoint {
    final role = _storage.getRole();
    return role == UserRole.doctor ? ApiConstants.doctorAlerts : ApiConstants.patientNotifications;
  }

  @override
  Stream<List<Map<String, dynamic>>> getNotifications() async* {
    if (_userId.isEmpty) {
      yield [];
      return;
    }
    
    // Polling API every 10 seconds for notifications
    while (true) {
      try {
        final dio = await DioFactory.getDio();
        final response = await dio.get(_notificationEndpoint);
        
        if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
          final List<dynamic> data = ApiResponseParser.extractList(response.data);
          final List<Map<String, dynamic>> mapped = data.map((d) => d as Map<String, dynamic>).toList();
          yield mapped;
        } else {
          yield []; // Yield empty if not successful to prevent infinite loading
        }
      } catch (e) {
        debugPrint('Error fetching notifications: $e');
        yield []; // Yield empty on error to prevent infinite loading
      }
      await Future.delayed(const Duration(seconds: 10));
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    if (_userId.isEmpty) return;
    try {
      final dio = await DioFactory.getDio();
      final role = _storage.getRole();
      if (role == UserRole.doctor) {
        // Doctor alerts use PUT
        await dio.put('$_notificationEndpoint/$id');
      } else {
        // Patient notifications use PATCH
        await dio.patch('$_notificationEndpoint/$id/read');
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  @override
  Future<void> removeNotification(String id) async {
    if (_userId.isEmpty) return;
    try {
      final dio = await DioFactory.getDio();
      await dio.delete('$_notificationEndpoint/$id');
    } catch (e) {
      debugPrint('Error removing notification: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    if (_userId.isEmpty) return;
    try {
      final dio = await DioFactory.getDio();
      await dio.delete(_notificationEndpoint);
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
    }
  }
}
