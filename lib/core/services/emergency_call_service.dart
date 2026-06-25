import 'dart:async';

import 'package:url_launcher/url_launcher.dart';
import '../../shared/data/datasources/user_remote_datasource.dart';

/// Service responsible for placing emergency calls when the AI model
/// returns a critical stroke-risk prediction.
///
/// Usage:
///   EmergencyCallService.instance.checkAndCallIfCritical(
///     userId: uid,
///     isCritical: prediction.isCritical,
///   );
class EmergencyCallService {
  EmergencyCallService._();
  static final EmergencyCallService instance = EmergencyCallService._();

  // Guard: only trigger one call per [_cooldownDuration] window.
  static const _cooldownDuration = Duration(minutes: 15);
  DateTime? _lastCallAttempt;

  /// Fetches the patient's emergency contact from Firestore and places
  /// a phone call if [isCritical] is true and the cooldown has passed.
  Future<void> checkAndCallIfCritical({
    required String userId,
    required bool isCritical,
  }) async {
    if (!isCritical) return;

    // Respect cooldown to avoid calling repeatedly on consecutive predictions.
    final now = DateTime.now();
    if (_lastCallAttempt != null &&
        now.difference(_lastCallAttempt!) < _cooldownDuration) {
      return;
    }

    final phone = await _fetchEmergencyPhone(userId);
    if (phone == null || phone.isEmpty) return;

    _lastCallAttempt = now;
    await _placeCall(phone);
  }

  /// Retrieves `emergency_contact_phone` from the patient's API profile.
  Future<String?> _fetchEmergencyPhone(String userId) async {
    try {
      final userDataSource = BackendUserDataSource();
      final user = await userDataSource.getUser(userId);
      return user.patientProfile?['emergency_contact_phone']?.toString();
    } catch (_) {
      return null;
    }
  }

  /// Launches the native phone dialer with [phoneNumber].
  Future<void> _placeCall(String phoneNumber) async {
    // Normalise the number: strip whitespace, ensure tel: prefix.
    final cleaned = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Call this to manually reset the cooldown (e.g., in tests).
  void resetCooldown() => _lastCallAttempt = null;
}
