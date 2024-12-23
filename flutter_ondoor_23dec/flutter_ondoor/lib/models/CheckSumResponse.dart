// To parse this JSON data, do
//
//     final checkSumResponse = checkSumResponseFromJson(jsonString);

import 'dart:convert';

CheckSumResponse checkSumResponseFromJson(String str) => CheckSumResponse.fromJson(json.decode(str));

String checkSumResponseToJson(CheckSumResponse data) => json.encode(data.toJson());

class CheckSumResponse {
  String vpa;
  String vpaname;
  String merchantcode;
  String orderid;
  String amount;
  String pspid;
  String notes;
  String minamount;
  String currency;
  String txnurl;
  String deeplink;
  // String deeplinkIos;
  String checksumhash;
  // String checksumhashIos;
  String success;

  CheckSumResponse({
    required this.vpa,
    required this.vpaname,
    required this.merchantcode,
    required this.orderid,
    required this.amount,
    required this.pspid,
    required this.notes,
    required this.minamount,
    required this.currency,
    required this.txnurl,
    required this.deeplink,
    // required this.deeplinkIos,
    required this.checksumhash,
    // required this.checksumhashIos,
    required this.success,
  });

  factory CheckSumResponse.fromJson(Map<String, dynamic> json) => CheckSumResponse(
    vpa: json["VPA"],
    vpaname: json["VPANAME"],
    merchantcode: json["MERCHANTCODE"],
    orderid: json["ORDERID"],
    amount: json["AMOUNT"],
    pspid: json["PSPID"],
    notes: json["NOTES"],
    minamount: json["MINAMOUNT"],
    currency: json["CURRENCY"],
    txnurl: json["TXNURL"],
    deeplink: json["DEEPLINK"],
    // deeplinkIos: json["DEEPLINK_IOS"],
    checksumhash: json["CHECKSUMHASH"],
    // checksumhashIos: json["CHECKSUMHASH_IOS"],
    success: json["success"],
  );

  Map<String, dynamic> toJson() => {
    "VPA": vpa,
    "VPANAME": vpaname,
    "MERCHANTCODE": merchantcode,
    "ORDERID": orderid,
    "AMOUNT": amount,
    "PSPID": pspid,
    "NOTES": notes,
    "MINAMOUNT": minamount,
    "CURRENCY": currency,
    "TXNURL": txnurl,
    "DEEPLINK": deeplink,
    // "DEEPLINK_IOS": deeplinkIos,
    "CHECKSUMHASH": checksumhash,
    // "CHECKSUMHASH_IOS": checksumhashIos,
    "success": success,
  };
}
