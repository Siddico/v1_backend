import 'package:flutter/material.dart';

class DoctorTaskEntity {
  const DoctorTaskEntity({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
  });

  final String title;
  final String description;
  final String time;
  final IconData icon;
}
