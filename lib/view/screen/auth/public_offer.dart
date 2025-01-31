import 'package:flutter/material.dart';
import 'package:tulpar/core/env.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PublicOfferScreen extends StatefulWidget {
  const PublicOfferScreen({super.key});

  @override
  State<PublicOfferScreen> createState() => _PublicOfferScreenState();
}

class _PublicOfferScreenState extends State<PublicOfferScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('Загрузка страницы: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Страница загружена: $url');
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('Запрос перехода: ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('${CoreEnvironment.appUrl}/public_offer/kz')); // Замени на нужный URL
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TULPAR")),
      body: WebViewWidget(controller: _controller),
    );
  }
}
