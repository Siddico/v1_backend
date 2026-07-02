import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/presentation/widgets/home_search/doctor_search_patient_item.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../../../core/networking/api_constants.dart';
import '../../../../core/networking/dio_factory.dart';

/// Streams the list of patients linked to the current doctor.
/// Used by the Search page to show real API patients.
final doctorLinkedPatientsProvider = StreamProvider<List<DoctorSearchPatientItem>>((ref) async* {
  final userId = ref.watch(authStateProvider).valueOrNull?.id ?? '';
  if (userId.isEmpty) yield [];

  while (true) {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get('${ApiConstants.baseUrl}/doctor/patients');

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        final List<dynamic> data = response.data['data']?['patients'] ?? [];
        final items = <DoctorSearchPatientItem>[];
        for (final doc in data) {
          final patientObj = doc['patient'] ?? {};
          final patientId = patientObj['id']?.toString() ?? doc['patient_id']?.toString() ?? '';
          if (patientId.isEmpty) continue;
          
          final shortId = '#${patientId.padLeft(4, '0')}';
          
          items.add(
            DoctorSearchPatientItem(
              name: patientObj['full_name']?.toString() ?? 'Patient',
              diagnosis: doc['diagnoses']?.toString() ?? 'N/A',
              patientId: shortId,
              status: patientObj['status']?.toString() ?? doc['status']?.toString() ?? 'Stable',
              image: patientObj['photo_url']?.toString() ?? patientObj['image']?.toString() ?? '',
              firestoreId: patientId,
            ),
          );
        }
        yield items;
      }
    } catch (e) {
      debugPrint('Error fetching linked patients: $e');
    }
    await Future.delayed(const Duration(seconds: 10));
  }
});
