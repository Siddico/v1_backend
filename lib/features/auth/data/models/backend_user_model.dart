import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/enums/gender.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/domain/entities/user_entity.dart';

class BackendUserModel {
  const BackendUserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.phone,
    this.gender,
    this.dateOfBirth,
    this.roleId,
    this.doctorProfile,
    this.patientProfile,
    this.photoUrl,
    this.aiRiskStrokeRate,
    this.status,
    this.lastPredictionTime,
  });

  final String id;
  final String? photoUrl;
  final String fullName;
  final String email;
  final UserRole role;
  final String? phone;
  final Gender? gender;
  final String? dateOfBirth;
  final int? roleId;
  final Map<String, dynamic>? doctorProfile;
  final Map<String, dynamic>? patientProfile;
  final double? aiRiskStrokeRate;
  final String? status;
  final DateTime? lastPredictionTime;

  factory BackendUserModel.fromJson(Map<String, dynamic> json) {
    final roleVal = json['role'];
    final roleJson = roleVal is Map<String, dynamic> ? roleVal : null;
    final patientProfile = json['patient_profile'] as Map<String, dynamic>?;
    final doctorProfile = json['doctor_profile'] as Map<String, dynamic>?;
    final researcherProfile =
        json['researcher_profile'] as Map<String, dynamic>?;

    final fullName = _firstNonEmpty([
      json['full_name'],
      json['name'],
      patientProfile?['full_name'],
      doctorProfile?['full_name'],
      researcherProfile?['full_name'],
    ]);

    final roleName = _firstNonEmpty([
      roleJson?['name_of_role'],
      json['role_name'],
      json['role'],
    ]);

    final genderValue = _firstNonEmpty([
      json['gender'],
      patientProfile?['gender'],
      doctorProfile?['gender'],
      researcherProfile?['gender'],
    ]);

    final dobValue = _firstNonEmpty([
      json['date_of_birth'],
      patientProfile?['date_of_birth'],
      doctorProfile?['date_of_birth'],
      researcherProfile?['date_of_birth'],
    ]);

    final aiRiskStrokeRateNum =
        json['ai_risk_stroke_rate'] ?? patientProfile?['ai_risk_stroke_rate'];
    final double? aiRiskStrokeRate = aiRiskStrokeRateNum != null
        ? (aiRiskStrokeRateNum as num).toDouble()
        : null;
    final String? status =
        json['status']?.toString() ?? patientProfile?['status']?.toString();
    final rawLastPredTime =
        json['last_prediction_time'] ?? patientProfile?['last_prediction_time'];
    DateTime? lastPredictionTime;
    if (rawLastPredTime != null) {
      if (rawLastPredTime is String) {
        lastPredictionTime = DateTime.tryParse(rawLastPredTime);
      } else if (rawLastPredTime is Timestamp) {
        lastPredictionTime = rawLastPredTime.toDate();
      }
    }

    return BackendUserModel(
      id: json['id']?.toString() ?? '',
      fullName: fullName ?? '',
      email: json['email']?.toString() ?? '',
      role: UserRoleX.fromString(roleName ?? 'patient'),
      phone: _firstNonEmpty([
        json['phone'],
        patientProfile?['phone'],
        doctorProfile?['phone'],
        researcherProfile?['phone'],
      ]),
      gender: genderValue == null ? null : _genderFromString(genderValue),
      dateOfBirth: dobValue,
      roleId: int.tryParse(json['role_id']?.toString() ?? ''),
      doctorProfile: doctorProfile,
      patientProfile: patientProfile,
      photoUrl: json['photo_url']?.toString(),
      aiRiskStrokeRate: aiRiskStrokeRate,
      status: status,
      lastPredictionTime: lastPredictionTime,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      name: fullName.isEmpty ? email : fullName,
      role: role,
      phone: phone,
      gender: gender?.name,
      dateOfBirth: dateOfBirth,
      doctorProfile: doctorProfile,
      patientProfile: patientProfile,
      photoUrl: photoUrl,
      aiRiskStrokeRate: aiRiskStrokeRate,
      status: status,
      lastPredictionTime: lastPredictionTime,
    );
  }

  static String? _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  static Gender _genderFromString(String value) {
    switch (value.toLowerCase()) {
      case 'female':
        return Gender.female;
      case 'male':
      default:
        return Gender.male;
    }
  }
}
