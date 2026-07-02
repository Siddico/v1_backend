import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grad_imp_1/core/localization/app_localizations.dart';
import 'package:grad_imp_1/shared/presentation/widgets/circular_loading_indicator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:grad_imp_1/core/networking/api_constants.dart';
import 'package:grad_imp_1/core/networking/dio_factory.dart';

import 'package:grad_imp_1/core/constants/app_images.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';
import 'package:grad_imp_1/core/networking/token_storage.dart';
import 'package:grad_imp_1/shared/presentation/widgets/user_qr_widget.dart';
import 'package:grad_imp_1/shared/ui/toast_service.dart';
import '../../../../auth/presentation/controllers/auth_providers.dart';

/// Profile header card shown on the patient's own profile page.
/// Displays their avatar (tappable to change), name + age, a real QR code
/// and an edit-profile button.
class PatientProfileHeaderCard extends ConsumerStatefulWidget {
  const PatientProfileHeaderCard({
    super.key,
    required this.onEditTap,
    required this.displayName,
    required this.ageLabel,
    this.photoUrl,
  });

  final VoidCallback onEditTap;
  final String displayName;
  final String ageLabel;
  final String? photoUrl;

  @override
  ConsumerState<PatientProfileHeaderCard> createState() =>
      _PatientProfileHeaderCardState();
}

class _PatientProfileHeaderCardState
    extends ConsumerState<PatientProfileHeaderCard> {
  File? _localImage;
  bool _uploading = false;

  Future<void> _pickAndUpload() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile == null) return;

    setState(() {
      _localImage = File(xFile.path);
      _uploading = true;
    });
    ToastService.showInfo('Uploading photo…');
    try {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('Not signed in');

      final dio = await DioFactory.getDio();
      final token = await TokenStorage.getToken();
      final formData = FormData.fromMap({
        '_method': 'PUT',
        'image': await MultipartFile.fromFile(
          _localImage!.path,
          filename: xFile.name,
        ),
      });

      await dio.post(
        ApiConstants.patientProfile,
        data: formData,
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      ref.invalidate(authStateProvider);
      ToastService.showSuccess('Profile photo updated!');
    } catch (e) {
      ToastService.showError('Upload failed: $e');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Choose best image source: local pick → network → asset fallback.
    final ImageProvider avatarImage;
    if (_localImage != null) {
      avatarImage = FileImage(_localImage!);
    } else if (widget.photoUrl != null && widget.photoUrl!.isNotEmpty) {
      avatarImage = NetworkImage(widget.photoUrl!);
    } else {
      avatarImage = const AssetImage(AppImages.patientImage);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          shadows: const [
            BoxShadow(
              color: AppColors.shadowBlack25,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Avatar with camera badge ──
            Stack(
              children: [
                GestureDetector(
                  onTap: _pickAndUpload,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: ShapeDecoration(
                      image: DecorationImage(
                        image: avatarImage,
                        fit: BoxFit.cover,
                      ),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 1.5,
                          color: AppColors.tealP,
                        ),
                        borderRadius: BorderRadius.circular(36),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: AppColors.shadowBlack25,
                          blurRadius: 4,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _uploading
                        ? Container(
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(36),
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularLoadingIndicator(
                                  size: 32,
                                  color: AppColors.tealP,
                                ),
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
                // Camera badge
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickAndUpload,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.tealP,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            // ── Name + age ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.displayName,
                    style:
                        AppTextStyles.patientProfileHeaderNameTeal18ExtraBold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.ageLabel,
                    style: AppTextStyles.patientProfileHeaderAgeTeal14Medium,
                  ),
                  const SizedBox(height: 8),
                  // Edit profile button
                  GestureDetector(
                    onTap: widget.onEditTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.tealP.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.tealP.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 13,
                            color: AppColors.tealP,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Edit profile'.tr(context),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.tealP,
                              fontFamily: AppTextStyles.isArabic
                                  ? 'Cairo'
                                  : 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // ── Real QR code — large & prominent ──
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.tealP.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const UserQrWidget(size: 90),
                ),
                const SizedBox(height: 5),
                Text(
                  'My QR Code'.tr(context),
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.tealP,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
