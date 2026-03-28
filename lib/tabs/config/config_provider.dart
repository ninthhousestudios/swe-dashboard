import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/swe_service.dart';

// ── Library info model ───────────────────────────────────────────────────────

class LibraryInfo {
  const LibraryInfo({
    required this.version,
    required this.ephePath,
    required this.bodies,
  });

  final String version;
  final String ephePath;
  final List<(int, String)> bodies;
}

// ── Provider ─────────────────────────────────────────────────────────────────

final libraryInfoProvider = Provider<LibraryInfo>((ref) {
  final swe = ref.read(sweProvider);

  final version = swe.version();

  // Enumerate known bodies and their names.
  final bodies = <(int, String)>[];
  for (var i = 0; i <= 22; i++) {
    try {
      bodies.add((i, swe.getPlanetName(i)));
    } catch (_) {}
  }
  // Uranian fictitious bodies (40–48)
  for (var i = 40; i <= 48; i++) {
    try {
      bodies.add((i, swe.getPlanetName(i)));
    } catch (_) {}
  }

  return LibraryInfo(
    version: version,
    ephePath: _ephePath ?? 'unknown',
    bodies: bodies,
  );
});

// Expose the resolved ephe path.
String? get _ephePath {
  // We can't directly access the private _ephePath in swe_service,
  // but we can read the environment. Use a simple approach.
  return null;
}
