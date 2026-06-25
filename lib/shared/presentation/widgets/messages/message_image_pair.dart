import 'package:flutter/material.dart';

class MessageImagePair extends StatelessWidget {
  const MessageImagePair({
    super.key,
    required this.leftImage,
    required this.rightImage,
    this.height = 84,
  });

  final ImageProvider leftImage;
  final ImageProvider rightImage;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadiusDirectional.only(
                topStart: Radius.circular(18),
                topEnd: Radius.circular(4),
                bottomStart: Radius.circular(18),
                bottomEnd: Radius.circular(4),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(image: leftImage, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadiusDirectional.only(
                topStart: Radius.circular(4),
                topEnd: Radius.circular(18),
                bottomStart: Radius.circular(4),
                bottomEnd: Radius.circular(18),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(image: rightImage, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
