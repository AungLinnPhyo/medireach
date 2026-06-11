import 'package:core_offline/core_offline.dart';

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
}
