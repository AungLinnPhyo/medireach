import 'package:flutter/material.dart';
import '../widgets/outbox_list_view.dart';

class SyncQueueScreen extends StatelessWidget {
  const SyncQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Outbox Queue'),
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: OutboxListView(),
        ),
      ),
    );
  }
}