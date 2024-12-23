import 'dart:convert';

import 'package:ondoor/models/AllProducts.dart';

class CartJsonModel {
  String? index;
  String? productId;
  String? name;
  String? qty;
  String? image;
  String? model;
  String? subtract;
  String? discountLabel;
  String? discountText;
  String? cOfferId;
  String? offerType;
  String? subProductOfferId;
  SubProduct? subProduct;
  double? price;
  List<dynamic>? option;
  String? locationId;
  ShippingOption? shippingOption;

  CartJsonModel({
    this.index,
    this.productId,
    this.name,
    this.qty,
    this.image,
    this.model,
    this.subtract,
    this.discountLabel,
    this.discountText,
    this.cOfferId,
    this.offerType,
    this.subProductOfferId,
    this.subProduct,
    this.price,
    this.option,
    this.locationId,
    this.shippingOption,
  });

  factory CartJsonModel.fromJson(String str) => CartJsonModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CartJsonModel.fromMap(Map<String, dynamic> json) => CartJsonModel(
    index: json["index"],
    productId: json["product_id"],
    name: json["name"],
    qty: json["qty"],
    image: json["image"],
    model: json["model"],
    subtract: json["subtract"],
    discountLabel: json["discount_label"],
    discountText: json["discount_text"],
    cOfferId: json["c_offer_id"],
    offerType: json["offer_type"],
    subProduct: json["sub_product"] == null ? null : SubProduct.fromMap(json["sub_product"]),
    subProductOfferId: json["offer_product_id"],
    price: json["price".trim()],
    option: json["option"] == null ? [] : List<dynamic>.from(json["option"]!.map((x) => x)),
    locationId: json["location_id"],
    shippingOption: json["shipping_option"] == null ? null : ShippingOption.fromMap(json["shipping_option"]),
  );

  Map<String, dynamic> toMap() => {
    "index": index,
    "product_id": productId,
    "name": name,
    "qty": qty,
    "image": image,
    "model": model,
    "subtract": subtract,
    "discount_label": discountLabel,
    "discount_text": discountText,
    "c_offer_id": cOfferId,
    "offer_type": offerType,
    "offer_product_id": subProductOfferId,
    "sub_product": subProduct,
    "price": price,
    "option": option == null ? [] : List<dynamic>.from(option!.map((x) => x)),
    "location_id": locationId,
    "shipping_option": shippingOption?.toMap(),
    "sub_product": subProduct?.toMap(),
  };
}

class ShippingOption {
  ShippingOption();

  factory ShippingOption.fromJson(String str) => ShippingOption.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ShippingOption.fromMap(Map<String, dynamic> json) => ShippingOption(
  );

  Map<String, dynamic> toMap() => {
  };
}


