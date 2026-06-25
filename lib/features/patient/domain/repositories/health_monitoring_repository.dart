import '../entities/health_signal_entity.dart';

abstract class HealthMonitoringRepository {
  Future<void> initialize(String userId);
  void startCollection();
  Future<void> stopCollection();
  void addSignal(HealthSignal signal);
  Stream<HealthSignal> get signalStream;
  Stream<List<HealthSignal>> get batchStream;
  int get bufferSize;
  bool get isCollecting;
  List<HealthSignal> getRecentSignals(int count);
  Future<void> dispose();
}
