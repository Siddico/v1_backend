import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grad_imp_1/core/enums/user_role.dart';
import 'package:grad_imp_1/features/patient/domain/entities/prediction_result_entity.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../data/datasources/health_signal_datasource.dart';
import '../../data/datasources/prediction_datasource.dart';
import '../../data/repositories/health_monitoring_repository_impl.dart';
import '../../data/repositories/prediction_repository_impl.dart';
import '../../domain/repositories/health_monitoring_repository.dart';
import '../../domain/repositories/prediction_repository.dart';
import 'health_monitoring_controller.dart';

final healthSignalRemoteDataSourceProvider =
    Provider<HealthSignalRemoteDataSource>((ref) {
      return BackendHealthSignalDataSource();
    });

final predictionRemoteDataSourceProvider = Provider<PredictionRemoteDataSource>(
  (ref) {
    return BackendPredictionDataSource();
  },
);

final healthMonitoringRepositoryProvider = Provider<HealthMonitoringRepository>(
  (ref) {
    return HealthMonitoringRepositoryImpl(
      ref.watch(healthSignalRemoteDataSourceProvider),
    );
  },
);

final predictionRepositoryProvider = Provider<PredictionRepository>((ref) {
  return PredictionRepositoryImpl(
    ref.watch(predictionRemoteDataSourceProvider),
  );
});

final predictionHistoryProvider =
    FutureProvider.family<List<PredictionResult>, String>((ref, userId) {
      return ref
          .watch(predictionRepositoryProvider)
          .getPredictionHistory(userId, limit: 100);
    });

final healthMonitoringControllerProvider =
    StateNotifierProvider<HealthMonitoringController, HealthMonitoringState>((
      ref,
    ) {
      final currentUser = ref.watch(authStateProvider).valueOrNull;
      final userId = currentUser?.id ?? '';
      final isDoctor = currentUser?.role == UserRole.doctor;
      return HealthMonitoringController(
        ref.watch(healthMonitoringRepositoryProvider),
        ref.watch(predictionRepositoryProvider),
        userId,
        isDoctor: isDoctor,
      );
    });

final healthMonitoringControllerProviderFamily =
    StateNotifierProvider.family<
      HealthMonitoringController,
      HealthMonitoringState,
      String
    >((ref, userId) {
      final currentUser = ref.watch(authStateProvider).valueOrNull;
      final isDoctor = currentUser?.role == UserRole.doctor;
      return HealthMonitoringController(
        ref.watch(healthMonitoringRepositoryProvider),
        ref.watch(predictionRepositoryProvider),
        userId,
        isDoctor: isDoctor,
      );
    });
