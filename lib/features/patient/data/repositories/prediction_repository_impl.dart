import '../../domain/repositories/prediction_repository.dart';
import '../../domain/entities/prediction_result_entity.dart';
import '../datasources/prediction_datasource.dart';

class PredictionRepositoryImpl implements PredictionRepository {
  final PredictionRemoteDataSource _remoteDataSource;

  PredictionRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> initialize(String userId) => _remoteDataSource.initialize(userId);

  @override
  Future<void> startListeningToPredictions() => _remoteDataSource.startListeningToPredictions();

  @override
  Future<PredictionWithStatus> getPredictionStatus(String predictionId) => _remoteDataSource.getPredictionStatus(predictionId);

  @override
  Future<void> stopListeningToPredictions() => _remoteDataSource.stopListeningToPredictions();

  @override
  Stream<PredictionResult> get predictionStream => _remoteDataSource.predictionStream;

  @override
  Stream<PredictionWithStatus> get statusStream => _remoteDataSource.statusStream;

  @override
  bool get isListening => _remoteDataSource.isListening;

  @override
  Future<String> requestPrediction(Map<String, dynamic> signalData) => _remoteDataSource.requestPrediction(signalData);

  @override
  Future<List<PredictionResult>> getPredictionHistory(String userId, {int limit = 100}) => _remoteDataSource.getPredictionHistory(userId, limit: limit);

  @override
  Future<void> dispose() => _remoteDataSource.dispose();
}
