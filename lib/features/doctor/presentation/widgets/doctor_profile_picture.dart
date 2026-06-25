import 'dart:io';
import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/shared/presentation/widgets/circular_loading_indicator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/controllers/auth_providers.dart';
import 'package:grad_imp_1/core/networking/api_constants.dart';
import 'package:grad_imp_1/core/networking/dio_factory.dart';
import '../../../../core/services/profile_storage_service.dart';
import '../../../../shared/ui/toast_service.dart';

/// Widget for doctors to view and edit their profile picture.
class DoctorProfilePicture extends ConsumerStatefulWidget {
  const DoctorProfilePicture({super.key});

  @override
  ConsumerState<DoctorProfilePicture> createState() =>
      _DoctorProfilePictureState();
}

class _DoctorProfilePictureState extends ConsumerState<DoctorProfilePicture> {
  String? _photoUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get(ApiConstants.doctorProfile);
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final data = response.data['data'];
        setState(() {
          _photoUrl = data['photo_url'] ?? data['image'];
        });
      }
    } catch (e) {
      debugPrint('Error loading doctor profile: $e');
    }
  }

  Future<void> _pickAndUpload() async {
    final picker = ImagePicker();
    final XFile? xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile == null) return;
    setState(() => _isLoading = true);
    ToastService.showInfo('Uploading photo...');
    try {
      final uid = ref.read(authStateProvider).valueOrNull?.id ?? 'doctor';
      final url = await ProfileStorageService().uploadProfileImage(
        uid: uid,
        imageFile: File(xFile.path),
      );

      final dio = await DioFactory.getDio();
      await dio.put(
        ApiConstants.doctorProfile,
        data: {'photo_url': url, 'image': url},
      );

      setState(() => _photoUrl = url);
      ToastService.showSuccess('Photo updated');
    } catch (e) {
      ToastService.showError('Upload failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickAndUpload,
          child: CircleAvatar(
            radius: 60,
            backgroundImage: _photoUrl != null
                ? NetworkImage(_photoUrl!)
                : null,
            child: _photoUrl == null
                ? const Icon(Icons.camera_alt, size: 40)
                : null,
          ),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularLoadingIndicator(size: 24, color: AppColors.redDeep),
          ),
      ],
    );
  }
}
