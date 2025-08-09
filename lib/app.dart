import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'theme.dart';

class NihongoApp extends ConsumerWidget {
  const NihongoApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Nihongo',
      theme: buildTheme(),
      routerConfig: router,
    );
  }
}
