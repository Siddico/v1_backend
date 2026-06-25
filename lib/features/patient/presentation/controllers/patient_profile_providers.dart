import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../injection/core_providers.dart';
import '../../../../shared/domain/entities/user_entity.dart';

final patientDetailsProvider = StreamProvider.family<UserEntity, String>((ref, patientId) {
  return ref.watch(userRepositoryProvider).getUserStream(patientId);
});
