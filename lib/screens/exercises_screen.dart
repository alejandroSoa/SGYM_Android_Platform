import 'package:flutter/material.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  String selectedCategory = 'Todos';
  final List<String> categories = [
    'Todos',
    'Pecho',
    'Espalda',
    'Piernas',
    'Hombros',
    'Brazos',
    'Abdomen',
    'Cardio',
  ];

  // Datos de ejemplo para los ejercicios
  final List<Map<String, dynamic>> exercisesList = [
    {
      'name': 'Press de Banca',
      'category': 'Pecho',
      'difficulty': 'Intermedio',
      'duration': '3 series x 12 reps',
      'equipment': 'Barra',
      'description':
          'Ejercicio fundamental para desarrollar el pecho, hombros y tríceps.',
    },
    {
      'name': 'Sentadillas',
      'category': 'Piernas',
      'difficulty': 'Principiante',
      'duration': '3 series x 15 reps',
      'equipment': 'Peso corporal',
      'description':
          'Ejercicio básico para fortalecer cuádriceps, glúteos y pantorrillas.',
    },
    {
      'name': 'Dominadas',
      'category': 'Espalda',
      'difficulty': 'Avanzado',
      'duration': '3 series x 8 reps',
      'equipment': 'Barra de dominadas',
      'description':
          'Excelente ejercicio para desarrollar la espalda y los bíceps.',
    },
    {
      'name': 'Press Militar',
      'category': 'Hombros',
      'difficulty': 'Intermedio',
      'duration': '3 series x 10 reps',
      'equipment': 'Mancuernas',
      'description':
          'Ejercicio para fortalecer los hombros y mejorar la estabilidad del core.',
    },
    {
      'name': 'Flexiones',
      'category': 'Pecho',
      'difficulty': 'Principiante',
      'duration': '3 series x 12 reps',
      'equipment': 'Peso corporal',
      'description':
          'Ejercicio clásico para pecho, hombros y tríceps usando el peso corporal.',
    },
    {
      'name': 'Curl de Bíceps',
      'category': 'Brazos',
      'difficulty': 'Principiante',
      'duration': '3 series x 12 reps',
      'equipment': 'Mancuernas',
      'description':
          'Ejercicio aislado para el desarrollo de los músculos bíceps.',
    },
    {
      'name': 'Plancha',
      'category': 'Abdomen',
      'difficulty': 'Principiante',
      'duration': '3 series x 30 seg',
      'equipment': 'Peso corporal',
      'description':
          'Ejercicio isométrico para fortalecer el core y mejorar la estabilidad.',
    },
    {
      'name': 'Burpees',
      'category': 'Cardio',
      'difficulty': 'Intermedio',
      'duration': '3 series x 10 reps',
      'equipment': 'Peso corporal',
      'description':
          'Ejercicio de cuerpo completo que combina fuerza y cardio.',
    },
  ];

  List<Map<String, dynamic>> get filteredExercises {
    if (selectedCategory == 'Todos') {
      return exercisesList;
    }
    return exercisesList
        .where((exercise) => exercise['category'] == selectedCategory)
        .toList();
  }

  Color getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Principiante':
        return Colors.green;
      case 'Intermedio':
        return Colors.orange;
      case 'Avanzado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Ejercicios',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filtros por categoría
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF6366F1),
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFF6366F1),
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF6366F1)
                          : Colors.grey.shade300,
                    ),
                  ),
                );
              },
            ),
          ),

          // Lista de ejercicios
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredExercises.length,
              itemBuilder: (context, index) {
                final exercise = filteredExercises[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () {
                      _showExerciseDetails(context, exercise);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  exercise['name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: getDifficultyColor(
                                    exercise['difficulty'],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  exercise['difficulty'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.fitness_center,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                exercise['equipment'],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.timer,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                exercise['duration'],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            exercise['description'],
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddExerciseDialog(context);
        },
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showExerciseDetails(
    BuildContext context,
    Map<String, dynamic> exercise,
  ) {
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          exercise['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: getDifficultyColor(exercise['difficulty']),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          exercise['difficulty'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    icon: Icons.category,
                    label: 'Categoría',
                    value: exercise['category'],
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.fitness_center,
                    label: 'Equipamiento',
                    value: exercise['equipment'],
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.timer,
                    label: 'Duración',
                    value: exercise['duration'],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Descripción',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exercise['description'],
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${exercise['name']} agregado a tu rutina',
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Agregar a mi rutina',
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

  void _showAddExerciseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Próximamente'),
          content: const Text(
            'La funcionalidad para agregar ejercicios personalizados estará disponible próximamente.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
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
