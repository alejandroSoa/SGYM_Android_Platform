import 'package:flutter/material.dart';
import '../interfaces/bussiness/diet_interface.dart';
import '../interfaces/bussiness/food_interface.dart';
import '../services/DietService.dart';
import '../services/FoodService.dart';

class DietsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const DietsScreen({super.key, this.onBack});

  @override
  State<DietsScreen> createState() => _DietsScreenState();
}

class _DietsScreenState extends State<DietsScreen> {
  // Lista de alimentos desde la API
  List<Food> foods = [];
  bool isLoadingFoods = false;
  String? foodsError;

  // Lista de dietas reales desde la API
  List<Diet> realDiets = [];
  bool isLoadingDiets = false;
  String? dietsError;

  @override
  void initState() {
    super.initState();
    _loadFoods();
    _loadDiets();
  }

  Future<void> _loadFoods() async {
    setState(() {
      isLoadingFoods = true;
      foodsError = null;
    });

    try {
      final foodsList = await FoodService.fetchFoods();
      setState(() {
        foods = foodsList ?? [];
        isLoadingFoods = false;
      });
      print("Alimentos cargados: $foods");
      print("Alimentos cargados: ${foods.length}");
    } catch (e) {
      setState(() {
        foodsError = e.toString();
        isLoadingFoods = false;
      });
      print("Error al cargar alimentos: $e");
    }
  }

  Future<void> _loadDiets() async {
    setState(() {
      isLoadingDiets = true;
      dietsError = null;
    });

    try {
      final dietsList = await DietService.fetchDiets();
      print("Lista de dietas extraída: $dietsList");
      print("Cantidad de dietas: ${dietsList?.length ?? 0}");

      setState(() {
        if (dietsList != null) {
          realDiets = [];
          for (var dietMap in dietsList) {
            try {
              print("Procesando dieta: $dietMap");
              final diet = Diet.fromJson(dietMap);
              realDiets.add(diet);
              print("Dieta procesada exitosamente: ${diet.name}");
            } catch (dietError) {
              print("Error al procesar dieta individual: $dietError");
              print("Datos de la dieta problemática: $dietMap");
              // Continúa con las otras dietas en lugar de fallar completamente
            }
          }
        } else {
          realDiets = [];
        }
        isLoadingDiets = false;
      });
      print(
        "Resultado final: ${realDiets.length} dietas cargadas exitosamente",
      );
    } catch (e) {
      setState(() {
        dietsError = e.toString();
        isLoadingDiets = false;
      });
      print("Error al cargar dietas: $e");
    }
  }

