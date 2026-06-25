import 'package:flutter/material.dart';

class SignalPlaceholder extends StatelessWidget {
  const SignalPlaceholder({
    super.key,
    required this.width,
    required this.height,
    required this.imageUrl,
  });

  final double width;
  final double height;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.fill),
      ),
    );
  }
}

class SignalsRow extends StatelessWidget {
  const SignalsRow({
    super.key,
    required this.signals,
    this.spacing = 12,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final List<({double width, double height, String imageUrl})> signals;
  final double spacing;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: crossAxisAlignment,
      spacing: spacing,
      children: signals
          .map(
            (signal) => SignalPlaceholder(
              width: signal.width,
              height: signal.height,
              imageUrl: signal.imageUrl,
            ),
          )
          .toList(),
    );
  }
}
