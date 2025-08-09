import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/realm_service.dart';
import '../services/srs_service.dart';

final realmServiceProvider = Provider<RealmService>((ref) {
  throw UnimplementedError();
});

final srsProvider =
    Provider<SrsService>((ref) => SrsService(ref.read(realmServiceProvider)));

final selectedLevelProvider =
    StateProvider<String?>((_) => null); // null = tất cả
