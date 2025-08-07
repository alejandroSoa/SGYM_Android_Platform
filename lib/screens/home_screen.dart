import 'package:flutter/material.dart';
import '../widgets/day_advice.dart';
import '../widgets/daily_activity.dart';
import '../services/RoutineService.dart';
import '../services/DietService.dart';
import '../services/AppointmentService.dart';
import '../services/GymStatusService.dart';
import '../services/SharedPreferencesService.dart';
import '../services/AuthService.dart';
import '../interfaces/bussiness/routine_interface.dart';
import '../interfaces/bussiness/appointment_interface.dart';
import '../main.dart';
import 'first_time_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Routine> userRoutines = [];
  bool isLoadingRoutines = false;
  String todayRoutineName = 'Sin rutina para hoy';
  List<Map<String, dynamic>> userDiets = [];
  bool isLoadingDiets = false;
  String todayDietName = 'Sin dieta para hoy';
  List<UserAppointment> userAppointments = [];
  bool isLoadingAppointments = false;
  String todayAppointmentText = 'Sin citas para hoy';
  String gymOccupancyText = 'Cargando ocupación...';
  bool isLoadingOccupancy = false;
  int? userRole;
  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserRoutines();
    _loadUserDiets();
    _loadUserAppointments();
    _loadGymOccupancy();
  }

  Future<void> _loadUserData() async {
    try {
      final roleId = await AuthService.getCurrentUserRole();
      setState(() {
        userRole = roleId;
        isLoadingUser = false;
      });
      print('=== DEBUG USER: Rol del usuario cargado: $userRole ===');
    } catch (e) {
      print('=== DEBUG USER: Error al cargar rol del usuario: $e ===');
      setState(() {
        isLoadingUser = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      // Mostrar diálogo de confirmación
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Cerrar Sesión'),
            content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
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
        // Limpiar datos de sesión
        await SharedPreferencesService.clearToken();
        await SharedPreferencesService.clearRefreshToken();
        
        // Navegar a FirstTimeScreen y limpiar el stack de navegación
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => FirstTimeScreen(
                onComplete: () {
                  // Esta función se ejecutará cuando el usuario complete el onboarding nuevamente
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const MainLayout()),
                  );
                },
              ),
            ),
            (Route<dynamic> route) => false,
          );
        }
      }
    } catch (e) {
      print('Error durante logout: $e');
      // Mostrar mensaje de error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cerrar sesión. Intenta nuevamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadUserRoutines() async {
    setState(() {
      isLoadingRoutines = true;
    });

    try {
      print('=== DEBUG RUTINAS: Iniciando carga de rutinas ===');
      final routines = await RoutineService.fetchUserRecentRoutines();
      print('=== DEBUG RUTINAS: Respuesta recibida ===');
      print('Rutinas recibidas: $routines');
      print('Tipo de respuesta: ${routines.runtimeType}');
      print('Cantidad de rutinas: ${routines?.length ?? 0}');

      setState(() {
        userRoutines = routines ?? [];
        isLoadingRoutines = false;
        _updateTodayRoutine();
      });
    } catch (e) {
      print('=== DEBUG RUTINAS: Error al cargar rutinas ===');
      print('Error completo: $e');
      print('Tipo de error: ${e.runtimeType}');
      setState(() {
        isLoadingRoutines = false;
        todayRoutineName = 'Error al cargar rutina';
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

  void _updateTodayRoutine() {
    print('=== DEBUG RUTINAS: Actualizando rutina del día ===');

    if (isLoadingRoutines) {
      print('Aún cargando rutinas...');
      setState(() {
        todayRoutineName = 'Cargando rutina...';
      });
      return;
    }

    final today = _getCurrentDayInEnglish();
    print('Día actual en inglés: $today');
    print('Total de rutinas disponibles: ${userRoutines.length}');

    // Mostrar todas las rutinas disponibles
    for (int i = 0; i < userRoutines.length; i++) {
      final routine = userRoutines[i];
      print('Rutina $i: ${routine.name} - Día: ${routine.day}');
    }

    final todayRoutine = userRoutines.where((routine) {
      final routineDay = routine.day.toLowerCase();
      print('Comparando: "$routineDay" == "$today"');
      return routineDay == today.toLowerCase();
    }).toList();

    print('Rutinas encontradas para hoy: ${todayRoutine.length}');

    setState(() {
      if (todayRoutine.isNotEmpty) {
        todayRoutineName = todayRoutine.first.name;
        print('Rutina seleccionada: $todayRoutineName');
      } else {
        todayRoutineName = 'Sin rutina para hoy';
        print('No se encontró rutina para el día: $today');
      }
    });
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
    final currentTime = '${today.hour.toString().padLeft(2, '0')}:${today.minute.toString().padLeft(2, '0')}';
    
    print('Fecha actual: $todayString');
    print('Hora actual: $currentTime');
    print('Total de citas disponibles: ${userAppointments.length}');

    // Mostrar todas las citas disponibles
    for (int i = 0; i < userAppointments.length; i++) {
      final appointment = userAppointments[i];
      print(
        'Cita $i: ID ${appointment.id} - Fecha: ${appointment.date} - Hora: ${appointment.startTime} - Tipo: ${appointment.type}',
      );
    }

    // Filtrar citas del día actual
    final todayAppointments = userAppointments.where((appointment) {
      final normalizedDate = _normalizeDate(appointment.date);
      print('Comparando fecha: "${appointment.date}" -> "$normalizedDate" == "$todayString"');
      return normalizedDate == todayString;
    }).toList();

    print('Citas encontradas para hoy: ${todayAppointments.length}');

    // Filtrar citas que aún no han pasado (hora >= hora actual)
    final upcomingAppointments = todayAppointments.where((appointment) {
      final appointmentTime = appointment.startTime.substring(0, 5); // "10:00:00" -> "10:00"
      final isUpcoming = appointmentTime.compareTo(currentTime) >= 0;
      print('Comparando hora: "$appointmentTime" >= "$currentTime" = $isUpcoming');
      return isUpcoming;
    }).toList();

    // Ordenar por hora para obtener la más próxima
    upcomingAppointments.sort((a, b) {
      final timeA = a.startTime.substring(0, 5);
      final timeB = b.startTime.substring(0, 5);
      return timeA.compareTo(timeB);
    });

    print('Citas próximas ordenadas: ${upcomingAppointments.length}');

    setState(() {
      if (upcomingAppointments.isNotEmpty) {
        final appointment = upcomingAppointments.first;
        // Formatear la hora para mostrar solo hora:minutos
        final startTime = appointment.startTime.substring(0, 5); // "10:00:00" -> "10:00"

        // Determinar el tipo de cita y mostrar información relevante
        final appointmentTypeText = appointment.type == 'trainer'
            ? 'Entrenador'
            : 'Nutriólogo';
        todayAppointmentText = 'Próxima cita con $appointmentTypeText a las $startTime';
        print(
          'Cita próxima seleccionada: $todayAppointmentText (Tipo: ${appointment.type})',
        );
      } else if (todayAppointments.isNotEmpty) {
        // Si hay citas del día pero todas ya pasaron
        todayAppointmentText = 'Todas las citas de hoy ya han pasado';
        print('Todas las citas del día ya han pasado');
      } else {
        todayAppointmentText = 'Sin citas para hoy';
        print('No se encontró cita para el día: $todayString');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
                  child: GestureDetector(
                    onTap: _logout,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
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

            // Mostrar DailyActivity solo si el usuario tiene rol = 5
            if (!isLoadingUser && userRole == 5) ...[
              DailyActivity(
                rutinaPrincipal: todayRoutineName,
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
            ],
          ],
        ),
      ),
    );
  }

  // Método auxiliar para normalizar fechas y manejar diferentes formatos
  String _normalizeDate(String dateString) {
    try {
      print('🔍 [HOME] Normalizando fecha: "$dateString"');
      
      // Si la fecha ya está en formato YYYY-MM-DD, devolverla tal como está
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateString)) {
        print('✅ [HOME] Fecha ya está en formato correcto: $dateString');
        return dateString;
      }

      // Si la fecha está en formato YYYY/MM/DD, convertir a YYYY-MM-DD
      if (RegExp(r'^\d{4}/\d{2}/\d{2}$').hasMatch(dateString)) {
        final normalized = dateString.replaceAll('/', '-');
        print('✅ [HOME] Fecha convertida de YYYY/MM/DD: $dateString -> $normalized');
        return normalized;
      }

      // Si la fecha está en formato ISO (2025-08-07T00:00:00.000Z), extraer solo la parte de la fecha
      if (dateString.contains('T')) {
        final normalized = dateString.split('T')[0];
        print('✅ [HOME] Fecha extraída de formato ISO: $dateString -> $normalized');
        return normalized;
      }

      // Si no coincide con ningún formato conocido, intentar parsear como DateTime
      final parsedDate = DateTime.parse(dateString);
      final normalized = '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}';
      print('✅ [HOME] Fecha parseada como DateTime: $dateString -> $normalized');
      return normalized;
    } catch (e) {
      print('❌ [HOME] Error normalizando fecha $dateString: $e');
      return dateString; // Devolver la fecha original si hay error
    }
  }
}
