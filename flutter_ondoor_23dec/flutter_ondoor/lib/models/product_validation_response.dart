import 'dart:convert';

class ProductValidationResponse {
  List<ProductValidationData>? data;
  String? orderId;
  dynamic? orderTotal;
  String? ondoorProduct;
  String? customerId;
  String? oldPromoWalletUsed;
  dynamic? campaignId;
  String? isEdit;
  String? orderLocationId;

  ProductValidationResponse({
    this.data,
    this.orderId,
    this.orderTotal,
    this.ondoorProduct,
    this.customerId,
    this.oldPromoWalletUsed,
    this.campaignId,
    this.isEdit,
    this.orderLocationId,
  });

  factory ProductValidationResponse.fromRawJson(String str) =>
      ProductValidationResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProductValidationResponse.fromJson(Map<String, dynamic> json) =>
      ProductValidationResponse(
        data: json["data"] == null
            ? []
            : List<ProductValidationData>.from(
                json["data"]!.map((x) => ProductValidationData.fromJson(x))),
        orderId: json["order_id"],
        orderTotal: json["order_total"] ?? 0.0,
        ondoorProduct: json["ondoor_product"],
        customerId: json["customer_id"],
        oldPromoWalletUsed: json["old_promo_wallet_used"],
        campaignId: json["campaign_id"],
        isEdit: json["is_edit"],
        orderLocationId: json["order_location_id"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "order_id": orderId,
        "order_total": orderTotal,
        "ondoor_product": ondoorProduct,
        "customer_id": customerId,
        "old_promo_wallet_used": oldPromoWalletUsed,
        "campaign_id": campaignId,
        "is_edit": isEdit,
        "order_location_id": orderLocationId,
      };
}

class ProductValidationData {
  String? index;
  String? productId;
  String? name;
  String? qty;
  String? image;
  String? model;
  String? subtract;
  String? cOfferId;
  String? offerType;
  ProductValidationShippingOption? subProduct;
  int? price;
  List<dynamic>? option;
  String? locationId;
  ProductValidationShippingOption? shippingOption;

  ProductValidationData({
    this.index,
    this.productId,
    this.name,
    this.qty,
    this.image,
    this.model,
    this.subtract,
    this.cOfferId,
    this.offerType,
    this.subProduct,
    this.price,
    this.option,
    this.locationId,
    this.shippingOption,
  });

  factory ProductValidationData.fromRawJson(String str) =>
      ProductValidationData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProductValidationData.fromJson(Map<String, dynamic> json) =>
      ProductValidationData(
        index: json["index"],
        productId: json["product_id"],
        name: json["name"],
        qty: json["qty"],
        image: json["image"],
        model: json["model"],
        subtract: json["subtract"],
        cOfferId: json["c_offer_id"],
        offerType: json["offer_type"],
        subProduct: json["sub_product"] == null
            ? null
            : ProductValidationShippingOption.fromJson(json["sub_product"]),
        price: json["price"],
        option: json["option"] == null
            ? []
            : List<dynamic>.from(json["option"]!.map((x) => x)),
        locationId: json["location_id"],
        shippingOption: json["shipping_option"] == null
            ? null
            : ProductValidationShippingOption.fromJson(json["shipping_option"]),
      );

  Map<String, dynamic> toJson() => {
        "index": index,
        "product_id": productId,
        "name": name,
        "qty": qty,
        "image": image,
        "model": model,
        "subtract": subtract,
        "c_offer_id": cOfferId,
        "offer_type": offerType,
        "sub_product": subProduct?.toJson(),
        "price": price,
        "option":
            option == null ? [] : List<dynamic>.from(option!.map((x) => x)),
        "location_id": locationId,
        "shipping_option": shippingOption?.toJson(),
      };
}

class ProductValidationShippingOption {
  ProductValidationShippingOption();

  factory ProductValidationShippingOption.fromRawJson(String str) =>
      ProductValidationShippingOption.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProductValidationShippingOption.fromJson(Map<String, dynamic> json) =>
      ProductValidationShippingOption();

  Map<String, dynamic> toJson() => {};
}
