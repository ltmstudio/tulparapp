// To parse this JSON data, do
//
//     final orderTypeModel = orderTypeModelFromJson(jsonString);

import 'dart:convert';

List<OrderTypeModel> orderTypeModelFromJson(String str) =>
    List<OrderTypeModel>.from(json.decode(str).map((x) => OrderTypeModel.fromJson(x)));

String orderTypeModelToJson(List<OrderTypeModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class OrderTypeModel {
  int? id;
  String? name;

  OrderTypeModel({
    this.id,
    this.name,
  });

  OrderTypeModel copyWith({
    int? id,
    String? name,
  }) =>
      OrderTypeModel(
        id: id ?? this.id,
        name: name ?? this.name,
      );

  factory OrderTypeModel.fromJson(Map<String, dynamic> json) => OrderTypeModel(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
