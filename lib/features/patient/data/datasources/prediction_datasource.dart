import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:grad_imp_1/core/networking/api_constants.dart';
import 'package:grad_imp_1/core/networking/api_response_parser.dart';
import 'package:grad_imp_1/core/networking/dio_factory.dart';
import 'package:grad_imp_1/features/patient/domain/entities/prediction_result_entity.dart';
import 'package:grad_imp_1/core/services/emergency_call_service.dart';

/// Service for handling AI model predictions from real-time signals
abstract class PredictionRemoteDataSource {
  Future<void> initialize(String userId);
  Future<void> startListeningToPredictions();
  Future<PredictionWithStatus> getPredictionStatus(String predictionId);
  Future<void> stopListeningToPredictions();
  Stream<PredictionResult> get predictionStream;
  Stream<PredictionWithStatus> get statusStream;
  bool get isListening;
  Future<String> requestPrediction(Map<String, dynamic> signalData);
  Future<List<PredictionResult>> getPredictionHistory(
    String userId, {
    int limit = 100,
  });
  Future<void> dispose();
}

class BackendPredictionDataSource implements PredictionRemoteDataSource {
  late final StreamController<PredictionResult> _predictionStreamController;
  late final StreamController<PredictionWithStatus> _statusStreamController;

  String? _userId;
  bool _isListening = false;
  Timer? _pollingTimer;
  Set<String> _knownPredictionIds = {};

  BackendPredictionDataSource() {
    _predictionStreamController =
        StreamController<PredictionResult>.broadcast();
    _statusStreamController =
        StreamController<PredictionWithStatus>.broadcast();
  }

  @override
  Future<void> initialize(String userId) async {
    _userId = userId;
  }

  bool _isInitialFetch = true;

  @override
  Future<void> startListeningToPredictions() async {
    if (_isListening || _userId == null || _userId!.isEmpty) return;
    _isListening = true;
    _isInitialFetch = true;

    // Start polling the API every 10 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _pollPredictions();
    });

    // Initial fetch
    _pollPredictions();
  }

  Future<void> _pollPredictions() async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get(ApiConstants.patientPredictions);

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        dynamic rawData = response.data['data'];
        List<dynamic> data = ApiResponseParser.extractList(rawData);

        for (final item in data) {
          final prediction = PredictionResult.fromJson(
            item as Map<String, dynamic>,
          );

          if (!_knownPredictionIds.contains(prediction.predictionId)) {
            _knownPredictionIds.add(prediction.predictionId);

            final isNewPrediction = !_isInitialFetch;

            _predictionStreamController.add(prediction);

            if (prediction.isCritical && isNewPrediction) {
              _sendAlert(prediction);
              EmergencyCallService.instance.checkAndCallIfCritical(
                userId: _userId!,
                isCritical: true,
              );
            }
          }
        }
      }
      _isInitialFetch = false;
    } catch (e) {
      debugPrint('Error getting prediction history: $e');
    }
  }

  @override
  Future<PredictionWithStatus> getPredictionStatus(String predictionId) async {
    // In a REST environment, we might fetch a specific prediction or filter the list
    final dio = await DioFactory.getDio();
    final response = await dio.get(ApiConstants.patientPredictions);

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      dynamic rawData = response.data['data'];
      List<dynamic> data = ApiResponseParser.extractList(rawData);

      final item = data.firstWhere(
        (p) => p['id'].toString() == predictionId,
        orElse: () => null,
      );
      if (item != null) {
        final status = PredictionWithStatus.fromJson(
          item as Map<String, dynamic>,
        );
        _statusStreamController.add(status);
        return status;
      }
    }
    throw Exception('Prediction not found.');
  }

  void _sendAlert(PredictionResult prediction) {
    debugPrint('🚨 ALERT: High stroke risk detected!');
    debugPrint('Risk Score: ${prediction.riskScore}');
    debugPrint('Confidence: ${prediction.confidence}');
  }

  @override
  Future<void> stopListeningToPredictions() async {
    _isListening = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  Stream<PredictionResult> get predictionStream =>
      _predictionStreamController.stream;

  @override
  Stream<PredictionWithStatus> get statusStream =>
      _statusStreamController.stream;

  @override
  bool get isListening => _isListening;

  @override
  Future<String> requestPrediction(Map<String, dynamic> signalData) async {
    if (_userId == null || _userId!.isEmpty) {
      throw Exception('No user available for prediction request.');
    }

    final dio = await DioFactory.getDio();
    // Assuming backend expects "ppg_file" or "file" and we must use FormData
    // But since the old code was passing predict_based_on_files as a bool, let's keep it if we can't be sure,
    // wait I'll fix this in step 4. For now just leave this method unchanged.
    final response = await dio.post(
      ApiConstants.patientPredict,
      data: {
        'patient_id': int.tryParse(_userId!) ?? 0,
        'predict_based_on_files': signalData['predict_based_on_files'] ?? false,
      },
    );

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      // Return the ID if the backend provides it, otherwise return a placeholder or parse from the result
      return response.data['data']?['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString();
    } else {
      throw Exception('Failed to request prediction');
    }
  }

  @override
  Future<List<PredictionResult>> getPredictionHistory(
    String userId, {
    int limit = 100,
  }) async {
    final dio = await DioFactory.getDio();
    final response = await dio.get(ApiConstants.patientPredictions);

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      dynamic rawData = response.data['data'];
      List<dynamic> data = ApiResponseParser.extractList(rawData);

      return data
          .take(limit)
          .map(
            (item) => PredictionResult.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }
    return [];
  }

  @override
  Future<void> dispose() async {
    await stopListeningToPredictions();
    await _predictionStreamController.close();
    await _statusStreamController.close();
  }
}
