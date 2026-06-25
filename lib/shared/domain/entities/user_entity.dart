import '../../../core/enums/user_role.dart';

class UserEntity {
  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.gender,
    this.dateOfBirth,
    this.doctorProfile,
    this.patientProfile,
    this.photoUrl,
    this.aiRiskStrokeRate,
    this.status,
    this.lastPredictionTime,
  });

  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? phone;
  final String? gender;
  final String? dateOfBirth;
  final Map<String, dynamic>? doctorProfile;
  final Map<String, dynamic>? patientProfile;
  final String? photoUrl;
  final double? aiRiskStrokeRate;
  final String? status;
  final DateTime? lastPredictionTime;

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? phone,
    String? gender,
    String? dateOfBirth,
    Map<String, dynamic>? doctorProfile,
    Map<String, dynamic>? patientProfile,
    String? photoUrl,
    double? aiRiskStrokeRate,
    String? status,
    DateTime? lastPredictionTime,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      doctorProfile: doctorProfile ?? this.doctorProfile,
      patientProfile: patientProfile ?? this.patientProfile,
      photoUrl: photoUrl ?? this.photoUrl,
      aiRiskStrokeRate: aiRiskStrokeRate ?? this.aiRiskStrokeRate,
      status: status ?? this.status,
      lastPredictionTime: lastPredictionTime ?? this.lastPredictionTime,
    );
  }

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: UserRoleX.fromString(json['role']?.toString() ?? 'patient'),
      phone: json['phone']?.toString(),
      gender: json['gender']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString() ?? json['patient_profile']?['date_of_birth']?.toString(),
      doctorProfile: json['doctor_profile'] as Map<String, dynamic>?,
      patientProfile: json['patient_profile'] as Map<String, dynamic>?,
      photoUrl: json['photo_url']?.toString() ?? json['image']?.toString(),
      aiRiskStrokeRate: (json['ai_risk_stroke_rate'] as num?)?.toDouble(),
      status: json['status']?.toString(),
      lastPredictionTime: json['last_prediction_time'] != null 
          ? (json['last_prediction_time'] is String 
              ? DateTime.tryParse(json['last_prediction_time']) 
              : (json['last_prediction_time'] as dynamic).toDate()) // handle Timestamp
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.value,
      'phone': phone,
      'gender': gender,
      'doctor_profile': doctorProfile,
      'patient_profile': patientProfile,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (photoUrl != null) 'image': photoUrl,
      if (aiRiskStrokeRate != null) 'ai_risk_stroke_rate': aiRiskStrokeRate,
      if (status != null) 'status': status,
      if (lastPredictionTime != null) 'last_prediction_time': lastPredictionTime!.toIso8601String(),
    };
  }
}
