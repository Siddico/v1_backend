import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../auth/presentation/controllers/auth_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:grad_imp_1/core/localization/app_localizations.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/presentation/widgets/user_qr_widget.dart';
import 'contact_info_tile.dart';
import 'doctor_avatar_panel.dart';
import 'doctor_stats_strip.dart';

class DoctorProfileContent extends ConsumerWidget {
  const DoctorProfileContent({super.key, 
    required this.displayName,
    required this.displayEmail,
    required this.displayPhone,
    required this.displayBio,
    required this.onAvatarEdit,
    required this.onLogout,
    this.photoUrl,
    this.specialist,
    this.yearsExperience,
    this.patientsCount,
    this.licenseNumber,
  });

  final String displayName;
  final String displayEmail;
  final String displayPhone;
  final String displayBio;
  final VoidCallback onAvatarEdit;
  final VoidCallback onLogout;
  final String? photoUrl;
  final String? specialist;
  final String? yearsExperience;
  final String? patientsCount;
  final String? licenseNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DoctorAvatarPanel(
          showIdentity: true,
          displayName: displayName,
          onAvatarEdit: onAvatarEdit,
          photoUrl: photoUrl,
          specialist: specialist,
          child: DoctorStatsStrip(
            yearsExperience: yearsExperience ?? '',
            patientsCount: patientsCount ?? '',
            licenseNumber: licenseNumber ?? '',
          ),
        ),
        const SizedBox(height: 34),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              displayBio.isNotEmpty
                  ? displayBio
                  : 'No bio description provided yet.'.tr(context),
              style: AppTextStyles.doctorProfileBioBlackNeutral16Regular,
            ),
          ),
        ),
        const SizedBox(height: 28),
        ContactInfoTile(icon: Icons.phone_outlined, value: displayPhone),
        const SizedBox(height: 15),
        ContactInfoTile(icon: Icons.email_outlined, value: displayEmail),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 61,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.info_outline_rounded, color: AppColors.white, size: 20),
                    label: Text(
                      'About Us'.tr(context),
                      style: TextStyle(
                        fontSize: 14, 
                        fontWeight: FontWeight.w700,
                        fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Inter',
                      ),
                    ),
                    onPressed: () => context.push(AppConstants.routeDoctorAboutUs),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      backgroundColor: AppColors.redDeep,
                      foregroundColor: AppColors.white,
                      elevation: 3,
                      shadowColor: AppColors.shadowBlack25,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 61,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code_rounded, color: AppColors.white, size: 20),
                    label: Text(
                      'My QR Code'.tr(context),
                      style: TextStyle(
                        fontSize: 14, 
                        fontWeight: FontWeight.w700,
                        fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Inter',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: () => _showQrDialog(context, ref),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      backgroundColor: AppColors.redDeep,
                      foregroundColor: AppColors.white,
                      elevation: 3,
                      shadowColor: AppColors.shadowBlack25,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 201,
          height: 61,
          child: OutlinedButton(
            onPressed: onLogout,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(width: 1, color: AppColors.redDeep),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              elevation: 3,
              shadowColor: AppColors.shadowBlack25,
              backgroundColor: AppColors.white,
            ),
            child: Text(
              'Log-out'.tr(context),
              style: AppTextStyles.doctorActionTextRedDeep27ExtraBold,
            ),
          ),
        ),
        const SizedBox(height: 120),
      ],
    );
  }

  void _showQrDialog(BuildContext context, WidgetRef ref) {
    final uid = ref.read(authStateProvider).valueOrNull?.id;
    if (uid == null) return;
    final qrData = jsonEncode({'uid': uid, 'role': 'doctor'});
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return QrShareDialog(qrData: qrData, qrColor: AppColors.redAccent);
      },
    );
  }
}
