import 'dart:convert';

class AddNotificationResponse {
  bool success;
  String data;

  AddNotificationResponse({
    required this.success,
    required this.data,
  });

  factory AddNotificationResponse.fromRawJson(String str) =>
      AddNotificationResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AddNotificationResponse.fromJson(Map<String, dynamic> json) =>
      AddNotificationResponse(
        success: json["success"] ?? false,
        data: json["data"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data,
      };
}
