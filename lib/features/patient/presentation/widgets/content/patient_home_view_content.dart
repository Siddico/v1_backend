import 'package:flutter/material.dart';

class PatientHomeViewContent extends StatefulWidget {
  const PatientHomeViewContent({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
  });

  final int currentIndex;
  final ValueChanged<int> onNavigate;

  @override
  State<PatientHomeViewContent> createState() => _PatientHomeViewContentState();
}

class _PatientHomeViewContentState extends State<PatientHomeViewContent> {
  // int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // _currentIndex = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: null);
  }
}
