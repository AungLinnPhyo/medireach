import 'dart:developer';

import 'package:core_offline/core_offline.dart';
import 'package:drift/drift.dart';
import 'package:medireach/features/patient/domain/entities/patient_entity.dart';

import '../../../../core/database/local_database.dart';
import '../../domain/repositories/patient_repository.dart';
import '../data_sources/patient_local_data_source.dart';
import '../data_sources/patient_remote_data_source.dart';
import '../models/patient_model.dart';

class PatientRepositoryImpl implements PatientRepository {
  final PatientLocalDataSource localDataSource;
  final PatientRemoteDataSource remoteDataSource;
  final MediReachDatabase db; // Batch Insert လုပ်ရန် Drift DB အား တိုက်ရိုက်ယူသုံးခြင်း

  PatientRepositoryImpl({required this.localDataSource, required this.remoteDataSource, required this.db});

  @override
  Future<void> fetchAndCachePatients() async {
    try {
      final remoteData = await remoteDataSource.fetchPatientsFromServer();

      // Drift Batch စနစ်ဖြင့် အုပ်စုလိုက် Cache လုပ်ခြင်း (Upsert)
      await db.batch((batch) {
        for (final raw in remoteData) {
          batch.insert(
            db.patients,
            PatientsCompanion.insert(
              serverId: Value(raw['id'] as int),
              name: raw['name'],
              age: raw['age'],
              nrc: raw['nrc'],
              phone: raw['phone'],
              address: raw['address'],
              syncStatus: const Value('synced'),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    } catch (e) {
      log("Cache Error: $e");
    }
  }

  @override
  Future<void> registerPatient(PatientEntity patient) async {
    await localDataSource.insertPatientOffline(patient.name, patient.nrc, patient.phone, patient.address, patient.age);
  }

  @override
  Stream<List<PatientEntity>> watchLocalPatients() {
    return localDataSource.watchPatients().map((list) => list.map((row) => PatientModel.fromDrift(row)).toList());
  }

  @override
  Stream<List<OfflineOutboxItem>> watchOutboxQueue() {
    return localDataSource.watchOutbox();
  }
}
