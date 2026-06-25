class DoctorSearchEntity {
  const DoctorSearchEntity({
    required this.id,
    required this.name,
    required this.specialty,
    this.photoUrl,
  });

  final String id;
  final String name;
  final String specialty;
  final String? photoUrl;
}
