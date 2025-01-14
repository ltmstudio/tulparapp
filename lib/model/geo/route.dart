// To parse this JSON data, do
//
//     final geoRouteModel = geoRouteModelFromJson(jsonString);

import 'dart:convert';

import 'package:latlong2/latlong.dart';

GeoRouteModel geoRouteModelFromJson(String str) => GeoRouteModel.fromJson(json.decode(str));

String geoRouteModelToJson(GeoRouteModel data) => json.encode(data.toJson());

class GeoRouteModel {
  GeoRoute? route;

  GeoRouteModel({
    this.route,
  });

  GeoRouteModel copyWith({
    GeoRoute? route,
  }) =>
      GeoRouteModel(
        route: route ?? this.route,
      );

  factory GeoRouteModel.fromJson(Map<String, dynamic> json) => GeoRouteModel(
        route: json["route"] == null ? null : GeoRoute.fromJson(json["route"]),
      );

  Map<String, dynamic> toJson() => {
        "route": route?.toJson(),
      };
}

class GeoRoute {
  GeoGeometry? geometry;
  List<GeoLeg>? legs;
  String? weightName;
  double? weight;
  double? duration;
  double? distance;

  String get distanceInKilometers => ((distance ?? 0) / 1000).toStringAsFixed(1);
  String get durationInMinutes => ((duration ?? 0) / 60).toStringAsFixed(0);

  GeoRoute({
    this.geometry,
    this.legs,
    this.weightName,
    this.weight,
    this.duration,
    this.distance,
  });

  GeoRoute copyWith({
    GeoGeometry? geometry,
    List<GeoLeg>? legs,
    String? weightName,
    double? weight,
    double? duration,
    double? distance,
  }) =>
      GeoRoute(
        geometry: geometry ?? this.geometry,
        legs: legs ?? this.legs,
        weightName: weightName ?? this.weightName,
        weight: weight ?? this.weight,
        duration: duration ?? this.duration,
        distance: distance ?? this.distance,
      );

  factory GeoRoute.fromJson(Map<String, dynamic> json) => GeoRoute(
        geometry: json["geometry"] == null ? null : GeoGeometry.fromJson(json["geometry"]),
        legs: json["legs"] == null ? [] : List<GeoLeg>.from(json["legs"]!.map((x) => GeoLeg.fromJson(x))),
        weightName: json["weight_name"],
        weight: json["weight"]?.toDouble(),
        duration: json["duration"]?.toDouble(),
        distance: json["distance"],
      );

  Map<String, dynamic> toJson() => {
        "geometry": geometry?.toJson(),
        "legs": legs == null ? [] : List<dynamic>.from(legs!.map((x) => x.toJson())),
        "weight_name": weightName,
        "weight": weight,
        "duration": duration,
        "distance": distance,
      };
}

class GeoGeometry {
  List<List<double>>? coordinates;
  String? type;

  GeoGeometry({
    this.coordinates,
    this.type,
  });

  List<LatLng>? get latLngList => coordinates?.map((coord) => LatLng(coord[1], coord[0])).toList();

  GeoGeometry copyWith({
    List<List<double>>? coordinates,
    String? type,
  }) =>
      GeoGeometry(
        coordinates: coordinates ?? this.coordinates,
        type: type ?? this.type,
      );

  factory GeoGeometry.fromJson(Map<String, dynamic> json) => GeoGeometry(
        coordinates: json["coordinates"] == null
            ? []
            : List<List<double>>.from(json["coordinates"]!.map((x) => List<double>.from(x.map((x) => x?.toDouble())))),
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "coordinates":
            coordinates == null ? [] : List<dynamic>.from(coordinates!.map((x) => List<dynamic>.from(x.map((x) => x)))),
        "type": type,
      };
}

class GeoLeg {
  List<dynamic>? steps;
  String? summary;
  double? weight;
  double? duration;
  double? distance;

  GeoLeg({
    this.steps,
    this.summary,
    this.weight,
    this.duration,
    this.distance,
  });

  GeoLeg copyWith({
    List<dynamic>? steps,
    String? summary,
    double? weight,
    double? duration,
    double? distance,
  }) =>
      GeoLeg(
        steps: steps ?? this.steps,
        summary: summary ?? this.summary,
        weight: weight ?? this.weight,
        duration: duration ?? this.duration,
        distance: distance ?? this.distance,
      );

  factory GeoLeg.fromJson(Map<String, dynamic> json) => GeoLeg(
        steps: json["steps"] == null ? [] : List<dynamic>.from(json["steps"]!.map((x) => x)),
        summary: json["summary"],
        weight: json["weight"]?.toDouble(),
        duration: json["duration"]?.toDouble(),
        distance: json["distance"],
      );

  Map<String, dynamic> toJson() => {
        "steps": steps == null ? [] : List<dynamic>.from(steps!.map((x) => x)),
        "summary": summary,
        "weight": weight,
        "duration": duration,
        "distance": distance,
      };
}
