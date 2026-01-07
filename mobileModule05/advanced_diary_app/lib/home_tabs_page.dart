import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'calendar_page.dart';
import 'theme.dart';

class HomeTabsPage extends StatelessWidget {
  const HomeTabsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Scaffold(
          // Pas d'appBar ici; chaque page gère sa propre AppBar via BackgroundScaffold
          body: const TabBarView(
            physics: BouncingScrollPhysics(),
            children: [
              ProfilePage(),
              CalendarPage(),
            ],
          ),
          bottomNavigationBar: Material(
            color: Colors.white.withValues(alpha: 0.95),
            child: const TabBar(
              indicatorColor: ZenTheme.primaryColor,
              labelColor: ZenTheme.primaryColor,
              unselectedLabelColor: ZenTheme.textLightColor,
              tabs: [
                Tab(icon: Icon(Icons.person_outline), text: 'Profil'),
                Tab(icon: Icon(Icons.calendar_today_outlined), text: 'Calendrier'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
