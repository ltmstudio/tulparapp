// To parse this JSON data, do
//
//     final phoneResponseModel = phoneResponseModelFromJson(jsonString);

import 'dart:convert';

PhoneResponseModel phoneResponseModelFromJson(String str) => PhoneResponseModel.fromJson(json.decode(str));

String phoneResponseModelToJson(PhoneResponseModel data) => json.encode(data.toJson());

class PhoneResponseModel {
  bool? success;
  String? message;
  PhoneResponseData? data;

  PhoneResponseModel({
    this.success,
    this.message,
    this.data,
  });

  PhoneResponseModel copyWith({
    bool? success,
    String? message,
    PhoneResponseData? data,
  }) =>
      PhoneResponseModel(
        success: success ?? this.success,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory PhoneResponseModel.fromJson(Map<String, dynamic> json) => PhoneResponseModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : PhoneResponseData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };
}

class PhoneResponseData {
  String? salt;
  int? sms;

  PhoneResponseData({
    this.salt,
    this.sms,
  });

  PhoneResponseData copyWith({
    String? salt,
    int? sms,
  }) =>
      PhoneResponseData(
        salt: salt ?? this.salt,
        sms: sms ?? this.sms,
      );

  factory PhoneResponseData.fromJson(Map<String, dynamic> json) => PhoneResponseData(
        salt: json["salt"],
        sms: json["sms"],
      );

  Map<String, dynamic> toJson() => {
        "salt": salt,
        "sms": sms,
      };
}
