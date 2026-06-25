import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:grad_imp_1/core/networking/api_constants.dart';
import 'package:grad_imp_1/core/networking/dio_factory.dart';

abstract class PatientUploadRemoteDataSource {
  Future<void> uploadCategoryFiles({
    required String category,
    required List<PlatformFile> files,
  });

  Future<Map<String, dynamic>> uploadAIPredictionFile(PlatformFile file);
}

class BackendPatientUploadDataSource implements PatientUploadRemoteDataSource {
  BackendPatientUploadDataSource({required String userId}) : _userId = userId;

  final String _userId;

  @override
  Future<void> uploadCategoryFiles({
    required String category,
    required List<PlatformFile> files,
  }) async {
    if (_userId.isEmpty || files.isEmpty) return;

    for (final file in files) {
      final sanitizedName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9.]'), '_');
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$sanitizedName';
      
      // Upload to Cloudinary
      final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
      final String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'grad_storage';
      
      final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'pdf'].contains(file.extension?.toLowerCase());
      final resourceType = isImage ? 'image' : 'raw';
      
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload');
      final request = http.MultipartRequest('POST', uri);
      
      request.fields['upload_preset'] = uploadPreset;
      request.fields['public_id'] = 'users/$_userId/uploads/$category/$fileName';
      
      if (file.path != null) {
        request.files.add(await http.MultipartFile.fromPath('file', file.path!));
      } else if (file.bytes != null) {
        request.files.add(http.MultipartFile.fromBytes('file', file.bytes!, filename: file.name));
      } else {
        continue;
      }
      
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse).timeout(const Duration(seconds: 30));
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to upload file to Cloudinary: ${response.statusCode}');
      }
      
      final data = jsonDecode(response.body);
      final downloadUrl = data['secure_url'];

      // Save to Laravel Backend
      final dio = await DioFactory.getDio();
      
      if (category.contains('signals')) {
        String signalType = 'ECG';
        if (category == 'ppg_signals' || category == 'ppg_ai_signals') {
          signalType = 'PPG';
        }
        
        await dio.post(
          ApiConstants.patientSignals,
          data: {
            'signal_type': signalType,
            'source': 'file_upload',
            'file_url': downloadUrl,
            'raw_data': [0],
          },
        );
      } else {
        await dio.post(
          ApiConstants.patientRadiology,
          data: {
            'upload_type': category,
            'description': file.name,
            'file_url': downloadUrl,
            'uploaded_at': DateTime.now().toUtc().toIso8601String().split('.')[0] + 'Z',
          },
        );
      }
    }
  }

  @override
  Future<Map<String, dynamic>> uploadAIPredictionFile(PlatformFile file) async {
    if (_userId.isEmpty) return {};

    // Use the deployed Vercel backend
    final String baseUrl = dotenv.env['VERCEL_BASE_URL'] ?? 'https://stroke-prediction-mocha.vercel.app';
    final uri = Uri.parse('$baseUrl/api/ai/predict-mat');
    final request = http.MultipartRequest('POST', uri);
    
    // Firebase auth is removed, you may need to implement Laravel token here if the Vercel backend expects it
    
    if (file.path != null) {
      request.files.add(await http.MultipartFile.fromPath('file', file.path!));
    } else if (file.bytes != null) {
      request.files.add(http.MultipartFile.fromBytes('file', file.bytes!, filename: file.name));
    } else {
      return {};
    }

    final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamedResponse).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to upload AI prediction file to backend: ${response.statusCode} - ${response.body}');
    }

    return jsonDecode(response.body);
  }
}
