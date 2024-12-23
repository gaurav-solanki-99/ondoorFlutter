import 'dart:convert';

class CancelOrderbyOrderIdResponse {
  bool? success;
  String? message;

  CancelOrderbyOrderIdResponse({
    this.success,
    this.message,
  });

  CancelOrderbyOrderIdResponse copyWith({
    bool? success,
    String? message,
  }) =>
      CancelOrderbyOrderIdResponse(
        success: success ?? this.success,
        message: message ?? this.message,
      );

  factory CancelOrderbyOrderIdResponse.fromRawJson(String str) =>
      CancelOrderbyOrderIdResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CancelOrderbyOrderIdResponse.fromJson(Map<String, dynamic> json) =>
      CancelOrderbyOrderIdResponse(
        success: json["success"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
      };
}
