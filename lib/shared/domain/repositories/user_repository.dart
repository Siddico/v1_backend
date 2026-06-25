import '../../domain/entities/user_entity.dart';

/// Abstract interface for user data operations.
/// Defined in the domain layer, implemented in the data layer.
abstract class UserRepository {
  Future<UserEntity> getUser(String id);
  Stream<UserEntity> getUserStream(String id);
  Future<UserEntity> updateUser(UserEntity user);
  Future<void> updatePatientProfile(String userId, Map<String, dynamic> data);
  Future<void> updateDoctorProfile(String userId, Map<String, dynamic> data);
}
