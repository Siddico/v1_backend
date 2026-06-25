import '../../domain/repositories/health_monitoring_repository.dart';
import '../../domain/entities/health_signal_entity.dart';
import '../datasources/health_signal_datasource.dart';

class HealthMonitoringRepositoryImpl implements HealthMonitoringRepository {
  final HealthSignalRemoteDataSource _remoteDataSource;

  HealthMonitoringRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> initialize(String userId) => _remoteDataSource.initialize(userId);

  @override
  void startCollection() => _remoteDataSource.startCollection();

  @override
  Future<void> stopCollection() => _remoteDataSource.stopCollection();

  @override
  void addSignal(HealthSignal signal) => _remoteDataSource.addSignal(signal);

  @override
  Stream<HealthSignal> get signalStream => _remoteDataSource.signalStream;

  @override
  Stream<List<HealthSignal>> get batchStream => _remoteDataSource.batchStream;

  @override
  int get bufferSize => _remoteDataSource.bufferSize;

  @override
  bool get isCollecting => _remoteDataSource.isCollecting;

  @override
  List<HealthSignal> getRecentSignals(int count) => _remoteDataSource.getRecentSignals(count);

  @override
  Future<void> dispose() => _remoteDataSource.dispose();
}
