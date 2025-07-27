import 'package:flutter/material.dart';
import '../widgets/day_advice.dart';
import '../widgets/daily_activity.dart';
import '../services/RoutineService.dart';
import '../interfaces/bussiness/routine_interface.dart';
import '../main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Routine> userRoutines = [];
  bool isLoadingRoutines = false;

  @override
  void initState() {
    super.initState();
    _loadUserRoutines();
  }

  Future<void> _loadUserRoutines() async {
    setState(() {
      isLoadingRoutines = true;
    });

    try {
      final routines = await RoutineService.fetchUserRecentRoutines();
      setState(() {
        userRoutines = routines ?? [];
        isLoadingRoutines = false;
      });
    } catch (e) {
      print('Error al cargar rutinas del usuario: $e');
      setState(() {
        isLoadingRoutines = false;
      });
    }
  }

  List<String> _getRoutineNames() {
    if (isLoadingRoutines) {
      return ['Cargando rutinas...', '', '', '', ''];
    }

    if (userRoutines.isEmpty) {
      return ['Sin rutinas creadas', '', '', '', ''];
    }

    List<String> routineNames = userRoutines
        .map((routine) => routine.name)
        .toList();

    // Completar con strings vacíos hasta tener 5 elementos
    while (routineNames.length < 5) {
      routineNames.add('');
    }

    // Tomar solo los primeros 5
    return routineNames.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/gym.png',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Text(
                  'Resumen Diario',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: CircleAvatar(backgroundColor: Colors.white, radius: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DayAdvice(
            color: Color.fromARGB(255, 122, 90, 249),
            frase: 'Si la vida te da limones, haz limonada 4K',
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              final mainLayoutState = context
                  .findAncestorStateOfType<State<MainLayout>>();
              if (mainLayoutState != null) {
                (mainLayoutState as dynamic).setState(() {
                  (mainLayoutState as dynamic).currentIndex = 4;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFF2F2FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.qr_code_2_rounded,
                    size: 36,
                    color: Color(0xFF7A5AF9),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Acceso rápido: QR para entrar al gimnasio',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF413477),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          DailyActivity(
            ejercicios: _getRoutineNames(),
            totalEjercicios: userRoutines.length,
            dietaPrincipal: 'Ensalada con proteína',
            citaPrincipal: 'Consulta coach a las 4:00 PM',
            onRutinaTap: () {
              final mainLayoutState = context
                  .findAncestorStateOfType<State<MainLayout>>();
              if (mainLayoutState != null) {
                (mainLayoutState as dynamic).setState(() {
                  (mainLayoutState as dynamic).currentIndex =
                      3; // Pestaña de Rutinas
                });
              }
            },
            onDietaTap: () {
              final mainLayoutState = context
                  .findAncestorStateOfType<State<MainLayout>>();
              if (mainLayoutState != null) {
                (mainLayoutState as dynamic).setState(() {
                  (mainLayoutState as dynamic).currentIndex =
                      2; // Pestaña de Dietas
                });
              }
            },
            onCitasTap: () {
              final mainLayoutState = context
                  .findAncestorStateOfType<State<MainLayout>>();
              if (mainLayoutState != null) {
                (mainLayoutState as dynamic).setState(() {
                  (mainLayoutState as dynamic).currentIndex =
                      1; // Pestaña de Citas
                });
              }
            },
          ),
          const SizedBox(height: 12),

          // Botón de logout/borrar datos de usuario
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('first-init-app');

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Datos del usuario borrados (Logout simulado)',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
