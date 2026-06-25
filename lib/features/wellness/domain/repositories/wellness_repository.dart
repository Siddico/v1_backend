import '../entities/health_data_entity.dart';

abstract class WellnessRepository {
  Future<List<HealthDataEntity>> getHealthData();
  Stream<List<HealthDataEntity>> getHealthDataStream();
  Future<void> saveHealthData(HealthDataEntity data);
}
