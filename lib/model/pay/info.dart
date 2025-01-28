// To parse this JSON data, do
//
//     final payInfoModel = payInfoModelFromJson(jsonString);

import 'dart:convert';

PayInfoModel payInfoModelFromJson(String str) => PayInfoModel.fromJson(json.decode(str));

String payInfoModelToJson(PayInfoModel data) => json.encode(data.toJson());

class PayInfoModel {
  String? payLink;
  String? payQrImage;
  String? payQrPhone;

  PayInfoModel({
    this.payLink,
    this.payQrImage,
    this.payQrPhone,
  });

  PayInfoModel copyWith({
    String? payLink,
    String? payQrImage,
    String? payQrPhone,
  }) =>
      PayInfoModel(
        payLink: payLink ?? this.payLink,
        payQrImage: payQrImage ?? this.payQrImage,
        payQrPhone: payQrPhone ?? this.payQrPhone,
      );

  factory PayInfoModel.fromJson(Map<String, dynamic> json) => PayInfoModel(
        payLink: json["pay_link"],
        payQrImage: json["pay_qr_image"],
        payQrPhone: json["pay_qr_phone"],
      );

  Map<String, dynamic> toJson() => {
        "pay_link": payLink,
        "pay_qr_image": payQrImage,
        "pay_qr_phone": payQrPhone,
      };
}
