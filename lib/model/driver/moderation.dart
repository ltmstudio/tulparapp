// To parse this JSON data, do
//
//     final driverModerationModel = driverModerationModelFromJson(jsonString);

import 'dart:convert';

DriverModerationModel driverModerationModelFromJson(String str) => DriverModerationModel.fromJson(json.decode(str));

String driverModerationModelToJson(DriverModerationModel data) => json.encode(data.toJson());

class DriverModerationStatus {
  //preparation, moderation, approved, rejected
  static const String preparation = 'preparation';
  static const String moderation = 'moderation';
  static const String approved = 'approved';
  static const String rejected = 'rejected';
}

class DriverModerationModel {
  int? id;
  int? userId;
  String? name;
  String? lastname;
  DateTime? birthdate;
  String? carId;
  String? carModelId;
  String? carVin;
  int? carYear;
  String? carGosNumber;
  String? carImage1;
  String? carImage2;
  String? carImage3;
  String? carImage4;
  String? driverLicenseNumber;
  String? driverLicenseFront;
  String? driverLicenseBack;
  DateTime? driverLicenseDate;
  String? tsPassportFront;
  String? tsPassportBack;
  String? status;
  String? rejectMessage;
  DateTime? createdAt;
  DateTime? updatedAt;

  DriverModerationModel({
    this.id,
    this.userId,
    this.name,
    this.lastname,
    this.birthdate,
    this.carId,
    this.carModelId,
    this.carVin,
    this.carYear,
    this.carGosNumber,
    this.carImage1,
    this.carImage2,
    this.carImage3,
    this.carImage4,
    this.driverLicenseNumber,
    this.driverLicenseFront,
    this.driverLicenseBack,
    this.driverLicenseDate,
    this.tsPassportFront,
    this.tsPassportBack,
    this.status,
    this.rejectMessage,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, String?> get carImages =>
      {'car_image_1': carImage1, 'car_image_2': carImage2, 'car_image_3': carImage3, 'car_image_4': carImage4};
  Map<String, String?> get driverLicenseImages =>
      {'driver_license_front': driverLicenseFront, 'driver_license_back': driverLicenseBack};
  Map<String, String?> get stoImages => {'ts_passport_front': tsPassportFront, 'ts_passport_back': tsPassportBack};

  DriverModerationModel copyWith({
    int? id,
    int? userId,
    String? name,
    String? lastname,
    DateTime? birthdate,
    String? carId,
    String? carModelId,
    String? carVin,
    int? carYear,
    String? carGosNumber,
    String? carImage1,
    String? carImage2,
    String? carImage3,
    String? carImage4,
    String? driverLicenseNumber,
    String? driverLicenseFront,
    String? driverLicenseBack,
    DateTime? driverLicenseDate,
    String? tsPassportFront,
    String? tsPassportBack,
    String? status,
    String? rejectMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      DriverModerationModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        lastname: lastname ?? this.lastname,
        birthdate: birthdate ?? this.birthdate,
        carId: carId ?? this.carId,
        carModelId: carModelId ?? this.carModelId,
        carVin: carVin ?? this.carVin,
        carYear: carYear ?? this.carYear,
        carGosNumber: carGosNumber ?? this.carGosNumber,
        carImage1: carImage1 ?? this.carImage1,
        carImage2: carImage2 ?? this.carImage2,
        carImage3: carImage3 ?? this.carImage3,
        carImage4: carImage4 ?? this.carImage4,
        driverLicenseNumber: driverLicenseNumber ?? this.driverLicenseNumber,
        driverLicenseFront: driverLicenseFront ?? this.driverLicenseFront,
        driverLicenseBack: driverLicenseBack ?? this.driverLicenseBack,
        driverLicenseDate: driverLicenseDate ?? this.driverLicenseDate,
        tsPassportFront: tsPassportFront ?? this.tsPassportFront,
        tsPassportBack: tsPassportBack ?? this.tsPassportBack,
        status: status ?? this.status,
        rejectMessage: rejectMessage ?? this.rejectMessage,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory DriverModerationModel.fromJson(Map<String, dynamic> json) => DriverModerationModel(
        id: json["id"],
        userId: json["user_id"],
        name: json["name"],
        lastname: json["lastname"],
        birthdate: json["birthdate"] == null ? null : DateTime.parse(json["birthdate"]),
        carId: json["car_id"],
        carModelId: json["car_model_id"],
        carVin: json["car_vin"],
        carYear: json["car_year"] != null ? int.tryParse(json["car_year"].toString()) : null,
        carGosNumber: json["car_gos_number"],
        carImage1: json["car_image_1"],
        carImage2: json["car_image_2"],
        carImage3: json["car_image_3"],
        carImage4: json["car_image_4"],
        driverLicenseNumber: json["driver_license_number"],
        driverLicenseFront: json["driver_license_front"],
        driverLicenseBack: json["driver_license_back"],
        driverLicenseDate: json["driver_license_date"] == null ? null : DateTime.parse(json["driver_license_date"]),
        tsPassportFront: json["ts_passport_front"],
        tsPassportBack: json["ts_passport_back"],
        status: json["status"],
        rejectMessage: json["reject_message"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "name": name,
        "lastname": lastname,
        "birthdate": birthdate == null
            ? null
            : "${birthdate!.year.toString().padLeft(4, '0')}-${birthdate!.month.toString().padLeft(2, '0')}-${birthdate!.day.toString().padLeft(2, '0')}",
        "car_id": carId,
        "car_model_id": carModelId,
        "car_vin": carVin,
        "car_year": carYear,
        "car_gos_number": carGosNumber,
        "car_image_1": carImage1,
        "car_image_2": carImage2,
        "car_image_3": carImage3,
        "car_image_4": carImage4,
        "driver_license_number": driverLicenseNumber,
        "driver_license_front": driverLicenseFront,
        "driver_license_back": driverLicenseBack,
        "driver_license_date": driverLicenseDate == null
            ? null
            : "${driverLicenseDate!.year.toString().padLeft(4, '0')}-${driverLicenseDate!.month.toString().padLeft(2, '0')}-${driverLicenseDate!.day.toString().padLeft(2, '0')}",
        "ts_passport_front": tsPassportFront,
        "ts_passport_back": tsPassportBack,
        "status": status,
        "reject_message": rejectMessage,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
