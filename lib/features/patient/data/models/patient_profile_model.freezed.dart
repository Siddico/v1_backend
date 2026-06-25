// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'patient_profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PatientProfileModel _$PatientProfileModelFromJson(Map<String, dynamic> json) {
  return _PatientProfileModel.fromJson(json);
}

/// @nodoc
mixin _$PatientProfileModel {
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  int? get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  String get fullName => throw _privateConstructorUsedError;
  int get age => throw _privateConstructorUsedError;
  double? get weight => throw _privateConstructorUsedError;
  @JsonKey(name: 'medical_history')
  String? get medicalHistory => throw _privateConstructorUsedError;
  @JsonKey(name: 'emergency_number')
  String? get emergencyNumber => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PatientProfileModelCopyWith<PatientProfileModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PatientProfileModelCopyWith<$Res> {
  factory $PatientProfileModelCopyWith(
          PatientProfileModel value, $Res Function(PatientProfileModel) then) =
      _$PatientProfileModelCopyWithImpl<$Res, PatientProfileModel>;
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'user_id') int? userId,
      @JsonKey(name: 'full_name') String fullName,
      int age,
      double? weight,
      @JsonKey(name: 'medical_history') String? medicalHistory,
      @JsonKey(name: 'emergency_number') String? emergencyNumber,
      String? phone,
      String? gender,
      String? image});
}

/// @nodoc
class _$PatientProfileModelCopyWithImpl<$Res, $Val extends PatientProfileModel>
    implements $PatientProfileModelCopyWith<$Res> {
  _$PatientProfileModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? fullName = null,
    Object? age = null,
    Object? weight = freezed,
    Object? medicalHistory = freezed,
    Object? emergencyNumber = freezed,
    Object? phone = freezed,
    Object? gender = freezed,
    Object? image = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int?,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      age: null == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      medicalHistory: freezed == medicalHistory
          ? _value.medicalHistory
          : medicalHistory // ignore: cast_nullable_to_non_nullable
              as String?,
      emergencyNumber: freezed == emergencyNumber
          ? _value.emergencyNumber
          : emergencyNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PatientProfileModelImplCopyWith<$Res>
    implements $PatientProfileModelCopyWith<$Res> {
  factory _$$PatientProfileModelImplCopyWith(_$PatientProfileModelImpl value,
          $Res Function(_$PatientProfileModelImpl) then) =
      __$$PatientProfileModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'user_id') int? userId,
      @JsonKey(name: 'full_name') String fullName,
      int age,
      double? weight,
      @JsonKey(name: 'medical_history') String? medicalHistory,
      @JsonKey(name: 'emergency_number') String? emergencyNumber,
      String? phone,
      String? gender,
      String? image});
}

/// @nodoc
class __$$PatientProfileModelImplCopyWithImpl<$Res>
    extends _$PatientProfileModelCopyWithImpl<$Res, _$PatientProfileModelImpl>
    implements _$$PatientProfileModelImplCopyWith<$Res> {
  __$$PatientProfileModelImplCopyWithImpl(_$PatientProfileModelImpl _value,
      $Res Function(_$PatientProfileModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? fullName = null,
    Object? age = null,
    Object? weight = freezed,
    Object? medicalHistory = freezed,
    Object? emergencyNumber = freezed,
    Object? phone = freezed,
    Object? gender = freezed,
    Object? image = freezed,
  }) {
    return _then(_$PatientProfileModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int?,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      age: null == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      medicalHistory: freezed == medicalHistory
          ? _value.medicalHistory
          : medicalHistory // ignore: cast_nullable_to_non_nullable
              as String?,
      emergencyNumber: freezed == emergencyNumber
          ? _value.emergencyNumber
          : emergencyNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PatientProfileModelImpl implements _PatientProfileModel {
  const _$PatientProfileModelImpl(
      {this.id,
      @JsonKey(name: 'user_id') this.userId,
      @JsonKey(name: 'full_name') required this.fullName,
      required this.age,
      this.weight,
      @JsonKey(name: 'medical_history') this.medicalHistory,
      @JsonKey(name: 'emergency_number') this.emergencyNumber,
      this.phone,
      this.gender,
      this.image});

  factory _$PatientProfileModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PatientProfileModelImplFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey(name: 'user_id')
  final int? userId;
  @override
  @JsonKey(name: 'full_name')
  final String fullName;
  @override
  final int age;
  @override
  final double? weight;
  @override
  @JsonKey(name: 'medical_history')
  final String? medicalHistory;
  @override
  @JsonKey(name: 'emergency_number')
  final String? emergencyNumber;
  @override
  final String? phone;
  @override
  final String? gender;
  @override
  final String? image;

  @override
  String toString() {
    return 'PatientProfileModel(id: $id, userId: $userId, fullName: $fullName, age: $age, weight: $weight, medicalHistory: $medicalHistory, emergencyNumber: $emergencyNumber, phone: $phone, gender: $gender, image: $image)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PatientProfileModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.medicalHistory, medicalHistory) ||
                other.medicalHistory == medicalHistory) &&
            (identical(other.emergencyNumber, emergencyNumber) ||
                other.emergencyNumber == emergencyNumber) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.image, image) || other.image == image));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, fullName, age,
      weight, medicalHistory, emergencyNumber, phone, gender, image);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PatientProfileModelImplCopyWith<_$PatientProfileModelImpl> get copyWith =>
      __$$PatientProfileModelImplCopyWithImpl<_$PatientProfileModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PatientProfileModelImplToJson(
      this,
    );
  }
}

abstract class _PatientProfileModel implements PatientProfileModel {
  const factory _PatientProfileModel(
      {final int? id,
      @JsonKey(name: 'user_id') final int? userId,
      @JsonKey(name: 'full_name') required final String fullName,
      required final int age,
      final double? weight,
      @JsonKey(name: 'medical_history') final String? medicalHistory,
      @JsonKey(name: 'emergency_number') final String? emergencyNumber,
      final String? phone,
      final String? gender,
      final String? image}) = _$PatientProfileModelImpl;

  factory _PatientProfileModel.fromJson(Map<String, dynamic> json) =
      _$PatientProfileModelImpl.fromJson;

  @override
  int? get id;
  @override
  @JsonKey(name: 'user_id')
  int? get userId;
  @override
  @JsonKey(name: 'full_name')
  String get fullName;
  @override
  int get age;
  @override
  double? get weight;
  @override
  @JsonKey(name: 'medical_history')
  String? get medicalHistory;
  @override
  @JsonKey(name: 'emergency_number')
  String? get emergencyNumber;
  @override
  String? get phone;
  @override
  String? get gender;
  @override
  String? get image;
  @override
  @JsonKey(ignore: true)
  _$$PatientProfileModelImplCopyWith<_$PatientProfileModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
