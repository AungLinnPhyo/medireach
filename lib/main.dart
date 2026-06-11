import 'package:core_offline/core_offline.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/database/local_database.dart';
import 'core/processor/add_virals_processor.dart';
import 'core/processor/register_patient_processor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ၁။ Supabase အား anonKey ဖြင့် Initialize လုပ်ခြင်း
  await Supabase.initialize(
    url: 'https://kusgvmjdljqswwgmyhtz.supabase.co',
    publishableKey : 'sb_publishable_dhSsbR1bDyHXW1f26kVMWA_MHKB9Bx_',
  );

  final db = MediReachDatabase();
  final syncEngine = OfflineSyncEngine(outboxRepository: db);

  // 🔌 Processor များကို Engine ထဲတွင် Register လုပ်ခြင်း
  syncEngine.registerProcessor(RegisterPatientProcessor(db));
  syncEngine.registerProcessor(AddVitalsProcessor(db));
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text('$_counter', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: _incrementCounter, tooltip: 'Increment', child: const Icon(Icons.add)),
    );
  }
}
