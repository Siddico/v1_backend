import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/networking/api_constants.dart';
import 'package:grad_imp_1/core/networking/dio_factory.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grad_imp_1/shared/presentation/widgets/circular_loading_indicator.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/enums/gender.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../../../shared/ui/toast_service.dart';
import 'package:grad_imp_1/core/networking/token_storage.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// Full-featured patient edit-profile page.
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _emergencyCtrl = TextEditingController();
  final _medicalHistoryCtrl = TextEditingController();

  Gender? _selectedGender;
  File? _selectedImage;
  String? _existingPhotoUrl;
  bool _isLoading = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  Future<void> _loadUserData() async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get(ApiConstants.patientProfile);
      
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300 && mounted) {
        final rawData = response.data['data'] as Map<String, dynamic>? ?? {};
        final data = rawData['profile'] as Map<String, dynamic>? ??
            rawData['patient_profile'] as Map<String, dynamic>? ??
            rawData;

        setState(() {
          _nameCtrl.text =
              data['full_name']?.toString() ?? data['fullName']?.toString() ?? data['name']?.toString() ?? '';
          _phoneCtrl.text = data['phone']?.toString() ?? '';
          
          if (data['age'] != null && data['age'].toString() != '0') {
            _ageCtrl.text = data['age'].toString();
            final ageVal = int.tryParse(data['age'].toString()) ?? 0;
            if (ageVal > 0) {
              _dobCtrl.text = '${DateTime.now().year - ageVal}-01-01';
            }
          }
          if (data['date_of_birth'] != null && data['date_of_birth'].toString().isNotEmpty && data['date_of_birth'].toString() != 'null') {
            _dobCtrl.text = data['date_of_birth'].toString();
          }

          if (data['weight'] != null && data['weight'].toString() != 'null') {
            _weightCtrl.text = data['weight'].toString();
          }
          if (data['emergency_number'] != null && data['emergency_number'].toString() != 'null') {
            _emergencyCtrl.text = data['emergency_number'].toString();
          }
          if (data['medical_history'] != null && data['medical_history'].toString() != 'null') {
            _medicalHistoryCtrl.text = data['medical_history'].toString();
          }
          
          _existingPhotoUrl = rawData['image_url']?.toString() ??
              data['image_url']?.toString() ??
              data['photo_url']?.toString() ??
              data['image']?.toString();
          
          final genderStr = data['gender']?.toString();
          if (genderStr != null) {
            _selectedGender = genderStr.toLowerCase() == 'female'
                ? Gender.female
                : Gender.male;
          }
          _loaded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError('Failed to load profile data.'.tr(context));
      }
    }
  }

  Future<void> _pickImage() async {
    final xFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (xFile != null && mounted) {
      setState(() => _selectedImage = File(xFile.path));
    }
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 30),
      firstDate: DateTime(1920),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.tealP,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dobCtrl.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    ToastService.showInfo('Saving your profile…'.tr(context));

    try {
      final dio = await DioFactory.getDio();
      final token = await TokenStorage.getToken();

      final formDataMap = <String, dynamic>{
        'full_name': _nameCtrl.text.trim(),
        if (_ageCtrl.text.isNotEmpty)
          'age': int.tryParse(_ageCtrl.text.trim()) ?? _ageCtrl.text.trim()
        else if (_dobCtrl.text.isNotEmpty)
          'age': DateTime.now().year - int.parse(_dobCtrl.text.split('-').first),
        if (_weightCtrl.text.isNotEmpty)
          'weight': double.tryParse(_weightCtrl.text.trim()) ?? _weightCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        if (_selectedGender != null) 'gender': _selectedGender!.name.toLowerCase(),
        if (_emergencyCtrl.text.isNotEmpty) 'emergency_number': _emergencyCtrl.text.trim(),
        if (_medicalHistoryCtrl.text.isNotEmpty) 'medical_history': _medicalHistoryCtrl.text.trim(),
      };

      final formData = FormData.fromMap(formDataMap);

      if (_selectedImage != null) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(_selectedImage!.path, filename: 'profile.png'),
        ));
      }

      await dio.post(
        ApiConstants.patientProfile,
        data: formData,
        options: Options(headers: {
           if (token != null) 'Authorization': 'Bearer $token',
           'Accept': 'application/json',
        }),
      );

      // Refresh auth state so UI picks up new data.
      ref.invalidate(authStateProvider);

      if (mounted) {
        ToastService.showSuccess('Profile saved successfully! 🎉'.tr(context));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError('${'Error saving profile: '.tr(context)}$e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _emergencyCtrl.dispose();
    _medicalHistoryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine which image to show.
    final ImageProvider avatarProvider;
    if (_selectedImage != null) {
      avatarProvider = FileImage(_selectedImage!);
    } else if (_existingPhotoUrl != null && _existingPhotoUrl!.isNotEmpty) {
      avatarProvider = NetworkImage(_existingPhotoUrl!);
    } else {
      avatarProvider = const AssetImage('assets/images/patient.png');
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFA),
      body: CustomScrollView(
        slivers: [
          // ── Teal gradient app bar ──
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.tealP,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF0FB39E),
                      AppColors.tealP,
                      const Color(0xFF0A7A6B),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Avatar
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: avatarProvider,
                                fit: BoxFit.cover,
                              ),
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.tealP,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 14,
                                color: AppColors.tealP,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Edit Profile'.tr(context),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        fontFamily: AppTextStyles.isArabic
                            ? 'Cairo'
                            : 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          // ── Form body ──
          SliverToBoxAdapter(
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(
                      child: CircularLoadingIndicator(
                        size: 50,
                        color: AppColors.tealP,
                      ),
                    ),
                  )
                : !_loaded
                ? const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(
                      child: CircularLoadingIndicator(
                        size: 50,
                        color: AppColors.tealP,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel('Personal Information'.tr(context)),
                          const SizedBox(height: 14),
                          _buildField(
                            controller: _nameCtrl,
                            label: 'Full Name'.tr(context),
                            icon: Icons.person_outline,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Full name is required'.tr(context)
                                : null,
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            controller: _phoneCtrl,
                            label: 'Phone Number'.tr(context),
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 14),
                          // Date of birth
                          _ReadOnlyField(
                            controller: _dobCtrl,
                            label: 'Date of Birth'.tr(context),
                            icon: Icons.cake_outlined,
                            hint: 'YYYY-MM-DD',
                            onTap: _pickDob,
                          ),
                          const SizedBox(height: 14),
                          // Gender picker
                          _GenderSelector(
                            selected: _selectedGender,
                            onChanged: (g) =>
                                setState(() => _selectedGender = g),
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            controller: _ageCtrl,
                            label: 'Age'.tr(context),
                            icon: Icons.calendar_today_outlined,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            controller: _weightCtrl,
                            label: 'Weight (kg)'.tr(context),
                            icon: Icons.monitor_weight_outlined,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            controller: _emergencyCtrl,
                            label: 'Emergency Number'.tr(context),
                            icon: Icons.contact_emergency_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            controller: _medicalHistoryCtrl,
                            label: 'Medical History'.tr(context),
                            icon: Icons.medical_services_outlined,
                          ),
                          const SizedBox(height: 36),
                          // Save button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.tealP,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shadowColor: AppColors.tealP.withValues(
                                  alpha: 0.4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'Save Changes'.tr(context),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4,
                                  fontFamily: AppTextStyles.isArabic
                                      ? 'Cairo'
                                      : 'Poppins',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
      ),
      decoration: _inputDecoration(label: label, icon: icon),
    );
  }
}

