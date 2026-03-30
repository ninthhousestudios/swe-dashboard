# Changelog

## [1.0.0] — 2026-03-30

Initial release. Cross-platform Swiss Ephemeris GUI via swisseph.dart.

### Features

- **18 calculation tabs:** Planets, Houses, Ayanamsa, Rise/Set, Eclipses, Stars, Crossings, Table, Dates, Coordinates, Nodes/Apsides, Heliacal, Phenomena, Differential, Planetocentric, Math, Config
- **Context bar:** Date/time input (with Julian Day display), geographic location, calendar system (Julian/Gregorian), ayanamsa selection, ephemeris source, house system
- **Flag bar:** Full Swiss Ephemeris calculation flags with auto-managed flags (sidereal, topocentric, heliocentric, barycentric, ephemeris source locked by context bar)
- **Explicit Calculate button:** Calculations run on demand, not on every state change
- **Chart file import/export:** 8 formats — AAF (AstroDienst), CHTK (Kala), JHD (Jagannatha Hora), QCK (Quick\*Chart), Astrolog, CSV, JSON, TOML
- **Export:** Per-card clipboard copy, per-tab CSV/JSON export
- **4 themes:** Dark, Light, Cosmic, Forest with persistent preference
- **Browser-style zoom:** Ctrl+=/- with responsive scaling across all UI elements
- **Responsive layout:** Desktop, tablet, and mobile breakpoints
- **Moshier fallback:** App works without .se1 ephemeris files using the built-in Moshier analytical ephemeris, with a warning label on the ephemeris selector

### Platforms

- Linux, macOS, Windows (desktop)
- Android, iOS (mobile)
- Web (WASM + Moshier mode)

### Dependencies

- Flutter 3.x (SDK ^3.11.1)
- swisseph ^0.4.3 (Swiss Ephemeris Dart FFI bindings)
- flutter_riverpod ^2.6.1 (state management)
