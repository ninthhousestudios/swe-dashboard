import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tab_definitions.dart';
import 'responsive_layout.dart';
import '../theme/theme_provider.dart';
import '../widgets/context_bar/context_bar.dart';
import '../core/context_provider.dart';
import '../core/display_format.dart';
import '../widgets/export_button.dart';
import '../widgets/flag_bar/flag_bar.dart';
import '../tabs/houses/houses_provider.dart';
import '../tabs/planets/planets_provider.dart';
import '../tabs/planets/planets_tab.dart';
import '../tabs/houses/houses_tab.dart';
import '../tabs/ayanamsa/ayanamsa_tab.dart';

final selectedTabProvider = StateProvider<AppTab>((ref) => AppTab.planets);

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> with TickerProviderStateMixin {
  late TabController _tabController;

  static final _allTabs = AppTab.values.toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _allTabs.length,
      vsync: this,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(selectedTabProvider.notifier).state =
            _allTabs[_tabController.index];
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(selectedTabProvider);
    final screenSize = ResponsiveLayout.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SWE Dashboard'),
        actions: [
          // Zoom controls
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            tooltip: 'Zoom out (Ctrl+-)',
            onPressed: () => zoomOut(ref),
          ),
          Builder(builder: (context) {
            final scale = ref.watch(scaleFactorProvider);
            return InkWell(
              onTap: () => zoomReset(ref),
              child: Tooltip(
                message: 'Reset zoom (Ctrl+0)',
                child: Text(
                  '${(scale * 100).round()}%',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            );
          }),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            tooltip: 'Zoom in (Ctrl+=)',
            onPressed: () => zoomIn(ref),
          ),
          const SizedBox(width: 4),
          // Theme toggle
          IconButton(
            icon: const Icon(Icons.brightness_6),
            tooltip: 'Toggle theme',
            onPressed: () {
              final current = ref.read(themeProvider);
              ref.read(themeProvider.notifier).state = switch (current) {
                ThemeMode.dark => ThemeMode.light,
                ThemeMode.light => ThemeMode.system,
                _ => ThemeMode.dark,
              };
            },
          ),
        ],
        bottom: screenSize == ScreenSize.mobile
            ? null
            : PreferredSize(
                preferredSize: Size.fromHeight(
                  46.0 * MediaQuery.textScalerOf(context).scale(1.0),
                ),
                child: _AllTabsBar(controller: _tabController),
              ),
      ),
      body: Column(
        children: [
          // Context bar
          const ContextBar(),
          // Flag bar (shown only for tabs with flags)
          if (selectedTab.hasFlags)
            FlagBar(
              trailing: _buildFlagBarTrailing(selectedTab),
            ),
          // Tab content
          Expanded(
            child: _TabContent(tab: selectedTab),
          ),
        ],
      ),
      // Mobile bottom navigation
      bottomNavigationBar: screenSize == ScreenSize.mobile
          ? _MobileTabBar(
              selectedTab: selectedTab,
              onSelected: (tab) {
                ref.read(selectedTabProvider.notifier).state = tab;
                final idx = AppTab.values.indexOf(tab);
                if (idx >= 0) _tabController.index = idx;
              },
            )
          : null,
    );
  }

  /// Format toggle + export button for tabs that use the flag bar.
  Widget? _buildFlagBarTrailing(AppTab tab) {
    final formatStyle = ButtonStyle(
      visualDensity: VisualDensity.compact,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: WidgetStatePropertyAll(
          Theme.of(context).textTheme.labelSmall),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 4),
      ),
      minimumSize: const WidgetStatePropertyAll(Size(0, 32)),
    );

    switch (tab) {
      case AppTab.planets:
        return Consumer(builder: (context, ref, _) {
          final format = ref.watch(planetsFormatProvider);
          final results = ref.watch(planetsResultsProvider);
          final jd = ref.watch(contextBarProvider).jdUt;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<DisplayFormat>(
                segments: DisplayFormat.values
                    .map((f) => ButtonSegment(value: f, label: Text(f.label)))
                    .toList(),
                selected: {format},
                onSelectionChanged: (s) =>
                    ref.read(planetsFormatProvider.notifier).state = s.first,
                style: formatStyle,
              ),
              const SizedBox(width: 8),
              ExportButton(
                hasResults: results.isNotEmpty,
                getRows: () => planetsToExportRows(results, format),
                filenameStem: 'swe_planets_${jd.toStringAsFixed(4)}',
              ),
            ],
          );
        });
      case AppTab.houses:
        return Consumer(builder: (context, ref, _) {
          final format = ref.watch(housesFormatProvider);
          final result = ref.watch(housesResultProvider);
          final jd = ref.watch(contextBarProvider).jdUt;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<DisplayFormat>(
                segments: DisplayFormat.values
                    .map((f) => ButtonSegment(value: f, label: Text(f.label)))
                    .toList(),
                selected: {format},
                onSelectionChanged: (s) =>
                    ref.read(housesFormatProvider.notifier).state = s.first,
                style: formatStyle,
              ),
              const SizedBox(width: 8),
              ExportButton(
                hasResults: result != null,
                getRows: () => result != null
                    ? housesToExportRows(result, format)
                    : [],
                filenameStem: 'swe_houses_${jd.toStringAsFixed(4)}',
              ),
            ],
          );
        });
      default:
        return null;
    }
  }
}

