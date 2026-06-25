import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:grad_imp_1/features/patient/presentation/controllers/patient_profile_providers.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/presentation/widgets/app_bar_controls.dart';
import '../../../../shared/presentation/widgets/app_toast.dart';
import '../widgets/doctor/contact_button.dart';
import '../widgets/doctor/doctor_details_view.dart';
import '../widgets/profile_components/section_title.dart';
import '../../../../shared/presentation/providers/chat_providers.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import 'patient_messages_page.dart';
import '../../../../core/localization/app_localizations.dart';

class DoctorDetailPage extends ConsumerStatefulWidget {
  const DoctorDetailPage({
    super.key,
    required this.name,
    required this.specialty,
    required this.doctorId,
  });

  final String name;
  final String specialty;
  final String doctorId;

  @override
  ConsumerState<DoctorDetailPage> createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends ConsumerState<DoctorDetailPage> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final doctorAsync = ref.watch(patientDetailsProvider(widget.doctorId));
    final doctorPhotoUrl = doctorAsync.valueOrNull?.photoUrl;
    // ignore: unused_local_variable
    final patientPhotoUrl =
        ref.watch(authControllerProvider).valueOrNull?.photoUrl ??
        ref.watch(authStateProvider).valueOrNull?.photoUrl;

    final doctorProfile = doctorAsync.valueOrNull?.doctorProfile;
    final yearsExperience =
        doctorProfile?['years_experience']?.toString() ?? '';
    final patientsCount = doctorProfile?['patients_count']?.toString() ?? '';
    final licenseNumber = doctorProfile?['license_number']?.toString() ?? '';
    final specialty =
        doctorProfile?['specialization']?.toString() ?? widget.specialty;
    final bio = doctorProfile?['bio']?.toString() ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: -34,
            child: Container(
              height: 264,
              decoration: BoxDecoration(
                color: AppColors.tealA,
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 135, 14, 120),
            child: Column(
              children: [
                DoctorHeaderCard(
                  name: widget.name,
                  specialty: specialty,
                  photoUrl: doctorPhotoUrl,
                  yearsExperience: yearsExperience,
                  patientsCount: patientsCount,
                  licenseNumber: licenseNumber,
                ),
                const SizedBox(height: 14),
                SectionTitle('About Doctor'.tr(context)),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: bio.isNotEmpty
                              ? bio
                              : 'With a caring and patient-centered approach, this doctor is committed to supporting the growth and health of every child. '
                                    .tr(context),
                          style: AppTextStyles
                              .patientDoctorDetailBodyBlackNeutral16Regular,
                        ),
                        if (bio.isEmpty) ...[
                          TextSpan(
                            text: 'Read more ..'.tr(context),
                            style: AppTextStyles
                                .patientDoctorDetailReadMoreTeal16Regular,
                          ),
                          TextSpan(
                            text: '.',
                            style: AppTextStyles
                                .patientDoctorDetailDotBlueDeep16Regular,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SectionTitle('Contacts'.tr(context)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    ContactButton(
                      iconAsset: AppImages.phoneLogoSvg,
                      onTap: () async {
                        AppToast.show(
                          context,
                          'Coming soon!'.tr(context),
                          type: AppToastType.info,
                          role: UserRole.patient,
                        );
                      },
                    ),
                    const SizedBox(width: 31),
                    ContactButton(
                      iconAsset: AppImages.messageLogoSvg,
                      onTap: () async {
                        final currentUserId =
                            ref.read(authControllerProvider).valueOrNull?.id ??
                            ref.read(authStateProvider).valueOrNull?.id ??
                            '';
                        final chatDS = ref.read(chatRemoteDataSourceProvider);

                        String? existingId = await chatDS
                            .getExistingConversation(
                              currentUserId,
                              widget.doctorId,
                            );
                        String conversationId;

                        if (existingId != null) {
                          conversationId = existingId;
                        } else {
                          // Show loading indicator for new conversation
                          showDialog(
                            // ignore: use_build_context_synchronously
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.tealP,
                              ),
                            ),
                          );

                          conversationId = await chatDS.getOrCreateConversation(
                            currentUserId,
                            widget.doctorId,
                          );

                          if (context.mounted) {
                            Navigator.pop(context); // dismiss loading
                          }
                        }

                        try {
                          // Navigate to chat
                          if (context.mounted) {
                            context.push(
                              AppConstants.routeMessages,
                              extra: PatientChatArgs(
                                contactName: widget.name,
                                contactImage:
                                    doctorPhotoUrl ?? AppImages.makramImage,
                                conversationId: conversationId,
                                otherId: widget.doctorId,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            Navigator.pop(context); // dismiss loading
                            AppToast.show(
                              context,
                              'Error starting conversation: $e',
                              type: AppToastType.error,
                              role: UserRole.patient,
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(width: 31),
                    ContactButton(
                      iconAsset: AppImages.videoCallIcon,
                      onTap: () async {
                        AppToast.show(
                          context,
                          'Coming soon!'.tr(context),
                          type: AppToastType.info,
                          role: UserRole.patient,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBarControls(
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
          ),
        ],
      ),
    );
  }
}
