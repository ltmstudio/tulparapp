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
  // String? left;
  // String? totalLeft;

  ShiftStatusModel({
    this.now,
    this.max,
    this.diffSec,
    // this.left,
  });

  bool get isActive => max != null && now != null && diffSec != null && diffSec! > 0 && now! < max!;

  String get left {
    if (diffSec != null && diffSec! > 0) {
      Duration duration = Duration(seconds: diffSec!);
      if (duration.inDays > 0) {
        var hours = duration.inHours % 24;
        var minutes = duration.inMinutes % 60;
        var seconds = duration.inSeconds % 60;
        return '${duration.inDays}d ${hours.toString().padLeft(2, "0")}:${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}';
      }
      return duration.toString().split('.').first.padLeft(8, "0");
    } else {
      return '00:00:00';
    }
  }

  void decreaseLeftByOneSecond() {
    if (diffSec != null && diffSec! > 0) {
      diffSec = diffSec! - 1;
    } else {
      Get.find<DriverShiftController>()
        ..shiftStatus.value = null
        ..update();
      return;
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
        // left: left ?? this.left,
      );

  factory ShiftStatusModel.fromJson(Map<String, dynamic> json) => ShiftStatusModel(
        now: json["now"],
        max: json["max"],
        diffSec: json["diff_sec"],
        // left: json["left"],
      );

  Map<String, dynamic> toJson() => {
        "now": now,
        "max": max,
        "diff_sec": diffSec,
        // "left": left,
      };
}
