import 'package:flutter/material.dart';

import 'package:grad_imp_1/core/theme/app_colors.dart';
import 'package:grad_imp_1/shared/presentation/widgets/circular_loading_indicator.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularLoadingIndicator(size: 56, color: AppColors.tealP),
          if (message != null) ...[const SizedBox(height: 12), Text(message!)],
        ],
      ),
    );
  }
}
