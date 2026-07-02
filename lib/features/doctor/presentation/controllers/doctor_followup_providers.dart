import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/networking/api_constants.dart';
import '../../../../core/networking/dio_factory.dart';
import '../../domain/entities/doctor_followup_entity.dart';

final doctorFollowUpControllerProvider = StateNotifierProvider.family<
    DoctorFollowUpController, AsyncValue<List<DoctorFollowUpEntity>>, String>(
  (ref, patientId) {
    return DoctorFollowUpController(patientId);
  },
);

class DoctorFollowUpController extends StateNotifier<AsyncValue<List<DoctorFollowUpEntity>>> {
  DoctorFollowUpController(this.patientId) : super(const AsyncValue.loading()) {
    fetchFollowUps();
  }

  final String patientId;

  Future<void> fetchFollowUps() async {
    try {
      state = const AsyncValue.loading();
      final dio = await DioFactory.getDio();
      
      final response = await dio.get(
        ApiConstants.doctorFollowUp,
        queryParameters: {'patient_id': patientId},
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final rawData = response.data['data'];
        final List<dynamic> list = rawData != null && rawData is Map
            ? (rawData['follow_ups'] as List<dynamic>? ?? [])
            : [];
            
        final followUps = list
            .map((item) => DoctorFollowUpEntity.fromJson(item as Map<String, dynamic>))
            .where((item) => item.patientId == patientId) // Filter by current patient ID
            .toList();

        state = AsyncValue.data(followUps);
      } else {
        state = AsyncValue.error(
          Exception('Failed to load follow-ups'),
          StackTrace.current,
        );
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addFollowUp({
    required String suggestionText,
    String? description,
    String? nextVisit,
    required String followUpType,
  }) async {
    try {
      final dio = await DioFactory.getDio();
      
      final response = await dio.post(
        ApiConstants.doctorFollowUp,
        data: {
          'patient_id': int.tryParse(patientId) ?? patientId,
          'suggestion_text': suggestionText,
          'notes': suggestionText, // Support notes key
          'description': description,
          'next_visit': nextVisit,
          'follow_up_type': followUpType,
        },
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        // Refresh list
        await fetchFollowUps();
      } else {
        throw Exception('Failed to add follow-up');
      }
    } catch (e) {
      rethrow;
    }
  }
}
