import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:grad_imp_1/core/networking/api_constants.dart';
import 'package:grad_imp_1/core/networking/api_response_parser.dart';
import 'package:grad_imp_1/core/networking/dio_factory.dart';

abstract class PatientSearchRemoteDataSource {
  Stream<List<String>> getAssignedDoctorIds();
  Stream<List<Map<String, dynamic>>> getAssignedDoctors(List<String> doctorIds);
}

class BackendPatientSearchDataSource implements PatientSearchRemoteDataSource {
  BackendPatientSearchDataSource({required String userId}) : _userId = userId;

  final String _userId;

  @override
  Stream<List<String>> getAssignedDoctorIds() async* {
    if (_userId.isEmpty) yield [];
    
    // Polling API every 10 seconds for assigned doctors
    while (true) {
      try {
        final dio = await DioFactory.getDio();
        // Assuming endpoint /patient/doctors returns assigned doctors
        final response = await dio.get('${ApiConstants.baseUrl}/doctors');
        
        if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
          final List<dynamic> data = ApiResponseParser.extractList(response.data);
          final ids = data.map((d) => d['id'].toString()).toList();
          yield ids;
        }
      } catch (e) {
        debugPrint('Error fetching assigned doctor IDs: $e');
      }
      await Future.delayed(const Duration(seconds: 10));
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> getAssignedDoctors(List<String> doctorIds) async* {
    if (_userId.isEmpty || doctorIds.isEmpty) yield [];
    
    while (true) {
      try {
        final dio = await DioFactory.getDio();
        // Assuming endpoint returns the full details
        final response = await dio.get('${ApiConstants.baseUrl}/doctors');
        
        if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
          final List<dynamic> data = ApiResponseParser.extractList(response.data);
          final List<Map<String, dynamic>> mapped = data.map((d) {
            return {
              ...d as Map<String, dynamic>,
              'id': d['id'].toString(),
              'specialty': d['specialty'] ?? 'General Neurology',
            };
          }).toList();
          yield mapped;
        }
      } catch (e) {
        debugPrint('Error fetching assigned doctors: $e');
      }
      await Future.delayed(const Duration(seconds: 10));
    }
  }
}
