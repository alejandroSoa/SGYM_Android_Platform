import 'package:flutter/material.dart';
import '../widgets/day_advice.dart';
import '../widgets/daily_activity.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DayAdvice(color: Color.fromARGB(255, 122, 90, 249), frase: 'Si la vida te da limones, haz limonada 4K'),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFF2F2FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Icon(Icons.qr_code_2_rounded, size: 36, color: Color(0xFF7A5AF9)),
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
          const SizedBox(height: 12),

          DailyActivity(
            ejercicios: ['Ejercicio 1', 'Ejercicio 2', 'Ejercicio 3', 'Ejercicio 4', 'Ejercicio 5'],
            totalEjercicios: 20,
            dietaPrincipal: 'Ensalada con proteína',
            citaPrincipal: 'Consulta coach a las 4:00 PM',
          ),

        ],
      ),
    );
  }
}
