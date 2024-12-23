import 'dart:convert';

import 'package:ondoor/models/AllProducts.dart';

class SaveOrdertoDatabaseParams {
  SaveOrderData? data;

  SaveOrdertoDatabaseParams({this.data});

  factory SaveOrdertoDatabaseParams.fromRawJson(String str) =>
      SaveOrdertoDatabaseParams.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SaveOrdertoDatabaseParams.fromJson(Map<String, dynamic> json) =>
      SaveOrdertoDatabaseParams(
        data:
            json["data"] == null ? null : SaveOrderData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
      };
}

class SaveOrderData {
  String? addressFormat;
  String? addressId;
  String? areaDetail;
  String? campaignId;
  String? city;
  String? comment;
  String? company;
  List<Content> contents;
  String? country;
  String? countryId;
  String? customField;
  String? customerId;
  String? deliveryDate;
  String? deliveryTime;
  String? discount;
  String? discountAmount;
  String? discountCode;
  String? discountType;
  String? firstname;
  String? flatSectorApartment;
  int gstInclude;
  String? landmark;
  String? lastname;
  String? locationId;
  String? offerId;
  List<dynamic> offerProduct;
  int? orderOfferTotal;
  String? orderStatus;
  String? paymentAddress1;
  String? paymentAddress2;
  String? paymentAddressFormat;
  String? paymentCity;
  String? paymentCode;
  String? paymentCompany;
  String? paymentCustomField;
  String? paymentFirstname;
  String? paymentLastname;
  String? paymentMethod;
  String? paymentPostcode;
  String? paymentTelephone;
  String? paymentZone;
  String? postcode;
  int promoWalletUsed;
  int recentCheckPassed;
  String? reward;
  String? rewardAmount;
  String? sellerProduct;
  String? shipping;
  String? sodexoAmount;
  String? storeCode;
  String? storeId;
  String? storeName;
  String? storeUrl;
  String? surcharge;
  String? tax;
  String? telephone;
  String? total;
  String? userAgent;
  String? zone;
  String? zoneId;

  SaveOrderData({
    this.addressFormat,
    this.addressId,
    this.areaDetail,
    this.campaignId,
    this.city,
    this.comment,
    this.company,
    List<Content>? contents,
    this.country,
    this.countryId,
    this.customField,
    this.customerId,
    this.deliveryDate,
    this.deliveryTime,
    this.discount,
    this.discountAmount,
    this.discountCode,
    this.discountType,
    this.firstname,
    this.flatSectorApartment,
    this.gstInclude = 0,
    this.landmark,
    this.lastname,
    this.locationId,
    this.offerId,
    List<dynamic>? offerProduct,
    this.orderStatus,
    this.paymentAddress1,
    this.paymentAddress2,
    this.paymentAddressFormat,
    this.paymentCity,
    this.paymentCode,
    this.paymentCompany,
    this.paymentCustomField,
    this.paymentFirstname,
    this.paymentLastname,
    this.paymentMethod,
    this.paymentPostcode,
    this.paymentTelephone,
    this.paymentZone,
    this.postcode,
    this.promoWalletUsed = 0,
    this.recentCheckPassed = 0,
    this.reward,
    this.rewardAmount,
    this.sellerProduct,
    this.shipping,
    this.sodexoAmount,
    this.storeCode,
    this.storeId,
    this.storeName,
    this.storeUrl,
    this.surcharge,
    this.tax,
    this.telephone,
    this.total,
    this.userAgent,
    this.zone,
    this.zoneId,
    this.orderOfferTotal,
  })  : contents = contents ?? [],
        offerProduct = offerProduct ?? [];

