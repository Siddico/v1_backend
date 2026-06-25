import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient_profile_model.freezed.dart';
part 'patient_profile_model.g.dart';

@freezed
class PatientProfileModel with _$PatientProfileModel {
  const factory PatientProfileModel({
    int? id,
    @JsonKey(name: 'user_id') int? userId,
    @JsonKey(name: 'full_name') required String fullName,
    required int age,
    double? weight,
    @JsonKey(name: 'medical_history') String? medicalHistory,
    @JsonKey(name: 'emergency_number') String? emergencyNumber,
    String? phone,
    String? gender,
    String? image,
  }) = _PatientProfileModel;

  factory PatientProfileModel.fromJson(Map<String, dynamic> json) => 
      _$PatientProfileModelFromJson(json);
}
