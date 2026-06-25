import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../data/datasources/patient_upload_datasource.dart';
import '../../data/repositories/patient_upload_repository_impl.dart';
import '../../domain/repositories/patient_upload_repository.dart';

final patientUploadRemoteDataSourceProvider =
    Provider<PatientUploadRemoteDataSource>((ref) {
      final userId = ref.watch(authStateProvider).valueOrNull?.id ?? '';
      return BackendPatientUploadDataSource(userId: userId);
    });

final patientUploadRepositoryProvider = Provider<PatientUploadRepository>((
  ref,
) {
  return PatientUploadRepositoryImpl(
    ref.watch(patientUploadRemoteDataSourceProvider),
  );
});

final patientUploadControllerProvider =
    StateNotifierProvider<PatientUploadController, AsyncValue<void>>((ref) {
      return PatientUploadController(
        ref.watch(patientUploadRepositoryProvider),
      );
    });

class PatientUploadController extends StateNotifier<AsyncValue<void>> {
  final PatientUploadRepository _repository;

  PatientUploadController(this._repository)
    : super(const AsyncValue.data(null));

  Future<void> uploadCategoryFiles({
    required String category,
    required List<PlatformFile> files,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.uploadCategoryFiles(category: category, files: files);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> uploadAIPredictionFile(PlatformFile file) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.uploadAIPredictionFile(file);
      state = const AsyncValue.data(null);
      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
