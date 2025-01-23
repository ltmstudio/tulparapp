// To parse this JSON data, do
//
//     final shiftOrderResponseModel = shiftOrderResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:tulpar/model/driver/shift_order.dart';

ShiftOrderResponseModel shiftOrderResponseModelFromJson(String str) =>
    ShiftOrderResponseModel.fromJson(json.decode(str));

String shiftOrderResponseModelToJson(ShiftOrderResponseModel data) => json.encode(data.toJson());

class ShiftOrderResponseModel {
  bool? success;
  String? message;
  ShiftOrderModel? data;

  ShiftOrderResponseModel({
    this.success,
    this.message,
    this.data,
  });

  ShiftOrderResponseModel copyWith({
    bool? success,
    String? message,
    ShiftOrderModel? data,
  }) =>
      ShiftOrderResponseModel(
        success: success ?? this.success,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory ShiftOrderResponseModel.fromJson(Map<String, dynamic> json) => ShiftOrderResponseModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : ShiftOrderModel.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };
}
