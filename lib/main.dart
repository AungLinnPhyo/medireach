import 'package:core_offline/core_offline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/database/local_database.dart';
import 'core/processor/add_virals_processor.dart';
import 'core/processor/register_patient_processor.dart';
import 'features/patient/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ၁။ Supabase အား anonKey ဖြင့် Initialize လုပ်ခြင်း
  await Supabase.initialize(url: 'https://kusgvmjdljqswwgmyhtz.supabase.co', publishableKey: 'sb_publishable_dhSsbR1bDyHXW1f26kVMWA_MHKB9Bx_');

  final db = MediReachDatabase();
  final syncEngine = OfflineSyncEngine(outboxRepository: db);

  // 🔌 Processor များကို Engine ထဲတွင် Register လုပ်ခြင်း
  syncEngine.registerProcessor(RegisterPatientProcessor(db));
  syncEngine.registerProcessor(AddVitalsProcessor(db));

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: const HomeScreen(),
    );
  }
}
