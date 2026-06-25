import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:grad_imp_1/core/networking/api_constants.dart';
import 'package:grad_imp_1/core/networking/dio_factory.dart';

import 'package:grad_imp_1/core/networking/api_response_parser.dart';

abstract class WellnessRemoteDataSource {
  Future<List<Map<String, dynamic>>> getHealthData();
  Stream<List<Map<String, dynamic>>> getHealthDataStream();
  Future<void> saveHealthData(Map<String, dynamic> data);
}

class BackendWellnessDataSource implements WellnessRemoteDataSource {
  BackendWellnessDataSource({required String userId}) : _userId = userId;

  final String _userId;

  @override
  Future<List<Map<String, dynamic>>> getHealthData() async {
    if (_userId.isEmpty) return [];
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get(ApiConstants.patientHealthData);
      
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        final List<dynamic> data = ApiResponseParser.extractList(response.data['data']);
        return data.map((d) => d as Map<String, dynamic>).toList();
      }
    } catch (e) {
      debugPrint('Error getting health data: $e');
    }
    return [];
  }

  @override
  Stream<List<Map<String, dynamic>>> getHealthDataStream() async* {
    if (_userId.isEmpty) yield [];
    
    while (true) {
      yield await getHealthData();
      await Future.delayed(const Duration(seconds: 15));
    }
  }

  @override
  Future<void> saveHealthData(Map<String, dynamic> data) async {
    if (_userId.isEmpty) return;
    try {
      final dio = await DioFactory.getDio();
      await dio.post(ApiConstants.patientHealthData, data: data);
    } catch (e) {
      debugPrint('Error saving health data: $e');
    }
  }
}
