import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:grad_imp_1/core/networking/api_constants.dart';
import 'package:grad_imp_1/core/networking/api_response_parser.dart';
import 'package:grad_imp_1/core/networking/dio_factory.dart';

class RequestService {
  static Future<String> createRequest({
    required String patientId,
    required String doctorId,
    String? message,
    int? expiresInHours,
  }) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.post(
        ApiConstants.patientRelationshipRequests,
        data: {
          'doctor_id': int.tryParse(doctorId) ?? doctorId,
          'message': message ?? '',
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        if (data is Map && data.containsKey('relationship_request')) {
          return data['relationship_request']['id'].toString();
        }
        return data['id']?.toString() ?? '';
      }
      throw Exception('Failed to create request');
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw Exception('A pending request already exists.');
      }
      debugPrint('Error creating request: $e');
      rethrow;
    } catch (e) {
      debugPrint('Error creating request: $e');
      rethrow;
    }
  }

  static Future<void> cancelRequest({required String requestId}) async {
    try {
      final dio = await DioFactory.getDio();
      await dio.delete('${ApiConstants.patientRelationshipRequests}/$requestId');
    } catch (e) {
      debugPrint('Error cancelling request: $e');
      rethrow;
    }
  }

  static Stream<List<Map<String, dynamic>>> streamDoctorRequests({
    required String doctorId,
  }) async* {
    final controller = StreamController<List<Map<String, dynamic>>>();

    Future<void> fetch() async {
      try {
        final dio = await DioFactory.getDio();
        final response = await dio.get(ApiConstants.doctorRelationshipRequests);

        if (response.statusCode == 200) {
          final list = ApiResponseParser.extractList(
            response.data is Map ? response.data['data'] : response.data,
          );
          if (!controller.isClosed) {
            controller.add(list.whereType<Map<String, dynamic>>().toList());
          }
        }
      } catch (e) {
        debugPrint('Error fetching doctor requests: $e');
      }
    }

    fetch();
    final timer = Timer.periodic(const Duration(seconds: 30), (_) => fetch());

    controller.onCancel = () {
      timer.cancel();
      controller.close();
    };

    yield* controller.stream;
  }

  static Stream<List<Map<String, dynamic>>> streamPatientRequests({
    required String patientId,
  }) async* {
    final controller = StreamController<List<Map<String, dynamic>>>();

    Future<void> fetch() async {
      try {
        final dio = await DioFactory.getDio();
        final response = await dio.get(ApiConstants.patientRelationshipRequests);

        if (response.statusCode == 200) {
          final list = ApiResponseParser.extractList(
            response.data is Map ? response.data['data'] : response.data,
          );
          if (!controller.isClosed) {
            controller.add(list.whereType<Map<String, dynamic>>().toList());
          }
        }
      } catch (e) {
        debugPrint('Error fetching patient requests: $e');
      }
    }

    fetch();
    final timer = Timer.periodic(const Duration(seconds: 30), (_) => fetch());

    controller.onCancel = () {
      timer.cancel();
      controller.close();
    };

    yield* controller.stream;
  }

  static Future<Map<String, dynamic>> acceptRequest({
    required String requestId,
    String? doctorId,
    String? patientId,
  }) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.put(
        '${ApiConstants.doctorRelationshipRequests}/$requestId',
        data: {'status': 'accepted'},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error accepting request: $e');
      rethrow;
    }
  }

  static Future<void> declineRequest({
    required String requestId,
    String? reason,
  }) async {
    try {
      final dio = await DioFactory.getDio();
      await dio.put(
        '${ApiConstants.doctorRelationshipRequests}/$requestId',
        data: {'status': 'rejected'},
      );
    } catch (e) {
      debugPrint('Error declining request: $e');
      rethrow;
    }
  }
}
