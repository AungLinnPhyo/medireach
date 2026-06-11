import 'package:supabase_flutter/supabase_flutter.dart';

class PatientRemoteDataSource {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchPatientsFromServer() async {
    return await _supabase.from('patients').select();
  }
}