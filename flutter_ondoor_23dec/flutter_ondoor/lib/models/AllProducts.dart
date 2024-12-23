import 'dart:convert';

class ProductsModel {
  bool? success;
  dynamic data;

  ProductsModel({
    this.success,
    this.data,
  });

  factory ProductsModel.fromJson(String str) =>
      ProductsModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ProductsModel.fromMap(Map<String, dynamic> json) => ProductsModel(
        success: json["success"],
        data: json["data"] == null
            ? []
            : json['data'] is String
                ? json['data']
                : List<ProductData>.from(
                    json["data"]!.map((x) => ProductData.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "success": success,
        "data":
            data == null ? [] : List<dynamic>.from(data!.map((x) => x.toMap())),
      };
}

class ProductData {
  List<ProductUnit>? unit;

  ProductData({
    this.unit,
  });

  factory ProductData.fromJson(String str) =>
      ProductData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ProductData.fromMap(Map<String, dynamic> json) => ProductData(
        unit: json["unit"] == null
            ? []
            : List<ProductUnit>.from(
                json["unit"]!.map((x) => ProductUnit.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "unit":
            unit == null ? [] : List<dynamic>.from(unit!.map((x) => x.toMap())),
      };
}

class ProductUnit {
  int addQuantity = 0;
  bool? mandatory = false;
  String? productId;
  String? max_quantity = "";
  String isSubscribe = "";
  String? offer_id = "";
  String? averageRating;
  var categoryId;
  String? name;
  String? description;
  String? model;
  String? sku;
  String? location;
  String? quantity;
  String? image;
  String? detailsImage;
  String? sortPrice;
  String? price;
  dynamic? specialPrice;
  String? subtract;
  dynamic? orderQtyLimit;
  String? pricePrefix;
  dynamic? productWeight;
  String? productWeightUnit;
  String? productPackType;
  String? frontDisplay;
  String? price_plain;
  String? total_plain;
  dynamic? isOption;
  dynamic? isCustomize;
  String? messageOnCard;
  String? messageOnCake;
  String? customMsg;
  String? cardMsg;
  List<dynamic>? options;
  Seller? seller;
  List<dynamic>? shippingOptions;
  int? ondoorProduct;
  String? cnfShippingSurcharge;
  String? shippingMaxAmount;
  String? rewardPoints;
  String? discountText;
  String? discountLabel;
  List<ImageArray>? imageArray;
  dynamic? cOfferId;
  dynamic? cOfferType;
  int? outOfStock;
  String selectedQuantity = "Select";
  SubProduct? subProduct;
  int selectedUnitIndex = 0;
  bool isselectUnit = false;
  bool isChecked = false;

  ProductUnit({
    this.productId,
    this.mandatory,
    this.categoryId,
    this.averageRating,
    this.offer_id,
    this.name,
    this.max_quantity,
    this.description,
    this.model,
    this.sku,
    this.location,
    this.quantity,
    this.price_plain,
    this.total_plain,
    this.image,
    this.detailsImage,
    this.sortPrice,
    this.price,
    this.specialPrice,
    this.subtract,
    this.orderQtyLimit,
    this.pricePrefix,
    this.productWeight,
    this.productWeightUnit,
    this.productPackType,
    this.frontDisplay,
    this.isOption,
    this.isCustomize,
    this.messageOnCard,
    this.messageOnCake,
    this.customMsg,
    this.cardMsg,
    this.options,
    this.seller,
    this.shippingOptions,
    this.ondoorProduct,
    this.cnfShippingSurcharge,
    this.shippingMaxAmount,
    this.rewardPoints,
    this.discountText,
    this.discountLabel,
    this.imageArray,
    this.cOfferId,
    this.cOfferType,
    this.outOfStock,
    this.subProduct,
  });

  factory ProductUnit.fromJson(String str) =>
      ProductUnit.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());
  factory ProductUnit.fromMap(Map<String, dynamic> json) => ProductUnit(
        productId: json["product_id"],
        offer_id: json['offer_id'] ?? "",
        mandatory: json["mandatory"] ?? false,
        max_quantity: json["max_quantity"] ?? "",
        price_plain: json['price_plain'] ?? "",
        total_plain: json["total_plain"].toString(),
        averageRating: json["average_rating"],
        categoryId: json["category_id"],
        name: json["name"],
        description: json["description"],
        model: json["model"],
        sku: json["sku"],
        location: json["location"].toString(),
        quantity: json["quantity"].toString(),
        image: json["image"],
        detailsImage: json["details_image"],
        sortPrice: json["sort_price"] ?? "",
        price: json["price"].toString(),
        specialPrice: json["special_price"],
        subtract: json["subtract"],
        orderQtyLimit: json["order_qty_limit"],
        pricePrefix: json["price_prefix"],
        productWeight: json["product_weight"],
        productWeightUnit: json["product_weight_unit"],
        productPackType: json["product_pack_type"],
        frontDisplay: json["front_display"],
        isOption: json["is_option"] is String
            ? json["is_option"] ?? ""
            : json["is_option"] ?? 0,
        isCustomize: json["is_customize"] is String
            ? json["is_customize"] ?? ""
            : json["is_customize"] ?? 0,
        messageOnCard: json["message_on_card"],
        messageOnCake: json["message_on_cake"],
        customMsg: json["custom_msg"],
        cardMsg: json["card_msg"],
        options: json["options"] == null
            ? []
            : List<dynamic>.from(json["options"]!.map((x) => x)),
        seller: json["seller"] == null ? null : Seller.fromMap(json["seller"]),
        shippingOptions: json["shipping_options"] == null
            ? []
            : List<dynamic>.from(json["shipping_options"]!.map((x) => x)),
        ondoorProduct: json["ondoor_product"],
        cnfShippingSurcharge: json["cnf_shipping_surcharge"],
        shippingMaxAmount: json["shipping_max_amount"],
        rewardPoints: json["reward_points"],
        discountText: json["discount_text"],
        discountLabel: json["discount_label"],
        imageArray: json["image_array"] == null
            ? []
            : List<ImageArray>.from(
                json["image_array"]!.map((x) => ImageArray.fromMap(x))),
        cOfferId: json["c_offer_id"] is String
            ? json["c_offer_id"] ?? "0"
            : json["c_offer_id"] ?? 0,
        cOfferType: json["c_offer_type"] is String
            ? json["c_offer_type"] ?? "0"
            : json["c_offer_type"] ?? 0,
        outOfStock: json["out_of_stock"] ?? 0,
        subProduct: json["sub_product"] == null
            ? SubProduct()
            : SubProduct.fromMap(json["sub_product"]),
      );

  Map<String, dynamic> toMap() => {
        "product_id": productId,
        "category_id": categoryId,
        "offer_id": offer_id,
        "average_rating": averageRating,
        "name": name,
        "description": description,
        "model": model,
        "sku": sku,
        "location": location,
        "price_plain": price_plain,
        "total_plain": total_plain,
        "quantity": quantity,
        "image": image,
        "details_image": detailsImage,
        "sort_price": sortPrice,
        "price": price,
        "special_price": specialPrice,
        "subtract": subtract,
        "order_qty_limit": orderQtyLimit,
        "price_prefix": pricePrefix,
        "product_weight": productWeight,
        "product_weight_unit": productWeightUnit,
        "product_pack_type": productPackType,
        "front_display": frontDisplay,
        "is_option": isOption,
        "is_customize": isCustomize,
        "message_on_card": messageOnCard,
        "message_on_cake": messageOnCake,
        "custom_msg": customMsg,
        "card_msg": cardMsg,
        "options":
            options == null ? [] : List<dynamic>.from(options!.map((x) => x)),
        "seller": seller?.toMap(),
        "shipping_options": shippingOptions == null
            ? []
            : List<dynamic>.from(shippingOptions!.map((x) => x)),
        "ondoor_product": ondoorProduct,
        "cnf_shipping_surcharge": cnfShippingSurcharge,
        "shipping_max_amount": shippingMaxAmount,
        "reward_points": rewardPoints,
        "discount_text": discountText,
        "discount_label": discountLabel,
        "image_array": imageArray == null
            ? []
            : List<dynamic>.from(imageArray!.map((x) => x.toMap())),
        "c_offer_id": cOfferId,
        "c_offer_type": cOfferType,
        "out_of_stock": outOfStock,
        "sub_product": subProduct?.toMap(),
      };
}

class ImageArray {
  int? type;
  String? title;
  String? imageUrl;
  String? videoUrl;

  ImageArray({
    this.type,
    this.title,
    this.imageUrl,
    this.videoUrl,
  });

  factory ImageArray.fromJson(String str) =>
      ImageArray.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ImageArray.fromMap(Map<String, dynamic> json) => ImageArray(
        type: json["type"],
        title: json["title"],
        imageUrl: json["image_url"],
        videoUrl: json["video_url"],
      );

  Map<String, dynamic> toMap() => {
        "type": type,
        "title": title,
        "image_url": imageUrl,
        "video_url": videoUrl,
      };
}

class Seller {
  Seller();

  factory Seller.fromJson(String str) => Seller.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Seller.fromMap(Map<String, dynamic> json) => Seller();

  Map<String, dynamic> toMap() => {};
}

class SubProduct {
  String? cOfferAvail;
  String? cOfferInfo;
  String? offerWarning;
  String? cOfferApplied;
  String? buyQty;
  String? getQty;
  String? discType;
  String? discAmt;
  String? offerProductId;
  List<ProductUnit>? subProductDetail;

  SubProduct({
    this.cOfferAvail,
    this.cOfferInfo,
    this.offerWarning,
    this.cOfferApplied,
    this.buyQty,
    this.getQty,
    this.discType,
    this.discAmt,
    this.offerProductId,
    this.subProductDetail,
  });

  factory SubProduct.fromJson(String str) =>
      SubProduct.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SubProduct.fromMap(Map<String, dynamic> json) => SubProduct(
        cOfferAvail: json["c_offer_avail"],
        cOfferInfo: json["c_offer_info"],
        offerWarning: json["offer_warning"],
        cOfferApplied: json["c_offer_applied"],
        buyQty: json["buy_qty"],
        getQty: json["get_qty"],
        discType: json["disc_type"],
        discAmt: json["disc_amt"],
        offerProductId: json["offer_product_id"],
        subProductDetail: json["sub_product_detail"] == null
            ? []
            : List<ProductUnit>.from(
                json["sub_product_detail"]!.map((x) => ProductUnit.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "c_offer_avail": cOfferAvail,
        "c_offer_info": cOfferInfo,
        "offer_warning": offerWarning,
        "c_offer_applied": cOfferApplied,
        "buy_qty": buyQty,
        "get_qty": getQty,
        "disc_type": discType,
        "disc_amt": discAmt,
        "offer_product_id": offerProductId,
        "sub_product_detail": subProductDetail == null
            ? []
            : List<dynamic>.from(subProductDetail!.map((x) => x.toMap())),
      };
}

// class SubProductDetail {
//   String? productId;
//   String? categoryId;
//   String? name;
//   String? webName;
//   String? description;
//   String? model;
//   String? sku;
//   String? location;
//   String? quantity;
//   String? image;
//   String? detailsImage;
//   String? sortPrice;
//   String? price;
//   String? specialPrice;
//   String? subtract;
//   String? orderQtyLimit;
//   String? pricePrefix;
//   int? productWeight;
//   String? productWeightUnit;
//   String? productPackType;
//   String? frontDisplay;
//   String? isOption;
//   String? isCustomize;
//   String? messageOnCard;
//   String? messageOnCake;
//   String? customMsg;
//   String? cardMsg;
//   List<dynamic>? options;
//   Seller? seller;
//   List<dynamic>? shippingOptions;
//   int? ondoorProduct;
//   String? cnfShippingSurcharge;
//   String? shippingMaxAmount;
//   String? rewardPoints;
//   String? discountText;
//   String? discountLabel;
//
//   SubProductDetail({
//     this.productId,
//     this.categoryId,
//     this.name,
//     this.webName,
//     this.description,
//     this.model,
//     this.sku,
//     this.location,
//     this.quantity,
//     this.image,
//     this.detailsImage,
//     this.sortPrice,
//     this.price,
//     this.specialPrice,
//     this.subtract,
//     this.orderQtyLimit,
//     this.pricePrefix,
//     this.productWeight,
//     this.productWeightUnit,
//     this.productPackType,
//     this.frontDisplay,
//     this.isOption,
//     this.isCustomize,
//     this.messageOnCard,
//     this.messageOnCake,
//     this.customMsg,
//     this.cardMsg,
//     this.options,
//     this.seller,
//     this.shippingOptions,
//     this.ondoorProduct,
//     this.cnfShippingSurcharge,
//     this.shippingMaxAmount,
//     this.rewardPoints,
//     this.discountText,
//     this.discountLabel,
//   });
//
//   factory SubProductDetail.fromJson(String str) => SubProductDetail.fromMap(json.decode(str));
//
//   String toJson() => json.encode(toMap());
//
//   factory SubProductDetail.fromMap(Map<String, dynamic> json) => SubProductDetail(
//     productId: json["product_id"],
//     categoryId: json["category_id"],
//     name: json["name"],
//     webName: json["web_name"],
//     description: json["description"],
//     model: json["model"],
//     sku: json["sku"],
//     location: json["location"],
//     quantity: json["quantity"],
//     image: json["image"],
//     detailsImage: json["details_image"],
//     sortPrice: json["sort_price"],
//     price: json["price"],
//     specialPrice: json["special_price"],
//     subtract: json["subtract"],
//     orderQtyLimit: json["order_qty_limit"],
//     pricePrefix: json["price_prefix"],
//     productWeight: json["product_weight"],
//     productWeightUnit: json["product_weight_unit"],
//     productPackType: json["product_pack_type"],
//     frontDisplay: json["front_display"],
//     isOption: json["is_option"],
//     isCustomize: json["is_customize"],
//     messageOnCard: json["message_on_card"],
//     messageOnCake: json["message_on_cake"],
//     customMsg: json["custom_msg"],
//     cardMsg: json["card_msg"],
//     options: json["options"] == null ? [] : List<dynamic>.from(json["options"]!.map((x) => x)),
//     seller: json["seller"] == null ? null : Seller.fromMap(json["seller"]),
//     shippingOptions: json["shipping_options"] == null ? [] : List<dynamic>.from(json["shipping_options"]!.map((x) => x)),
//     ondoorProduct: json["ondoor_product"],
//     cnfShippingSurcharge: json["cnf_shipping_surcharge"],
//     shippingMaxAmount: json["shipping_max_amount"],
//     rewardPoints: json["reward_points"],
//     discountText: json["discount_text"],
//     discountLabel: json["discount_label"],
//   );
//
//   Map<String, dynamic> toMap() => {
//     "product_id": productId,
//     "category_id": categoryId,
//     "name": name,
//     "web_name": webName,
//     "description": description,
//     "model": model,
//     "sku": sku,
//     "location": location,
//     "quantity": quantity,
//     "image": image,
//     "details_image": detailsImage,
//     "sort_price": sortPrice,
//     "price": price,
//     "special_price": specialPrice,
//     "subtract": subtract,
//     "order_qty_limit": orderQtyLimit,
//     "price_prefix": pricePrefix,
//     "product_weight": productWeight,
//     "product_weight_unit": productWeightUnit,
//     "product_pack_type": productPackType,
//     "front_display": frontDisplay,
//     "is_option": isOption,
//     "is_customize": isCustomize,
//     "message_on_card": messageOnCard,
//     "message_on_cake": messageOnCake,
//     "custom_msg": customMsg,
//     "card_msg": cardMsg,
//     "options": options == null ? [] : List<dynamic>.from(options!.map((x) => x)),
//     "seller": seller?.toMap(),
//     "shipping_options": shippingOptions == null ? [] : List<dynamic>.from(shippingOptions!.map((x) => x)),
//     "ondoor_product": ondoorProduct,
//     "cnf_shipping_surcharge": cnfShippingSurcharge,
//     "shipping_max_amount": shippingMaxAmount,
//     "reward_points": rewardPoints,
//     "discount_text": discountText,
//     "discount_label": discountLabel,
//   };
// }
