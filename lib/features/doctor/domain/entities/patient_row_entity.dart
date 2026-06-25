class PatientRowEntity {
  const PatientRowEntity({
    required this.id,
    required this.name,
    required this.diagnosis,
    required this.status,
    required this.lastReview,
  });

  final String id;
  final String name;
  final String diagnosis;
  final String status;
  final String lastReview;
}
