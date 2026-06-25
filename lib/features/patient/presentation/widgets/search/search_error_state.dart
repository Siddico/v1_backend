import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/theme/app_text_styles.dart';

class SearchErrorState extends StatelessWidget {
  const SearchErrorState({
    super.key,
    this.message = 'Failed to load doctors. Please try again.',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTextStyles.emptyBellBody15Regular,
      ),
    );
  }
}
