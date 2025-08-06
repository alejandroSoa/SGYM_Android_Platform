import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../interfaces/bussiness/routine_interface.dart';
import '../services/RoutineService.dart';

class UserRoutinesScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const UserRoutinesScreen({super.key, this.onBack});

  @override
  State<UserRoutinesScreen> createState() => _UserRoutinesScreenState();
}

class _UserRoutinesScreenState extends State<UserRoutinesScreen> {
  List<Routine> userRoutines = [];
  bool isLoadingRoutines = false;
  String? routinesError;

  @override
  void initState() {
    super.initState();
    _loadUserRoutines();
  }

  Future<void> _loadUserRoutines() async {
    setState(() {
      isLoadingRoutines = true;
      routinesError = null;
    });

    try {
      final routinesList = await RoutineService.fetchRoutinesByUser(0);
      setState(() {
        userRoutines = routinesList ?? [];
        isLoadingRoutines = false;
      });
      print("Rutinas del usuario cargadas: ${userRoutines.length}");
      for (var routine in userRoutines) {
        print(
          "Rutina: ${routine.name} - Día: ${_convertDayToSpanish(routine.day)}",
        );
      }
    } catch (e) {
      setState(() {
        routinesError = e.toString();
        isLoadingRoutines = false;
      });
      print("Error al cargar rutinas del usuario: $e");
    }
  }

  // Convertir días del inglés al español para mostrar en la UI
  String _convertDayToSpanish(String englishDay) {
    switch (englishDay.toLowerCase()) {
      case 'monday':
        return 'Lunes';
      case 'tuesday':
        return 'Martes';
      case 'wednesday':
        return 'Miércoles';
      case 'thursday':
        return 'Jueves';
      case 'friday':
        return 'Viernes';
      case 'saturday':
        return 'Sábado';
      case 'sunday':
        return 'Domingo';
      default:
        return englishDay;
    }
  }

  Map<String, List<Routine>> _organizeRoutinesByDay() {
    Map<String, List<Routine>> organizedRoutines = {
      'Lunes': [],
      'Martes': [],
      'Miércoles': [],
      'Jueves': [],
      'Viernes': [],
      'Sábado': [],
      'Domingo': [],
    };

    for (final routine in userRoutines) {
      final spanishDay = _convertDayToSpanish(routine.day);
      if (organizedRoutines.containsKey(spanishDay)) {
        organizedRoutines[spanishDay]!.add(routine);
      }
    }

    return organizedRoutines;
  }

  Widget _buildRoutinesSection() {
    if (isLoadingRoutines) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
        ),
      );
    }

    if (routinesError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Error al cargar rutinas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              routinesError!,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserRoutines,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (userRoutines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No tienes rutinas asignadas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu entrenador te asignará rutinas pronto',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Vista organizada por día para usuarios
    final routinesByDay = _organizeRoutinesByDay();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: routinesByDay.entries.map((dayEntry) {
        final day = dayEntry.key;
        final dayRoutines = dayEntry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado del día
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: dayRoutines.isEmpty
                    ? Colors.grey[200]
                    : const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(12),
                boxShadow: dayRoutines.isNotEmpty
                    ? [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: dayRoutines.isEmpty ? Colors.grey[500] : Colors.white,
                ),
              ),
            ),

            // Rutinas del día
            if (dayRoutines.isNotEmpty) ...[
              ...dayRoutines.map(
                (routine) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      _showUserRoutineDetails(context, routine);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF6366F1,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.fitness_center,
                                  color: Color(0xFF6366F1),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  routine.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                          if (routine.description != null &&
                              routine.description!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              routine.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  'Sin rutinas para este día',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  void _showUserRoutineDetails(BuildContext context, Routine routine) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          color: Color(0xFF6366F1),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              routine.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _convertDayToSpanish(routine.day),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Descripción',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    routine.description ?? 'Sin descripción disponible',
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  // Botón para ver ejercicios
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showUserRoutineExercises(routine);
                      },
                      icon: const Icon(Icons.list_alt),
                      label: const Text('Ver Ejercicios'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showUserRoutineExercises(Routine routine) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Ejercicios de ${routine.name}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6366F1),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(child: _UserRoutineExercisesViewer(routine: routine)),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                    onPressed: widget.onBack ?? () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Mis Rutinas',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Para balancear el espacio
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildRoutinesSection(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget para mostrar los ejercicios de una rutina (solo lectura para usuarios)
class _UserRoutineExercisesViewer extends StatefulWidget {
  final Routine routine;

  const _UserRoutineExercisesViewer({Key? key, required this.routine})
    : super(key: key);

  @override
  _UserRoutineExercisesViewerState createState() =>
      _UserRoutineExercisesViewerState();
}

class _UserRoutineExercisesViewerState
    extends State<_UserRoutineExercisesViewer> {
  List<Map<String, dynamic>> routineExercises = [];
  bool isLoadingExercises = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRoutineExercises();
  }

  // Convertir tipos de equipamiento del inglés al español
  String _convertEquipmentToSpanish(String englishEquipment) {
    switch (englishEquipment.toLowerCase()) {
      case 'machine':
        return 'Máquina';
      case 'dumbbell':
        return 'Mancuernas';
      case 'other':
        return 'Otro';
      default:
        return englishEquipment;
    }
  }

  Future<void> _loadRoutineExercises() async {
    try {
      setState(() {
        isLoadingExercises = true;
        errorMessage = null;
      });

      final exercises = await RoutineService.fetchExercisesOfRoutine(
        widget.routine.id,
      );

      setState(() {
        routineExercises = exercises ?? [];
        isLoadingExercises = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar ejercicios: $e';
        isLoadingExercises = false;
      });
    }
  }

  // Abrir video de YouTube
  Future<void> _openYouTubeVideo(String videoUrl) async {
    try {
      final Uri url = Uri.parse(videoUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        print('No se puede abrir la URL: $videoUrl');
      }
    } catch (e) {
      print('Error al abrir video de YouTube: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingExercises) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRoutineExercises,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (routineExercises.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay ejercicios en esta rutina',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: routineExercises.length,
      itemBuilder: (context, index) {
        final exercise = routineExercises[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.fitness_center, color: Color(0xFF6366F1)),
            ),
            title: Text(
              exercise['name'] ?? 'Sin nombre',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  exercise['description'] ?? 'Sin descripción',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (exercise['equipmentType'] != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _convertEquipmentToSpanish(exercise['equipmentType']),
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            trailing:
                exercise['videoUrl'] != null &&
                    exercise['videoUrl'].toString().isNotEmpty
                ? Icon(Icons.play_arrow, color: Colors.red[600])
                : null,
            onTap:
                exercise['videoUrl'] != null &&
                    exercise['videoUrl'].toString().isNotEmpty
                ? () => _openYouTubeVideo(exercise['videoUrl'])
                : null,
          ),
        );
      },
    );
  }
}
