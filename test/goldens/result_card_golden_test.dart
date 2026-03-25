import 'package:flutter_test/flutter_test.dart';

import 'golden_helper.dart';

void main() {
  testWidgets('ResultCard goldens', (tester) async {
    await generateGoldens(tester, 'result_card', fakeResultCard());
  });

  testWidgets('ResultCard with actions goldens', (tester) async {
    await generateGoldens(
      tester,
      'result_card_actions',
      fakeResultCard(showActions: true),
    );
  });
}
