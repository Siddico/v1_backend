// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PatientProfileModelImpl _$$PatientProfileModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PatientProfileModelImpl(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['user_id'] as num?)?.toInt(),
      fullName: json['full_name'] as String,
      age: (json['age'] as num).toInt(),
      weight: (json['weight'] as num?)?.toDouble(),
      medicalHistory: json['medical_history'] as String?,
      emergencyNumber: json['emergency_number'] as String?,
      phone: json['phone'] as String?,
      gender: json['gender'] as String?,
      image: json['image'] as String?,
    );

Map<String, dynamic> _$$PatientProfileModelImplToJson(
        _$PatientProfileModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'full_name': instance.fullName,
      'age': instance.age,
      'weight': instance.weight,
      'medical_history': instance.medicalHistory,
      'emergency_number': instance.emergencyNumber,
      'phone': instance.phone,
      'gender': instance.gender,
      'image': instance.image,
    };
