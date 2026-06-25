import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/health_data_entity.dart';
import '../../data/datasources/wellness_remote_datasource.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../data/repositories/wellness_repository_impl.dart';
import '../../domain/repositories/wellness_repository.dart';

final wellnessRemoteDataSourceProvider = Provider<WellnessRemoteDataSource>((
  ref,
) {
  final userId = ref.watch(authStateProvider).valueOrNull?.id ?? '';
  return BackendWellnessDataSource(userId: userId);
});

final wellnessRepositoryProvider = Provider<WellnessRepository>((ref) {
  return WellnessRepositoryImpl(ref.watch(wellnessRemoteDataSourceProvider));
});

final healthDataProvider = StreamProvider<List<HealthDataEntity>>((ref) {
  return ref.watch(wellnessRepositoryProvider).getHealthDataStream();
});

final latestHealthDataProvider = Provider<HealthDataEntity?>((ref) {
  return ref
      .watch(healthDataProvider)
      .when(
        data: (data) => data.isEmpty ? null : data.first,
        loading: () => null,
        // ignore: unnecessary_underscores
        error: (_, __) => null,
      );
});
