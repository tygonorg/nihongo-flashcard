import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../services/srs_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

final srsProvider =
    Provider<SrsService>((ref) => SrsService(ref.read(databaseServiceProvider)));

final selectedLevelProvider =
    StateProvider<String?>((ref) => null); // null = tất cả
