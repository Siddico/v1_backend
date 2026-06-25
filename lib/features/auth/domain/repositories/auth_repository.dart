import '../../../../core/enums/user_role.dart';
import '../../../../core/enums/gender.dart';
import '../../../../shared/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> getCurrentUser();

  Future<UserEntity> login({required String email, required String password});

  Future<UserEntity> signup({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
    required Gender gender,
    required UserRole role,
  });

  Future<void> logout();

  Future<void> sendOtp(String email, String role);

  Future<String> verifyOtp({required String email, required String code});

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  });
}
