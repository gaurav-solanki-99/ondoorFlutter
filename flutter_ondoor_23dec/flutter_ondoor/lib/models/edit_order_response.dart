import 'dart:convert';

class EditOrderResponse {
  bool? success;
  String? orderId;
  dynamic? total;
  String? message;

  EditOrderResponse({
    this.success,
    this.orderId,
    this.total,
    this.message,
  });

  factory EditOrderResponse.fromRawJson(String str) =>
      EditOrderResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory EditOrderResponse.fromJson(Map<String, dynamic> json) =>
      EditOrderResponse(
        success: json["success"],
        orderId: json["order_id"],
        total: json["Total"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "order_id": orderId,
        "Total": total,
        "message": message,
      };
}
