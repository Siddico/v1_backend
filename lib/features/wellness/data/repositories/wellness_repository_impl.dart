import '../../domain/entities/health_data_entity.dart';
import '../../domain/repositories/wellness_repository.dart';
import '../datasources/wellness_remote_datasource.dart';

class WellnessRepositoryImpl implements WellnessRepository {
  WellnessRepositoryImpl(this._remoteDataSource);
  final WellnessRemoteDataSource _remoteDataSource;

  @override
  Future<List<HealthDataEntity>> getHealthData() async {
    final rawData = await _remoteDataSource.getHealthData();
    return rawData
        .map(
          (json) => HealthDataEntity(
            heartRate: (json['heartRate'] as num?)?.toInt() ?? 0,
            bloodPressure: json['bloodPressure']?.toString() ?? '0/0',
            temperature: (json['temperature'] as num?)?.toDouble() ?? 0,
            weight: (json['weight'] as num?)?.toDouble() ?? 0,
            height: (json['height'] as num?)?.toDouble() ?? 0,
            date:
                DateTime.tryParse(json['date']?.toString() ?? '') ??
                DateTime.now(),
            oxygenSaturation: (json['oxygenSaturation'] as num?)?.toInt() ?? 98,
            riskScore: (json['riskScore'] as num?)?.toDouble() ?? 46,
          ),
        )
        .toList();
  }

  @override
  Stream<List<HealthDataEntity>> getHealthDataStream() {
    return _remoteDataSource.getHealthDataStream().map((list) {
      return list.map((json) => HealthDataEntity.fromJson(json)).toList();
    });
  }

  @override
  Future<void> saveHealthData(HealthDataEntity data) async {
    await _remoteDataSource.saveHealthData({
      'heartRate': data.heartRate,
      'bloodPressure': data.bloodPressure,
      'temperature': data.temperature,
      'weight': data.weight,
      'height': data.height,
      'date': data.date.toIso8601String(),
      'oxygenSaturation': data.oxygenSaturation,
      'riskScore': data.riskScore,
    });
  }
}
