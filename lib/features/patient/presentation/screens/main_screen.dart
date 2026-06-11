import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/patient_provider.dart';
import 'patient_list_screen.dart';
import 'patient_register_screen.dart';
import 'sync_queue_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  // ပြသမည့် Screen များ စာရင်း
  final List<Widget> _screens = [
    const PatientRegisterScreen(),
    const PatientListScreen(),
    const SyncQueueScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Outbox Queue Stream ကို နားထောင်ပြီး ကျန်ရှိနေသော ဒေတာအရေအတွက်ကို Badge ပြရန် ယူခြင်း
    final outboxQueueAsync = ref.watch(outboxQueueStreamProvider);
    final pendingCount = outboxQueueAsync.value?.length ?? 0;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens, // Screen status မပျောက်ပျက်စေရန် IndexedStack သုံးသည်
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_add_alt_1),
            label: 'စာရင်းသွင်း',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.folder_shared),
            label: 'လူနာများ',
          ),
          BottomNavigationBarItem(
            // 🌟 ဒေတာ ဆင့်ခ်လုပ်ရန် ကျန်ပါက Badge အနီလေးဖြင့် ပြပေးမည်
            icon: Badge(
              label: Text('$pendingCount'),
              isLabelVisible: pendingCount > 0,
              child: Icon(Icons.sync),
            ),
            label: 'Outbox Queue',
          ),
        ],
      ),
    );
  }
}