class DoctorFollowUpEntity {
  const DoctorFollowUpEntity({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.suggestionText,
    this.description,
    this.nextVisit,
    required this.followUpType,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String doctorId;
  final String patientId;
  final String suggestionText;
  final String? description;
  final DateTime? nextVisit;
  final String followUpType;
  final String status;
  final DateTime createdAt;

  factory DoctorFollowUpEntity.fromJson(Map<String, dynamic> json) {
    return DoctorFollowUpEntity(
      id: json['id']?.toString() ?? '',
      doctorId: json['doctor_id']?.toString() ?? '',
      patientId: json['patient_id']?.toString() ?? '',
      suggestionText: json['suggestion_text']?.toString() ?? json['notes']?.toString() ?? '',
      description: json['description']?.toString(),
      nextVisit: json['next_visit'] != null ? DateTime.tryParse(json['next_visit'].toString()) : null,
      followUpType: json['follow_up_type']?.toString() ?? 'routine',
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at'] != null ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()) : DateTime.now(),
    );
  }
}
