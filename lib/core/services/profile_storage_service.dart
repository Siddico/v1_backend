import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service responsible for uploading a user's profile image to Cloudinary.
class ProfileStorageService {
  // Cloudinary configuration loaded from env
  String get _cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  final String _uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'grad_storage';

  /// Uploads the given [imageFile] to Cloudinary.
  /// Returns the secure download URL of the uploaded image.
  /// Throws an [Exception] if the upload fails.
  Future<String> uploadProfileImage({required String uid, required File imageFile}) async {
    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri);
      
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['public_id'] = 'profile_${uid}_${DateTime.now().millisecondsSinceEpoch}'; // Unique ID to prevent caching issues
      
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final String secureUrl = data['secure_url'];
        
        return secureUrl;
      } else {
        throw Exception('Failed to upload image to Cloudinary: ${response.statusCode}');
      }
    } catch (e) {
      // Re‑throw to let callers handle UI feedback.
      rethrow;
    }
  }
}
