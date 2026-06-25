import 'package:flutter/material.dart';
import '../../../domain/entities/stat_summary_entity.dart';
import 'state_summary_card.dart';

class DoctorStatsRow extends StatelessWidget {
  const DoctorStatsRow({super.key, required this.stats});

  final List<StatSummaryEntity> stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stats
          .map(
            (item) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: StatSummaryCard(data: item),
              ),
            ),
          )
          .toList(),
    );
  }
}
