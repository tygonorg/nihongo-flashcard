import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'theme.dart';
import 'providers/providers.dart';

class NihongoApp extends ConsumerWidget {
  const NihongoApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Nihongo',
      theme: buildTheme(settings.primaryColor, settings.fontSize),
      routerConfig: router,
    );
  }
}
