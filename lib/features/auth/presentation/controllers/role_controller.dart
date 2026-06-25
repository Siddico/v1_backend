import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/networking/local_storage.dart';
import '../../../../injection/core_providers.dart';
import 'auth_providers.dart';

class RoleController extends StateNotifier<UserRole?> {
  RoleController(this._ref, this._storage) : super(null) {
    _loadRole();
  }

  final Ref _ref;
  final LocalStorage _storage;

  void _loadRole() {
    state = _storage.getRole();
  }

  /// Persist selected role locally and, if a user is logged in,
  /// update the user's role on the backend via `UserRepository`.
  Future<void> setRole(UserRole role) async {
    state = role;
    await _storage.saveRole(role);

    try {
      final authState = _ref.read(authControllerProvider);
      final currentUser = authState.valueOrNull;
      if (currentUser != null) {
        final userRepo = _ref.read(userRepositoryProvider);
        final updated = currentUser.copyWith(role: role);
        await userRepo.updateUser(updated);
      }
    } catch (_) {
      // Ignore backend update failures here; role is still saved locally.
    }
  }

  Future<void> clearRole() async {
    state = null;
    await _storage.clearRole();
  }
}

final roleProvider = StateNotifierProvider<RoleController, UserRole?>((ref) {
  return RoleController(ref, ref.watch(localStorageProvider));
});
