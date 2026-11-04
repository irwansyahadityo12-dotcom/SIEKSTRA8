import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'ekskul_detail_screen.dart';
import 'members_screen.dart';
import 'approval_screen.dart';
import 'schedule_screen.dart';

final ValueNotifier<int> tabIndex = ValueNotifier<int>(0);

class MainShell extends StatelessWidget {
  const MainShell({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: tabIndex,
      builder: (_, i, __) => Scaffold(
        body: IndexedStack(index: i, children: const [HomeScreen(), EkskulDetailScreen(), MembersScreen(), ApprovalScreen(), ScheduleScreen()]),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.line))),
          child: NavigationBar(
            selectedIndex: i,
            height: 68,
            onDestinationSelected: (v) => tabIndex.value = v,
            destinations: [
              _d(Icons.home_outlined, Icons.home_rounded, 'Beranda'),
              _d(Icons.layers_outlined, Icons.layers_rounded, 'Ekskul'),
              _d(Icons.groups_outlined, Icons.groups_rounded, 'Anggota'),
              NavigationDestination(
                icon: Badge(smallSize: 9, backgroundColor: AppColors.red, child: const Icon(Icons.person_add_alt_1_outlined, color: AppColors.muted)),
                selectedIcon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
                label: 'Daftar',
              ),
              _d(Icons.calendar_month_outlined, Icons.calendar_month_rounded, 'Jadwal'),
            ],
          ),
        ),
      ),
    );
  }

  NavigationDestination _d(IconData o, IconData s, String l) =>
      NavigationDestination(icon: Icon(o, color: AppColors.muted), selectedIcon: Icon(s, color: AppColors.primary), label: l);
}
