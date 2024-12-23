import 'dart:convert';

class LocationProductsModel {
  bool success;
  List<CartData> data;
  String locationChangeMessage;

  LocationProductsModel({
    required this.success,
    required this.data,
    required this.locationChangeMessage,
  });

  factory LocationProductsModel.fromJson(String str) => LocationProductsModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LocationProductsModel.fromMap(Map<String, dynamic> json) => LocationProductsModel(
    success: json["success"],
    data: List<CartData>.from(json["data"].map((x) => CartData.fromMap(x))),
    locationChangeMessage: json["location_change_message"],
  );

  Map<String, dynamic> toMap() => {
    "success": success,
    "data": List<dynamic>.from(data.map((x) => x.toMap())),
    "location_change_message": locationChangeMessage,
  };
}

class CartData {
  String index;
  String? productId;
  String? outOfStock;
  var oldPrice;
  var newPrice;
  String name;
  String qty;
  String? outOfSTock;
  String? proDuctId;
  String? special_price;
  String? price;

  CartData({
    required this.index,
    this.productId,
    this.outOfStock,
    required this.oldPrice,
    this.newPrice,
    required this.name,
    required this.qty,
    this.outOfSTock,
    this.proDuctId,
    this.special_price,
    this.price,
  });

  factory CartData.fromJson(String str) => CartData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CartData.fromMap(Map<String, dynamic> json) => CartData(
    index: json["index"],
    productId: json["product_id"],
    outOfStock: json["out_of_stock"],
    oldPrice: json["old_price"],
    newPrice: json["new_price"],
    name: json["name"],
    qty: json["qty"],
    special_price: json["special_price"],
    price: json["price"],
  );

  Map<String, dynamic> toMap() => {
    "index": index,
    "product_id": productId,
    "out_of_stock": outOfStock,
    "old_price": oldPrice,
    "new_price": newPrice,
    "name": name,
    "qty": qty,
    "special_price": special_price,
    "price": price,

  };
}
