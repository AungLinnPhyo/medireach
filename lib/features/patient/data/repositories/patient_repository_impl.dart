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

      await db.transaction(() async {
        for (final raw in remoteData) {
          final serverId = raw['id'] as int;
          final nrc = raw['nrc'] as String;

          final existingPatients = await (db.select(db.patients)..where((t) => t.serverId.equals(serverId) | t.nrc.equals(nrc))).get();

          if (existingPatients.isNotEmpty) {
            final existingPatient = existingPatients.firstWhere((patient) => patient.serverId == serverId, orElse: () => existingPatients.first);

            if (existingPatients.length > 1) {
              final duplicateIds = existingPatients.where((patient) => patient.id != existingPatient.id).map((patient) => patient.id).toList();
              if (duplicateIds.isNotEmpty) {
                await (db.delete(db.patients)..where((t) => t.id.isIn(duplicateIds))).go();
              }
            }

            await (db.update(db.patients)..where((t) => t.id.equals(existingPatient.id))).write(
              PatientsCompanion(
                serverId: Value(serverId),
                name: Value(raw['name'] as String),
                age: Value(raw['age'] as int),
                nrc: Value(nrc),
                phone: Value(raw['phone'] as String),
                address: Value(raw['address'] as String),
                syncStatus: const Value('synced'),
              ),
            );
          } else {
            await db
                .into(db.patients)
                .insert(
                  PatientsCompanion.insert(
                    serverId: Value(serverId),
                    name: raw['name'] as String,
                    age: raw['age'] as int,
                    nrc: nrc,
                    phone: raw['phone'] as String,
                    address: raw['address'] as String,
                    syncStatus: const Value('synced'),
                  ),
                );
          }
        }
      });
    } catch (e) {
      log('Cache Error: $e');
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

  @override
  Future<void> deleteOutboxItem(int id) async {
    await localDataSource.removeOutboxItem(id);
  }

  @override
  Future<void> retryOutboxItem(int id) async {
    await localDataSource.updateOutboxToRetry(id);
  }
}
