import 'dart:convert';

class RegisterResponse {
  bool? success;
  String? data;

  RegisterResponse({
    this.success,
    this.data,
  });

  factory RegisterResponse.fromRawJson(String str) =>
      RegisterResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      RegisterResponse(
        success: json["success"] ?? false,
        data: json["data"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data,
      };
}
