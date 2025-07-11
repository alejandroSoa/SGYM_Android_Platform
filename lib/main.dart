import 'package:flutter/material.dart';
// import 'package:sgym/screens/diets_screen.dart';
// import 'package:sgym/screens/home_screen.dart';
// import 'package:sgym/screens/appointments_screen.dart';
// import 'package:sgym/screens/routines_screen.dart';
// import 'package:sgym/screens/profile_screen.dart';
// import 'screens/notifications_screen.dart';
import 'screens/first_time_screen.dart';
import 'widgets/custom_top_bar.dart';
import 'config/ScreenConfig.dart';
import 'services/InitializationService.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/AuthService.dart';
import 'services/RoleConfigService.dart';
import 'services/UserService.dart';
import 'services/ProfileService.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  //Agregar en resumen del dia congestion del gym, numero de notis/citas sin ver o nuevas
  //Agregar evento para cuando tenga firsttime pero no token 
    //Linea 276 home screen cambiar eso a un logout y solo quite el token
    //si tiene el token invalido actualizar en base a el servicio, mas no cerrarle o pedirle que vuelva a iniciar sesion
  //Agregar middleware conection para ajustar que en cada ruta mande token y verifique cada q realiza una peticion el status del token y actualizarlo si es necesario.
  WidgetsFlutterBinding.ensureInitialized();
  final isFirstTime = await InitializationService.isFirstTimeUser();
  runApp(MyApp(isFirstTime: isFirstTime));
}

class MyApp extends StatelessWidget {
  final bool isFirstTime;

  const MyApp({super.key, required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: isFirstTime 
          ? FirstTimeScreen(
              onComplete: () async {
                if (context.mounted) {
                  runApp(const MyApp(isFirstTime: false));
                }
              },
            )
          : const MainLayout(),
      debugShowCheckedModeBanner: false,
    );
  }
}



class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

// ...existing code...

class _MainLayoutState extends State<MainLayout> {
  int currentIndex = 0;
  List<Screenconfig> viewConfigs = [];
  List<Map<String, dynamic>> navItems = [];
  bool isLoading = true;
  String userProfileImage = 'assets/profile.png';
  String username = 'Usuario';

  @override
  void initState() {
    super.initState();
    _loadRoleBasedConfig();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      // Cargar datos de configuración y usuario en paralelo
      await Future.wait([
        _loadRoleBasedConfig(),
        _loadUserData(),
      ]);
    } catch (e) {
      print("[MAIN_LAYOUT] Error loading data: $e");
    } finally {
      // Solo marcar como cargado cuando ambos procesos terminen
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadRoleBasedConfig() async {
    try {
      final userRole = await AuthService.getCurrentUserRole();
      print("[MAIN_LAYOUT] User role: $userRole");
      
      if (userRole != null) {
        viewConfigs = RoleConfigService.getScreensForRole(userRole);
        navItems = RoleConfigService.getNavItemsForRole(userRole);
      } else {
        viewConfigs = RoleConfigService.getScreensForRole(0);
        navItems = RoleConfigService.getNavItemsForRole(0);
      }
      
      print("[MAIN_LAYOUT] NavItems: $navItems");
      print("[MAIN_LAYOUT] ViewConfigs length: ${viewConfigs.length}");
    } catch (e) {
      print("[MAIN_LAYOUT] Error loading role config: $e");
      // Configuración por defecto en caso de error
      viewConfigs = RoleConfigService.getScreensForRole(0);
      navItems = RoleConfigService.getNavItemsForRole(0);
    }
  }

  Future<void> _loadUserData() async {
    try {
      // Obtener perfil del usuario
      final profile = await ProfileService.fetchProfile();
      
      if (profile != null) {
          print("[PROFILE DATA]: ${profile.fullName}");
          print("[PROFILE DATA]: ${profile.photoUrl}");

          // Actualizar las variables sin setState aquí
          userProfileImage = profile.photoUrl ?? 'assets/profile.png';
          username = profile.fullName;
      }
    } catch (e) {
      print("[MAIN_LAYOUT] Error loading user data: $e");
      // Mantener valores por defecto en caso de error
      userProfileImage = 'assets/profile.png';
      username = 'Usuario';
    }
  }

  @override
Widget build(BuildContext context) {
  if (isLoading) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  if (viewConfigs.isEmpty) {
    return const Scaffold(
      body: Center(child: Text('Error: No se pudieron cargar las pantallas')),
    );
  }

  final config = viewConfigs[currentIndex];

  return Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Column(
        children: [
          // TopBar sin SizedBox wrapper
          CustomTopBar(
            username: username,
            profileImage: userProfileImage,
            currentViewTitle: config.title,
            showBackButton: config.showBackButton,
            showProfileIcon: config.showProfileIcon,
            showNotificationIcon: config.showNotificationIcon,
            onBack: () => setState(() => currentIndex = 0),
            onProfileTap: () => setState(() => currentIndex = viewConfigs.length - 2),
            onNotificationsTap: () => setState(() => currentIndex = viewConfigs.length - 1),
          ),
          // Contenido principal
          Expanded(
            child: config.view,
          ),
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
              children: navItems.map((item) => _buildNavButton(
                index: item['index'],
                label: item['label'],
                icon: item['icon'],
              )).toList(),
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

