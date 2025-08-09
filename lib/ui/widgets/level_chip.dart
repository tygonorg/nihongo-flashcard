import 'package:flutter/material.dart';

class LevelChip extends StatelessWidget {
  final String level;
  final bool selected;
  final VoidCallback onTap;
  const LevelChip({super.key, required this.level, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(level),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
