import 'package:flutter/material.dart';
import 'package:grad_imp_1/features/patient/presentation/widgets/profile_components/radiology_tile.dart';

class RadiologyImagingGrid extends StatelessWidget {
  const RadiologyImagingGrid({super.key});

  @override
  Widget build(BuildContext context) {
    const items = ['CT brain', 'Chest X-Ray', 'Cervical Spine MRI', 'Echo'];
    const itemSpacing = 25.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            RadiologyTile(label: items[i]),
            if (i != items.length - 1) const SizedBox(width: itemSpacing),
          ],
        ],
      ),
    );
  }
}
