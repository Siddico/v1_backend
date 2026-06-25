import 'package:flutter/foundation.dart';
import 'package:grad_imp_1/core/networking/api_constants.dart';
import 'package:grad_imp_1/core/networking/dio_factory.dart';

class RequestService {
  /// Create a new relationship request (patient -> doctor)
  static Future<String> createRequest({
    required String patientId,
    required String doctorId,
    String? message,
    int? expiresInHours,
  }) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.post(
        '${ApiConstants.baseUrl}/patient/relationship-requests',
        data: {
          'doctor_id': doctorId,
          'message': message ?? '',
          // Add expiry logic if API supports it, omitted for standard MVP
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['data']?['id']?.toString() ?? 'created';
      }
      throw Exception('Failed to create request');
    } catch (e) {
      debugPrint('Error creating request: $e');
      rethrow;
    }
  }

  static Future<void> cancelRequest({required String requestId}) async {
    try {
      final dio = await DioFactory.getDio();
      await dio.delete(
        '${ApiConstants.baseUrl}/patient/relationship-requests/$requestId',
      );
    } catch (e) {
      debugPrint('Error cancelling request: $e');
      rethrow;
    }
  }

  /// Stream pending requests for a specific doctor
  static Stream<List<Map<String, dynamic>>> streamDoctorRequests({
    required String doctorId,
  }) async* {
    while (true) {
      try {
        final dio = await DioFactory.getDio();
        final response = await dio.get(
          '${ApiConstants.baseUrl}/doctor/relationship-requests',
        );

        if (response.statusCode != null &&
            response.statusCode! >= 200 &&
            response.statusCode! < 300) {
          final List<dynamic> data = response.data['data'] ?? [];
          yield data.map((d) => d as Map<String, dynamic>).toList();
        }
      } catch (e) {
        debugPrint('Error fetching doctor requests: $e');
      }
      await Future.delayed(const Duration(seconds: 10));
    }
  }

  /// Stream requests made by a specific patient
  static Stream<List<Map<String, dynamic>>> streamPatientRequests({
    required String patientId,
  }) async* {
    while (true) {
      try {
        final dio = await DioFactory.getDio();
        final response = await dio.get(
          '${ApiConstants.baseUrl}/patient/relationship-requests',
        );

        if (response.statusCode != null &&
            response.statusCode! >= 200 &&
            response.statusCode! < 300) {
          final List<dynamic> data = response.data['data'] ?? [];
          yield data.map((d) => d as Map<String, dynamic>).toList();
        }
      } catch (e) {
        debugPrint('Error fetching patient requests: $e');
      }
      await Future.delayed(const Duration(seconds: 10));
    }
  }

  static Future<Map<String, dynamic>> acceptRequest({
    required String requestId,
  }) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.put(
        '${ApiConstants.baseUrl}/doctor/relationship-requests/$requestId',
        data: {'status': 'accepted'},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error accepting request: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> declineRequest({
    required String requestId,
    String? reason,
  }) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.put(
        '${ApiConstants.baseUrl}/doctor/relationship-requests/$requestId',
        data: {'status': 'rejected', if (reason != null) 'reason': reason},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error declining request: $e');
      rethrow;
    }
  }
}
