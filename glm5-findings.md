# Code Review: SWE Dashboard
**Reviewer:** GLM-5:cloud
**Date:** 2026-03-30

## Summary

This is a well-architected Flutter desktop/mobile application providing a GUI for the Swiss Ephemeris astronomical calculation library. The codebase demonstrates strong separation of concerns with Riverpod state management, proper disposal of resources, and careful handling of C global state for thread safety. The cross-platform file handling and responsive layout implementation are sophisticated. However, there are several correctness issues in coordinate sign handling, potential null dereferences, and error handling gaps that should be addressed before v1 release.

## Critical Findings

| # | File | Line(s) | Issue | Impact |
|---|------|---------|-------|--------|
| C1 | `lib/chart_formats/formats/jhd.dart` | 46, 97 | **Sign inversion bug in longitude handling.** JHD format stores longitudes with inverted sign convention (West positive). Lines 41 (read) applies `-rawLon` but line 97 (write) also applies `-chart.birthLocation.longitude`, resulting in double negation. Eastern longitudes will be corrupted on round-trip. | Data corruption - chart file I/O produces wrong coordinates |
| C2 | `lib/chart_formats/formats/qck.dart` | 69-74 | **String index out of bounds.** Line 65 reads `s[53]` without bounds check for strings shorter than 54 characters. The `padRight(100)` is applied AFTER extracting substrings, so short lines will crash on `s[53]`, `s[59]`, `s[96]`, `s[97]` accesses. | Crash when parsing malformed/short QCK files |
| C3 | `lib/chart_formats/formats/toml_chart.dart` | 114-139 | **Julian Day conversion gives wrong dates.** The algorithm doesn't handle BCE dates correctly (year ≤ 0). Also, the day fraction calculation at line 151-152 truncates hours incorrectly when `dt.hour + dt.minute/60 + dt.second/3600` produces a rounded value >= 24, which would break JD calculation. | Wrong calculation results for historical dates |
| C4 | `lib/tabs/heliacal/heliacal_tab.dart` | 547 | **Hour overflow in date formatting.** `swe.revjul()` can return `hour == 24.0` (midnight carry). The code uses `utcDt.add(Duration(hours: h, minutes: m))` but `h` comes from `t.truncate()` which will be 24, causing DateTime to roll over unexpectedly or throw. The comment mentions this case but doesn't handle it correctly. | Crash or wrong date display for heliacal events at midnight |

## High Findings

| # | File | Line(s) | Issue | Impact |
|---|------|---------|-------|--------|
| H1 | `lib/core/swe_service_io.dart` | 195-198 | **Silent catch discards errors.** The `_findLibraryInDartTool()` function catches all exceptions and returns `null`. This swallows permission errors, I/O errors, and other issues that should be logged. Debugging path resolution issues becomes very difficult. | Development friction - hard to debug library loading failures |
| H2 | `lib/widgets/context_bar/context_bar.dart` | 254-255 | **Controller text modified during build.** Inside `StatefulBuilder` in `_showPreciseTimePicker()`, lines 254-255 set `ctrl.text = value.str(...)`. This is called during the widget build phase of the dialog, which modifies the controller during the build cycle. Can cause framework assertion failures. | Potential UI assertion failure in time picker |
| H3 | `lib/tabs/heliacal/heliacal_provider.dart` | 137-145 | **Broad catch loses error context.** The provider catches `SweException` and then a generic `catch (e)` that wraps ALL remaining exceptions as `HeliacalCalcResult.error: e.toString()`. This includes `StateError`, `ArgumentError`, null pointer exceptions, etc., masking programming errors. | Debugging difficulty - all errors look the same |
| H4 | `lib/chart_formats/formats/aaf.dart` | 184-192 | **Regex not anchored.** `_parseAafCoord()` matches coordinates with regex `^(\d+)([nesw])(\d*)$` but doesn't validate format properly. Input like "90Xabc123" would parse as longitude 90 (stopping at X) when it should fail. Similar issue in `_parseAafTimezone()`. | Silent parsing of malformed coordinate data |
| H5 | `lib/tabs/stars/stars_provider.dart` | 201-213 | **Star fallback search is racy.** When the initial search fails to match, code retries with a comma-prefixed Bayer designation. But the `nameMatches()` function checks both `termLower` and `bayerTerm` which might not match the new search. Multiple users typing quickly could hit inconsistent states. | Unpredictable star search behavior under rapid input |
| H6 | `lib/tabs/planetocentric/planetocentric_provider.dart` | 82-84 | **ET vs UT not clearly documented.** The comment says "calcPctr takes ET" but the conversion `ectx.jdUt + swe.deltat()` is done inline. If `deltat()` is expensive (file I/O for some ephemeris settings), this could cause performance issues. Also, the conversion is not stored, so repeated calculations waste time. | Performance concern; undocumented API usage pattern |
| H7 | `lib/core/calc_context.dart` | 51-53 | **Ayanamsa mode set but never reset.** When `zodiacRef == ZodiacRef.sidereal`, `swe.setSidMode(ayanamsa)` is called, but there's no corresponding cleanup. If the SwissEph instance is reused across calculations with different contexts, stale sidereal mode could persist. This is mitigated by the singleton provider pattern but still architecturally concerning. | Potential cross-contamination of calculation settings |
| H8 | `lib/widgets/result_card.dart` | 113-114 | **Clipboard operation not guarded.** `Clipboard.setData()` is called without try-catch. On platforms where clipboard access is restricted (some mobile permissions models, corporate MDM), this could throw and crash the app. | Crash on clipboard-restricted environments |

