import '../../domain/entities/doctor_search_entity.dart';
import '../../domain/repositories/patient_search_repository.dart';
import '../datasources/patient_search_remote_datasource.dart';

class PatientSearchRepositoryImpl implements PatientSearchRepository {
  PatientSearchRepositoryImpl(this._remoteDataSource);
  final PatientSearchRemoteDataSource _remoteDataSource;

  @override
  Stream<List<String>> getAssignedDoctorIds() {
    return _remoteDataSource.getAssignedDoctorIds();
  }

  @override
  Stream<List<DoctorSearchEntity>> getAssignedDoctors(List<String> doctorIds) {
    return _remoteDataSource.getAssignedDoctors(doctorIds).map(
          (list) => list.map((json) {
            final rawName = (json['name'] as String?)?.trim() ?? '';
            final rawSpecialty = (json['specialty'] as String?)?.trim() ?? '';
            final photoUrl = json['photo_url']?.toString() ?? json['image']?.toString();

            return DoctorSearchEntity(
              id: json['id'] as String,
              name: rawName.isEmpty ? 'Doctor' : rawName,
              specialty: rawSpecialty.isEmpty ? 'General Medicine' : rawSpecialty,
              photoUrl: photoUrl,
            );
          }).toList(),
        );
  }
}
