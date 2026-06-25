import 'package:flutter/material.dart';

class HealthChart extends StatelessWidget {
  const HealthChart({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(child: Text('$title chart placeholder')),
    );
  }
}

