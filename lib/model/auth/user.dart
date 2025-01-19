// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

// ignore: constant_identifier_names
enum UserRole { USR, DRV }

class UserModel {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? role;
  int? driverId;
  int? status;
  dynamic emailVerifiedAt;
  DateTime? createdAt;
  DateTime? updatedAt;

  bool get isDriver => role == UserRole.DRV.toString() && driverId != null;

  String get letter => name?.isNotEmpty == true ? name![0].toUpperCase() : '•';

  String get formattedTelephone {
    if (phone == null) return '';
    final digits = phone!.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) return phone!;
    return '+7 (${digits.substring(0, 3)}) ${digits.substring(3, 5)} ${digits.substring(5)}';
  }

  UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.driverId,
    this.status,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    int? driverId,
    int? status,
    dynamic emailVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        role: role ?? this.role,
        driverId: driverId ?? this.driverId,
        status: status ?? this.status,
        emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        role: json["role"],
        driverId: json["driver_id"],
        status: json["status"],
        emailVerifiedAt: json["email_verified_at"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "phone": phone,
        "role": role,
        "driver_id": driverId,
        "status": status,
        "email_verified_at": emailVerifiedAt,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
