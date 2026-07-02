import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:grad_imp_1/core/networking/api_constants.dart';
import 'package:grad_imp_1/core/networking/api_response_parser.dart';
import 'package:grad_imp_1/core/networking/dio_factory.dart';
import 'package:grad_imp_1/features/patient/domain/entities/prediction_result_entity.dart';
import 'package:grad_imp_1/core/services/emergency_call_service.dart';

abstract class PredictionRemoteDataSource {
  Future<void> initialize(String userId);
  Future<void> startListeningToPredictions();
  Future<PredictionWithStatus> getPredictionStatus(String predictionId);
  Future<void> stopListeningToPredictions();
  Stream<PredictionResult> get predictionStream;
  Stream<PredictionWithStatus> get statusStream;
  bool get isListening;
  Future<String> requestPrediction(
    Map<String, dynamic> signalData, {
    bool predictBasedOnFiles = false,
  });
  Future<PredictionResult> requestQuestionnairePrediction(
    Map<String, dynamic> questionnaireData,
  );
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
  final Set<String> _knownPredictionIds = {};

  BackendPredictionDataSource() {
    _predictionStreamController = StreamController<PredictionResult>.broadcast();
    _statusStreamController = StreamController<PredictionWithStatus>.broadcast();
  }

  @override
  Future<void> initialize(String userId) async {
    _userId = userId;
  }

  @override
  Future<void> startListeningToPredictions() async {
    if (_isListening || _userId == null || _userId!.isEmpty) return;
    _isListening = true;

    _pollPredictions();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _pollPredictions();
    });
  }

  Future<void> _pollPredictions() async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get(ApiConstants.patientPredictions);

      if (response.statusCode == 200) {
        final List<dynamic> data = ApiResponseParser.extractList(
          response.data is Map ? response.data['data'] : response.data,
        );

        for (final item in data) {
          if (item is! Map<String, dynamic>) continue;
          final prediction = PredictionResult.fromJson(item);
          
          if (!_knownPredictionIds.contains(prediction.predictionId)) {
            final isNewPrediction = _knownPredictionIds.isNotEmpty;
            _knownPredictionIds.add(prediction.predictionId);

            _predictionStreamController.add(prediction);

            if (prediction.isCritical && isNewPrediction && _userId != null) {
              _sendAlert(prediction);
              EmergencyCallService.instance.checkAndCallIfCritical(
                userId: _userId!,
                isCritical: true,
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error getting predictions: $e');
    }
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
  Stream<PredictionResult> get predictionStream => _predictionStreamController.stream;

  @override
  Stream<PredictionWithStatus> get statusStream => _statusStreamController.stream;

  @override
  bool get isListening => _isListening;

  @override
  Future<String> requestPrediction(
    Map<String, dynamic> signalData, {
    bool predictBasedOnFiles = false,
  }) async {
    if (_userId == null || _userId!.isEmpty) {
      throw Exception('No user available for prediction request.');
    }

    try {
      final dio = await DioFactory.getDio();

      if (!predictBasedOnFiles && signalData.containsKey('raw_data')) {
        // Step 1: Upload signal if provided
        await dio.post(
          ApiConstants.patientSignals,
          data: {
            "signal_type": "PPG",
            "raw_data": signalData['raw_data'] ?? [],
            "source": "wearable"
          },
        );
      }

      // Step 2: Run prediction
      final response = await dio.post(
        ApiConstants.patientPredict,
        data: {"predict_based_on_files": predictBasedOnFiles},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final prediction = response.data['data']['prediction'];
        return prediction['id'].toString();
      } else {
        throw Exception('Failed to request prediction');
      }
    } catch (e) {
      throw Exception('Failed to request prediction: $e');
    }
  }

  @override
  Future<PredictionResult> requestQuestionnairePrediction(
    Map<String, dynamic> questionnaireData,
  ) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.post(
        ApiConstants.patientQuestionnairePredict,
        data: questionnaireData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        final predMap = data is Map && data.containsKey('prediction')
            ? data['prediction'] as Map<String, dynamic>
            : data as Map<String, dynamic>;
        return PredictionResult.fromJson(predMap);
      } else {
        throw Exception('Failed to run questionnaire prediction');
      }
    } catch (e) {
      throw Exception('Failed to run questionnaire prediction: $e');
    }
  }

  @override
  Future<PredictionWithStatus> getPredictionStatus(String predictionId) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get(ApiConstants.patientPredictions);

      if (response.statusCode == 200) {
        final List<dynamic> data = ApiResponseParser.extractList(
          response.data is Map ? response.data['data'] : response.data,
        );
        final item = data.firstWhere(
          (p) => p is Map && (p['id']?.toString() == predictionId || p['prediction_id']?.toString() == predictionId),
          orElse: () => throw Exception('Prediction not found.'),
        );
        
        final status = PredictionWithStatus.fromJson(item as Map<String, dynamic>);
        _statusStreamController.add(status);
        return status;
      }
      throw Exception('Prediction not found.');
    } catch (e) {
      throw Exception('Prediction not found.');
    }
  }

  @override
  Future<List<PredictionResult>> getPredictionHistory(
    String userId, {
    int limit = 100,
  }) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get(ApiConstants.patientPredictions);

      if (response.statusCode == 200) {
        final List<dynamic> data = ApiResponseParser.extractList(
          response.data is Map ? response.data['data'] : response.data,
        );
        return data
            .whereType<Map<String, dynamic>>()
            .take(limit)
            .map((item) => PredictionResult.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting prediction history: $e');
      return [];
    }
  }

  @override
  Future<void> dispose() async {
    await stopListeningToPredictions();
    await _predictionStreamController.close();
    await _statusStreamController.close();
  }
}
