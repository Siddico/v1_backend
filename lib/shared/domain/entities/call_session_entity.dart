class CallSessionArgs {
  const CallSessionArgs({
    required this.contactName,
    required this.contactImage,
    this.startConnected = false,
    this.autoConnectDelay = const Duration(seconds: 3),
    this.elapsedAtStart = Duration.zero,
    this.localPreviewImage,
    this.callSessionId, // Optional reference to the signaling document
    this.isIncoming = false,
  });

  final String contactName;
  final String contactImage;
  final bool startConnected;
  final Duration autoConnectDelay;
  final Duration elapsedAtStart;
  final String? localPreviewImage;
  final String? callSessionId;
  final bool isIncoming;
}

class CallSession {
  const CallSession({
    required this.id,
    required this.initiatorId,
    required this.receiverId,
    required this.callType,
    required this.callStatus,
    this.startedAt,
    this.connectedAt,
    this.endedAt,
    this.durationSeconds,
  });

  final String id;
  final String initiatorId;
  final String receiverId;
  final String callType; // 'audio' or 'video'
  final String callStatus; // 'pending', 'ringing', 'connected', 'ended', 'declined', 'missed'
  final DateTime? startedAt;
  final DateTime? connectedAt;
  final DateTime? endedAt;
  final int? durationSeconds;

  factory CallSession.fromMap(String id, Map<String, dynamic> map) {
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is String) return DateTime.tryParse(value);
      // If it's a Firestore Timestamp
      try {
        return (value as dynamic).toDate() as DateTime;
      } catch (_) {
        return null;
      }
    }

    return CallSession(
      id: id,
      initiatorId: map['initiator_id']?.toString() ?? '',
      receiverId: map['receiver_id']?.toString() ?? '',
      callType: map['call_type']?.toString() ?? 'audio',
      callStatus: map['call_status']?.toString() ?? 'pending',
      startedAt: parseDateTime(map['started_at']),
      connectedAt: parseDateTime(map['connected_at']),
      endedAt: parseDateTime(map['ended_at']),
      durationSeconds: map['duration_seconds'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'initiator_id': initiatorId,
      'receiver_id': receiverId,
      'call_type': callType,
      'call_status': callStatus,
      'started_at': startedAt,
      'connected_at': connectedAt,
      'ended_at': endedAt,
      'duration_seconds': durationSeconds,
    };
  }

  CallSession copyWith({
    String? id,
    String? initiatorId,
    String? receiverId,
    String? callType,
    String? callStatus,
    DateTime? startedAt,
    DateTime? connectedAt,
    DateTime? endedAt,
    int? durationSeconds,
  }) {
    return CallSession(
      id: id ?? this.id,
      initiatorId: initiatorId ?? this.initiatorId,
      receiverId: receiverId ?? this.receiverId,
      callType: callType ?? this.callType,
      callStatus: callStatus ?? this.callStatus,
      startedAt: startedAt ?? this.startedAt,
      connectedAt: connectedAt ?? this.connectedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }
}

