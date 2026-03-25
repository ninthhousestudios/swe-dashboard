import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/display_format.dart';

/// A single key-value pair in a result card.
class ResultField {
  const ResultField({required this.label, required this.value, this.rawValue});
  final String label;

  /// Formatted value (respects current DisplayFormat).
  final String value;

  /// Raw numeric value for copy/export (optional).
  final double? rawValue;
}

/// Generic result card used across all tabs.
///
/// Shows a header (function name, body, flag hex), a list of
/// key-value result fields, and action buttons (format toggle,
/// copy, pin placeholder).
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.title,
    this.subtitle,
    this.flagHex,
    required this.fields,
    required this.format,
    this.onFormatChanged,
    this.onPin,
  });

  final String title;
  final String? subtitle;
  final String? flagHex;
  final List<ResultField> fields;
  final DisplayFormat format;
  final ValueChanged<DisplayFormat>? onFormatChanged;
  final VoidCallback? onPin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.all(4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleSmall),
                      if (subtitle != null)
                        Text(subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            )),
                    ],
                  ),
                ),
                if (flagHex != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(flagHex!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontFamily: 'monospace',
                          color: colorScheme.onSurfaceVariant,
                        )),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Result fields
            ...fields.map((f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80 * MediaQuery.textScalerOf(context).scale(1.0),
                        child: Text(f.label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            )),
                      ),
                      Expanded(
                        child: SelectableText(f.value,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: 'monospace',
                            )),
                      ),
                    ],
                  ),
                )),
            // Action row (hidden when no per-card controls needed)
            if (onFormatChanged != null || onPin != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onFormatChanged != null)
                    SegmentedButton<DisplayFormat>(
                      segments: DisplayFormat.values
                          .map((f) => ButtonSegment(value: f, label: Text(f.label)))
                          .toList(),
                      selected: {format},
                      onSelectionChanged: (s) => onFormatChanged?.call(s.first),
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        textStyle: WidgetStatePropertyAll(theme.textTheme.labelSmall),
                      ),
                    ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: 'Copy to clipboard',
                    onPressed: () {
                      final text = fields.map((f) => '${f.label}: ${f.value}').join('\n');
                      Clipboard.setData(ClipboardData(text: '$title\n$text'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied'), duration: Duration(seconds: 1)),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.push_pin_outlined, size: 18),
                    tooltip: 'Pin result',
                    onPressed: onPin,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
