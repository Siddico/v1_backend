import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// Removed unused firebase_auth import
import 'package:grad_imp_1/shared/presentation/widgets/circular_loading_indicator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:grad_imp_1/core/networking/api_constants.dart';
import 'package:grad_imp_1/core/networking/dio_factory.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/presentation/widgets/app_bar_controls.dart';
import '../../../../shared/presentation/widgets/app_toast.dart';
import '../../../../shared/presentation/providers/chat_providers.dart';
import '../../../doctor/presentation/widgets/instruction_item.dart';
import '../../../requests/request_doctor_dialog.dart';
import '../pages/patient_messages_page.dart';
import '../../../../core/localization/app_localizations.dart';

class PatientScanQrPage extends ConsumerStatefulWidget {
  const PatientScanQrPage({super.key});

  @override
  ConsumerState<PatientScanQrPage> createState() => _PatientScanQrPageState();
}

class _PatientScanQrPageState extends ConsumerState<PatientScanQrPage> {
  bool _isDarkMode = false;
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _isHandlingScan = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _scanImageFromGallery() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile == null) return;

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularLoadingIndicator(size: 24, color: AppColors.tealP),
      ),
    );

    try {
      final BarcodeCapture? capture = await _scannerController.analyzeImage(
        xFile.path,
      );
      if (mounted) Navigator.of(context).pop();

      if (capture != null && capture.barcodes.isNotEmpty) {
        final rawValue = capture.barcodes.first.rawValue;
        if (rawValue != null && rawValue.isNotEmpty) {
          _handleDetectedCode(rawValue);
        } else {
          _showNoCodeToast();
        }
      } else {
        _showNoCodeToast();
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      _showNoCodeToast();
    }
  }

  void _showNoCodeToast() {
    if (mounted) {
      AppToast.show(
        context,
        'No valid QR code found in the selected image.'.tr(context),
        type: AppToastType.error,
        role: UserRole.patient,
      );
    }
  }

  Future<void> _handleDetectedCode(String rawValue) async {
    if (_isHandlingScan) return;
    _isHandlingScan = true;

    await _scannerController.stop();

    if (!mounted) return;

    String code;
    try {
      final decoded = jsonDecode(rawValue) as Map<String, dynamic>;
      code = decoded['uid']?.toString() ?? rawValue;
    } catch (_) {
      if (rawValue.startsWith('uid:')) {
        code = rawValue.split(';').first.replaceFirst('uid:', '');
      } else {
        code = rawValue;
      }
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularLoadingIndicator(size: 24, color: AppColors.tealP),
      ),
    );

    try {
      final dio = await DioFactory.getDio();
      final response = await dio.post(
        ApiConstants.patientQr,
        data: {'qr_data': code},
      );

      // Dismiss loading indicator
      if (mounted) Navigator.of(context).pop();

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        if (!mounted) return;
        AppToast.show(
          context,
          'QR Code scanned and request sent successfully'.tr(context),
          type: AppToastType.success,
          role: UserRole.patient,
        );
      } else {
        if (!mounted) return;
        AppToast.show(
          context,
          'Failed to link with Doctor'.tr(context),
          type: AppToastType.error,
          role: UserRole.patient,
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop(); // dismiss loading
      if (mounted) {
        AppToast.show(
          context,
          '${'Error checking QR: '.tr(context)}$e',
          type: AppToastType.error,
          role: UserRole.patient,
        );
      }
    } finally {
      if (mounted) {
        _isHandlingScan = false;
        await _scannerController.start();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxContentWidth = size.width > 440 ? 358.0 : size.width - 44;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppBarControls(
                isDarkMode: _isDarkMode,
                onDarkModeToggle: () {
                  setState(() {
                    _isDarkMode = !_isDarkMode;
                  });
                },
                onLanguageSelect: () {},
                darkModeToggleLightColor: AppColors.tealBorderLight,
                darkModeToggleDarkColor: AppColors.tealP,
              ),
              SizedBox(
                width: maxContentWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // QR Frame
                        Image.asset(
                          AppImages.frameOfQrcode,
                          fit: BoxFit.contain,
                          opacity: const AlwaysStoppedAnimation(0.95),
                        ),
                        // Scan window
                        SizedBox(
                          width: double.infinity,
                          height: 310,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: MobileScanner(
                                  controller: _scannerController,
                                  onDetect: (capture) {
                                    final rawValue =
                                        capture.barcodes.firstOrNull?.rawValue;
                                    if (rawValue != null &&
                                        rawValue.isNotEmpty) {
                                      _handleDetectedCode(rawValue);
                                    }
                                  },
                                ),
                              ),
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: Container(
                                    decoration: const ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 5,
                                          color: AppColors.tealP,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 27),
                    Text(
                      'Please place the doctor\'s QR code directly under the camera lens so that it appears clearly within the scanning frame'
                          .tr(context),
                      style: AppTextStyles.robotoBlack14Regular,
                    ),
                    const SizedBox(height: 20),
                    InstructionItem(
                      text: 'Make sure the lighting is sufficient'.tr(context),
                      dotColor: AppColors.tealP,
                    ),
                    const SizedBox(height: 15),
                    InstructionItem(
                      text: 'The camera lens is clean.'.tr(context),
                      dotColor: AppColors.tealP,
                    ),
                    const SizedBox(height: 15),
                    InstructionItem(
                      text: 'Tap the Scan button to begin reading the QR code.'
                          .tr(context),
                      dotColor: AppColors.tealP,
                    ),
                    const SizedBox(height: 37),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: Material(
                              color: AppColors.tealP,
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () async {
                                  await _scannerController.start();
                                },
                                child: Center(
                                  child: Text(
                                    'Scan'.tr(context),
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles
                                        .buttonTextTealSurface27ExtraBold
                                        .copyWith(
                                          fontSize: 16,
                                          fontFamily: AppTextStyles.isArabic
                                              ? 'Cairo'
                                              : 'Poppins',
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton.icon(
                              icon: const Icon(
                                Icons.photo_library_outlined,
                                size: 20,
                              ),
                              label: Text(
                                'Scan Image'.tr(context),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AppTextStyles.isArabic
                                      ? 'Cairo'
                                      : 'Poppins',
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                alignment: Alignment.center,
                                foregroundColor: AppColors.tealP,
                                side: const BorderSide(
                                  color: AppColors.tealP,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: _scanImageFromGallery,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 37),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
