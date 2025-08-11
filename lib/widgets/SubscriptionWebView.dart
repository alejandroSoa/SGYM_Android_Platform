import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/UserService.dart';

class SubscriptionWebView extends StatefulWidget {
  final Function(Map<String, dynamic>?) onResult;

  const SubscriptionWebView({super.key, required this.onResult});

  @override
  State<SubscriptionWebView> createState() => _SubscriptionWebViewState();
}

class _SubscriptionWebViewState extends State<SubscriptionWebView> {
  WebViewController? _controller;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    try {
      print('=== INICIANDO INICIALIZACIÓN DEL WEBVIEW DE SUSCRIPCIÓN ===');
      
      // Obtener el token del usuario
      final token = await UserService.getToken();
      print('Token obtenido: ${token != null ? 'Token disponible (${token.length} caracteres)' : 'null'}');
      
      if (token != null) {
        print('Token completo: $token');
      }

      // Construir la URL con el endpoint y el token - usando HTTP directamente
      final baseUrl = '146.190.130.50';
      String url;
      
      if (token != null) {
        url = 'http://$baseUrl/federation-login?access_token=$token';
      } else {
        url = 'http://$baseUrl/federation-login';
      }

      print('URL construida (HTTP): $url');

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setUserAgent('SGym-App/1.0 (Flutter WebView)')
        ..enableZoom(false)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              print('🔄 Página iniciada: $url');
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
            },
            onPageFinished: (String url) {
              print('✅ Página terminada de cargar: $url');
              setState(() {
                _isLoading = false;
              });
              
              // Inyectar el token en el JavaScript si está disponible
              if (token != null) {
                print('💉 Inyectando token en JavaScript...');
                _controller!.runJavaScript('''
                  console.log('🔧 Token inyectado desde Flutter: $token');
                  window.flutterToken = '$token';
                  if (window.localStorage) {
                    window.localStorage.setItem('access_token', '$token');
                    console.log('💾 Token guardado en localStorage');
                  }
                  if (window.sessionStorage) {
                    window.sessionStorage.setItem('access_token', '$token');
                    console.log('💾 Token guardado en sessionStorage');
                  }
                ''').then((_) {
                  print('✅ JavaScript ejecutado correctamente');
                }).catchError((error) {
                  print('❌ Error ejecutando JavaScript: $error');
                });
              }
            },
            onHttpError: (HttpResponseError error) {
              print('❌ Error HTTP: ${error.response?.statusCode}');
              print('❌ Error HTTP details: ${error.response}');
              setState(() {
                _isLoading = false;
                _errorMessage = 'Error de conexión HTTP: ${error.response?.statusCode}';
              });
            },
            onWebResourceError: (WebResourceError error) {
              print('❌ Error de recurso web: ${error.errorCode} - ${error.description}');
              print('❌ URL que falló: ${error.url}');
              print('❌ Tipo de error: ${error.errorType}');
              
              // Solo mostrar error si es la página principal, no recursos secundarios
              if (error.url != null && error.url!.contains('146.190.130.50')) {
                setState(() {
                  _isLoading = false;
                  _errorMessage = 'Error de conexión: ${error.description}';
                });
              } else {
                print('⚠️ Error en recurso secundario, continuando...');
              }
            },
            onNavigationRequest: (NavigationRequest request) {
              print('🔗 Solicitud de navegación: ${request.url}');
              return NavigationDecision.navigate;
            },
          ),
        );
      
      print('🚀 Cargando URL en WebView: $url');
      await _controller!.loadRequest(Uri.parse(url));
      
      setState(() {
        _isInitialized = true;
      });
      
      print('✅ loadRequest completado');
      
    } catch (e, stackTrace) {
      print('❌ Error al inicializar WebView: $e');
      print('📍 Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al inicializar: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suscripción - SGym'),
        backgroundColor: const Color(0xFF7012DA),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          if (_errorMessage != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _errorMessage = null;
                        _isLoading = true;
                      });
                      _initializeWebView();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7012DA),
                    ),
                    child: const Text(
                      'Reintentar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          else if (_controller != null && _isInitialized)
            WebViewWidget(controller: _controller!),
          if (_isLoading && _errorMessage == null)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF7012DA),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Cargando página de suscripción...',
                    style: TextStyle(fontSize: 16, color: Color(0xFF7012DA)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
