import '../../../../core/networking/api_constants.dart';
import '../../../../core/networking/dio_factory.dart';

import '../../domain/entities/user_entity.dart';

/// Abstract interface for remote user data operations.
abstract class UserRemoteDataSource {
  Future<UserEntity> getUser(String id);
  Stream<UserEntity> getUserStream(String id);
  Future<UserEntity> updateUser(UserEntity user);
  Future<void> updatePatientProfile(String userId, Map<String, dynamic> data);
  Future<void> updateDoctorProfile(String userId, Map<String, dynamic> data);
}

/// Firebase implementation for user profile operations.
class BackendUserDataSource implements UserRemoteDataSource {
  BackendUserDataSource();

  @override
  Future<UserEntity> getUser(String id) async {
    final dio = await DioFactory.getDio();

    // 1. Try fetching as a patient detail for a doctor (GET /doctor/patients/{id})
    try {
      final response = await dio.get('${ApiConstants.baseUrl}/doctor/patients/$id');
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final patientData = response.data['data']?['patient'];
        if (patientData != null) {
          final userJson = <String, dynamic>{
            'id': patientData['user_id']?.toString() ?? id,
            'name': patientData['full_name'] ?? '',
            'full_name': patientData['full_name'] ?? '',
            'email': patientData['email'] ?? '',
            'phone': patientData['phone'],
            'gender': patientData['gender'],
            'role': 'patient',
            'patient_profile': patientData,
            'photo_url': patientData['photo_url'] ?? patientData['image'],
          };
          return UserEntity.fromJson(userJson);
        }
      }
    } catch (e) {
      // Ignored
    }

    // 2. Try fetching as a doctor profile from /doctors?user_id=$id
    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}/doctors',
        queryParameters: {'user_id': id},
      );
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final List<dynamic> doctors = response.data['data']?['doctors'] ?? [];
        if (doctors.isNotEmpty) {
          final docMap = doctors.first as Map<String, dynamic>;
          final userJson = <String, dynamic>{
            'id': docMap['user_id']?.toString() ?? id,
            'name': docMap['full_name'] ?? docMap['user']?['full_name'] ?? '',
            'full_name': docMap['full_name'] ?? docMap['user']?['full_name'] ?? '',
            'email': docMap['email'] ?? docMap['user']?['email'] ?? '',
            'phone': docMap['phone'],
            'gender': docMap['gender'],
            'role': 'doctor',
            'doctor_profile': docMap,
            'photo_url': docMap['photo_url'] ?? docMap['image'],
          };
          return UserEntity.fromJson(userJson);
        }
      }
    } catch (e) {
      // Ignored
    }

    final response = await dio.get(ApiConstants.me);
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data['data'];
      return UserEntity.fromJson(data);
    }
    throw const FormatException('User profile not found.');
  }

  @override
  Stream<UserEntity> getUserStream(String id) async* {
    // Return a single element stream since REST doesn't support real-time subscriptions
    yield await getUser(id);
  }

  @override
  Future<UserEntity> updateUser(UserEntity user) async {
    final dio = await DioFactory.getDio();
    final response = await dio.put(ApiConstants.me, data: user.toJson());
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data['data'];
      return UserEntity.fromJson(data);
    }
    return user;
  }

  @override
  Future<void> updatePatientProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    final dio = await DioFactory.getDio();
    final updatedData = Map<String, dynamic>.from(data);
    if (updatedData.containsKey('emergency_contact_phone')) {
      updatedData['emergency_number'] = updatedData.remove(
        'emergency_contact_phone',
      );
    }
    if (updatedData.containsKey('medical_history_summary')) {
      updatedData['medical_history'] = updatedData.remove(
        'medical_history_summary',
      );
    }
    await dio.post(ApiConstants.patientProfile, data: updatedData);
  }

  @override
  Future<void> updateDoctorProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    final dio = await DioFactory.getDio();
    final updatedData = Map<String, dynamic>.from(data);
    if (updatedData.containsKey('specialization')) {
      updatedData['specialty'] = updatedData.remove('specialization');
    }
    if (updatedData.containsKey('hospital_affiliation')) {
      updatedData['hospital'] = updatedData.remove('hospital_affiliation');
    }
    if (updatedData.containsKey('years_experience')) {
      updatedData['years_of_experience'] = updatedData.remove(
        'years_experience',
      );
    }
    await dio.post(ApiConstants.doctorProfile, data: updatedData);
  }
}
