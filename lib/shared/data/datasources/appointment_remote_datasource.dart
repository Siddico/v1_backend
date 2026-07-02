import 'package:flutter/foundation.dart';
import 'package:grad_imp_1/core/networking/api_constants.dart';
import 'package:grad_imp_1/core/networking/api_response_parser.dart';
import 'package:grad_imp_1/core/networking/dio_factory.dart';

class AppointmentRemoteDataSource {
  /// Fetch all appointments for a patient
  static Future<List<Map<String, dynamic>>> getPatientAppointments() async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get(ApiConstants.patientAppointments);
      
      final List<dynamic> data = ApiResponseParser.extractList(
        response.data != null && response.data is Map ? response.data['data'] : null,
      );
      return data.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('Error fetching patient appointments: $e');
      rethrow;
    }
  }

  /// Fetch a single appointment by ID for a patient
  static Future<Map<String, dynamic>?> getPatientAppointmentById(int appointmentId) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get('${ApiConstants.patientAppointments}/$appointmentId');
      if (response.data is Map) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return data;
        } else if (data is Map) {
          return Map<String, dynamic>.from(data);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching patient appointment $appointmentId: $e');
      rethrow;
    }
  }

  /// Create a new appointment as a patient
  static Future<void> createAppointment({
    required int doctorId,
    required String appointmentDate,
    String? specialty,
    String? notes,
  }) async {
    try {
      final dio = await DioFactory.getDio();
      
      int validDoctorId = doctorId;
      if (validDoctorId <= 0) {
        try {
          final docRes = await dio.get('/doctors');
          final List<dynamic> doctors = ApiResponseParser.extractList(docRes.data?['data']);
          if (doctors.isNotEmpty) {
            validDoctorId = doctors.first['id'] as int;
          }
        } catch (_) {}
      }

      await dio.post(
        ApiConstants.patientAppointments,
        data: {
          'doctor_id': validDoctorId,
          'appointment_date': appointmentDate,
          'specialty':? specialty,
          'notes':? notes,
        },
      );
    } catch (e) {
      debugPrint('Error creating appointment: $e');
      rethrow;
    }
  }

  /// Update an appointment as a patient
  static Future<void> updatePatientAppointment(
    int appointmentId,
    String status,
  ) async {
    try {
      final dio = await DioFactory.getDio();
      await dio.put(
        '${ApiConstants.patientAppointments}/$appointmentId',
        data: {'status': status},
      );
    } catch (e) {
      debugPrint('Error updating patient appointment: $e');
      rethrow;
    }
  }

  /// Fetch all appointments for a doctor
  static Future<List<Map<String, dynamic>>> getDoctorAppointments() async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get(ApiConstants.doctorAppointments);
      
      final List<dynamic> data = ApiResponseParser.extractList(
        response.data != null && response.data is Map ? response.data['data'] : null,
      );
      return data.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('Error fetching doctor appointments: $e');
      rethrow;
    }
  }

  /// Update an appointment as a doctor
  static Future<void> updateDoctorAppointment(
    int appointmentId,
    String status,
    String notes,
  ) async {
    try {
      final dio = await DioFactory.getDio();
      await dio.put(
        '${ApiConstants.doctorAppointments}/$appointmentId',
        data: {'status': status, 'notes': notes},
      );
    } catch (e) {
      debugPrint('Error updating doctor appointment: $e');
      rethrow;
    }
  }
}
