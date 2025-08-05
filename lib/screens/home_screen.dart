import 'package:flutter/material.dart';
import '../widgets/day_advice.dart';
import '../widgets/daily_activity.dart';
import '../services/RoutineService.dart';
import '../services/DietService.dart';
import '../services/AppointmentService.dart';
import '../services/GymStatusService.dart';
import '../interfaces/bussiness/routine_interface.dart';
import '../interfaces/bussiness/appointment_interface.dart';
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
  List<Map<String, dynamic>> userDiets = [];
  bool isLoadingDiets = false;
  String todayDietName = 'Sin dieta para hoy';
  List<UserAppointment> userAppointments = [];
  bool isLoadingAppointments = false;
  String todayAppointmentText = 'Sin citas para hoy';
  String gymOccupancyText = 'Cargando ocupación...';
  bool isLoadingOccupancy = false;

  @override
  void initState() {
    super.initState();
    _loadUserRoutines();
    _loadUserDiets();
    _loadUserAppointments();
    _loadGymOccupancy();
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

  Future<void> _loadUserDiets() async {
    setState(() {
      isLoadingDiets = true;
    });

    try {
      print('=== DEBUG DIETAS: Iniciando carga de dietas ===');
      final diets = await DietService.fetchDiets();
      print('=== DEBUG DIETAS: Respuesta recibida ===');
      print('Dietas recibidas: $diets');
      print('Tipo de respuesta: ${diets.runtimeType}');
      print('Cantidad de dietas: ${diets?.length ?? 0}');

      setState(() {
        userDiets = diets ?? [];
        isLoadingDiets = false;
        _updateTodayDiet();
      });
    } catch (e) {
      print('=== DEBUG DIETAS: Error al cargar dietas ===');
      print('Error completo: $e');
      print('Tipo de error: ${e.runtimeType}');
      setState(() {
        isLoadingDiets = false;
        todayDietName = 'Error al cargar dieta';
      });
    }
  }

  Future<void> _loadUserAppointments() async {
    setState(() {
      isLoadingAppointments = true;
    });

    try {
      print('=== DEBUG CITAS: Iniciando carga de citas ===');
      final appointments = await AppointmentService.fetchUserAppointments();
      print('=== DEBUG CITAS: Respuesta recibida ===');
      print('Citas recibidas: $appointments');
      print('Tipo de respuesta: ${appointments.runtimeType}');
      print('Cantidad de citas: ${appointments?.length ?? 0}');

      setState(() {
        userAppointments = appointments ?? [];
        isLoadingAppointments = false;
        _updateTodayAppointment();
      });
    } catch (e) {
      print('=== DEBUG CITAS: Error al cargar citas ===');
      print('Error completo: $e');
      print('Tipo de error: ${e.runtimeType}');
      setState(() {
        isLoadingAppointments = false;
        todayAppointmentText = 'Error al cargar citas';
      });
    }
  }

  Future<void> _loadGymOccupancy() async {
    setState(() {
      isLoadingOccupancy = true;
    });

    try {
      print(
        '=== DEBUG OCUPACIÓN: Iniciando carga de ocupación del gimnasio ===',
      );

      // Obtener solo los registros del día actual
      final today = DateTime.now();
      final todayString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final occupancyRecords = await GymStatusService.fetchOccupancyRecords(
        startDate: todayString,
        endDate: todayString,
      );

      print('=== DEBUG OCUPACIÓN: Respuesta recibida ===');
      print('Registros recibidos: $occupancyRecords');
      print('Cantidad de registros: ${occupancyRecords?.length ?? 0}');

      setState(() {
        isLoadingOccupancy = false;
        if (occupancyRecords != null && occupancyRecords.isNotEmpty) {
          // Tomar el registro más reciente del día
          final latestRecord = occupancyRecords.last;
          final level = latestRecord['level'] ?? 'unknown';
          final peopleCount = latestRecord['people_count'] ?? 0;

          // Formatear el texto según el nivel de ocupación
          switch (level.toLowerCase()) {
            case 'low':
              gymOccupancyText = 'Ocupación baja • $peopleCount personas';
              break;
            case 'medium':
              gymOccupancyText = 'Ocupación media • $peopleCount personas';
              break;
            case 'high':
              gymOccupancyText = 'Ocupación alta • $peopleCount personas';
              break;
            default:
              gymOccupancyText = 'Ocupación: $peopleCount personas';
          }
          print('Texto de ocupación: $gymOccupancyText');
        } else {
          gymOccupancyText = 'Sin datos de ocupación hoy';
          print('No se encontraron datos de ocupación para hoy');
        }
      });
    } catch (e) {
      print('=== DEBUG OCUPACIÓN: Error al cargar ocupación ===');
      print('Error completo: $e');
      print('Tipo de error: ${e.runtimeType}');

      setState(() {
        isLoadingOccupancy = false;
        // Como la API aún no está disponible, mostramos un mensaje amigable
        gymOccupancyText = 'Ocupación no disponible';
      });
    }
  }

  String _getCurrentDayInEnglish() {
    final now = DateTime.now();
    final weekdays = [
      'monday', // 1
      'tuesday', // 2
      'wednesday', // 3
      'thursday', // 4
      'friday', // 5
      'saturday', // 6
      'sunday', // 7
    ];
    return weekdays[now.weekday - 1];
  }

  void _updateTodayDiet() {
    print('=== DEBUG DIETAS: Actualizando dieta del día ===');

    if (isLoadingDiets) {
      print('Aún cargando dietas...');
      setState(() {
        todayDietName = 'Cargando dieta...';
      });
      return;
    }

    final today = _getCurrentDayInEnglish();
    print('Día actual en inglés: $today');
    print('Total de dietas disponibles: ${userDiets.length}');

    // Mostrar todas las dietas disponibles
    for (int i = 0; i < userDiets.length; i++) {
      final diet = userDiets[i];
      print('Dieta $i: ${diet['name']} - Día: ${diet['day']}');
    }

    final todayDiet = userDiets.where((diet) {
      final dietDay = diet['day']?.toString().toLowerCase();
      print('Comparando: "$dietDay" == "$today"');
      return dietDay == today.toLowerCase();
    }).toList();

    print('Dietas encontradas para hoy: ${todayDiet.length}');

    setState(() {
      if (todayDiet.isNotEmpty) {
        todayDietName = todayDiet.first['name'] ?? 'Dieta sin nombre';
        print('Dieta seleccionada: $todayDietName');
      } else {
        todayDietName = 'Sin dieta para hoy';
        print('No se encontró dieta para el día: $today');
      }
    });
  }

  void _updateTodayAppointment() {
    print('=== DEBUG CITAS: Actualizando cita del día ===');

    if (isLoadingAppointments) {
      print('Aún cargando citas...');
      setState(() {
        todayAppointmentText = 'Cargando citas...';
      });
      return;
    }

    final today = DateTime.now();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    print('Fecha actual: $todayString');
    print('Total de citas disponibles: ${userAppointments.length}');

    // Mostrar todas las citas disponibles
    for (int i = 0; i < userAppointments.length; i++) {
      final appointment = userAppointments[i];
      print(
        'Cita $i: ID ${appointment.id} - Fecha: ${appointment.date} - Hora: ${appointment.startTime} - Tipo: ${appointment.type}',
      );
    }

    final todayAppointments = userAppointments.where((appointment) {
      print('Comparando: "${appointment.date}" == "$todayString"');
      return appointment.date == todayString;
    }).toList();

    print('Citas encontradas para hoy: ${todayAppointments.length}');

    setState(() {
      if (todayAppointments.isNotEmpty) {
        final appointment = todayAppointments.first;
        // Formatear la hora para mostrar solo hora:minutos
        final startTime = appointment.startTime.substring(
          0,
          5,
        ); // "10:00:00" -> "10:00"

        // Determinar el tipo de cita y mostrar información relevante
        final appointmentTypeText = appointment.type == 'trainer'
            ? 'Entrenador'
            : 'Nutriólogo';
        todayAppointmentText = 'Cita con $appointmentTypeText a las $startTime';
        print(
          'Cita seleccionada: $todayAppointmentText (Tipo: ${appointment.type})',
        );
      } else {
        todayAppointmentText = 'Sin citas para hoy';
        print('No se encontró cita para el día: $todayString');
      }
    });
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
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          gymOccupancyText,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
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
            dietaPrincipal: todayDietName,
            citaPrincipal: todayAppointmentText,
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
                // Mostrar diálogo de confirmación
                bool? shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Cerrar Sesión'),
                      content: const Text(
                        '¿Estás seguro de que deseas cerrar sesión?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Cerrar Sesión'),
                        ),
                      ],
                    );
                  },
                );

                if (shouldLogout == true) {
                  // Borrar datos del usuario
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('first-init-app');

                  // Mostrar mensaje de éxito
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sesión cerrada exitosamente'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 1),
                      ),
                    );

                    // Esperar un momento y reiniciar la aplicación
                    await Future.delayed(const Duration(seconds: 1));

                    if (context.mounted) {
                      // Reiniciar la aplicación navegando al FirstTimeScreen
                      runApp(const MyApp(isFirstTime: true));
                    }
                  }
                }
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
