import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/patient_provider.dart';

class OutboxListView extends ConsumerWidget {
  const OutboxListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outboxQueueAsync = ref.watch(outboxQueueStreamProvider);
    final formState = ref.watch(patientFormControllerProvider);

    return outboxQueueAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('✨ ဆာဗာသို့ ပို့ရန် Queue အလွတ်ဖြစ်နေသည်။ ဒေတာအားလုံး Sync ပြီးပါပြီ။'),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final statusColor = item.status == 'failed' ? Colors.red : Colors.orange;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              elevation: 2,
              child: ListTile(
                leading: Icon(Icons.sync_outlined, color: statusColor, size: 28),
                title: Text(
                  'Action: ${item.actionType.toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Status: ${item.status}\nကြိုးစားမှု: ${item.retryCount}/${item.maxRetries} ကြိမ်',
                  style: const TextStyle(height: 1.3),
                ),
                // 🌟 လုပ်ဆောင်ချက် ခလုတ်များ
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Retry Button (Error ဖြစ်နေတဲ့ ကောင်တွေအတွက် ပိုအသုံးဝင်ပါတယ်)
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.blue),
                      tooltip: 'ပြန်လည်ကြိုးစားမည်',
                      onPressed: formState.isLoading 
                          ? null 
                          : () {
                              ref.read(patientFormControllerProvider.notifier).retryItem(item.id);
                            },
                    ),
                    // Delete Button
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'ဖျက်ပစ်မည်',
                      onPressed: formState.isLoading 
                          ? null 
                          : () {
                              // အမှားမပါစေရန် Confirm Box တောင်းခြင်း
                              _showDeleteConfirmDialog(context, ref, item.id);
                            },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
    );
  }

  // အတည်ပြုချက်တောင်းခံသည့် Dialog တွဲပြပေးခြင်း
  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, int itemId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ အတည်ပြုရန်'),
        content: const Text('ဤ Queue လုပ်ငန်းစဉ်ကို ဖျက်ပစ်ရန် သေချာပါသလား? (ဆာဗာသို့ ဒေတာ ရောက်ရှိမည်မဟုတ်တော့ပါ)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('မလုပ်တော့ပါ'),
          ),
          TextButton(
            onPressed: () {
              ref.read(patientFormControllerProvider.notifier).deleteItem(itemId);
              Navigator.pop(ctx);
            },
            child: const Text('သေချာသည်', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}