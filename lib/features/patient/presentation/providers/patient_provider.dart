import 'package:core_offline/core_offline.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/dependency_injections/patient_di.dart';
import '../../domain/entities/patient_entity.dart';

part 'patient_provider.g.dart';

// 🌟 ၁။ Local DB ထဲက လူနာစာရင်းကို Live စောင့်ကြည့်မည့် Stream Provider
@riverpod
Stream<List<PatientEntity>> localPatientsStream(Ref ref) {
  final repository = ref.watch(patientRepositoryProvider);
  return repository.watchLocalPatients();
}

// 🌟 ၂။ Outbox Queue (ဆင့်ခ်လုပ်ရန်ကျန်တာ) ကို Live စောင့်ကြည့်မည့် Stream Provider
@riverpod
Stream<List<OfflineOutboxItem>> outboxQueueStream(Ref ref) {
  final repository = ref.watch(patientRepositoryProvider);
  return repository.watchOutboxQueue();
}

// 🌟 ၃။ လူနာသစ်ဆောက်ချိန်တွင် Loading Status ကို ထိန်းချုပ်ပေးမည့် Notifier
@riverpod
class PatientFormController extends _$PatientFormController {
  @override
  FutureOr<void> build() {
    // ပထမဆုံး အစပြုချိန်တွင် ဘာ State မှ မရှိပါ (Idle State)
  }

  Future<void> registerPatient({required String name, required String nrc, required String phone, required String address, required int age}) async {
    // UI ကို Loading စပြခိုင်းလိုက်သည်
    state = const AsyncLoading();

    // ကွန်ပျူတာနောက်ကွယ်မှ လုပ်ငန်းစဉ်ကို UseCase သုံးပြီး ပတ်မည်
    state = await AsyncValue.guard(() async {
      final registerUseCase = ref.read(registerPatientUseCaseProvider);

      final patient = PatientEntity(name: name, nrc: nrc, phone: phone, address: address, age: age, syncStatus: 'pending');

      await registerUseCase.registerPatient(patient);
    });
  }

  Future<void> syncFromServer() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final fetchUseCase = ref.read(fetchAndCachePatientsUseCaseProvider);
      await fetchUseCase();
    });
  }
}
