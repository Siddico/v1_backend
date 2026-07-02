import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grad_imp_1/core/localization/app_localizations.dart';
import 'package:grad_imp_1/shared/presentation/widgets/circular_loading_indicator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:grad_imp_1/core/networking/api_constants.dart';
import 'package:grad_imp_1/core/networking/dio_factory.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../core/theme/app_text_styles.dart' show AppTextStyles;
import 'package:grad_imp_1/core/networking/token_storage.dart';
import 'package:dio/dio.dart';
import '../../../../../shared/ui/toast_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../auth/presentation/controllers/auth_providers.dart';

class DoctorAvatarPanel extends ConsumerStatefulWidget {
  const DoctorAvatarPanel({
    super.key,
    required this.showIdentity,
    required this.onAvatarEdit,
    this.displayName,
    this.child,
    this.isEditMode = false,
    this.photoUrl,
    this.specialist,
    this.selectedImage,
    this.onImagePicked,
  });

  final bool showIdentity;
  final VoidCallback onAvatarEdit;
  final String? displayName;
  final Widget? child;
  final bool isEditMode;
  final String? photoUrl;
  final String? specialist;
  final File? selectedImage;
  final ValueChanged<File>? onImagePicked;

  @override
  ConsumerState<DoctorAvatarPanel> createState() => _DoctorAvatarPanelState();
}

class _DoctorAvatarPanelState extends ConsumerState<DoctorAvatarPanel> {
  File? _localImage;
  bool _uploading = false;

  Future<void> _pickAndUpload() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile == null) return;

    if (widget.onImagePicked != null) {
      widget.onImagePicked!(File(xFile.path));
      return;
    }

    setState(() {
      _localImage = File(xFile.path);
      _uploading = true;
    });
    // ignore: use_build_context_synchronously
    ToastService.showInfo('Uploading photo…'.tr(context));

    try {
      final uid = ref.read(authStateProvider).valueOrNull?.id;
      if (uid == null) throw Exception('Not signed in');

      final dio = await DioFactory.getDio();
      final token = await TokenStorage.getToken();
      final formData = FormData.fromMap({
        '_method': 'PUT',
        'image': await MultipartFile.fromFile(_localImage!.path, filename: xFile.name),
      });

      await dio.post(
        ApiConstants.doctorProfile,
        data: formData,
        options: Options(headers: {
           if (token != null) 'Authorization': 'Bearer $token',
           'Accept': 'application/json',
        }),
      );
      ref.invalidate(authStateProvider);
      // ignore: use_build_context_synchronously
      ToastService.showSuccess('Profile photo updated'.tr(context));
    } catch (e) {
      // ignore: use_build_context_synchronously
      ToastService.showError('${'Upload failed:'.tr(context)} $e');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const editBadgeTop = 84.0;

    // Determine which image to show: parent-level picked > local picked > network URL > asset fallback.
    ImageProvider imageProvider;
    if (widget.selectedImage != null) {
      imageProvider = FileImage(widget.selectedImage!);
    } else if (_localImage != null) {
      imageProvider = FileImage(_localImage!);
    } else if (widget.photoUrl != null && widget.photoUrl!.isNotEmpty) {
      imageProvider = NetworkImage(widget.photoUrl!);
    } else {
      imageProvider = const AssetImage(AppImages.makramImage);
    }

    return SizedBox(
      height: widget.showIdentity ? 272 : 122,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 25,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowBlack25,
                          blurRadius: 4,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  if (_uploading)
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Center(
                        child: CircularLoadingIndicator(
                          size: 24,
                          color: AppColors.redDeep,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Edit badge — always visible but only triggers upload in edit mode.
          Positioned(
            left: 0,
            right: -64,
            top: editBadgeTop,
            child: Center(
              child: GestureDetector(
                onTap: widget.isEditMode ? _pickAndUpload : widget.onAvatarEdit,
                child: Container(
                  width: 31,
                  height: 31,
                  decoration: BoxDecoration(
                    color: AppColors.redSurface,
                    borderRadius: BorderRadius.circular(15.5),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AppImages.editIconSvg,
                      width: 17,
                      height: 17,
                      colorFilter: const ColorFilter.mode(
                        AppColors.redDeep,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (widget.showIdentity)
            Positioned(
              left: 0,
              right: 0,
              top: 128,
              child: Column(
                children: [
                  Text(
                    widget.displayName ?? 'Doctor'.tr(context),
                    textAlign: TextAlign.center,
                    style:
                        AppTextStyles.doctorProfileNameRedNearBlack20SemiBold,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.specialist?.isNotEmpty == true
                            ? widget.specialist!
                            : 'Specialist'.tr(context),
                        style:
                            AppTextStyles.doctorSpecialtyRedNearBlack16Regular,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          if (widget.child != null)
            Positioned(left: 0, right: 0, top: 198, child: widget.child!),
        ],
      ),
    );
  }
}
