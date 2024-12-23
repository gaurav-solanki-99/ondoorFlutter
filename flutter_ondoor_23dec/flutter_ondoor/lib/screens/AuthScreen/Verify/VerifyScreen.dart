import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:ondoor/screens/AuthScreen/Verify/VerifyBloc/verify_bloc.dart';
import 'package:ondoor/screens/AuthScreen/Verify/VerifyBloc/verify_state.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:pinput/pinput.dart';
import 'package:proste_bezier_curve/proste_bezier_curve.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../../constants/Constant.dart';
import '../../../constants/FontConstants.dart';
import '../../../constants/ImageConstants.dart';
import '../../../constants/StringConstats.dart';
import '../../../services/ApiServices.dart';
import '../../../services/Navigation/routes.dart';
import '../../../utils/Comman_Loader.dart';
import '../../../utils/Connection.dart';
import '../../../utils/SizeConfig.dart';
import '../../../utils/colors.dart';
import '../../../utils/sharedpref.dart';
import '../../../widgets/AppWidgets.dart';
import '../../../widgets/MyDialogs.dart';
import 'VerifyBloc/verify_event.dart';

class VerifyScreen extends StatefulWidget {
  String name;
  String mobileNo;
  String email;
  String fromRoute;
  VerifyScreen({
    super.key,
    required this.name,
    required this.mobileNo,
    required this.email,
    required this.fromRoute,
  });

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> with CodeAutoFill {
  VerifyBloc verifyBloc = VerifyBloc();
  int _start = 60;
  late Timer _timer;
  bool isOtpFilled = false;
  late String enteredOtp;
  bool isClear = false;
  final TextEditingController _pinController = TextEditingController();
  List<String> listImage = [
    Imageconstants.img_regiterd1,
    Imageconstants.img_regiterd2,
    Imageconstants.img_regiterd3,
    Imageconstants.img_regiterd4,
  ];
  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_start == 0) {
        timer.cancel();
      } else {
        _start--;

        verifyBloc.add(UpdateTimeEvent(countDownTime: _start));
        //
      }
    });
  }

  @override
  void initState() {
    Appwidgets.setStatusBarColorWhite();
    listenOtp();
    verifyBloc.add(UpdateTimeEvent(countDownTime: _start));
    startTimer();
    super.initState();
  }

  void listenOtp() async {
    listenForCode();
  }

  verifyOtp() async {
    if (await Network.isConnected()) {
      SharedPref.setStringPreference(Constants.sp_MOBILE_NO, widget.mobileNo);

      ApiProvider()
          .verifyOtp(enteredOtp, widget.mobileNo, context, widget.fromRoute)
          .then((value) {});
    } else {
      MyDialogs.showInternetDialog(context, () {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // transparent status bar
      statusBarIconBrightness: Brightness.dark, // dark icons on the status bar
    ));
    var pinviewSize = (Sizeconfig.getWidth(context) - 30) * 0.2;

    return MediaQuery(
      data: Appwidgets().mediaqueryDataforWholeApp(context: context),
      child: WillPopScope(
        onWillPop: () async {
          print("exit");
          Constants.tv_name = widget.name;
          Constants.tv_email = widget.email;
          Constants.tv_number = widget.mobileNo;
          Navigator.pushReplacementNamed(context, Routes.register_screen,
              // arguments: {
              //   'email': widget.email,
              //   'mobileNo': widget.mobileNo,
              //   'name': widget.email,
              // },

              arguments: "");
          // Navigator.pop(context);
          return false;
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          child:
              KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
            return Scaffold(
              resizeToAvoidBottomInset: true,
              body: Container(
                height: Sizeconfig.getHeight(context),
                width: Sizeconfig.getWidth(context),
                color: ColorName.aquaHazeColor,
                child: Container(
                  child: Stack(
                    children: [
                      Container(
                        height: (Sizeconfig.getHeight(context) / 1.5),
                        width: Sizeconfig.getWidth(context),
                        child: Stack(
                          children: [
                            CarouselSlider(
                              options: CarouselOptions(
                                height: (Sizeconfig.getHeight(context) / 1.5),
                                viewportFraction: 1.0,
                                enlargeCenterPage: false,
                                autoPlayAnimationDuration:
                                    Duration(milliseconds: 4000),
                                autoPlayCurve: Curves.linear,
                                autoPlay: true,
                              ),
                              items: listImage
                                  .map((item) => Container(
                                        child: Center(
                                            child: Image.asset(
                                          item,
                                          fit: BoxFit.cover,
                                          height:
                                              (Sizeconfig.getHeight(context) /
                                                  1.5),
                                        )),
                                      ))
                                  .toList(),
                            ),
                            Container(
                              height: (Sizeconfig.getHeight(context) / 1.5),
                              width: Sizeconfig.getWidth(context),
                              color: Colors.black.withOpacity(0.2),
                            ),
                            // Container(
                            //   height: (Sizeconfig.getHeight(context) / 1.8),
                            //   width: Sizeconfig.getWidth(context),
                            //   child: Column(
                            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //     children: [
                            //       Container(),
                            //       Container(
                            //         child: Image.asset(
                            //           Imageconstants.img_app_icon,
                            //           height: 100,
                            //           width: 100,
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      BlocProvider(
                        create: (Context) => verifyBloc,
                        child: BlocBuilder(
                            bloc: verifyBloc,
                            builder: (context, state) {
                              debugPrint("State is $state ");
                              if (state is UpdateTimeState) {
                                _start = state.countDownTime;
                              }

                              if (state is ClearOTPFilledState) {
                                if (state.otp == "") {
                                  enteredOtp = "";
                                  isOtpFilled = false;
                                  isClear = true;
                                  _pinController.text = "";
                                  _pinController.clear();
                                } else {
                                  _pinController.text = state.otp;
                                  enteredOtp = state.otp;
                                  isOtpFilled = true;
                                  isClear = false;
                                  verifyOtp();
                                }
                              }
                              return Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(),
                                          Container(
                                            child: Image.asset(
                                              Imageconstants.img_app_icon,
                                              height: 100,
                                              width: 100,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: isKeyboardVisible ? 3 : 1,
                                    child: ClipPath(
                                      clipper: ProsteBezierCurve(
                                        position: ClipPosition.top,
                                        list: [
                                          BezierCurveSection(
                                            start: Offset(
                                                Sizeconfig.getWidth(context),
                                                0),
                                            top: Offset(
                                                Sizeconfig.getWidth(context) /
                                                    2,
                                                30),
                                            end: Offset(0, 0),
                                          ),
                                        ],
                                      ),
                                      child: Container(
                                        color: Colors.white,
                                        // height: 150,
                                        // height: (Sizeconfig.getHeight(context) /
                                        //         2),

                                        // !invalidForm
                                        //     ?  (Sizeconfig.getHeight(context) / 2)*0.90
                                        //     : ((Sizeconfig.getHeight(context) / 2) +
                                        //     (Sizeconfig.getHeight(context) / 2) *
                                        //         0.02),

                                        child: SingleChildScrollView(
                                          child: Container(
                                            // height:
                                            //     (Sizeconfig.getHeight(context) /
                                            //             2) *
                                            //         0.90,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(top: 20),
                                                  child: Column(
                                                    children: [
                                                      Center(
                                                        child: Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 20),
                                                          child: Container(
                                                            child: Text(
                                                              StringContants
                                                                  .lbl_otp_verification,
                                                              style: TextStyle(
                                                                fontSize:
                                                                    Constants
                                                                        .Size_20,
                                                                fontFamily:
                                                                    Fontconstants
                                                                        .fc_family_sf,
                                                                fontWeight:
                                                                    Fontconstants
                                                                        .SF_Pro_Display_SEMIBOLD,
                                                                color: ColorName
                                                                    .ColorPrimary,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Center(
                                                        child: Container(
                                                          width: Sizeconfig
                                                                  .getWidth(
                                                                      context) *
                                                              0.7,
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 2),
                                                          child: Container(
                                                            child: Text(
                                                              StringContants
                                                                  .lbl_otpverification_subheading,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontSize: Constants
                                                                    .SizeSmall,
                                                                fontFamily:
                                                                    Fontconstants
                                                                        .fc_family_sf,
                                                                fontWeight:
                                                                    Fontconstants
                                                                        .SF_Pro_Display_SEMIBOLD,
                                                                color: ColorName
                                                                    .greyheading,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Center(
                                                        child: Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 7),
                                                          child: Container(
                                                            child: Text(
                                                              "${widget.mobileNo}",
                                                              style: TextStyle(
                                                                fontSize: Constants
                                                                    .SizeMidium,
                                                                fontFamily:
                                                                    Fontconstants
                                                                        .fc_family_sf,
                                                                fontWeight:
                                                                    Fontconstants
                                                                        .SF_Pro_Display_SEMIBOLD,
                                                                color: ColorName
                                                                    .black,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 15),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Appwidgets.TextSemiBold(
                                                                    StringContants
                                                                        .lbl_code,
                                                                    ColorName
                                                                        .black,
                                                                    TextAlign
                                                                        .start),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 8,
                                                          ),
                                                          Container(
                                                            child: Pinput(
                                                              controller:
                                                                  _pinController,
                                                              length: 5,
                                                              onChanged: (pin) {
                                                                isOtpFilled =
                                                                    false;
                                                              },
                                                              onCompleted:
                                                                  (pin) async {
                                                                isOtpFilled =
                                                                    true;
                                                                enteredOtp =
                                                                    pin;

                                                                if (await Network
                                                                    .isConnected()) {
                                                                  ApiProvider()
                                                                      .verifyOtp(
                                                                          enteredOtp,
                                                                          widget
                                                                              .mobileNo,
                                                                          context,
                                                                          widget
                                                                              .fromRoute)
                                                                      .then(
                                                                          (value) {});
                                                                } else {
                                                                  MyDialogs
                                                                      .showInternetDialog(
                                                                          context,
                                                                          () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  });
                                                                }
                                                              },
                                                              focusedPinTheme:
                                                                  PinTheme(
                                                                width:
                                                                    pinviewSize,
                                                                height: pinviewSize -
                                                                    (pinviewSize *
                                                                        0.15),
                                                                textStyle:
                                                                    TextStyle(
                                                                  fontSize: 20,
                                                                  color: ColorName
                                                                      .ColorPrimary,
                                                                ),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          244,
                                                                          246,
                                                                          247),
                                                                  border: Border.all(
                                                                      color: ColorName
                                                                          .ColorPrimary),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.0),
                                                                ),
                                                              ),
                                                              defaultPinTheme:
                                                                  PinTheme(
                                                                width:
                                                                    pinviewSize,
                                                                height: pinviewSize -
                                                                    (pinviewSize *
                                                                        0.15),
                                                                textStyle:
                                                                    TextStyle(
                                                                  fontSize: 20,
                                                                  color:
                                                                      ColorName
                                                                          .black,
                                                                ),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      244,
                                                                      246,
                                                                      247),
                                                                  border: Border.all(
                                                                      color: ColorName
                                                                          .mediumGrey),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.0),
                                                                ),
                                                              ),
                                                              scrollPadding:
                                                                  EdgeInsets.only(
                                                                      bottom:
                                                                          60),
                                                            ),
                                                          ),
                                                          5.toSpace,
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Container(),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  _start > 0
                                                                      ? Text(
                                                                          StringContants
                                                                              .lbl_resend_after,
                                                                          style: TextStyle(
                                                                              fontSize: Constants.SizeSmall,
                                                                              fontFamily: Fontconstants.fc_family_sf,
                                                                              fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
                                                                              color: Colors.grey),
                                                                        )
                                                                      : InkWell(
                                                                          onTap:
                                                                              () async {
                                                                            verifyBloc.add(ClearOTPFilledEvent(otp: ""));

                                                                            await Future.delayed(Duration(seconds: 1));
                                                                            _start =
                                                                                60;
                                                                            verifyBloc.add(UpdateTimeEvent(countDownTime: _start));
                                                                            startTimer();
                                                                            ApiProvider().registerUser(widget.name, widget.mobileNo, widget.email, context, true, "").then((value) {});
                                                                          },
                                                                          child:
                                                                              Text(
                                                                            StringContants.lbl_resend,
                                                                            style: TextStyle(
                                                                                fontSize: Constants.SizeSmall,
                                                                                fontFamily: Fontconstants.fc_family_sf,
                                                                                fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
                                                                                color: ColorName.ColorPrimary),
                                                                          ),
                                                                        ),
                                                                  _start > 0
                                                                      ? Appwidgets.TextRegular(
                                                                          " ${_start}Sec",
                                                                          Colors
                                                                              .grey)
                                                                      : Container()
                                                                ],
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    Align(
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                      child: InkWell(
                                                        onTap: () async {
                                                          if (isOtpFilled ==
                                                              false) {
                                                            Appwidgets.showToastMessage(
                                                                StringContants
                                                                    .lbl_enter_otp);
                                                          } else {
                                                            if (await Network
                                                                .isConnected()) {
                                                              ApiProvider()
                                                                  .verifyOtp(
                                                                      enteredOtp,
                                                                      widget
                                                                          .mobileNo,
                                                                      context,
                                                                      widget
                                                                          .fromRoute)
                                                                  .then(
                                                                      (value) {});
                                                            } else {
                                                              MyDialogs
                                                                  .showInternetDialog(
                                                                      context,
                                                                      () {
                                                                Navigator.pop(
                                                                    context);
                                                              });
                                                            }
                                                          }
                                                        },
                                                        child: Container(
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10),
                                                            width:
                                                                Sizeconfig.getWidth(
                                                                    context),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        10),
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius.all(
                                                                        Radius.circular(
                                                                            10.0)),
                                                                color: ColorName
                                                                    .ColorPrimary),
                                                            child: Center(
                                                              child: Appwidgets.TextLagre(
                                                                  StringContants
                                                                      .lbl_verify,
                                                                  Colors.white),
                                                            )),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Container()
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );

                              /*          Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: isKeyboardVisible?3:1,
                                      child: Container(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(),
                                            Container(
                                              child: Image.asset(
                                                Imageconstants.img_app_icon,
                                                height: 100,
                                                width: 100,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: ClipPath(
                                        clipper: ProsteBezierCurve(
                                          position: ClipPosition.top,
                                          list: [
                                            BezierCurveSection(
                                              start: Offset(
                                                  Sizeconfig.getWidth(context), 0),
                                              top: Offset(
                                                  Sizeconfig.getWidth(context) / 2,
                                                  30),
                                              end: Offset(0, 0),
                                            ),
                                          ],
                                        ),
                                        child: Container(
                                          color: Colors.white,
                                          // height: 150,
                                          // height:
                                          //     (Sizeconfig.getHeight(context) / 2) *
                                          //         0.90,

                                          // !invalidForm
                                          //     ?  (Sizeconfig.getHeight(context) / 2)*0.90
                                          //     : ((Sizeconfig.getHeight(context) / 2) +
                                          //     (Sizeconfig.getHeight(context) / 2) *
                                          //         0.02),

                                          child: Column(
                                            children: [
                                              SingleChildScrollView(
                                                child: Container(
                                                  // height:
                                                  //     (Sizeconfig.getHeight(context) /
                                                  //             2) *
                                                  //         0.90,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                        margin:
                                                            EdgeInsets.only(top: 20),
                                                        child: Column(
                                                          children: [
                                                            Center(
                                                              child: Container(
                                                                margin:
                                                                    EdgeInsets.only(
                                                                        top: 20),
                                                                child: Container(
                                                                  child: Text(
                                                                    StringContants
                                                                        .lbl_otp_verification,
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          Constants
                                                                              .Size_20,
                                                                      fontFamily:
                                                                          Fontconstants
                                                                              .fc_family_sf,
                                                                      fontWeight:
                                                                          Fontconstants
                                                                              .SF_Pro_Display_SEMIBOLD,
                                                                      color: ColorName
                                                                          .ColorPrimary,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Center(
                                                              child: Container(
                                                                width: Sizeconfig
                                                                        .getWidth(
                                                                            context) *
                                                                    0.7,
                                                                margin:
                                                                    EdgeInsets.only(
                                                                        top: 2),
                                                                child: Container(
                                                                  child: Text(
                                                                    StringContants
                                                                        .lbl_otpverification_subheading,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: TextStyle(
                                                                      fontSize: Constants
                                                                          .SizeSmall,
                                                                      fontFamily:
                                                                          Fontconstants
                                                                              .fc_family_sf,
                                                                      fontWeight:
                                                                          Fontconstants
                                                                              .SF_Pro_Display_SEMIBOLD,
                                                                      color: ColorName
                                                                          .greyheading,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Center(
                                                              child: Container(
                                                                margin:
                                                                    EdgeInsets.only(
                                                                        top: 7),
                                                                child: Container(
                                                                  child: Text(
                                                                    "${widget.mobileNo}",
                                                                    style: TextStyle(
                                                                      fontSize: Constants
                                                                          .SizeMidium,
                                                                      fontFamily:
                                                                          Fontconstants
                                                                              .fc_family_sf,
                                                                      fontWeight:
                                                                          Fontconstants
                                                                              .SF_Pro_Display_SEMIBOLD,
                                                                      color: ColorName
                                                                          .black,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Column(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                    horizontal: 15),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Appwidgets.TextSemiBold(
                                                                          StringContants
                                                                              .lbl_code,
                                                                          ColorName
                                                                              .black,
                                                                          TextAlign
                                                                              .start),
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 8,
                                                                ),
                                                                Container(
                                                                  child: Pinput(
                                                                    controller:
                                                                        _pinController,
                                                                    length: 5,
                                                                    onChanged: (pin) {
                                                                      isOtpFilled =
                                                                          false;
                                                                    },
                                                                    onCompleted:
                                                                        (pin) async {
                                                                      isOtpFilled =
                                                                          true;
                                                                      enteredOtp =
                                                                          pin;

                                                                      if (await Network
                                                                          .isConnected()) {
                                                                        ApiProvider()
                                                                            .verifyOtp(
                                                                                enteredOtp,
                                                                                widget
                                                                                    .mobileNo,
                                                                                context,
                                                                                widget
                                                                                    .fromRoute)
                                                                            .then(
                                                                                (value) {});
                                                                      } else {
                                                                        MyDialogs
                                                                            .showInternetDialog(
                                                                                context,
                                                                                () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        });
                                                                      }
                                                                    },
                                                                    focusedPinTheme:
                                                                        PinTheme(
                                                                      width:
                                                                          pinviewSize,
                                                                      height: pinviewSize -
                                                                          (pinviewSize *
                                                                              0.15),
                                                                      textStyle:
                                                                          TextStyle(
                                                                        fontSize: 20,
                                                                        color: ColorName
                                                                            .ColorPrimary,
                                                                      ),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Color
                                                                            .fromARGB(
                                                                                255,
                                                                                244,
                                                                                246,
                                                                                247),
                                                                        border: Border.all(
                                                                            color: ColorName
                                                                                .ColorPrimary),
                                                                        borderRadius:
                                                                            BorderRadius
                                                                                .circular(
                                                                                    10.0),
                                                                      ),
                                                                    ),
                                                                    defaultPinTheme:
                                                                        PinTheme(
                                                                      width:
                                                                          pinviewSize,
                                                                      height: pinviewSize -
                                                                          (pinviewSize *
                                                                              0.15),
                                                                      textStyle:
                                                                          TextStyle(
                                                                        fontSize: 20,
                                                                        color:
                                                                            ColorName
                                                                                .black,
                                                                      ),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Color
                                                                            .fromARGB(
                                                                                255,
                                                                                244,
                                                                                246,
                                                                                247),
                                                                        border: Border.all(
                                                                            color: ColorName
                                                                                .mediumGrey),
                                                                        borderRadius:
                                                                            BorderRadius
                                                                                .circular(
                                                                                    10.0),
                                                                      ),
                                                                    ),
                                                                    scrollPadding:
                                                                        EdgeInsets.only(
                                                                            bottom:
                                                                                60),
                                                                  ),
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Container(),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        _start > 0
                                                                            ? Text(
                                                                                StringContants
                                                                                    .lbl_resend_after,
                                                                                style: TextStyle(
                                                                                    fontSize: Constants.SizeSmall,
                                                                                    fontFamily: Fontconstants.fc_family_sf,
                                                                                    fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
                                                                                    color: Colors.grey),
                                                                              )
                                                                            : InkWell(
                                                                                onTap:
                                                                                    () async {
                                                                                  verifyBloc.add(ClearOTPFilledEvent(otp: ""));

                                                                                  await Future.delayed(Duration(seconds: 1));
                                                                                  _start =
                                                                                      60;
                                                                                  verifyBloc.add(UpdateTimeEvent(countDownTime: _start));
                                                                                  startTimer();
                                                                                  ApiProvider().registerUser(widget.name, widget.mobileNo, widget.email, context, true, "").then((value) {});
                                                                                },
                                                                                child:
                                                                                    Text(
                                                                                  StringContants.lbl_resend,
                                                                                  style: TextStyle(
                                                                                      fontSize: Constants.SizeSmall,
                                                                                      fontFamily: Fontconstants.fc_family_sf,
                                                                                      fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
                                                                                      color: ColorName.ColorPrimary),
                                                                                ),
                                                                              ),
                                                                        _start > 0
                                                                            ? Appwidgets.TextRegular(
                                                                                " ${_start}Sec",
                                                                                Colors
                                                                                    .grey)
                                                                            : Container()
                                                                      ],
                                                                    ),
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 20,
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .bottomCenter,
                                                            child: InkWell(
                                                              onTap: () async {
                                                                if (isOtpFilled ==
                                                                    false) {
                                                                  Appwidgets.showToastMessage(
                                                                      StringContants
                                                                          .lbl_enter_otp);
                                                                } else {
                                                                  if (await Network
                                                                      .isConnected()) {
                                                                    ApiProvider()
                                                                        .verifyOtp(
                                                                            enteredOtp,
                                                                            widget
                                                                                .mobileNo,
                                                                            context,
                                                                            widget
                                                                                .fromRoute)
                                                                        .then(
                                                                            (value) {});
                                                                  } else {
                                                                    MyDialogs
                                                                        .showInternetDialog(
                                                                            context,
                                                                            () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    });
                                                                  }
                                                                }
                                                              },
                                                              child: Container(
                                                                  margin: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              10),
                                                                  width:
                                                                      Sizeconfig.getWidth(
                                                                          context),
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          vertical:
                                                                              10),
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(
                                                                                  10.0)),
                                                                      color: ColorName
                                                                          .ColorPrimary),
                                                                  child: Center(
                                                                    child: Appwidgets.TextLagre(
                                                                        StringContants
                                                                            .lbl_verify,
                                                                        Colors.white),
                                                                  )),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      Container()
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );*/
                            }),
                      ),
                      Positioned(
                          top: 30,
                          left: 20,
                          child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 30,
                              )))
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  void codeUpdated() {
    debugPrint("Code >>>   " + code!);
    verifyBloc.add(ClearOTPFilledEvent(otp: code!));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    CommanLoader().dismissEasyLoader();
    super.dispose();
  }
}
