import 'package:flutter/material.dart';

class RoleImageCard extends StatelessWidget {
  final String imageUrl;
  final Color shadowColor;

  const RoleImageCard({
    super.key,
    required this.imageUrl,
    required this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        // border: Border.all(width: 1, color: Colors.black),
        image: DecorationImage(image: AssetImage(imageUrl), fit: BoxFit.cover),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
      ),
    );
  }
}
