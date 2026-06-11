import 'package:core_offline/core_offline.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/local_database.dart';

class AddVitalsProcessor extends OutboxActionProcessor {
  final MediReachDatabase _db;
  final _supabase = Supabase.instance.client;

  AddVitalsProcessor(this._db);

  @override
  String get actionType => 'add_vitals';

  @override
  Future<void> process(Map<String, dynamic> payload) async {
    final localPatientId = payload['patient_id'] as int;

    // ၁။ Local ID ကို သုံးပြီး ဖုန်းထဲက local_database ထဲမှာ လူနာကို လှမ်းရှာမည်
    final patient = await _db.getPatientById(localPatientId);

    if (patient == null) {
      throw Exception("လူနာမှတ်တမ်းအား Local Database တွင် ရှာမတွေ့ပါ။");
    }

    // ၂။ အကယ်၍ လူနာကိုယ်တိုင်က ဆာဗာပေါ် မရောက်သေးရင် (serverId က null ဖြစ်နေရင်)
    if (patient.serverId == null) {
      // 💡 ဤနေရာတွင် Exception အတင်းပစ်လိုက်ခြင်းဖြင့် သင့် Framework ရဲ့ SyncEngine ကို
      // ၎င်းအလုပ်အား 'failed/pending' အဖြစ် သတ်မှတ်စေပြီး ခေတ္တ စောင့်ဆိုင်းစေမည်ဖြစ်သည်။
      // FIFO စနစ်အရ ရှေ့က လူနာစာရင်းသွင်းတဲ့အလုပ် အောင်မြင်သွားမှ ၎င်းသည် serverId ရရှိပြီး နောက်တစ်ခေါက်တွင် အောင်မြင်သွားမည်။
      throw Exception("လူနာသည် ဆာဗာပေါ်သို့ မရောက်သေးပါ။ FIFO အလှည့်အရ ခေတ္တစောင့်ဆိုင်းပါမည်။");
    }

    // ၃။ serverId ရှိနေပြီဆိုမှ ၎င်းကို ယူမည်
    final serverPatientId = patient.serverId!;

    // ၄။ serverId ကို သုံးပြီး ဆေးစစ်ချက် (Vitals) ကို Supabase ဆီ လှမ်းပို့မည်
    await _supabase.from('vitals').insert({
      'patient_id': serverPatientId, // 👈 Supabase Table မှ လက်ခံသော Foreign Key (Server ID) ဖြစ်သွားပါပြီ
      'temperature': payload['temperature'],
      'blood_pressure': payload['blood_pressure'],
    });

    // မှတ်ချက် - ဒေတာ ဆာဗာပေါ်ရောက်သွားရင် Engine က Outbox ထဲကနေ အလိုအလျောက် ဖျက်ပေးသွားပါမည်။
  }

  @override
  Future<void> onConflict(Object error, Map<String, dynamic> payload) async {
    // ဒေတာချင်း ထပ်နေပါက လုပ်ဆောင်မည့် အလုပ်
  }

  @override
  Future<void> onFailure(Object error, Map<String, dynamic> payload, int currentRetries) async {
    // လုံးဝ ပို့မရတော့ပါက လုပ်ဆောင်မည့် အလုပ်
  }
}
