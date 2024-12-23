import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../widgets/MyDialogs.dart';

class UpiHandler {
  static const platform = MethodChannel('com.ondoor/upi');

  static Future<bool> getUpiAppsInstalled(BuildContext context,String deepLink,Function callback) async {
    try {
      final result = await platform.invokeMethod('getUpiAppsInstalled', {
        'deepLink': deepLink,
        'blacklist':['com.olacabs.customer', 'com.whatsapp'],
      });


      if (result == "SUCCESS") {
        print("Payment Successful");
        callback();
        // Handle success case
        return true;
      } else {
        print("Payment Failed");
          MyDialogs.showAlertDialog(
              context, "No response from UPI payment.\n Please try again", "Okay", "", () {
            Navigator.pop(context);
          }, () {
            Navigator.pop(context);
          });
        return false;
      }
      print(result);
    } on PlatformException catch (e) {
      print("Failed to handle UPI deep link: '${e.message}'.");
      return false;
    }
  }
}