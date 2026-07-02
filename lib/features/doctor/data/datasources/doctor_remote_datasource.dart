import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:grad_imp_1/core/networking/token_storage.dart';

abstract class DoctorRemoteDataSource {
  Stream<Map<String, dynamic>?> getDashboardStream();
}

class BackendDoctorDataSource implements DoctorRemoteDataSource {
  BackendDoctorDataSource({required String userId}) : _userId = userId;

  final String _userId;
  final Dio _dio = Dio();
  static const String _baseUrl = 'https://brainguard.devawy.com/api/v1';

  Future<Map<String, String>> get _headers async {
    final token = await TokenStorage.getToken();
    return {
      if (token != null) 'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  @override
  Stream<Map<String, dynamic>?> getDashboardStream() async* {
    if (_userId.isEmpty) {
      yield null;
      return;
    }

    final controller = StreamController<Map<String, dynamic>?>();

    Future<void> fetch() async {
      try {
        final headers = await _headers;
        final response = await _dio.get(
          '$_baseUrl/doctor/patients',
          options: Options(headers: headers),
        );

        if (response.statusCode == 200) {
          final List<dynamic> patientsData = response.data['data']['patients'] ?? [];
          
          final parsedPatients = patientsData.map((p) {
             final patientObj = p['patient'] ?? {};
             return {
               'doctor_id': p['doctor_id'],
               'patient_id': p['patient_id'],
               'status': p['status'],
               ...patientObj, // Spread patient details into the map for easy access
             };
          }).toList();

          final statsArray = [
            {
              'title': 'Total\nPatients',
              'value': patientsData.length.toString(),
              'image': 'assets/images/green_graph.svg'
            }
          ];

          if (!controller.isClosed) {
            controller.add({
              'patients': parsedPatients,
              'tasks': [],
              'stats': statsArray,
            });
          }
        } else {
           if (!controller.isClosed) {
             controller.add({});
           }
        }
      } catch (e) {
        debugPrint('Error fetching doctor dashboard: $e');
        if (!controller.isClosed) {
          controller.add({});
        }
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

  // ignore: unused_element
  Future<void> _addPatient(String patientId) async {
    try {
      final headers = await _headers;
      await _dio.post(
        '$_baseUrl/doctor/patients',
        data: {"patient_id": patientId},
        options: Options(headers: headers),
      );
    } catch (e) {
      debugPrint('Error adding patient: $e');
      rethrow;
    }
  }

  // ignore: unused_element
  Future<Map<String, dynamic>> _getPatientDetail(String patientId) async {
    try {
      final headers = await _headers;
      final response = await _dio.get(
        '$_baseUrl/doctor/patients/$patientId',
        options: Options(headers: headers),
      );
      
      if (response.statusCode == 200) {
        return response.data['data']['patient'] ?? {};
      }
      throw Exception('Failed to get patient details');
    } catch (e) {
      debugPrint('Error getting patient details: $e');
      rethrow;
    }
  }
}