  factory SaveOrderData.fromRawJson(String str) =>
      SaveOrderData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SaveOrderData.fromJson(Map<String, dynamic> json) => SaveOrderData(
        addressFormat: json["address_format"],
        addressId: json["address_id"],
        areaDetail: json["area_detail"],
        campaignId: json["campaign_id"],
        city: json["city"],
        comment: json["comment"],
        company: json["company"],
        contents: json["contents"] == null
            ? []
            : List<Content>.from(
                json["contents"].map((x) => Content.fromJson(x))),
        country: json["country"],
        countryId: json["country_id"],
        customField: json["custom_field"],
        customerId: json["customer_id"],
        deliveryDate: json["delivery_date"],
        deliveryTime: json["delivery_time"],
        discount: json["discount"],
        discountAmount: json["discount_amount"],
        discountCode: json["discount_code"],
        discountType: json["discount_type"],
        firstname: json["firstname"],
        flatSectorApartment: json["flat_sector_apartment"],
        gstInclude: json["gst_include"] ?? 0,
        landmark: json["landmark"],
        lastname: json["lastname"],
        locationId: json["location_id"],
        offerId: json["offer_id"],
        offerProduct: json["offer_product"] ?? [],
        orderStatus: json["order_status"],
        paymentAddress1: json["payment_address_1"],
        paymentAddress2: json["payment_address_2"],
        paymentAddressFormat: json["payment_address_format"],
        paymentCity: json["payment_city"],
        paymentCode: json["payment_code"],
        paymentCompany: json["payment_company"],
        paymentCustomField: json["payment_custom_field"],
        paymentFirstname: json["payment_firstname"],
        paymentLastname: json["payment_lastname"],
        paymentMethod: json["payment_method"],
        paymentPostcode: json["payment_postcode"],
        paymentTelephone: json["payment_telephone"],
        paymentZone: json["payment_zone"],
        postcode: json["postcode"],
        promoWalletUsed: json["promo_wallet_used"] ?? 0,
        recentCheckPassed: json["recent_check_passed"] ?? 0,
        orderOfferTotal: json["order_offer_total"] ?? 0,
        reward: json["reward"],
        rewardAmount: json["reward_amount"],
        sellerProduct: json["seller_product"],
        shipping: json["shipping"],
        sodexoAmount: json["sodexo_amount"],
        storeCode: json["store_code"],
        storeId: json["store_id"],
        storeName: json["store_name"],
        storeUrl: json["store_url"],
        surcharge: json["surcharge"],
        tax: json["tax"],
        telephone: json["telephone"],
        total: json["total"],
        userAgent: json["user_agent"],
        zone: json["zone"],
        zoneId: json["zone_id"],
      );

  Map<String, dynamic> toJson() => {
        "address_format": addressFormat,
        "address_id": addressId,
        "area_detail": areaDetail,
        "campaign_id": campaignId,
        "city": city,
        "comment": comment,
        "company": company,
        "contents": List<dynamic>.from(contents.map((x) => x.toJson())),
        "country": country,
        "country_id": countryId,
        "custom_field": customField,
        "customer_id": customerId,
        "delivery_date": deliveryDate,
        "delivery_time": deliveryTime,
        "discount": discount,
        "discount_amount": discountAmount,
        "discount_code": discountCode,
        "discount_type": discountType,
        "firstname": firstname,
        "flat_sector_apartment": flatSectorApartment,
        "gst_include": gstInclude,
        "landmark": landmark,
        "lastname": lastname,
        "location_id": locationId,
        "offer_id": offerId,
        "offer_product": offerProduct,
        "order_offer_total": orderOfferTotal,
        "order_status": orderStatus,
        "payment_address_1": paymentAddress1,
        "payment_address_2": paymentAddress2,
        "payment_address_format": paymentAddressFormat,
        "payment_city": paymentCity,
        "payment_code": paymentCode,
        "payment_company": paymentCompany,
        "payment_custom_field": paymentCustomField,
        "payment_firstname": paymentFirstname,
        "payment_lastname": paymentLastname,
        "payment_method": paymentMethod,
        "payment_postcode": paymentPostcode,
        "payment_telephone": paymentTelephone,
        "payment_zone": paymentZone,
        "postcode": postcode,
        "promo_wallet_used": promoWalletUsed,
        "recent_check_passed": recentCheckPassed,
        "reward": reward,
        "reward_amount": rewardAmount,
        "seller_product": sellerProduct,
        "shipping": shipping,
        "sodexo_amount": sodexoAmount,
        "store_code": storeCode,
        "store_id": storeId,
        "store_name": storeName,
        "store_url": storeUrl,
        "surcharge": surcharge,
        "tax": tax,
        "telephone": telephone,
        "total": total,
        "user_agent": userAgent,
        "zone": zone,
        "zone_id": zoneId,
      };
}

