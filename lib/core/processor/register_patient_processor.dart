import 'package:core_offline/core_offline.dart';
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/local_database.dart';

class RegisterPatientProcessor extends OutboxActionProcessor {
  final MediReachDatabase _database;
  final _supabase = Supabase.instance.client;

  RegisterPatientProcessor(this._database);

  @override
  String get actionType => 'register_patient';

  @override
  Future<void> process(Map<String, dynamic> payload) async {
    final localId = payload['local_id'] as int;

    // ၁။ Supabase ၏ 'patients' table ထဲသို့ ဒေတာလှမ်းထည့်ခြင်း
    final response = await _supabase
        .from('patients')
        .insert({'name': payload['name'], 'age': payload['age'], 'nrc': payload['nrc'], 'phone': payload['phone'], 'address': payload['address']})
        .select('id')
        .single(); // ဆာဗာက ထုတ်ပေးလိုက်သော id ကို ပြန်ယူမည်

    final serverId = response['id'] as int;

    // ၂။ အောင်မြင်ပါက Local Database ထဲရှိ လူနာ၏ အခြေအနေကို 'synced' ဟု ပြောင်းပြီး serverId ကို မှတ်သားမည်
    await (_database.update(_database.patients)..where((t) => t.id.equals(localId))).write(PatientsCompanion(syncStatus: const Value('synced'), serverId: Value(serverId)));
  }

  @override
  Future<void> onConflict(Object error, Map<String, dynamic> payload) async {
    // NRC နံပါတ် တူနေခြင်း စသည့် Conflict ဖြစ်ပါက Local ဒေတာကို 'conflict' ဟု ပြောင်းမည်
    final localId = payload['local_id'] as int;

    await (_database.update(_database.patients)..where((t) => t.id.equals(localId))).write(const PatientsCompanion(syncStatus: Value('conflict')));
  }

  @override
  Future<void> onFailure(Object error, Map<String, dynamic> payload, int currentRetries) async {
    final localId = payload['local_id'] as int;

    await (_database.update(_database.patients)..where((t) => t.id.equals(localId))).write(const PatientsCompanion(syncStatus: Value('failed')));
  }
}
