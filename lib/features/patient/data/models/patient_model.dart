import '../../../../core/database/local_database.dart';
import '../../domain/entities/patient_entity.dart';

class PatientModel extends PatientEntity {
  PatientModel({
    super.id,
    super.serverId,
    required super.name,
    required super.age,
    required super.nrc,
    required super.phone,
    required super.address,
    required super.syncStatus,
  });

  // Drift ၏ Data Class (Patient) မှ Domain Entity သို့ ပြောင်းရန်
  factory PatientModel.fromDrift(Patient row) {
    return PatientModel(
      id: row.id,
      serverId: row.serverId,
      name: row.name,
      age: row.age,
      nrc: row.nrc,
      phone: row.phone,
      address: row.address,
      syncStatus: row.syncStatus,
    );
  }

  // Supabase (JSON Map) မှ Domain Entity သို့ ပြောင်းရန်
  factory PatientModel.fromSupabase(Map<String, dynamic> json) {
    return PatientModel(
      serverId: json['id'] as int,
      name: json['name'] as String,
      age: json['age'] as int,
      nrc: json['nrc'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      syncStatus: 'synced',
    );
  }
}