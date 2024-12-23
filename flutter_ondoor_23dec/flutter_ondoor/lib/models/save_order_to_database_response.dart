import 'dart:convert';

class SaveOrdertoDatabaseResponse {
  bool? success;
  Ratings? ratings;
  String? coupon;
  int? orderId;
  dynamic total;
  String? deliveryTime;
  String? deliveryDate;
  String? message;
  String? error;
  String? data;
  String? errorStatus;
  int? walletBalance;
  dynamic? rewardBalance;
  String? promoWallet;

  SaveOrdertoDatabaseResponse({
    this.success,
    this.ratings,
    this.coupon,
    this.orderId,
    this.total,
    this.deliveryTime,
    this.deliveryDate,
    this.message,
    this.error,
    this.data,
    this.errorStatus,
    this.walletBalance,
    this.rewardBalance,
    this.promoWallet,
  });

  factory SaveOrdertoDatabaseResponse.fromRawJson(String str) =>
      SaveOrdertoDatabaseResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());
  // {
  // "success": false,
  // "error": "Dear Customer, you made a recent attempt for online payment. Please allow us 10 mins processing time for your purchase.",
  // "data": "Dear Customer, you made a recent attempt for online payment. Please allow us 10 mins processing time for your purchase.",
  // "error_status": "3",
  // "wallet_balance": 0,
  // "reward_balance": 0,
  // "promoWallet": "0.00"
  // }
  factory SaveOrdertoDatabaseResponse.fromJson(Map<String, dynamic> json) =>
      SaveOrdertoDatabaseResponse(
        success: json["success"] ?? false,
        ratings: json["ratings"] == null
            ? Ratings()
            : Ratings.fromJson(json["ratings"]),
        coupon: json["Coupon"] ?? "",
        orderId: json["order_id"] ?? 0,
        total: json["Total"] ?? "",
        deliveryTime: json["delivery_time"] ?? "",
        deliveryDate: json["delivery_date"] ?? "",
        message: json["message"] ?? "",
        error: json["error"] ?? "",
        data: json["data"] ?? "",
        errorStatus: json["error_status"] ?? "",
        walletBalance: json["wallet_balance"] ?? 0,
        rewardBalance: json["reward_balance"] ?? "",
        promoWallet: json["promoWallet"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "ratings": ratings?.toJson(),
        "Coupon": coupon,
        "order_id": orderId,
        "Total": total,
        "delivery_time": deliveryTime,
        "delivery_date": deliveryDate,
        "message": message,
        "error": error,
        "data": data,
        "error_status": errorStatus,
        "wallet_balance": walletBalance,
        "reward_balance": rewardBalance,
        "promoWallet": promoWallet,
      };
}

class Ratings {
  String? ratingPopupVisible;
  int? showRating;
  String? ratingMessage;
  String? ratingRiderctUrl;
  String? ratingText;

  Ratings({
    this.ratingPopupVisible,
    this.showRating,
    this.ratingMessage,
    this.ratingRiderctUrl,
    this.ratingText,
  });

  factory Ratings.fromRawJson(String str) => Ratings.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Ratings.fromJson(Map<String, dynamic> json) => Ratings(
        ratingPopupVisible: json["rating_popup_visible"],
        showRating: json["show_rating"],
        ratingMessage: json["rating_message"],
        ratingRiderctUrl: json["rating_riderct_url"],
        ratingText: json["rating_text"],
      );

  Map<String, dynamic> toJson() => {
        "rating_popup_visible": ratingPopupVisible,
        "show_rating": showRating,
        "rating_message": ratingMessage,
        "rating_riderct_url": ratingRiderctUrl,
        "rating_text": ratingText,
      };
}
