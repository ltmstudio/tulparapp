// To parse this JSON data, do
//
//     final orderModel = orderModelFromJson(jsonString);

import 'dart:convert';

import 'package:get/get.dart';
import 'package:tulpar/controller/user_order.dart';

List<OrderModel> orderModelFromJson(String str) =>
    List<OrderModel>.from(json.decode(str).map((x) => OrderModel.fromJson(x)));

String orderModelToJson(List<OrderModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class OrderModel {
  int? id;
  String? phone;
  int? typeId;
  int? classId;
  int? userId;
  int? driverId;
  int? userCost;
  String? userTime;
  int? people;
  String? userComment;
  String? driverComment;
  String? pointA;
  String? pointB;
  String? geoA;
  String? geoB;
  int? cityAId;
  int? cityBId;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? status;

  String? get type {
    var ordertypes = Get.find<UserOrderController>().orderTypes.value;
    return ordertypes.firstWhereOrNull((o) => o.id == typeId)?.name;
  }

  OrderModel({
    this.id,
    this.phone,
    this.typeId,
    this.classId,
    this.userId,
    this.driverId,
    this.userCost,
    this.userTime,
    this.people,
    this.userComment,
    this.driverComment,
    this.pointA,
    this.pointB,
    this.geoA,
    this.geoB,
    this.cityAId,
    this.cityBId,
    this.createdAt,
    this.updatedAt,
    this.status,
  });

  OrderModel copyWith({
    int? id,
    String? phone,
    int? typeId,
    int? classId,
    int? userId,
    int? driverId,
    int? userCost,
    String? userTime,
    int? people,
    String? userComment,
    String? driverComment,
    String? pointA,
    String? pointB,
    String? geoA,
    String? geoB,
    int? cityAId,
    int? cityBId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
  }) =>
      OrderModel(
        id: id ?? this.id,
        phone: phone ?? this.phone,
        typeId: typeId ?? this.typeId,
        classId: classId ?? this.classId,
        userId: userId ?? this.userId,
        driverId: driverId ?? this.driverId,
        userCost: userCost ?? this.userCost,
        userTime: userTime ?? this.userTime,
        people: people ?? this.people,
        userComment: userComment ?? this.userComment,
        driverComment: driverComment ?? this.driverComment,
        pointA: pointA ?? this.pointA,
        pointB: pointB ?? this.pointB,
        geoA: geoA ?? this.geoA,
        geoB: geoB ?? this.geoB,
        cityAId: cityAId ?? this.cityAId,
        cityBId: cityBId ?? this.cityBId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        status: status ?? this.status,
      );

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json["id"],
        phone: json["phone"],
        typeId: json["type_id"],
        classId: json["class_id"],
        userId: json["user_id"],
        driverId: json["driver_id"],
        userCost: json["user_cost"],
        userTime: json["user_time"],
        people: json["people"],
        userComment: json["user_comment"],
        driverComment: json["driver_comment"],
        pointA: json["point_a"],
        pointB: json["point_b"],
        geoA: json["geo_a"],
        geoB: json["geo_b"],
        cityAId: json["city_a_id"],
        cityBId: json["city_b_id"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "phone": phone,
        "type_id": typeId,
        "class_id": classId,
        "user_id": userId,
        "driver_id": driverId,
        "user_cost": userCost,
        "user_time": userTime,
        "people": people,
        "user_comment": userComment,
        "driver_comment": driverComment,
        "point_a": pointA,
        "point_b": pointB,
        "geo_a": geoA,
        "geo_b": geoB,
        "city_a_id": cityAId,
        "city_b_id": cityBId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "status": status,
      };

  Map<String, dynamic> toCreateForm() {
    Map<String, dynamic> form = {
      "type_id": typeId,
      "class_id": classId,
      "user_cost": userCost,
      "user_time": userTime,
      "people": people,
      "user_comment": userComment,
      "point_a": pointA,
      "point_b": pointB,
      "geo_a": geoA,
      "geo_b": geoB,
      "city_a_id": cityAId,
      "city_b_id": cityBId
    };
    form.removeWhere((key, value) => value == null);
    return form;
  }
}
