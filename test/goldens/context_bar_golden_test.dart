import 'package:flutter_test/flutter_test.dart';

import 'package:swe_dashboard/widgets/context_bar/context_bar.dart';

import 'golden_helper.dart';

void main() {
  testWidgets('ContextBar goldens', (tester) async {
    await generateGoldens(
      tester,
      'context_bar',
      const ContextBar(),
      allowOverflow: true,
    );
  });
}
