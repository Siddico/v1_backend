import 'package:grad_imp_1/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/patient_row_entity.dart';
import 'states_chip.dart';
import '../../pages/patient_detail_page.dart';

class PatientsSection extends StatelessWidget {
  const PatientsSection({super.key, required this.patients});

  final List<PatientRowEntity> patients;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Patients list'.tr(context),
                style: AppTextStyles.doctorOverviewHeaderRedDarkest20ExtraBold,
              ),
            ),
            Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.redMaroon),
                borderRadius: const BorderRadiusDirectional.only(
                  topEnd: Radius.circular(100),
                  bottomEnd: Radius.circular(100),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Filter'.tr(context),
                    style: AppTextStyles.doctorFilterLabelRedMaroon12Bold,
                  ),
                  SizedBox(width: 5),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: AppColors.redMaroon,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: AppColors.redMaroon),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowBlack25,
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: patients.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people_outline, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'No patients linked yet.\nUse the QR scanner to connect patients.'.tr(context),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13, 
                        color: Colors.grey.shade500,
                        fontFamily: AppTextStyles.isArabic ? 'Cairo' : 'Poppins',
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowHeight: 34,
                  dataRowMinHeight: 40,
                  dataRowMaxHeight: 44,
                  columnSpacing: 18,
                  headingTextStyle:
                      AppTextStyles.doctorDataTableHeaderNeutral450_11ExtraBold,
                  columns: [
                    DataColumn(label: Text('ID'.tr(context))),
                    DataColumn(label: Text('Name'.tr(context))),
                    DataColumn(label: Text('Diagnoses'.tr(context))),
                    DataColumn(label: Text('Status'.tr(context))),
                    DataColumn(label: Text('Last review'.tr(context))),
                    DataColumn(
                      label: SvgPicture.asset(
                        'assets/images/eye_of_patient_record.svg',
                      ),
                    ),
                  ],
                  rows: patients
                      .map(
                        (p) => DataRow(
                          cells: [
                            DataCell(cellText(p.id)),
                            DataCell(cellText(p.name)),
                            DataCell(cellText(p.diagnosis)),
                            DataCell(StatusChip(text: p.status)),
                            DataCell(cellText(p.lastReview)),
                            DataCell(
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PatientDetailPage(patientId: p.id),
                                    ),
                                  );
                                },
                                child: SvgPicture.asset(
                                  'assets/images/eye_of_patient_record.svg',
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
        ),
      ],
    );
  }

  static Widget cellText(String value) {
    return Text(
      value,
      style: AppTextStyles.doctorDataTableCellNeutral450_11Bold,
    );
  }
}
