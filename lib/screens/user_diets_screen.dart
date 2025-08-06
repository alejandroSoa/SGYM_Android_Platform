import 'package:flutter/material.dart';
import '../interfaces/bussiness/user_diet_interface.dart';
import '../services/DietService.dart';

class UserDietsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const UserDietsScreen({super.key, this.onBack});

  @override
  State<UserDietsScreen> createState() => _UserDietsScreenState();
}

class _UserDietsScreenState extends State<UserDietsScreen> {
  List<UserDiet> userDiets = [];
  bool isLoadingDiets = false;
  String? dietsError;

  @override
  void initState() {
    super.initState();
    _loadUserDiets();
  }

  Future<void> _loadUserDiets() async {
    setState(() {
      isLoadingDiets = true;
      dietsError = null;
    });

    try {
      final dietsList = await DietService.fetchUserDiets();
      setState(() {
        userDiets = dietsList ?? [];
        isLoadingDiets = false;
      });
      print("Dietas del usuario cargadas: ${userDiets.length}");
    } catch (e) {
      setState(() {
        dietsError = e.toString();
        isLoadingDiets = false;
      });
      print("Error al cargar dietas del usuario: $e");
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

  // Organizar dietas por día de la semana
  Map<String, List<UserDiet>> _groupDietsByDay() {
    Map<String, List<UserDiet>> groupedDiets = {};

    final days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];

    for (String day in days) {
      groupedDiets[day] = userDiets
          .where((diet) => diet.day.toLowerCase() == day)
          .toList();
    }

    return groupedDiets;
  }

  Widget _buildDietsSection() {
    if (isLoadingDiets) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
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
              onPressed: _loadUserDiets,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (userDiets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No tienes dietas asignadas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu nutricionista aún no te ha asignado ninguna dieta.',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final groupedDiets = _groupDietsByDay();
    final daysInSpanish = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    final daysInEnglish = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];

    return Column(
      children: [
        for (int i = 0; i < daysInSpanish.length; i++) ...[
          _buildDaySection(
            daysInSpanish[i],
            groupedDiets[daysInEnglish[i]] ?? [],
          ),
          if (i < daysInSpanish.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildDaySection(String dayName, List<UserDiet> diets) {
    // Si no hay dietas, mostrar sección gris
    if (diets.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFCAD1D9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          dayName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    // Si hay dietas, mostrar en formato expandido
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Día activo con dietas
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            dayName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Lista de dietas
        for (int i = 0; i < diets.length; i++) ...[
          _buildDietCard(diets[i]),
          if (i < diets.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildDietCard(UserDiet diet) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFCAD1D9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _showDietDetails(context, diet);
        },
        borderRadius: BorderRadius.circular(12),
        child: Text(
          diet.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  void _showDietDetails(BuildContext context, UserDiet diet) {
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
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.restaurant_menu,
                          color: const Color(0xFF4CAF50),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              diet.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _convertDayToSpanish(diet.day),
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F8E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      diet.description ?? 'Sin descripción disponible',
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Botón de Ver Alimentos
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showDietFoodsDialog(diet);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.visibility),
                          SizedBox(width: 8),
                          Text(
                            'Ver Alimentos',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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

  void _showDietFoodsDialog(UserDiet diet) {
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
                        diet.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
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

                // Lista de alimentos reales
                Expanded(child: _UserDietFoodsWidget(diet: diet)),
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
                      'Mis Dietas',
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

              _buildDietsSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserDietFoodsWidget extends StatefulWidget {
  final UserDiet diet;

  const _UserDietFoodsWidget({Key? key, required this.diet}) : super(key: key);

  @override
  _UserDietFoodsWidgetState createState() => _UserDietFoodsWidgetState();
}

class _UserDietFoodsWidgetState extends State<_UserDietFoodsWidget> {
  List<Map<String, dynamic>> dietFoods = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDietFoods();
  }

  Future<void> _loadDietFoods() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final foods = await DietService.fetchFoodsOfUserDiet(widget.diet.id);

      setState(() {
        dietFoods = foods ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar alimentos: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[700]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDietFoods,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (dietFoods.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              'Tu nutricionista aún no ha agregado alimentos a esta dieta.',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFCAD1D9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.builder(
        itemCount: dietFoods.length,
        itemBuilder: (context, index) {
          final dietFood = dietFoods[index];
          final food = dietFood['food'];

          if (food == null) {
            return Container();
          }

          final foodName = food['name']?.toString() ?? 'Alimento desconocido';
          final foodGrams = food['grams']?.toString() ?? '0';
          final foodCalories = food['calories']?.toString() ?? '0';
          final foodOtherInfo = food['other_info']?.toString();

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  foodName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${foodGrams}g - ${foodCalories} cal',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (foodOtherInfo != null && foodOtherInfo.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    foodOtherInfo,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
