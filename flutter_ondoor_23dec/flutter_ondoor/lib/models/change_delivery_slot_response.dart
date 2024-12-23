import 'dart:convert';

class ChangeDeliverySlotResponse {
  bool? success;
  String? message;

  ChangeDeliverySlotResponse({
    this.success,
    this.message,
  });

  factory ChangeDeliverySlotResponse.fromRawJson(String str) =>
      ChangeDeliverySlotResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ChangeDeliverySlotResponse.fromJson(Map<String, dynamic> json) =>
      ChangeDeliverySlotResponse(
        success: json["success"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
      };
}