## Medium Findings

| # | File | Line(s) | Issue | Impact |
|---|------|---------|-------|--------|
| M1 | `lib/layout/app_shell.dart` | 447-452 | **ScrollController position accessed without hasClients check.** `_scrollToSelected()` calls `_scrollController.position.viewportDimension` and `maxScrollExtent` without first checking `hasClients`. If called before the scroll view is built, this throws. The `addPostFrameCallback` pattern helps but isn't a guarantee. | Potential Flutter assertion on fast tab switches |
| M2 | `lib/chart_formats/formats/chtk.dart` | 222-226 | **UTF-16 decoder assumes valid input.** The `_decodeUtf16Le()` function doesn't validate that bytes.length is even or that surrogate pairs are complete. Malformed UTF-16 input (odd byte count, lone surrogates) would produce invalid Dart strings. | Silent production of invalid strings from malformed files |
| M3 | `lib/tabs/heliacal/heliacal_tab.dart` | 82-96 | **Star suggestions rebuild entire list on every keystroke.** `_onStarChanged()` calls `setState()` for every character typed, rebuilding the entire star catalog filter and suggestions list. For a 136-entry catalog this is fine, but the pattern doesn't scale. Should debounce. | Poor performance on slower devices |
| M4 | `lib/core/jd_utils.dart` | 26 | **Millisecond rounding not clamped.** Line 26 calculates `ms = ((secondFrac - s) * 1000).round()` but doesn't clamp. Rounding 59.999 seconds gives 60000ms, creating an invalid `DateTime` when passed to `DateTime.utc()`. | Edge case: invalid DateTime for certain JD values |
| M5 | `lib/tabs/eclipses/eclipses_provider.dart` | 169-173 | **Next eclipse search can infinite loop.** If `event.maxEclipseJd` is always null (error conditions), the search loop will `break` but that's not clearly handled. The code structure assumes success, but malformed results could leave the app hanging. | Infinite loop potential, though mitigation exists |
| M6 | `lib/core/persistence.dart` | 51-53, etc. | **Enum parsing can throw.** Using `Origin.values.firstWhere(..., orElse: ...)` is safe, but `values.byName(json['gender'] as String)` at line 87 in `chart_data.dart` can throw `ArgumentError` if the string doesn't match. Should use `try {...}` with a default. | Crash on corrupted persisted data |
| M7 | `lib/chart_formats/formats/json_chart.dart` | 12-14 | **No validation of JSON structure.** `jsonDecode()` succeeds but the cast `as Map<String, dynamic>` doesn't validate presence of required fields. If `ChartData.fromJson()` receives missing fields, null dereferences occur. | Crash on malformed JSON chart files |
| M8 | `lib/core/flag_state.dart` | 56-57 | **Set equality is order-dependent.** `toggles.containsAll(other.toggles)` alone isn't sufficient for equality when sets have different sizes. The `&&` with `length` check is correct, but `toggles.length == other.toggles.length && toggles.containsAll(other.toggles)` is the standard pattern. Current implementation is correct but fragile. | Minor: subtle equality bug potential |
| M9 | `lib/chart_formats/formats/astrolog.dart` | 35-37 | **Timezone sign convention unclear.** Line 35 negates the parsed value with `utcOffset = -(double.tryParse(parts[4]) ?? 0.0). The comment at line 10 says "Zone: positive = west of UTC, negative = east (US convention)" but the file format also uses `-qa` switch format. The sign handling should be validated against the Astrolog documentation. | Potential coordinate system confusion |

## Low Findings

| # | File | Line(s) | Issue | Impact |
|---|------|---------|-------|--------|
| L1 | `lib/core/display_format.dart` | Not examined | File not read - should verify DMS formatting handles negative values correctly (West/South coordinates) | Documentation/verification needed |
| L2 | `test/star_test.dart` | 21 | **Hardcoded path in test file.** `setEphePath('/home/josh/...')` is developer-specific and will fail on other machines. Tests should use relative paths or environment variables. | Test portability issue |
| L3 | Throughout | **Missing API docs.** Core calculation functions (`swe.calcUt()`, `swe.houses()`, etc.) are called without inline documentation explaining flag meanings, return value interpretations, or error conditions. | Maintainability: future contributors need Swiss Ephemeris docs |
| L4 | `lib/widgets/context_bar/context_bar.dart` | 330-336 | **UTC offset popup recreates labels.** `_utcOffsets` list is created once, but `_offsetLabel()` is called repeatedly in `itemBuilder`. Could be pre-computed for minor performance gain. | Minor efficiency |
| L5 | `lib/tabs/heliacal/heliacal_tab.dart` | 42-49 | **Seven TextEditingController instances.** While properly disposed, having 7 separate controllers for atmospheric fields suggests the UI could be refactored into a reusable parameter row widget. | Code organization |
| L6 | `lib/core/persistence.dart` | 88-94 | **String-to-int conversion for flags.** Storing flags as `"${flag.toInt()}"` string then `int.tryParse()` back is inefficient. Could use `setInt('key', flag)` directly for int-valued flags. | Minor storage inefficiency |

## Positive Observations

1. **Excellent C global state management:** The `EffectiveContext.calculate()` pattern (lines 39-46 of `calc_context.dart`) atomically sets C globals before each calculation, avoiding race conditions with per-card overrides and ensuring thread safety.

2. **Robust cross-platform file handling:** The `ChartIO` class properly dispatches to format-specific parsers for 8 different chart file formats. The `swe_service_io.dart` file thoroughly handles desktop release/dev modes, mobile asset extraction, and version checking.

3. **Proper resource disposal:** Every `StatefulWidget` with controllers or focus nodes implements `dispose()` to clean up, preventing memory leaks. This is often missed in Flutter codebases.

4. **Thoughtful provider architecture:** The separation of `calcTriggerProvider` as an explicit "recalculate now" signal rather than reacting to every state change is the right pattern for expensive astronomical calculations.

5. **Progressive disclosure UI:** The collapsible context bar on mobile and the expandable atmospheric parameters in the Heliacal tab show good UX awareness—surface the most common options while hiding complexity.

6. **Accessible responsive layout:** The `MediaQuery.textScalerOf(context).scale(1.0)` pattern for computing scalable widths respects browser zoom and accessibility font scaling, which many apps hardcode.

7. **Comprehensive flag bar management:** The `autoManagedFlags` set and the `lockedFlagsFrom()` static function correctly prevent users from setting conflicting flags (sidereal + topocentric when the context bar already defines origin).

8. **File format round-trip consideration:** Most formats handle the sign conventions for longitude/latitude correctly (Kala, Astrolog). The JHD bug is the exception that proves the rule.

9. **Provider dependency ordering:** The `contextBarProvider` factory correctly uses `ref.watch()` for dependencies, and the flag bar's `ref.listen()` pattern avoids infinite rebuild loops while staying synchronized.

10. **Good null safety discipline:** Most code uses `?.` appropriately and provides fallback values (e.g., `lines[12] ?? ''`). The few issues found are edge cases in parsing.