import 'package:flutter/material.dart';
import '../../models/kanji.dart';

class KanjiTile extends StatelessWidget {
  final Kanji k;
  final VoidCallback? onTap;
  const KanjiTile(this.k, {super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(k.character, style: Theme.of(context).textTheme.titleLarge),
      subtitle: Text('${k.onyomi} / ${k.kunyomi} - ${k.meaning}'),
      trailing: Text(k.level),
      onTap: onTap,
    );
  }
}
