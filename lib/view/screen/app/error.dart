import 'package:flutter/material.dart';

class AppErrorScreen extends StatefulWidget {
  const AppErrorScreen({super.key});

  @override
  State<AppErrorScreen> createState() => _AppErrorScreenState();
}

class _AppErrorScreenState extends State<AppErrorScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Error Screen")));
  }
}
