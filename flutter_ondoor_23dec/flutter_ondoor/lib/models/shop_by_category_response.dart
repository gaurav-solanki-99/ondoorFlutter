// import 'dart:convert';
//
// class ShopByCategoryResponse {
//   bool success = false;
//   List<Data> data;
//
//   ShopByCategoryResponse({required this.success, required this.data});
//
//   factory ShopByCategoryResponse.fromJson(String str) =>
//       ShopByCategoryResponse.fromMap(json.decode(str));
//
//   factory ShopByCategoryResponse.fromMap(Map<String, dynamic> json) =>
//       ShopByCategoryResponse(
//         data: json["data"] == null
//             ? []
//             : json["data"] is String
//                 ? json["data"]
//                 : List<Data>.from(json["data"].map((x) => Data.fromMap(x))),
//         success: json["success"] ?? false,
//       );
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['success'] = success;
//     if (this.data != null) {
//       if (this.data is List<Data>) {
//         data['data'] = this.data.map((v) => v.toJson()).toList();
//       } else {
//         data['data'] = this.data;
//       }
//     }
//     return data;
//   }
// }
//
// class Data {
//   List<Unit> unit = [];
//
//   Data({required this.unit});
//
//   factory Data.fromJson(String str) => Data.fromMap(json.decode(str));
//
//   factory Data.fromMap(Map<String, dynamic> json) => Data(
//         unit: json["unit"] == null
//             ? []
//             : List<Unit>.from(json["unit"].map((x) => Unit.fromMap(x))),
//       );
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['unit'] = unit.map((v) => v.toJson()).toList();
//     return data;
//   }
// }
//
// class Unit {
//   String? productId = "";
//   String? isSubscribe = "";
//   String? categoryId = "";
//   String? name = "";
//   String? webName = "";
//   String? description = "";
//   String? model = "";
//   String? sku = "";
//   String? location = "";
//   String? quantity = "";
//   String? image = "";
//   String? detailsImage = "";
//   String? sortPrice = "";
//   String? price = "";
//   dynamic specialPrice;
//   String? subtract = "";
//   dynamic orderQtyLimit;
//   String? pricePrefix = "";
//   dynamic productWeight;
//   String? productWeightUnit = "";
//   String? productPackType = "";
//   String? frontDisplay = "";
//   String? isOption = "";
//   String? isCustomize = "";
//   String? messageOnCard = "";
//   String? messageOnCake = "";
//   String? customMsg = "";
//   String? cardMsg = "";
//   int? ondoorProduct = 0;
//   String? cnfShippingSurcharge = "";
//   String? shippingMaxAmount = "";
//   String? rewardPoints = "";
//   String? discountText = "";
//   String? discountLabel = "";
//   List<ImageArray>? imageArray = [];
//   int? cOfferId = 0;
//   int? cOfferType = 0;
//   int? outOfStock = 0;
//   int itemCount = 0;
//   int addQuantity = 0;
//   String selectedQuantity = "Select";
//
//   Unit({
//     this.productId,
//     this.isSubscribe,
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
//     this.ondoorProduct,
//     this.cnfShippingSurcharge,
//     this.shippingMaxAmount,
//     this.rewardPoints,
//     this.discountText,
//     this.discountLabel,
//     this.imageArray,
//     this.cOfferId,
//     this.cOfferType,
//     this.outOfStock,
//   });
//
//   factory Unit.fromJson(String str) => Unit.fromMap(json.decode(str));
//
//   factory Unit.fromMap(Map<String, dynamic> json) => Unit(
//         productId: json['product_id'] ?? "",
//         isSubscribe: json['is_subscribe'] ?? "",
//         categoryId: json['category_id'] ?? "",
//         name: json['name'] ?? "",
//         webName: json['web_name'] ?? "",
//         description: json['description'] ?? "",
//         model: json['model'] ?? "",
//         sku: json['sku'] ?? "",
//         location: json['location'] ?? "",
//         quantity: json['quantity'] ?? "",
//         image: json['image'] ?? "",
//         detailsImage: json['details_image'] ?? "",
//         sortPrice: json['sort_price'] ?? "",
//         price: json['price'] ?? "",
//         specialPrice: json['special_price'] ?? "",
//         subtract: json['subtract'] ?? "",
//         orderQtyLimit: json['order_qty_limit'],
//         pricePrefix: json['price_prefix'] ?? "",
//         productWeight: json['product_weight'],
//         productWeightUnit: json['product_weight_unit'] ?? "",
//         productPackType: json['product_pack_type'] ?? "",
//         frontDisplay: json['front_display'] ?? "",
//         isOption: json['is_option'] ?? "",
//         isCustomize: json['is_customize'] ?? "",
//         messageOnCard: json['message_on_card'] ?? "",
//         messageOnCake: json['message_on_cake'] ?? "",
//         customMsg: json['custom_msg'] ?? "",
//         cardMsg: json['card_msg'] ?? "",
//         ondoorProduct: json['ondoor_product'] ?? 0,
//         cnfShippingSurcharge: json['cnf_shipping_surcharge'] ?? "",
//         shippingMaxAmount: json['shipping_max_amount'] ?? "",
//         rewardPoints: json['reward_points'] ?? "",
//         discountText: json['discount_text'] ?? "",
//         discountLabel: json['discount_label'] ?? "",
//         imageArray: json['image_array'] == null
//             ? []
//             : List<ImageArray>.from(
//                 json['image_array'].map((x) => ImageArray.fromMap(x))),
//         cOfferId: json['c_offer_id'] ?? 0,
//         cOfferType: json['c_offer_type'] ?? 0,
//         outOfStock: json['out_of_stock'] ?? 0,
//       );
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['product_id'] = productId;
//     data['is_subscribe'] = isSubscribe;
//     data['category_id'] = categoryId;
//     data['name'] = name;
//     data['web_name'] = webName;
//     data['description'] = description;
//     data['model'] = model;
//     data['sku'] = sku;
//     data['location'] = location;
//     data['quantity'] = quantity;
//     data['image'] = image;
//     data['details_image'] = detailsImage;
//     data['sort_price'] = sortPrice;
//     data['price'] = price;
//     data['special_price'] = specialPrice;
//     data['subtract'] = subtract;
//     data['order_qty_limit'] = orderQtyLimit;
//     data['price_prefix'] = pricePrefix;
//     data['product_weight'] = productWeight;
//     data['product_weight_unit'] = productWeightUnit;
//     data['product_pack_type'] = productPackType;
//     data['front_display'] = frontDisplay;
//     data['is_option'] = isOption;
//     data['is_customize'] = isCustomize;
//     data['message_on_card'] = messageOnCard;
//     data['message_on_cake'] = messageOnCake;
//     data['custom_msg'] = customMsg;
//     data['card_msg'] = cardMsg;
//     data['ondoor_product'] = ondoorProduct;
//     data['cnf_shipping_surcharge'] = cnfShippingSurcharge;
//     data['shipping_max_amount'] = shippingMaxAmount;
//     data['reward_points'] = rewardPoints;
//     data['discount_text'] = discountText;
//     data['discount_label'] = discountLabel;
//     data['image_array'] = imageArray!.map((v) => v.toJson()).toList();
//     data['c_offer_id'] = cOfferId;
//     data['c_offer_type'] = cOfferType;
//     data['out_of_stock'] = outOfStock;
//     return data;
//   }
// }
//
// class ImageArray {
//   int type = 0;
//   String title = "";
//   String imageUrl = "";
//   String videoUrl = "";
//
//   ImageArray({
//     required this.type,
//     required this.title,
//     required this.imageUrl,
//     required this.videoUrl,
//   });
//
//   factory ImageArray.fromJson(String str) =>
//       ImageArray.fromMap(json.decode(str));
//
//   factory ImageArray.fromMap(Map<String, dynamic> json) => ImageArray(
//         type: json['type'] ?? 0,
//         title: json['title'] ?? "",
//         imageUrl: json['image_url'] ?? "",
//         videoUrl: json['video_url'] ?? "",
//       );
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['type'] = type;
//     data['title'] = title;
//     data['image_url'] = imageUrl;
//     data['video_url'] = videoUrl;
//     return data;
//   }
// }
