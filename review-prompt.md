# Code Review Prompt for SWE Dashboard

You are reviewing a Flutter/Dart cross-platform app (Linux, macOS, Windows, iOS, Android, Web) that provides a GUI for the Swiss Ephemeris astronomical calculation library.

## Instructions

1. **DO NOT modify any files.** This is a read-only review.
2. Write ALL findings to a single markdown file when done (see output format below).
3. Be thorough — examine every `.dart` file under `lib/` and `test/`.
4. Focus on real bugs, correctness issues, and security problems. Style nits are low priority.

## Project Context

- **State management:** Riverpod (StateNotifier, no codegen). Explicit Calculate button triggers computation.
- **Architecture:** `EffectiveContext` merges global context + flags + per-card overrides. C globals are set atomically at calculation time via `ectx.calculate(swe, fn)`.
- **Cross-platform:** Uses `file_picker` for mobile/web file selection, native file dialog for desktop. Ephemeris files (.se1) extracted to app support dir on mobile/macOS, bundled next to exe on Linux/Windows.
- **Responsive:** Supports browser-style zoom via `MediaQuery.textScalerOf`. Mobile layout has collapsible context bar and scrollable bottom nav.

## What to Look For

### Critical (blocks shipping)
- Crashes: null dereferences, unhandled exceptions, index out of bounds
- Wrong results: incorrect astronomical calculations, sign inversions, unit errors
- Data loss: file corruption on read/write round-trips
- Security: path traversal, injection, unsafe file handling

### High (should fix before v1)
- Platform-specific failures (works on Linux but crashes on iOS, etc.)
- Race conditions in async code or provider graph
- Resource leaks (controllers, streams, subscriptions not disposed)
- Error handling gaps (user sees stack trace instead of error message)

### Medium (fix soon after v1)
- Edge cases that produce wrong UI but don't crash
- Performance issues (unnecessary rebuilds, expensive operations in build())
- Accessibility gaps
- API misuse (wrong SwissEph flags, incorrect JD conversion)

### Low (nice to have)
- Code organization, naming, dead code
- Missing tests for critical paths
- Documentation gaps

## Key Files to Examine Carefully

- `lib/core/swe_service_io.dart` — native library loading, ephemeris path resolution
- `lib/core/calc_context.dart` — C globals management
- `lib/widgets/context_bar/context_bar.dart` — largest file (850+ lines), mobile/desktop layouts
- `lib/tabs/planetocentric/planetocentric_provider.dart` — newest tab, uses calcPctr
- `lib/chart_formats/formats/*.dart` — 8 file format parsers (chtk, jhd, aaf, astrolog, csv, json, qck, toml)
- `lib/layout/app_shell.dart` — responsive shell, mobile tab bar
- `lib/tabs/heliacal/heliacal_tab.dart` — heliacal events, JD-to-date conversion
- `lib/tabs/stars/stars_provider.dart` — fixed star calculations

## Output Format

Write findings to a markdown file with this structure:

```markdown
# Code Review: SWE Dashboard
**Reviewer:** [model name]
**Date:** 2026-03-30

## Summary
[2-3 sentence overall assessment]

## Critical Findings
| # | File | Line(s) | Issue | Impact |
|---|------|---------|-------|--------|

## High Findings
| # | File | Line(s) | Issue | Impact |
|---|------|---------|-------|--------|

## Medium Findings
| # | File | Line(s) | Issue | Impact |
|---|------|---------|-------|--------|

## Low Findings
| # | File | Line(s) | Issue | Impact |
|---|------|---------|-------|--------|

## Positive Observations
[What's done well — architecture, patterns, etc.]
```

Write the output file as:
- Devstral: `./devstral-findings.md`
- GLM-5: `./glm5-findings.md`
