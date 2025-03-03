import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

extension TimeParser on String {
  TimeOfDay? get toTimeOfDay {
    var splitted = split(":");
    if (splitted.length != 2) return null;
    var hours = int.tryParse(splitted[0]);
    var minutes = int.tryParse(splitted[1]);
    if (hours == null || minutes == null) return null;
    return TimeOfDay(hour: hours, minute: minutes);
  }

  DateTime? get toDateTime {
    var splitted = split(" ");
    if (splitted.length == 1) {
      var time = splitted[0].toTimeOfDay;
      if (time == null) return null;
      var now = DateTime.now();
      return DateTime(now.year, now.month, now.day, time.hour, time.minute);
    } else if (splitted.length == 2) {
      var date = splitted[0].toDate;
      var time = splitted[1].toTimeOfDay;
      if (date == null || time == null) return null;
      return DateTime(date.year, date.month, date.day, time.hour, time.minute);
    }
    return null;
  }

  DateTime? get toDate {
    var splitted = split("-");
    if (splitted.length != 3) return null;
    var day = int.tryParse(splitted[0]);
    var month = int.tryParse(splitted[1]);
    var year = int.tryParse(splitted[2]);
    if (year == null || month == null || day == null) return null;
    return DateTime(year, month, day);
  }
}

extension LatLngParser on String {
  LatLng? get toLatLng {
    var splitted = split(",");
    if (splitted.length != 2) return null;
    var lat = double.tryParse(splitted[0]);
    var lng = double.tryParse(splitted[1]);
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }
}
