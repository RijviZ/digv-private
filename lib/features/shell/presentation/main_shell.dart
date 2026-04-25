import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/features/home_discovery/presentation/screens/home_screen.dart';
import 'package:digv/features/more/presentation/screens/more_screen.dart';
import 'package:digv/features/orders/presentation/screens/my_orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ── Tab index constants (public so router can reference them) ──────────────
const int kHomeTab = 0;
const int kOrdersTab = 1;
const int kMoreTab = 2;

/// ─────────────────────────────────────────────────────────────────────────
/// [MainShell] — the root frame of the app after login.
///
/// Owns the SINGLE bottom navigation bar and switches between
/// [HomeScreen], [MyOrdersScreen] and [MoreScreen] using an [IndexedStack].
/// No individual screen should define its own bottom nav bar.
/// ─────────────────────────────────────────────────────────────────────────
class MainShell extends StatefulWidget {
  /// Which tab to activate on first render. Defaults to [kHomeTab].
  final int initialTab;

  const MainShell({super.key, this.initialTab = kHomeTab});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _tab;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

  void _switchTab(int index) => setState(() => _tab = index);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      // ── Tab content — all three screens stay alive ─────────────────
      body: IndexedStack(
        index: _tab,
        children: const [
          HomeScreen(),      // Tab 0
          MyOrdersScreen(),  // Tab 1
          MoreScreen(),      // Tab 2
        ],
      ),
      // ── Single fixed bottom navigation bar ─────────────────────────
      bottomNavigationBar: _BottomNav(
        selectedIndex: _tab,
        onTap: _switchTab,
      ),
    );
  }
}

// ── Bottom Navigation Bar ──────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.selectedIndex, required this.onTap});

  static const _items = [
    _NavDef(label: 'Home', asset: 'assets/images/home', index: kHomeTab),
    _NavDef(label: 'Orders', asset: 'assets/images/order', index: kOrdersTab),
    _NavDef(label: 'More', asset: 'assets/images/more', index: kMoreTab),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      padding: EdgeInsets.only(
        top: 8,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _items
            .map((def) => _NavItem(
                  def: def,
                  isSelected: selectedIndex == def.index,
                  onTap: () => onTap(def.index),
                ))
            .toList(),
      ),
    );
  }
}

class _NavDef {
  final String label;
  final String asset;
  final int index;
  const _NavDef(
      {required this.label, required this.asset, required this.index});
}

class _NavItem extends StatelessWidget {
  final _NavDef def;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.def,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        isSelected ? theme.colorScheme.primary : theme.colorScheme.secondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              isSelected
                  ? '${def.asset}-selected.svg'
                  : '${def.asset}.svg',
              height: 24,
              width: 24,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(height: 4),
            Text(
              def.label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontFamily: AppTextStyles.fontFamily,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
