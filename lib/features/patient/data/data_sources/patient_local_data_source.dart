import 'package:core_offline/core_offline.dart';
import 'package:drift/drift.dart';

import '../../../../core/database/local_database.dart';

class PatientLocalDataSource {
  final MediReachDatabase _db;

  PatientLocalDataSource(this._db);

  Future<void> insertPatientOffline(String name, String nrc, String phone, String address, int age) async {
    await _db.registerPatientOffline(name, nrc, phone, address, age);
  }

  Stream<List<Patient>> watchPatients() {
    return _db.select(_db.patients).watch();
  }

  Stream<List<OfflineOutboxItem>> watchOutbox() {
    return _db.watchOutbox();
  }

  Future<void> updateOutboxToRetry(int id) async {
    // Status ကို pending ပြန်ပြောင်းပြီး retryCount ကို 0 ပြန်ညှိပေးခြင်းဖြင့် Sync Engine က ပြန်အလုပ်လုပ်ပါမည်
    await (_db.update(_db.outboxQueue)
          ..where((t) => t.id.equals(id)))
        .write(
      OutboxQueueCompanion(
        status: const Value('pending'),
        retryCount: const Value(0),
      ),
    );
  }

  Future<void> removeOutboxItem(int id) async {
    await (_db.delete(_db.outboxQueue)
          ..where((t) => t.id.equals(id)))
        .go();
  }
}
