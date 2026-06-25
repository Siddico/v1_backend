import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/enums/user_role.dart';
import '../../../../../core/services/local_notification_service.dart';
import '../../../../../shared/presentation/widgets/app_toast.dart';
import '../../../../../shared/presentation/widgets/circular_loading_indicator.dart';

import '../../../../../shared/data/datasources/medication_remote_datasource.dart';

class ProfileMedsTab extends StatefulWidget {
  const ProfileMedsTab({super.key});

  @override
  State<ProfileMedsTab> createState() => _ProfileMedsTabState();
}

class _ProfileMedsTabState extends State<ProfileMedsTab> {
  List<Map<String, dynamic>> _meds = [];
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchMedications();
  }

  Future<void> _fetchMedications() async {
    setState(() => _isLoading = true);
    try {
      final fetched = await MedicationRemoteDataSource.getMedications();
      setState(() {
        _meds = fetched.map((e) {
          int hour = 8;
          int minute = 0;
          if (e['reminder_time'] != null) {
            final parts = e['reminder_time'].toString().split(':');
            if (parts.length >= 2) {
              hour = int.tryParse(parts[0]) ?? 8;
              minute = int.tryParse(parts[1]) ?? 0;
            }
          }
          return {
            'id': e['id']?.toString() ?? '',
            'name': e['name'] ?? 'Unknown',
            'hour': hour,
            'minute': minute,
            'imageUrl': e['image_url'], // Optional
          };
        }).toList();
      });
    } catch (e) {
      debugPrint('Failed to load medications: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String?> _uploadImageToCloudinary(File imageFile, String uid) async {
    try {
      final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
      const String uploadPreset = 'grad_storage';
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );
      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = uploadPreset;
      request.fields['public_id'] =
          'medication_${uid}_${DateTime.now().millisecondsSinceEpoch}';
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['secure_url'] as String;
      }
    } catch (e) {
      debugPrint('Cloudinary upload error: $e');
    }
    return null;
  }

  void _showAddEditBottomSheet({Map<String, dynamic>? medDoc}) {
    final bool isEdit = medDoc != null;
    final Map<String, dynamic>? data = medDoc;

    final TextEditingController nameController = TextEditingController(
      text: data?['name'] ?? '',
    );
    TimeOfDay selectedTime = isEdit
        ? TimeOfDay(hour: data?['hour'] ?? 8, minute: data?['minute'] ?? 0)
        : const TimeOfDay(hour: 8, minute: 0);

    File? localImageFile;
    String? currentImageUrl = data?['imageUrl'];
    bool isUploadingImage = false;

    final isArabic = AppTextStyles.isArabic;
    final font = isArabic ? 'Cairo' : 'Poppins';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            String formatTimeOfDay(TimeOfDay time) {
              final localizations = MaterialLocalizations.of(ctx);
              return localizations.formatTimeOfDay(
                time,
                alwaysUse24HourFormat: false,
              );
            }

            Future<void> pickImage(ImageSource source) async {
              try {
                final pickedFile = await _picker.pickImage(
                  source: source,
                  imageQuality: 70,
                );
                if (pickedFile != null) {
                  setSheetState(() {
                    localImageFile = File(pickedFile.path);
                  });
                }
              } catch (e) {
                debugPrint('Image picker error: $e');
              }
            }

            Future<void> onSave() async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                AppToast.show(
                  ctx,
                  'Please enter medication name'.tr(ctx),
                  type: AppToastType.warning,
                  role: UserRole.patient,
                  translate: false,
                );
                return;
              }

              setSheetState(() => _isSaving = true);

              final uid = 'mock_uid';
              String? finalImageUrl = currentImageUrl;

              if (localImageFile != null) {
                setSheetState(() => isUploadingImage = true);
                final uploadedUrl = await _uploadImageToCloudinary(
                  localImageFile!,
                  uid,
                );
                if (uploadedUrl != null) finalImageUrl = uploadedUrl;
                setSheetState(() => isUploadingImage = false);
              }

              final int notificationId =
                  data?['notificationId'] ??
                  DateTime.now().millisecondsSinceEpoch.hashCode;

              final Map<String, dynamic> payload = {
                'id': isEdit
                    ? medDoc!['id']
                    : Random().nextInt(10000).toString(),
                'name': name,
                'hour': selectedTime.hour,
                'minute': selectedTime.minute,
                'imageUrl': finalImageUrl,
                'notificationId': notificationId,
              };

              try {
                final reminderStr = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
                
                if (isEdit) {
                  await MedicationRemoteDataSource.updateMedication(
                    id: int.parse(medDoc!['id']),
                    name: name,
                    dosage: '1', // default for now
                    isActive: true,
                  );
                } else {
                  await MedicationRemoteDataSource.addMedication(
                    name: name,
                    dosage: '1',
                    frequency: 'Daily',
                    reminderTime: reminderStr,
                  );
                }

                await _fetchMedications(); // Refresh data

                await LocalNotificationService.instance
                    .scheduleDailyNotification(
                      id: notificationId,
                      title: isArabic ? 'موعد دواء' : 'Medication Time',
                      // ignore: use_build_context_synchronously
                      body: '${'Time to take your medication:'.tr(ctx)} $name',
                      firestoreTitle: 'Medication Time',
                      firestoreBody: 'Time to take your medication: $name',
                      hour: selectedTime.hour,
                      minute: selectedTime.minute,
                      payload: '{"type": "medication"}',
                    );

                if (mounted) {
                  // ignore: use_build_context_synchronously
                  Navigator.of(sheetContext).pop();
                  AppToast.show(
                    context,
                    isEdit
                        ? 'Medication updated successfully'.tr(context)
                        : 'Medication added successfully'.tr(context),
                    type: AppToastType.success,
                    role: UserRole.patient,
                    translate: false,
                  );
                }
              } catch (e) {
                AppToast.show(
                  // ignore: use_build_context_synchronously
                  ctx,
                  // ignore: use_build_context_synchronously
                  'Failed to save medication'.tr(ctx),
                  type: AppToastType.error,
                  translate: false,
                );
              } finally {
                setSheetState(() => _isSaving = false);
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 4),
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Header gradient banner
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0FB39E), Color(0xFF0A8F7E)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.medication_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            isEdit
                                ? 'Edit Medication'.tr(ctx)
                                : 'Add Medication'.tr(ctx),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: font,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Form fields
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Medication name field
                          TextField(
                            controller: nameController,
                            style: TextStyle(
                              fontFamily: font,
                              fontSize: 14,
                              color: AppColors.neutral900,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Medication Name'.tr(ctx),
                              labelStyle: TextStyle(
                                color: AppColors.tealP,
                                fontFamily: font,
                                fontSize: 13,
                              ),
                              prefixIcon: const Icon(
                                Icons.medical_information_outlined,
                                color: AppColors.tealP,
                                size: 20,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF3FAFB),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: AppColors.tealP,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Time selector
                          GestureDetector(
                            onTap: () async {
                              final TimeOfDay? time = await showTimePicker(
                                context: ctx,
                                initialTime: selectedTime,
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: AppColors.tealP,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (time != null) {
                                setSheetState(() => selectedTime = time);
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3FAFB),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    color: AppColors.tealP,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Dose Time:'.tr(ctx),
                                      style: TextStyle(
                                        color: AppColors.tealP,
                                        fontFamily: font,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.tealP,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      formatTimeOfDay(selectedTime),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: font,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Photo section
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Medication Photo (Optional)'.tr(ctx),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontFamily: font,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Image preview
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: localImageFile != null
                                    ? Image.file(
                                        localImageFile!,
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                      )
                                    : currentImageUrl != null
                                    ? Image.network(
                                        currentImageUrl,
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: AppColors.tealSurface,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.medication_rounded,
                                          color: AppColors.tealP,
                                          size: 28,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Pick photo buttons
                          Row(
                            children: [
                              Expanded(
                                child: _PhotoPickButton(
                                  icon: Icons.camera_alt_outlined,
                                  label: 'Camera'.tr(ctx),
                                  font: font,
                                  onTap: () => pickImage(ImageSource.camera),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _PhotoPickButton(
                                  icon: Icons.photo_library_outlined,
                                  label: 'Gallery'.tr(ctx),
                                  font: font,
                                  onTap: () => pickImage(ImageSource.gallery),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _isSaving
                                      ? null
                                      : () => Navigator.of(sheetContext).pop(),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    side: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel'.tr(ctx),
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontFamily: font,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: _isSaving ? null : onSave,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.tealP,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: _isSaving || isUploadingImage
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          'Save'.tr(ctx),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: font,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteMedication(Map<String, dynamic> medDoc) async {
    final Map<String, dynamic>? data = medDoc;
    final int? notificationId = data?['notificationId'];
    final String name = data?['name'] ?? '';
    final isArabic = AppTextStyles.isArabic;
    final font = isArabic ? 'Cairo' : 'Poppins';

    final bool confirm =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              titlePadding: EdgeInsets.zero,
              title: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFECEE),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete_rounded,
                      color: Colors.red,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Delete Medication'.tr(ctx),
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontFamily: font,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              content: Text(
                '${'Are you sure you want to delete'.tr(ctx)} $name?',
                style: TextStyle(fontFamily: font, fontSize: 14),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(
                    'Cancel'.tr(ctx),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontFamily: font,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Delete'.tr(ctx),
                    style: TextStyle(color: Colors.white, fontFamily: font),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirm) return;

    try {
      final int medId = int.tryParse(medDoc['id'].toString()) ?? 0;
      if (medId != 0) {
        await MedicationRemoteDataSource.deleteMedication(medId);
      }
      
      setState(() {
        _meds.removeWhere((m) => m['id'] == medDoc['id']);
      });

      if (notificationId != null) {
        await LocalNotificationService.instance.cancelNotification(
          notificationId,
        );
      }

      if (mounted) {
        AppToast.show(
          context,
          'Medication deleted'.tr(context),
          type: AppToastType.success,
          role: UserRole.patient,
          translate: false,
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          'Failed to delete medication'.tr(context),
          type: AppToastType.error,
          translate: false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = AppTextStyles.isArabic;
    final font = isArabic ? 'Cairo' : 'Poppins';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Medications'.tr(context),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: font,
                  color: AppColors.tealPrimaryDark,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddEditBottomSheet(),
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: Text(
                  'Add'.tr(context),
                  style: TextStyle(color: Colors.white, fontFamily: font),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tealP,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          )
        else if (_meds.isEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.tealBorderLight.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.medication_liquid_rounded,
                  size: 48,
                  color: AppColors.tealP.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'No medications listed'.tr(context),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: font,
                    color: AppColors.tealPrimaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add your daily medications and schedule notifications so you never miss a dose.'
                      .tr(context),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontFamily: font,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// A styled photo picker button
class _PhotoPickButton extends StatelessWidget {
  const _PhotoPickButton({
    required this.icon,
    required this.label,
    required this.font,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String font;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3FAFB),
          border: Border.all(color: AppColors.tealBorderLight),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.tealP),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.tealPrimaryDark,
                fontWeight: FontWeight.w600,
                fontFamily: font,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
