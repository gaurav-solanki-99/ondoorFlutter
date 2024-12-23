import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:ondoor/constants/StringConstats.dart';
import 'package:ondoor/screens/AuthScreen/Register/RegisterdBloc/registerd_bloc.dart';
import 'package:ondoor/screens/AuthScreen/Register/RegisterdBloc/registerd_event.dart';
import 'package:ondoor/utils/Comman_Loader.dart';
import 'package:ondoor/utils/SizeConfig.dart';
import 'package:ondoor/utils/validator.dart';
import 'package:ondoor/widgets/AppWidgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:proste_bezier_curve/proste_bezier_curve.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../constants/Constant.dart';
import '../../../constants/FontConstants.dart';
import '../../../constants/ImageConstants.dart';
import '../../../services/ApiServices.dart';
import '../../../utils/Connection.dart';
import '../../../utils/Utility.dart';
import '../../../utils/colors.dart';
import '../../../utils/sharedpref.dart';
import '../../../utils/themeData.dart';
import '../../../widgets/MyDialogs.dart';
import 'RegisterdBloc/registerd_state.dart';

class RegisterScreen extends StatefulWidget {
  String fromRoute;
  RegisterScreen({super.key, required this.fromRoute});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  RegisterdBloc registerdBloc = RegisterdBloc();
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  String fcmToken = "";
  final _formKey = GlobalKey<FormState>();
  bool invalidForm = false;
  List<String> listImage = [
    Imageconstants.img_regiterd1,
    Imageconstants.img_regiterd2,
    Imageconstants.img_regiterd3,
    Imageconstants.img_regiterd4,
  ];
  FocusNode namefocus = FocusNode();
  FocusNode mobilefocus = FocusNode();
  FocusNode emailfocus = FocusNode();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      //   statusBarColor: Colors.transparent, // transparent status bar
      //   statusBarIconBrightness:
      //       Brightness.dark, // dark icons on the status bar
      // ));
    });

    cleanData();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // transparent status bar
      statusBarIconBrightness: Brightness.dark, // dark icons on the status bar
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    _requestPermissions();

    super.initState();
  }

  cleanData() async {
    await SharedPref.setStringPreference(Constants.sp_notificationdata, "");
  }

  Future<void> _requestPermissions() async {
    if (await Permission.sms.request().isGranted) {
      // Permissions are granted
    } else {
      // Permissions are denied, you can handle the case here
    }
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor: Colors.transparent, // transparent status bar
    //   statusBarIconBrightness: Brightness.dark, // dark icons on the status bar
    // ));

    // Retrieve arguments with null-safety checks

    // Use null-aware operators and default values
    String email = Constants.tv_email;
    String phoneOtp = Constants.tv_number;
    String name = Constants.tv_name;
    //
    //
    print("Verifiy Data page $email $phoneOtp $name");
    //
    // if(email!="") {emailController.text=email;}
    // if(phoneOtp!="") {
    //   mobileController.text=email;}
    // if(name!="") {nameController.text=email;}

    if (name != "") {
      registerdBloc.add(
          RegisterFormFillEvent(name: name, mobile: phoneOtp, email: email));
    }

    return MediaQuery(
      data: Appwidgets().mediaqueryDataforWholeApp(context: context),
      child: SafeArea(
          top: false,
          bottom: false,
          child: VisibilityDetector(
            key: Key("RegisterdScreen"),
            onVisibilityChanged: (VisibilityInfo info) async {
              debugPrint("RegisterdScreen");

              // await Future.delayed(Duration(seconds: 1), () {
              //   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
              //     statusBarColor: Colors.transparent, // transparent status bar
              //     statusBarIconBrightness:
              //         Brightness.light, // dark icons on the status bar
              //   ));
              // });
            },
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
              ),
              child: KeyboardVisibilityBuilder(
                  builder: (context, isKeyboardVisible) {
                print("isKeyboardVisible $isKeyboardVisible");
                return Scaffold(
                  body: BlocProvider(
                    create: (context) => registerdBloc,
                    child: BlocBuilder(
                        bloc: registerdBloc,
                        builder: (context, state) {
                          SystemChrome.setSystemUIOverlayStyle(
                              SystemUiOverlayStyle(
                            statusBarColor:
                                Colors.transparent, // transparent status bar
                            statusBarIconBrightness:
                                Brightness.dark, // dark icons on the status bar
                          ));

                          if (state is RegisterFormFillState) {
                            if (state.email != "") {
                              emailController.text = state.email;
                            }
                            if (state.name != "") {
                              nameController.text = state.name;
                            }
                            if (state.mobile != "") {
                              mobileController.text = state.mobile;
                            }

                            Constants.tv_name = "";
                            Constants.tv_email = "";
                            Constants.tv_number = "";
                          }

                          if (state is FormStateState) {
                            invalidForm = state.isvalid;
                          }

                          return Container(
                            height: Sizeconfig.getHeight(context),
                            width: Sizeconfig.getWidth(context),
                            color: Colors.white,
                            child: Container(
                              child: Stack(
                                children: [
                                  //
                                  // SingleChildScrollView(
                                  //   child: Container(
                                  //     height: Sizeconfig.getHeight(context) -
                                  //         Sizeconfig.getHeight(context) * 0.04,
                                  //     width: Sizeconfig.getWidth(context),
                                  //     child: Column(
                                  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //       children: [
                                  //         // Container(
                                  //         //   height: Sizeconfig.getHeight(context)*0.43,
                                  //         // ),
                                  //         Container(),
                                  //         Container(
                                  //           width: Sizeconfig.getWidth(context),
                                  //           height: !invalidForm
                                  //               ? (Sizeconfig.getHeight(context) / 2)
                                  //               : ((Sizeconfig.getHeight(context) / 2) +
                                  //                   (Sizeconfig.getHeight(context) / 2) *
                                  //                       0.15),
                                  //           padding: EdgeInsets.symmetric(
                                  //               horizontal: 15, vertical: 15),
                                  //           decoration: BoxDecoration(
                                  //               color: Colors.white,
                                  //               borderRadius: BorderRadius.only(
                                  //                   topRight: Radius.circular(20.0),
                                  //                   topLeft: Radius.circular(20.0))),
                                  //           child: Form(
                                  //             key: _formKey,
                                  //             child: Column(
                                  //               mainAxisAlignment:
                                  //                   MainAxisAlignment.spaceBetween,
                                  //               crossAxisAlignment:
                                  //                   CrossAxisAlignment.start,
                                  //               children: [
                                  //                 Expanded(
                                  //                   flex: 8,
                                  //                   child: Container(
                                  //                     child: Column(
                                  //                       crossAxisAlignment:
                                  //                           CrossAxisAlignment.start,
                                  //                       mainAxisAlignment:
                                  //                           MainAxisAlignment.spaceAround,
                                  //                       children: [
                                  //                         Center(
                                  //                           child: Container(
                                  //                             child: Appwidgets.TextLagre(
                                  //                                 StringContants
                                  //                                     .lbl_mobil_verification,
                                  //                                 ColorName.black),
                                  //                           ),
                                  //                         ),
                                  //                         Column(
                                  //                           mainAxisAlignment:
                                  //                               MainAxisAlignment.start,
                                  //                           crossAxisAlignment:
                                  //                               CrossAxisAlignment.start,
                                  //                           children: [
                                  //                             Appwidgets.TextMedium(
                                  //                               StringContants.lbl_name,
                                  //                               ColorName.black,
                                  //                             ),
                                  //                             SizedBox(
                                  //                               height: 5,
                                  //                             ),
                                  //                             Appwidgets
                                  //                                 .commonTextForFieldAuth(
                                  //                                     controller:
                                  //                                         nameController,
                                  //                                     maxlines: 1,
                                  //                                     hintText:
                                  //                                         "Enter name",
                                  //                                     maxLength: 25,
                                  //                                     textInputType:
                                  //                                         TextInputType
                                  //                                             .text,
                                  //                                     validatorFunc:
                                  //                                         (p0) {
                                  //                                       if (p0!.isEmpty) {
                                  //                                         return 'Please enter full name';
                                  //                                       }
                                  //                                     }),
                                  //                           ],
                                  //                         ),
                                  //                         Column(
                                  //                           mainAxisAlignment:
                                  //                               MainAxisAlignment.start,
                                  //                           crossAxisAlignment:
                                  //                               CrossAxisAlignment.start,
                                  //                           children: [
                                  //                             Appwidgets.TextMedium(
                                  //                               StringContants.lbl_Mobile,
                                  //                               ColorName.black,
                                  //                             ),
                                  //                             SizedBox(
                                  //                               height: 5,
                                  //                             ),
                                  //                             Appwidgets
                                  //                                 .commonTextForFieldAuth(
                                  //                                     controller:
                                  //                                         mobileController,
                                  //                                     maxlines: 1,
                                  //                                     hintText:
                                  //                                         "Enter Mobile number",
                                  //                                     maxLength: 10,
                                  //                                     textInputType:
                                  //                                         TextInputType
                                  //                                             .number,
                                  //                                     validatorFunc:
                                  //                                         (p0) {
                                  //                                       if (p0!.isEmpty) {
                                  //                                         return 'Please enter Mobile number';
                                  //                                       } else if (p0
                                  //                                               .length <
                                  //                                           10) {
                                  //                                         return 'Please enter valid Mobile number';
                                  //                                       }
                                  //                                     }),
                                  //                           ],
                                  //                         ),
                                  //                         Column(
                                  //                           mainAxisAlignment:
                                  //                               MainAxisAlignment.start,
                                  //                           crossAxisAlignment:
                                  //                               CrossAxisAlignment.start,
                                  //                           children: [
                                  //                             Appwidgets.TextMedium(
                                  //                               StringContants.lbl_email,
                                  //                               ColorName.black,
                                  //                             ),
                                  //                             SizedBox(
                                  //                               height: 5,
                                  //                             ),
                                  //                             Appwidgets
                                  //                                 .commonTextForFieldAuth(
                                  //                                     controller:
                                  //                                         emailController,
                                  //                                     maxlines: 1,
                                  //                                     hintText:
                                  //                                         StringContants
                                  //                                             .lbl_exapmle,
                                  //                                     maxLength: 100,
                                  //                                     textInputType:
                                  //                                         TextInputType
                                  //                                             .emailAddress,
                                  //                                     validatorFunc:
                                  //                                         (value) {
                                  //                                       if (value!
                                  //                                           .isEmpty) {
                                  //                                         return 'Please enter Email';
                                  //                                       } else if (Validator
                                  //                                               .emailValidator(
                                  //                                                   value) !=
                                  //                                           null) {
                                  //                                         return 'Please enter valid Email';
                                  //                                       }
                                  //                                     }),
                                  //                           ],
                                  //                         ),
                                  //                       ],
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //                 Expanded(
                                  //                   flex: 2,
                                  //                   child: Container(
                                  //                     child: Column(
                                  //                       mainAxisAlignment:
                                  //                           MainAxisAlignment
                                  //                               .spaceBetween,
                                  //                       children: [
                                  //                         Container(),
                                  //                         Container(
                                  //                           child: Align(
                                  //                             alignment:
                                  //                                 Alignment.bottomCenter,
                                  //                             child: InkWell(
                                  //                               onTap: () async {
                                  //                                 OndoorThemeData
                                  //                                     .keyBordDow();
                                  //
                                  //                                 if (_formKey
                                  //                                     .currentState!
                                  //                                     .validate()) {
                                  //                                   invalidForm = false;
                                  //                                   registerdBloc.add(
                                  //                                       FormStateEvent(
                                  //                                           isvalid:
                                  //                                               invalidForm));
                                  //
                                  //                                   if (await Network
                                  //                                       .isConnected()) {
                                  //                                     ApiProvider()
                                  //                                         .registerUser(
                                  //                                             nameController
                                  //                                                 .text,
                                  //                                             mobileController
                                  //                                                 .text,
                                  //                                             emailController
                                  //                                                 .text,
                                  //                                             context,
                                  //                                             false,
                                  //                                             widget
                                  //                                                 .fromRoute)
                                  //                                         .then(
                                  //                                             (value) {});
                                  //                                   } else {
                                  //                                     MyDialogs
                                  //                                         .showInternetDialog(
                                  //                                             context,
                                  //                                             () {
                                  //                                       Navigator.pop(
                                  //                                           context);
                                  //                                     });
                                  //                                   }
                                  //                                 } else {
                                  //                                   invalidForm = true;
                                  //                                   registerdBloc.add(
                                  //                                       FormStateEvent(
                                  //                                           isvalid:
                                  //                                               invalidForm));
                                  //                                 }
                                  //                               },
                                  //                               child: Container(
                                  //                                   width: Sizeconfig
                                  //                                       .getWidth(
                                  //                                           context),
                                  //                                   padding: EdgeInsets
                                  //                                       .symmetric(
                                  //                                           vertical: 10),
                                  //                                   decoration: BoxDecoration(
                                  //                                       borderRadius: BorderRadius
                                  //                                           .all(Radius
                                  //                                               .circular(
                                  //                                                   10.0)),
                                  //                                       color: ColorName
                                  //                                           .ColorPrimary),
                                  //                                   child: Center(
                                  //                                     child: Appwidgets
                                  //                                         .TextLagre(
                                  //                                             StringContants
                                  //                                                 .lbl_login,
                                  //                                             Colors
                                  //                                                 .white),
                                  //                                   )),
                                  //                             ),
                                  //                           ),
                                  //                         ),
                                  //                       ],
                                  //                     ),
                                  //                   ),
                                  //                 )
                                  //               ],
                                  //             ),
                                  //           ),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),

                                  Container(
                                    height:
                                        (Sizeconfig.getHeight(context) / 1.5),
                                    width: Sizeconfig.getWidth(context),
                                    child: Stack(
                                      children: [
                                        CarouselSlider(
                                          options: CarouselOptions(
                                            height:
                                                (Sizeconfig.getHeight(context) /
                                                    1.5),
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
                                                          (Sizeconfig.getHeight(
                                                                  context) /
                                                              1.5),
                                                    )),
                                                  ))
                                              .toList(),
                                        ),
                                        Container(
                                          height:
                                              (Sizeconfig.getHeight(context) /
                                                  1.5),
                                          width: Sizeconfig.getWidth(context),
                                          color: Colors.black.withOpacity(0.2),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Column(
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
                                                  height: 90,
                                                  width: 90,
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
                                                    Sizeconfig.getWidth(
                                                        context),
                                                    0),
                                                top: Offset(
                                                    Sizeconfig.getWidth(
                                                            context) /
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
                                                width: Sizeconfig.getWidth(
                                                    context),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(),
                                                    Container(
                                                      width:
                                                          Sizeconfig.getWidth(
                                                              context),
                                                      // height: !invalidForm
                                                      //     ? (Sizeconfig.getHeight(context) / 2)*0.90
                                                      //     : ((Sizeconfig.getHeight(context) / 2) +
                                                      //     (Sizeconfig.getHeight(context) / 2) *
                                                      //         0.15),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 15,
                                                              vertical: 15),

                                                      child: Form(
                                                        key: _formKey,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              child: Container(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Center(
                                                                      child:
                                                                          Container(
                                                                        margin: EdgeInsets.only(
                                                                            top:
                                                                                20),
                                                                        child:
                                                                            Container(
                                                                          child:
                                                                              Text(
                                                                            StringContants.lbl_mobil_verification,
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: Constants.Size_20,
                                                                              fontFamily: Fontconstants.fc_family_sf,
                                                                              fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
                                                                              color: ColorName.ColorPrimary,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Center(
                                                                      child:
                                                                          Container(
                                                                        width: Sizeconfig.getWidth(context) *
                                                                            0.7,
                                                                        margin: EdgeInsets.only(
                                                                            top:
                                                                                2),
                                                                        child:
                                                                            Container(
                                                                          child:
                                                                              Text(
                                                                            StringContants.lbl_verification_subheading,
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: Constants.SizeSmall,
                                                                              fontFamily: Fontconstants.fc_family_sf,
                                                                              fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
                                                                              color: ColorName.greyheading,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          15,
                                                                    ),
                                                                    /* Container(
                                                                      child: Appwidgets
                                                                          .commonTextForFieldAuth(
                                                                        controller: nameController,
                                                                        maxlines: 1,
                                                                        hintText: "Please enter your name*",
                                                                        maxLength: 25,
                                                                        textInputType: TextInputType.name,
                                                                        validatorFunc: (p0) {
                                                                          if (p0!
                                                                              .isEmpty) {
                                                                            return 'Please enter full name';
                                                                          }
                                                                        },
                                                                        img_form_email: Imageconstants.img_person,
                                                                        onchanged:
                                                                            (value) {
                                                                          _formKey
                                                                              .currentState!
                                                                              .validate();
                                                                        },
                                                                        inputformaters: [
                                                                          FilteringTextInputFormatter
                                                                              .allow(RegExp(
                                                                                  r'[a-zA-Z ]')),
                                                                        ],
                                                                      ),
                                                                    ),*/

                                                                    Container(
                                                                      child: Appwidgets
                                                                          .commonTextForFieldAuth2(
                                                                        focusNode:
                                                                            namefocus,
                                                                        controller:
                                                                            nameController,
                                                                        maxLines:
                                                                            1,
                                                                        hintText:
                                                                            "Name",
                                                                        maxLength:
                                                                            25,
                                                                        textInputType:
                                                                            TextInputType.name,
                                                                        validatorFunc:
                                                                            (p0) {
                                                                          if (p0!
                                                                              .isEmpty) {
                                                                            return 'Please enter full name';
                                                                          }
                                                                        },
                                                                        imgFormEmail:
                                                                            Imageconstants.img_person,
                                                                        onChanged:
                                                                            (value) {
                                                                          final newValue = value.replaceAll(
                                                                              RegExp(r'\s{2,}'),
                                                                              ' ');
                                                                          if (newValue !=
                                                                              value) {
                                                                            _formKey.currentState!.validate();
                                                                          }
                                                                        },
                                                                        inputFormatters: [
                                                                          FilteringTextInputFormatter.allow(
                                                                              RegExp(r'''^[\w\'\’\"_,.()&!*|:/\\–%-]*(?:\s[\w\'\’\"_,.()&!*|:/\\–%-]*)*\s?$''')),
                                                                          // FilteringTextInputFormatter
                                                                          //     .allow(
                                                                          //        // RegExp(r'''^[\w\'\’\"_,.()&!*|:/\\–%-]+(?:\s[\w\'\’\"_,.()&!*|:/\\–%-]+)*?\s?$''')
                                                                          //     RegExp(r'''^[\w\'\’\"_,.()&!*|:/\\–%-]+(?:\s[\w\'\’\"_,.()&!*|:/\\–%-]*)?\s?$''')
                                                                          //
                                                                          //
                                                                          // )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    Container(
                                                                      child: Appwidgets
                                                                          .commonTextForFieldAuth2(
                                                                              // focusNode: mobilefocus,
                                                                              focusNode: mobilefocus,
                                                                              imgFormEmail: Imageconstants.img_form_numer,
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
                                                                                } else if (int.parse(p0[0]) < 5) {
                                                                                  return 'Please enter valid Mobile number';
                                                                                }
                                                                              },
                                                                              onChanged: (value) {
                                                                                _formKey.currentState!.validate();
                                                                              },
                                                                              inputFormatters: [
                                                                            FilteringTextInputFormatter.digitsOnly
                                                                          ]),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    /*     Container(
                                                                      child: Appwidgets
                                                                          .commonTextForFieldAuth(
                                                                              img_form_email:
                                                                                  Imageconstants
                                                                                      .img_form_email,
                                                                              controller:
                                                                                  emailController,
                                                                              maxlines:
                                                                                  1,
                                                                              hintText:
                                                                                  'Please enter your email',
                                                                              maxLength:
                                                                                  100,
                                                                              textInputType:
                                                                                  TextInputType
                                                                                      .emailAddress,
                                                                              validatorFunc:
                                                                                  (value) {
                                                                                if (value!.isNotEmpty &&
                                                                                    Validator.emailValidator(value) !=
                                                                                        null) {
                                                                                  return 'Please enter valid Email';
                                                                                }
                                                                              },
                                                                              onchanged:
                                                                                  (value) {},
                                                                              inputformaters: []),
                                                                    ),*/
                                                                    Container(
                                                                      child: Appwidgets.commonTextForFieldAuth2(
                                                                          focusNode: emailfocus,
                                                                          imgFormEmail: Imageconstants.img_form_email,
                                                                          controller: emailController,
                                                                          maxLines: 1,
                                                                          hintText: 'Email',
                                                                          maxLength: 100,
                                                                          textInputType: TextInputType.emailAddress,
                                                                          validatorFunc: (value) {
                                                                            if (value!.trim().isNotEmpty &&
                                                                                Validator.emailValidator(value.trim()) != null) {
                                                                              return 'Please enter valid Email';
                                                                            }
                                                                          },
                                                                          onChanged: (value) {},
                                                                          inputFormatters: [
                                                                            FilteringTextInputFormatter.allow(RegExp("[0-9@a-zA-Z.]")),
                                                                          ]),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      top: 10),
                                                              alignment: Alignment
                                                                  .bottomCenter,
                                                              child: Container(
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Container(),
                                                                    Container(
                                                                      child:
                                                                          Align(
                                                                        alignment:
                                                                            Alignment.bottomCenter,
                                                                        child:
                                                                            InkWell(
                                                                          onTap:
                                                                              () async {
                                                                            OndoorThemeData.keyBordDow();

                                                                            if (_formKey.currentState!.validate()) {
                                                                              invalidForm = false;
                                                                              registerdBloc.add(FormStateEvent(isvalid: invalidForm));

                                                                              if (await Network.isConnected()) {
                                                                                ApiProvider().registerUser(nameController.text, mobileController.text, emailController.text, context, false, widget.fromRoute).then((value) {});
                                                                              } else {
                                                                                MyDialogs.showInternetDialog(context, () {
                                                                                  Navigator.pop(context);
                                                                                });
                                                                              }
                                                                            } else {
                                                                              invalidForm = true;
                                                                              registerdBloc.add(FormStateEvent(isvalid: invalidForm));
                                                                            }
                                                                          },
                                                                          child: Container(
                                                                              width: Sizeconfig.getWidth(context),
                                                                              padding: EdgeInsets.symmetric(vertical: 10),
                                                                              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10.0)), color: ColorName.ColorPrimary),
                                                                              child: Center(
                                                                                child: Appwidgets.TextLagre(StringContants.lbl_login, Colors.white),
                                                                              )),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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
                          );
                        }),
                  ),
                );
              }),
            ),
          )),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    CommanLoader().dismissEasyLoader();
    super.dispose();
  }
}
