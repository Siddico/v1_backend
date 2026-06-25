import 'doctor_task_entity.dart';
import 'patient_row_entity.dart';
import 'stat_summary_entity.dart';

class DoctorDashboardEntity {
  const DoctorDashboardEntity({
    required this.tasks,
    required this.stats,
    required this.patients,
  });

  final List<DoctorTaskEntity> tasks;
  final List<StatSummaryEntity> stats;
  final List<PatientRowEntity> patients;
}
