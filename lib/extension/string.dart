import 'package:flutter/material.dart';

extension TimeParser on String {
  TimeOfDay? get toTimeOfDay {
    var splitted = split(":");
    if (splitted.length != 2) return null;
    var hours = int.tryParse(splitted[0]);
    var minutes = int.tryParse(splitted[1]);
    if (hours == null || minutes == null) return null;
    return TimeOfDay(hour: hours, minute: minutes);
  }
}
