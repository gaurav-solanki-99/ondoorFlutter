import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:ondoor/constants/ImageConstants.dart';
import 'package:ondoor/models/add_notification_response.dart';
import 'package:ondoor/services/ApiServices.dart';
import 'package:ondoor/utils/colors.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../constants/Constant.dart';
import '../../main.dart';
import '../../utils/sharedpref.dart';
import '../../widgets/AppWidgets.dart';
import '../Navigation/routes.dart';
import '../NetworkConfig.dart';

class NotificationService {
  static const channelId = "com.ondoor.app";
  static const channelName = "CHANNEL_NAME";
  static const channelDescription = "CHANNEL_DESCRIPTION";

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // INITIALIZING
  Future<void> initLocalNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        // This will handle taps for notifications received while the app is in the foreground.
        print("onDidReceiveNotificationResponse $notificationResponse");
        _handleNotificationTap(notificationResponse);
      },
    );
  }

  static AndroidNotificationChannel channel = const AndroidNotificationChannel(
      channelId, channelName,
      description: channelDescription,
      importance: Importance.max,
      playSound: true);

  // Download image from network
  Future<String> _downloadAndSaveImage(String url, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final response = await http.get(Uri.parse(url));

    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  Future<void> showNotificationWithImage(
      {int? id,
      String? title,
      String? body,
      String? payload,
      required String imageUrl}) async {
    if (imageUrl != "") {
      final String largeImagePath =
          await _downloadAndSaveImage(imageUrl, 'large_image.jpg');
      final BigPictureStyleInformation bigPictureStyleInformation =
          BigPictureStyleInformation(FilePathAndroidBitmap(largeImagePath),
              contentTitle: title,
              summaryText: body,
              hideExpandedLargeIcon:
                  false); // Keep large icon visible in expanded view

      final NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            icon: '@drawable/logo_new', // Small app icon in the status bar
            color: Color(0xffC01414),
            //largeIcon: const FilePathAndroidBitmap(Imageconstants.ondoor_logo),
            channelDescription: channel.description,
            importance: Importance.max,
            priority: Priority.high,
            styleInformation:
                bigPictureStyleInformation, // Set the big picture style here
            visibility: NotificationVisibility.public,

            playSound: true,
          ),
          iOS: const DarwinNotificationDetails());

      // Show the notification
      await flutterLocalNotificationsPlugin
          .show(id!, title, body, notificationDetails, payload: payload);
    } else {
      final NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          icon: '@drawable/logo_new',
          color: Color(0xffC01414),
          //  largeIcon: const FilePathAndroidBitmap(Imageconstants.ondoor_logo),
          channelDescription: channel.description,
          importance: Importance.max,
          priority: Priority.high,
          visibility: NotificationVisibility.public,
          playSound: true,
          styleInformation: BigTextStyleInformation(
            body ?? '',
            contentTitle: title, // Title of the notification
          ),
        ),
        iOS: const DarwinNotificationDetails(),
      );

      // Show the notification
      await flutterLocalNotificationsPlugin
          .show(id!, title, body, notificationDetails, payload: payload);
    }
  }

  Future<void> showNotificationWithoutImage({
    int? id,
    String? title,
    String? body,
    String? payload,
  }) async {
    final NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        icon: '@drawable/logo_new',
        color: Color(0xffC01414),
        //largeIcon: const FilePathAndroidBitmap(Imageconstants.ondoor_logo),
        channelDescription: channel.description,
        importance: Importance.max,
        priority: Priority.high,
        visibility: NotificationVisibility.public,
        playSound: true,
        styleInformation: BigTextStyleInformation(
          body ?? '',
          contentTitle: title ?? "", // Title of the notification
        ),
      ),
      iOS: const DarwinNotificationDetails(),
    );

    // Show the notification
    await flutterLocalNotificationsPlugin
        .show(id!, title, body, notificationDetails, payload: payload);
  }

  void _handleNotificationTap(NotificationResponse message) async {
    print("onDidReceiveNotificationResponse 1 ${message.payload}");
    print("onDidReceiveNotificationResponse 1 ${message.input}");
    print(
        "onDidReceiveNotificationResponse 1 ${message.notificationResponseType}");
    print("onDidReceiveNotificationResponse 1 ${message}");

    if (message.payload.toString() != "" && message != null) {
      print("onDidReceiveNotificationResponse 1a ${message.payload}");

      await SharedPref.setStringPreference(
          Constants.sp_notificationdata, message.payload.toString());
    }

    log(message.toString());

    print("onDidReceiveNotificationResponse 2");
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
      // Navigator.pushNamed(navigationService.navigatorKey.currentContext!,
      //         Routes.notification_center)
      //     .then(
      //   (value) {
      //     Appwidgets.setStatusBarColor();
      //   },
      // );
      // await SharedPref.setStringPreference(
      //     Constants.sp_notificationdata, message.payload.toString());

      var data =
          await SharedPref.getStringPreference(Constants.sp_notificationdata);

      print("onDidReceiveNotificationResponse 3 ${data}");

      Navigator.pushNamed(
        navigationService.navigatorKey.currentContext!,
        Routes.home_page,
      ).then(
        (value) {
          Appwidgets.setStatusBarColor();
        },
      );

      // Today 20 Nov
    }
  }
}
