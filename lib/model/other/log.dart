import 'package:flutter/animation.dart';
import 'package:intl/intl.dart';

class LogModel {
  final NumberFormat _ = NumberFormat("00");
  DateTime time = DateTime.now();
  String text;
  Color color;

  String get message => "[${_.format(time.hour)}:${_.format(time.minute)}:${_.format(time.second)}] $text";

  LogModel({required this.text, required this.color});
}
