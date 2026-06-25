import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:grad_imp_1/core/networking/api_constants.dart';
import 'package:grad_imp_1/core/networking/dio_factory.dart';

abstract class DoctorRemoteDataSource {
  Stream<Map<String, dynamic>?> getDashboardStream();
}

class BackendDoctorDataSource implements DoctorRemoteDataSource {
  BackendDoctorDataSource({required String userId}) : _userId = userId;

  final String _userId;

  @override
  Stream<Map<String, dynamic>?> getDashboardStream() async* {
    if (_userId.isEmpty) yield null;

    final staticTasks = [
      {
        'title': 'Review MRI Scan',
        'description': 'Review the latest MRI scan for patient Ahmed.',
        'time': '10:00 AM',
        'iconCode': 0xe000,
      },
      {
        'title': 'Follow-up Call',
        'description': 'Call patient Mahmoud for follow-up.',
        'time': '01:30 PM',
        'iconCode': 0xe001,
      },
    ];

    while (true) {
      try {
        final dio = await DioFactory.getDio();
        
        // Fetch patients
        final response = await dio.get('${ApiConstants.baseUrl}/doctor/patients');
        
        // Fetch follow-ups
        final followUpsResponse = await dio.get('${ApiConstants.baseUrl}/doctor/follow-up');

        if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
          final List<dynamic> data = response.data['data'] ?? [];
          final latestPatients = data.map((d) {
            return {
              'id': d['id'].toString(),
              'name': d['name'] ?? d['full_name'] ?? 'Patient',
              'diagnosis': d['diagnosis'] ?? 'N/A',
              'status': d['status'] ?? 'Stable',
              'lastReview': d['last_review'] ?? 'Today',
            };
          }).toList();
          
          final dynamicStats = [
            {
              'title': 'Total\nPatients',
              'value': latestPatients.length.toString(),
              'image': 'assets/images/green_graph.svg',
            }
          ];

          // Parse follow ups into tasks
          final dynamicTasks = [...staticTasks];
          if (followUpsResponse.statusCode != null && followUpsResponse.statusCode! >= 200 && followUpsResponse.statusCode! < 300) {
            final List<dynamic> followUpsData = followUpsResponse.data['data'] ?? [];
            dynamicTasks.clear();
            for (var f in followUpsData) {
              final dateStr = f['scheduled_date']?.toString() ?? '';
              String time = 'TBD';
              if (dateStr.isNotEmpty) {
                 final dt = DateTime.tryParse(dateStr);
                 if (dt != null) {
                    time = '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
                 }
              }
              dynamicTasks.add({
                'title': 'Follow-up',
                'description': f['notes'] ?? 'Follow up with patient',
                'time': time,
                'iconCode': 0xe001,
              });
            }
            if (dynamicTasks.isEmpty) {
              dynamicTasks.addAll(staticTasks); // fallback to static if empty
            }
          }

          yield {
            'patients': latestPatients,
            'tasks': dynamicTasks,
            'stats': dynamicStats,
          };
        }
      } catch (e) {
        debugPrint('Error fetching doctor dashboard: $e');
      }
      await Future.delayed(const Duration(seconds: 10));
    }
  }
}
