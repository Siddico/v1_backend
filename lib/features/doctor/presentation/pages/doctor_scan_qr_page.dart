import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:grad_imp_1/core/networking/api_constants.dart';
import 'package:grad_imp_1/core/networking/dio_factory.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/presentation/widgets/app_bar_controls.dart';
import '../../../../shared/presentation/widgets/app_toast.dart';
import '../../../../shared/presentation/widgets/circular_loading_indicator.dart';
import '../widgets/instruction_item.dart';
import '../../../../core/localization/app_localizations.dart';

class DoctorScanQrPage extends ConsumerStatefulWidget {
  const DoctorScanQrPage({super.key});

  @override
  ConsumerState<DoctorScanQrPage> createState() => _DoctorScanQrPageState();
}

class _DoctorScanQrPageState extends ConsumerState<DoctorScanQrPage> {
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
        child: CircularLoadingIndicator(size: 32, color: AppColors.redDeep),
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
        role: UserRole.doctor,
      );
    }
  }

  Future<void> _handleDetectedCode(String rawValue) async {
    if (_isHandlingScan) return;
    _isHandlingScan = true;

    await _scannerController.stop();

    if (!mounted) return;

    // Extract the actual patient UID from the QR payload.
    // The QR stores JSON: {"uid": "<firestore_uid>", "role": "patient"}
    // Fallback: if rawValue is not valid JSON, treat it as a bare UID.
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
        child: CircularLoadingIndicator(size: 32, color: AppColors.redDeep),
      ),
    );

    try {
      final dio = await DioFactory.getDio();
      
      // Parse code to int if backend expects integer ID
      final patientId = int.tryParse(code) ?? code;

      final response = await dio.post(
        ApiConstants.doctorPatients,
        data: {'patient_id': patientId},
      );

      // Dismiss loading indicator
      if (mounted) Navigator.of(context).pop();

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        if (!mounted) return;
        AppToast.show(
          context,
          'Patient linked successfully'.tr(context),
          type: AppToastType.success,
          role: UserRole.doctor,
        );
      } else {
        if (!mounted) return;
        AppToast.show(
          context,
          'Failed to connect patient'.tr(context),
          type: AppToastType.error,
          role: UserRole.doctor,
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop(); // dismiss loading
      if (mounted) {
        AppToast.show(
          context,
          '${'Error connecting patient:'.tr(context)} $e',
          type: AppToastType.error,
          role: UserRole.doctor,
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
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBarControls(
                  isDarkMode: _isDarkMode,
                  onDarkModeToggle: () {
                    setState(() {
                      _isDarkMode = !_isDarkMode;
                    });
                  },
                  onLanguageSelect: () {},
                  darkModeToggleLightColor: AppColors.pinkLight,
                  darkModeToggleDarkColor: AppColors.redDeep,
                ),
                SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: SizedBox(
                      width: maxContentWidth,
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 45),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                AppImages.frameOfQrcode,
                                fit: BoxFit.contain,
                                opacity: const AlwaysStoppedAnimation(0.95),
                              ),
                              SizedBox(
                                width: double.infinity,
                                height: 310,
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: MobileScanner(
                                        controller: _scannerController,
                                        onDetect: (capture) {
                                          final rawValue = capture
                                              .barcodes
                                              .firstOrNull
                                              ?.rawValue;
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
                                                color: AppColors.redDarkest,
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
                            'Please place the patient\'s QR code directly under the camera lens so that it appears clearly within the scanning frame'
                                .tr(context),
                            style: AppTextStyles.robotoBlack14Regular,
                          ),
                          const SizedBox(height: 20),
                          InstructionItem(
                            text: 'Make sure the lighting is sufficient'.tr(
                              context,
                            ),
                          ),
                          const SizedBox(height: 15),
                          InstructionItem(
                            text: 'The camera lens is clean.'.tr(context),
                          ),
                          const SizedBox(height: 15),
                          InstructionItem(
                            text:
                                'Tap the Scan button to begin reading the QR code.'
                                    .tr(context),
                          ),
                          const SizedBox(height: 37),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 56,
                                  child: Material(
                                    color: AppColors.redDeep,
                                    borderRadius: BorderRadius.circular(20),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () async {
                                        await _scannerController.start();
                                      },
                                      child: Center(
                                        child: Text(
                                          'Scan'.tr(context),
                                          style: AppTextStyles
                                              .doctorActionTextRedSurface27ExtraBold
                                              .copyWith(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Center(
                                  child: SizedBox(
                                    height: 56,
                                    child: OutlinedButton.icon(
                                      icon: const Icon(
                                        Icons.photo_library_outlined,
                                        size: 20,
                                      ),
                                      label: Center(
                                        child: Text(
                                          'Scan Image'.tr(context),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: AppTextStyles.isArabic
                                                ? 'Cairo'
                                                : 'Poppins',
                                          ),
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.redDeep,
                                        side: const BorderSide(
                                          color: AppColors.redDeep,
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                      onPressed: _scanImageFromGallery,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 37),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
