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
