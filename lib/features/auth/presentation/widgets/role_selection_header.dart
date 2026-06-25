// import 'package:flutter/material.dart';

// class RoleSelectionHeader extends StatelessWidget {
//   const RoleSelectionHeader({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       height: 300,
//       child: Stack(
//         clipBehavior: Clip.antiAlias,
//         children: [
//           // Gradient background
//           Positioned(
//             left: -86.51,
//             top: 0,
//             child: Container(
//               transform: Matrix4.identity()
//                 ..setEntry(3, 2, 0.0)
//                 ..rotateZ(0.92),
//               width: 844.33,
//               height: 660.95,
//               clipBehavior: Clip.antiAlias,
//               decoration: BoxDecoration(
//                 gradient: const SweepGradient(
//                   center: Alignment(-0, 0),
//                   startAngle: -3.93,
//                   endAngle: 2.36,
//                   colors: [
//                     AppColors.tealAccentMuted,
//                     AppColors.tealA,
//                     AppColors.blueSecondary,
//                     AppColors.redStrong,
//                   ],
//                   stops: [0, 0.25, 0.57, 0.99],
//                   transform: GradientRotation(-3.93),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.shadowBlack25,
//                     blurRadius: 4,
//                     offset: Offset(0, 4),
//                     spreadRadius: 0,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // Title
//           Positioned(
//             left: 99,
//             top: 80,
//             child: Text(
//               'you are',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: AppColors.$1,
//                 fontSize: 50,
//                 fontFamily: 'Croissant One',
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//           ),
//           // Subtitle
//           Positioned(
//             left: 20,
//             top: 150,
//             right: 20,
//             child: SizedBox(
//               width: 362,
//               child: Text(
//                 'Identify your role to continue',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: AppColors.$1,
//                   fontSize: 22,
//                   fontFamily: 'Inter',
//                   fontWeight: FontWeight.w400,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