class Content {
  String? addItem;
  String? cOfferId;
  String? customMsg;
  String? discountLabel;
  String? discountText;
  String? giftItem;
  String? image;
  String? index;
  String? isOption;
  String? messageOnCake;
  String? messageOnCard;
  String? model;
  String? name;
  int offerEligible;
  dynamic offerProductId;
  List<dynamic> option;
  double? price;
  String? priceTotal;
  String? productId;
  String? productID;
  String? productName;
  String? quantity;
  String? shippingCharge;
  String? shippingOption;
  String? specialPrice;
  List<SubProduct>? subProduct;
  String? subtract;
  double? total;

  Content({
    this.addItem,
    this.cOfferId,
    this.customMsg,
    this.discountLabel,
    this.discountText,
    this.giftItem,
    this.image,
    this.index,
    this.isOption,
    this.messageOnCake,
    this.messageOnCard,
    this.model,
    this.name,
    this.offerEligible = 0,
    this.offerProductId,
    List<dynamic>? option,
    this.price,
    this.priceTotal,
    this.productId,
    this.productID,
    this.productName,
    this.quantity,
    this.shippingCharge,
    this.shippingOption,
    this.specialPrice,
    List<SubProduct>? subProduct,
    this.subtract,
    this.total,
  })  : option = option ?? [],
        subProduct = subProduct ?? [];

  factory Content.fromRawJson(String str) => Content.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Content.fromJson(Map<String, dynamic> json) => Content(
        addItem: json["add_item"],
        cOfferId: json["c_offer_id"],
        customMsg: json["custom_msg"],
        discountLabel: json["discount_label"],
        discountText: json["discount_text"],
        giftItem: json["gift_item"],
        image: json["image"],
        index: json["index"],
        isOption: json["is_option"],
        messageOnCake: json["message_on_cake"],
        messageOnCard: json["message_on_card"],
        model: json["model"],
        name: json["name"],
        offerEligible: json["offer_eligible"] ?? 0,
        offerProductId: json["offer_product_id"],
        option: json["option"] ?? [],
        price: json["price"]?.toDouble(),
        priceTotal: json["price_total"],
        productId: json["product_id"],
        productID: json["productID"],
        productName: json["productName"],
        quantity: json["quantity"],
        shippingCharge: json["shipping_charge"],
        shippingOption: json["shipping_option"],
        specialPrice: json["special_price"],
        subProduct: json["sub_product"] == null
            ? []
            : List<SubProduct>.from(
                json["sub_product"].map((x) => SubProduct.fromJson(x))),
        subtract: json["subtract"],
        total: json["total"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "add_item": addItem,
        "c_offer_id": cOfferId,
        "custom_msg": customMsg,
        "discount_label": discountLabel,
        "discount_text": discountText,
        "gift_item": giftItem,
        "image": image,
        "index": index,
        "is_option": isOption,
        "message_on_cake": messageOnCake,
        "message_on_card": messageOnCard,
        "model": model,
        "name": name,
        "offer_eligible": offerEligible,
        "offer_product_id": offerProductId,
        "option": option,
        "price": price,
        "price_total": priceTotal,
        "product_id": productId,
        "productID": productID,
        "productName": productName,
        "quantity": quantity,
        "shipping_charge": shippingCharge,
        "shipping_option": shippingOption,
        "special_price": specialPrice,
        "sub_product": List<dynamic>.from(subProduct!.map((x) => x.toJson())),
        "subtract": subtract,
        "total": total,
      };
}
