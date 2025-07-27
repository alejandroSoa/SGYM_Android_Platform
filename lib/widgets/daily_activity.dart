import 'package:flutter/material.dart';

class DailyActivity extends StatelessWidget {
  final List<String> ejercicios; // Ahora representa nombres de rutinas
  final int totalEjercicios; // Ahora representa total de rutinas
  final String dietaPrincipal;
  final String citaPrincipal;
  final VoidCallback? onRutinaTap;
  final VoidCallback? onDietaTap;
  final VoidCallback? onCitasTap;

  const DailyActivity({
    super.key,
    required this.ejercicios,
    required this.totalEjercicios,
    required this.dietaPrincipal,
    required this.citaPrincipal,
    this.onRutinaTap,
    this.onDietaTap,
    this.onCitasTap,
  }) : assert(
         ejercicios.length == 5,
         'Debe haber exactamente 5 elementos en la lista',
       );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actividad diaria',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onRutinaTap,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: const Color(0xFF9E8DF2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.fitness_center,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Rutina',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...ejercicios.map(
                          (e) => Text(
                            e,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 19),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Rutinas',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '$totalEjercicios',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Dieta y Citas
              Expanded(
                child: Column(
                  children: [
                    // Dieta
                    GestureDetector(
                      onTap: onDietaTap,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE4F431),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.restaurant,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Dieta',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dietaPrincipal,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Citas
                    GestureDetector(
                      onTap: onCitasTap,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF50D2C2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Citas',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              citaPrincipal,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
