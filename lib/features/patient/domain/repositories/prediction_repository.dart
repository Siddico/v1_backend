import '../entities/prediction_result_entity.dart';

abstract class PredictionRepository {
  Future<void> initialize(String userId);
  Future<void> startListeningToPredictions();
  Future<PredictionWithStatus> getPredictionStatus(String predictionId);
  Future<void> stopListeningToPredictions();
  Stream<PredictionResult> get predictionStream;
  Stream<PredictionWithStatus> get statusStream;
  bool get isListening;
  Future<String> requestPrediction(Map<String, dynamic> signalData);
  Future<List<PredictionResult>> getPredictionHistory(String userId, {int limit = 100});
  Future<void> dispose();
}
