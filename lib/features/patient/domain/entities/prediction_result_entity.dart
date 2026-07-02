import 'package:equatable/equatable.dart';

DateTime _parseDateTime(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}

/// Prediction result from AI model
class PredictionResult extends Equatable {
  final String predictionId;
  final String signalId;
  final String userId;
  final DateTime predictionTimestamp;
  final String strokeRisk; // 'low', 'medium', 'high', 'moderate'
  final String prediction; // e.g., 'PAC', 'AF', 'NSR'
  final double riskScore; // 0.0 to 1.0
  final double confidence; // 0.0 to 1.0
  final String status; // UI status string (af, pac, nsr, etc.)
  final Map<String, dynamic>? modelOutput; // Raw model output data
  final String? message; // Human-readable message
  final dynamic recommendations; // Health recommendations (List or Map)
  final String? predictionType;
  final String? overview;
  final String? modelVersion;
  final bool? predictBasedOnFiles;
  final Map<String, dynamic>? probabilities;

  const PredictionResult({
    required this.predictionId,
    required this.signalId,
    required this.userId,
    required this.predictionTimestamp,
    required this.strokeRisk,
    required this.prediction,
    required this.riskScore,
    required this.confidence,
    required this.status,
    this.modelOutput,
    this.message,
    this.recommendations,
    this.predictionType,
    this.overview,
    this.modelVersion,
    this.predictBasedOnFiles,
    this.probabilities,
  });

  /// Create from JSON response
  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    double calcRiskScore = 0.0;
    if (json['risk_score'] != null) {
      calcRiskScore = (json['risk_score'] as num).toDouble();
    } else if (json['score'] != null) {
      final s = (json['score'] as num).toDouble();
      calcRiskScore = s > 1.0 ? s / 100.0 : s;
    }

    return PredictionResult(
      predictionId: (json['prediction_id'] ?? json['id'] ?? '').toString(),
      signalId: (json['signal_id'] ?? '').toString(),
      userId: (json['user_id'] ?? json['patient_id'] ?? '').toString(),
      predictionTimestamp: _parseDateTime(
        json['prediction_timestamp'] ?? json['predicted_at'] ?? json['created_at'],
      ),
      strokeRisk: (json['stroke_risk'] ?? json['risk_level'] ?? 'low').toString(),
      prediction: (json['prediction'] ?? '').toString(),
      riskScore: calcRiskScore,
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      status: (json['status'] ?? '').toString(),
      modelOutput: json['model_output'] is Map<String, dynamic> ? json['model_output'] : null,
      message: json['message']?.toString(),
      recommendations: json['recommendations'],
      predictionType: json['prediction_type']?.toString(),
      overview: json['overview']?.toString(),
      modelVersion: json['model_version']?.toString(),
      predictBasedOnFiles: json['predict_based_on_files'] as bool?,
      probabilities: json['probabilities'] is Map<String, dynamic>
          ? json['probabilities']
          : (json['probabilities'] is Map
              ? Map<String, dynamic>.from(json['probabilities'])
              : null),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'prediction_id': predictionId,
      'signal_id': signalId,
      'user_id': userId,
      'prediction_timestamp': predictionTimestamp.toIso8601String(),
      'stroke_risk': strokeRisk,
      'prediction': prediction,
      'risk_score': riskScore,
      'confidence': confidence,
      'status': status,
      'model_output': modelOutput,
      'message': message,
      'recommendations': recommendations,
      'prediction_type': predictionType,
      'overview': overview,
      'model_version': modelVersion,
      'predict_based_on_files': predictBasedOnFiles,
      'probabilities': probabilities,
    };
  }

  /// Helper to create a copy with modified fields
  PredictionResult copyWith({
    String? status,
  }) {
    return PredictionResult(
      predictionId: predictionId,
      signalId: signalId,
      userId: userId,
      predictionTimestamp: predictionTimestamp,
      strokeRisk: strokeRisk,
      prediction: prediction,
      riskScore: riskScore,
      confidence: confidence,
      status: status ?? this.status,
      modelOutput: modelOutput,
      message: message,
      recommendations: recommendations,
      predictionType: predictionType,
      overview: overview,
      modelVersion: modelVersion,
      predictBasedOnFiles: predictBasedOnFiles,
      probabilities: probabilities,
    );
  }

  /// Check if risk is high
  bool get isHighRisk => strokeRisk == 'high' || riskScore > 0.7;

  /// Check if result is critical (needs immediate action)
  bool get isCritical => strokeRisk == 'high' && confidence > 0.8;

  @override
  List<Object?> get props => [
        predictionId,
        signalId,
        userId,
        predictionTimestamp,
        strokeRisk,
        prediction,
        riskScore,
        confidence,
        status,
        modelOutput,
        message,
        recommendations,
        predictionType,
        overview,
        modelVersion,
        predictBasedOnFiles,
        probabilities,
      ];

  @override
  String toString() =>
      'PredictionResult(predictionId: $predictionId, prediction: $prediction, strokeRisk: $strokeRisk, riskScore: $riskScore, status: $status)';
}

/// Status of a prediction (pending, processing, completed, failed)
enum PredictionStatus { pending, processing, completed, failed }

/// Prediction with status tracking
class PredictionWithStatus extends Equatable {
  final String predictionId;
  final String signalId;
  final PredictionStatus status;
  final PredictionResult? result;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? completedAt;

  const PredictionWithStatus({
    required this.predictionId,
    required this.signalId,
    required this.status,
    this.result,
    this.errorMessage,
    required this.createdAt,
    this.completedAt,
  });

  factory PredictionWithStatus.fromJson(Map<String, dynamic> json) {
    return PredictionWithStatus(
      predictionId: json['prediction_id'] ?? json['id'] ?? '',
      signalId: json['signal_id'] ?? '',
      status: _parseStatus(json['status']),
      result: json['result'] != null ? PredictionResult.fromJson(json['result']) : null,
      errorMessage: json['error_message'],
      createdAt: _parseDateTime(json['created_at']),
      completedAt: json['completed_at'] != null ? _parseDateTime(json['completed_at']) : null,
    );
  }

  static PredictionStatus _parseStatus(String? status) {
    switch (status) {
      case 'processing':
        return PredictionStatus.processing;
      case 'completed':
        return PredictionStatus.completed;
      case 'failed':
        return PredictionStatus.failed;
      default:
        return PredictionStatus.pending;
    }
  }

  @override
  List<Object?> get props => [
        predictionId,
        signalId,
        status,
        result,
        errorMessage,
        createdAt,
        completedAt,
      ];
}
