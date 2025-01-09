import 'package:flutter/material.dart';

class AuthSmsScreen extends StatefulWidget {
  const AuthSmsScreen({super.key});

  @override
  State<AuthSmsScreen> createState() => _AuthSmsScreenState();
}

class _AuthSmsScreenState extends State<AuthSmsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Auth Sms Screen"),
      ),
    );
  }
}
