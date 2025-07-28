import 'package:flutter/material.dart';
import '../interfaces/exercises/exercise_interface.dart';
import '../interfaces/bussiness/routine_interface.dart';
import '../services/ExerciseService.dart';
import '../services/RoutineService.dart';
import '../services/UserService.dart';
import '../services/NotificationService.dart';

class RoutinesScreen extends StatefulWidget {
  final bool showExerciseButton;
  final VoidCallback? onBack;

  const RoutinesScreen({
    super.key,
    this.showExerciseButton = false,
    this.onBack,
  });

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  // Lista de ejercicios desde la API
  List<Exercise> exercises = [];
  bool isLoadingExercises = false;
  String? exercisesError;

  // Lista de rutinas reales desde la API
  List<Routine> realRoutines = [];
  bool isLoadingRoutines = false;
  String? routinesError;

  // Lista de rutinas de ejemplo (para trainers que aún no usan API)
  List<String> routines = ['Rutina nombre', 'Rutina nombre', 'Rutina nombre'];

  @override
  void initState() {
    super.initState();
    if (widget.showExerciseButton) {
      _loadExercises();
    }
    // Cargar rutinas para todos los usuarios
    _loadRoutines();
  }

  Future<void> _loadExercises() async {
    setState(() {
      isLoadingExercises = true;
      exercisesError = null;
    });

    try {
      final exercisesList = await ExerciseService.getExercises();
      setState(() {
        exercises = exercisesList;
        isLoadingExercises = false;
      });
    } catch (e) {
      setState(() {
        exercisesError = e.toString();
        isLoadingExercises = false;
      });
    }
  }

  Future<void> _loadRoutines() async {
    setState(() {
      isLoadingRoutines = true;
      routinesError = null;
    });

    try {
      final routinesList = await RoutineService.fetchRoutines();
      setState(() {
        realRoutines = routinesList ?? [];
        isLoadingRoutines = false;
      });
      print("Rutinas cargadas: ${realRoutines.length}");
      for (var routine in realRoutines) {
        print(
          "Rutina: ${routine.name} - Día: ${_convertDayToSpanish(routine.day)}",
        );
      }
    } catch (e) {
      setState(() {
        routinesError = e.toString();
        isLoadingRoutines = false;
      });
      print("Error al cargar rutinas: $e");
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

    for (final routine in realRoutines) {
      // Convertir el día de inglés a español para la organización
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
            Text(
              'Error al cargar rutinas',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadRoutines,
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

    // Si es trainer, mostrar vista simple
    if (widget.showExerciseButton) {
      return Column(
        children: [
          // Sección "Agregar nueva rutina"
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Agregar nueva rutina',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white, size: 20),
                    onPressed: () {
                      _showAddRoutineDialog();
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Lista de rutinas reales
          ...realRoutines.map(
            (routine) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  _showRoutineDetails(context, routine);
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        routine.name,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Día: ${_convertDayToSpanish(routine.day)}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      if (routine.description != null &&
                          routine.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          routine.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // Vista para usuarios organizadas por día
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
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: dayRoutines.isEmpty ? Colors.grey[200] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: dayRoutines.isEmpty
                      ? null
                      : Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: dayRoutines.isEmpty
                        ? Colors.grey[500]
                        : Colors.black87,
                  ),
                ),
              ),

              // Rutinas del día
              if (dayRoutines.isNotEmpty) ...[
                ...dayRoutines.map((routine) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E5FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        _showRoutineDetails(context, routine);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              routine.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            if (routine.description != null &&
                                routine.description!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                routine.description!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],

              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      );
    }
  }

  Widget _buildExercisesContent() {
    if (isLoadingExercises) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
          ),
        ),
      );
    }

    if (exercisesError != null) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error al cargar ejercicios',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadExercises,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (exercises.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No hay ejercicios disponibles',
            style: TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SizedBox(
      height: 200, // Altura fija para la sección de ejercicios
      child: ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          return _buildExerciseItem(exercises[index]);
        },
      ),
    );
  }

