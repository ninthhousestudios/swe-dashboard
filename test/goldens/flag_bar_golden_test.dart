import 'package:flutter_test/flutter_test.dart';

import 'package:swe_dashboard/widgets/flag_bar/flag_bar.dart';

import 'golden_helper.dart';

void main() {
  testWidgets('FlagBar goldens', (tester) async {
    await generateGoldens(
      tester,
      'flag_bar',
      const FlagBar(),
      allowOverflow: true,
    );
  });
}
