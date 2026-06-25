import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/health_signal_entity.dart';
import '../../domain/entities/prediction_result_entity.dart';
import '../../domain/repositories/health_monitoring_repository.dart';
import '../../domain/repositories/prediction_repository.dart';
import '../../../../core/utils/status_mapper.dart';

class HealthMonitoringState {
  final bool isLoading;
  final String? errorMessage;
  final List<HealthSignal> recentSignals;
  final List<PredictionResult> recentPredictions;
  final HealthSignal? currentSignal;
  final PredictionResult? currentPrediction;
  final double averageHeartRate;
  final double averageRiskScore;
  final int criticalAlertsCount;
  final bool isMonitoring;

  HealthMonitoringState({
    this.isLoading = false,
    this.errorMessage,
    this.recentSignals = const [],
    this.recentPredictions = const [],
    this.currentSignal,
    this.currentPrediction,
    this.averageHeartRate = 0.0,
    this.averageRiskScore = 0.0,
    this.criticalAlertsCount = 0,
    this.isMonitoring = false,
  });

  HealthMonitoringState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<HealthSignal>? recentSignals,
    List<PredictionResult>? recentPredictions,
    HealthSignal? currentSignal,
    PredictionResult? currentPrediction,
    double? averageHeartRate,
    double? averageRiskScore,
    int? criticalAlertsCount,
    bool? isMonitoring,
  }) {
    return HealthMonitoringState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      recentSignals: recentSignals ?? this.recentSignals,
      recentPredictions: recentPredictions ?? this.recentPredictions,
      currentSignal: currentSignal ?? this.currentSignal,
      currentPrediction: currentPrediction ?? this.currentPrediction,
      averageHeartRate: averageHeartRate ?? this.averageHeartRate,
      averageRiskScore: averageRiskScore ?? this.averageRiskScore,
      criticalAlertsCount: criticalAlertsCount ?? this.criticalAlertsCount,
      isMonitoring: isMonitoring ?? this.isMonitoring,
    );
  }

  String get riskLevelSummary {
    if (recentPredictions.isEmpty) return 'No data';
    final highRiskCount = recentPredictions.where((p) => p.isHighRisk).length;
    if (highRiskCount == 0) return 'Low Risk';
    if (highRiskCount <= 2) return 'Moderate Risk';
    return 'High Risk';
  }
}

class HealthMonitoringController extends StateNotifier<HealthMonitoringState> {
  final HealthMonitoringRepository _healthRepo;
  final PredictionRepository _predictionRepo;
  final String _userId;
  final bool isDoctor;

  StreamSubscription<HealthSignal>? _signalSubscription;
  StreamSubscription<PredictionResult>? _predictionSubscription;

  HealthMonitoringController(
    this._healthRepo,
    this._predictionRepo,
    this._userId, {
    this.isDoctor = false,
  }) : super(HealthMonitoringState()) {
    if (_userId.isNotEmpty) {
      _initAndStart();
    }
  }

  Future<void> _initAndStart() async {
    await initializeMonitoring();
    if (!mounted) return;
    await startMonitoring();
  }

  Future<void> initializeMonitoring() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      await _healthRepo.initialize(_userId);
      if (!mounted) return;
      await _predictionRepo.initialize(_userId);
      if (!mounted) return;
      state = state.copyWith(isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to initialize monitoring: $e',
      );
    }
  }

  Future<void> startMonitoring() async {
    try {
      if (_healthRepo.isCollecting) return;

      state = state.copyWith(isLoading: true, errorMessage: null);

      _healthRepo.startCollection();
      await _predictionRepo.startListeningToPredictions();
      if (!mounted) return;

      _signalSubscription?.cancel();
      _signalSubscription = _healthRepo.signalStream.listen((signal) {
        if (!mounted) return;
        final updatedSignals = List<HealthSignal>.from(state.recentSignals)
          ..add(signal);
        if (updatedSignals.length > 60) updatedSignals.removeAt(0);

        final double avgHeartRate =
            updatedSignals.fold<double>(0.0, (prev, s) => prev + s.heartRate) /
            updatedSignals.length;

        state = state.copyWith(
          currentSignal: signal,
          recentSignals: updatedSignals,
          averageHeartRate: avgHeartRate,
          isMonitoring: true,
        );
      });

      _predictionSubscription?.cancel();
      _predictionSubscription = _predictionRepo.predictionStream.listen((
        prediction,
      ) {
        if (!mounted) return;
        // Map AI prediction to UI status string
        final String mappedStatus = StatusMapper.mapPredictionToStatus(
          prediction,
        );
        final PredictionResult updatedPrediction = prediction.copyWith(
          status: mappedStatus,
        );
        final updatedPredictions = List<PredictionResult>.from(
          state.recentPredictions,
        )..add(updatedPrediction);
        if (updatedPredictions.length > 100) updatedPredictions.removeAt(0);

        final int alerts = updatedPrediction.isCritical
            ? state.criticalAlertsCount + 1
            : state.criticalAlertsCount;
        final double avgRisk =
            updatedPredictions.fold<double>(
              0.0,
              (prev, p) => prev + p.riskScore,
            ) /
            updatedPredictions.length;

        state = state.copyWith(
          currentPrediction: updatedPrediction,
          recentPredictions: updatedPredictions,
          criticalAlertsCount: alerts,
          averageRiskScore: avgRisk,
        );
      });

      state = state.copyWith(isLoading: false, isMonitoring: true);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to start monitoring: $e',
      );
    }
  }

  Future<void> stopMonitoring() async {
    try {
      _signalSubscription?.cancel();
      _signalSubscription = null;
      _predictionSubscription?.cancel();
      _predictionSubscription = null;
      await _healthRepo.stopCollection();
      await _predictionRepo.stopListeningToPredictions();
      if (!mounted) return;
      state = state.copyWith(isMonitoring: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(errorMessage: 'Failed to stop monitoring: $e');
    }
  }

  void clearHistory() {
    state = state.copyWith(
      recentSignals: [],
      recentPredictions: [],
      criticalAlertsCount: 0,
      averageHeartRate: 0.0,
      averageRiskScore: 0.0,
    );
  }

  @override
  void dispose() {
    _signalSubscription?.cancel();
    _predictionSubscription?.cancel();
    stopMonitoring();
    _healthRepo.dispose();
    _predictionRepo.dispose();
    super.dispose();
  }
}
