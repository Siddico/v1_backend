// NOTE: REST API client has been disabled. The application now uses Firebase exclusively.
// If future backend API integration is needed, re-enable this file and ensure proper configuration.
// The original ApiClient implementation has been commented out for safety.

// import 'package:dio/dio.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'api_config.dart';

// /// HTTP client for API communication
// class ApiClient {
//   late Dio _dio;
//   final SharedPreferences _prefs;

//   ApiClient({required SharedPreferences prefs}) : _prefs = prefs {
//     _initializeDio();
//   }

//   void _initializeDio() {
//     _dio = Dio(
//       BaseOptions(
//         baseUrl: ApiConfig.baseUrl,
//         connectTimeout: ApiConfig.connectionTimeout,
//         receiveTimeout: ApiConfig.receiveTimeout,
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       ),
//     );

//     // Add interceptor for token handling
//     _dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) async {
//           final token = _prefs.getString('auth_token');
//           if (token != null) {
//             options.headers['Authorization'] = 'Bearer $token';
//           }
//           return handler.next(options);
//         },
//         onError: (error, handler) {
//           // Handle errors (401 unauthorized, etc.)
//           return handler.next(error);
//         },
//       ),
//     );
//   }

//   /// Send health signal data to backend
//   Future<Response> sendHealthSignal(Map<String, dynamic> data) async {
//     try {
//       final response = await _dio.post(
//         ApiConfig.healthSignalsEndpoint,
//         data: data,
//       );
//       return response;
//     } on DioException {
//       rethrow;
//     }
//   }

//   /// Get prediction result for a specific signal
//   Future<Response> getPrediction(String signalId) async {
//     try {
//       final response = await _dio.get(
//         '${ApiConfig.predictionsEndpoint}/$signalId',
//       );
//       return response;
//     } on DioException {
//       rethrow;
//     }
//   }

//   /// Get user's health data history
//   Future<Response> getUserHealthData(String userId) async {
//     try {
//       final response = await _dio.get(
//         '${ApiConfig.userHealthDataEndpoint}/$userId/health-data',
//       );
//       return response;
//     } on DioException {
//       rethrow;
//     }
//   }

//   Dio get dio => _dio;
// }
