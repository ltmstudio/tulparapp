// To parse this JSON data, do
//
//     final shiftOrderModel = shiftOrderModelFromJson(jsonString);

import 'dart:convert';

import 'package:intl/intl.dart';

List<ShiftOrderModel> shiftOrderModelFromJson(String str) =>
    List<ShiftOrderModel>.from(json.decode(str).map((x) => ShiftOrderModel.fromJson(x)));

String shiftOrderModelToJson(List<ShiftOrderModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ShiftOrderModel {
  int? id;
  int? driverId;
  int? classId;
  int? hours;
  String? hoursState;
  String? levelName;
  int? price;
  int? endtime;
  DateTime? createdAt;
  DateTime? updatedAt;

  String get title => '$hours $hoursState';
  String get subtitle => '$price ₸';
  String get formattedCreated => createdAt != null ? DateFormat('dd MMM HH:mm', 'ru').format(createdAt!) : '';

  ShiftOrderModel({
    this.id,
    this.driverId,
    this.classId,
    this.hours,
    this.hoursState,
    this.levelName,
    this.price,
    this.endtime,
    this.createdAt,
    this.updatedAt,
  });

  ShiftOrderModel copyWith({
    int? id,
    int? driverId,
    int? classId,
    int? hours,
    String? hoursState,
    String? levelName,
    int? price,
    int? endtime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      ShiftOrderModel(
        id: id ?? this.id,
        driverId: driverId ?? this.driverId,
        classId: classId ?? this.classId,
        hours: hours ?? this.hours,
        hoursState: hoursState ?? this.hoursState,
        levelName: levelName ?? this.levelName,
        price: price ?? this.price,
        endtime: endtime ?? this.endtime,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory ShiftOrderModel.fromJson(Map<String, dynamic> json) => ShiftOrderModel(
        id: json["id"],
        driverId: json["driver_id"],
        classId: json["class_id"],
        hours: json["hours"],
        hoursState: json["hours_state"],
        levelName: json["level_name"],
        price: json["price"],
        endtime: json["endtime"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "driver_id": driverId,
        "class_id": classId,
        "hours": hours,
        "hours_state": hoursState,
        "level_name": levelName,
        "price": price,
        "endtime": endtime,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
