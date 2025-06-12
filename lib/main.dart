import 'package:flutter/material.dart';
import 'package:sgym/screens/diets_screen.dart';
import 'package:sgym/screens/home_screen.dart';
import 'package:sgym/screens/appointments_screen.dart';
import 'package:sgym/screens/routines_screen.dart';
import 'package:sgym/screens/profile_screen.dart';
import 'screens/notifications_screen.dart';
import 'widgets/custom_top_bar.dart';
import 'config/ScreenConfig.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainLayout(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainLayout extends StatefulWidget {
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentIndex = 0;

  final List<Screenconfig> viewConfigs = [
    Screenconfig(view: const HomeScreen()), 
    Screenconfig(view: const AppointmentsScreen(), title: 'Citas', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
    Screenconfig(view: const DietsScreen(), title: 'Dietas', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
    Screenconfig(view: const RoutinesScreen(), title: 'Rutinas', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
    Screenconfig(view: const ProfileScreen(), title: 'Perfil', showBackButton: true, showProfileIcon: false, showNotificationIcon: false, showBottomNav: false),
    Screenconfig(view: const NotificationsScreen(), title: 'Notificaciones', showBackButton: true, showProfileIcon: false, showNotificationIcon: false, showBottomNav: false),
  ];


  @override
  Widget build(BuildContext context) {
    final config = viewConfigs[currentIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomTopBar(
              username: 'Alejandro',
              profileImage: 'assets/profile.png',
              currentViewTitle: config.title,
              showBackButton: config.showBackButton,
              showProfileIcon: config.showProfileIcon,
              showNotificationIcon: config.showNotificationIcon,
              onBack: () => setState(() => currentIndex = 0),
              onProfileTap: () => setState(() => currentIndex = 4),
              onNotificationsTap: () => setState(() => currentIndex = 5),
            ),
            Expanded(child: config.view),
          ],
        ),
      ),
      bottomNavigationBar: config.showBottomNav
          ? Container(
              margin: const EdgeInsets.only(bottom: 25, left: 15, right: 15),
              height: 80,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavButton(index: 0, label: 'Inicio'),
                  _buildNavButton(index: 1, label: 'Citas'),
                  _buildNavButton(index: 2, label: 'Dietas'),
                  _buildNavButton(index: 3, label: 'Rutinas'),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildNavButton({required int index, required String label}) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => currentIndex = index),
      child: Container(
        height: 65,
        width: isSelected ? 150 : 65,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7C4DFF) : const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: isSelected
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 20, height: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(label, style: const TextStyle(color: Colors.white)),
                  ],
                )
              : Container(width: 16, height: 16, color: Colors.grey),
        ),
      ),
    );
  }
}

