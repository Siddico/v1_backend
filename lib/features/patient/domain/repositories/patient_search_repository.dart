import '../entities/doctor_search_entity.dart';

abstract class PatientSearchRepository {
  Stream<List<String>> getAssignedDoctorIds();
  Stream<List<DoctorSearchEntity>> getAssignedDoctors(List<String> doctorIds);
}
