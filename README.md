# Ephemeris Dashboard

A cross-platform GUI for the [Swiss Ephemeris](https://www.astro.com/swisseph/swephinfo_e.htm), built with Flutter and [swisseph.dart](https://pub.dev/packages/swisseph).

Every calculation the Swiss Ephemeris library can do, exposed through a tabbed interface with full control over input parameters and output formats. Pure astronomical values — no astrological interpretation.

## Features

- **18 calculation tabs** — Planets, Houses, Ayanamsa, Rise/Set, Eclipses, Stars, Crossings, Table, Dates, Coordinates, Nodes/Apsides, Heliacal, Phenomena, Differential, Planetocentric, Math, Config
- **Planet positions** — Sun through Pluto, nodes, Lilith, Chiron, Pholus, Uranian bodies, and any asteroid by MPC number. Ecliptic, equatorial, or Cartesian coordinates with speed values.
- **Planetocentric** — View any body from any other body (e.g. Mars as seen from Jupiter) via `calcPctr`.
- **House cusps** — 24 house systems including Placidus, Koch, Equal, Whole Sign, Campanus, Regiomontanus, Gauquelin (36 sectors), and more.
- **Fixed stars** — 136-star catalog with common name and Bayer designation search. Magnitude, longitude, latitude, distance, and speeds.
- **Ayanamsa values** — 44 sidereal modes. Compare all in a sortable table.
- **Rise/Set times** — Rising, setting, upper/lower transit for any body.
- **Eclipses** — Solar and lunar eclipse search with circumstances.
- **Heliacal events** — First/last visibility of planets and stars.
- **Chart file import/export** — Reads and writes AAF, CHTK (Kala), JHD (Jagannatha Hora), QCK (Quick\*Chart), Astrolog, CSV, JSON, TOML formats.
- **Export** — Per-card clipboard copy, per-tab CSV/JSON export.
- **Context bar** — Date/time (with Julian Day), geographic coordinates, UTC offset, calendar system, ayanamsa, ephemeris source, house system.
- **Flag bar** — Composable Swiss Ephemeris calculation flags with auto-linking to context bar settings. Shows the computed `iflag` hex value.
- **4 themes** — Light, Dark, Cosmic, Forest with persistent preference.
- **Browser-style zoom** — Ctrl+=/- with responsive scaling.
- **Responsive layout** — Desktop, tablet, and mobile breakpoints.
- **Moshier fallback** — Works without .se1 ephemeris files using the built-in analytical ephemeris.

## Installation

### Linux

```bash
unzip eph-dashboard-linux.zip
cd ephemeris-dashboard/
./ephemeris_dashboard
```

### macOS

<!-- TODO: Test and fill in -->

### Windows

<!-- TODO: Test and fill in -->

### Android

<!-- TODO: Test and fill in -->

### iOS

<!-- TODO: Test and fill in -->

### Web

<!-- TODO: Test and fill in -->

## Building from Source

Requires Flutter SDK 3.11+ and a C compiler (for the native Swiss Ephemeris library, built automatically via Dart's native asset system).

```bash
# Linux
sudo pacman -S clang   # Arch
sudo apt install clang  # Debian/Ubuntu

# macOS — Xcode command line tools (usually already installed)
xcode-select --install

# Windows — Visual Studio Build Tools with C++ workload
```

```bash
git clone <repo-url>
cd swe_dashboard
flutter pub get
flutter run -d linux   # or macos, windows, chrome
```

The Swiss Ephemeris C library compiles automatically on first build via the native asset hook in the `swisseph` package.

## Usage

1. Set your date, time, location, and options in the **context bar** at the top.
2. Configure calculation flags in the **flag bar** (coordinate system, speed, aberration, etc.).
3. Switch to a tab and press **Calculate**.
4. Results appear as cards. Toggle between DMS, decimal, or raw format.
5. Copy individual cards or export the full tab as CSV/JSON.

## Ephemeris Sources

The Swiss Ephemeris supports three ephemeris modes:

| Mode | Accuracy | Files needed |
|------|----------|-------------|
| **Swiss Ephemeris** | Highest (sub-arcsecond) | `.se1` data files |
| **JPL DE431** | Highest | JPL ephemeris file |
| **Moshier** | Good (0.1 arcsecond for modern dates) | None (built-in) |

The app ships with Swiss Ephemeris data files on native platforms. On web, it uses Moshier mode automatically. If .se1 files are not found on a native platform, the ephemeris selector shows a warning and falls back to Moshier.

## Tests

```bash
flutter test test/goldens/                     # run golden image tests
flutter test test/goldens/ --update-goldens    # regenerate baselines
```

54 golden images across 3 screen sizes (mobile, tablet, desktop) x 2 themes (light, dark).

## License

[AGPL-3.0](LICENSE) — required by the Swiss Ephemeris license terms.
