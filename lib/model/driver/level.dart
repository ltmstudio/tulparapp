import 'package:flutter/material.dart';
import 'package:tulpar/core/colors.dart';

class DriverLevelModel {
  int? id;
  String? name;
  int? count;
  String? color;
  DateTime? createdAt;
  DateTime? updatedAt;

  Color get colorValue {
    if (color == null || color!.isEmpty) {
      return CoreColors.primary;
    }
    return Color(int.parse(color!, radix: 16) + 0xFF000000);
  }

  DriverLevelModel({
    this.id,
    this.name,
    this.count,
    this.color,
    this.createdAt,
    this.updatedAt,
  });

  DriverLevelModel copyWith({
    int? id,
    String? name,
    int? count,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      DriverLevelModel(
        id: id ?? this.id,
        name: name ?? this.name,
        count: count ?? this.count,
        color: color ?? this.color,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory DriverLevelModel.fromJson(Map<String, dynamic> json) => DriverLevelModel(
        id: json["id"],
        name: json["name"],
        count: json["count"],
        color: json["color"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "count": count,
        "color": color,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
