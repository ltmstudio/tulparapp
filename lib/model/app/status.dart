// To parse this JSON data, do
//
//     final appStatusModel = appStatusModelFromJson(jsonString);

import 'dart:convert';

import 'package:tulpar/model/app/city.dart';
import 'package:tulpar/model/order/type.dart';

AppStatusModel appStatusModelFromJson(String str) => AppStatusModel.fromJson(json.decode(str));

String appStatusModelToJson(AppStatusModel data) => json.encode(data.toJson());

class AppStatusModel {
  bool? success;
  String? appVersion;
  List<CityModel>? cities;
  List<OrderTypeModel>? orderTypes;

  AppStatusModel({
    this.success,
    this.appVersion,
    this.cities,
    this.orderTypes,
  });

  AppStatusModel copyWith({
    bool? success,
    String? appVersion,
    List<CityModel>? cities,
    List<OrderTypeModel>? orderTypes,
  }) =>
      AppStatusModel(
        success: success ?? this.success,
        appVersion: appVersion ?? this.appVersion,
        cities: cities ?? this.cities,
        orderTypes: orderTypes ?? this.orderTypes,
      );

  factory AppStatusModel.fromJson(Map<String, dynamic> json) => AppStatusModel(
        success: json["success"],
        appVersion: json["appVersion"],
        cities: json["cities"] == null ? [] : List<CityModel>.from(json["cities"]!.map((x) => CityModel.fromJson(x))),
        orderTypes: json["orderTypes"] == null
            ? []
            : List<OrderTypeModel>.from(json["orderTypes"]!.map((x) => OrderTypeModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "appVersion": appVersion,
        "cities": cities == null ? [] : List<dynamic>.from(cities!.map((x) => x.toJson())),
        "orderTypes": orderTypes == null ? [] : List<dynamic>.from(orderTypes!.map((x) => x.toJson())),
      };
}
