import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swisseph/swisseph.dart';

import '../../core/calc_context.dart';
import '../../core/calc_trigger.dart';
import '../../core/swe_service.dart';

/// Result of a house calculation.
class HousesCalcResult {
  const HousesCalcResult({
    required this.cusps,
    required this.ascmc,
    required this.hsys,
    required this.hsysName,
    required this.returnFlag,
  });

  final List<double> cusps;
  /// [0] Asc, [1] MC, [2] ARMC, [3] Vertex, [4] Eq Asc, [5..7] co-asc/polar
  final List<double> ascmc;
  final int hsys;
  final String hsysName;
  final int returnFlag;

  double get asc => ascmc[0];
  double get mc => ascmc[1];
  double get armc => ascmc[2];
  double get vertex => ascmc[3];
  double get equatorialAsc => ascmc[4];
}

/// Known house system codes and names.
class HouseSystemDef {
  const HouseSystemDef(this.code, this.label);
  final int code; // ASCII char code
  final String label;

  String get char => String.fromCharCode(code);
}

final houseSystems = <HouseSystemDef>[
  HouseSystemDef(0x50, 'Placidus'),           // P
  HouseSystemDef(0x4B, 'Koch'),               // K
  HouseSystemDef(0x4F, 'Porphyry'),           // O
  HouseSystemDef(0x52, 'Regiomontanus'),      // R
  HouseSystemDef(0x43, 'Campanus'),           // C
  HouseSystemDef(0x45, 'Equal (Asc)'),        // E
  HouseSystemDef(0x57, 'Whole Sign'),         // W
  HouseSystemDef(0x41, 'Equal (MC)'),         // A
  HouseSystemDef(0x42, 'Alcabitius'),         // B
  HouseSystemDef(0x4D, 'Morinus'),            // M
  HouseSystemDef(0x55, 'Krusinski'),          // U
  HouseSystemDef(0x48, 'Azimuthal/Horizontal'), // H
  HouseSystemDef(0x56, 'Vehlow Equal'),       // V
  HouseSystemDef(0x58, 'Meridian (Axial)'),   // X
  HouseSystemDef(0x47, 'Gauquelin (36)'),     // G
  HouseSystemDef(0x54, 'Polich/Page'),        // T
  HouseSystemDef(0x44, 'Equal (MC, desc)'),   // D
  HouseSystemDef(0x4E, 'Equal/1=Aries'),      // N
  HouseSystemDef(0x59, 'APC Houses'),         // Y
  HouseSystemDef(0x46, 'Carter Poli-Equatorial'), // F
  HouseSystemDef(0x49, 'Sunshine (Treindl)'), // I
  HouseSystemDef(0x69, 'Sunshine (Makransky)'), // i
  HouseSystemDef(0x4C, 'Pullen SD'),          // L
  HouseSystemDef(0x51, 'Pullen SR'),          // Q
];

/// Selected house system.
final selectedHouseSystemProvider = StateProvider<int>((ref) => 0x50); // Placidus

/// Houses calculation result.
final housesResultProvider = Provider<HousesCalcResult?>((ref) {
  ref.watch(calcTriggerProvider);

  final ectx = ref.watch(effectiveContextProvider);
  final swe = ref.read(sweProvider);
  final hsys = ref.watch(selectedHouseSystemProvider);

  // Apply C globals.
  ectx.calculate(swe, (s, jd, flags) => null);

  try {
    final r = swe.houses(ectx.jdUt, ectx.latitude, ectx.longitude, hsys);
    final hsysName = swe.houseName(hsys);
    return HousesCalcResult(
      cusps: r.cusps,
      ascmc: r.ascmc,
      hsys: hsys,
      hsysName: hsysName,
      returnFlag: r.returnFlag,
    );
  } on SweException {
    return null;
  }
});
