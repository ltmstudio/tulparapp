import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tulpar/controller/other/log.dart';
import 'package:tulpar/controller/user.dart';
import 'package:tulpar/core/log.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Logs"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_applications_rounded),
            onPressed: () {
              Log.warning(Get.find<UserController>().token.value ?? 'null');
            },
          ),
        ],
      ),
      body: GetBuilder<LogController>(builder: (l) {
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          reverse: true,
          children: [
            for (var m in l.list.value.reversed)
              Container(
                width: w,
                // color: m.color.withOpacity(0.5),
                child: Text(
                  m.message,
                  style: TextStyle(fontSize: 14, color: m.color, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        );
      }),
    );
  }
}
