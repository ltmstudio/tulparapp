import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tulpar/controller/other/log.dart';
import 'package:tulpar/model/other/log.dart';

abstract class Log {
  static void info(String msg) {
    developer.log('\x1B[34m$msg\x1B[0m');
    var logger = Get.find<LogController>();
    logger.set(LogModel(text: msg, color: const Color.fromARGB(255, 33, 31, 136)));
  }

  static void success(String msg) {
    developer.log('\x1B[32m$msg\x1B[0m');
    var logger = Get.find<LogController>();
    logger.set(LogModel(text: msg, color: const Color.fromARGB(255, 18, 105, 15)));
  }

  static void warning(String msg) {
    developer.log('\x1B[33m$msg\x1B[0m');
    var logger = Get.find<LogController>();
    logger.set(LogModel(text: msg, color: const Color.fromARGB(255, 154, 128, 24)));
  }

  static void error(String msg) {
    developer.log('\x1B[31m$msg\x1B[0m');
    var logger = Get.find<LogController>();
    logger.set(LogModel(text: msg, color: const Color.fromARGB(255, 146, 34, 19)));
  }
}
