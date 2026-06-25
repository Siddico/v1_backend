import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:grad_imp_1/core/networking/api_constants.dart';
import 'package:grad_imp_1/core/networking/dio_factory.dart';
import '../../../../core/constants/app_images.dart';

abstract class DoctorMessageRemoteDataSource {
  Stream<Map<String, dynamic>?> getInboxData();
}

class BackendDoctorMessageDataSource implements DoctorMessageRemoteDataSource {
  BackendDoctorMessageDataSource({required String userId}) : _userId = userId;

  final String _userId;

  @override
  Stream<Map<String, dynamic>?> getInboxData() async* {
    if (_userId.isEmpty) yield null;

    while (true) {
      try {
        final dio = await DioFactory.getDio();
        final response = await dio.get('${ApiConstants.baseUrl}/chat/conversations');
        
        if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
          final List<dynamic> data = response.data['data'] ?? [];
          
          final conversations = data.map((d) {
            final p1 = d['participant_1_id']?.toString();
            final p2 = d['participant_2_id']?.toString();
            final otherId = p1 == _userId ? p2 : p1;
            
            return {
              'id': d['id'].toString(),
              'otherId': otherId,
              'name': d['name'] ?? 'User', // Assume API returns the other user's name or we handle it in UI
              'preview': d['preview'] ?? 'No messages yet',
              'image': d['image'] ?? AppImages.patientImage,
              'unreadCount': d['unread_count'] ?? 0,
            };
          }).toList();

          yield {'conversations': conversations};
        }
      } catch (e) {
        debugPrint('Error fetching doctor inbox: $e');
      }
      await Future.delayed(const Duration(seconds: 10));
    }
  }
}

