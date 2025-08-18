import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/UserService.dart';
import '../services/SuscriptionService.dart';
import '../main.dart';
import 'first_time_screen.dart';

class SubscriptionNeededScreen extends StatefulWidget {
  const SubscriptionNeededScreen({super.key});

  @override
  State<SubscriptionNeededScreen> createState() =>
      _SubscriptionNeededScreenState();
}

class _SubscriptionNeededScreenState extends State<SubscriptionNeededScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA), Color(0xFFAB47BC)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header con acciones
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'SGYM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.refresh,
                          onTap: _checkSubscriptionStatus,
                          backgroundColor: Colors.white.withOpacity(0.2),
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          icon: Icons.logout,
                          onTap: _logout,
                          backgroundColor: Colors.red.withOpacity(0.7),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Contenido principal
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height - 200,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          // Icono principal animado
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 2000),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: 0.8 + (0.2 * value),
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(60),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.diamond,
                                    size: 60,
                                    color: Color(0xFF6A1B9A),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 40),

                          // Título principal
                          const Text(
                            '¡Desbloquea tu\nPotencial Fitness!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 20),

                          // Subtítulo
                          Text(
                            'Accede a todas las funciones premium de SGYM\ncon una suscripción activa',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 40),

                          // Lista de beneficios
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildBenefitItem(
                                  Icons.fitness_center,
                                  'Rutinas Personalizadas',
                                  'Entrenamientos adaptados a tus objetivos',
                                ),
                                const SizedBox(height: 16),
                                _buildBenefitItem(
                                  Icons.restaurant_menu,
                                  'Planes Nutricionales',
                                  'Dietas balanceadas para tu estilo de vida',
                                ),
                                const SizedBox(height: 16),
                                _buildBenefitItem(
                                  Icons.calendar_today,
                                  'Reserva de Citas',
                                  'Agenda sesiones con entrenadores expertos',
                                ),
                                const SizedBox(height: 16),
                                _buildBenefitItem(
                                  Icons.trending_up,
                                  'Seguimiento Avanzado',
                                  'Monitorea tu progreso día a día',
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Botones de acción
                          Column(
                            children: [
                              // Botón principal de suscripción
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _openSubscriptionPage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF6A1B9A),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 8,
                                    shadowColor: Colors.black.withOpacity(0.3),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.star, size: 24),
                                      SizedBox(width: 8),
                                      Text(
                                        'Suscribirme Ahora',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Botón secundario
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: _checkSubscriptionStatus,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Ya tengo suscripción',
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
                        ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color backgroundColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openSubscriptionPage() async {
    try {
      final token = await UserService.getToken();
      if (token == null) {
        _showSnackBar('Error: No se encontró token de usuario', Colors.red);
        return;
      }

      const baseUrl = '146.190.130.50';
      final subscriptionUrl =
          'http://$baseUrl/federation-login?access_token=$token';
      final uri = Uri.parse(subscriptionUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        _showSnackBar(
          'Abriendo página de suscripción...',
          const Color(0xFF6A1B9A),
        );
      } else {
        throw Exception('No se puede abrir la URL');
      }
    } catch (e) {
      _showSnackBar('Error al abrir la página de suscripción: $e', Colors.red);
    }
  }

  Future<void> _checkSubscriptionStatus() async {
    try {
      _showLoadingDialog();

      final hasSubscription =
          await SubscriptionService.hasActiveSubscriptions();

      if (mounted) {
        Navigator.of(context).pop(); // Cerrar loading

        if (hasSubscription) {
          _showSnackBar(
            '¡Suscripción verificada! Cargando aplicación...',
            Colors.green,
          );

          // Recargar la aplicación
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainLayout()),
            );
          }
        } else {
          _showSnackBar(
            'No se detectó suscripción activa. Inténtalo de nuevo.',
            Colors.orange,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Cerrar loading
        _showSnackBar('Error verificando suscripción: $e', Colors.red);
      }
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Deseas cerrar sesión para cambiar de cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        _showLoadingDialog();

        // Limpiar datos de usuario
        await UserService.clearToken();
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('first-init-app');

        if (mounted) {
          Navigator.of(context).pop(); // Cerrar loading
          
          // Navegar a FirstTimeScreen para login/register
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => FirstTimeScreen(
                onComplete: () async {
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const MainLayout()),
                    );
                  }
                },
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // Cerrar loading
          _showSnackBar('Error cerrando sesión: $e', Colors.red);
        }
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
