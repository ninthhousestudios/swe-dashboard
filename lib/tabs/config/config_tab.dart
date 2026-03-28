import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config_provider.dart';

class ConfigTab extends ConsumerWidget {
  const ConfigTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final info = ref.watch(libraryInfoProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Library info card ──
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Swiss Ephemeris Library',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _infoRow(theme, 'Version', info.version),
                  const SizedBox(height: 4),
                  _infoRow(theme, 'Dart Package', 'swisseph 0.3.0'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // ── Known bodies card ──
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Known Bodies', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    '${info.bodies.length} bodies enumerated',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: info.bodies.map((b) {
                      return Chip(
                        label: Text('${b.$2} (${b.$1})'),
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // ── About card ──
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'SWE Dashboard is a Flutter GUI for the Swiss Ephemeris. '
                    'It provides pure astronomical calculations with no '
                    'interpretation.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All calculations use the Swiss Ephemeris C library '
                    'via FFI through the swisseph.dart package.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(ThemeData theme, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ),
        Expanded(
          child: SelectableText(value, style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }
}
