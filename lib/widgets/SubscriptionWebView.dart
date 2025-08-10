import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SubscriptionWebView extends StatefulWidget {
  final String subscriptionUrl;
  final String? redirectUri;

  const SubscriptionWebView({
    super.key,
    required this.subscriptionUrl,
    this.redirectUri,
  });

  @override
  State<SubscriptionWebView> createState() => _SubscriptionWebViewState();
}

class _SubscriptionWebViewState extends State<SubscriptionWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            // Si hay un redirectUri, verificar si la URL coincide
            if (widget.redirectUri != null && 
                request.url.startsWith(widget.redirectUri!)) {
              _handleCallback(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.subscriptionUrl));
  }

  void _handleCallback(String url) {
    try {
      // Procesar callback si es necesario
      final uri = Uri.parse(url);
      
      // Por ahora, simplemente cerrar el WebView
      // En el futuro se puede procesar información de suscripción aquí
      Navigator.of(context).pop({'success': true, 'url': url});
    } catch (e) {
      debugPrint('Error procesando callback de suscripción: $e');
      Navigator.of(context).pop({'success': false, 'error': e.toString()});
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
          WebViewWidget(controller: _controller),
          if (_isLoading) 
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7012DA)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Cargando página de suscripción...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF7012DA),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
