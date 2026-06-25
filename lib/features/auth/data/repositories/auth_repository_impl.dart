import '../../../../shared/domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/enums/gender.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<UserEntity?> getCurrentUser() {
    return _remoteDataSource.getCurrentUser();
  }

  @override
  Future<UserEntity> login({required String email, required String password}) {
    return _remoteDataSource.login(email, password);
  }

  @override
  Future<UserEntity> signup({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
    required Gender gender,
    required UserRole role,
  }) {
    return _remoteDataSource.signup(
      name,
      email,
      password,
      passwordConfirmation,
      phone,
      gender,
      role,
    );
  }

  @override
  Future<void> logout() {
    return _remoteDataSource.logout();
  }

  @override
  Future<void> sendOtp(String email, String role) {
    return _remoteDataSource.sendOtp(email, role);
  }

  @override
  Future<String> verifyOtp({required String email, required String code}) {
    return _remoteDataSource.verifyOtp(email: email, code: code);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) {
    return _remoteDataSource.resetPassword(
      email: email,
      otp: otp,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}
