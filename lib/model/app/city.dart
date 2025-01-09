// To parse this JSON data, do
//
//     final cityModel = cityModelFromJson(jsonString);

import 'dart:convert';

List<CityModel> cityModelFromJson(String str) =>
    List<CityModel>.from(json.decode(str).map((x) => CityModel.fromJson(x)));

String cityModelToJson(List<CityModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CityModel {
  int? id;
  String? name;

  CityModel({
    this.id,
    this.name,
  });

  CityModel copyWith({
    int? id,
    String? name,
  }) =>
      CityModel(
        id: id ?? this.id,
        name: name ?? this.name,
      );

  factory CityModel.fromJson(Map<String, dynamic> json) => CityModel(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
