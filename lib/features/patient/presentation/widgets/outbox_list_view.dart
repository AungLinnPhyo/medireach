import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/patient_provider.dart';

class OutboxListView extends ConsumerWidget {
  const OutboxListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Stream Provider ကို လှမ်းကြည့်ခြင်း
    final outboxQueueAsync = ref.watch(outboxQueueStreamProvider);

    return outboxQueueAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Queue ဖတ်ရာတွင် Error တက်ပါသည်: $err', style: const TextStyle(color: Colors.red))),
      data: (items) {
        if (items.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('🔔 ဆာဗာသို့ ပို့ရန် Queue အလွတ်ဖြစ်နေသည်။ ဒေတာအားလုံး Sync ပြီးပါပြီ။ ✨'),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), // Scroll ငြိမနေစေရန်
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            
            // Status အလိုက် အရောင် သတ်မှတ်ခြင်း
            final statusColor = item.status == 'failed' ? Colors.red : Colors.orange;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: Icon(Icons.sync_outlined, color: statusColor),
                title: Text(
                  'Action: ${item.actionType.toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Status: ${item.status} | ကြိုးစားမှု: ${item.retryCount}/${item.maxRetries} ကြိမ်'),
                trailing: Text(
                  '#${item.id}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
            );
          },
        );
      },
    );
  }
}