import 'package:flutter/material.dart';
import 'package:grad_imp_1/features/wellness/presentation/pages/wellness_page.dart';
import '../widgets/content/patient_search_view_content.dart';
import '../widgets/content/patient_charts_view_content.dart';
import '../widgets/profile/patient_profile_view_content.dart';

class PatientDashboardPage extends StatefulWidget {
  final int initialIndex;

  const PatientDashboardPage({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<PatientDashboardPage> createState() => _PatientDashboardPageState();
}

class _PatientDashboardPageState extends State<PatientDashboardPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant PatientDashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      setState(() {
        _currentIndex = widget.initialIndex;
      });
    }
  }

  void _onNavigate(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _currentIndex,
      children: [
        WellnessPage(currentIndex: _currentIndex, onNavigate: _onNavigate),
        PatientSearchViewContent(
          currentIndex: _currentIndex,
          onNavigate: _onNavigate,
        ),
        PatientChartsViewContent(
          currentIndex: _currentIndex,
          onNavigate: _onNavigate,
        ),
        PatientProfileViewContent(
          currentIndex: _currentIndex,
          onNavigate: _onNavigate,
        ),
      ],
    );
  }
}