class _AllTabsBar extends StatelessWidget implements PreferredSizeWidget {
  const _AllTabsBar({required this.controller});
  final TabController controller;

  static final _allTabs = AppTab.values.toList();
  static final _dividerIndex = AppTab.primaryTabs.length;
  static const _baseHeight = 46.0;

  @override
  Size get preferredSize => const Size.fromHeight(_baseHeight);

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1.0);
    final barHeight = _baseHeight * scale;

    return SizedBox(
      height: barHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _allTabs.length + 1, // +1 for divider
        itemBuilder: (context, i) {
          // Insert divider at the boundary
          if (i == _dividerIndex) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: barHeight * 0.2),
              child: VerticalDivider(
                width: 1,
                thickness: 1,
                color: Theme.of(context).dividerColor,
              ),
            );
          }
          final tabIndex = i < _dividerIndex ? i : i - 1;
          final tab = _allTabs[tabIndex];
          return _TabButton(
            tab: tab,
            index: tabIndex,
            controller: controller,
          );
        },
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.tab,
    required this.index,
    required this.controller,
  });
  final AppTab tab;
  final int index;
  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final selected = controller.index == index;
        final color = selected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant;
        return InkWell(
          onTap: () => controller.animateTo(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(tab.icon, size: 16, color: color),
                const SizedBox(height: 2),
                Text(
                  tab.label,
                  style: theme.textTheme.labelSmall?.copyWith(color: color),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TabContent extends StatelessWidget {
  const _TabContent({required this.tab});
  final AppTab tab;

  @override
  Widget build(BuildContext context) {
    return switch (tab) {
      AppTab.planets => const PlanetsTab(),
      AppTab.houses => const HousesTab(),
      AppTab.ayanamsa => const AyanamsaTab(),
      _ => _Placeholder(tab: tab),
    };
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.tab});
  final AppTab tab;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(tab.icon, size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(tab.label, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Not implemented yet',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _MobileTabBar extends StatelessWidget {
  const _MobileTabBar({required this.selectedTab, required this.onSelected});
  final AppTab selectedTab;
  final ValueChanged<AppTab> onSelected;

  @override
  Widget build(BuildContext context) {
    // Show first 4 primary tabs + "more" on mobile
    final mobileTabs = AppTab.primaryTabs.take(4).toList();
    final selectedIndex = mobileTabs.indexOf(selectedTab);

    return NavigationBar(
      selectedIndex: selectedIndex >= 0 ? selectedIndex : 0,
      onDestinationSelected: (i) => onSelected(mobileTabs[i]),
      destinations: mobileTabs
          .map((t) => NavigationDestination(icon: Icon(t.icon), label: t.label))
          .toList(),
    );
  }
}
