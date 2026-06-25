import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:grad_imp_1/core/localization/app_localizations.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/presentation/widgets/app_bar_controls.dart';
import '../../../../../shared/presentation/widgets/circular_loading_indicator.dart';
import '../../../../../shared/presentation/widgets/floating_notification_button.dart';
import '../../../../../shared/presentation/widgets/floating_chatbot_button.dart';
import '../../../../../shared/presentation/widgets/navigation/bottom_nav_bar.dart';
import '../../../../auth/presentation/controllers/auth_providers.dart';
import '../search/doctor_card.dart';
import '../search/speciality_chip.dart';
import '../search/search_error_state.dart';
import '../search/search_not_found_state.dart';
import '../../controllers/patient_search_providers.dart';
import '../../../domain/entities/doctor_search_entity.dart';
import '../../pages/doctor_detail_page.dart';

class PatientSearchViewContent extends ConsumerStatefulWidget {
  const PatientSearchViewContent({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
  });

  final int currentIndex;
  final ValueChanged<int> onNavigate;

  @override
  ConsumerState<PatientSearchViewContent> createState() =>
      _PatientSearchViewContentState();
}

class _PatientSearchViewContentState
    extends ConsumerState<PatientSearchViewContent> {
  late int _currentNavIndex;
  bool _isDarkMode = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String? _selectedSpecialty;

  // We'll fetch specialties from Firestore via provider

  bool get _hasSearchQuery => _searchController.text.trim().isNotEmpty;

  List<DoctorSearchEntity> _filteredDoctors(List<DoctorSearchEntity> doctors) {
    final query = _searchController.text.trim().toLowerCase();
    final selectedSpecialty = _selectedSpecialty?.toLowerCase();

    return doctors.where((doctor) {
      final specialtyMatches =
          selectedSpecialty == null ||
          doctor.specialty.toLowerCase() == selectedSpecialty;
      final queryMatches =
          query.isEmpty ||
          doctor.name.toLowerCase().contains(query) ||
          doctor.specialty.toLowerCase().contains(query);
      return specialtyMatches && queryMatches;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.currentIndex;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(PatientSearchViewContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _currentNavIndex = widget.currentIndex;
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final normalizedText = _searchController.text.trim().toLowerCase();
    // Get specialties from provider
    final specialties = ref
        .read(doctorSpecialtiesProvider)
        .maybeWhen(data: (list) => list, orElse: () => const <String>[]);
    String? exactMatch;
    for (final specialty in specialties) {
      if (specialty.toLowerCase() == normalizedText) {
        exactMatch = specialty;
        break;
      }
    }
    if (_selectedSpecialty != exactMatch) {
      setState(() {
        _selectedSpecialty = exactMatch;
      });
      return;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxContentWidth = size.width > 440 ? 420.0 : size.width - 24;
    final authState = ref.watch(authStateProvider);
    final assignedIdsAsync = ref.watch(assignedDoctorIdsProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 140),
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 44,
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                      width: 1,
                                      color: AppColors.tealBorderLight,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  shadows: const [
                                    BoxShadow(
                                      color: AppColors.shadowBlack10,
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    if (_selectedSpecialty != null)
                                      Positioned(
                                        left: 16,
                                        top: 7,
                                        child: Container(
                                          height: 30,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 15,
                                            vertical: 6,
                                          ),
                                          decoration: ShapeDecoration(
                                            color: AppColors.tealBorderLight,
                                            shape: RoundedRectangleBorder(
                                              side: const BorderSide(
                                                width: 1,
                                                color:
                                                    AppColors.tealPrimaryDark,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            _selectedSpecialty!,
                                            textAlign: TextAlign.center,
                                            style: AppTextStyles
                                                .chipTextTealIcon12BoldTight,
                                          ),
                                        ),
                                      ),
                                    if (_selectedSpecialty != null)
                                      Positioned(
                                        right: 10,
                                        top: 12,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedSpecialty = null;
                                              _searchController.clear();
                                            });
                                            Future.microtask(() {
                                              if (mounted) {
                                                _searchFocusNode.requestFocus();
                                              }
                                            });
                                          },
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: const ShapeDecoration(
                                              color: AppColors.neutralSurface,
                                              shape: OvalBorder(),
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: AppColors.tealPrimaryDark,
                                              size: 14,
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      Positioned.fill(
                                        child: TextField(
                                          controller: _searchController,
                                          focusNode: _searchFocusNode,
                                          cursorColor:
                                              AppColors.tealPrimaryDark,
                                          style: AppTextStyles
                                              .searchInputBlack12Regular,
                                          decoration: InputDecoration(
                                            prefixIcon: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: SvgPicture.asset(
                                                AppImages.searchUnselectedSvg,
                                                colorFilter:
                                                    const ColorFilter.mode(
                                                      AppColors.tealPrimaryDark,
                                                      BlendMode.srcIn,
                                                    ),
                                              ),
                                            ),
                                            prefixIconConstraints:
                                                const BoxConstraints(
                                                  minWidth: 38,
                                                  minHeight: 38,
                                                ),
                                            labelText: 'Search'.tr(context),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.auto,
                                            floatingLabelStyle: AppTextStyles
                                                .searchInputBlack12Regular
                                                .copyWith(
                                                  color:
                                                      AppColors.tealPrimaryDark,
                                                  fontSize: 10,
                                                ),
                                            labelStyle: AppTextStyles
                                                .searchInputBlack12Regular,
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                color:
                                                    AppColors.tealPrimaryDark,
                                                width: 1.2,
                                              ),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                color:
                                                    AppColors.tealBorderLight,
                                                width: 1,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                color:
                                                    AppColors.tealBorderLight,
                                                width: 1,
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 12,
                                                ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Container(
                              width: 46,
                              height: 44,
                              decoration: ShapeDecoration(
                                color: AppColors.tealPrimaryLight,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    width: 0.5,
                                    color: AppColors.tealA,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                shadows: const [
                                  BoxShadow(
                                    color: AppColors.shadowBlack25,
                                    blurRadius: 4,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  AppImages.searchUnselectedSvg,
                                  width: 20,
                                  height: 20,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 11,
                          runSpacing: 9,
                          children: ref
                              .watch(doctorSpecialtiesProvider)
                              .maybeWhen(
                                data: (specialties) => specialties
                                    .map(
                                      (specialty) => SpecialtyChip(
                                        label: specialty,
                                        isSelected:
                                            _selectedSpecialty == specialty,
                                        onTap: () {
                                          setState(() {
                                            _selectedSpecialty = specialty;
                                            _searchController.text = specialty;
                                          });
                                        },
                                      ),
                                    )
                                    .toList(),
                                orElse: () => const [],
                              ),
                        ),
                        const SizedBox(height: 31),

                        assignedIdsAsync.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.only(top: 64),
                            child: Center(
                              child: CircularLoadingIndicator(
                                size: 44,
                                color: AppColors.tealPrimaryDark,
                              ),
                            ),
                          ),
                          error: (err, _) => const Padding(
                            padding: EdgeInsets.only(top: 64),
                            child: SearchErrorState(),
                          ),
                          data: (doctorIds) {
                            if (!authState.hasValue ||
                                authState.value == null) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 124),
                                child: SearchErrorState(
                                  message: 'Please login to view your doctors.',
                                ),
                              );
                            }

                            if (doctorIds.isEmpty) {
                              return const SizedBox.shrink(); // Or build empty state
                            }

                            final doctorsAsync = ref.watch(
                              assignedDoctorsProvider(doctorIds),
                            );

                            return doctorsAsync.when(
                              loading: () => const Padding(
                                padding: EdgeInsets.only(top: 64),
                                child: Center(
                                  child: CircularLoadingIndicator(
                                    size: 44,
                                    color: AppColors.tealPrimaryDark,
                                  ),
                                ),
                              ),
                              error: (err, _) => const Padding(
                                padding: EdgeInsets.only(top: 64),
                                child: SearchErrorState(),
                              ),
                              data: (doctors) {
                                final filteredDoctors = _filteredDoctors(
                                  doctors,
                                );

                                if (filteredDoctors.isNotEmpty) {
                                  return Column(
                                    children: filteredDoctors
                                        .map(
                                          (doctor) => Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 31,
                                            ),
                                            child: DoctorCard(
                                              name: doctor.name,
                                              specialty: doctor.specialty,
                                              photoUrl: doctor.photoUrl,
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        DoctorDetailPage(
                                                          name: doctor.name,
                                                          specialty:
                                                              doctor.specialty,
                                                          doctorId: doctor.id,
                                                        ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  );
                                }

                                if (_hasSearchQuery ||
                                    _selectedSpecialty != null) {
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 124),
                                    child: SearchNotFoundState(),
                                  );
                                }

                                return const SizedBox.shrink(); // Or build empty state
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          FloatingNotificationButton(
            onTap: () => context.push(AppConstants.routeNotifications),
            bottom: 25,
          ),
          const FloatingChatbotButton(bottom: 25),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentNavIndex,
        labels: [
          'Home'.tr(context),
          'Search'.tr(context),
          'Charts'.tr(context),
          'Profile'.tr(context),
        ],
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          widget.onNavigate(index);
        },
        centerButtonOnTap: () {
          context.push(AppConstants.routeUploadFilesStep1);
        },
      ),
    );
  }
}
