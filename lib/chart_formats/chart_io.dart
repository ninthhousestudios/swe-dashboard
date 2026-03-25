import 'package:path/path.dart' as p;

import 'model/chart_data.dart';
import 'formats/chtk.dart';
import 'formats/jhd.dart';
import 'formats/aaf.dart';
import 'formats/astrolog.dart';
import 'formats/json_chart.dart';
import 'formats/csv_chart.dart';
import 'formats/toml_chart.dart';
import 'formats/qck.dart';

/// Unified chart I/O — dispatches to the correct format by file extension.
class ChartIO {
  static const supportedExtensions = [
    '.chtk', '.jhd', '.aaf', '.as', '.json', '.csv', '.toml', '.qck',
  ];

  static const formatDescriptions = {
    '.chtk': 'Kala Vedic Astrology',
    '.jhd': 'Jagannatha Hora',
    '.aaf': 'AAF\'97 Astrological Exchange Format',
    '.as': 'Astrolog',
    '.json': 'JSON (native)',
    '.csv': 'CSV tabular',
    '.toml': 'TOML (native)',
    '.qck': 'Quick*Chart (Solar Fire / Astrolog interchange)',
  };

  /// Read a chart from any supported format.
  static ChartData read(String filePath) {
    final ext = p.extension(filePath).toLowerCase();
    return switch (ext) {
      '.chtk' => ChtkFormat.read(filePath),
      '.jhd' => JhdFormat.read(filePath),
      '.aaf' => AafFormat.read(filePath),
      '.as' => AstrologFormat.read(filePath),
      '.json' => JsonChartFormat.read(filePath),
      '.csv' => CsvChartFormat.read(filePath),
      '.toml' => TomlChartFormat.read(filePath),
      '.qck' => QckFormat.read(filePath),
      _ => throw UnsupportedError('Unknown chart format: $ext'),
    };
  }

  /// Write a chart to any supported format.
  static void write(String filePath, ChartData chart) {
    final ext = p.extension(filePath).toLowerCase();
    switch (ext) {
      case '.chtk':
        ChtkFormat.write(filePath, chart);
      case '.jhd':
        JhdFormat.write(filePath, chart);
      case '.aaf':
        AafFormat.write(filePath, chart);
      case '.as':
        AstrologFormat.write(filePath, chart);
      case '.json':
        JsonChartFormat.write(filePath, chart);
      case '.csv':
        CsvChartFormat.write(filePath, chart);
      case '.toml':
        TomlChartFormat.write(filePath, chart);
      case '.qck':
        QckFormat.write(filePath, chart);
      default:
        throw UnsupportedError('Unknown chart format: $ext');
    }
  }

  /// Convert a chart file from one format to another.
  static ChartData convert(String inputPath, String outputPath) {
    final chart = read(inputPath);
    write(outputPath, chart);
    return chart;
  }
}
