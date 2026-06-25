import 'package:file_picker/file_picker.dart';
import '../../domain/repositories/patient_upload_repository.dart';
import '../datasources/patient_upload_datasource.dart';

class PatientUploadRepositoryImpl implements PatientUploadRepository {
  final PatientUploadRemoteDataSource _remoteDataSource;

  PatientUploadRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> uploadCategoryFiles({
    required String category,
    required List<PlatformFile> files,
  }) {
    return _remoteDataSource.uploadCategoryFiles(
      category: category,
      files: files,
    );
  }

  @override
  Future<Map<String, dynamic>> uploadAIPredictionFile(PlatformFile file) {
    return _remoteDataSource.uploadAIPredictionFile(file);
  }
}
