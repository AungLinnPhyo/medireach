class PatientEntity {
  final int? id;
  final int? serverId;
  final String name;
  final int age;
  final String nrc;
  final String phone;
  final String address;
  final String syncStatus;

  PatientEntity({
    this.id,
    this.serverId,
    required this.name,
    required this.age,
    required this.nrc,
    required this.phone,
    required this.address,
    required this.syncStatus,
  });
}