import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';

/// Concrete implementation of [UserRepository].
/// Delegates all operations to the remote data source.
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._remoteDataSource);
  final UserRemoteDataSource _remoteDataSource;

  @override
  Future<UserEntity> getUser(String id) => _remoteDataSource.getUser(id);

  @override
  Stream<UserEntity> getUserStream(String id) => _remoteDataSource.getUserStream(id);

  @override
  Future<UserEntity> updateUser(UserEntity user) =>
      _remoteDataSource.updateUser(user);

  @override
  Future<void> updatePatientProfile(String userId, Map<String, dynamic> data) =>
      _remoteDataSource.updatePatientProfile(userId, data);

  @override
  Future<void> updateDoctorProfile(String userId, Map<String, dynamic> data) =>
      _remoteDataSource.updateDoctorProfile(userId, data);
}
