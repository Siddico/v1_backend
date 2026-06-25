import 'package:equatable/equatable.dart';

/// Real-time health signal data model
class HealthSignal extends Equatable {
  final String signalId; // Generated on backend
  final String userId;
  final DateTime timestamp;
  final double heartRate; // BPM
  final double ppgSignal; // PPG sensor reading
  final double? temperature; // Optional
  final double? spO2; // Optional - Blood Oxygen
  final Map<String, dynamic>? additionalData; // For other sensor readings

  const HealthSignal({
    required this.signalId,
    required this.userId,
    required this.timestamp,
    required this.heartRate,
    required this.ppgSignal,
    this.temperature,
    this.spO2,
    this.additionalData,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'signal_id': signalId,
      'user_id': userId,
      'timestamp': timestamp.toIso8601String(),
      'heart_rate': heartRate,
      'ppg_signal': ppgSignal,
      'temperature': temperature,
      'spo2': spO2,
      'additional_data': additionalData,
    };
  }

  /// Create from JSON response
  factory HealthSignal.fromJson(Map<String, dynamic> json) {
    return HealthSignal(
      signalId: json['signal_id'] ?? '',
      userId: json['user_id'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      heartRate: (json['heart_rate'] ?? 0).toDouble(),
      ppgSignal: (json['ppg_signal'] ?? 0).toDouble(),
      temperature: json['temperature']?.toDouble(),
      spO2: json['spo2']?.toDouble(),
      additionalData: json['additional_data'],
    );
  }

  /// Create a copy with modifications
  HealthSignal copyWith({
    String? signalId,
    String? userId,
    DateTime? timestamp,
    double? heartRate,
    double? ppgSignal,
    double? temperature,
    double? spO2,
    Map<String, dynamic>? additionalData,
  }) {
    return HealthSignal(
      signalId: signalId ?? this.signalId,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      heartRate: heartRate ?? this.heartRate,
      ppgSignal: ppgSignal ?? this.ppgSignal,
      temperature: temperature ?? this.temperature,
      spO2: spO2 ?? this.spO2,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  List<Object?> get props => [
    signalId,
    userId,
    timestamp,
    heartRate,
    ppgSignal,
    temperature,
    spO2,
    additionalData,
  ];

  @override
  String toString() => 'HealthSignal('
      'signalId: $signalId, '
      'userId: $userId, '
      'heartRate: $heartRate, '
      'ppgSignal: $ppgSignal)';
}

/// Batch of health signals (for efficient transmission)
class HealthSignalBatch extends Equatable {
  final String userId;
  final List<HealthSignal> signals;
  final DateTime batchTimestamp;

  const HealthSignalBatch({
    required this.userId,
    required this.signals,
    required this.batchTimestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'signals': signals.map((s) => s.toJson()).toList(),
      'batch_timestamp': batchTimestamp.toIso8601String(),
    };
  }

  @override
  List<Object> get props => [userId, signals, batchTimestamp];
}
