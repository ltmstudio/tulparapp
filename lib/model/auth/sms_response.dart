// To parse this JSON data, do
//
//     final smsResponseModel = smsResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:tulpar/model/auth/user.dart';

SmsResponseModel smsResponseModelFromJson(String str) => SmsResponseModel.fromJson(json.decode(str));

String smsResponseModelToJson(SmsResponseModel data) => json.encode(data.toJson());

class SmsResponseModel {
  bool? success;
  String? message;
  SmsResponseData? data;

  SmsResponseModel({
    this.success,
    this.message,
    this.data,
  });

  SmsResponseModel copyWith({
    bool? success,
    String? message,
    SmsResponseData? data,
  }) =>
      SmsResponseModel(
        success: success ?? this.success,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory SmsResponseModel.fromJson(Map<String, dynamic> json) => SmsResponseModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : SmsResponseData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };
}

class SmsResponseData {
  String? token;
  UserModel? profile;

  SmsResponseData({
    this.token,
    this.profile,
  });

  SmsResponseData copyWith({
    String? token,
    UserModel? profile,
  }) =>
      SmsResponseData(
        token: token ?? this.token,
        profile: profile ?? this.profile,
      );

  factory SmsResponseData.fromJson(Map<String, dynamic> json) => SmsResponseData(
        token: json["token"],
        profile: json["profile"] == null ? null : UserModel.fromJson(json["profile"]),
      );

  Map<String, dynamic> toJson() => {
        "token": token,
        "profile": profile?.toJson(),
      };
}
