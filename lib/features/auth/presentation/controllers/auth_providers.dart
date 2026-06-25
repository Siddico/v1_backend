import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/networking/local_storage.dart';
import '../../../../shared/domain/entities/user_entity.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_controller.dart';

final authStateProvider = FutureProvider<UserEntity?>((ref) {
  return ref.watch(authRepositoryProvider).getCurrentUser();
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return BackendAuthDataSource(storage: ref.watch(localStorageProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<UserEntity?>>((ref) {
      return AuthController(
        ref.watch(authRepositoryProvider),
        () => ref.invalidate(authStateProvider),
      );
    });
