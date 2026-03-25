import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

/// Global UI scale factor (1.0 = 100%). Ctrl+= / Ctrl+- to adjust.
final scaleFactorProvider = StateProvider<double>((ref) => 1.0);

const _scaleStep = 0.05;
const _scaleMin = 0.6;
const _scaleMax = 2.0;

void zoomIn(WidgetRef ref) {
  ref.read(scaleFactorProvider.notifier).update(
      (s) => (s + _scaleStep).clamp(_scaleMin, _scaleMax));
}

void zoomOut(WidgetRef ref) {
  ref.read(scaleFactorProvider.notifier).update(
      (s) => (s - _scaleStep).clamp(_scaleMin, _scaleMax));
}

void zoomReset(WidgetRef ref) {
  ref.read(scaleFactorProvider.notifier).state = 1.0;
}
