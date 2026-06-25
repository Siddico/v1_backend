import 'package:grad_imp_1/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grad_imp_1/core/constants/app_images.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';
import 'package:grad_imp_1/features/doctor/presentation/controllers/doctor_search_providers.dart';
import 'package:grad_imp_1/features/doctor/presentation/pages/patient_detail_page.dart';
import 'package:grad_imp_1/shared/presentation/widgets/app_bar_controls.dart';
import 'package:grad_imp_1/shared/presentation/widgets/circular_loading_indicator.dart';
import 'package:grad_imp_1/shared/presentation/widgets/home_search/doctor_search_no_data_state.dart';
import 'package:grad_imp_1/shared/presentation/widgets/home_search/doctor_search_patient_item.dart';
import 'package:grad_imp_1/shared/presentation/widgets/home_search/patient_search_result_card.dart';

class DoctorSearchViewContent extends ConsumerStatefulWidget {
  const DoctorSearchViewContent({
    super.key,
    this.currentIndex = 1,
    this.onNavigate,
  });

  final int currentIndex;
  final ValueChanged<int>? onNavigate;

  @override
  ConsumerState<DoctorSearchViewContent> createState() =>
      DoctorSearchViewContentState();
}

class DoctorSearchViewContentState
    extends ConsumerState<DoctorSearchViewContent> {
  bool _isDarkMode = false;
  final TextEditingController _searchController = TextEditingController();

  List<DoctorSearchPatientItem> _applyFilter(
    List<DoctorSearchPatientItem> patients,
  ) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return patients;
    return patients.where((item) {
      return item.name.toLowerCase().contains(query) ||
          item.diagnosis.toLowerCase().contains(query) ||
          item.patientId.toLowerCase().contains(query);
    }).toList();
  }

  bool get _hasSearchQuery => _searchController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxContentWidth = width > 420 ? 402.0 : width - 22;
    final patientsAsync = ref.watch(doctorLinkedPatientsProvider);

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: SizedBox(
          // width: maxContentWidth,
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
              Center(
                child: SizedBox(
                  width: maxContentWidth,
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 36,
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                shadows: const [
                                  BoxShadow(
                                    color: AppColors.shadowBlack25,
                                    blurRadius: 4,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _searchController,
                                style:
                                    AppTextStyles.searchFieldInputBlack12Inter,
                                decoration: InputDecoration(
                                  hintText: 'Search'.tr(context),
                                  hintStyle: AppTextStyles
                                      .searchFieldInputBlack12Inter,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 11,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 46,
                            height: 36,
                            padding: const EdgeInsets.all(4),
                            decoration: ShapeDecoration(
                              color: AppColors.redSoft,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 0.5,
                                  color: AppColors.redSoft,
                                ),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              shadows: const [
                                BoxShadow(
                                  color: AppColors.shadowBlack25,
                                  blurRadius: 4,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: SvgPicture.asset(
                              AppImages.searchUnselectedSvg,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                              height: 24,
                              width: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 296,
                        child: Text(
                          'You can search with patient name, ID or diagnosis'
                              .tr(context),
                          style: AppTextStyles
                              .homeSearchHelperBlack14RobotoRegular,
                        ),
                      ),
                      const SizedBox(height: 20),
                      patientsAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsetsDirectional.only(top: 60),
                          child: Center(
                            child: CircularLoadingIndicator(
                              size: 20,
                              color: AppColors.redDeep,
                            ),
                          ),
                        ),
                        error: (err, _) => Padding(
                          padding: const EdgeInsetsDirectional.only(top: 60),
                          child: Center(
                            child: Text(
                              '${'Error loading patients:'.tr(context)} $err',
                            ),
                          ),
                        ),
                        data: (patients) {
                          final filtered = _applyFilter(patients);

                          if (filtered.isNotEmpty) {
                            return Column(
                              children: filtered
                                  .map(
                                    (patient) => Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                        bottom: 18,
                                      ),
                                      child: PatientSearchResultCard(
                                        data: patient,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => PatientDetailPage(
                                                // Use the real Firestore UID
                                                patientId: patient.firestoreId,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                  .toList(),
                            );
                          } else if (_hasSearchQuery) {
                            return const Padding(
                              padding: EdgeInsetsDirectional.only(top: 136),
                              child: DoctorSearchNoDataState(),
                            );
                          } else if (patients.isEmpty) {
                            return Padding(
                              padding: const EdgeInsetsDirectional.only(
                                top: 80,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 56,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No linked patients yet.\nUse the QR scanner to add patients.'
                                        .tr(context),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                    ],
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
