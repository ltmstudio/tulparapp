// To parse this JSON data, do
//
//     final driverProfileModel = driverProfileModelFromJson(jsonString);

import 'dart:convert';

import 'package:tulpar/core/env.dart';
import 'package:tulpar/model/driver/level.dart';
import 'package:tulpar/model/order/car_class.dart';

DriverProfileModel driverProfileModelFromJson(String str) => DriverProfileModel.fromJson(json.decode(str));

String driverProfileModelToJson(DriverProfileModel data) => json.encode(data.toJson());

class DriverProfileModel {
  int? id;
  String? phone;
  String? name;
  String? lastname;
  String? avatar;
  String? carName;
  String? carNumber;
  int? people;
  int? classId;
  int? delivery;
  int? cargo;
  int? balance;
  int? status;
  String? carImage1;
  String? carImage2;
  String? carImage3;
  dynamic carImage4;
  CarClassModel? carClass;
  DriverLevelModel? level;

  String get avatarUrl => avatar == null ? '' : "${CoreEnvironment.appUrl}/storage/$avatar";

  DriverProfileModel({
    this.id,
    this.phone,
    this.name,
    this.lastname,
    this.avatar,
    this.carName,
    this.carNumber,
    this.people,
    this.classId,
    this.delivery,
    this.cargo,
    this.balance,
    this.status,
    this.carImage1,
    this.carImage2,
    this.carImage3,
    this.carImage4,
    this.carClass,
    this.level,
  });

  DriverProfileModel copyWith({
    int? id,
    String? phone,
    String? name,
    String? lastname,
    String? avatar,
    String? carName,
    String? carNumber,
    int? people,
    int? classId,
    int? delivery,
    int? cargo,
    int? balance,
    int? status,
    String? carImage1,
    String? carImage2,
    String? carImage3,
    dynamic carImage4,
    CarClassModel? carClass,
    DriverLevelModel? level,
  }) =>
      DriverProfileModel(
        id: id ?? this.id,
        phone: phone ?? this.phone,
        name: name ?? this.name,
        lastname: lastname ?? this.lastname,
        avatar: avatar ?? this.avatar,
        carName: carName ?? this.carName,
        carNumber: carNumber ?? this.carNumber,
        people: people ?? this.people,
        classId: classId ?? this.classId,
        delivery: delivery ?? this.delivery,
        cargo: cargo ?? this.cargo,
        balance: balance ?? this.balance,
        status: status ?? this.status,
        carImage1: carImage1 ?? this.carImage1,
        carImage2: carImage2 ?? this.carImage2,
        carImage3: carImage3 ?? this.carImage3,
        carImage4: carImage4 ?? this.carImage4,
        carClass: carClass ?? this.carClass,
        level: level ?? this.level,
      );

  String get fullname => "${name ?? ''} ${lastname ?? ''}";

  factory DriverProfileModel.fromJson(Map<String, dynamic> json) => DriverProfileModel(
        id: json["id"],
        phone: json["phone"],
        name: json["name"],
        lastname: json["lastname"],
        avatar: json["avatar"],
        carName: json["car_name"],
        carNumber: json["car_number"],
        people: json["people"],
        classId: json["class_id"],
        delivery: json["delivery"],
        cargo: json["cargo"],
        balance: json["balance"],
        status: json["status"],
        carImage1: json["car_image_1"],
        carImage2: json["car_image_2"],
        carImage3: json["car_image_3"],
        carImage4: json["car_image_4"],
        carClass: json["class"] == null ? null : CarClassModel.fromJson(json["class"]),
        level: json["level"] == null ? null : DriverLevelModel.fromJson(json["level"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "phone": phone,
        "name": name,
        "lastname": lastname,
        "avatar": avatar,
        "car_name": carName,
        "car_number": carNumber,
        "people": people,
        "class_id": classId,
        "delivery": delivery,
        "cargo": cargo,
        "balance": balance,
        "status": status,
        "car_image_1": carImage1,
        "car_image_2": carImage2,
        "car_image_3": carImage3,
        "car_image_4": carImage4,
        "class": carClass?.toJson(),
        "level": level?.toJson(),
      };
}
