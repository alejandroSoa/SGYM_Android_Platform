import 'package:flutter/material.dart';
import '../interfaces/exercises/exercise_interface.dart';
import '../interfaces/bussiness/routine_interface.dart';
import '../services/ExerciseService.dart';
import '../services/RoutineService.dart';

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
        print("Rutina: ${routine.name}");
      }
    } catch (e) {
      setState(() {
        routinesError = e.toString();
        isLoadingRoutines = false;
      });
      print("Error al cargar rutinas: $e");
    }
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
      // Vista simple para usuarios (igual que trainers pero sin botón de agregar)
      return Column(
        children: [
          // Lista de rutinas reales
          ...realRoutines.map(
            (routine) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8E5FF),
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
                      if (routine.description != null &&
                          routine.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
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
            ),
          ),
        ],
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
    bool isUpdating = false;
    String? errorMessage; // Variable para almacenar mensajes de error

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Editar Ejercicio',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del ejercicio',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) {
                        // Limpiar error cuando el usuario escriba
                        setDialogState(() {
                          errorMessage = null;
                        });
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
                      onChanged: (_) {
                        // Limpiar error cuando el usuario escriba
                        setDialogState(() {
                          errorMessage = null;
                        });
                      },
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
                          setDialogState(() {
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
                      onChanged: (_) {
                        // Limpiar error cuando el usuario escriba
                        setDialogState(() {
                          errorMessage = null;
                        });
                      },
                    ),

                    // Mostrar mensaje de error si existe
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red[700],
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isUpdating ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: isUpdating
                      ? null
                      : () async {
                          // Validar nombre - mínimo 3 caracteres
                          if (nameController.text.trim().isEmpty) {
                            setDialogState(() {
                              errorMessage = 'El nombre del ejercicio es obligatorio';
                            });
                            return;
                          }
                          
                          if (nameController.text.trim().length < 3) {
                            setDialogState(() {
                              errorMessage = 'El nombre debe tener al menos 3 caracteres';
                            });
                            return;
                          }

                          // Validar descripción - mínimo 5 caracteres
                          if (descriptionController.text.trim().isEmpty) {
                            setDialogState(() {
                              errorMessage = 'La descripción es obligatoria';
                            });
                            return;
                          }
                          
                          if (descriptionController.text.trim().length < 5) {
                            setDialogState(() {
                              errorMessage = 'La descripción debe tener al menos 5 caracteres';
                            });
                            return;
                          }

                          // Validar URL del video si no está vacía
                          final videoUrl = videoUrlController.text.trim();
                          if (videoUrl.isNotEmpty) {
                            final urlRegex = RegExp(
                              r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
                            );
                            if (!urlRegex.hasMatch(videoUrl)) {
                              setDialogState(() {
                                errorMessage = 'La URL del video no es válida';
                              });
                              return;
                            }
                          }

                          // Limpiar mensaje de error si todo está bien
                          setDialogState(() {
                            errorMessage = null;
                            isUpdating = true;
                          });

                          await _updateExercise(
                            id: exercise.id,
                            name: nameController.text.trim(),
                            description: descriptionController.text.trim(),
                            equipmentType: selectedEquipmentType,
                            videoUrl: videoUrl,
                          );

                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: isUpdating
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
                      : const Text('Actualizar'),
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
    EquipmentType selectedEquipmentType = EquipmentType.dumbbell;
    bool isCreating = false;
    String? errorMessage; // Variable para almacenar mensajes de error

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Agregar Ejercicio',
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
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del ejercicio',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) {
                        // Limpiar error cuando el usuario escriba
                        setDialogState(() {
                          errorMessage = null;
                        });
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
                      onChanged: (_) {
                        // Limpiar error cuando el usuario escriba
                        setDialogState(() {
                          errorMessage = null;
                        });
                      },
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
                          setDialogState(() {
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
                      onChanged: (_) {
                        // Limpiar error cuando el usuario escriba
                        setDialogState(() {
                          errorMessage = null;
                        });
                      },
                    ),

                    // Mostrar mensaje de error si existe
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red[700],
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isCreating ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: isCreating
                      ? null
                      : () async {
                          // Validar nombre - mínimo 3 caracteres
                          if (nameController.text.trim().isEmpty) {
                            setDialogState(() {
                              errorMessage = 'El nombre del ejercicio es obligatorio';
                            });
                            return;
                          }
                          
                          if (nameController.text.trim().length < 3) {
                            setDialogState(() {
                              errorMessage = 'El nombre debe tener al menos 3 caracteres';
                            });
                            return;
                          }

                          // Validar descripción - mínimo 5 caracteres
                          if (descriptionController.text.trim().isEmpty) {
                            setDialogState(() {
                              errorMessage = 'La descripción es obligatoria';
                            });
                            return;
                          }
                          
                          if (descriptionController.text.trim().length < 5) {
                            setDialogState(() {
                              errorMessage = 'La descripción debe tener al menos 5 caracteres';
                            });
                            return;
                          }

                          // Validar URL del video si no está vacía
                          final videoUrl = videoUrlController.text.trim();
                          if (videoUrl.isNotEmpty) {
                            final urlRegex = RegExp(
                              r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
                            );
                            if (!urlRegex.hasMatch(videoUrl)) {
                              setDialogState(() {
                                errorMessage = 'La URL del video no es válida';
                              });
                              return;
                            }
                          }

                          // Limpiar mensaje de error si todo está bien
                          setDialogState(() {
                            errorMessage = null;
                            isCreating = true;
                          });

                          await _createExercise(
                            name: nameController.text.trim(),
                            description: descriptionController.text.trim(),
                            equipmentType: selectedEquipmentType,
                            videoUrl: videoUrl,
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
    String? description,
  }) async {
    try {
      // Crear la rutina usando el servicio solo con name y description
      final newRoutine = await RoutineService.createRoutine(
        name: name,
        description: description,
      );

      if (newRoutine != null) {
        // Recargar las rutinas para mostrar la nueva
        await _loadRoutines();

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
    bool isUpdating = false;
    String? errorMessage; // Variable para almacenar mensajes de error

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Editar Rutina',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la rutina',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) {
                        // Limpiar error cuando el usuario escriba
                        setDialogState(() {
                          errorMessage = null;
                        });
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
                      onChanged: (_) {
                        // Limpiar error cuando el usuario escriba
                        setDialogState(() {
                          errorMessage = null;
                        });
                      },
                    ),

                    // Mostrar mensaje de error si existe
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red[700],
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isUpdating ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: isUpdating
                      ? null
                      : () async {
                          // Validar nombre - mínimo 3 caracteres
                          if (nameController.text.trim().isEmpty) {
                            setDialogState(() {
                              errorMessage = 'El nombre de la rutina es obligatorio';
                            });
                            return;
                          }
                          
                          if (nameController.text.trim().length < 3) {
                            setDialogState(() {
                              errorMessage = 'El nombre debe tener al menos 3 caracteres';
                            });
                            return;
                          }

                          // Validar descripción - mínimo 5 caracteres
                          if (descriptionController.text.trim().isEmpty) {
                            setDialogState(() {
                              errorMessage = 'La descripción es obligatoria';
                            });
                            return;
                          }
                          
                          if (descriptionController.text.trim().length < 5) {
                            setDialogState(() {
                              errorMessage = 'La descripción debe tener al menos 5 caracteres';
                            });
                            return;
                          }

                          // Limpiar mensaje de error si todo está bien
                          setDialogState(() {
                            errorMessage = null;
                            isUpdating = true;
                          });

                          await _updateRoutine(
                            id: routine.id,
                            name: nameController.text.trim(),
                            description: descriptionController.text.trim(),
                          );

                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: isUpdating
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
                      : const Text('Actualizar'),
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
    required String description,
  }) async {
    try {
      await RoutineService.updateRoutine(
        id: id,
        name: name,
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
      print('🗑️ Iniciando eliminación en cascada de rutina: $routineName (ID: $routineId)');
      
      // Paso 1: Obtener todos los ejercicios de la rutina
      print('📋 Paso 1: Obteniendo ejercicios de la rutina...');
      final routineExercises = await RoutineService.fetchRoutineExercisesStructured(routineId);
      
      if (routineExercises != null && routineExercises.isNotEmpty) {
        print('🔍 Encontrados ${routineExercises.length} ejercicios en la rutina');
        
        // Paso 2: Eliminar todos los ejercicios de la rutina
        print('🧹 Paso 2: Eliminando ejercicios de la rutina...');
        for (int i = 0; i < routineExercises.length; i++) {
          final routineExercise = routineExercises[i];
          print('   🗂️ Eliminando ejercicio ${i + 1}/${routineExercises.length}: ${routineExercise.exercise.name} (Routine Exercise ID: ${routineExercise.id})');
          
          try {
            final success = await RoutineService.removeExerciseFromRoutine(routineExercise.id);
            if (success) {
              print('   ✅ Ejercicio "${routineExercise.exercise.name}" eliminado exitosamente');
            } else {
              print('   ⚠️  Error al eliminar ejercicio "${routineExercise.exercise.name}" - servicio retornó false');
            }
          } catch (exerciseError) {
            print('   ❌ Error al eliminar ejercicio "${routineExercise.exercise.name}": $exerciseError');
            // Continuar con los otros ejercicios aunque uno falle
          }
        }
        print('🎯 Eliminación de ejercicios completada');
      } else {
        print('📝 La rutina no tiene ejercicios asignados');
      }
      
      // Paso 3: Eliminar la rutina
      print('🗑️ Paso 3: Eliminando la rutina...');
      await RoutineService.deleteRoutine(routineId);
      print('✅ Rutina eliminada exitosamente');
      
      // Paso 4: Recargar la lista
      print('🔄 Paso 4: Recargando lista de rutinas...');
      await _loadRoutines();
      print('✨ Proceso de eliminación completado exitosamente');

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
      print('❌ Error durante la eliminación en cascada de rutina: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar la rutina: $e'),
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
    bool isCreating = false;
    String? errorMessage; // Variable para almacenar mensajes de error

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                      onChanged: (_) {
                        // Limpiar error cuando el usuario escriba
                        setDialogState(() {
                          errorMessage = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo descripción
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                        hintText: 'Describe la rutina...',
                      ),
                      onChanged: (_) {
                        // Limpiar error cuando el usuario escriba
                        setDialogState(() {
                          errorMessage = null;
                        });
                      },
                    ),

                    // Mostrar mensaje de error si existe
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red[700],
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isCreating ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: isCreating
                      ? null
                      : () async {
                          // Validar nombre - mínimo 3 caracteres
                          if (nameController.text.trim().isEmpty) {
                            setDialogState(() {
                              errorMessage = 'El nombre de la rutina es obligatorio';
                            });
                            return;
                          }
                          
                          if (nameController.text.trim().length < 3) {
                            setDialogState(() {
                              errorMessage = 'El nombre debe tener al menos 3 caracteres';
                            });
                            return;
                          }

                          // Validar descripción - mínimo 5 caracteres
                          if (descriptionController.text.trim().isEmpty) {
                            setDialogState(() {
                              errorMessage = 'La descripción es obligatoria';
                            });
                            return;
                          }
                          
                          if (descriptionController.text.trim().length < 5) {
                            setDialogState(() {
                              errorMessage = 'La descripción debe tener al menos 5 caracteres';
                            });
                            return;
                          }

                          // Limpiar mensaje de error si todo está bien
                          setDialogState(() {
                            errorMessage = null;
                            isCreating = true;
                          });

                          await _createRoutine(
                            name: nameController.text.trim(),
                            description: descriptionController.text.trim(),
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
  List<RoutineExerciseResponse> routineExercises = [];
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

  // Método para cargar ejercicios de rutina con interfaz estructurada
  Future<void> _loadRoutineExercises() async {
    try {
      setState(() {
        isLoadingRoutineExercises = true;
        errorMessage = null;
      });

      print('🔍 Cargando ejercicios para rutina ID: ${widget.routine.id}');
      final exercises = await RoutineService.fetchRoutineExercisesStructured(
        widget.routine.id,
      );

      print('📦 Respuesta de fetchRoutineExercisesStructured:');
      print('   - Número de ejercicios: ${exercises?.length ?? 0}');

      if (exercises != null) {
        for (int i = 0; i < exercises.length; i++) {
          final exercise = exercises[i];
          print('   📝 Ejercicio $i:');
          print('      - ID: ${exercise.id}');
          print('      - Nombre: ${exercise.exercise.name}');
          print('      - Descripción: ${exercise.exercise.description}');
          print('      - Equipment Type: ${exercise.exercise.equipmentType}');
          print('      - Exercise ID: ${exercise.exerciseId}');
          print('      - Routine ID: ${exercise.routineId}');
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
      }
    } catch (e) {
      // Error handling sin SnackBar - solo logging si es necesario
      print('Error al agregar ejercicio a rutina: $e');
    }
  }

  Future<void> _removeExerciseFromRoutine(
    RoutineExerciseResponse routineExercise,
  ) async {
    try {
      final success = await RoutineService.removeExerciseFromRoutine(
        routineExercise.id,
      );

      if (success) {
        await _loadRoutineExercises();
      }
    } catch (e) {
      // Error handling sin SnackBar - solo logging si es necesario
      print('Error al eliminar ejercicio de rutina: $e');
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
        .map((re) => re.exerciseId)
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
                    print('🎯 Mostrando ejercicio $index: ${routineExercise.exercise.name}');

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(
                          Icons.fitness_center,
                          color: Color(0xFF6366F1),
                        ),
                        title: Text(
                          routineExercise.exercise.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          routineExercise.exercise.description,
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

  void _showRemoveExerciseConfirmation(RoutineExerciseResponse routineExercise) {
    final exerciseName = routineExercise.exercise.name;

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
