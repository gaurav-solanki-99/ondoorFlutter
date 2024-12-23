import 'dart:convert';

class ContactUsResponse {
  String? productMsg;
  dynamic success;
  String? message;

  ContactUsResponse({this.productMsg, this.success, this.message});
  factory ContactUsResponse.fromJson(String str) =>
      ContactUsResponse.fromMap(json.decode(str));

  factory ContactUsResponse.fromMap(Map<String, dynamic> json) =>
      ContactUsResponse(
          success: json['success'] ?? false,
          message: json["message"] ?? "",
          productMsg: json['product_msg'] ?? "");

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_msg'] = this.productMsg;
    data['success'] = this.success;
    data['message'] = this.message;
    return data;
  }
}
