import '../entities/patient_entity.dart';
import '../repositories/patient_repository.dart';

class RegisterPatientUseCase {
  final PatientRepository repository;
  RegisterPatientUseCase(this.repository);

  Future<void> registerPatient(PatientEntity patient) async => await repository.registerPatient(patient);
}

class FetchAndCachePatientsUseCase {
  final PatientRepository repository;

  FetchAndCachePatientsUseCase(this.repository);

  Future<void> call() async => await repository.fetchAndCachePatients();
}

class RetryOutboxItemUseCase {
  final PatientRepository repository;
  RetryOutboxItemUseCase(this.repository);

  Future<void> call(int id) async {
    return await repository.retryOutboxItem(id);
  }
}

class DeleteOutboxItemUseCase {
  final PatientRepository repository;
  DeleteOutboxItemUseCase(this.repository);

  Future<void> call(int id) async {
    return await repository.deleteOutboxItem(id);
  }
}