// ── Small helpers ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.tealP,
        letterSpacing: 0.8,
        fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String hint;
  final VoidCallback onTap;

  const _ReadOnlyField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
      ),
      decoration: _inputDecoration(
        label: label,
        icon: icon,
        hint: hint,
        trailing: const Icon(
          Icons.calendar_today_outlined,
          size: 18,
          color: AppColors.tealP,
        ),
      ),
    );
  }
}

class _GenderSelector extends StatelessWidget {
  final Gender? selected;
  final ValueChanged<Gender?> onChanged;

  const _GenderSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Gender'.tr(context),
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
              fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
            ),
          ),
        ),
        Row(
          children: [
            _GenderChip(
              label: 'Male'.tr(context),
              icon: Icons.male,
              isSelected: selected == Gender.male,
              onTap: () => onChanged(Gender.male),
            ),
            const SizedBox(width: 12),
            _GenderChip(
              label: 'Female'.tr(context),
              icon: Icons.female,
              isSelected: selected == Gender.female,
              onTap: () => onChanged(Gender.female),
            ),
          ],
        ),
      ],
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.tealP : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.tealP : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.tealP.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey.shade500,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration({
  required String label,
  required IconData icon,
  String? hint,
  Widget? trailing,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon, color: AppColors.tealP, size: 20),
    suffixIcon: trailing,
    labelStyle: TextStyle(
      color: Colors.grey.shade600,
      fontSize: 14,
      fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.tealP, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
    ),
  );
}

extension StringExtension on String {
  String capitalize() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : '';
}
