import 'package:flutter_riverpod/flutter_riverpod.dart';
// removed firestore import
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:grad_imp_1/core/networking/api_constants.dart';
import 'package:grad_imp_1/core/networking/api_response_parser.dart';
import 'package:grad_imp_1/core/networking/dio_factory.dart';
import '../../domain/entities/doctor_search_entity.dart';
import '../../data/datasources/patient_search_remote_datasource.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../data/repositories/patient_search_repository_impl.dart';
import '../../domain/repositories/patient_search_repository.dart';

final patientSearchRemoteDataSourceProvider =
    Provider<PatientSearchRemoteDataSource>((ref) {
      final userId = ref.watch(authStateProvider).valueOrNull?.id ?? '';
      return BackendPatientSearchDataSource(userId: userId);
    });

final patientSearchRepositoryProvider = Provider<PatientSearchRepository>((
  ref,
) {
  return PatientSearchRepositoryImpl(
    ref.watch(patientSearchRemoteDataSourceProvider),
  );
});

final assignedDoctorIdsProvider = StreamProvider<List<String>>((ref) {
  return ref.watch(patientSearchRepositoryProvider).getAssignedDoctorIds();
});

// Provider to fetch distinct specialties of all doctors from API
final doctorSpecialtiesProvider = StreamProvider<List<String>>((ref) async* {
  while (true) {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get('${ApiConstants.baseUrl}/doctors');
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final List<dynamic> data = ApiResponseParser.extractList(response.data);
        final specialtiesSet = <String>{};
        for (var doc in data) {
          final spec = (doc['specialization'] as String?)?.trim();
          if (spec != null && spec.isNotEmpty) {
            specialtiesSet.add(spec);
          }
        }
        final list = specialtiesSet.toList()..sort();
        yield list;
      }
    } catch (e) {
      debugPrint('Error fetching specialties: $e');
    }
    await Future.delayed(const Duration(seconds: 10));
  }
});

final assignedDoctorsProvider =
    StreamProvider.family<List<DoctorSearchEntity>, List<String>>((
      ref,
      doctorIds,
    ) {
      return ref
          .watch(patientSearchRepositoryProvider)
          .getAssignedDoctors(doctorIds);
    });
