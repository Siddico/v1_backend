import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserEntity> getUser(String id) async {
    final dio = await DioFactory.getDio();
    final response = await dio.get(ApiConstants.me);
    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
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
    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
      final data = response.data['data'];
      return UserEntity.fromJson(data);
    }
    return user;
  }

  @override
  Future<void> updatePatientProfile(String userId, Map<String, dynamic> data) async {
    final dio = await DioFactory.getDio();
    await dio.post(ApiConstants.patientProfile, data: data);
  }

  @override
  Future<void> updateDoctorProfile(String userId, Map<String, dynamic> data) async {
    final dio = await DioFactory.getDio();
    await dio.post(ApiConstants.doctorProfile, data: data);
  }
}
