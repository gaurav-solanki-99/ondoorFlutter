import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:googleapis_auth/auth_io.dart' as googleApiAuth;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:ondoor/database/database_helper.dart';
import 'package:ondoor/main.dart';
import 'package:ondoor/models/AllProducts.dart';
import 'package:ondoor/utils/sharedpref.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:googleapis_auth/auth_io.dart' as googleApiAuth;

import '../constants/Constant.dart';
import '../database/dbconstants.dart';
import 'colors.dart';
import 'package:http/http.dart' as http;
class MyUtility {
  static checkOfferSubProductUpdate(
      ProductUnit dummyData, ProductUnit statemodel, DatabaseHelper dbhelper) {
    ProductUnit unit = ProductUnit();

    if (dummyData.subProduct!.subProductDetail!.length > 0) {
      List<ProductUnit>? listsubproduct =
          dummyData.subProduct!.subProductDetail!;

      for (int x = 0; x < listsubproduct.length; x++) {
        getCartQuantity(listsubproduct[x].productId!, dbhelper).then((value) {
          debugPrint(
              "${listsubproduct[x].name} Sub Product Quantity quanityt ${value}");
          listsubproduct[x].addQuantity = value;
        });
      }

      if (dummyData.productId == statemodel.productId) {
        dummyData.addQuantity = statemodel.addQuantity;
      }

      dummyData.subProduct!.subProductDetail = listsubproduct;
    }

    return dummyData;
  }

  Future<String> getFcmToken() async {
    String token = " ";
    try {
      token = await firebaseMessaging.getToken() ?? "";
      print("FCM TOKEN ${token}");
    } catch (e) {
      debugPrint("exception : $e");
    }
    await SharedPref.setStringPreference(Constants.fcmToken, token);
    return token;
  }

  static Future<String> getServerToken() async {
    try {
      const String firebaseMessagingScopeUrl =
          "https://www.googleapis.com/auth/firebase.messaging";

      //the scope url for the firebase messaging
      final firebaseMessagingScope = [firebaseMessagingScopeUrl];

      final String response =
          await rootBundle.loadString('assets/json/firebase_server.json');
      final data = await json.decode(response);

      final client = await googleApiAuth.clientViaServiceAccount(
          googleApiAuth.ServiceAccountCredentials.fromJson(data),
          firebaseMessagingScope);

      final accessToken = client.credentials.accessToken.data;
      print("access token : $accessToken");
      await SharedPref.setStringPreference(Constants.serverToken, accessToken);
      return accessToken;
    } catch (e) {
      throw Exception('Error getting access token : $e');
    }
  }

  static checkOfferSubProductLoad(
      ProductUnit dummyData, DatabaseHelper dbhelper) {
    // ProductUnit unit=ProductUnit();

    List<ProductUnit>? listsubproduct = [];
    if (dummyData!.cOfferId != 0 && dummyData.cOfferId != null) {
      debugPrint("***********************");
      if (dummyData.subProduct != null) {
        log("***********************>>>>>>>>>>>>>>>>" +
            dummyData.subProduct!.toJson());
        if (dummyData.subProduct!.subProductDetail!.length > 0) {
          listsubproduct = dummyData.subProduct!.subProductDetail!;

          for (int x = 0; x < listsubproduct.length; x++) {
            getCartQuantity(listsubproduct![x].productId!, dbhelper)
                .then((value) {
              debugPrint(
                  "${listsubproduct![x].name} Sub Product Quantity quanityt ${value}");
              listsubproduct[x].addQuantity = value;
            });
          }

          dummyData.subProduct!.subProductDetail = listsubproduct;
        }
      }
    }

    return listsubproduct;
  }

  static Future<int> getCartQuantity(String id, DatabaseHelper dbHelper) async {
    final allRows = await dbHelper.queryAllRowsCardProducts();
    for (final row in allRows) {
      String id2 = row[DBConstants.PRODUCT_ID].toString();

      if (id == id2) {
        return row[DBConstants.QUANTITY];
      }
    }
    return 0;
  }

  static Future<String> downloadAndSaveImage(String url, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';

    if (await File(filePath).exists() == false) {
      final response = await http.get(Uri.parse(url));

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
    }

    return filePath;
  }
}
