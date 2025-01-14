// To parse this JSON data, do
//
//     final addressModel = addressModelFromJson(jsonString);

import 'dart:convert';

import 'package:latlong2/latlong.dart';

List<AddressModel> addressModelFromJson(String str) =>
    List<AddressModel>.from(json.decode(str).map((x) => AddressModel.fromJson(x)));

String addressModelToJson(List<AddressModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AddressModel {
  int? id;
  int? userId;
  String? address;
  String? geo;

  LatLng? get latLng {
    if (geo == null) return null;
    var splitted = geo!.split(",");
    if (splitted.length != 2) return null;
    var lat = double.tryParse(splitted[0]);
    var lng = double.tryParse(splitted[1]);
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  AddressModel({
    this.id,
    this.userId,
    this.address,
    this.geo,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        id: json["id"],
        userId: json["user_id"],
        address: json["address"],
        geo: json["geo"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "address": address,
        "geo": geo,
      };
}
