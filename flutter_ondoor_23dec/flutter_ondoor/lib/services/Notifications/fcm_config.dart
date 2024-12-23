import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ondoor/constants/ImageConstants.dart';
import 'package:ondoor/main.dart';
import 'package:ondoor/services/Navigation/routes.dart';
import 'package:ondoor/utils/Utility.dart';
import 'package:ondoor/widgets/AppWidgets.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../constants/Constant.dart';
import '../../utils/SizeConfig.dart';
import '../../utils/colors.dart';
import '../../utils/sharedpref.dart';
import '../NetworkConfig.dart';
import 'NotificationService.dart';

@pragma('vm:entry-point')
Future<void> backgroundHandler(RemoteMessage message) async {

  await Firebase.initializeApp().then((value){
    print("inside background handler---------->>>>>>>>>>>GG0 ${message.data}");
  });
  print("inside background handler---------->>>>>>>>>>>GG1 ${message.data}");
   try {
    if (message.data != null) {
    //  print('BACKGROUND MESSAGE TITLE AND BODY :- ${message.notification?.title} | ${message.notification?.body}');
     // Constants.notificationdata=message.data.toString();

      // WidgetsBinding.instance.addPostFrameCallback((_) async {
        //_handleNotificationTap(message);

        // await SharedPref.setStringPreference(
        //     Constants.sp_notificationdata, message.data.toString());
        // print("inside background handler---------->>>>>>>>>>>GG2 ${await SharedPref.getStringPreference(Constants.sp_notificationdata)}");
        // print("inside background handler---------->>>>>>>>>>>GG3 ${Constants.notificationdata}");

      // });

      //await SharedPref.setStringPreference(Constants.sp_notificationdata, message.data.toString());
      /*  if (message.data.toString().contains("image")) {


        Map<String, dynamic> map = message.data;

        var tile = map["title"];
        var body = map["message"];


        var image = map["image"];
        print("background >> 2 $tile");
        print("background >> 2 $body");
        NotificationService().showNotificationWithImage(
            id: message.data.hashCode,
            title:tile,
            body: body,
            payload: message.data.toString(),

            imageUrl: image);
      }
      else
      {



        Map<String, dynamic> map = message.data;

        var tile = map["title"];
        var body = map["message"];

        print("background >> 2 ${map["title"]}");

        NotificationService().showNotificationWithoutImage(
            id: message.data.hashCode,
            title: tile,
            body:body.toString(),
            payload: message.data.toString());
      }*/
    }
  } catch (e) {
    print("FCM BACKGROUND HANDLER EXCEPTION :- $e");
  }
}

class FcmConfig {
  String fcmToken = "";
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  static NotificationSettings? settings;
  final GlobalKey _key = GlobalKey();
  OverlayEntry? _overlayEntry;

  ///ask permission from the user to display notifications
  requestPermission() async {
    await firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        sound: true,
        provisional: false,
        criticalAlert: false);
  }

  Future<void> configNotification() async {
    final PermissionStatus status = await Permission.notification.request();
    if (status.isGranted) {
      //fcmToken =
      firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          print("INITIAL MESSAGETerminate *** : ${message.data}");

          WidgetsBinding.instance.addPostFrameCallback((_) async {
            //_handleNotificationTap(message);

            await SharedPref.setStringPreference(
                Constants.sp_notificationdata, message.data.toString());
          });
        }
      });

      await NotificationService()
          .flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(NotificationService.channel);

      FirebaseMessaging.onMessage.listen((event) async {
       // print("message : ${event.notification?.title} | ${event.notification?.body}");
        try {
          print("REMOTE MESSAGE ${event.toMap()}");
          print("REMOTE MESSAGE ${event.data.toString()}");


          // await SharedPref.setStringPreference(
          //     Constants.sp_notificationdata, event.data.toString());
          FcmConfig.onMessage(event);
        }catch(e)
        {
          print("REMOTE MESSAGE Execptio ${e}");
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((event) {
        print(
            "on message opened app : ${event.notification?.title} | ${event.notification?.body}");
        print("on message opened app : ${event.data}");
        _handleNotificationTap(event);
      });

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (status.isDenied) {
      Appwidgets.showToastMessage(status.name);
    } else if (status.isPermanentlyDenied) {
      // Notification permissions permanently denied, open app settings
      await openAppSettings();
    }
    print("Permission Status : $status");
  }

  static Future<void> onMessage(RemoteMessage message) async {
 //   print("Image Url >> ${message.notification?.android?.imageUrl}");
    print("onMessage >>1 ");
   // if (message.data.toString().contains("image")) {
      //print("onMessage >> 2 ");
      Map<String, dynamic> map = message.data;

      var tile = map["title"];
      var body = map["message"];
      print("background >> 2 $tile");
      print("background >> 2 $body");
      NotificationService().showNotificationWithImage(
          id: message.data.hashCode,
          title: tile,
          body: body,
          payload: message.data.toString(),
          imageUrl:  "");
  //  }
/*    else
      {



        Map<String, dynamic> map = message.data;

        var tile = map["title"];
        var body = map["message"];

        print("onMessage >> 2 ${map["title"]}");

        NotificationService().showNotificationWithoutImage(
            id: message.notification.hashCode,
            title: tile,
            body:body.toString(),
            payload: message.data.toString());
      }*/



  }

  void _handleNotificationTap(RemoteMessage message) async {
    if (message.data.isNotEmpty) {
      await DioFactory().getDio();
      // Example: Navigate to a specific screen based on notification data
      String customer_id =
          await SharedPref.getStringPreference(Constants.sp_CustomerId);
      String token_type =
          await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
      String access_token =
          await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);

      String token = "$token_type $access_token";
      if (token == ' ' && customer_id == '') {
        await SharedPref.setStringPreference(
            Constants.sp_VerifyRoute, Routes.notification_center);
        Navigator.pushNamed(navigationService.navigatorKey.currentContext!,
                Routes.register_screen,
                arguments: Routes.home_page)
            .then(
          (value) {
            Appwidgets.setStatusBarColor();
          },
        );
      } else {
        // Decode the JSON string into a Map
        try {
          Map<String, dynamic> data = message.data;

          // Access values directly
          String type = data['type'];

          print('_handleNotificationTap Type: $type');

          if (type == "Order") {
            String orderId = data['order_id'];
            print('_handleNotificationTap Order ID: $orderId');
            Navigator.pushNamed(navigationService.navigatorKey.currentContext!,
                Routes.order_history_detail,
                arguments: {"order_id": orderId,"order_type":""});
          }

          else if(type=="General")
          {
            //String orderId = data2['order_id'];
          //  print('checkNotificationRoute Order ID: $orderId');

            Navigator.pushNamed(navigationService.navigatorKey.currentContext!,
                Routes.notification_center)
                .then(
                  (value) {
                Appwidgets.setStatusBarColor();
              },
            );
          }

          else {
            Navigator.pushNamed(navigationService.navigatorKey.currentContext!,
                    Routes.home_page)
                .then(
              (value) {
                Appwidgets.setStatusBarColor();
              },
            );
          }
        } catch (e) {
          Navigator.pushNamed(navigationService.navigatorKey.currentContext!,
                  Routes.notification_center)
              .then(
            (value) {
              Appwidgets.setStatusBarColor();
            },
          );
        }
      }
    }
  }
}


















