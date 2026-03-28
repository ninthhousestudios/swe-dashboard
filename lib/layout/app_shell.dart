import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tab_definitions.dart';
import 'responsive_layout.dart';
import '../core/persistence.dart';
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
import '../tabs/dates/dates_tab.dart';
import '../tabs/differential/differential_tab.dart';
import '../tabs/math/math_tab.dart';
import '../tabs/phenomena/phenomena_tab.dart';
import '../tabs/nodes_apsides/nodes_apsides_tab.dart';
import '../tabs/coordinates/coordinates_tab.dart';
import '../tabs/rise_set/rise_set_tab.dart';
import '../tabs/stars/stars_tab.dart';
import '../tabs/crossings/crossings_tab.dart';
import '../tabs/heliacal/heliacal_tab.dart';
import '../tabs/eclipses/eclipses_tab.dart';
import '../tabs/table_view/table_view_tab.dart';
import '../tabs/table_view/table_view_provider.dart';
import '../tabs/config/config_tab.dart';

final selectedTabProvider = StateProvider<AppTab>((ref) {
  final persistence = ref.read(persistenceProvider);
  return persistence.loadTab();
});

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
    // Restore persisted context bar state after the widget tree finishes building.
    Future.microtask(() {
      ref.read(contextBarProvider.notifier).restoreFromPersistence();
    });

    final initialTab = ref.read(selectedTabProvider);
    final initialIndex = _allTabs.indexOf(initialTab);

    _tabController = TabController(
      length: _allTabs.length,
      initialIndex: initialIndex >= 0 ? initialIndex : 0,
      vsync: this,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final tab = _allTabs[_tabController.index];
        ref.read(selectedTabProvider.notifier).state = tab;
        ref.read(persistenceProvider).saveTab(tab);
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
              final next = switch (current) {
                ThemeMode.dark => ThemeMode.light,
                ThemeMode.light => ThemeMode.system,
                _ => ThemeMode.dark,
              };
              ref.read(themeProvider.notifier).state = next;
              ref.read(persistenceProvider).saveTheme(next);
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
      case AppTab.tableView:
        return Consumer(builder: (context, ref, _) {
          final format = ref.watch(tableViewFormatProvider);
          final results = ref.watch(tableViewResultsProvider);
          final bodies = ref.watch(tableViewBodiesProvider);
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<DisplayFormat>(
                segments: DisplayFormat.values
                    .map((f) => ButtonSegment(value: f, label: Text(f.label)))
                    .toList(),
                selected: {format},
                onSelectionChanged: (s) =>
                    ref.read(tableViewFormatProvider.notifier).state = s.first,
                style: formatStyle,
              ),
              const SizedBox(width: 8),
              ExportButton(
                hasResults: results.isNotEmpty,
                getRows: () =>
                    tableViewToExportRows(results, bodies, format),
                filenameStem: 'swe_table',
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
      AppTab.dates => const DatesTab(),
      AppTab.differential => const DifferentialTab(),
      AppTab.math => const MathTab(),
      AppTab.phenomena => const PhenomenaTab(),
      AppTab.nodesApsides => const NodesApsidesTab(),
      AppTab.coordinates => const CoordinatesTab(),
      AppTab.riseSet => const RiseSetTab(),
      AppTab.stars => const StarsTab(),
      AppTab.crossings => const CrossingsTab(),
      AppTab.heliacal => const HeliacalTab(),
      AppTab.eclipses => const EclipsesTab(),
      AppTab.tableView => const TableViewTab(),
      AppTab.config => const ConfigTab(),
    };
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
