// import 'package:flutter/material.dart';

// /// Decorative background circles for the patient home view
// class BackgroundDecorations extends StatelessWidget {
//   const BackgroundDecorations({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       height: 500,
//       child: Stack(
//         children: [
//           // Large gradient circle at bottom
//           Positioned(
//             left: -207,
//             bottom: -140,
//             child: Container(
//               width: 500,
//               height: 468,
//               decoration: ShapeDecoration(
//                 color: AppColors.$1,
//                 shape: const OvalBorder(),
//                 shadows: [
//                   BoxShadow(
//                     color: AppColors.$1,
//                     blurRadius: 111,
//                     offset: const Offset(11, 22),
//                     spreadRadius: 11,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // White shadow circle
//           // Positioned(
//           //   left: -212,
//           //   bottom: -134,
//           //   child: Container(
//           //     width: 500,
//           //     height: 468,
//           //     decoration: ShapeDecoration(
//           //       color: Colors.white,
//           //       shape: const OvalBorder(),
//           //       shadows: [
//           //         BoxShadow(
//           //           color: AppColors.$1,
//           //           blurRadius: 111,
//           //           offset: const Offset(11, 22),
//           //           spreadRadius: 11,
//           //         ),
//           //       ],
//           //     ),
//           //   ),
//           // ),
//           // Teal accent circle
//           // Positioned(
//           //   left: -57,
//           //   bottom: -220,
//           //   child: Container(
//           //     width: 136,
//           //     height: 135,
//           //     decoration: const ShapeDecoration(
//           //       color: AppColors.tealA,
//           //       shape: OvalBorder(),
//           //     ),
//           //   ),
//           // ),
//         ],
//       ),
//     );
//   }
// }
