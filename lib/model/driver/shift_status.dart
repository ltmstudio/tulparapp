// Ни разу не активировал смену или нет активной смены
// {
//     "now": 1737652310073,
//     "max": null,
//     "diff_sec": 0,
//     "left": "00:00:00"
// }

// Активная смена
// {
//     "now": 1737652713834,
//     "max": 1737656227442,
//     "diff_sec": 3514,
//     "left": "00:58:34"
// }

// To parse this JSON data, do
//
//     final shiftStatusModel = shiftStatusModelFromJson(jsonString);

import 'dart:convert';

import 'package:get/get.dart';
import 'package:tulpar/controller/driver_shift.dart';

ShiftStatusModel shiftStatusModelFromJson(String str) => ShiftStatusModel.fromJson(json.decode(str));

String shiftStatusModelToJson(ShiftStatusModel data) => json.encode(data.toJson());

class ShiftStatusModel {
  int? now;
  int? max;
  int? diffSec;
  String? left;

  ShiftStatusModel({
    this.now,
    this.max,
    this.diffSec,
    this.left,
  });

  bool get isActive => max != null && now != null && diffSec != null && diffSec! > 0 && now! < max!;

  void decreaseLeftByOneSecond() {
    if (left != null) {
      List<String> parts = left!.split(':');
      int? hours = int.tryParse(parts[0]);
      int? minutes = int.tryParse(parts[1]);
      int? seconds = int.tryParse(parts[2]);
      if (hours == null || minutes == null || seconds == null) {
        return;
      }
      if (hours == 0 && minutes == 0 && seconds == 0) {
        Get.find<DriverShiftController>()
          ..shiftStatus.value = null
          ..update();
        return;
      }

      Duration duration = Duration(hours: hours, minutes: minutes, seconds: seconds);
      duration -= const Duration(seconds: 1);
      left = duration.toString().split('.').first.padLeft(8, "0");
    }
  }

  ShiftStatusModel copyWith({
    int? now,
    int? max,
    int? diffSec,
    String? left,
  }) =>
      ShiftStatusModel(
        now: now ?? this.now,
        max: max ?? this.max,
        diffSec: diffSec ?? this.diffSec,
        left: left ?? this.left,
      );

  factory ShiftStatusModel.fromJson(Map<String, dynamic> json) => ShiftStatusModel(
        now: json["now"],
        max: json["max"],
        diffSec: json["diff_sec"],
        left: json["left"],
      );

  Map<String, dynamic> toJson() => {
        "now": now,
        "max": max,
        "diff_sec": diffSec,
        "left": left,
      };
}
