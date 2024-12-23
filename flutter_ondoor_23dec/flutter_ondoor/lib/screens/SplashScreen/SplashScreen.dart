// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ondoor/constants/Constant.dart';
import 'package:ondoor/constants/StringConstats.dart';
import 'package:ondoor/models/validate_app_version_response.dart';
import 'package:ondoor/screens/HomeScreen/HomePageScreen.dart';
import 'package:ondoor/screens/SplashScreen/splash_bloc/splash_events.dart';
import 'package:ondoor/screens/SplashScreen/splash_bloc/splash_screen_bloc.dart';
import 'package:ondoor/screens/SplashScreen/splash_bloc/splash_states.dart';
import 'package:ondoor/services/ApiServices.dart';
import 'package:ondoor/utils/Connection.dart';
import 'package:ondoor/utils/colors.dart';
import 'package:ondoor/utils/sharedpref.dart';
import 'package:ondoor/widgets/AppWidgets.dart';
import 'package:ondoor/widgets/MyDialogs.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../main.dart';
import '../../services/Navigation/routes.dart';
import '../../services/NetworkConfig.dart';
import '../../utils/Comman_Loader.dart';
import '../../utils/themeData.dart';
import '../../widgets/Custom_Widgets.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen();

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _imageAnimation;
  SplashScreenBloc splashScreenBloc = SplashScreenBloc();

  // @override
  // void initState() {
  //   OndoorThemeData.setStatusBarColor();
  //   super.initState();
  // }

  @override
  void dispose() {
    _controller.dispose();
    CommanLoader().dismissEasyLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocBuilder(
      bloc: splashScreenBloc,
      builder: (context, state) {
        if (state is SplashInitialState) {
          startSplash(context);
        }
        if (state is SplashStartState) {
          return Center(
            child: CustomPaint(
              painter:
                  CirclePainter(state.animation.value, ColorName.ColorPrimary),
              child: SizedBox(
                width: state.imageAnimation.value,
                height: state.imageAnimation.value,
                child: Image.asset(
                  'assets/images/ondoor.png',
                ),
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    ));
  }

  Future<void> startSplash(context) async {
    _controller = AnimationController(
      vsync: this,
      animationBehavior: AnimationBehavior.normal,
      duration: const Duration(milliseconds: 3000),
    )..addListener(() {
        splashScreenBloc.add(SplashStartEvent(
            animation: _animation, imageAnimation: _imageAnimation));
      });

    _animation = Tween<double>(begin: 20, end: 1000).animate(_controller);
    _imageAnimation = Tween<double>(begin: 28, end: 230).animate(_controller);
    _controller.forward();

    callValidateAppApi(context);
  }

  callValidateAppApi(context) async {
    if (await Network.isConnected()) {
      Future.delayed(
        const Duration(milliseconds: 2000),
        () async {
          debugPrint("ANIMATION STATUS ${_controller.status}");
          var validateApp = await ApiProvider().validateAppVersionApi();
          // await SharedPref.setStringPreference(
          //     Constants.CURRENTLY_SERVING_CITY_TEXT,
          //     validateApp.currentlyServedCityTxt);
          if (validateApp != null) {
            if (validateApp.success == "false") {
              showAppvalidationDialog(validateApp);
            }
            if (validateApp.success == "warning") {
              showAppvalidationDialog(validateApp);
            }
            if (validateApp.success == "true") {
              userNavigationFunction(validateApp, context);
            }
          }
        },
      );
    } else {
      MyDialogs.showInternetDialog(context, () {
        Navigator.pop(context);
        callValidateAppApi(context);
      });
    }
  }

  @override
  void initState() {
    Appwidgets.setStatusBarColor();
    fetchOldSharedPreferences();
    super.initState();
  }

  void showAppvalidationDialog(ValidateAppVersionResponse validateApp) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Dialog(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 20,
                children: [
                  Center(
                    child: Text(
                      StringContants.lbl_app_update_required,
                      style: Appwidgets().commonTextStyle(ColorName.black),
                    ),
                    // child: Appwidgets.Text_20(
                    //     "App Update Required!", ColorName.black),
                  ),
                  Center(
                    child: Appwidgets.Text_15(
                        StringContants.lbl_we_have_added_newFeatures,
                        ColorName.black,
                        TextAlign.center),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Appwidgets.appUpdateDialogButton("Update", () {
                        //TODO to uncomment below line for testing & development it should uncommented for live:- Rohit Ayre
                        debugPrint("update jhfdhf");
                        openPlayStore();
                        // userNavigationFunction(validateApp);
                      }, ColorName.ColorPrimary),
                      validateApp.success == "false"
                          ? const SizedBox()
                          : Appwidgets.appUpdateDialogButton("Later", () {
                              debugPrint("Later jhfdhf");
                              // Navigator.pop(context);
                              userNavigationFunction(validateApp, context);

                              debugPrint("Gauravddd");

                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) =>
                              //             const Homepagescreen()));
                            }, ColorName.grey)
                    ],
                  )
                ],
              ),
            ),
          ),
        );

        /*
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          content: Appwidgets.AppUpdationText(
              "Please Update the App", ColorName.black),
          title: Appwidgets.Text_20("New Version Available", ColorName.black),
          actions: [
            ElevatedButton(
                onPressed: () async {

                },
                child: Appwidgets.Text_15(
                    "Update", ColorName.ColorBagroundPrimary)),
            ElevatedButton(
                onPressed: () {

                },
                child: Appwidgets.Text_15(
                    "Later", ColorName.ColorBagroundPrimary)),
          ],
        );
*/
      },
    );
  }

  void openPlayStore() async {
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        final url = Uri.parse(Platform.isAndroid
            ? "https://play.google.com/store/apps/details?id=com.ondoor.app&pcampaignid=web_share"
            : "");
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } on PlatformException catch (e) {
        debugPrint('Failed to launch URL: ${e.message}');
        // Handle error in UI or retry logic
      }
    }
  }

  void userNavigationFunction(
      ValidateAppVersionResponse validateApp, context) async {
    // if (_controller.status == AnimationStatus.completed) {
    String street = await splashScreenBloc.getAddress();
    String locality = await splashScreenBloc.getLocality();
    var check = await splashScreenBloc.checkPreivousData();
    String token = await splashScreenBloc.getTokenAndroid();

    print("PreviousData ${check}");
    print("PreviousData ${token}");
    print("STREET ${street}");
    print("LOCALITY ${locality}");
    print("LOCALITY ${locality}");
    if (street != "" && locality != "") {
      debugPrint("STREET ADDRESS ${street}, ${locality}");

      try {
        Navigator.of(context).pushReplacementNamed(Routes.home_page);
      } catch (e) {
        debugPrint("Exeption " + e.toString());
      }
    } else {
      debugPrint("ADDRESS ${street}, ${locality}");
      Navigator.of(context).pushReplacementNamed(Routes.location_screen,
          arguments: Routes.splashscreen);
    }
  }

