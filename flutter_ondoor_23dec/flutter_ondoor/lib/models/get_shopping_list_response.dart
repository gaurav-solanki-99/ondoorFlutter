import 'dart:convert';

class GetShoppingListResponse {
  bool? success;
  List<Shoppinglist>? shoppinglist;

  GetShoppingListResponse({this.success, this.shoppinglist});
  factory GetShoppingListResponse.fromJson(String str) =>
      GetShoppingListResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory GetShoppingListResponse.fromMap(Map<String, dynamic> json) =>
      GetShoppingListResponse(
          success: json['success'] ?? false,
          shoppinglist: json["shoppinglist"] == null
              ? []
              : List<Shoppinglist>.from(
                  json["shoppinglist"].map((x) => Shoppinglist.fromMap(x))));

  Map<String, dynamic> toMap() =>
      {"shoppinglist": shoppinglist, "success": success};
}

class Shoppinglist {
  String? shoppingListId;
  String? name;
  int? count;

  Shoppinglist({this.shoppingListId, this.name, this.count});

  factory Shoppinglist.fromJson(String str) =>
      Shoppinglist.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Shoppinglist.fromMap(Map<String, dynamic> json) => Shoppinglist(
      shoppingListId: json['shopping_list_id'] ?? "",
      name: json['name'] ?? "",
      count: json['count'] ?? "");

  Map<String, dynamic> toMap() =>
      {"shopping_list_id": shoppingListId, "name": name, "count": count};
}
