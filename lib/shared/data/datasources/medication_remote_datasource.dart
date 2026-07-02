import 'package:flutter/foundation.dart';
import 'package:grad_imp_1/core/networking/api_constants.dart';
import 'package:grad_imp_1/core/networking/api_response_parser.dart';
import 'package:grad_imp_1/core/networking/dio_factory.dart';

class MedicationRemoteDataSource {
  /// Fetch all medications for a patient
  static Future<List<Map<String, dynamic>>> getMedications() async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get(ApiConstants.medications);
      
      final List<dynamic> list = ApiResponseParser.extractList(
        response.data is Map ? response.data['data'] : null,
      );
      return list.map((e) => e as Map<String, dynamic>).toList();
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
    String? imageUrl,
  }) async {
    try {
      String formattedTime = reminderTime;
      if (formattedTime.length == 5) { // HH:mm
        formattedTime = '$formattedTime:00';
      }
      
      final dio = await DioFactory.getDio();
      final Map<String, dynamic> data = {
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'reminder_time': formattedTime,
      };
      if (imageUrl != null && imageUrl.isNotEmpty) {
        data['image_url'] = imageUrl;
      }
      await dio.post(
        ApiConstants.medications,
        data: data,
      );
    } catch (e) {
      debugPrint('Error adding medication: $e');
      rethrow;
    }
  }

  /// Update an existing medication
  static Future<void> updateMedication({
    required int id,
    String? name,
    String? dosage,
    String? frequency,
    String? reminderTime,
    bool? isActive,
    String? imageUrl,
  }) async {
    try {
      String? formattedTime = reminderTime;
      if (formattedTime != null && formattedTime.length == 5) { // HH:mm
        formattedTime = '$formattedTime:00';
      }

      final dio = await DioFactory.getDio();
      final Map<String, dynamic> data = {
        if (name != null) 'name': name,
        if (dosage != null) 'dosage': dosage,
        if (frequency != null) 'frequency': frequency,
        if (formattedTime != null) 'reminder_time': formattedTime,
        if (isActive != null) 'is_active': isActive,
        if (imageUrl != null) 'image_url': imageUrl,
      };
      await dio.put(
        '${ApiConstants.medications}/$id',
        data: data,
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
      await dio.delete('${ApiConstants.medications}/$id');
    } catch (e) {
      debugPrint('Error deleting medication: $e');
      rethrow;
    }
  }
}
