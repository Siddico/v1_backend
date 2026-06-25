import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/enums/gender.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/networking/api_constants.dart';
import '../../../../core/networking/dio_factory.dart';
import '../../../../core/networking/local_storage.dart';
import '../../../../shared/domain/entities/user_entity.dart';
import '../../domain/auth_exception.dart';
import '../models/backend_user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserEntity?> getCurrentUser();

  Future<UserEntity> login(String email, String password);

  Future<UserEntity> signup(
    String name,
    String email,
    String password,
    String passwordConfirmation,
    String phone,
    Gender gender,
    UserRole role,
  );

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

class BackendAuthDataSource implements AuthRemoteDataSource {
  BackendAuthDataSource({required LocalStorage storage}) : _storage = storage;

  final LocalStorage _storage;

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get(ApiConstants.me);

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300 && response.data['success'] == true) {
        final userData = response.data['data']['user'];
        final user = BackendUserModel.fromJson(userData).toEntity();
        await _storage.saveRole(user.role);
        return user;
      }
      return null;
    } catch (e) {
      await _storage.clearRole();
      return null;
    }
  }

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300 && response.data['success'] == true) {
        final token = response.data['data']['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        final userData = response.data['data']['user'];
        final user = BackendUserModel.fromJson(userData).toEntity();

        await _storage.saveRole(user.role);
        return user;
      } else {
        throw AuthException(response.data['message'] ?? 'Login failed.');
      }
    } on DioException catch (e) {
      String errorMessage = 'Registration failed.';
      if (e.response?.data != null) {
        if (e.response?.data['errors'] != null) {
          try {
            final errors = e.response?.data['errors'] as Map<String, dynamic>;
            final firstError = errors.values.first;
            errorMessage = firstError is List ? firstError.first.toString() : firstError.toString();
          } catch (_) {
            errorMessage = e.response?.data['message'] ?? 'Validation Error';
          }
        } else if (e.response?.data['message'] != null) {
          errorMessage = e.response!.data['message'].toString();
        }
      }
      throw AuthException(errorMessage);
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<UserEntity> signup(
    String name,
    String email,
    String password,
    String passwordConfirmation,
    String phone,
    Gender gender,
    UserRole role,
  ) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.post(
        ApiConstants.register,
        data: {
          'full_name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'phone': phone,
          'gender': gender.name,
          'role': role.value,
          'agreement': true,
        },
      );

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300 && response.data['success'] == true) {
        final token = response.data['data']['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        final userData = response.data['data']['user'];
        final user = BackendUserModel.fromJson(userData).toEntity();

        await _storage.saveRole(user.role);
        return user;
      } else {
        throw AuthException(response.data['message'] ?? 'Registration failed.');
      }
    } on DioException catch (e) {
      String errorMessage = 'Request failed.';
      if (e.response?.data != null) {
        if (e.response?.data['errors'] != null) {
          try {
            final errors = e.response?.data['errors'] as Map<String, dynamic>;
            final firstError = errors.values.first;
            errorMessage = firstError is List ? firstError.first.toString() : firstError.toString();
          } catch (_) {
            errorMessage = e.response?.data['message'] ?? 'Validation Error';
          }
        } else if (e.response?.data['message'] != null) {
          errorMessage = e.response!.data['message'].toString();
        }
      }
      throw AuthException(errorMessage);
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final dio = await DioFactory.getDio();
      await dio.post(ApiConstants.logout);
    } catch (e) {
      // Ignore logout errors
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await _storage.clearRole();
    }
  }

  @override
  Future<void> sendOtp(String email, String role) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.post(
        ApiConstants.sendOtp,
        data: {
          'email': email,
        },
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw AuthException(response.data['message'] ?? 'Failed to send OTP.');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to send OTP.';
      throw AuthException(message);
    }
  }

  @override
  Future<String> verifyOtp({required String email, required String code}) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.post(
        ApiConstants.verifyOtp,
        data: {'email': email, 'code': code},
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw AuthException(response.data['message'] ?? 'Invalid OTP.');
      }
      
      return response.data['data']['reset_token'] as String;
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Invalid OTP.';
      throw AuthException(message);
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      if (password != passwordConfirmation) {
        throw const AuthException('Passwords do not match.');
      }

      final dio = await DioFactory.getDio();
      // Since the frontend previously passed 'otp', we map it to 'token' which is expected by Laravel backend
      final response = await dio.post(
        ApiConstants.resetPassword,
        data: {
          'email': email,
          'token': otp,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw AuthException(
          response.data['message'] ?? 'Failed to reset password.',
        );
      }
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ?? 'Failed to reset password.';
      throw AuthException(message);
    }
  }
}
