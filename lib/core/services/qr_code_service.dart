import 'dart:convert';

/// Service to store and retrieve QR‑code data for a user.
class QRCodeService {

  /// Stores a JSON payload containing the user's uid and role.
  Future<void> storeQrData({required String uid, required String role}) async {
    // Left empty for API implementation if needed in the future
  }

  /// Retrieves the QR‑code JSON payload for the given uid.
  /// Returns a Map with keys `uid` and `role` or null if not set.
  Future<Map<String, dynamic>?> fetchQrData({required String uid}) async {
    return null;
  }
}
