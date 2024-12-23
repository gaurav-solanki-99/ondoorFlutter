import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';

class UpiPaymentIntegration {
  Future<Map<dynamic, dynamic>?> payment(
      mid, orderId, payamount, token, callbackurl, isstaging) async {
    Map<dynamic, dynamic> result = {};
    try {
      await AllInOneSdk.startTransaction(
              mid.toString(),
              orderId.toString(),
              payamount.toString(),
              token.toString(),
              callbackurl.toString(),
              isstaging,
              false)
          .then((value) async {
        debugPrint("Transaction Started!!   ${value.toString()}");
        result = value!;
      }).catchError((onError, stackTrace) {
        if (onError is PlatformException) {
          result = {"error": onError.details};
          log("====>result2 $onError");
        } else {
          result = {"error": onError};
          log("====>result3 $onError");
        }
      });
    } catch (err, stackTrace) {
      result = {"error": err.toString()};
      log("====>result4 $err");
    }
    log("====>final result $result");
    return result;
  }
}
