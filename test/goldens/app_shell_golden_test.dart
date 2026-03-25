import 'package:flutter_test/flutter_test.dart';

import 'package:swe_dashboard/layout/app_shell.dart';

import 'golden_helper.dart';

void main() {
  testWidgets('AppShell goldens', (tester) async {
    await generateGoldens(
      tester,
      'app_shell',
      const AppShell(),
      overrides: tabOverrides,
      allowOverflow: true,
    );
  });
}
