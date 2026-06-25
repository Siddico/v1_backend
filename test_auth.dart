import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  dio.options.validateStatus = (status) => true;

  try {
    final res = await dio.post(
      'https://brainguard.devawy.com/api/v1/auth/register',
      data: {
        'full_name': 'Test User',
        'email': 'testuser2345@example.com',
        'password': 'password123',
        'password_confirmation': 'password123',
        'phone': '1234567890',
        'gender': 'male',
        'role': 'patient',
      },
    );
    print('REGISTER STATUS: ${res.statusCode}');
    print('REGISTER RESPONSE: ${res.data}');
  } catch (e) {
    print('ERROR: $e');
  }
}
