import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ondoor/screens/AuthScreen/Register/RegisterScreen.dart';
import 'package:ondoor/screens/HomeScreen/HomePageScreen.dart';
import 'package:ondoor/screens/SplashScreen/SplashScreen.dart';
import 'package:ondoor/services/Notifications/NotificationService.dart';
import 'package:ondoor/services/Notifications/fcm_config.dart';
import 'package:ondoor/utils/Comman_Loader.dart';
// import 'package:ondoor/utils/Comman_Loader.dart';
import 'package:ondoor/utils/Connection.dart';
import 'package:ondoor/utils/Utility.dart';
import 'package:ondoor/utils/themeData.dart';
import 'package:ondoor/widgets/AppWidgets.dart';
import 'package:provider/provider.dart';

import 'services/ApiServices.dart';
import 'services/Navigation/route_generator.dart';
import 'services/NavigationService.dart';

NavigationService navigationService = NavigationService();
FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: "AIzaSyCy7V0h_4ZF2OS4AlV6s_faKRJE3AdVDWc",
              appId: "1:69414575810:android:480644acc28a3182",
              messagingSenderId: "",
              projectId: "ondoor-2542a"))
      .then(
    (value) {
      print("FIREBASE APP ${value}");
    },
  );
  //
  await NotificationService().initLocalNotification();
  await FcmConfig().configNotification();

 FirebaseMessaging.onBackgroundMessage(backgroundHandler);






  await ApiProvider().initializeDio();
  CommanLoader().configEasyLoading();
  OndoorThemeData.setStatusBarColor();
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ConnectionStatus(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ondoor Concept',
      debugShowCheckedModeBanner: false,
      theme: OndoorThemeData.lightTheme,
      navigatorKey: navigationService.navigatorKey,

      builder: (context, child) {
        child = EasyLoading.init()(context, child);
        return MediaQuery(
          data: Appwidgets().mediaqueryDataforWholeApp(context: context),
          child: child,
        );
      },
      // home: Homepagescreen(),
      home: SplashScreen(),
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