  Widget _buildFoodsSection() {
    if (isLoadingFoods) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      );
    }

    if (foodsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error al cargar alimentos',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadFoods,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Verificar si hay alimentos
        if (foods.isEmpty) ...[
          // Mensaje cuando no hay alimentos
          Container(
            width: double.infinity,
            height: 200, // Altura fija para consistencia
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                'No hay alimentos disponibles',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ] else ...[
          // Lista de alimentos con altura fija y scroll
          Container(
            height: 100, // Altura fija para la lista de alimentos
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  ...foods.map(
                    (food) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          _showFoodDetails(context, food);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      food.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.more_vert,
                                color: Colors.grey[400],
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        // Botón de agregar - siempre visible en la parte inferior
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.black, size: 24),
              onPressed: () {
                _showAddFoodDialog();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDietsSection() {
    if (isLoadingDiets) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      );
    }

    if (dietsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error al cargar dietas',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadDiets,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Botón "Agregar nueva dieta"
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
                'Agregar nueva dieta',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.black, size: 20),
                  onPressed: () {
                    _showAddDietDialog();
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Lista de dietas reales
        ...realDiets.map(
          (diet) => Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                _showDietDetails(context, diet);
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                child: Text(
                  diet.name,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showFoodDetails(BuildContext context, Food food) {
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
                    food.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    icon: Icons.monitor_weight,
                    label: 'Gramos',
                    value: '${food.grams}g',
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.local_fire_department,
                    label: 'Calorías',
                    value: '${food.calories} cal',
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Información adicional',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    food.otherInfo?.isNotEmpty == true
                        ? food.otherInfo!
                        : 'Sin información adicional',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      fontStyle: food.otherInfo?.isNotEmpty == true
                          ? FontStyle.normal
                          : FontStyle.italic,
                      color: food.otherInfo?.isNotEmpty == true
                          ? Colors.black
                          : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Botón de Editar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditFoodDialog(food);
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
                        _showDeleteFoodConfirmationDialog(food);
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

  void _showDietDetails(BuildContext context, Diet diet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
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
                    diet.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botón de Editar
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showEditDietDialog(diet);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Editar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Botón de Eliminar
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showDeleteDietConfirmationDialog(diet);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Eliminar'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Gestión de alimentos de la dieta
                  Expanded(child: _DietFoodsManager(diet: diet)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddFoodDialog() {
    final nameController = TextEditingController();
    final gramsController = TextEditingController();
    final caloriesController = TextEditingController();
    final otherInfoController = TextEditingController();
    bool isCreating = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Nuevo Alimento',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
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
                        labelText: 'Nombre del alimento',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.restaurant),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campo gramos
                    TextField(
                      controller: gramsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Gramos',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.monitor_weight),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campo calorías
                    TextField(
                      controller: caloriesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Calorías',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.local_fire_department),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campo información adicional
                    TextField(
                      controller: otherInfoController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Información adicional (opcional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.info),
                        hintText: 'Información nutricional adicional...',
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
                  onPressed: isCreating
                      ? null
                      : () async {
                          if (nameController.text.trim().isEmpty ||
                              gramsController.text.trim().isEmpty ||
                              caloriesController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Todos los campos son obligatorios excepto información adicional',
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

                          await _createFood(
                            name: nameController.text.trim(),
                            grams:
                                double.tryParse(gramsController.text.trim()) ??
                                0,
                            calories:
                                double.tryParse(
                                  caloriesController.text.trim(),
                                ) ??
                                0,
                            otherInfo: otherInfoController.text.trim().isEmpty
                                ? null
                                : otherInfoController.text.trim(),
                          );

                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
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

  void _showEditFoodDialog(Food food) {
    final nameController = TextEditingController(text: food.name);
    final gramsController = TextEditingController(text: food.grams.toString());
    final caloriesController = TextEditingController(
      text: food.calories.toString(),
    );
    final otherInfoController = TextEditingController(
      text: food.otherInfo ?? '',
    );
    bool isUpdating = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Editar Alimento',
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
                    // Campo nombre
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del alimento',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.restaurant),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campo gramos
                    TextField(
                      controller: gramsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Gramos',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.monitor_weight),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campo calorías
                    TextField(
                      controller: caloriesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Calorías',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.local_fire_department),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campo información adicional
                    TextField(
                      controller: otherInfoController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Información adicional (opcional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.info),
                        hintText: 'Información nutricional adicional...',
                      ),
                    ),
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
                          if (nameController.text.trim().isEmpty ||
                              gramsController.text.trim().isEmpty ||
                              caloriesController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Todos los campos son obligatorios excepto información adicional',
                                ),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            isUpdating = true;
                          });

                          await _updateFood(
                            id: food.id,
                            name: nameController.text.trim(),
                            grams:
                                double.tryParse(gramsController.text.trim()) ??
                                0,
                            calories:
                                double.tryParse(
                                  caloriesController.text.trim(),
                                ) ??
                                0,
                            otherInfo: otherInfoController.text.trim().isEmpty
                                ? null
                                : otherInfoController.text.trim(),
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

  void _showDeleteFoodConfirmationDialog(Food food) {
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
                '¿Estás seguro de que quieres eliminar este alimento?',
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
                      food.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${food.grams}g - ${food.calories} cal',
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
                await _deleteFood(food.id, food.name);
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

  void _showAddDietDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isCreating = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Nueva Dieta',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
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
                        labelText: 'Nombre de la dieta',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.restaurant_menu),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campo descripción
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Descripción (opcional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                        hintText: 'Describe la dieta...',
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
                  onPressed: isCreating
                      ? null
                      : () async {
                          if (nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'El nombre de la dieta es obligatorio',
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

                          await _createDiet(
                            name: nameController.text.trim(),
                            description:
                                descriptionController.text.trim().isEmpty
                                ? null
                                : descriptionController.text.trim(),
                          );

                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
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

  void _showEditDietDialog(Diet diet) {
    final nameController = TextEditingController(text: diet.name);
    final descriptionController = TextEditingController(
      text: diet.description ?? '',
    );
    bool isUpdating = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Editar Dieta',
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
                    // Campo nombre
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la dieta',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.restaurant_menu),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campo descripción
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Descripción (opcional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                        hintText: 'Describe la dieta...',
                      ),
                    ),
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
                          if (nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'El nombre de la dieta es obligatorio',
                                ),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            isUpdating = true;
                          });

                          await _updateDiet(
                            dietId: diet.id,
                            name: nameController.text.trim(),
                            description:
                                descriptionController.text.trim().isEmpty
                                ? null
                                : descriptionController.text.trim(),
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

  void _showDeleteDietConfirmationDialog(Diet diet) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('¿Estás seguro de que quieres eliminar esta dieta?'),
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
                      diet.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (diet.description != null &&
                        diet.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        diet.description!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
                await _deleteDiet(diet.id, diet.name);
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

  Future<void> _createDiet({required String name, String? description}) async {
    try {
      final newDiet = await DietService.createDiet(
        name: name,
        description: description,
      );

      if (newDiet != null) {
        await _loadDiets();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dieta "$name" creada exitosamente'),
            backgroundColor: Colors.grey[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al crear la dieta'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Error al crear dieta: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear la dieta: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteDiet(int dietId, String dietName) async {
    try {
      final success = await DietService.deleteDiet(dietId);
      if (success) {
        await _loadDiets();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$dietName eliminada exitosamente'),
            backgroundColor: Colors.grey[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al eliminar la dieta'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _updateDiet({
    required int dietId,
    required String name,
    String? description,
  }) async {
    try {
      final updatedDiet = await DietService.updateDiet(
        id: dietId,
        name: name,
        description: description,
      );

      if (updatedDiet != null) {
        await _loadDiets();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dieta "$name" actualizada exitosamente'),
            backgroundColor: Colors.grey[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al actualizar la dieta'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Error al actualizar dieta: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar la dieta: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // CRUD Methods for Foods
  Future<void> _createFood({
    required String name,
    required double grams,
    required double calories,
    String? otherInfo,
  }) async {
    try {
      final newFood = await FoodService.createFood(
        name: name,
        grams: grams,
        calories: calories,
        otherInfo: otherInfo,
      );

      if (newFood != null) {
        await _loadFoods();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alimento "$name" creado exitosamente'),
            backgroundColor: Colors.grey[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al crear el alimento'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear el alimento: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _updateFood({
    required int id,
    required String name,
    required double grams,
    required double calories,
    String? otherInfo,
  }) async {
    try {
      final updatedFood = await FoodService.updateFood(
        id: id,
        name: name,
        grams: grams,
        calories: calories,
        otherInfo: otherInfo,
      );

      if (updatedFood != null) {
        await _loadFoods();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alimento "$name" actualizado exitosamente'),
            backgroundColor: Colors.grey[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al actualizar el alimento'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar el alimento: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteFood(int foodId, String foodName) async {
    try {
      final success = await FoodService.deleteFood(foodId);
      if (success) {
        await _loadFoods();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$foodName eliminado exitosamente'),
            backgroundColor: Colors.grey[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al eliminar el alimento'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
                      'Dietas',
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

              // Sección de Alimentos en contenedor destacado
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFCAD1D9),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alimentos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFoodsSection(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Sección de Dietas
              _buildDietsSection(),
            ],
          ),
        ),
      ),
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
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _DietFoodsManager extends StatefulWidget {
  final Diet diet;

  const _DietFoodsManager({Key? key, required this.diet}) : super(key: key);

  @override
  _DietFoodsManagerState createState() => _DietFoodsManagerState();
}

class _DietFoodsManagerState extends State<_DietFoodsManager> {
  List<Map<String, dynamic>> dietFoods = [];
  List<Food> allFoods = [];
  bool isLoadingDietFoods = true;
  bool isLoadingAllFoods = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAllFoods().then((_) {
      _loadDietFoods();
    });
  }

  Future<void> _loadDietFoods() async {
    try {
      setState(() {
        isLoadingDietFoods = true;
        errorMessage = null;
      });

      final foods = await DietService.fetchFoodsOfDiet(widget.diet.id);

      setState(() {
        dietFoods = foods ?? [];
        isLoadingDietFoods = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar alimentos de la dieta: $e';
        isLoadingDietFoods = false;
      });
    }
  }

  Future<void> _loadAllFoods() async {
    try {
      setState(() {
        isLoadingAllFoods = true;
      });

      final foods = await FoodService.fetchFoods();
      setState(() {
        allFoods = foods ?? [];
        isLoadingAllFoods = false;
      });
    } catch (e) {
      setState(() {
        isLoadingAllFoods = false;
      });
    }
  }

  Future<void> _assignFoodToDiet(Food food) async {
    try {
      final dietFood = await DietService.addFoodsToDiet(
        dietId: widget.diet.id,
        foodIds: [food.id],
      );

      if (dietFood != null) {
        await _loadDietFoods();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Alimento "${food.name}" agregado a la dieta'),
              backgroundColor: Colors.grey[600],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al agregar el alimento'),
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

  Future<void> _removeFoodFromDiet(Map<String, dynamic> dietFood) async {
    try {
      final success = await DietService.removeFoodFromDiet(
        dietId: widget.diet.id,
        dietFoodId: dietFood['id'], // This is the pivot table ID
      );

      if (success) {
        await _loadDietFoods();
        if (mounted) {
          final food = dietFood['food']; // Access the nested food object
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Alimento "${food['name']}" eliminado de la dieta'),
              backgroundColor: Colors.grey[600],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al eliminar el alimento'),
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

  void _showAddFoodDialog() {
    // Filtrar alimentos que no están en la dieta
    final availableFoods = allFoods.where((food) {
      return !dietFoods.any((dietFood) => dietFood['food']['id'] == food.id);
    }).toList();

    if (availableFoods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay alimentos disponibles para agregar'),
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
          title: const Text(
            'Agregar Alimento',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: availableFoods.length,
              itemBuilder: (context, index) {
                final food = availableFoods[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[600],
                    child: Icon(
                      Icons.restaurant,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    food.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('${food.grams}g - ${food.calories} cal'),
                  onTap: () {
                    Navigator.pop(context);
                    _assignFoodToDiet(food);
                  },
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
    if (isLoadingDietFoods || isLoadingAllFoods) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[700]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDietFoods,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFCAD1D9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Alimentos',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.black, size: 20),
                  onPressed: _showAddFoodDialog,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Foods list
        if (dietFoods.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(Icons.restaurant, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No hay alimentos en esta dieta',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Agrega alimentos usando el botón +',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: dietFoods.length,
              itemBuilder: (context, index) {
                final dietFood = dietFoods[index];
                final food = dietFood['food']; // Access the nested food object
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      food['name'] ?? 'Alimento desconocido',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '${food['grams'] ?? 0}g - ${food['calories'] ?? 0} cal',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.remove_circle, color: Colors.red[400]),
                      onPressed: () {
                        _showRemoveFoodConfirmation(dietFood);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showRemoveFoodConfirmation(Map<String, dynamic> dietFood) {
    final food = dietFood['food']; // Access the nested food object
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text(
            '¿Estás seguro de que quieres eliminar "${food['name']}" de esta dieta?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _removeFoodFromDiet(dietFood);
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
}
