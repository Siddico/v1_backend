import 'package:file_picker/file_picker.dart';

abstract class PatientUploadRepository {
  Future<void> uploadCategoryFiles({
    required String category,
    required List<PlatformFile> files,
  });

  Future<Map<String, dynamic>> uploadAIPredictionFile(PlatformFile file);
}
