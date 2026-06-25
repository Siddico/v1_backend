import 'package:cloud_firestore/cloud_firestore.dart';
// Removed firebase_auth import
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../shared/data/datasources/user_remote_datasource.dart';
import '../shared/data/repositories/user_repository_impl.dart';
import '../shared/domain/repositories/user_repository.dart';

/// Provider for SharedPreferences instance.
/// Must be overridden in ProviderScope during initialization.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

// Removed firebaseAuthProvider
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});


final firebaseFunctionsProvider = Provider<FirebaseFunctions>((ref) {
  return FirebaseFunctions.instance;
});

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  return BackendUserDataSource();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.watch(userRemoteDataSourceProvider));
});
