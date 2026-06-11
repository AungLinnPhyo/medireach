import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/patient_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _nameController = TextEditingController();
  final _nrcController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Stream များကို Watch လုပ်ခြင်း
    final outboxQueueAsync = ref.watch(outboxQueueStreamProvider);
    final formState = ref.watch(patientFormControllerProvider);

    // 💡 အကယ်၍ Error တက်ရင်ဖြစ်စေ၊ အောင်မြင်ရင်ဖြစ်စေ UI မှာ Dialog/SnackBar ပြရန် Listen လုပ်ခြင်း
    ref.listen(patientFormControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error တက်သွားပါသည်: ${next.error}')));
      } else if (next is AsyncData && previous is AsyncLoading) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('အော့ဖ်လိုင်း (Outbox) ထဲသို့ အောင်မြင်စွာ ထည့်သွင်းပြီးပါပြီ။')));
        // Form များကို ရှင်းထုတ်ပစ်မည်
        _nameController.clear();
        _nrcController.clear();
        _ageController.clear();
        _phoneController.clear();
        _addressController.clear();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('MediReach Riverpod'),
        backgroundColor: Colors.teal,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.read(patientFormControllerProvider.notifier).syncFromServer())],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ၁။ Outbox Queue ကို Live စောင့်ကြည့်ပြသခြင်း
            const Text('🔄 Sync Queue Status', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              height: 100,
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
              child: outboxQueueAsync.when(
                data: (items) => items.isEmpty
                    ? const Center(child: Text('ဒေတာများ အကုန် Sync ပြီးပါပြီ ✨'))
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, idx) => ListTile(dense: true, title: Text('Action: ${items[idx].actionType} (${items[idx].status})')),
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
            const Divider(height: 24),

            // ၂။ Inputs Form
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'အမည်'),
            ),
            TextField(
              controller: _nrcController,
              decoration: const InputDecoration(labelText: 'NRC'),
            ),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'အသက်'),
            ),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'ဖုန်း'),
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'လိပ်စာ'),
            ),
            const SizedBox(height: 16),

            // ၃။ Loading ဖြစ်နေလျှင် ခလုတ်ကို ပိတ်ထားပြီး Indicator ပြမည်
            formState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50), backgroundColor: Colors.teal),
                    onPressed: () {
                      if (_nameController.text.isEmpty || _nrcController.text.isEmpty) return;

                      ref
                          .read(patientFormControllerProvider.notifier)
                          .registerPatient(
                            name: _nameController.text,
                            nrc: _nrcController.text,
                            age: int.tryParse(_ageController.text) ?? 0,
                            phone: _phoneController.text,
                            address: _addressController.text,
                          );
                    },
                    child: const Text('အော့ဖ်လိုင်း သိမ်းဆည်းမည်', style: TextStyle(color: Colors.white)),
                  ),
          ],
        ),
      ),
    );
  }
}
