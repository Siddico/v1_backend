import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../domain/entities/doctor_dashboard_entity.dart';
import '../../domain/entities/doctor_task_entity.dart';
import '../../domain/entities/patient_row_entity.dart';
import '../../domain/entities/stat_summary_entity.dart';
import '../../domain/repositories/doctor_repository.dart';
import '../datasources/doctor_remote_datasource.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  DoctorRepositoryImpl(this._remoteDataSource);

  final DoctorRemoteDataSource _remoteDataSource;

  static const List<DoctorTaskEntity> _defaultTasks = [
    DoctorTaskEntity(
      title: 'Check patient',
      description: 'Review patients\' recent reports and monitor their health updates',
      time: '3:00 PM',
      icon: Icons.fact_check_outlined,
    ),
    DoctorTaskEntity(
      title: 'Video Calls',
      description: 'Schedule or join online consultations with your patients.',
      time: '8:00 PM',
      icon: Icons.videocam_outlined,
    ),
  ];

  static const List<StatSummaryEntity> _defaultStats = [
    StatSummaryEntity(
      title: 'New\nPatient',
      value: '0',
      colors: [Colors.white, AppColors.greenForest],
      image: AppImages.greenGraph,
    ),
  ];

  @override
  Stream<DoctorDashboardEntity> getDashboardStream() {
    return _remoteDataSource.getDashboardStream().map((data) {
      return DoctorDashboardEntity(
        tasks: _parseTasks(data),
        stats: _parseStats(data),
        patients: _parsePatients(data),
      );
    });
  }

  List<DoctorTaskEntity> _parseTasks(Map<String, dynamic>? data) {
    final raw = data?['tasks'];
    if (raw is! List) return _defaultTasks;

    final tasks = raw.whereType<Map>().map((item) {
      final iconCode = (item['iconCode'] as num?)?.toInt();
      return DoctorTaskEntity(
        title: (item['title'] as String?) ?? 'Task',
        description: (item['description'] as String?) ?? '',
        time: (item['time'] as String?) ?? '--:--',
        // Use a const-safe lookup so the release tree-shaker can analyse icons.
        icon: _iconFromCode(iconCode),
      );
    }).toList();

    return tasks.isEmpty ? _defaultTasks : tasks;
  }

  /// Maps a known Material icon codepoint to a constant [IconData].
  /// Falls back to [Icons.fact_check_outlined] for any unknown code.
  static IconData _iconFromCode(int? code) {
    // Add more entries here if remote data sends additional icon codes.
    const knownIcons = <int, IconData>{
      0xe1b4: Icons.fact_check_outlined,
      0xe63d: Icons.videocam_outlined,
      0xe318: Icons.person_outline,
      0xe0d0: Icons.call_outlined,
      0xe7ef: Icons.schedule,
      0xe87c: Icons.medical_services_outlined,
      0xe3ab: Icons.favorite_border,
      0xe547: Icons.notifications_outlined,
      0xe88e: Icons.note_outlined,
    };
    if (code == null) return Icons.fact_check_outlined;
    return knownIcons[code] ?? Icons.fact_check_outlined;
  }

  List<StatSummaryEntity> _parseStats(Map<String, dynamic>? data) {
    final raw = data?['stats'];
    if (raw is! List) return _defaultStats;

    const fallbackImages = [AppImages.greenGraph, AppImages.redGraph, AppImages.blueGraph];
    const fallbackColors = [
      [Colors.white, AppColors.greenForest],
      [Colors.white, AppColors.redAlert],
      [Colors.white, AppColors.redDeep],
    ];

    final stats = <StatSummaryEntity>[];
    for (var i = 0; i < raw.length; i++) {
      final item = raw[i];
      if (item is! Map) continue;

      final colorIndex = i < fallbackColors.length ? i : fallbackColors.length - 1;
      final imageIndex = i < fallbackImages.length ? i : fallbackImages.length - 1;

      stats.add(StatSummaryEntity(
        title: (item['title'] as String?) ?? 'Stat',
        value: (item['value'] as String?) ?? '0',
        colors: fallbackColors[colorIndex],
        image: (item['image'] as String?) ?? fallbackImages[imageIndex],
      ));
    }
    return stats.isEmpty ? _defaultStats : stats;
  }

  List<PatientRowEntity> _parsePatients(Map<String, dynamic>? data) {
    final raw = data?['patients'];
    if (raw is! List) return [];

    return raw.whereType<Map>().map((item) {
      return PatientRowEntity(
        id: (item['id'] as String?) ?? '-',
        name: (item['name'] as String?) ?? 'Patient',
        diagnosis: (item['diagnosis'] as String?) ?? 'N/A',
        status: (item['status'] as String?) ?? 'Stable',
        lastReview: (item['lastReview'] as String?) ?? '-',
      );
    }).toList();
  }
}
