import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grad_imp_1/core/localization/app_localizations.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';
import 'package:grad_imp_1/shared/presentation/widgets/app_bar_controls.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends ConsumerWidget {
  final bool isDoctor;

  const AboutUsPage({super.key, required this.isDoctor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeColor = isDoctor ? AppColors.redDeep : AppColors.tealP;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBarControls(
              isDarkMode: false,
              onDarkModeToggle: () {},
              onLanguageSelect: () {},
              languageTextColor: themeColor,
              darkModeToggleLightColor: isDoctor ? AppColors.pinkLight : AppColors.tealBorderLight,
              darkModeToggleDarkColor: isDoctor ? AppColors.redDeep : AppColors.tealP,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAboutCard(context, themeColor),
                  const SizedBox(height: 24),
                  Text(
                    'Our Team'.tr(context),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Inter',
                      color: themeColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ..._teamMembers
                      .map(
                        (member) =>
                            _buildTeamMemberCard(context, member, themeColor),
                      )
                      ,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context, Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: themeColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: themeColor, size: 28),
              const SizedBox(width: 12),
              Text(
                'About BrainGuard'.tr(context),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Inter',
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'We are a passionate team dedicated to leveraging technology for early stroke prediction and continuous patient monitoring. Our goal is to bridge the gap between patients and doctors by providing a seamless, intelligent, and life-saving healthcare platform.'
                .tr(context),
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Inter',
              color: AppColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberCard(
    BuildContext context,
    _TeamMember member,
    Color themeColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, themeColor.withValues(alpha: 0.08)],
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [themeColor.withValues(alpha: 0.7), themeColor],
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: themeColor.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: ClipOval(
                    child: member.imagePath.isNotEmpty
                        ? Image.asset(
                            member.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                Icon(Icons.person, color: Colors.grey.shade400),
                          )
                        : Icon(Icons.person, color: Colors.grey.shade400),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Name & Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      member.name.tr(context),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                        letterSpacing: 0.2,
                        fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Inter',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        if (member.email.isNotEmpty) {
                          final url = Uri.parse('mailto:${member.email}');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          }
                        }
                      },
                      child: Text(
                        member.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: themeColor,
                          decoration: TextDecoration.underline,
                          decorationColor: themeColor,
                          fontFamily: AppTextStyles.isArabic
                              ? 'Cairo'
                              : 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // WhatsApp Button
              InkWell(
                onTap: () async {
                  final url = Uri.parse('https://wa.me/${member.phone}');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [themeColor, themeColor.withValues(alpha: 0.85)],
                      begin: AlignmentDirectional.topStart,
                      end: AlignmentDirectional.bottomEnd,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: themeColor.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamMember {
  final String name;
  final String email;
  final String phone;
  final String imagePath;

  const _TeamMember({
    required this.name,
    required this.email,
    required this.phone,
    required this.imagePath,
  });
}

const List<_TeamMember> _teamMembers = [
  _TeamMember(
    name: 'Mohammed Ahmed Mohammed Siddiq',
    email: 'mohammedasiddiqdev@gmail.com',
    phone: '+201227897361',
    imagePath: 'assets/images/Mohammed Ahmed Mohammed Siddiq-01227897361.jpg',
  ),
  _TeamMember(
    name: 'Ahmed Bahaa El-dien Mohammed',
    email: 'ahmed.bahaa6423@gmail.com',
    phone: '+201069461770',
    imagePath: 'assets/images/Ahmed Bahaa El-dien Mohammed-01069461770.jpg',
  ),
  _TeamMember(
    name: 'Ahmed Mohammed Mahmoud',
    email: 'ahmedmohammedmahmoud552sd23_fcis@bsunu.edu.eg',
    phone: '+201004871381',
    imagePath: 'assets/images/Ahmed Mohammed Mahmoud-01004871381.jpg',
  ),
  _TeamMember(
    name: 'Belal Rabea Khalifa',
    email: 'belalfergani502@gmail.com',
    phone: '+201118247476',
    imagePath: 'assets/images/Belal Rabea Khalifa-01118247476.jpg',
  ),
  _TeamMember(
    name: 'Kareem Ashraf Hosny',
    email: 'kareemashraf495@gmail.com',
    phone: '+201004289028',
    imagePath: 'assets/images/Kareem Ashraf Hosny-01004289028.jpg',
  ),
];

