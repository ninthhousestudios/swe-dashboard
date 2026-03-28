import 'package:swisseph/swisseph.dart';

/// Stub for web — these functions are never called on web,
/// but the conditional import requires matching signatures.

class NativeInitResult {
  final String? ephePath;
  final SwissEph? swe;
  const NativeInitResult({this.ephePath, this.swe});
}

Future<NativeInitResult> initNativeEphePath() =>
    throw UnsupportedError('Not available on web');

SwissEph createDesktopSwissEph() =>
    throw UnsupportedError('Not available on web');