//
// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//       body: BlocBuilder(
//     bloc: splashScreenBloc,
//     builder: (context, state) {
//       if (state is SplashInitialState) {
//         startSplash();
//       }
//       if (state is SplashStartState) {
//         return Center(
//           child: CustomPaint(
//             painter: CirclePainter(state.animation.value),
//             child: SizedBox(
//               width: state.imageAnimation.value,
//               height: state.imageAnimation.value,
//               child: Image.asset(
//                 'assets/images/ondoor.png',
//               ),
//             ),
//           ),
//         );
//       } else {
//         return const SizedBox();
//       }
//     },
//   ));
// }

  Future<void> fetchOldSharedPreferences() async {
    print("fetchOldSharedPreferences start >>  ");
    const platform = MethodChannel('com.ondoor/shared_prefs');

    try {
      final Map<dynamic, dynamic>? oldPrefs =
          await platform.invokeMethod('getOldPreferences');

      print("fetchOldSharedPreferences result : $oldPrefs");
      if (oldPrefs != null) {
        oldPrefs.forEach((key, value) {
          print('Key: $key, Value: $value');

          if (key == "ACCESS_TOKEN") {
            var data = value;
            if (data != "" && data != null) {
              SharedPref.setStringPreference(Constants.sp_AccessTOEKN, data);
            }
          }
          if (key == "TOKEN_TYPE") {
            var data = value;

            if (data != "" && data != null) {
              SharedPref.setStringPreference(Constants.sp_TOKENTYPE, data);
            }
          }
          if (key == "CURRENT_LOCATION_ID") {
            var data = value;
            if (data != "" && data != null) {
              SharedPref.setStringPreference(Constants.LOCATION_ID, data);
            }
          }
          if (key == "STOREID") {
            var data = value;
            if (data != "" && data != null) {
              SharedPref.setStringPreference(Constants.STORE_ID, data);
            }
          }
          if (key == "STORECODE") {
            var data = value;
            if (data != "" && data != null) {
              SharedPref.setStringPreference(Constants.STORE_CODE, data);
            }
          }
          if (key == "STORENAME") {
            var data = value;

            if (data != "" && data != null) {
              SharedPref.setStringPreference(Constants.STORE_Name, data);
            }
          }
          if (key == "SELECTED_ADDRESS") {
            var data = value;

            if (data != "" && data != null) {
              SharedPref.setStringPreference(Constants.ADDRESS, data);
            }
          }
          if (key == "WMS_STORE_ID") {
            var data = value;
            if (data != "" && data != null) {
              SharedPref.setStringPreference(Constants.WMS_STORE_ID, data);
            }
          }
          if (key == "CURRENT_CITY") {
            var data = value;
            if (data != "" && data != null) {
              SharedPref.setStringPreference(Constants.LOCALITY, data);
            }
          }
          if (key == "CUSTOMER_ID") {
            var data = value;
            if (data != "" && data != null) {
              SharedPref.setStringPreference(Constants.sp_CustomerId, data);
            }
          }

          clearOldPreferences();

          // SharedPref.setStringPreference(Constants.ADDRESS, street);
          // SharedPref.setStringPreference(Constants.LOCALITY, "$usercity, $userState");
        });

        try {
          String customerID =
              await SharedPref.getStringPreference(Constants.sp_CustomerId);
          if (customerID.trim().isNotEmpty) {
            addNotificationApi();
          }
        } catch (e) {}
      }
    } on PlatformException catch (e) {
      print(
          "fetchOldSharedPreferences Failed to fetch old SharedPreferences: '${e.message}'.");
    }
  }
}

addNotificationApi() async {
  await ApiProvider().addNotiFication(() {
    addNotificationApi();
  });
}

Future<void> clearOldPreferences() async {
  const platform = MethodChannel('com.ondoor/shared_prefs');

  try {
    final String result = await platform.invokeMethod('clearOldPreferences');
    print(result); // Output: "SharedPreferences cleared successfully."
  } on PlatformException catch (e) {
    print(
        "clearOldPreferences Failed to clear old SharedPreferences: '${e.message}'.");
  }
}

/*
class CirclePainter extends CustomPainter {
  final double radius;

  CirclePainter(this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ColorName.ColorPrimary
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
*/
