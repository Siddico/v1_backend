import '../entities/doctor_dashboard_entity.dart';

abstract class DoctorRepository {
  Stream<DoctorDashboardEntity> getDashboardStream();
}
