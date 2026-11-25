import 'package:flutter/material.dart';
import '../../app/session.dart';
import '../core/theme.dart';
import 'home_screen.dart';
import 'ekskul_list_screen.dart';
import 'gemini_ai_screen.dart';
import 'schedule_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'student_drawer.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int index = widget.initialIndex;

  @override
  void initState() {
    super.initState();
    loadCurrentProfile();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(goTab: (i) => setState(() => index = i)),
      const EkskulListScreen(),
      const GeminiAiScreen(),
      const ScheduleScreen(),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      drawer: StudentDrawer(onSelectTab: (i) => setState(() => index = i)),
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x141D4ED8),
              blurRadius: 16,
              offset: Offset(0, -4),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (i) => setState(() => index = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: C.primary,
          unselectedItemColor: C.muted,
          selectedLabelStyle: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 10.5),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Ekskul',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: index == 2 ? const Color(0xFFEEF2FF) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_outlined, color: Color(0xFF6366F1)),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF2563EB)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white),
              ),
              label: 'Gemini AI',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Jadwal',
            ),
            BottomNavigationBarItem(
              icon: Badge(smallSize: 8, child: const Icon(Icons.notifications_none)),
              activeIcon: Badge(smallSize: 8, child: const Icon(Icons.notifications)),
              label: 'Notifikasi',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
