import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tulpar/core/log.dart';

class LocationProvider {
  final ValueNotifier<Position?> currentPosition = ValueNotifier(null);
  StreamSubscription<Position>? subscrition;

  LocationProvider() {
    Log.info('Провайдер локации инициализирован');
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }
    subscrition = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      currentPosition.value = position;
    });
  }

  void close() {
    subscrition?.cancel();
    subscrition = null;
    currentPosition.value = null;
  }

  static double calculateDistance({required Position lastPosition, required Position currentPosition}) {
    double distanceInMeters = Geolocator.distanceBetween(
      lastPosition.latitude,
      lastPosition.longitude,
      currentPosition.latitude,
      currentPosition.longitude,
    );

    Log.warning('Расстояние: $distanceInMeters метров');
    return distanceInMeters;
  }
}
