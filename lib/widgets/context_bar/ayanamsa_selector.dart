import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/context_provider.dart';
import 'labeled_dropdown.dart';

/// Ayanamsa mode dropdown (SE_SIDM_* constants).
class AyanamsaSelector extends ConsumerWidget {
  const AyanamsaSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ayanamsa = ref.watch(contextBarProvider.select((s) => s.ayanamsa));

    return LabeledDropdown<int>(
      label: 'Ayanamsa',
      value: ayanamsa,
      items: _ayanamsaEntries.map((e) => e.id).toList(),
      itemLabel: (id) =>
          _ayanamsaEntries.firstWhere((e) => e.id == id).name,
      onChanged: (v) {
        ref.read(contextBarProvider.notifier).setAyanamsa(v);
      },
    );
  }
}

class _AyanamsaEntry {
  const _AyanamsaEntry(this.id, this.name);
  final int id;
  final String name;
}

const _ayanamsaEntries = [
  _AyanamsaEntry(-1, 'None (Tropical)'),
  _AyanamsaEntry(0, 'Fagan/Bradley'),
  _AyanamsaEntry(1, 'Lahiri'),
  _AyanamsaEntry(2, 'De Luce'),
  _AyanamsaEntry(3, 'Raman'),
  _AyanamsaEntry(4, 'Usha/Shashi'),
  _AyanamsaEntry(5, 'Krishnamurti'),
  _AyanamsaEntry(6, 'Djwhal Khul'),
  _AyanamsaEntry(7, 'Yukteshwar'),
  _AyanamsaEntry(8, 'J.N. Bhasin'),
  _AyanamsaEntry(9, 'Babylonian (Kugler 1)'),
  _AyanamsaEntry(10, 'Babylonian (Kugler 2)'),
  _AyanamsaEntry(11, 'Babylonian (Kugler 3)'),
  _AyanamsaEntry(12, 'Babylonian (Huber)'),
  _AyanamsaEntry(13, 'Babylonian (ETPSC)'),
  _AyanamsaEntry(14, 'Aldebaran 15 Tau'),
  _AyanamsaEntry(15, 'Hipparchos'),
  _AyanamsaEntry(16, 'Sassanian'),
  _AyanamsaEntry(17, 'Galactic Ctr 0 Sag'),
  _AyanamsaEntry(18, 'J2000'),
  _AyanamsaEntry(19, 'J1900'),
  _AyanamsaEntry(20, 'B1950'),
  _AyanamsaEntry(21, 'Suryasiddhanta'),
  _AyanamsaEntry(22, 'Suryasiddhanta (mean Sun)'),
  _AyanamsaEntry(23, 'Aryabhata'),
  _AyanamsaEntry(24, 'Aryabhata (mean Sun)'),
  _AyanamsaEntry(25, 'SS Revati'),
  _AyanamsaEntry(26, 'SS Citra'),
  _AyanamsaEntry(27, 'True Citra'),
  _AyanamsaEntry(28, 'True Revati'),
  _AyanamsaEntry(29, 'True Pushya'),
  _AyanamsaEntry(30, 'Galactic Ctr (Gilbrand)'),
  _AyanamsaEntry(31, 'Gal. Equator (IAU 1958)'),
  _AyanamsaEntry(32, 'Gal. Equator (True)'),
  _AyanamsaEntry(33, 'Gal. Equator (Mula)'),
  _AyanamsaEntry(34, 'Gal. Alignment (Mardyks)'),
  _AyanamsaEntry(35, 'True Mula'),
  _AyanamsaEntry(36, 'Galactic Ctr (Mula/Wilhelm)'),
  _AyanamsaEntry(37, 'Aryabhata 522'),
  _AyanamsaEntry(38, 'Babylonian (Britton)'),
  _AyanamsaEntry(39, 'True Sheoran'),
  _AyanamsaEntry(40, 'Galactic Ctr (Cochrane)'),
  _AyanamsaEntry(41, 'Gal. Equator (Fiorenza)'),
  _AyanamsaEntry(42, 'Valens (Moon)'),
  _AyanamsaEntry(43, 'Lahiri 1940'),
  _AyanamsaEntry(44, 'Lahiri VP285'),
  _AyanamsaEntry(45, 'Krishnamurti VP291'),
  _AyanamsaEntry(46, 'Lahiri ICRC'),
];
