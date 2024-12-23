import 'dart:convert';

class ShippingCharge {
  bool? success;
  String? daysAllowedForCalendar;
  String? data;
  Offer? offer;
  int? showCoupon;
  String? currentWalletBalance;
  String? rewardMinimumAmount;
  String? currentRewardBalance;
  List<PaymentGetway>? paymentGetway;

  ShippingCharge({
    this.success,
    this.daysAllowedForCalendar,
    this.data,
    this.offer,
    this.showCoupon,
    this.currentWalletBalance,
    this.rewardMinimumAmount,
    this.currentRewardBalance,
    this.paymentGetway,
  });

  factory ShippingCharge.fromJson(String str) =>
      ShippingCharge.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ShippingCharge.fromMap(Map<String, dynamic> json) => ShippingCharge(
        success: json["success"],
        daysAllowedForCalendar: json["days_allowed_for_calendar"],
        data: json["data"].toString(),
        offer: json["offer"] == null ? null : Offer.fromMap(json["offer"]),
        showCoupon: json["show_coupon"],
        currentWalletBalance: json["current_wallet_balance"],
        rewardMinimumAmount: json["reward_minimum_amount"],
        currentRewardBalance: json["current_reward_balance"],
        paymentGetway: json["payment_getway"] == null
            ? []
            : List<PaymentGetway>.from(
                json["payment_getway"]!.map((x) => PaymentGetway.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "success": success,
        "days_allowed_for_calendar": daysAllowedForCalendar,
        "data": data,
        "offer": offer?.toMap(),
        "show_coupon": showCoupon,
        "current_wallet_balance": currentWalletBalance,
        "reward_minimum_amount": rewardMinimumAmount,
        "current_reward_balance": currentRewardBalance,
        "payment_getway": paymentGetway == null
            ? []
            : List<PaymentGetway>.from(paymentGetway!.map((x) => x.toMap())),
      };
}

class Offer {
  String? freeDeliveryAmount;
  List<OfferList>? offerList;
  int? isOffer;

  Offer({
    this.freeDeliveryAmount,
    this.offerList,
    this.isOffer,
  });

  factory Offer.fromJson(String str) => Offer.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Offer.fromMap(Map<String, dynamic> json) => Offer(
        freeDeliveryAmount: json["free_delivery_amount"],
        offerList: json["offer_list"] == null
            ? []
            : List<OfferList>.from(
                json["offer_list"]!.map((x) => OfferList.fromMap(x))),
        isOffer: json["is_offer"],
      );

  Map<String, dynamic> toMap() => {
        "free_delivery_amount": freeDeliveryAmount,
        "offer_list": offerList == null
            ? []
            : List<dynamic>.from(offerList!.map((x) => x.toMap())),
        "is_offer": isOffer,
      };
}

class OfferList {
  String? description;

  OfferList({
    this.description,
  });

  factory OfferList.fromJson(String str) => OfferList.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory OfferList.fromMap(Map<String, dynamic> json) => OfferList(
        description: json["description"],
      );

  Map<String, dynamic> toMap() => {
        "description": description,
      };
}

class PaymentGetway {
  String? title;
  String? paymentMethod;
  String? paymentCode;
  String? imageLocation;
  String? message;
  dynamic enable;
  bool isChecked = false;

  PaymentGetway({
    this.title,
    this.paymentMethod,
    this.paymentCode,
    this.imageLocation,
    this.message,
    this.enable,
  });

  factory PaymentGetway.fromJson(String str) =>
      PaymentGetway.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PaymentGetway.fromMap(Map<String, dynamic> json) => PaymentGetway(
        title: json["title"],
        paymentMethod: json["payment_method"],
        paymentCode: json["payment_code"],
        imageLocation: json["image_location"],
        message: json["message"],
        enable: json["enable"],
      );

  Map<String, dynamic> toMap() => {
        "title": title,
        "payment_method": paymentMethod,
        "payment_code": paymentCode,
        "image_location": imageLocation,
        "message": message,
        "enable": enable,
      };
}
