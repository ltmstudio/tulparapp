// To parse this JSON data, do
//
//     final catalogCarModel = catalogCarModelFromJson(jsonString);

import 'dart:convert';

import 'package:tulpar/model/cars/model.dart';

List<CatalogCarModel> catalogCarModelFromJson(String str) =>
    List<CatalogCarModel>.from(json.decode(str).map((x) => CatalogCarModel.fromJson(x)));

String catalogCarModelToJson(List<CatalogCarModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CatalogCarModel {
  String? id;
  String? name;
  String? cyrillicName;
  int? popular;
  String? country;
  String? image;
  List<CatalogCarModelModel>? models;

  CatalogCarModel({
    this.id,
    this.name,
    this.cyrillicName,
    this.popular,
    this.country,
    this.image,
    this.models,
  });

  CatalogCarModel copyWith({
    String? id,
    String? name,
    String? cyrillicName,
    int? popular,
    String? country,
    String? image,
    List<CatalogCarModelModel>? models,
  }) =>
      CatalogCarModel(
        id: id ?? this.id,
        name: name ?? this.name,
        cyrillicName: cyrillicName ?? this.cyrillicName,
        popular: popular ?? this.popular,
        country: country ?? this.country,
        image: image ?? this.image,
        models: models ?? this.models,
      );

  factory CatalogCarModel.fromJson(Map<String, dynamic> json) => CatalogCarModel(
        id: json["id"],
        name: json["name"],
        cyrillicName: json["cyrillic-name"],
        popular: json["popular"],
        country: json["country"],
        image: json["image"],
        models: json["models"] == null
            ? []
            : List<CatalogCarModelModel>.from(json["models"].map((x) => CatalogCarModelModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "cyrillic-name": cyrillicName,
        "popular": popular,
        "country": country,
        "image": image,
        "models": List<dynamic>.from(models!.map((x) => x.toJson())),
      };
}
