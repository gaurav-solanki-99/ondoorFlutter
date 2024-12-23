import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondoor/main.dart';
import 'package:ondoor/screens/AuthScreen/Verify/VerifyBloc/verify_bloc.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/widgets/login_widget_dialog/login_widget_bloc.dart';
import 'package:ondoor/widgets/login_widget_dialog/login_widget_events.dart';
import 'package:ondoor/widgets/login_widget_dialog/login_widget_state.dart';
import 'package:pinput/pinput.dart';
import 'package:proste_bezier_curve/proste_bezier_curve.dart';

import '../../constants/Constant.dart';
import '../../constants/FontConstants.dart';
import '../../constants/ImageConstants.dart';
import '../../constants/StringConstats.dart';
import '../../screens/AuthScreen/Register/RegisterdBloc/registerd_bloc.dart';
import '../../screens/AuthScreen/Register/RegisterdBloc/registerd_event.dart';
import '../../screens/AuthScreen/Register/RegisterdBloc/registerd_state.dart';
import '../../screens/AuthScreen/Verify/VerifyBloc/verify_event.dart';
import '../../screens/AuthScreen/Verify/VerifyBloc/verify_state.dart';
import '../../services/ApiServices.dart';
import '../../services/Navigation/routes.dart';
import '../../utils/Connection.dart';
import '../../utils/SizeConfig.dart';
import '../../utils/colors.dart';
import '../../utils/themeData.dart';
import '../../utils/validator.dart';
import '../AppWidgets.dart';
import '../MyDialogs.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  List<Widget> widgetList = [];
  RegisterdBloc registerdBloc = RegisterdBloc();

  VerifyBloc verifyBloc = VerifyBloc();
  bool invalidForm = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  FocusNode namefocus = FocusNode();
  FocusNode mobilefocus = FocusNode();
  FocusNode emailfocus = FocusNode();
  int _start = 60;
  late Timer _timer;
  bool isOtpFilled = false;
  late String enteredOtp;
  int currentPageIndex = 0;
  LoginWidgetBloc loginWidgetBloc = LoginWidgetBloc();
  bool isClear = false;
  final TextEditingController _pinController = TextEditingController();
  PageController pageController = PageController();
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
    // TODO: implement initState
    super.initState();
  }

  Widget verifyView() {
    var pinviewSize =
        (Sizeconfig.getWidth(navigationService.navigatorKey.currentContext!) -
                30) *
            0.2;
    return Wrap(
      spacing: 5,
      runSpacing: 10,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                    onTap: () {
                      loginWidgetBloc
                          .add(LoginWidgetPageChangeEvent(pageIndex: 0));
                    },
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: ColorName.black,
                    )),
              ),
              Spacer(),
              Center(
                child: Text(
                  StringContants.lbl_otp_verification,
                  style: TextStyle(
                    fontSize: Constants.Size_20,
                    fontFamily: Fontconstants.fc_family_sf,
                    fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
                    color: ColorName.ColorPrimary,
                  ),
                ),
              ),
              Spacer(),
            ],
          ),
        ),
        Center(
          child: Text(
            StringContants.lbl_otpverification_subheading,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Constants.SizeSmall,
              fontFamily: Fontconstants.fc_family_sf,
              fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
              color: ColorName.greyheading,
            ),
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
                return Container(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Wrap(
                        runSpacing: 10,
                        children: [
                          // Title and Subheading

                          // OTP Input
                          Pinput(
                            controller: _pinController,
                            length: 5,
                            onChanged: (pin) {
                              isOtpFilled = false;
                            },
                            onCompleted: (pin) async {
                              isOtpFilled = true;
                              enteredOtp = pin;

                              if (await Network.isConnected()) {
                                await ApiProvider().verifyOtp(
                                  enteredOtp,
                                  mobileController.text,
                                  context,
                                  Routes.checkoutscreen,
                                );
                              } else {
                                MyDialogs.showInternetDialog(context, () {
                                  Navigator.pop(context);
                                });
                              }
                            },
                            focusedPinTheme:
                                _pinTheme(pinviewSize: pinviewSize),
                            defaultPinTheme:
                                _pinTheme(pinviewSize: pinviewSize),
                            scrollPadding: EdgeInsets.only(bottom: 60),
                          ),

                          // Resend OTP and Verify Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _start > 0
                                  ? Text(
                                      StringContants.lbl_resend_after,
                                      style: TextStyle(
                                        fontSize: Constants.SizeSmall,
                                        fontFamily: Fontconstants.fc_family_sf,
                                        fontWeight: Fontconstants
                                            .SF_Pro_Display_SEMIBOLD,
                                        color: Colors.grey,
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () async {
                                        verifyBloc
                                            .add(ClearOTPFilledEvent(otp: ""));
                                        await Future.delayed(
                                            Duration(seconds: 1));
                                        _start = 60;
                                        verifyBloc.add(UpdateTimeEvent(
                                            countDownTime: _start));
                                        startTimer();
                                        await ApiProvider()
                                            .registerUserwithoutRoute(
                                          nameController.text,
                                          mobileController.text,
                                          emailController.text,
                                          context,
                                          true,
                                          "",
                                        );
                                      },
                                      child: Text(
                                        StringContants.lbl_resend,
                                        style: TextStyle(
                                          fontSize: Constants.SizeSmall,
                                          fontFamily:
                                              Fontconstants.fc_family_sf,
                                          fontWeight: Fontconstants
                                              .SF_Pro_Display_SEMIBOLD,
                                          color: ColorName.ColorPrimary,
                                        ),
                                      ),
                                    ),
                              if (_start > 0)
                                Appwidgets.TextRegular(
                                  " ${_start}Sec",
                                  Colors.grey,
                                ),
                            ],
                          ),
                          InkWell(
                            onTap: () async {
                              if (!isOtpFilled) {
                                Appwidgets.showToastMessage(
                                    StringContants.lbl_enter_otp);
                              } else {
                                if (await Network.isConnected()) {
                                  await ApiProvider().verifyOtp(
                                    enteredOtp,
                                    mobileController.text,
                                    context,
                                    Routes.checkoutscreen,
                                  );
                                } else {
                                  MyDialogs.showInternetDialog(context, () {
                                    Navigator.pop(context);
                                  });
                                }
                              }
                            },
                            child: Container(
                              width: Sizeconfig.getWidth(context),
                              padding: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                color: ColorName.ColorPrimary,
                              ),
                              child: Center(
                                child: Appwidgets.TextLagre(
                                  StringContants.lbl_verify,
                                  Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
        ),
        10.toSpace
      ],
    );
  }

  PinTheme _pinTheme({required double pinviewSize}) {
    return PinTheme(
      width: pinviewSize,
      height: pinviewSize - (pinviewSize * 0.15),
      textStyle: TextStyle(
        fontSize: 20,
        color: Color.fromARGB(255, 180, 178, 178),
      ),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 244, 246, 247),
        border: Border.all(color: ColorName.mediumGrey),
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  verifyOtp() async {
    if (await Network.isConnected()) {
      ApiProvider()
          .verifyOtp(
              enteredOtp, mobileController.text, context, Routes.checkoutscreen)
          .then((value) {});
    } else {
      MyDialogs.showInternetDialog(context, () {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("VIEW INSETS >>>   ${MediaQuery.of(context).viewInsets.vertical}");
    return BlocBuilder<LoginWidgetBloc, LoginWidgetState>(
      bloc: loginWidgetBloc,
      builder: (context, state) {
        if (state is LoginWidgetInitialState) {
          widgetList.add(BlocProvider(
            create: (context) => registerdBloc,
            child: BlocBuilder(
                bloc: registerdBloc,
                builder: (context, state) {
                  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                    statusBarColor:
                        Colors.transparent, // transparent status bar
                    statusBarIconBrightness:
                        Brightness.dark, // dark icons on the status bar
                  ));
                  if (state is FormStateState) {
                    invalidForm = state.isvalid;
                  }

                  return Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Wrap(
                        // mainAxisAlignment: MainAxisAlignment.start,
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 10, right: 10, left: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Mobile Verification",
                                          style: TextStyle(
                                            fontSize: Constants.Size_20,
                                            fontFamily:
                                                Fontconstants.fc_family_sf,
                                            fontWeight: Fontconstants
                                                .SF_Pro_Display_SEMIBOLD,
                                            color: ColorName.ColorPrimary,
                                          ),
                                        ),
                                        Text(
                                          "Please Enter your Details",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: Constants.SizeSmall,
                                            fontFamily:
                                                Fontconstants.fc_family_sf,
                                            fontWeight: Fontconstants
                                                .SF_Pro_Display_SEMIBOLD,
                                            color: ColorName.darkGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Icon(
                                        Icons.close,
                                        color: ColorName.black,
                                      ),
                                    )
                                  ],
                                ),
                                15.toSpace,
                                Container(
                                  child: Appwidgets.commonTextForFieldAuth2(
                                    focusNode: namefocus,
                                    controller: nameController,
                                    maxLines: 1,
                                    hintText: "Name",
                                    maxLength: 25,
                                    textInputType: TextInputType.name,
                                    validatorFunc: (p0) {
                                      if (p0!.isEmpty) {
                                        return 'Please enter full name';
                                      }
                                    },
                                    imgFormEmail: Imageconstants.img_person,
                                    onChanged: (value) {
                                      final newValue = value.replaceAll(RegExp(r'\s{2,}'), ' ');

                                      if (newValue != value) {
                                        _formKey
                                            .currentState!
                                            .validate();
                                      }
                                    },
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'''^[\w\'\’\"_,.()&!*|:/\\–%-]*(?:\s[\w\'\’\"_,.()&!*|:/\\–%-]*)*\s?$''')
                                      ),
                                    ],
                                  ),
                                ),
                                10.toSpace,
                                Container(
                                  child: Appwidgets.commonTextForFieldAuth2(
                                      focusNode: mobilefocus,
                                      imgFormEmail:
                                          Imageconstants.img_form_numer,
                                      controller: mobileController,
                                      maxLines: 1,
                                      hintText: "Mobile Number",
                                      maxLength: 10,
                                      textInputType: TextInputType.number,
                                      validatorFunc: (p0) {
                                        if (p0!.isEmpty) {
                                          return 'Please enter Mobile number';
                                        } else if (p0.length < 10) {
                                          return 'Please enter valid Mobile number';
                                        }
                                        else if (int.parse(p0[0]) < 5) {
                                          return 'Please enter valid Mobile number';
                                        }
                                      },
                                      onChanged: (value) {
                                        _formKey.currentState!.validate();
                                      },
                                      inputFormatters: []),
                                ),
                                10.toSpace,
                                Container(
                                  child: Appwidgets.commonTextForFieldAuth2(
                                      focusNode: emailfocus,
                                      imgFormEmail:
                                          Imageconstants.img_form_email,
                                      controller: emailController,
                                      maxLines: 1,
                                      hintText: 'Email',
                                      maxLength: 100,
                                      textInputType: TextInputType.emailAddress,
                                      validatorFunc: (value) {
                                        if (value!.isNotEmpty &&
                                            Validator.emailValidator(value) !=
                                                null) {
                                          return 'Please enter valid Email';
                                        }
                                      },
                                      onChanged: (value) {},
                                      inputFormatters: []),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin:
                                EdgeInsets.only(top: 10, left: 10, right: 10),
                            alignment: Alignment.bottomCenter,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: InkWell(
                                onTap: () async {
                                  OndoorThemeData.keyBordDow();

                                  if (_formKey.currentState!.validate()) {
                                    invalidForm = false;
                                    registerdBloc.add(
                                        FormStateEvent(isvalid: invalidForm));

                                    if (await Network.isConnected()) {
                                      ApiProvider()
                                          .registerUserwithoutRoute(
                                              nameController.text,
                                              mobileController.text,
                                              emailController.text,
                                              context,
                                              false,
                                              Routes.checkoutscreen)
                                          .then((value) {
                                        if (value.success == true) {
                                          loginWidgetBloc.add(
                                              LoginWidgetPageChangeEvent(
                                                  pageIndex: 1));
                                        }
                                      });
                                    } else {
                                      MyDialogs.showInternetDialog(context, () {
                                        Navigator.pop(context);
                                      });
                                    }
                                  } else {
                                    invalidForm = true;
                                    registerdBloc.add(
                                        FormStateEvent(isvalid: invalidForm));
                                  }
                                },
                                child: Container(
                                    width: Sizeconfig.getWidth(context),
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
                                        color: ColorName.ColorPrimary),
                                    child: Center(
                                      child: Appwidgets.TextLagre(
                                          StringContants.lbl_login,
                                          Colors.white),
                                    )),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }),
          ));
          widgetList.add(verifyView());
        }
        if (state is LoginWidgetPageChangeState) {
          currentPageIndex = state.pageIndex;
          startTimer();
          pageController.animateToPage(
            currentPageIndex,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeIn,
          );
        }
        return SizedBox(
          height: getheight(context: context),
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.light,
              statusBarColor: ColorName.ColorPrimary,
            ),
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              body: PageView.builder(
                physics: NeverScrollableScrollPhysics(),
                controller: pageController,
                itemCount: widgetList.length,
                itemBuilder: (context, index) {
                  return widgetList[index];
                },
              ),
            ),
          ),
        );
      },
    );
  }

  double getheight({required BuildContext context}) {
    return MediaQuery.of(context).viewInsets.vertical > 0
        ? currentPageIndex == 0
            ? Sizeconfig.getHeight(context) * .74
            : Sizeconfig.getHeight(context) * .65
        : currentPageIndex == 0
            ? Sizeconfig.getHeight(context) * .4
            : Sizeconfig.getHeight(context) * .32;
  }
}
