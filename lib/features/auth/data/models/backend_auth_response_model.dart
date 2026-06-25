import '../../../../core/enums/user_role.dart';
import '../../../../shared/domain/entities/user_entity.dart';
import 'backend_user_model.dart';

class BackendAuthResponseModel {
  const BackendAuthResponseModel({
    required this.success,
    required this.message,
    required this.token,
    required this.user,
    required this.role,
  });

  final bool success;
  final String message;
  final String token;
  final UserEntity user;
  final UserRole role;

  factory BackendAuthResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final userJson = data['user'] as Map<String, dynamic>? ?? const {};
    final user = BackendUserModel.fromJson(userJson).toEntity();
    final roleValue = _firstNonEmpty([
      data['role'],
      userJson['role'] is Map<String, dynamic>
          ? (userJson['role'] as Map<String, dynamic>)['name_of_role']
          : userJson['role'],
      user.role.value,
    ]);

    return BackendAuthResponseModel(
      success: json['success'] == true || data['token'] != null,
      message: json['message']?.toString() ?? '',
      token: data['token']?.toString() ?? '',
      user: user,
      role: UserRoleX.fromString(roleValue ?? 'patient'),
    );
  }

  static String? _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }
}
