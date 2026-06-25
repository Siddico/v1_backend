class DoctorSearchPatientItem {
  const DoctorSearchPatientItem({
    required this.name,
    required this.diagnosis,
    required this.patientId,
    required this.status,
    required this.image,
    this.firestoreId = '',
  });

  final String name;
  final String diagnosis;
  /// Display ID (e.g. "#0123") — NOT the Firestore UID.
  final String patientId;
  final String status;
  final String image;
  /// The real Firestore document UID used for navigation.
  final String firestoreId;
}
