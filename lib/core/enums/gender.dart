/// Gender enum for user profile
enum Gender { male, female }

extension GenderExtension on Gender {
  String get displayName {
    return this == Gender.male ? 'Male' : 'Female';
  }
}
