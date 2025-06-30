import 'package:flutter/material.dart';
import '../widgets/day_advice.dart';
import '../widgets/daily_activity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/UserService.dart';
import '../main.dart';
import 'package:flutter/services.dart';

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
          GestureDetector(
            onTap: () {
              final mainLayoutState = context.findAncestorStateOfType<State<MainLayout>>();
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
          ),
          const SizedBox(height: 12),

          DailyActivity(
            ejercicios: ['Ejercicio 1', 'Ejercicio 2', 'Ejercicio 3', 'Ejercicio 4', 'Ejercicio 5'],
            totalEjercicios: 20,
            dietaPrincipal: 'Ensalada con proteína',
            citaPrincipal: 'Consulta coach a las 4:00 PM',
          ),
          const SizedBox(height: 12),
          _ClearPreferencesButton(),
          const SizedBox(height: 12),

          FutureBuilder<String?>(
            future: UserService.getToken(),
            builder: (context, tokenSnapshot) {
              return FutureBuilder<Map<String, dynamic>?>(
                future: UserService.getUser(),
                builder: (context, userSnapshot) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFEDF0F3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Color(0xFFDBE0E5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.token, color: Color(0xFF7A5AF9)),
                            const SizedBox(width: 8),
                            const Text(
                              'Beta Test',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF413477),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // User Info Section
                        if (userSnapshot.connectionState == ConnectionState.waiting)
                          const Text('Cargando información del usuario...')
                        else if (userSnapshot.hasData && userSnapshot.data != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Color(0xFFDBE0E5)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 16, color: Color(0xFF7A5AF9)),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Usuario:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF413477),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'ID: ${userSnapshot.data!['id'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
                                ),
                                Text(
                                  'Email: ${userSnapshot.data!['email'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Color(0xFFDBE0E5)),
                            ),
                            child: const Text(
                              'No hay información del usuario disponible',
                              style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
                            ),
                          ),
                        
                        const SizedBox(height: 12),
                        
                        // Token Section
                        GestureDetector(
                          onTap: () async {
                            final token = tokenSnapshot.data;
                            if (token != null && token.isNotEmpty) {
                              await Clipboard.setData(ClipboardData(text: token));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Token copiado al portapapeles'),
                                  backgroundColor: Color(0xFF7A5AF9),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Color(0xFFDBE0E5)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.key, size: 16, color: Color(0xFF7A5AF9)),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Token:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF413477),
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.copy,
                                      size: 16,
                                      color: Color(0xFF7A5AF9),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  tokenSnapshot.connectionState == ConnectionState.waiting
                                      ? 'Cargando token...'
                                      : tokenSnapshot.data ?? 'No hay token disponible',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                    color: Color(0xFF333333),
                                  ),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
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
          ),

        ],
      ),
    );
  }
}

class _ClearPreferencesButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('first-init-app');
         
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Boton de prueba para borrar shared preferences.'),
              backgroundColor: Colors.green,
            ),
          );
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
            const Icon(Icons.delete_forever, color: Colors.white),
            const SizedBox(width: 8),
            const Text(
              'Borrar User Beta Test',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
