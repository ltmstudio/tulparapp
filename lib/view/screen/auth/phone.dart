import 'package:flutter/material.dart';

class AuthPhoneScreen extends StatefulWidget {
  const AuthPhoneScreen({super.key});

  @override
  State<AuthPhoneScreen> createState() => _AuthPhoneScreenState();
}

class _AuthPhoneScreenState extends State<AuthPhoneScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Auth Phone Screen"),
      ),
    );
  }
}
