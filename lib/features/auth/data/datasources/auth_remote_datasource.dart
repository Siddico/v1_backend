import 'package:dio/dio.dart';
import '../../../../core/enums/gender.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/networking/api_constants.dart';
import '../../../../core/networking/dio_factory.dart';
import '../../../../core/networking/local_storage.dart';
import '../../../../core/networking/token_storage.dart';
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

  Future<void> sendPasswordResetLink(String email);

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
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      await _storage.clearRole();
      return null;
    }

    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get(ApiConstants.me);

      if ((response.statusCode ?? 0) >= 200 && (response.statusCode ?? 0) < 300) {
        final dataMap = response.data['data'] as Map<String, dynamic>? ?? response.data as Map<String, dynamic>;
        final userData = dataMap['user'] as Map<String, dynamic>? ?? dataMap;
        final user = BackendUserModel.fromJson(userData).toEntity();
        await _storage.saveRole(user.role);
        return user;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await TokenStorage.clearAll();
        await _storage.clearRole();
        return null;
      }
      return null;
    } catch (e) {
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

      if ((response.statusCode ?? 0) >= 200 && (response.statusCode ?? 0) < 300) {
        final dataMap = response.data['data'] as Map<String, dynamic>? ?? response.data as Map<String, dynamic>;
        final token = dataMap['token']?.toString();
        if (token != null && token.isNotEmpty) {
          await TokenStorage.saveToken(token);
        }

        final userData = dataMap['user'] as Map<String, dynamic>? ?? dataMap;
        final user = BackendUserModel.fromJson(userData).toEntity();

        await _storage.saveRole(user.role);
        return user;
      } else {
        throw const AuthException('Login failed.');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const AuthException('An unexpected error occurred. Please try again.');
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
          'gender': gender.name.toLowerCase(),
          'role': role.value.toLowerCase(),
        },
      );

      if ((response.statusCode ?? 0) >= 200 && (response.statusCode ?? 0) < 300) {
        final dataMap = response.data['data'] as Map<String, dynamic>? ?? response.data as Map<String, dynamic>;
        final token = dataMap['token']?.toString();
        if (token != null && token.isNotEmpty) {
          await TokenStorage.saveToken(token);
        }

        final userData = dataMap['user'] as Map<String, dynamic>? ?? dataMap;
        final user = BackendUserModel.fromJson(userData).toEntity();

        await _storage.saveRole(user.role);
        return user;
      } else {
        throw const AuthException('Registration failed.');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const AuthException('An unexpected error occurred. Please try again.');
    }
  }

  @override
  Future<void> logout() async {
    final token = await TokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final dio = await DioFactory.getDio();
        await dio.post(ApiConstants.logout);
      } catch (e) {
        // Always clear local session even if remote call fails
      }
    }
    await TokenStorage.clearAll();
    await _storage.clearRole();
  }

  @override
  Future<void> sendOtp(String email, String role) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.post(
        ApiConstants.sendOtp,
        data: {'email': email},
      );
      if ((response.statusCode ?? 0) < 200 || (response.statusCode ?? 0) >= 300) {
        throw const AuthException('Failed to send OTP.');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const AuthException('An unexpected error occurred. Please try again.');
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

      if ((response.statusCode ?? 0) >= 200 && (response.statusCode ?? 0) < 300) {
        final dataMap = response.data['data'] as Map<String, dynamic>? ?? response.data as Map<String, dynamic>;
        final resetToken = dataMap['reset_token']?.toString() ?? dataMap['token']?.toString() ?? response.data['reset_token']?.toString() ?? response.data['token']?.toString() ?? '';
        await TokenStorage.saveResetToken(resetToken);
        return resetToken;
      } else {
        throw const AuthException('Failed to verify OTP.');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw const AuthException('Invalid or expired OTP code.');
      }
      _handleDioException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const AuthException('An unexpected error occurred. Please try again.');
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    final resetToken = await TokenStorage.getResetToken();
    if (resetToken == null || resetToken.isEmpty) {
      throw const AuthException('Session expired. Please request a new OTP.');
    }

    try {
      final dio = await DioFactory.getDio();
      final response = await dio.post(
        ApiConstants.resetPassword,
        data: {
          'email': email,
          'token': resetToken,
          'reset_token': resetToken,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      if ((response.statusCode ?? 0) < 200 || (response.statusCode ?? 0) >= 300) {
        throw const AuthException('Failed to reset password.');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const AuthException('An unexpected error occurred. Please try again.');
    }
  }

  @override
  Future<void> sendPasswordResetLink(String email) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.post(
        ApiConstants.resetPasswordLink,
        data: {'email': email},
      );
      if ((response.statusCode ?? 0) < 200 || (response.statusCode ?? 0) >= 300) {
        throw const AuthException('Failed to send OTP.');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const AuthException('An unexpected error occurred. Please try again.');
    }
  }

  static Never _handleDioException(DioException e) {
    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;

      if (statusCode == 401) {
        throw const AuthException('Invalid email or password.');
      } else if (statusCode == 403) {
        throw const AuthException('Forbidden request, try again later');
      } else if (statusCode == 404) {
        throw const AuthException('User not found.');
      } else if (statusCode == 422) {
        String errorMessage = 'Validation Error';
        if (data is Map<String, dynamic> && data['errors'] is Map<String, dynamic>) {
          final errors = data['errors'] as Map<String, dynamic>;
          if (errors.containsKey('email')) {
            final val = errors['email'];
            errorMessage = val is List ? val.first.toString() : val.toString();
          } else if (errors.containsKey('phone')) {
            final val = errors['phone'];
            errorMessage = val is List ? val.first.toString() : val.toString();
          } else if (errors.containsKey('password')) {
            final val = errors['password'];
            errorMessage = val is List ? val.first.toString() : val.toString();
          } else if (errors.isNotEmpty) {
            final val = errors.values.first;
            errorMessage = val is List ? val.first.toString() : val.toString();
          }
        } else if (data is Map<String, dynamic> && data['message'] != null) {
          errorMessage = data['message'].toString();
        }
        throw AuthException(errorMessage);
      } else if (data is Map<String, dynamic> && data['message'] != null) {
        throw AuthException(data['message'].toString());
      } else if (statusCode != null && statusCode >= 500) {
        throw const AuthException('Server error, try again later');
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw const AuthException('Connection timeout, try again later');
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        throw const AuthException('Please check your internet connection');
      default:
        throw const AuthException('Network error. Please try again.');
    }
  }
}
