import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grad_imp_1/core/localization/app_localizations.dart';
import 'dart:async';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/enums/user_role.dart';
import '../../domain/entities/upload_file_entity.dart';
import '../controllers/patient_upload_providers.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../../../core/services/emergency_call_service.dart';
import '../../../../shared/presentation/widgets/app_bar_controls.dart';
import '../../../../shared/presentation/widgets/app_toast.dart';
import '../../../../shared/presentation/widgets/bottom_background_circles.dart';
import '../../../../shared/presentation/widgets/circular_loading_indicator.dart';
import '../widgets/upload_files/upload_action_buttons.dart';
import '../widgets/upload_files/upload_drop_area.dart';
import '../widgets/upload_files/upload_header.dart';
import '../widgets/upload_files/upload_help_section.dart';
import '../widgets/upload_files/upload_progress_section.dart';
import '../widgets/upload_files/upload_step_indicator.dart';

class UploadFilesPage extends ConsumerStatefulWidget {
  const UploadFilesPage({super.key});

  @override
  ConsumerState<UploadFilesPage> createState() => _UploadFilesPageState();
}

class _UploadFilesPageState extends ConsumerState<UploadFilesPage> {
  static const Set<String> _supportedExtensions = {
    'jpg',
    'jpeg',
    'png',
    'pdf',
    'csv',
    'txt',
    'mat',
  };

  bool _isDarkMode = false;
  bool _isSubmitting = false;
  int _currentStep = 1;
  List<UploadFileItem> _step1Files = const [];
  List<UploadFileItem> _step2Files = const [];
  List<UploadFileItem> _step3Files = const [];
  List<UploadFileItem> _step4Files = const [];
  List<PlatformFile> _step1RawFiles = const [];
  List<PlatformFile> _step2RawFiles = const [];
  List<PlatformFile> _step3RawFiles = const [];
  List<PlatformFile> _step4RawFiles = const [];

  List<UploadFileItem> get _currentStepFiles {
    switch (_currentStep) {
      case 1:
        return _step1Files;
      case 2:
        return _step2Files;
      case 3:
        return _step3Files;
      case 4:
        return _step4Files;
      default:
        return const [];
    }
  }

  String _stepTitle(BuildContext context) {
    if (_currentStep == 1) {
      return 'Upload ECG Signals'.tr(context);
    }
    if (_currentStep == 2) {
      return 'Upload PPG Signals'.tr(context);
    }
    if (_currentStep == 3) {
      return 'Upload Prescription'.tr(context);
    }
    return 'Upload AI PPG (.mat)'.tr(context);
  }

  String _primaryButtonText(BuildContext context) {
    return _currentStep == 4 ? 'Submit'.tr(context) : 'Next'.tr(context);
  }

