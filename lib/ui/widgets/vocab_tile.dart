import 'package:flutter/material.dart';
import '../../models/vocab.dart';

class VocabTile extends StatelessWidget {
  final Vocab v;
  final VoidCallback? onTap;
  const VocabTile(this.v, {super.key, this.onTap});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(v.term, style: Theme.of(context).textTheme.titleLarge),
      subtitle: Text('${v.hiragana} – ${v.meaning}'),
      trailing: Text(v.level),
      onTap: onTap,
    );
  }
}
