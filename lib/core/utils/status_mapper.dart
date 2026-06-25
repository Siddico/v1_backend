import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/theme/app_colors.dart';
import '../../features/patient/domain/entities/prediction_result_entity.dart';

class StatusMapper {
  /// Resolves the status string dynamically, falling back to profile status or risk score if prediction is null.
  static String resolveStatus({
    PredictionResult? prediction,
    String? patientStatus,
    double? riskScore,
  }) {
    if (prediction != null) {
      return mapPredictionToStatus(prediction);
    }
    if (patientStatus != null && patientStatus.isNotEmpty && patientStatus.toLowerCase() != 'unknown') {
      final statusLower = patientStatus.toLowerCase();
      if (statusLower == 'unnormal') {
        return 'pac';
      }
      return statusLower;
    }
    if (riskScore != null) {
      return mapRiskScoreToStatus(riskScore);
    }
    return 'stable';
  }

  /// Maps a [PredictionResult] to a UI status string used by StatusChip.
  /// Returns one of: 'af', 'pac', 'nsr', 'stable'.
  static String mapPredictionToStatus(PredictionResult result) {
    final predUpper = result.prediction.toUpperCase().trim();
    if (predUpper == 'AF') return 'af';
    if (predUpper == 'PAC') return 'pac';
    if (predUpper == 'NSR') return 'nsr';

    // General questionnaire or empty prediction maps status based on the risk score
    if (predUpper == 'AI_QUESTIONNAIRE' || result.prediction.isEmpty) {
      final statusFromScore = mapRiskScoreToStatus(result.riskScore);
      if (statusFromScore == 'warning') return 'pac';
      if (statusFromScore == 'critical') return 'af';
      return 'nsr';
    }

    // High risk with high confidence -> AF (critical)
    if (result.strokeRisk.toLowerCase() == 'high' && result.confidence > 0.8) {
      return 'af';
    }
    // High risk with lower confidence or medium risk -> PAC (orange)
    if (result.strokeRisk.toLowerCase() == 'high' && result.confidence <= 0.8) {
      return 'pac';
    }
    if (result.strokeRisk.toLowerCase() == 'medium') {
      return 'pac';
    }
    // Low risk -> NSR (green)
    if (result.strokeRisk.toLowerCase() == 'low') {
      return 'nsr';
    }
    // Fallback – keep existing status if any, otherwise 'stable'
    return result.status.isNotEmpty ? result.status : 'stable';
  }

  /// Returns a Color corresponding to a given status string.
  static Color getColorForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'af':
      case 'critical':
      case 'high':
        return AppColors.redDeep;
      case 'pac':
      case 'warning':
      case 'medium':
      case 'unnormal':
        return Colors.orange;
      case 'nsr':
      case 'stable':
      case 'low':
        return AppColors.tealP;
      default:
        return AppColors.tealP;
    }
  }

  /// Maps a numerical risk score (0-100) to a standard status string ('stable', 'warning', 'critical')
  static String mapRiskScoreToStatus(double riskScore) {
    final normScore = riskScore <= 1.0 ? riskScore * 100 : riskScore;
    if (normScore > 75) {
      return 'critical';
    } else if (normScore <= 30) {
      return 'stable';
    } else {
      return 'warning';
    }
  }
}
