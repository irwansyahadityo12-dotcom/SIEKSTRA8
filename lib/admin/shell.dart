import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/home_screen.dart';
import 'screens/ekstra_screen.dart';
import 'screens/pendaftaran_screen.dart';
import 'screens/proposal_list_screen.dart';
import 'screens/presensi_screen.dart';
import 'screens/sistem_screen.dart';

final ValueNotifier<int> tabIndex = ValueNotifier<int>(0);

void goTab(BuildContext c, int i) {
  Navigator.of(c).popUntil((r) => r.isFirst);
  tabIndex.value = i;
}

class MainShell extends StatelessWidget {
  const MainShell({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: tabIndex,
      builder: (_, i, __) => Scaffold(
        body: IndexedStack(index: i, children: const [HomeScreen(), EkstraScreen(), PendaftaranScreen(), ProposalListScreen(), PresensiScreen(), SistemScreen()]),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: C.line))),
          child: NavigationBar(
            selectedIndex: i,
            height: 66,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (v) => tabIndex.value = v,
            destinations: [
              _d(Icons.grid_view_rounded, 'Beranda'),
              _d(Icons.sports_soccer_outlined, 'Ekstra'),
              _d(Icons.how_to_reg_outlined, 'Pendaftaran'),
              _d(Icons.description_outlined, 'Proposal'),
              _d(Icons.fact_check_outlined, 'Presensi'),
              _d(Icons.tune_rounded, 'Sistem'),
            ],
          ),
        ),
      ),
    );
  }

  NavigationDestination _d(IconData i, String l) => NavigationDestination(icon: Icon(i, color: C.muted), selectedIcon: Icon(i, color: C.primary), label: l);
}
