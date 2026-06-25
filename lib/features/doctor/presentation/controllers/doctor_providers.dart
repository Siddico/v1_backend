import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/doctor_dashboard_entity.dart';
import '../../data/datasources/doctor_remote_datasource.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../data/repositories/doctor_repository_impl.dart';
import '../../domain/repositories/doctor_repository.dart';

final doctorRemoteDataSourceProvider = Provider<DoctorRemoteDataSource>((ref) {
  final userId = ref.watch(authStateProvider).valueOrNull?.id ?? '';
  return BackendDoctorDataSource(userId: userId);
});

final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  return DoctorRepositoryImpl(ref.watch(doctorRemoteDataSourceProvider));
});

final doctorDashboardProvider = StreamProvider<DoctorDashboardEntity>((ref) {
  return ref.watch(doctorRepositoryProvider).getDashboardStream();
});
