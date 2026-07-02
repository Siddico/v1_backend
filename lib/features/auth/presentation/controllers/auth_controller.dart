import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums/gender.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/domain/entities/user_entity.dart';
import '../../../../shared/data/services/fcm_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/auth_exception.dart';

class AuthController extends StateNotifier<AsyncValue<UserEntity?>> {
  AuthController(this._repository, this._onSessionChanged)
    : super(const AsyncValue.data(null));

  final AuthRepository _repository;
  final void Function() _onSessionChanged;

  void _markSessionChanged() {
    _onSessionChanged();
  }

  Future<void> login({
    required String email,
    required String password,
    required UserRole selectedRole,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await _repository.login(email: email, password: password);
      if (user.role != selectedRole) {
        await _repository.logout();
        throw const AuthException(
          'Invalid email or password.',
        );
      }
      _markSessionChanged();
      return user;
    });
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
    required Gender gender,
    required UserRole role,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await _repository.signup(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        phone: phone,
        gender: gender,
        role: role,
      );
      _markSessionChanged();
      return user;
    });
  }

  Future<void> logout() async {
    final currentUserId = state.valueOrNull?.id;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (currentUserId != null) {
        await FcmService.instance.removeToken(currentUserId);
      }
      await _repository.logout();
      _markSessionChanged();
      return null;
    });
  }

  Future<void> sendOtp({required String email, required String role}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.sendOtp(email, role);
      return state.valueOrNull;
    });
  }

  Future<void> sendPasswordResetLink({required String email}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.sendPasswordResetLink(email);
      return state.valueOrNull;
    });
  }

  Future<String> verifyOtp({required String email, required String code}) async {
    state = const AsyncValue.loading();
    try {
      final token = await _repository.verifyOtp(email: email, code: code);
      state = AsyncValue.data(state.valueOrNull);
      return token;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.resetPassword(
        email: email,
        otp: otp,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return null;
    });
  }

  /// The user verifies via OTP and resets their password.
  Future<void> resetPasswordWithPhoneBackend({
    required String phone,
    required String newPassword,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      throw const AuthException('Phone password reset is not supported by API yet.');
    });
  }

  /// Re-authenticate the current user and update their password.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    throw const AuthException('Change password is not supported by API yet.');
  }
}
