# SWE Dashboard

A cross-platform GUI for the [Swiss Ephemeris](https://www.astro.com/swisseph/swephinfo_e.htm), built with Flutter and [swisseph.dart](https://pub.dev/packages/swisseph).

Every calculation the Swiss Ephemeris library can do, exposed through a tabbed interface with full control over input parameters and output formats. Pure astronomical values — no astrological interpretation.

## Features

- **Planet positions** — Sun through Pluto, nodes, Lilith, Chiron, Pholus, Uranian bodies, and any asteroid by MPC number. Ecliptic, equatorial, or Cartesian coordinates with speed values.
- **House cusps** — 24 house systems including Placidus, Koch, Equal, Whole Sign, Campanus, Regiomontanus, Gauquelin (36 sectors), and more. Angles (Asc, MC, ARMC, Vertex, Eq. Asc) included.
- **Ayanamsa values** — 44 sidereal modes. Select individual modes or compare all in a sortable table.
- **Context bar** — Global date/time (with JD), geographic coordinates, UTC offset, origin (geocentric/topocentric/heliocentric/barycentric), zodiac reference, equinox reference, ayanamsa, and ephemeris source.
- **Flag bar** — Composable Swiss Ephemeris calculation flags with auto-linking to context bar settings. Shows the computed `iflag` hex value.
- **Chart file import** — Reads `.chtk`, `.jhd`, `.aaf`, `.as`, `.qck`, `.toml`, `.json`, `.csv` chart formats to populate context.
- **Four themes** — Light, Dark, Cosmic, Forest.
- **Responsive layout** — Three breakpoints (mobile, tablet, desktop) with zoom support.

## Requirements

- Flutter SDK 3.11+
- A C compiler (for the native Swiss Ephemeris library, built automatically via Dart's native asset system)

Linux: `sudo pacman -S clang` or `sudo apt install clang`

## Getting Started

```bash
git clone <this-repo>
cd swe_dashboard
flutter pub get
flutter run -d linux   # or macos, windows, chrome
```

The Swiss Ephemeris C library compiles automatically on first `flutter pub get` via the native asset build hook in the `swisseph` package.

## Usage

1. Set your date, time, location, and options in the **context bar** at the top.
2. Configure calculation flags in the **flag bar** (coordinate system, speed, aberration, etc.).
3. Switch to a tab (Planets, Houses, Ayanamsa, etc.) and press **Calculate**.
4. Results appear as cards with DMS, decimal, or raw format toggle.

## Project Status

Phases 1–4 complete (core UI, context bar, flag bar, first three calculation tabs). Remaining work includes export, eclipses, crossings, fixed stars, heliacal events, coordinate transforms, rise/set times, Delta T, and more calculation tabs.

## Tests

```bash
flutter test test/goldens/                     # run golden image tests
flutter test test/goldens/ --update-goldens    # regenerate baselines
```

54 golden images cover all implemented widgets across three screen sizes and two themes.

## License

TBD
