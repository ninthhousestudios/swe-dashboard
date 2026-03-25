import 'package:flutter/material.dart';

import '../../core/flag_definitions.dart';

/// A single composable flag toggle chip.
class FlagToggle extends StatelessWidget {
  const FlagToggle({
    super.key,
    required this.def,
    required this.active,
    required this.onToggle,
  });

  final FlagDef def;
  final bool active;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: def.tooltip,
      child: FilterChip(
        label: Text(def.label),
        selected: active,
        onSelected: (_) => onToggle(),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
