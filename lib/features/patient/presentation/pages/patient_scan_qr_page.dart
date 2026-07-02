import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grad_imp_1/shared/presentation/widgets/circular_loading_indicator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:grad_imp_1/core/networking/api_constants.dart';
import 'package:grad_imp_1/core/networking/dio_factory.dart';
import 'package:grad_imp_1/core/networking/token_storage.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/presentation/widgets/app_bar_controls.dart';
import '../../../../shared/presentation/widgets/app_toast.dart';
import '../../../doctor/presentation/widgets/instruction_item.dart';
import '../../../requests/request_doctor_dialog.dart';
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularLoadingIndicator(size: 24, color: AppColors.tealP),
      ),
    );

    try {
      final dio = await DioFactory.getDio();
      final token = await TokenStorage.getToken();
      final response = await dio.post(
        ApiConstants.patientQr,
        data: {'qr_data': rawValue},
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (mounted) Navigator.of(context).pop();

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final data = response.data['data'];
        if (data['type'] == 'doctor') {
          final doctor = data['doctor'];
          final status = data['connection_status'];
          if (mounted) {
            _showDoctorInfoCard(doctor, status);
          }
        } else {
          if (mounted) {
            AppToast.show(
              context,
              'Invalid QR code type.'.tr(context),
              type: AppToastType.error,
              role: UserRole.patient,
            );
          }
        }
      } else {
        if (mounted) {
          AppToast.show(
            context,
            'Failed to process QR code.'.tr(context),
            type: AppToastType.error,
            role: UserRole.patient,
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
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
        if (!_isShowingDialog) {
          await _scannerController.start();
        }
      }
    }
  }

  bool _isShowingDialog = false;

  void _showDoctorInfoCard(Map<String, dynamic> doctor, String status) {
    _isShowingDialog = true;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: doctor['photo_url'] != null
                    ? NetworkImage(doctor['photo_url'])
                    : null,
                child: doctor['photo_url'] == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                doctor['full_name'] ?? 'Doctor',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${doctor['specialty'] ?? ''} - ${doctor['hospital'] ?? ''}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              if (status == 'none')
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tealP,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (ctx) => RequestDoctorDialog(
                        doctorId: doctor['id'].toString(),
                      ),
                    ).then((_) {
                      _scannerController.start();
                    });
                  },
                  child: Text(
                    'Send Request'.tr(context),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: null,
                  child: Text(
                    status == 'pending'
                        ? 'Request Already Sent'.tr(context)
                        : 'Already Connected'.tr(context),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      _isShowingDialog = false;
      _scannerController.start();
    });
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
