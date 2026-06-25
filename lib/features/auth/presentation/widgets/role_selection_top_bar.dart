// import 'package:flutter/material.dart';

// class RoleSelectionTopBar extends StatelessWidget {
//   final VoidCallback? onBackPressed;

//   const RoleSelectionTopBar({super.key, this.onBackPressed});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 347,
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         spacing: 216,
//         children: [
//           // Back button
//           Container(
//             height: 38,
//             padding: const EdgeInsets.all(10),
//             decoration: ShapeDecoration(
//               color: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(11),
//               ),
//               shadows: [
//                 BoxShadow(
//                   color: AppColors.shadowBlack25,
//                   blurRadius: 4,
//                   offset: Offset(0, 4),
//                   spreadRadius: 0,
//                 ),
//               ],
//             ),
//             child: GestureDetector(
//               onTap: onBackPressed,
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 spacing: 10,
//                 children: [
//                   Container(
//                     width: 32,
//                     height: 24,
//                     clipBehavior: Clip.antiAlias,
//                     decoration: ShapeDecoration(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(11),
//                       ),
//                     ),
//                     child: Stack(),
//                   ),
//                   Container(
//                     width: 24,
//                     height: 24,
//                     clipBehavior: Clip.antiAlias,
//                     decoration: BoxDecoration(),
//                     child: Stack(),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // Settings button
//           Container(
//             width: 45,
//             height: 43,
//             padding: const EdgeInsets.all(10),
//             decoration: ShapeDecoration(
//               color: AppColors.$1,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(333),
//               ),
//               shadows: [
//                 BoxShadow(
//                   color: AppColors.shadowBlack25,
//                   blurRadius: 4,
//                   offset: Offset(0, 4),
//                   spreadRadius: 0,
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [SizedBox(width: 23, height: 21, child: Stack())],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
