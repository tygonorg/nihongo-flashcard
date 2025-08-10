import 'package:get_it/get_it.dart';
import 'services/database_service.dart';
import 'services/srs_service.dart';
import 'services/kanji_srs_service.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<DatabaseService>(() => DatabaseService.instance);
  locator.registerLazySingleton<SrsService>(
    () => SrsService(locator<DatabaseService>()),
  );
  locator.registerLazySingleton<KanjiSrsService>(
    () => KanjiSrsService(locator<DatabaseService>()),
  );
}
