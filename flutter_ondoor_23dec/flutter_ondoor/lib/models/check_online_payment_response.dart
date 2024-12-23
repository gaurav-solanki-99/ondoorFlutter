// To parse this JSON data, do
//
//     final checkOnlinePaymentResponse = checkOnlinePaymentResponseFromJson(jsonString);

import 'dart:convert';

CheckOnlinePaymentResponse checkOnlinePaymentResponseFromJson(String str) => CheckOnlinePaymentResponse.fromJson(json.decode(str));

String checkOnlinePaymentResponseToJson(CheckOnlinePaymentResponse data) => json.encode(data.toJson());

class CheckOnlinePaymentResponse {
  bool? success;
  String? orderId;
  String? total;
  String? deliveryTime;
  String? deliveryDate;
  String? message;
  int? key;

  CheckOnlinePaymentResponse({
    this.success,
    this.orderId,
    this.total,
    this.deliveryTime,
    this.deliveryDate,
    this.message,
    this.key,
  });

  factory CheckOnlinePaymentResponse.fromJson(Map<String, dynamic> json) => CheckOnlinePaymentResponse(
    success: json["success"],
    orderId: json["order_id"],
    total: json["Total"],
    deliveryTime: json["delivery_time"],
    deliveryDate: json["delivery_date"],
    message: json["message"],
    key: json["key"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "order_id": orderId,
    "Total": total,
    "delivery_time": deliveryTime,
    "delivery_date": deliveryDate,
    "message": message,
    "key": key,
  };
}
