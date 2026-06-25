import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:grad_imp_1/core/networking/api_constants.dart';
import 'package:grad_imp_1/core/networking/dio_factory.dart';
import 'package:grad_imp_1/features/patient/domain/entities/health_signal_entity.dart';

/// Service for managing real-time health signals collection and transmission
abstract class HealthSignalRemoteDataSource {
  Future<void> initialize(String userId);
  void startCollection();
  Future<void> stopCollection();
  void addSignal(HealthSignal signal);
  Stream<HealthSignal> get signalStream;
  Stream<List<HealthSignal>> get batchStream;
  int get bufferSize;
  bool get isCollecting;
  List<HealthSignal> getRecentSignals(int count);
  Future<void> dispose();
}

class BackendHealthSignalDataSource implements HealthSignalRemoteDataSource {
  late final StreamController<HealthSignal> _signalStreamController;
  late final StreamController<List<HealthSignal>> _batchStreamController;

  Timer? _collectionTimer;
  Timer? _batchTransmissionTimer;

  final List<HealthSignal> _signalBuffer = [];
  final int batchSize = 1; // Send immediately for now, or change back to 10
  final Duration collectionFrequency = const Duration(seconds: 1);
  final Duration batchTransmissionInterval = const Duration(seconds: 5);

  String? _userId;
  bool _isCollecting = false;

  BackendHealthSignalDataSource() {
    _signalStreamController = StreamController<HealthSignal>.broadcast();
    _batchStreamController = StreamController<List<HealthSignal>>.broadcast();
  }

  @override
  Future<void> initialize(String userId) async {
    _userId = userId;
  }

  @override
  void startCollection() {
    if (_isCollecting) return;
    _isCollecting = true;

    // Optional: Re-enable random mock data generation here if needed
    // _collectionTimer = Timer.periodic(collectionFrequency, (_) {
    //   _collectSignal();
    // });
    
    // _batchTransmissionTimer = Timer.periodic(batchTransmissionInterval, (_) {
    //   _transmitBatch();
    // });
  }

  @override
  Future<void> stopCollection() async {
    _isCollecting = false;
    _collectionTimer?.cancel();
    _batchTransmissionTimer?.cancel();
    if (_signalBuffer.isNotEmpty) {
      await _transmitBatch();
    }
  }

  // ignore: unused_element
  void _collectSignal() {
    if (_userId == null) return;

    final signal = HealthSignal(
      signalId: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _userId!,
      timestamp: DateTime.now(),
      heartRate: 72.0 + (DateTime.now().millisecond % 10).toDouble(),
      ppgSignal: 100.0 + (DateTime.now().millisecond % 20).toDouble(),
      temperature: 36.5,
      spO2: 98.0,
    );

    _signalBuffer.add(signal);
    _signalStreamController.add(signal);
    if (_signalBuffer.length >= batchSize) {
      _transmitBatch();
    }
  }

  Future<void> _transmitBatch() async {
    if (_signalBuffer.isEmpty || _userId == null) return;

    final batchList = List<HealthSignal>.from(_signalBuffer);
    
    try {
      final dio = await DioFactory.getDio();
      
      // Since the API takes a single health data object in the example, we'll iterate or send the latest.
      // For batching, the API might need to be adjusted, but we'll send them one by one for now.
      for (final signal in batchList) {
        await dio.post(
          ApiConstants.patientHealthData,
          data: {
            'heart_rate': signal.heartRate,
            'blood_pressure': '120/80', // Replace with real data if available
            'blood_glucose': 90.0,      // Replace with real data if available
            'cholesterol': 180.0,       // Replace with real data if available
            'spo2_level': signal.spO2,
            'stability_index': 0.95,    // Dummy or calculated value
            'recorded_at': signal.timestamp.toUtc().toIso8601String(),
          },
        );
      }

      _batchStreamController.add(batchList);
      _signalBuffer.clear();
    } on DioException catch (e) {
      debugPrint('Error transmitting health signals: ${e.message}');
    } catch (e) {
      debugPrint('Error transmitting health signals: $e');
    }
  }

  @override
  void addSignal(HealthSignal signal) {
    _signalBuffer.add(signal);
    _signalStreamController.add(signal);
    if (_signalBuffer.length >= batchSize) {
      _transmitBatch();
    }
  }

  @override
  Stream<HealthSignal> get signalStream => _signalStreamController.stream;

  @override
  Stream<List<HealthSignal>> get batchStream => _batchStreamController.stream;

  @override
  int get bufferSize => _signalBuffer.length;

  @override
  bool get isCollecting => _isCollecting;

  @override
  List<HealthSignal> getRecentSignals(int count) {
    return _signalBuffer.length <= count
        ? List.from(_signalBuffer)
        : _signalBuffer.sublist(_signalBuffer.length - count);
  }

  @override
  Future<void> dispose() async {
    await stopCollection();
    await _signalStreamController.close();
    await _batchStreamController.close();
  }
}
