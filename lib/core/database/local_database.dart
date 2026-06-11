import 'dart:convert';
import 'dart:io';

import 'package:core_offline/core_offline.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'local_database.g.dart';

// ၁။ လူနာမှတ်တမ်း သိမ်းမည့် ဇယား
class Patients extends Table {
  IntColumn get id => integer().autoIncrement()(); // primary key
  IntColumn get serverId => integer().nullable()(); // 👈 ဆာဗာကပေးသော ID ကို Cache ရန် (အသစ်တိုးလိုက်ပါ)
  TextColumn get name => text()();
  IntColumn get age => integer()();
  TextColumn get nrc => text()(); // Server ဘက်တွင် Unique သတ်မှတ်မည့် NRC နံပါတ်
  TextColumn get phone => text()();
  TextColumn get address => text()();
  TextColumn get syncStatus => text().clientDefault(() => "pending")(); // pending, synced, conflict
  DateTimeColumn get createdDate => dateTime().clientDefault(() => DateTime.now())();
}

// ၂။ Offline အတွက် ဒေတာသိမ်းမည့် Outbox Queue ဇယား
class OutboxQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get actionType => text()();
  TextColumn get payload => text()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  IntColumn get maxRetries => integer().withDefault(const Constant(3))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

// ၃။ Offline အတွက် ဒေတာသိမ်းမည့် Vitals ဇယား
class Vitals extends Table {
  IntColumn get id => integer().autoIncrement()(); // primary key
  IntColumn get serverId => integer().nullable()();
  IntColumn get localPatientId => integer()(); // ဘယ်လူနာလဲဆိုတာ ချိတ်ဆက်ရန်
  RealColumn get temperature => real()();
  TextColumn get bloodPressure => text()();
}

@DriftDatabase(tables: [Patients, OutboxQueue, Vitals])
class MediReachDatabase extends _$MediReachDatabase implements OfflineOutboxRepository {
  MediReachDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ==========================================
  // Framework အတွက် အလုပ်လုပ်ပေးမည့် အပိုင်း (Implementation)
  // ==========================================

  @override
  Future<void> deleteOutboxItem(int id) async {
    await (delete(outboxQueue)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<OfflineOutboxItem?> getNextSyncableItem() async {
    final row =
        await (select(outboxQueue)
              ..where((t) => t.status.equals('pending') | (t.status.equals('failed') & t.retryCount.isSmallerThan(t.maxRetries)))
              ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc)])
              ..limit(1))
            .getSingleOrNull();

    if (row == null) return null;
    return OfflineOutboxItem(
      id: row.id,
      actionType: row.actionType,
      payload: row.payload,
      retryCount: row.retryCount,
      maxRetries: row.maxRetries,
      status: row.status,
      lastError: row.lastError,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  @override
  Future<void> updateOutboxItem({required int id, required String status, required int retryCount, String? lastError}) async {
    await (update(
      outboxQueue,
    )..where((t) => t.id.equals(id))).write(OutboxQueueCompanion(status: Value(status), retryCount: Value(retryCount), lastError: Value(lastError), updatedAt: Value(DateTime.now())));
  }

  @override
  Stream<List<OfflineOutboxItem>> watchOutbox() {
    return select(outboxQueue).watch().map((rows) {
      return rows
          .map(
            (row) => OfflineOutboxItem(
              id: row.id,
              actionType: row.actionType,
              payload: row.payload,
              retryCount: row.retryCount,
              maxRetries: row.maxRetries,
              status: row.status,
              lastError: row.lastError,
              createdAt: row.createdAt,
              updatedAt: row.updatedAt,
            ),
          )
          .toList();
    });
  }

  // ==========================================
  // လုပ်ငန်းသုံး Business Logic (Atomicity ဖြစ်အောင် Transaction သုံးမည်)
  // ==========================================

  Future<Patient?> getPatientById(int localId) async {
  return await (select(patients)..where((t) => t.id.equals(localId))).getSingleOrNull();
}

  Future<void> registerPatientOffline(String name, String nrc, String phone, String address, int age) async {
    await transaction(() async {
      // ကနဦး လူနာကို Local Table ထဲ အော့ဖ်လိုင်း အရင်သိမ်းမည်
      final patientId = await into(patients).insert(PatientsCompanion.insert(name: name, nrc: nrc, syncStatus: const Value('pending'), age: age, phone: phone, address: address));

      // Server သို့ ပို့မည့် Payload JSON ထုပ်ပိုးမည်
      final payload = jsonEncode({'local_id': patientId, 'name': name, 'nrc': nrc, 'phone': phone, 'address': address, 'age': age});

      // Outbox Queue ထဲသို့ FIFO စနစ်အရ တန်းစီထည့်မည်
      await into(outboxQueue).insert(OutboxQueueCompanion.insert(actionType: 'register_patient', payload: payload, status: const Value('pending')));
    });
  }

  Future<void> addVitalsOffline(int patientId, double temp, String bp) async {
    await transaction(() async {
      // Local ထဲ အရင်သိမ်းမည်
      await into(vitals).insert(VitalsCompanion.insert(localPatientId: patientId, temperature: temp, bloodPressure: bp));

      // Outbox Queue ထဲသို့ 'add_vitals' ဆိုပြီး FIFO စနစ်အရ တန်းစီထည့်မည်
      await into(
        outboxQueue,
      ).insert(OutboxQueueCompanion.insert(actionType: 'add_vitals', payload: jsonEncode({'patient_id': patientId, 'temperature': temp, 'blood_pressure': bp}), status: const Value('pending')));
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'medireach.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
