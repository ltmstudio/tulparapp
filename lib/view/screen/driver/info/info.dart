import 'package:flutter/material.dart';

class InfoAndFaqScreen extends StatefulWidget {
  const InfoAndFaqScreen({super.key});

  @override
  State<InfoAndFaqScreen> createState() => _InfoAndFaqScreenState();
}

class _InfoAndFaqScreenState extends State<InfoAndFaqScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Справочник и FAQ"),
      ),
    );
  }
}
