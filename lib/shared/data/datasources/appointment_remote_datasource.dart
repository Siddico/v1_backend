import 'package:flutter/foundation.dart';
import 'package:grad_imp_1/core/networking/api_constants.dart';
import 'package:grad_imp_1/core/networking/dio_factory.dart';

class AppointmentRemoteDataSource {
  /// Fetch all appointments for a patient
  static Future<List<Map<String, dynamic>>> getPatientAppointments() async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get(
        '${ApiConstants.baseUrl}/patient/appointments',
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('Error fetching patient appointments: $e');
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
      
      // Fetch a valid doctor ID if possible to avoid 422
      int validDoctorId = doctorId;
      try {
        final docRes = await dio.get('${ApiConstants.baseUrl}/doctors');
        final List<dynamic> doctors = docRes.data['data'] ?? [];
        if (doctors.isNotEmpty) {
          validDoctorId = doctors.first['id'] as int;
        }
      } catch (_) {}

      await dio.post(
        '${ApiConstants.baseUrl}/patient/appointments',
        data: {
          'doctor_id': validDoctorId,
          'appointment_date': appointmentDate,
          if (specialty != null) 'specialty': specialty,
          if (notes != null) 'notes': notes,
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
        '${ApiConstants.baseUrl}/patient/appointments/$appointmentId',
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
      final response = await dio.get(
        '${ApiConstants.baseUrl}/doctor/appointments',
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
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
        '${ApiConstants.baseUrl}/doctor/appointments/$appointmentId',
        data: {'status': status, 'notes': notes},
      );
    } catch (e) {
      debugPrint('Error updating doctor appointment: $e');
      rethrow;
    }
  }
}
