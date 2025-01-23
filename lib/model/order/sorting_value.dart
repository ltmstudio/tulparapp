// To parse this JSON data, do
//
//     final sortingValueModel = sortingValueModelFromJson(jsonString);

import 'dart:convert';

List<OrdersSortingValueModel> sortingValueModelFromJson(String str) =>
    List<OrdersSortingValueModel>.from(json.decode(str).map((x) => OrdersSortingValueModel.fromJson(x)));

String sortingValueModelToJson(List<OrdersSortingValueModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class OrdersSortingValueModel {
  String? name;
  String? value;
  String? direction;

  OrdersSortingValueModel({
    this.name,
    this.value,
    this.direction,
  });

  OrdersSortingValueModel copyWith({
    String? name,
    String? value,
    String? direction,
  }) =>
      OrdersSortingValueModel(
        name: name ?? this.name,
        value: value ?? this.value,
        direction: direction ?? this.direction,
      );

  factory OrdersSortingValueModel.fromJson(Map<String, dynamic> json) => OrdersSortingValueModel(
        name: json["name"],
        value: json["value"],
        direction: json["direction"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "value": value,
        "direction": direction,
      };

  static List<OrdersSortingValueModel> initialValues = [
    // OrdersSortingValueModel(name: 'Сначала по близости', value: 'near', direction: 'asc'),
    OrdersSortingValueModel(name: 'Сначала новые', value: 'created_at', direction: 'desc'),
    OrdersSortingValueModel(name: 'Сначала дорогие', value: 'user_cost', direction: 'desc')
  ];
}
