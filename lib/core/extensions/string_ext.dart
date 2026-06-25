// extension StringX on String {
//   bool get isValidEmail {
//     final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
//     return emailRegex.hasMatch(this);
//   }

//   bool get isValidPassword {
//     if (length < 8) {
//       return false;
//     }
//     final hasLetter = RegExp(r'[A-Za-z]').hasMatch(this);
//     final hasNumber = RegExp(r'\d').hasMatch(this);
//     return hasLetter && hasNumber;
//   }
// }
