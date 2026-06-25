import 'package:flutter/foundation.dart';
import 'package:grad_imp_1/core/networking/api_constants.dart';
import 'package:grad_imp_1/core/networking/dio_factory.dart';

class MedicationRemoteDataSource {
  /// Fetch all medications for a patient
  static Future<List<Map<String, dynamic>>> getMedications() async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get(
        '${ApiConstants.baseUrl}/patient/medications',
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('Error fetching medications: $e');
      rethrow;
    }
  }

  /// Add a new medication
  static Future<void> addMedication({
    required String name,
    required String dosage,
    required String frequency,
    required String reminderTime,
  }) async {
    try {
      String formattedTime = reminderTime;
      if (formattedTime.length == 5) { // HH:mm
        formattedTime = '$formattedTime:00';
      }
      
      final dio = await DioFactory.getDio();
      await dio.post(
        '${ApiConstants.baseUrl}/patient/medications',
        data: {
          'name': name,
          'dosage': dosage,
          'frequency': frequency,
          'reminder_time': formattedTime,
        },
      );
    } catch (e) {
      debugPrint('Error adding medication: $e');
      rethrow;
    }
  }

  /// Update an existing medication
  static Future<void> updateMedication({
    required int id,
    required String name,
    required String dosage,
    required bool isActive,
  }) async {
    try {
      final dio = await DioFactory.getDio();
      await dio.put(
        '${ApiConstants.baseUrl}/patient/medications/$id',
        data: {'name': name, 'dosage': dosage, 'is_active': isActive},
      );
    } catch (e) {
      debugPrint('Error updating medication: $e');
      rethrow;
    }
  }

  /// Delete a medication
  static Future<void> deleteMedication(int id) async {
    try {
      final dio = await DioFactory.getDio();
      await dio.delete('${ApiConstants.baseUrl}/patient/medications/$id');
    } catch (e) {
      debugPrint('Error deleting medication: $e');
      rethrow;
    }
  }
}
