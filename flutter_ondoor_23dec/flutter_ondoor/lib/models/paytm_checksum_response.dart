import 'dart:convert';

class PaytmChecksumresponse {
  int? orderid;
  String? amount;
  String? currency;
  String? mid;
  String? checksumhash;
  String? callbackUrl;
  bool? success;
  String? message;
  String? signature;
  String? txnToken;
  String? paytmChecksumresponseMid;
  int? orderId;

  PaytmChecksumresponse({
    this.orderid,
    this.amount,
    this.currency,
    this.mid,
    this.checksumhash,
    this.callbackUrl,
    this.success,
    this.message,
    this.signature,
    this.txnToken,
    this.paytmChecksumresponseMid,
    this.orderId,
  });

  factory PaytmChecksumresponse.fromRawJson(String str) =>
      PaytmChecksumresponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PaytmChecksumresponse.fromJson(Map<String, dynamic> json) =>
      PaytmChecksumresponse(
        orderid: json["ORDERID"] ?? 0,
        amount: json["AMOUNT"] ?? "",
        currency: json["CURRENCY"] ?? "",
        mid: json["MID"] ?? "",
        checksumhash: json["CHECKSUMHASH"] ?? "",
        callbackUrl: json["callbackUrl"] ?? "",
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        signature: json["signature"] ?? "",
        txnToken: json["txnToken"] ?? "",
        paytmChecksumresponseMid: json["mid"] ?? "",
        orderId: json["orderId"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "ORDERID": orderid,
        "AMOUNT": amount,
        "CURRENCY": currency,
        "MID": mid,
        "CHECKSUMHASH": checksumhash,
        "callbackUrl": callbackUrl,
        "success": success,
        "message": message,
        "signature": signature,
        "txnToken": txnToken,
        "mid": paytmChecksumresponseMid,
        "orderId": orderId,
      };
}
