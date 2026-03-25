import 'package:swisseph/swisseph.dart';

/// Metadata for a single flag toggle or group member.
class FlagDef {
  const FlagDef({
    required this.label,
    required this.value,
    this.tooltip = '',
  });

  final String label;
  final int value;
  final String tooltip;
}

/// A mutually exclusive group — only one member can be active at a time.
/// The first member is the default.
class FlagGroup {
  const FlagGroup({
    required this.label,
    required this.members,
  });

  final String label;
  final List<FlagDef> members;

  int get defaultValue => members.first.value;
}

/// Coordinate system group — mutually exclusive.
final coordGroup = FlagGroup(
  label: 'Coordinates',
  members: [
    const FlagDef(
      label: 'Ecliptic',
      value: 0, // default — no flag bit needed
      tooltip: 'Ecliptic longitude/latitude (default)',
    ),
    FlagDef(
      label: 'Equatorial',
      value: seflgEquatorial,
      tooltip: 'Right ascension / declination',
    ),
    FlagDef(
      label: 'XYZ',
      value: seflgXyz,
      tooltip: 'Cartesian X/Y/Z coordinates',
    ),
  ],
);

/// Independent composable toggles.
final flagToggles = [
  FlagDef(
    label: 'Speed',
    value: seflgSpeed,
    tooltip: 'Include speed (daily motion) in output',
  ),
  FlagDef(
    label: 'True Pos',
    value: seflgTruepos,
    tooltip: 'True geometric position (no aberration/deflection)',
  ),
  FlagDef(
    label: 'No Aberr',
    value: seflgNoaberr,
    tooltip: 'No annual aberration correction',
  ),
  FlagDef(
    label: 'No Grav',
    value: seflgNogdefl,
    tooltip: 'No gravitational light deflection',
  ),
  FlagDef(
    label: 'Radians',
    value: seflgRadians,
    tooltip: 'Output in radians instead of degrees',
  ),
  FlagDef(
    label: 'J2000',
    value: seFlgJ2000,
    tooltip: 'J2000 equator/ecliptic reference frame',
  ),
  FlagDef(
    label: 'No Nut',
    value: seFlgNoNut,
    tooltip: 'No nutation',
  ),
  FlagDef(
    label: 'ICRS',
    value: seflgIcrs,
    tooltip: 'ICRS (International Celestial Reference System)',
  ),
];

/// Flags that are auto-locked by context bar settings.
/// These should NOT appear as user toggles — they are managed automatically.
const autoManagedFlags = {
  seflgSidereal, // locked by ZodiacRef.sidereal
  seflgTopoctr, // locked by Origin.topocentric
  seflgHelctr, // locked by Origin.heliocentric
  seflgBaryctr, // locked by Origin.barycentric
  seflgJpleph, // locked by EpheSource.jpl
  seflgSwieph, // locked by EpheSource.swissEph
  seflgMoseph, // locked by EpheSource.moshier
};
