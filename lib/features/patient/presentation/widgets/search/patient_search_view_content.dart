import 'package:flutter/material.dart';
import 'package:grad_imp_1/features/patient/presentation/widgets/search/patient_search_view_content_state.dart';

class PatientSearchViewContent extends StatefulWidget {
  const PatientSearchViewContent({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
  });

  final int currentIndex;
  final ValueChanged<int> onNavigate;

  @override
  State<PatientSearchViewContent> createState() =>
      PatientSearchViewContentState();
  // PatientSearchViewContentState();
}
