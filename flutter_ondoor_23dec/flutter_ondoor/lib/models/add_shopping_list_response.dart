import 'dart:convert';

class AddShoppingListResponse {
  bool? success;
  String? message;

  AddShoppingListResponse({this.success, this.message});
  factory AddShoppingListResponse.fromJson(String str) =>
      AddShoppingListResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AddShoppingListResponse.fromMap(Map<String, dynamic> json) =>
      AddShoppingListResponse(
          success: json['success'] ?? false, message: json['message'] ?? ""
          /* shoppinglist: json["shoppinglist"] == null
              ? []
              : List<Shoppinglist>.from(
              json["shoppinglist"].map((x) => Shoppinglist.fromMap(x)))*/
          );

  Map<String, dynamic> toMap() => {"success": success, "message": message};
  // AddShoppingListResponse.fromJson(Map<String, dynamic> json) {
  //   success = json['success'];
  //   message = json['message'];
  // }
  //
  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = new Map<String, dynamic>();
  //   data['success'] = this.success;
  //   data['message'] = this.message;
  //   return data;
  // }
}
