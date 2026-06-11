import 'package:core_offline/core_offline.dart';
import '../entities/patient_entity.dart';

abstract class PatientRepository {
  Future<void> registerPatient(PatientEntity patient);
  Stream<List<PatientEntity>> watchLocalPatients();
  Stream<List<OfflineOutboxItem>> watchOutboxQueue();
  Future<void> fetchAndCachePatients();
  Future<void> retryOutboxItem(int id);
  Future<void> deleteOutboxItem(int id);
}