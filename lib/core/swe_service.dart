import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swisseph/swisseph.dart';

final sweProvider = Provider<SwissEph>((ref) {
  final swe = SwissEph(_findLibrary());
  ref.onDispose(() => swe.close());
  return swe;
});

/// Find libswisseph.so — checks the release bundle location first,
/// then falls back to SwissEph.findLibrary() for dev mode (.dart_tool).
String _findLibrary() {
  // Release build: lib/libswisseph.so next to the executable.
  final exeDir = File(Platform.resolvedExecutable).parent.path;
  for (final name in ['libswisseph.so', 'libswisseph.dylib']) {
    final path = '$exeDir/lib/$name';
    if (File(path).existsSync()) return path;
  }

  // Dev mode: .dart_tool search
  return SwissEph.findLibrary();
}
