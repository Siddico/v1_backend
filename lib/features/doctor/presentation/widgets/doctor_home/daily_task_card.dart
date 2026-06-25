import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../domain/entities/doctor_task_entity.dart';

class DailyTaskCard extends StatelessWidget {
  const DailyTaskCard({super.key, required this.item, required this.cardWidth});

  final DoctorTaskEntity item;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowBlack25,
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.redSurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(item.icon, color: AppColors.redDeep, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.title.tr(context),
                  style: AppTextStyles.doctorTaskTitleGray850_16Bold,
                ),
                const SizedBox(height: 3),
                Text(
                  item.description.tr(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.doctorTaskDescriptionNeutral300_13,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.time,
            style: AppTextStyles.doctorTaskTimeNeutral300_11Medium,
          ),
        ],
      ),
    );
  }
}
