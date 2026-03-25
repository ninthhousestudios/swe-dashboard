import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global calculation trigger. Increment to recalculate all active tabs.
/// The flag bar's Calculate button drives this.
final calcTriggerProvider = StateProvider<int>((ref) => 0);
