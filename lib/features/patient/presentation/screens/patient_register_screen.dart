import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/patient_provider.dart';

class PatientRegisterScreen extends ConsumerStatefulWidget {
  const PatientRegisterScreen({super.key});

  @override
  ConsumerState<PatientRegisterScreen> createState() => _PatientRegisterScreenState();
}

class _PatientRegisterScreenState extends ConsumerState<PatientRegisterScreen> {
  final _nameController = TextEditingController();
  final _nrcController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(patientFormControllerProvider);

    ref.listen(patientFormControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🛑 Error: ${next.error}')));
      } else if (next is AsyncData && previous is AsyncLoading) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📝 အော့ဖ်လိုင်းထဲသို့ ထည့်သွင်းပြီးပါပြီ။')));
        _nameController.clear(); _nrcController.clear(); _ageController.clear(); _phoneController.clear(); _addressController.clear();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('လူနာသစ် မှတ်ပုံတင်ရန်'), backgroundColor: Colors.teal, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'လူနာအမည်', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _nrcController, decoration: const InputDecoration(labelText: 'NRC နံပါတ်', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: _ageController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'အသက်', border: OutlineInputBorder()))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'ဖုန်းနံပါတ်', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 12),
            TextField(controller: _addressController, maxLines: 2, decoration: const InputDecoration(labelText: 'နေရပ်လိပ်စာ', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            formState.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(55), backgroundColor: Colors.teal),
                    onPressed: () {
                      if (_nameController.text.isEmpty || _nrcController.text.isEmpty) return;
                      ref.read(patientFormControllerProvider.notifier).registerPatient(
                            name: _nameController.text,
                            nrc: _nrcController.text,
                            age: int.tryParse(_ageController.text) ?? 0,
                            phone: _phoneController.text,
                            address: _addressController.text,
                          );
                    },
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text('အော့ဖ်လိုင်း ဒေတာသိမ်းမည်', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
          ],
        ),
      ),
    );
  }
}