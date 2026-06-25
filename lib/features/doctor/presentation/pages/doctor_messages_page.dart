import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';
import 'package:grad_imp_1/shared/presentation/widgets/messages/conversation_item.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../shared/presentation/widgets/app_bar_controls.dart';
import '../../../../shared/presentation/widgets/messages/conversation_tile.dart';
import '../../../../shared/presentation/widgets/circular_loading_indicator.dart';
import '../../../../shared/presentation/widgets/navigation/bottom_nav_bar.dart';
import '../controllers/doctor_message_providers.dart';
import 'doctor_chat_page.dart';
import '../../../../core/localization/app_localizations.dart';

class DoctorMessagesPage extends ConsumerStatefulWidget {
  const DoctorMessagesPage({super.key, this.currentIndex = 2, this.onNavigate});

  final int currentIndex;
  final ValueChanged<int>? onNavigate;

  @override
  ConsumerState<DoctorMessagesPage> createState() => _DoctorMessagesPageState();
}

class _DoctorMessagesPageState extends ConsumerState<DoctorMessagesPage> {
  late int _currentNavIndex;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.currentIndex;
  }

  void _handleNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });

    if (widget.onNavigate != null) {
      widget.onNavigate!(index);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(doctorConversationsProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
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
          const SizedBox(height: 16),
          Expanded(
            child: conversationsAsync.when(
              data: (conversations) {
                if (conversations.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 56,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No conversations yet.\nStart chatting with your patients!'
                                .tr(context),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: AppTextStyles.isArabic
                                  ? 'Cairo'
                                  : 'Inter',
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 12),
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    return ConversationTile(
                      item: ConversationItem(
                        name: conversation.name,
                        preview: conversation.preview,
                        image: conversation.image,
                        unreadCount: conversation.unreadCount,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DoctorChatPage(
                              contactName: conversation.name,
                              contactImage: conversation.image,
                              conversationId: conversation.id,
                              otherId: conversation.otherId,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularLoadingIndicator(
                  size: 32,
                  color: AppColors.redDeep,
                ),
              ),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _handleNavTap,
        labels: [
          'Home'.tr(context),
          'Search'.tr(context),
          'Message'.tr(context),
          'Profile'.tr(context),
        ],
        selectedIcons: const [
          AppImages.homeSelectedSvg,
          AppImages.searchSelectedSvg,
          AppImages.messageLogoSvg,
          AppImages.profileSelectedSvg,
        ],
        unselectedIcons: const [
          AppImages.homeUnselectedSvg,
          AppImages.searchUnselectedSvg,
          AppImages.messageLogoSvg,
          AppImages.profileUnselectedSvg,
        ],
        activeColor: AppColors.redDeep,
        inactiveColor: AppColors.redSoft,
        centerButtonColor: AppColors.redDeep,
        centerButtonBorderColor: AppColors.pinkLight,
        centerButtonIcon: AppImages.scanQrCodeSvg,
        centerButtonOnTap: () {
          context.push(AppConstants.routeDoctorScanQr);
        },
      ),
    );
  }
}
