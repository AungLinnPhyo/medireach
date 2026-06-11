import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/patient/data/data_sources/patient_local_data_source.dart';
import '../../features/patient/data/data_sources/patient_remote_data_source.dart';
import '../../features/patient/data/repositories/patient_repository_impl.dart';
import '../../features/patient/domain/repositories/patient_repository.dart';
import '../../features/patient/domain/usecases/patient_usecase.dart';
import '../providers/core_providers.dart';

part 'patient_di.g.dart';

// ၁။ Data Source Injection
@riverpod
PatientLocalDataSource patientLocalDataSource(Ref ref) {
  final db = ref.watch(globalDatabaseProvider);
  return PatientLocalDataSource(db);
}

@riverpod
PatientRemoteDataSource patientRemoteDataSource(Ref ref) {
  return PatientRemoteDataSource();
}

// ၂။ Repository Injection
@riverpod
PatientRepository patientRepository(Ref ref) {
  final db = ref.watch(globalDatabaseProvider);
  final localDataSource = ref.watch(patientLocalDataSourceProvider);
  final remoteDataSource = ref.watch(patientRemoteDataSourceProvider);

  return PatientRepositoryImpl(localDataSource: localDataSource, remoteDataSource: remoteDataSource, db: db);
}

// ၃။ UseCase Injection
@riverpod
RegisterPatientUseCase registerPatientUseCase(Ref ref) {
  final repository = ref.watch(patientRepositoryProvider);
  return RegisterPatientUseCase(repository);
}

// ၄။ Fetch & Cache UseCase Injection
@riverpod
FetchAndCachePatientsUseCase fetchAndCachePatientsUseCase(Ref ref) {
  final repository = ref.watch(patientRepositoryProvider);
  return FetchAndCachePatientsUseCase(repository);
}

@riverpod
RetryOutboxItemUseCase retryOutboxItemUseCase(Ref ref) {
  final repository = ref.watch(patientRepositoryProvider);
  return RetryOutboxItemUseCase(repository);
}

@riverpod
DeleteOutboxItemUseCase deleteOutboxItemUseCase(Ref ref) {
  final repository = ref.watch(patientRepositoryProvider);
  return DeleteOutboxItemUseCase(repository);
}
