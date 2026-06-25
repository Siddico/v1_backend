import 'package:flutter/material.dart';

class StatSummaryEntity {
  const StatSummaryEntity({
    required this.title,
    required this.value,
    required this.colors,
    required this.image,
  });

  final String title;
  final String value;
  final List<Color> colors;
  final String image;
}
