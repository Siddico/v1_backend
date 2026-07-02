import 'dart:async';
import '../../../../core/networking/api_constants.dart';
import '../../../../core/networking/api_response_parser.dart';
import '../../../../core/networking/dio_factory.dart';

abstract class NotificationRemoteDataSource {
  Stream<List<Map<String, dynamic>>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> removeNotification(String id);
  Future<void> clearAll();
}

class BackendNotificationDataSource implements NotificationRemoteDataSource {
  BackendNotificationDataSource({required String userId, bool isDoctor = false}) 
      : _userId = userId,
        _isDoctor = isDoctor;

  // ignore: unused_field
  final String _userId;
  final bool _isDoctor;

  Future<List<Map<String, dynamic>>> _fetch() async {
    try {
      final dio = await DioFactory.getDio();
      if (_isDoctor) {
        final response = await dio.get(ApiConstants.doctorAlerts);
        if (response.statusCode == 200) {
          final rawData = response.data is Map ? response.data['data'] : null;
          final List<dynamic> alerts = rawData != null && rawData is Map ? (rawData['alerts'] as List<dynamic>? ?? []) : [];
          return alerts.map((alertItem) {
            final alert = alertItem as Map<String, dynamic>;
            final patient = alert['patient'] as Map<String, dynamic>?;
            final riskLevel = alert['risk_level']?.toString() ?? 'high';
            return {
              'id': alert['id']?.toString() ?? '',
              'title': 'Stroke Risk Alert',
              'subtitle': 'Patient ${patient?['full_name'] ?? ''} is at $riskLevel stroke risk.',
              'time': alert['alert_time']?.toString() ?? '',
              'isUnread': !(alert['is_read'] as bool? ?? false),
              'createdAt': alert['alert_time']?.toString() ?? '',
              'sender_image': patient?['image']?.toString(),
              'sender_id': alert['patient_id']?.toString(),
            };
          }).toList();
        }
      } else {
        final response = await dio.get(ApiConstants.patientNotifications);
        if (response.statusCode == 200) {
          final list = ApiResponseParser.extractList(
            response.data is Map ? response.data['data'] : response.data,
          );
          return list.whereType<Map<String, dynamic>>().toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> getNotifications() {
    final controller = StreamController<List<Map<String, dynamic>>>();
    
    // Immediate fetch
    _fetch().then((data) {
      if (!controller.isClosed) {
        controller.add(data);
      }
    });

    // Periodic poll
    final timer = Timer.periodic(const Duration(seconds: 30), (_) async {
      final data = await _fetch();
      if (!controller.isClosed) {
        controller.add(data);
      }
    });

    controller.onCancel = () {
      timer.cancel();
      controller.close();
    };

    return controller.stream;
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      final dio = await DioFactory.getDio();
      if (_isDoctor) {
        await dio.put('${ApiConstants.doctorAlerts}/$id', data: {'is_read': true});
      } else {
        await dio.put('${ApiConstants.patientNotifications}/$id');
      }
    } catch (e) {
      if (!_isDoctor) {
        try {
          final dio = await DioFactory.getDio();
          await dio.patch('${ApiConstants.patientNotifications}/$id');
        } catch (_) {}
      }
    }
  }

  @override
  Future<void> removeNotification(String id) async {
    try {
      if (_isDoctor) {
        // Doctor alerts usually aren't hard deleted by client side swipe, but we can mark it as read as fallback
        final dio = await DioFactory.getDio();
        await dio.put('${ApiConstants.doctorAlerts}/$id', data: {'is_read': true});
      } else {
        final dio = await DioFactory.getDio();
        await dio.delete('${ApiConstants.patientNotifications}/$id');
      }
    } catch (e) {
      // Ignore errors gracefully
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      final notifications = await _fetch();
      final dio = await DioFactory.getDio();
      for (final notification in notifications) {
        final id = notification['id'].toString();
        try {
          if (_isDoctor) {
            await dio.put('${ApiConstants.doctorAlerts}/$id', data: {'is_read': true});
          } else {
            await dio.delete('${ApiConstants.patientNotifications}/$id');
          }
        } catch (e) {
          // Ignore individual errors
        }
      }
    } catch (e) {
      // Ignore fetch errors
    }
  }
}
