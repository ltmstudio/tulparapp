// To parse this JSON data, do
//
//     final catalogCarModelModel = catalogCarModelModelFromJson(jsonString);

import 'dart:convert';

List<CatalogCarModelModel> catalogCarModelModelFromJson(String str) =>
    List<CatalogCarModelModel>.from(json.decode(str).map((x) => CatalogCarModelModel.fromJson(x)));

String catalogCarModelModelToJson(List<CatalogCarModelModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CatalogCarModelModel {
  String? id;
  String? carId;
  String? name;
  String? cyrillicName;
  int? yearFrom;
  int? yearTo;
  String? mClass;

  CatalogCarModelModel({
    this.id,
    this.carId,
    this.name,
    this.cyrillicName,
    this.yearFrom,
    this.yearTo,
    this.mClass,
  });

  CatalogCarModelModel copyWith({
    String? id,
    String? carId,
    String? name,
    String? cyrillicName,
    int? yearFrom,
    int? yearTo,
    String? mClass,
  }) =>
      CatalogCarModelModel(
        id: id ?? this.id,
        carId: carId ?? this.carId,
        name: name ?? this.name,
        cyrillicName: cyrillicName ?? this.cyrillicName,
        yearFrom: yearFrom ?? this.yearFrom,
        yearTo: yearTo ?? this.yearTo,
        mClass: mClass ?? this.mClass,
      );

  factory CatalogCarModelModel.fromJson(Map<String, dynamic> json) => CatalogCarModelModel(
        id: json["id"],
        carId: json["car_id"],
        name: json["name"],
        cyrillicName: json["cyrillic-name"],
        yearFrom: json["year-from"],
        yearTo: json["year-to"],
        mClass: json["class"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "car_id": carId,
        "name": name,
        "cyrillic-name": cyrillicName,
        "year-from": yearFrom,
        "year-to": yearTo,
        "class": mClass,
      };
}