  Widget _buildExerciseItem(Exercise exercise) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          _showExerciseDetails(context, exercise);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exercise.name,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                exercise.equipmentType.displayName,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteExercise(int exerciseId, String exerciseName) async {
    try {
      await ExerciseService.deleteExercise(exerciseId);
      await _loadExercises(); // Recargar la lista

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$exerciseName eliminado exitosamente'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmationDialog(Exercise exercise) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¿Estás seguro de que quieres eliminar este ejercicio?',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercise.equipmentType.displayName,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Esta acción no se puede deshacer.',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteExercise(exercise.id, exercise.name);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _showEditExerciseDialog(Exercise exercise) {
    final nameController = TextEditingController(text: exercise.name);
    final descriptionController = TextEditingController(
      text: exercise.description,
    );
    final videoUrlController = TextEditingController(text: exercise.videoUrl);
    EquipmentType selectedEquipmentType = exercise.equipmentType;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Editar Ejercicio'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del ejercicio',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<EquipmentType>(
                      value: selectedEquipmentType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de equipamiento',
                        border: OutlineInputBorder(),
                      ),
                      items: EquipmentType.values.map((type) {
                        return DropdownMenuItem<EquipmentType>(
                          value: type,
                          child: Text(type.displayName),
                        );
                      }).toList(),
                      onChanged: (EquipmentType? value) {
                        if (value != null) {
                          setState(() {
                            selectedEquipmentType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: videoUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL del video (opcional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty ||
                        descriptionController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Por favor completa los campos obligatorios',
                          ),
                          backgroundColor: Colors.orange,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    Navigator.pop(context);
                    await _updateExercise(
                      id: exercise.id,
                      name: nameController.text.trim(),
                      description: descriptionController.text.trim(),
                      equipmentType: selectedEquipmentType,
                      videoUrl: videoUrlController.text.trim(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Actualizar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateExercise({
    required int id,
    required String name,
    required String description,
    required EquipmentType equipmentType,
    required String videoUrl,
  }) async {
    try {
      await ExerciseService.updateExercise(
        id: id,
        name: name,
        description: description,
        equipmentType: equipmentType,
        videoUrl: videoUrl,
      );

      await _loadExercises(); // Recargar la lista

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ejercicio actualizado exitosamente'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _createExercise({
    required String name,
    required String description,
    required EquipmentType equipmentType,
    required String videoUrl,
  }) async {
    try {
      await ExerciseService.createExercise(
        name: name,
        description: description,
        equipmentType: equipmentType,
        videoUrl: videoUrl,
      );

      await _loadExercises(); // Recargar la lista

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ejercicio creado exitosamente'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAddExerciseDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final videoUrlController = TextEditingController();
    EquipmentType selectedEquipmentType = EquipmentType.other;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Agregar Ejercicio'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del ejercicio',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<EquipmentType>(
                      value: selectedEquipmentType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de equipamiento',
                        border: OutlineInputBorder(),
                      ),
                      items: EquipmentType.values.map((type) {
                        return DropdownMenuItem<EquipmentType>(
                          value: type,
                          child: Text(type.displayName),
                        );
                      }).toList(),
                      onChanged: (EquipmentType? value) {
                        if (value != null) {
                          setState(() {
                            selectedEquipmentType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: videoUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL del video (opcional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty ||
                        descriptionController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Por favor completa los campos obligatorios',
                          ),
                          backgroundColor: Colors.orange,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    Navigator.pop(context);
                    await _createExercise(
                      name: nameController.text.trim(),
                      description: descriptionController.text.trim(),
                      equipmentType: selectedEquipmentType,
                      videoUrl: videoUrlController.text.trim(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showExerciseDetails(BuildContext context, Exercise exercise) {
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
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    icon: Icons.fitness_center,
                    label: 'Equipamiento',
                    value: exercise.equipmentType.displayName,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Descripción',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exercise.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  // Botón de Editar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditExerciseDialog(exercise);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Editar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Botón de Eliminar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showDeleteConfirmationDialog(exercise);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Eliminar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con título y botón de regreso
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                    onPressed: widget.onBack ?? () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Rutinas',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 48,
                  ), // Para balancear el espacio del IconButton
                ],
              ),
              const SizedBox(height: 20),

              // Sección de Ejercicios (Solo para trainers - role_id = 3)
              if (widget.showExerciseButton) ...[
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E5FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ejercicios',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.add, color: Colors.black),
                              onPressed: () {
                                _showAddExerciseDialog();
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildExercisesContent(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Sección de rutinas
              _buildRoutinesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createRoutine({
    required String name,
    required String day,
    String? description,
    required int userId, // Ahora recibe el userId como parámetro
  }) async {
    try {
      // Crear la rutina usando el servicio con el userId seleccionado
      final newRoutine = await RoutineService.createRoutine(
        name: name,
        day: day,
        description: description,
        userId: userId,
      );

      if (newRoutine != null) {
        // Recargar las rutinas para mostrar la nueva
        await _loadRoutines();

        // Enviar notificación al usuario
        try {
          await NotificationService.sendRoutineAssignedNotification(
            userId: userId,
          );
          print('Notificación de rutina enviada al usuario $userId');
        } catch (notificationError) {
          print('Error al enviar notificación: $notificationError');
          // No mostrar error al usuario, solo loggearlo
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rutina "$name" creada exitosamente'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al crear la rutina'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Error al crear rutina: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear la rutina: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Convertir días del español al inglés para la API
  String _convertDayToEnglish(String spanishDay) {
    switch (spanishDay) {
      case 'Lunes':
        return 'monday';
      case 'Martes':
        return 'tuesday';
      case 'Miércoles':
        return 'wednesday';
      case 'Jueves':
        return 'thursday';
      case 'Viernes':
        return 'friday';
      case 'Sábado':
        return 'saturday';
      case 'Domingo':
        return 'sunday';
      default:
        return spanishDay.toLowerCase();
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

  void _showRoutineDetails(BuildContext context, Routine routine) {
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
                  Text(
                    routine.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    icon: Icons.calendar_today,
                    label: 'Día',
                    value: _convertDayToSpanish(routine.day),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Descripción',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    routine.description ?? 'Sin descripción',
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  // Botón de Gestionar Ejercicios
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showManageExercisesDialog(routine);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Gestionar Ejercicios',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Botón de Editar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditRoutineDialog(routine);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Editar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Botón de Eliminar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showDeleteRoutineConfirmationDialog(routine);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Eliminar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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

  void _showEditRoutineDialog(Routine routine) {
    final nameController = TextEditingController(text: routine.name);
    final descriptionController = TextEditingController(
      text: routine.description,
    );
    String selectedDay = _convertDayToSpanish(routine.day);

    final List<String> days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Editar Rutina'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la rutina',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedDay,
                      decoration: const InputDecoration(
                        labelText: 'Día de la semana',
                        border: OutlineInputBorder(),
                      ),
                      items: days.map((day) {
                        return DropdownMenuItem<String>(
                          value: day,
                          child: Text(day),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            selectedDay = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Por favor completa los campos obligatorios',
                          ),
                          backgroundColor: Colors.orange,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    Navigator.pop(context);
                    await _updateRoutine(
                      id: routine.id,
                      name: nameController.text.trim(),
                      day: _convertDayToEnglish(selectedDay),
                      description: descriptionController.text.trim(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Actualizar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateRoutine({
    required int id,
    required String name,
    required String day,
    required String description,
  }) async {
    try {
      await RoutineService.updateRoutine(
        id: id,
        name: name,
        day: day,
        description: description,
      );

      await _loadRoutines(); // Recargar la lista

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rutina actualizada exitosamente'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showDeleteRoutineConfirmationDialog(Routine routine) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('¿Estás seguro de que quieres eliminar esta rutina?'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routine.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Día: ${_convertDayToSpanish(routine.day)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Esta acción no se puede deshacer.',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteRoutine(routine.id, routine.name);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteRoutine(int routineId, String routineName) async {
    try {
      await RoutineService.deleteRoutine(routineId);
      await _loadRoutines(); // Recargar la lista

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$routineName eliminada exitosamente'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showManageExercisesDialog(Routine routine) {
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
                Expanded(child: _RoutineExercisesManager(routine: routine)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddRoutineDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedDay = 'Lunes';
    bool isCreating = false;
    bool isLoadingUsers = true;
    List<Map<String, dynamic>> availableUsers = [];
    Map<String, dynamic>? selectedUser;

    final List<String> days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Cargar usuarios al abrir el diálogo
            if (isLoadingUsers) {
              UserService.getUsersByRole(5)
                  .then((users) {
                    print('Usuarios cargados: ${users?.length ?? 0}');
                    if (users != null) {
                      for (var user in users) {
                        print(
                          'Usuario: ${user['name']} - ${user['email']} - ID: ${user['id']}',
                        );
                      }
                    }
                    setDialogState(() {
                      isLoadingUsers = false;
                      if (users != null && users.isNotEmpty) {
                        availableUsers = users;
                        selectedUser = users.first;
                      }
                    });
                  })
                  .catchError((error) {
                    setDialogState(() {
                      isLoadingUsers = false;
                    });
                    print('Error loading users: $error');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al cargar usuarios: $error'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  });
            }

            return AlertDialog(
              title: const Text(
                'Nueva Rutina',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6366F1),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campo nombre
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la rutina',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.fitness_center),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Selector de día
                    const Text(
                      'Día de la semana:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedDay,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      items: days.map((day) {
                        return DropdownMenuItem(value: day, child: Text(day));
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedDay = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Selector de usuario
                    const Text(
                      'Asignar a usuario:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isLoadingUsers)
                      Container(
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Cargando usuarios...'),
                            ],
                          ),
                        ),
                      )
                    else if (availableUsers.isEmpty)
                      Container(
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Center(
                          child: Text(
                            'No hay usuarios disponibles',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      )
                    else
                      DropdownButtonFormField<Map<String, dynamic>>(
                        value: selectedUser,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        items: availableUsers.map((user) {
                          // Crear un texto más descriptivo para mostrar
                          String displayText = '';
                          if (user['name'] != null &&
                              user['name'].toString().isNotEmpty) {
                            displayText = user['name'];
                            if (user['email'] != null) {
                              displayText += ' (${user['email']})';
                            }
                          } else if (user['email'] != null) {
                            displayText = user['email'];
                          } else {
                            displayText = 'Usuario ID: ${user['id']}';
                          }

                          return DropdownMenuItem(
                            value: user,
                            child: Text(
                              displayText,
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedUser = value;
                          });
                        },
                      ),
                    const SizedBox(height: 16),

                    // Campo descripción (opcional)
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Descripción (opcional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                        hintText: 'Describe la rutina...',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isCreating ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed:
                      isCreating || isLoadingUsers || selectedUser == null
                      ? null
                      : () async {
                          if (nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'El nombre de la rutina es obligatorio',
                                ),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            isCreating = true;
                          });

                          await _createRoutine(
                            name: nameController.text.trim(),
                            day: _convertDayToEnglish(selectedDay),
                            description:
                                descriptionController.text.trim().isEmpty
                                ? null
                                : descriptionController.text.trim(),
                            userId: selectedUser!['id'] as int,
                          );

                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                  ),
                  child: isCreating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _RoutineExercisesManager extends StatefulWidget {
  final Routine routine;

  const _RoutineExercisesManager({Key? key, required this.routine})
    : super(key: key);

  @override
  _RoutineExercisesManagerState createState() =>
      _RoutineExercisesManagerState();
}

class _RoutineExercisesManagerState extends State<_RoutineExercisesManager> {
  List<Map<String, dynamic>> routineExercises = [];
  List<Exercise> allExercises = [];
  bool isLoadingRoutineExercises = true;
  bool isLoadingAllExercises = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAllExercises().then((_) {
      _loadRoutineExercises();
    });
  }

  // Método para enriquecer los datos de rutina con información completa del ejercicio
  Future<void> _loadRoutineExercises() async {
    try {
      setState(() {
        isLoadingRoutineExercises = true;
        errorMessage = null;
      });

      print('🔍 Cargando ejercicios para rutina ID: ${widget.routine.id}');
      final exercises = await RoutineService.fetchExercisesOfRoutine(
        widget.routine.id,
      );

      print('📦 Respuesta de fetchExercisesOfRoutine:');
      print('   - Número de ejercicios: ${exercises?.length ?? 0}');
      print('   - Datos completos: $exercises');

      if (exercises != null) {
        for (int i = 0; i < exercises.length; i++) {
          final exercise = exercises[i];
          print('   📝 Ejercicio $i:');
          print('      - ID: ${exercise['id']}');
          print('      - Nombre: ${exercise['name'] ?? 'N/A'}');
          print('      - Descripción: ${exercise['description'] ?? 'N/A'}');
          print(
            '      - Equipment Type: ${exercise['equipment_type'] ?? 'N/A'}',
          );
          print('      - Exercise ID: ${exercise['exercise_id'] ?? 'N/A'}');
          print('      - Routine ID: ${exercise['routine_id'] ?? 'N/A'}');
          print('      - Datos completos del ejercicio: $exercise');
        }
      }

      setState(() {
        routineExercises = exercises ?? [];
        isLoadingRoutineExercises = false;
      });
    } catch (e) {
      print('❌ Error en _loadRoutineExercises: $e');
      setState(() {
        errorMessage = 'Error al cargar ejercicios de la rutina: $e';
        isLoadingRoutineExercises = false;
      });
    }
  }

  Future<void> _loadAllExercises() async {
    try {
      setState(() {
        isLoadingAllExercises = true;
      });

      final exercises = await ExerciseService.getExercises();
      setState(() {
        allExercises = exercises;
        isLoadingAllExercises = false;
      });
    } catch (e) {
      setState(() {
        isLoadingAllExercises = false;
      });
    }
  }

  Future<void> _assignExerciseToRoutine(Exercise exercise) async {
    try {
      final routineExercise = await RoutineService.assignExerciseToRoutine(
        routineId: widget.routine.id,
        exerciseId: exercise.id,
      );

      if (routineExercise != null) {
        await _loadRoutineExercises();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Ejercicio "${exercise.name}" agregado a la rutina',
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al agregar el ejercicio'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _removeExerciseFromRoutine(
    Map<String, dynamic> routineExercise,
  ) async {
    try {
      final success = await RoutineService.removeExerciseFromRoutine(
        routineExercise['id'] as int,
      );

      if (success) {
        await _loadRoutineExercises();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Ejercicio "${routineExercise['exercise']?['name'] ?? 'Ejercicio'}" eliminado de la rutina',
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al eliminar el ejercicio'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAddExerciseDialog() {
    if (allExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay ejercicios disponibles'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Filtrar ejercicios que ya están en la rutina
    final assignedExerciseIds = routineExercises
        .map((re) => re['exercise_id'] as int?)
        .where((id) => id != null)
        .cast<int>()
        .toList();

    print('🔍 IDs de ejercicios ya asignados: $assignedExerciseIds');

    final availableExercises = allExercises
        .where((exercise) => !assignedExerciseIds.contains(exercise.id))
        .toList();

    if (availableExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Todos los ejercicios ya están asignados a esta rutina',
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Ejercicio'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: availableExercises.length,
              itemBuilder: (context, index) {
                final exercise = availableExercises[index];
                return Card(
                  child: ListTile(
                    title: Text(exercise.name),
                    subtitle: Text(exercise.equipmentType.displayName),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _assignExerciseToRoutine(exercise);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Agregar'),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ejercicios asignados',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            ElevatedButton.icon(
              onPressed: isLoadingAllExercises ? null : _showAddExerciseDialog,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Agregar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.error, color: Colors.red[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        Expanded(
          child: isLoadingRoutineExercises
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF6366F1),
                    ),
                  ),
                )
              : routineExercises.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fitness_center, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No hay ejercicios asignados',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Presiona "Agregar" para asignar ejercicios',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: routineExercises.length,
                  itemBuilder: (context, index) {
                    final routineExercise = routineExercises[index];

                    // Mostrar datos directos del API
                    print('🎯 Mostrando ejercicio $index: $routineExercise');

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(
                          Icons.fitness_center,
                          color: Color(0xFF6366F1),
                        ),
                        title: Text(
                          routineExercise['name'] ?? 'Sin nombre',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          routineExercise['description'] ?? 'Sin descripción',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          onPressed: () {
                            _showRemoveExerciseConfirmation(routineExercise);
                          },
                          icon: const Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showRemoveExerciseConfirmation(Map<String, dynamic> routineExercise) {
    final exerciseName = routineExercise['name'] ?? 'Ejercicio';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text(
            '¿Estás seguro de que quieres quitar "$exerciseName" de esta rutina?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _removeExerciseFromRoutine(routineExercise);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Quitar'),
            ),
          ],
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6366F1)),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
      ],
    );
  }
}
