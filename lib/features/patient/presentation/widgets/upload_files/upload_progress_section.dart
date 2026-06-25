import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../domain/entities/upload_file_entity.dart';
import 'upload_file_item_card.dart';

class UploadProgressSection extends StatelessWidget {
  const UploadProgressSection({
    super.key,
    required this.files,
    required this.onClear,
  });

  final List<UploadFileItem> files;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final isArabic = AppTextStyles.isArabic;
    final successCount = files.where((file) => file.isSuccess).length;
    final errorCount = files.length - successCount;

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${'Selected files: '.tr(context)}$successCount ${'accepted'.tr(context)}, $errorCount ${'rejected'.tr(context)}',
                  style: AppTextStyles.uploadHeaderMulish14Bold.copyWith(
                    fontFamily: isArabic ? 'Cairo' : null,
                  ),
                ),
              ),
              IconButton(
                onPressed: onClear,
                icon: const Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.neutral700,
                ),
                splashRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...files.asMap().entries.map((entry) {
            return Padding(
              padding: EdgeInsetsDirectional.only(
                bottom: entry.key < files.length - 1 ? 20 : 0,
              ),
              child: UploadFileItemCard(file: entry.value),
            );
          }),
        ],
      ),
    );
  }
}
