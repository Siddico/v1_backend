import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/features/patient/presentation/widgets/profile_components/lab_header_row.dart';
import 'package:grad_imp_1/features/patient/presentation/widgets/profile_components/lab_row.dart';

class LabDocumentsCard extends StatelessWidget {
  const LabDocumentsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const minTableWidth = 360.0;
        final tableWidth = constraints.maxWidth < minTableWidth
            ? minTableWidth
            : constraints.maxWidth;

        return Container(
          width: double.infinity,
          height: 148,
          padding: const EdgeInsetsDirectional.fromSTEB(10, 12, 10, 10),
          decoration: ShapeDecoration(
            color: AppColors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: AppColors.redMaroon),
              borderRadius: BorderRadius.circular(17),
            ),
            shadows: const [
              BoxShadow(
                color: AppColors.shadowBlack25,
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: SingleChildScrollView(
                child: const Column(
                  children: [
                    LabHeaderRow(),
                    LabRow(
                      name: 'Troponin I / T',
                      category: 'Cardiac Function',
                    ),
                    LabRow(name: 'HDL', category: 'Lipid Profile'),
                    LabRow(name: 'LDL', category: 'Lipid Profile'),
                    LabRow(
                      name: 'Total Cholesterol',
                      category: 'Lipid Profile',
                    ),
                    LabRow(name: 'RBG', category: 'Blood Glucose'),
                    LabRow(name: 'FBG', category: 'Blood Glucose'),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
