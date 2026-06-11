import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/patient_provider.dart';

class CachedPatientListView extends ConsumerWidget {
  const CachedPatientListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Local DB ထဲရှိ လူနာ Stream ကို Watch လုပ်ခြင်း
    final patientsAsync = ref.watch(localPatientsStreamProvider);

    return patientsAsync.when(
      data: (patients) {
        if (patients.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('📁 ဖုန်းထဲတွင် လူနာမှတ်တမ်း ရှာမတွေ့သေးပါ။'),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: patients.length,
          itemBuilder: (context, index) {
            final patient = patients[index];
            
            // Sync ဖြစ်ပြီး/မဖြစ်သေးပေါ်မူတည်၍ Icon ပြောင်းလဲခြင်း
            final isSynced = patient.serverId != null;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isSynced ? Colors.teal[100] : Colors.amber[100],
                  child: Icon(
                    isSynced ? Icons.cloud_done : Icons.cloud_off,
                    color: isSynced ? Colors.teal : Colors.amber[800],
                  ),
                ),
                title: Text(
                  patient.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('NRC: ${patient.nrc} | အသက်: ${patient.age} နှစ်'),
                    Text('ဖုန်း: ${patient.phone}'),
                  ],
                ),
                trailing: Chip(
                  label: Text(
                    isSynced ? 'Synced' : 'Local Only',
                    style: TextStyle(
                      color: isSynced ? Colors.white : Colors.black87,
                      fontSize: 11,
                    ),
                  ),
                  backgroundColor: isSynced ? Colors.teal : Colors.amber,
                  padding: EdgeInsets.zero,
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('လူနာစာရင်းဖတ်ရာတွင် Error တက်ပါသည်: $err', style: const TextStyle(color: Colors.red))),
    );
  }
}