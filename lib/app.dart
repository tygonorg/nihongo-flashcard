import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/settings_controller.dart';
import 'controllers/level_controller.dart';
import 'router.dart';
import 'theme.dart';

class NihongoApp extends StatelessWidget {
  const NihongoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.put(SettingsController());
    Get.put(LevelController());
    return Obx(
      () => GetMaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Nihongo',
        theme: buildTheme(settings.primaryColor.value, settings.fontSize.value),
        routerDelegate: router.routerDelegate,
        routeInformationParser: router.routeInformationParser,
        routeInformationProvider: router.routeInformationProvider,
      ),
    );
  }
}
