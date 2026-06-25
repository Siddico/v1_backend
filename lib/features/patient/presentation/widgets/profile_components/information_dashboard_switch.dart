import 'package:flutter/material.dart';
import 'package:grad_imp_1/features/patient/presentation/widgets/profile_components/segment_tab.dart';
import 'package:grad_imp_1/core/localization/app_localizations.dart';

class InfoDashboardSwitch extends StatelessWidget {
  const InfoDashboardSwitch({super.key, 
    required this.showMedicalDashboard,
    required this.onToggle,
  });

  final bool showMedicalDashboard;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: SegmentTab(
                label: 'Information'.tr(context),
                selected: !showMedicalDashboard,
                leftRounded: true,
                onTap: () => onToggle(false),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: SegmentTab(
                label: 'Medical Dashboard'.tr(context),
                selected: showMedicalDashboard,
                leftRounded: false,
                onTap: () => onToggle(true),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
