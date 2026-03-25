import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'context_provider.dart';
import 'context_state.dart';
import 'flag_state.dart';

/// Global flag bar state provider.
final flagBarProvider =
    StateNotifierProvider<FlagBarNotifier, FlagBarState>((ref) {
  final notifier = FlagBarNotifier();

  // Auto-link: update locked flags when context bar changes.
  // Use ref.listen (not ref.watch inside notifier) to avoid infinite loops.
  ref.listen<ContextBarState>(contextBarProvider, (prev, next) {
    notifier.syncLockedFlags(next);
  });

  // Set initial locked flags from current context.
  final ctx = ref.read(contextBarProvider);
  notifier.syncLockedFlags(ctx);

  return notifier;
});

class FlagBarNotifier extends StateNotifier<FlagBarState> {
  FlagBarNotifier() : super(const FlagBarState());

  /// Set the mutually exclusive coordinate group.
  void setCoordGroup(int value) {
    state = state.copyWith(coordValue: value);
  }

  /// Toggle a composable flag on/off.
  void toggleFlag(int value) {
    final newToggles = Set<int>.from(state.toggles);
    if (newToggles.contains(value)) {
      newToggles.remove(value);
    } else {
      newToggles.add(value);
    }
    state = state.copyWith(toggles: newToggles);
  }

  /// Set a composable flag explicitly on or off.
  void setFlag(int value, bool on) {
    final newToggles = Set<int>.from(state.toggles);
    if (on) {
      newToggles.add(value);
    } else {
      newToggles.remove(value);
    }
    state = state.copyWith(toggles: newToggles);
  }

  /// Update locked flags from context bar state.
  /// Called by ref.listen — guard against no-op to avoid rebuild churn.
  void syncLockedFlags(ContextBarState ctx) {
    final newLocked = FlagBarState.lockedFlagsFrom(ctx);
    if (newLocked != state.lockedFlags) {
      state = state.copyWith(lockedFlags: newLocked);
    }
  }
}
