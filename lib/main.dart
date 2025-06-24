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
                  _buildNavButton(index: 0, label: 'Inicio', icon: Icons.home),
                  _buildNavButton(index: 1, label: 'Citas', icon: Icons.calendar_today),
                  _buildNavButton(index: 2, label: 'Dietas', icon: Icons.restaurant),
                  _buildNavButton(index: 3, label: 'Rutinas', icon: Icons.fitness_center),
                ],
              ),
            )
          : null,
    );
  }
  Widget _buildNavButton({required int index, required String label, IconData? icon}) {
    final isSelected = currentIndex == index;
    double screenWidth = MediaQuery.of(context).size.width;
    double selectedWidth = screenWidth * 0.36; 
    double unselectedWidth = screenWidth * 0.16;

    return GestureDetector(
      onTap: () => setState(() => currentIndex = index),
      child: Container(
        height: 65,
        width: isSelected ? selectedWidth : unselectedWidth, 
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7C4DFF) : const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: isSelected
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon ?? Icons.circle,
                      size: 25,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(label, style: const TextStyle(color: Colors.white)),
                  ],
                )
              : Icon(
                  icon ?? Icons.circle,
                  size: 16,
                  color: Colors.grey,
                ),
        ),
      ),
    );
  }
}

