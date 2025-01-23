// To parse this JSON data, do
//
//     final availableShiftsResponseModel = availableShiftsResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:tulpar/model/driver/level.dart';
import 'package:tulpar/model/driver/shift.dart';

AvailableShiftsResponseModel availableShiftsResponseModelFromJson(String str) =>
    AvailableShiftsResponseModel.fromJson(json.decode(str));

String availableShiftsResponseModelToJson(AvailableShiftsResponseModel data) => json.encode(data.toJson());

class AvailableShiftsResponseModel {
  List<ShiftPriceModel>? shifts;
  DriverLevelModel? level;
  int? classId;

  AvailableShiftsResponseModel({
    this.shifts,
    this.level,
    this.classId,
  });

  AvailableShiftsResponseModel copyWith({
    List<ShiftPriceModel>? shifts,
    DriverLevelModel? level,
    int? classId,
  }) =>
      AvailableShiftsResponseModel(
        shifts: shifts ?? this.shifts,
        level: level ?? this.level,
        classId: classId ?? this.classId,
      );

  factory AvailableShiftsResponseModel.fromJson(Map<String, dynamic> json) => AvailableShiftsResponseModel(
        shifts: json["shifts"] == null
            ? []
            : List<ShiftPriceModel>.from(json["shifts"]!.map((x) => ShiftPriceModel.fromJson(x))),
        level: json["level"] == null ? null : DriverLevelModel.fromJson(json["level"]),
        classId: json["class_id"],
      );

  Map<String, dynamic> toJson() => {
        "shifts": shifts == null ? [] : List<dynamic>.from(shifts!.map((x) => x.toJson())),
        "level": level?.toJson(),
        "class_id": classId,
      };
}
