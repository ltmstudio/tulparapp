// To parse this JSON data, do
//
//     final payInfoModel = payInfoModelFromJson(jsonString);

import 'dart:convert';

PayInfoModel payInfoModelFromJson(String str) => PayInfoModel.fromJson(json.decode(str));

String payInfoModelToJson(PayInfoModel data) => json.encode(data.toJson());

class PayInfoModel {
  String? payLink;
  String? payQrImage;

  PayInfoModel({
    this.payLink,
    this.payQrImage,
  });

  PayInfoModel copyWith({
    String? payLink,
    String? payQrImage,
  }) =>
      PayInfoModel(
        payLink: payLink ?? this.payLink,
        payQrImage: payQrImage ?? this.payQrImage,
      );

  factory PayInfoModel.fromJson(Map<String, dynamic> json) => PayInfoModel(
        payLink: json["pay_link"],
        payQrImage: json["pay_qr_image"],
      );

  Map<String, dynamic> toJson() => {
        "pay_link": payLink,
        "pay_qr_image": payQrImage,
      };
}
