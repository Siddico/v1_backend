import 'package:flutter/material.dart';

class InformationGroup extends StatelessWidget {
  const InformationGroup({super.key, required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows
          .map(
            (row) =>
                Padding(padding: const EdgeInsetsDirectional.only(bottom: 14), child: row),
          )
          .toList(),
    );
  }
}
