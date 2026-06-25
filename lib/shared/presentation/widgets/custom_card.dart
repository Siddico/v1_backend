import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/theme/app_radius.dart';
import 'package:grad_imp_1/core/theme/app_shadows.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardColor,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.standardShadow,
      ),
      child: child,
    );

    if (onTap == null) {
      return card;
    }

    return InkWell(onTap: onTap, borderRadius: AppRadius.card, child: card);
  }
}