  Future<void> _onPickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result == null || result.files.isEmpty || !mounted) {
      return;
    }

    final pickedFiles = result.files.map(_mapPickedFile).toList();
    final validFiles = result.files.where((file) {
      final extension = _fileExtension(file.name);
      final isSupported = _supportedExtensions.contains(extension);
      final isTooLarge = file.size > 10 * 1024 * 1024;
      return isSupported && !isTooLarge;
    }).toList();

    setState(() {
      _replaceCurrentStepFiles([..._currentStepFiles, ...pickedFiles]);
      _replaceCurrentStepRawFiles([..._currentStepRawFiles, ...validFiles]);
    });
  }

  UploadFileItem _mapPickedFile(PlatformFile file) {
    final extension = _fileExtension(file.name);
    final isSupported = _supportedExtensions.contains(extension);
    final isTooLarge = file.size > 10 * 1024 * 1024;
    final isValid = isSupported && !isTooLarge;

    return UploadFileItem(
      name: file.name,
      status: isValid ? UploadFileStatus.success : UploadFileStatus.error,
      progress: isValid ? 1 : 0,
      message: isValid
          ? 'Added successfully'
          : isTooLarge
          ? 'File is too large. Max size is 10 MB.'
          : 'Unsupported file format. Use JPG, JPEG, PNG, PDF, CSV, TXT, or MAT.',
    );
  }

  String _fileExtension(String name) {
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == name.length - 1) {
      return '';
    }

    return name.substring(dotIndex + 1).toLowerCase();
  }

  void _replaceCurrentStepFiles(List<UploadFileItem> files) {
    switch (_currentStep) {
      case 1:
        _step1Files = files;
        break;
      case 2:
        _step2Files = files;
        break;
      case 3:
        _step3Files = files;
        break;
      case 4:
        _step4Files = files;
        break;
    }
  }

  List<PlatformFile> get _currentStepRawFiles {
    switch (_currentStep) {
      case 1:
        return _step1RawFiles;
      case 2:
        return _step2RawFiles;
      case 3:
        return _step3RawFiles;
      case 4:
        return _step4RawFiles;
      default:
        return const [];
    }
  }

  void _replaceCurrentStepRawFiles(List<PlatformFile> files) {
    switch (_currentStep) {
      case 1:
        _step1RawFiles = files;
        break;
      case 2:
        _step2RawFiles = files;
        break;
      case 3:
        _step3RawFiles = files;
        break;
      case 4:
        _step4RawFiles = files;
        break;
    }
  }

  void _onClearCurrentStepFiles() {
    setState(() {
      _replaceCurrentStepFiles(const []);
      _replaceCurrentStepRawFiles(const []);
    });
  }

  Future<void> _onNextStep() async {
    if (_isSubmitting) {
      return;
    }

    if (_currentStep < 4) {
      setState(() {
        _currentStep += 1;
      });
      return;
    }

    await _submitAllSteps();
  }

  Future<void> _submitAllSteps() async {
    final lang = Localizations.localeOf(context).languageCode;
    final isArabic = lang == 'ar';

    final hasAnyFile =
        _step1RawFiles.isNotEmpty ||
        _step2RawFiles.isNotEmpty ||
        _step3RawFiles.isNotEmpty ||
        _step4RawFiles.isNotEmpty;

    if (!hasAnyFile) {
      AppToast.show(
        context,
        'Please add at least one file before submitting.'.tr(context),
        type: AppToastType.warning,
        role: UserRole.patient,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final uploadNotifier = ref.read(patientUploadControllerProvider.notifier);
      await uploadNotifier.uploadCategoryFiles(
        category: 'ecg_signals',
        files: _step1RawFiles,
      );
      await uploadNotifier.uploadCategoryFiles(
        category: 'ppg_signals',
        files: _step2RawFiles,
      );
      await uploadNotifier.uploadCategoryFiles(
        category: 'prescription',
        files: _step3RawFiles,
      );

      // Save the .mat files to Firebase/Cloudinary so the doctor can view them
      await uploadNotifier.uploadCategoryFiles(
        category: 'ppg_ai_signals',
        files: _step4RawFiles,
      );

      // Also send them to the Node.js backend for AI prediction
      bool isCriticalFound = false;
      for (final file in _step4RawFiles) {
        final result = await uploadNotifier.uploadAIPredictionFile(file);

        final data = result['data'];
        if (data != null && data['risk_score'] != null) {
          final riskScore = (data['risk_score'] as num).toDouble();
          if (riskScore > 60) {
            isCriticalFound = true;
          }
        }
      }

      final authState = ref.read(authStateProvider);
      final userId = authState.valueOrNull?.id;
      final isDoctor = authState.valueOrNull?.role == UserRole.doctor;

      if (isCriticalFound && userId != null && !isDoctor) {
        EmergencyCallService.instance.checkAndCallIfCritical(
          userId: userId,
          isCritical: true,
        );
      }

      if (!mounted) {
        return;
      }

      AppToast.show(
        context,
        'Files uploaded successfully.'.tr(context),
        type: AppToastType.success,
        role: UserRole.patient,
      );
      context.pushReplacement(AppConstants.routeHome);
    } on FormatException catch (e) {
      if (!mounted) {
        return;
      }
      AppToast.show(
        context,
        isArabic ? 'صيغة غير صحيحة: ${e.message}' : e.message,
        type: AppToastType.error,
        role: UserRole.patient,
      );
    } on TimeoutException {
      if (!mounted) {
        return;
      }
      AppToast.show(
        context,
        isArabic ? 'انتهت مهلة الاتصال. يرجى التحقق من الإنترنت.' : 'Connection timeout. Please check your internet connection.',
        type: AppToastType.error,
        role: UserRole.patient,
        translate: false,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      AppToast.show(
        context,
        isArabic ? 'فشل الرفع: $e' : 'Upload failed: $e',
        type: AppToastType.error,
        role: UserRole.patient,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _onBackStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  void _onSkipStep() {
    _onNextStep();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: IgnorePointer(child: BottomBackgroundCircles()),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric().copyWith(bottom: 140),
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
                          darkModeToggleLightColor: AppColors.tealBorderLight,
                          darkModeToggleDarkColor: AppColors.tealP,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              UploadHeader(
                                title: _stepTitle(context),
                                onSkip: _onSkipStep,
                              ),
                              const SizedBox(height: 40),
                              UploadDropArea(
                                onFilePick: _onPickFiles,
                                supportedFormatsText:
                                    'Supported formats: JPG, JPEG, PNG, PDF, CSV, TXT, MAT'
                                        .tr(context),
                              ),
                              const SizedBox(height: 25),
                              const UploadHelpSection(),
                              if (_currentStepFiles.isNotEmpty) ...[
                                const SizedBox(height: 30),
                                UploadProgressSection(
                                  files: _currentStepFiles,
                                  onClear: _onClearCurrentStepFiles,
                                ),
                              ],
                              const SizedBox(height: 33),
                              Center(
                                child: UploadStepIndicator(
                                  currentStep: _currentStep,
                                ),
                              ),
                              const SizedBox(height: 36),
                              UploadActionButtons(
                                showBack: _currentStep > 1,
                                primaryButtonText: _isSubmitting
                                    ? 'Uploading...'.tr(context)
                                    : _primaryButtonText(context),
                                onNext: _onNextStep,
                                onBack: _onBackStep,
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isSubmitting)
                    Positioned.fill(
                      child: Container(
                        color: AppColors.shadowBlack25,
                        child: const Center(
                          child: CircularLoadingIndicator(
                            size: 72,
                            color: AppColors.tealPrimaryDark,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
