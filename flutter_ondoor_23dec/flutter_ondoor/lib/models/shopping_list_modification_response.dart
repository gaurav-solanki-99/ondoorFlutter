import 'dart:convert';

class ShoppingListModificationResponse {
  bool? success;
  String? message;

  ShoppingListModificationResponse({this.success, this.message});
  factory ShoppingListModificationResponse.fromJson(String str) =>
      ShoppingListModificationResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ShoppingListModificationResponse.fromMap(Map<String, dynamic> json) =>
      ShoppingListModificationResponse(
          message: json['message'] ?? "", success: json['success'] ?? "");

  Map<String, dynamic> toMap() => {"success": success, "message": message};
}
