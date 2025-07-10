import '../services/InitializationService.dart';
import '../services/AuthService.dart'; 
import 'package:flutter/material.dart';

class FirstTimeScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const FirstTimeScreen({super.key, required this.onComplete});

  @override
  State<FirstTimeScreen> createState() => _FirstTimeScreenState();
}

class _FirstTimeScreenState extends State<FirstTimeScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  bool _hasReachedEnd = false;
  bool _isAuthenticating = false; 

  Future<void> _continueToApp() async {
    setState(() {
      _isAuthenticating = true; 
    });


    String? authResult;
    bool success = false;
    try {
      success = await AuthService.authenticateWithOAuth(context)
        .then((value) {
          return value;
        });

        if (success) {
          print("[FIRST_TIME] Autenticación exitosa, verificando rol...");

          bool hasAccess = await AuthService.accessByRole();
          
          if (hasAccess) {
            authResult = "Autenticación completada y rol verificado exitosamente.";
            print("[FIRST_TIME] Usuario tiene acceso con el rol requerido");
          } else {
            success = false;
            authResult = "Autenticación exitosa pero sin permisos de acceso.";
            print("[FIRST_TIME] Usuario no tiene el rol requerido");
          }
        } else {
          authResult = "Autenticación fallida.";
        }
      // authResult = "Autenticación completada.\nResultado: $success";
    } catch (e) {
      authResult = "$e";
    }



    setState(() {
      _isAuthenticating = false; 
    });

    if (mounted) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(success ? 'Verificación exitosa' : 'Oops'),
          content: Text(authResult ?? 'Sin información'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    }
  
    if (success) {
      await InitializationService.markFirstTimeDone();
      if (mounted) {
        widget.onComplete();
      }
    }
  }
  final List<Map<String, String>> _carouselData = [
    {
      'title': 'Bienvenido a SGym',
      'description': 'Tu aplicación de fitness personalizada que te ayudará a alcanzar tus metas de entrenamiento y bienestar.',
    },
    {
      'title': '¿Cómo te ayuda SGym?',
      'description': 'Planifica rutinas, lleva control de tu citas, gestiona tu dieta y mantente motivado con nuestras herramientas.',
    },
    {
      'title': 'Regístrate y Comienza',
      'description': 'Para usar todas las funciones de la aplicación, necesitas registrarte o iniciar sesion nuevamente.',
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (_isAuthenticating) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Carrusel de contenido
          PageView.builder(
            controller: _pageController,            
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
                if (index == 2) {
                  _hasReachedEnd = true;
                }
              });
            },
            itemCount: _carouselData.length,
            itemBuilder: (context, index) {
              return _buildCarouselItem(_carouselData[index]);
            },
          ),         
          Positioned(
            bottom: 120 ,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _carouselData.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: _currentPage == index ? 18 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _currentPage == index
                      ? const Color(0xFF755FE3)
                      : Colors.black.withOpacity(0.35),
                    boxShadow: _currentPage == index
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                    border: Border.all(
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.black.withOpacity(0.15),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),          
          if (_hasReachedEnd)
            Positioned(
              bottom: 50,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: _continueToApp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Empezar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCarouselItem(Map<String, String> data) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(
                data['title']!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                data['description']!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 0, 0, 0),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}