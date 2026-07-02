import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grad_imp_1/core/networking/api_constants.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:grad_imp_1/core/networking/dio_factory.dart';
import 'package:grad_imp_1/core/networking/token_storage.dart';

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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularLoadingIndicator(size: 32, color: AppColors.redDeep),
      ),
    );

    try {
      final dio = await DioFactory.getDio();
      final token = await TokenStorage.getToken();
      final response = await dio.post(
        ApiConstants.doctorScanQr,
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
        if (data['type'] == 'patient') {
          final patient = data['patient'];
          final isConnected = data['is_connected'] ?? false;
          if (mounted) {
            _showPatientInfoCard(patient, isConnected);
          }
        } else {
          if (mounted)
            AppToast.show(
              context,
              'Invalid QR code type.',
              type: AppToastType.error,
              role: UserRole.doctor,
            );
        }
      } else {
        if (mounted)
          AppToast.show(
            context,
            'Failed to process QR',
            type: AppToastType.error,
            role: UserRole.doctor,
          );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted)
        AppToast.show(
          context,
          'Error checking QR: $e',
          type: AppToastType.error,
          role: UserRole.doctor,
        );
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

  void _showPatientInfoCard(Map<String, dynamic> patient, bool isConnected) {
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
                backgroundImage: patient['photo_url'] != null
                    ? NetworkImage(patient['photo_url'])
                    : null,
                child: patient['photo_url'] == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                patient['full_name'] ?? 'Patient',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Age: ${patient['age'] ?? 'N/A'} - Blood Type: ${patient['blood_type'] ?? 'N/A'}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              if (!isConnected)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redDeep,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _addPatient(patient['id'].toString());
                  },
                  child: const Text(
                    'Add Patient',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: null,
                  child: const Text(
                    'Already in Your List',
                    style: TextStyle(color: Colors.white, fontSize: 16),
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

  Future<void> _addPatient(String patientId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularLoadingIndicator(size: 32, color: AppColors.redDeep),
      ),
    );

    try {
      final dio = await DioFactory.getDio();
      final token = await TokenStorage.getToken();
      final response = await dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.doctorPatients}',
        data: {'patient_id': patientId},
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
        if (mounted)
          AppToast.show(
            context,
            'Patient added to your list',
            type: AppToastType.success,
            role: UserRole.doctor,
          );
      } else {
        if (mounted)
          AppToast.show(
            context,
            'Failed to add patient',
            type: AppToastType.error,
            role: UserRole.doctor,
          );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted)
        AppToast.show(
          context,
          'Error adding patient: $e',
          type: AppToastType.error,
          role: UserRole.doctor,
        );
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
