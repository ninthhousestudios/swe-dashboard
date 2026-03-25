import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/context_provider.dart';
import '../../core/context_state.dart';
import 'labeled_dropdown.dart';

class EpheSourceSelector extends ConsumerWidget {
  const EpheSourceSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final source =
        ref.watch(contextBarProvider.select((s) => s.epheSource));

    return LabeledDropdown<EpheSource>(
      label: 'Ephe',
      value: source,
      items: EpheSource.values,
      itemLabel: (s) => s.label,
      onChanged: (v) => ref.read(contextBarProvider.notifier).setEpheSource(v),
    );
  }
}
