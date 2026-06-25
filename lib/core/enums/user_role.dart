enum UserRole { patient, doctor, researcher }

extension UserRoleX on UserRole {
  String get value {
    switch (this) {
      case UserRole.patient:
        return 'patient';
      case UserRole.doctor:
        return 'doctor';
      case UserRole.researcher:
        return 'researcher';
    }
  }

  static UserRole fromString(String value) {
    switch (value) {
      case 'doctor':
        return UserRole.doctor;
      case 'researcher':
        return UserRole.researcher;
      case 'patient':
      default:
        return UserRole.patient;
    }
  }
}
