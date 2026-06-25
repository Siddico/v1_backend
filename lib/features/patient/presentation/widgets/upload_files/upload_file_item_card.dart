import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/upload_file_entity.dart';

class UploadFileItemCard extends StatelessWidget {
  const UploadFileItemCard({super.key, required this.file});

  final UploadFileItem file;

  @override
  Widget build(BuildContext context) {
    final progressColor = file.isSuccess
        ? AppColors.tealIconActive
        : AppColors.redDeep;
    final textColor = file.isSuccess ? AppColors.neutral850 : AppColors.redDeep;
    final icon = file.isSuccess
        ? Icons.check_circle_outline
        : Icons.error_outline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: ShapeDecoration(
            color: AppColors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 0.5, color: AppColors.grayDivider),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: file.isSuccess
                    ? AppColors.tealIconActive
                    : AppColors.redDeep,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      style: AppTextStyles.uploadFileNameMulish12Regular
                          .copyWith(color: textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      file.message,
                      style: AppTextStyles.uploadHintNeutral700_12.copyWith(
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 4,
            child: LinearProgressIndicator(
              value: file.progress,
              backgroundColor: AppColors.grayDivider,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ),
      ],
    );
  }
}
