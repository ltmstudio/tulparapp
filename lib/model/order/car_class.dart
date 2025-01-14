// To parse this JSON data, do
//
//     final carClassModel = carClassModelFromJson(jsonString);

import 'dart:convert';

List<CarClassModel> carClassModelFromJson(String str) =>
    List<CarClassModel>.from(json.decode(str).map((x) => CarClassModel.fromJson(x)));

String carClassModelToJson(List<CarClassModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CarClassModel {
  int? id;
  String? name;
  String? image;
  int? cost;
  int? priority;
  DateTime? createdAt;
  DateTime? updatedAt;

  CarClassModel({
    this.id,
    this.name,
    this.image,
    this.cost,
    this.priority,
    this.createdAt,
    this.updatedAt,
  });

  CarClassModel copyWith({
    int? id,
    String? name,
    String? image,
    int? cost,
    int? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      CarClassModel(
        id: id ?? this.id,
        name: name ?? this.name,
        image: image ?? this.image,
        cost: cost ?? this.cost,
        priority: priority ?? this.priority,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory CarClassModel.fromJson(Map<String, dynamic> json) => CarClassModel(
        id: json["id"],
        name: json["name"],
        image: json["image"],
        cost: json["cost"],
        priority: json["priority"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "cost": cost,
        "priority": priority,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
