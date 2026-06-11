import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/local_database.dart';

part 'core_providers.g.dart';

@riverpod
MediReachDatabase globalDatabase(Ref ref) {
  return MediReachDatabase();
}