import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show StandardMessageCodec, rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:swisseph/swisseph.dart';

/// Result of native ephemeris path initialization.
class NativeInitResult {
  final String? ephePath;
  final SwissEph? swe;
  const NativeInitResult({this.ephePath, this.swe});
}

/// Initialize ephemeris path and optionally preload SwissEph on native platforms.
Future<NativeInitResult> initNativeEphePath() async {
  // --- Desktop release build: ephe/ next to the executable ---
  final exeDir = File(Platform.resolvedExecutable).parent.path;
  final releaseEphe = '$exeDir/data/ephe';
  if (_isValidEpheDir(releaseEphe)) {
    return NativeInitResult(ephePath: releaseEphe);
  }

  // --- Desktop dev mode: find swisseph package in pub cache ---
  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    final pkgConfigFile =
        File('${Directory.current.path}/.dart_tool/package_config.json');
    if (pkgConfigFile.existsSync()) {
      final config =
          jsonDecode(pkgConfigFile.readAsStringSync()) as Map<String, dynamic>;
      final packages = config['packages'] as List<dynamic>;
      for (final pkg in packages) {
        if (pkg['name'] == 'swisseph') {
          final rootUri = pkg['rootUri'] as String;
          var pkgRoot = Uri.parse(rootUri).toFilePath();
          if (!pkgRoot.endsWith('/')) pkgRoot = '$pkgRoot/';
          final epheDir = '${pkgRoot}ephe';
          if (_isValidEpheDir(epheDir)) {
            return NativeInitResult(ephePath: epheDir);
          }
        }
      }
    }
  }

  // --- Mobile (Android/iOS): extract assets to app support directory ---
  if (Platform.isAndroid || Platform.isIOS) {
    final appDir = await getApplicationSupportDirectory();
    final epheDir = Directory('${appDir.path}/ephe');

    if (!_isValidEpheDir(epheDir.path)) {
      await epheDir.create(recursive: true);
      final epheFiles = await _listEpheAssets();

      for (final fileName in epheFiles) {
        final data = await rootBundle.load('assets/ephe/$fileName');
        final outFile = File('${epheDir.path}/$fileName');
        await outFile.writeAsBytes(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
          flush: true,
        );
      }
    }

    final swe = SwissEph(
        Platform.isAndroid ? 'libswisseph.so' : 'libswisseph.dylib');
    return NativeInitResult(ephePath: epheDir.path, swe: swe);
  }

  throw StateError(
    'Swiss Ephemeris data files not found. '
    'The app cannot run without .se1 files.',
  );
}

/// Create a SwissEph instance for desktop (release bundle or dev mode).
SwissEph createDesktopSwissEph() {
  final exeDir = File(Platform.resolvedExecutable).parent.path;
  for (final name in ['libswisseph.so', 'libswisseph.dylib']) {
    final path = '$exeDir/lib/$name';
    if (File(path).existsSync()) return SwissEph(path);
  }
  return SwissEph.find();
}

bool _isValidEpheDir(String path) {
  final dir = Directory(path);
  if (!dir.existsSync()) return false;
  return dir.listSync().any((e) => e.path.endsWith('.se1'));
}

Future<List<String>> _listEpheAssets() async {
  try {
    final manifestBytes = await rootBundle.load('AssetManifest.bin');
    final manifest = const StandardMessageCodec()
        .decodeMessage(manifestBytes) as Map<Object?, Object?>;
    return manifest.keys
        .map((k) => k.toString())
        .where((k) => k.startsWith('assets/ephe/'))
        .map((k) => k.split('/').last)
        .toList();
  } catch (_) {
    final files = ['sefstars.txt'];
    for (final n in ['00', '06', '12', '18', '24', '30', '36', '42', '48']) {
      files.addAll(['seas_$n.se1', 'semo_$n.se1', 'sepl_$n.se1']);
    }
    for (final n in ['06', '12', '18', '24', '30', '36', '42', '48', '54']) {
      files.addAll(['seasm$n.se1', 'semom$n.se1', 'seplm$n.se1']);
    }
    return files;
  }
}
