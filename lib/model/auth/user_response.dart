// To parse this JSON data, do
//
//     final userResponseModel = userResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:tulpar/model/auth/user.dart';

UserResponseModel userResponseModelFromJson(String str) => UserResponseModel.fromJson(json.decode(str));

String userResponseModelToJson(UserResponseModel data) => json.encode(data.toJson());

class UserResponseModel {
  bool? success;
  String? message;
  UserModel? data;

  UserResponseModel({
    this.success,
    this.message,
    this.data,
  });

  UserResponseModel copyWith({
    bool? success,
    String? message,
    UserModel? data,
  }) =>
      UserResponseModel(
        success: success ?? this.success,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory UserResponseModel.fromJson(Map<String, dynamic> json) => UserResponseModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : UserModel.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };
}
