import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swisseph/swisseph.dart';

import 'context_state.dart';
import 'jd_utils.dart';
import 'swe_service.dart';

/// Global context bar state provider.
final contextBarProvider =
    StateNotifierProvider<ContextBarNotifier, ContextBarState>((ref) {
  final swe = ref.watch(sweProvider);
  return ContextBarNotifier(swe);
});

/// Manages context bar state with bidirectional JD ↔ DateTime sync.
class ContextBarNotifier extends StateNotifier<ContextBarState> {
  ContextBarNotifier(SwissEph swe)
      : _jdUtils = JdUtils(swe),
        super(_initialState(swe));

  final JdUtils _jdUtils;

  static ContextBarState _initialState(SwissEph swe) {
    final now = DateTime.now().toUtc();
    final jdUtils = JdUtils(swe);
    final jd = jdUtils.dateTimeToJd(now);
    final localOffset = DateTime.now().timeZoneOffset.inMinutes / 60.0;
    return ContextBarState(
      dateTime: now,
      utcOffset: localOffset,
      jdUt: jd,
    );
  }

  /// Set date/time (UT) — JD is recomputed.
  void setDateTime(DateTime dt) {
    final jd = _jdUtils.dateTimeToJd(dt);
    state = state.copyWith(dateTime: dt, jdUt: jd);
  }

  /// Set Julian Day — DateTime is recomputed.
  void setJd(double jd) {
    final dt = _jdUtils.jdToDateTime(jd);
    state = state.copyWith(jdUt: jd, dateTime: dt);
  }

  /// Set UTC offset (display only — does not change UT or JD).
  void setUtcOffset(double offsetHours) {
    state = state.copyWith(utcOffset: offsetHours);
  }

  /// Set "now" — current system time.
  void setNow() {
    final now = DateTime.now().toUtc();
    final jd = _jdUtils.dateTimeToJd(now);
    state = state.copyWith(dateTime: now, jdUt: jd);
  }

  /// Set geographic location.
  void setLocation({
    required double latitude,
    required double longitude,
    double? altitude,
    String? cityLabel,
  }) {
    state = state.copyWith(
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      cityLabel: cityLabel,
    );
  }

  void setOrigin(Origin origin) {
    state = state.copyWith(origin: origin);
  }

  void setZodiacRef(ZodiacRef zodiacRef) {
    state = state.copyWith(zodiacRef: zodiacRef);
  }

  void setEqRef(EqRef eqRef) {
    state = state.copyWith(eqRef: eqRef);
  }

  void setAyanamsa(int sidMode) {
    state = state.copyWith(ayanamsa: sidMode);
  }

  void setEpheSource(EpheSource source) {
    state = state.copyWith(epheSource: source);
  }
}
