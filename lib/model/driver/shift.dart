class ShiftPriceModel {
  int? id;
  int? txShiftId;
  int? txLevelId;
  int? txCarClassId;
  int? price;
  DateTime? createdAt;
  DateTime? updatedAt;
  ShiftModel? shift;

  String get shiftName => "${shift?.hours} ${shift?.state}";

  ShiftPriceModel({
    this.id,
    this.txShiftId,
    this.txLevelId,
    this.txCarClassId,
    this.price,
    this.createdAt,
    this.updatedAt,
    this.shift,
  });

  ShiftPriceModel copyWith({
    int? id,
    int? txShiftId,
    int? txLevelId,
    int? txCarClassId,
    int? price,
    DateTime? createdAt,
    DateTime? updatedAt,
    ShiftModel? shift,
  }) =>
      ShiftPriceModel(
        id: id ?? this.id,
        txShiftId: txShiftId ?? this.txShiftId,
        txLevelId: txLevelId ?? this.txLevelId,
        txCarClassId: txCarClassId ?? this.txCarClassId,
        price: price ?? this.price,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        shift: shift ?? this.shift,
      );

  factory ShiftPriceModel.fromJson(Map<String, dynamic> json) => ShiftPriceModel(
        id: json["id"],
        txShiftId: json["tx_shift_id"],
        txLevelId: json["tx_level_id"],
        txCarClassId: json["tx_car_class_id"],
        price: json["price"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        shift: json["shift"] == null ? null : ShiftModel.fromJson(json["shift"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "tx_shift_id": txShiftId,
        "tx_level_id": txLevelId,
        "tx_car_class_id": txCarClassId,
        "price": price,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "shift": shift?.toJson(),
      };
}

class ShiftModel {
  int? id;
  int? hours;
  String? state;

  ShiftModel({
    this.id,
    this.hours,
    this.state,
  });

  ShiftModel copyWith({
    int? id,
    int? hours,
    String? state,
  }) =>
      ShiftModel(
        id: id ?? this.id,
        hours: hours ?? this.hours,
        state: state ?? this.state,
      );

  factory ShiftModel.fromJson(Map<String, dynamic> json) => ShiftModel(
        id: json["id"],
        hours: json["hours"],
        state: json["state"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "hours": hours,
        "state": state,
      };
}
