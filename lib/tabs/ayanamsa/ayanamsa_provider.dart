import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swisseph/swisseph.dart';

import '../../core/calc_context.dart';
import '../../core/display_format.dart';
import '../../core/export_service.dart';
import '../../core/swe_service.dart';

/// Display format for Ayanamsa tab (promoted from local state).
final ayanamsaFormatProvider = StateProvider<DisplayFormat>((ref) => DisplayFormat.dms);

/// Result for a single ayanamsa calculation.
class AyanamsaCalcResult {
  const AyanamsaCalcResult({
    required this.sidMode,
    required this.name,
    required this.value,
  });

  final int sidMode;
  final String name;
  final double value;
}

/// Known ayanamsa modes with names.
/// SE_SIDM_* constants from swisseph: 0..43 are defined.
final ayanamsaModes = <int, String>{
  0: 'Fagan/Bradley',
  1: 'Lahiri',
  2: 'De Luce',
  3: 'Raman',
  4: 'Ushashashi',
  5: 'Krishnamurti',
  6: 'Djwhal Khul',
  7: 'Yukteswar',
  8: 'J.N. Bhasin',
  9: 'Babylonian (Kugler 1)',
  10: 'Babylonian (Kugler 2)',
  11: 'Babylonian (Kugler 3)',
  12: 'Babylonian (Huber)',
  13: 'Babylonian (Eta Piscium)',
  14: 'Babylonian (Aldebaran 15 Tau)',
  15: 'Hipparchos',
  16: 'Sassanian',
  17: 'Galactic Center 0 Sag',
  18: 'J2000',
  19: 'J1900',
  20: 'B1950',
  21: 'Suryasiddhanta',
  22: 'Suryasiddhanta (mean Sun)',
  23: 'Aryabhata',
  24: 'Aryabhata (mean Sun)',
  25: 'SS Revati',
  26: 'SS Citra',
  27: 'True Citra',
  28: 'True Revati',
  29: 'True Pushya',
  30: 'Galactic Center (Gil Brand)',
  31: 'Galactic Equator (IAU1958)',
  32: 'Galactic Equator',
  33: 'Galactic Equator (mid-Mula)',
  34: 'Skydram (Mardyks)',
  35: 'True Mula (Chandra Hari)',
  36: 'Dhruva (Galactic Center mid-Mula)',
  37: 'Aryabhata 522',
  38: 'Babylonian (Britton)',
  39: 'Vedic (Sheoran)',
  40: 'Cochrane (Galactic Center 0 Cap)',
  41: 'Galactic Equator (Fiorenza)',
  42: 'Vettius Valens',
  43: 'Lahiri (ICRC)',
};

/// Selected ayanamsas for compare mode.
final selectedAyanamsasProvider = StateProvider<List<int>>((ref) => [1]); // Lahiri default

/// Calculation trigger.
final ayanamsaCalcTriggerProvider = StateProvider<int>((ref) => 0);

/// Compare mode toggle.
final ayanamsaCompareModeProvider = StateProvider<bool>((ref) => false);

/// Ayanamsa calculation results.
final ayanamsaResultsProvider = Provider<List<AyanamsaCalcResult>>((ref) {
  ref.watch(ayanamsaCalcTriggerProvider);

  final ectx = ref.watch(effectiveContextProvider);
  final swe = ref.read(sweProvider);
  final selected = ref.watch(selectedAyanamsasProvider);
  final compareMode = ref.watch(ayanamsaCompareModeProvider);

  final modes = compareMode ? ayanamsaModes.keys.toList() : selected;

  final results = <AyanamsaCalcResult>[];
  for (final sidMode in modes) {
    try {
      swe.setSidMode(sidMode);
      final value = swe.getAyanamsaUt(ectx.jdUt);
      final name = ayanamsaModes[sidMode] ?? swe.getAyanamsaName(sidMode);
      results.add(AyanamsaCalcResult(sidMode: sidMode, name: name, value: value));
    } on SweException {
      // Skip failed modes.
    }
  }

  return results;
});

/// Convert ayanamsa results to export rows.
List<ExportRow> ayanamsaToExportRows(List<AyanamsaCalcResult> results, DisplayFormat fmt) {
  return results.map((r) => ExportRow(
    header: r.name,
    fields: [('Value', formatAngle(r.value, fmt))],
  )).toList();
}
