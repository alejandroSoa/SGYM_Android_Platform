import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OAuthWebView extends StatefulWidget {
  final String authUrl;
  final String redirectUri;

  const OAuthWebView({
    super.key,
    required this.authUrl,
    required this.redirectUri,
  });

  @override
  State<OAuthWebView> createState() => _OAuthWebViewState();
}

class _OAuthWebViewState extends State<OAuthWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (request.url.startsWith(widget.redirectUri)) {
              _handleCallback(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authUrl));
  }

  void _handleCallback(String url) {
    final uri = Uri.parse(url);
    final token = uri.queryParameters['access_token'];
    
    if (token != null) {
      Navigator.of(context).pop(token);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SGym'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: WebViewWidget(controller: _controller), 
    );
  }
}