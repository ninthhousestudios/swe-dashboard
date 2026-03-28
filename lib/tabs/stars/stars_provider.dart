import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swisseph/swisseph.dart';

import '../../core/calc_context.dart';
import '../../core/calc_trigger.dart';
import '../../core/display_format.dart';
import '../../core/export_service.dart';
import '../../core/swe_service.dart';

/// Common star names for quick selection.
const commonStars = [
  'Aldebaran', 'Regulus', 'Spica', 'Antares', 'Fomalhaut',
  'Algol', 'Sirius', 'Canopus', 'Arcturus', 'Vega',
  'Capella', 'Rigel', 'Betelgeuse', 'Pollux',
];

/// Current star search term (name or catalog number).
final starSearchProvider = StateProvider<String>((ref) => 'Aldebaran');

/// Display format for star results.
final starsFormatProvider = StateProvider<DisplayFormat>((ref) => DisplayFormat.dms);

/// Result of a fixed star calculation.
class StarResult {
  const StarResult({
    required this.searchTerm,
    required this.resolvedName,
    required this.longitude,
    required this.latitude,
    required this.distance,
    required this.speedLon,
    required this.speedLat,
    required this.speedDist,
    required this.magnitude,
    required this.returnFlag,
  });

  final String searchTerm;
  final String resolvedName;
  final double longitude;
  final double latitude;
  final double distance;
  final double speedLon;
  final double speedLat;
  final double speedDist;
  final double magnitude;
  final int returnFlag;
}

/// Fixed star calculation result. Recalculates when calcTriggerProvider fires.
final starResultProvider = Provider<StarResult?>((ref) {
  // Watch trigger so we recalculate on button press.
  ref.watch(calcTriggerProvider);

  final ectx = ref.watch(effectiveContextProvider);
  final swe = ref.read(sweProvider);
  final searchTerm = ref.watch(starSearchProvider);

  final term = searchTerm.trim();
  if (term.isEmpty) return null;

  // Set C globals atomically.
  ectx.calculate(swe, (s, jd, flags) => null);

  try {
    final flags = ectx.iflag | seFlgSpeed;
    final r = swe.fixstar2Ut(term, ectx.jdUt, flags);

    double magnitude;
    try {
      magnitude = swe.fixstar2Mag(term);
    } catch (_) {
      magnitude = double.nan;
    }

    return StarResult(
      searchTerm: term,
      resolvedName: r.starName,
      longitude: r.longitude,
      latitude: r.latitude,
      distance: r.distance,
      speedLon: r.longitudeSpeed,
      speedLat: r.latitudeSpeed,
      speedDist: r.distanceSpeed,
      magnitude: magnitude,
      returnFlag: r.returnFlag,
    );
  } on SweException {
    return null;
  }
});

/// Convert a star result to export rows.
List<ExportRow> starToExportRows(StarResult result, DisplayFormat fmt) {
  return [
    ExportRow(
      header: result.resolvedName,
      fields: [
        ('Longitude', formatAngle(result.longitude, fmt)),
        ('Latitude', formatAngle(result.latitude, fmt)),
        ('Distance', formatDistance(result.distance, fmt)),
        ('Magnitude', result.magnitude.isNaN ? '—' : result.magnitude.toStringAsFixed(2)),
        ('Spd Lon', formatSpeed(result.speedLon, fmt)),
        ('Spd Lat', formatSpeed(result.speedLat, fmt)),
        ('Spd Dist', formatSpeed(result.speedDist, fmt)),
      ],
    ),
  ];
}
