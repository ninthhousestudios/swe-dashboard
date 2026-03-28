import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/calc_trigger.dart';
import '../../core/display_format.dart';
import '../../widgets/export_button.dart';
import '../../widgets/result_card.dart';
import 'stars_provider.dart';

class StarsTab extends ConsumerStatefulWidget {
  const StarsTab({super.key});

  @override
  ConsumerState<StarsTab> createState() => _StarsTabState();
}

class _StarsTabState extends ConsumerState<StarsTab> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(starSearchProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _calculate() {
    final term = _searchController.text.trim();
    if (term.isNotEmpty) {
      ref.read(starSearchProvider.notifier).state = term;
    }
    ref.read(calcTriggerProvider.notifier).state++;
  }

  void _setStarPreset(String name) {
    _searchController.text = name;
    ref.read(starSearchProvider.notifier).state = name;
  }

  bool get _hasCalculated => ref.watch(calcTriggerProvider) > 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = ref.watch(starsFormatProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Star name input row ──
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(
            children: [
              Text('Star ', style: theme.textTheme.labelLarge),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: theme.textTheme.bodySmall,
                  decoration: const InputDecoration(
                    hintText: 'Star name or catalog #',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _calculate(),
                ),
              ),
            ],
          ),
        ),
        // ── Format + export row ──
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SegmentedButton<DisplayFormat>(
                  segments: DisplayFormat.values
                      .map((f) =>
                          ButtonSegment(value: f, label: Text(f.label)))
                      .toList(),
                  selected: {fmt},
                  onSelectionChanged: (s) =>
                      ref.read(starsFormatProvider.notifier).state = s.first,
                  style: const ButtonStyle(
                      visualDensity: VisualDensity.compact),
                ),
                const SizedBox(width: 8),
                Consumer(builder: (context, ref, _) {
                  final result = ref.watch(starResultProvider);
                  final fmt2 = ref.watch(starsFormatProvider);
                  return ExportButton(
                    hasResults: _hasCalculated && result != null,
                    getRows: () =>
                        result != null ? starToExportRows(result, fmt2) : [],
                    filenameStem:
                        'swe_star_${result?.resolvedName ?? 'unknown'}',
                  );
                }),
              ],
            ),
          ),
        ),
        // ── Preset star chips ──
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: commonStars.map((name) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: ActionChip(
                    label: Text(name),
                    onPressed: () => _setStarPreset(name),
                    visualDensity: VisualDensity.compact,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const Divider(height: 1),
        // ── Results ──
        Expanded(
          child: _hasCalculated ? _buildResults(theme) : _buildPlaceholder(),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Text('Enter a star name or catalog number and press Calculate'),
    );
  }

  Widget _buildResults(ThemeData theme) {
    final result = ref.watch(starResultProvider);
    final fmt = ref.watch(starsFormatProvider);

    if (result == null) {
      return Center(
        child: Text(
          'Star not found — check the name or catalog number',
          style: TextStyle(color: theme.colorScheme.error),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: ResultCard(
        title: result.resolvedName,
        subtitle: 'fixstar2Ut("${result.searchTerm}")',
        flagHex: '0x${result.returnFlag.toRadixString(16).toUpperCase()}',
        fields: [
          ResultField(
            label: 'Longitude',
            value: formatAngle(result.longitude, fmt),
            rawValue: result.longitude,
          ),
          ResultField(
            label: 'Latitude',
            value: formatAngle(result.latitude, fmt),
            rawValue: result.latitude,
          ),
          ResultField(
            label: 'Distance',
            value: formatDistance(result.distance, fmt),
            rawValue: result.distance,
          ),
          ResultField(
            label: 'Magnitude',
            value: result.magnitude.isNaN
                ? '—'
                : result.magnitude.toStringAsFixed(2),
            rawValue: result.magnitude,
          ),
          ResultField(
            label: 'Spd Lon',
            value: formatSpeed(result.speedLon, fmt),
            rawValue: result.speedLon,
          ),
          ResultField(
            label: 'Spd Lat',
            value: formatSpeed(result.speedLat, fmt),
            rawValue: result.speedLat,
          ),
          ResultField(
            label: 'Spd Dist',
            value: formatSpeed(result.speedDist, fmt),
            rawValue: result.speedDist,
          ),
        ],
      ),
    );
  }
}
