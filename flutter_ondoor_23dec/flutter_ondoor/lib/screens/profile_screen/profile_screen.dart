import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ondoor/constants/Constant.dart';
import 'package:ondoor/constants/FontConstants.dart';
import 'package:ondoor/constants/ImageConstants.dart';
import 'package:ondoor/constants/StringConstats.dart';
import 'package:ondoor/models/get_profile_response.dart';
import 'package:ondoor/screens/profile_screen/profile_screen_bloc/profile_screen_bloc.dart';
import 'package:ondoor/screens/profile_screen/profile_screen_bloc/profile_screen_event.dart';
import 'package:ondoor/screens/profile_screen/profile_screen_bloc/profile_screen_state.dart';
import 'package:ondoor/services/ApiServices.dart';
import 'package:ondoor/services/Navigation/routes.dart';
import 'package:ondoor/utils/Connection.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/SizeConfig.dart';
import 'package:ondoor/utils/sharedpref.dart';
import 'package:ondoor/utils/shimmerUi.dart';
import 'package:ondoor/widgets/AppWidgets.dart';
import 'package:ondoor/widgets/MyDialogs.dart';
import 'package:ondoor/widgets/common_loading_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../utils/Comman_Loader.dart';
import '../../utils/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  ProfileScreenBloc profileScreenBloc = ProfileScreenBloc();
  String userName = "";
  String email = "";
  String userMobileNumber = "";
  String userLocality = "";
  String fcmToken = "";
  String serverToken = "";
  String customer_id = "";
  String token_type = "";
  String access_token = "";
  String token = "";
  @override
  void initState() {
    EasyLoading.dismiss();
    Appwidgets.setStatusBarColor();
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    // profileScreenBloc.getprofileData(context);
    readLocality();
    super.initState();
  }

  readLocality() async {
    userLocality = await SharedPref.getStringPreference(Constants.LOCALITY);
    fcmToken = await SharedPref.getStringPreference(Constants.fcmToken);
    serverToken = await SharedPref.getStringPreference(Constants.serverToken);
    print("FCM TOKEN ${fcmToken}");
    log("SERVER TOKEN ${serverToken}");
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: profileScreenBloc,
      builder: (context, state) {
        // Handle different states if needed
        debugPrint("CURRENT STATE $state");
        if (state is ProfileScreenInitialState) {
          // EasyLoading.show();
        }
        if (state is ProfileScreenLoadedState) {
          userName = "${state.data.firstname} ${state.data.lastname}";
          userMobileNumber = "${state.data.telephone}";
          email = "${state.data.email}";
        }
        print("USER NAME ${userName} ${userName.length}");
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            statusBarColor: ColorName.ColorPrimary,
          ),
          child: MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(1.2)),
            child: Scaffold(
              backgroundColor: ColorName.whiteSmokeColor,
              appBar: AppBar(
                  systemOverlayStyle: const SystemUiOverlayStyle(
                    statusBarIconBrightness: Brightness.light,
                    statusBarColor: ColorName.ColorPrimary,
                  ),
                  leading: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.arrow_back_ios)),
                  //TODO logout button for testing purpose only
                  // actions: [
                  //   token == " "
                  //       ? const SizedBox.shrink()
                  //       : GestureDetector(
                  //           onTap: () {
                  //             SharedPref.clearSharedPreference(context);
                  //             Navigator.pushReplacementNamed(
                  //                 context, Routes.location_screen,
                  //                 arguments: Routes.profile_screen);
                  //           },
                  //           child: Text(
                  //             "Log out",
                  //             style: Appwidgets()
                  //                 .commonTextStyle(ColorName.ColorBagroundPrimary),
                  //           )),
                  //   10.toSpace
                  // ],
                  title: Text(
                    StringContants.lbl_profile,
                    style: Appwidgets()
                        .commonTextStyle(ColorName.ColorBagroundPrimary)
                        .copyWith(fontSize: 17, fontWeight: FontWeight.w500),
                  )),
              body: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  if (details.primaryDelta!.toInt() > 0.0) {
                    Navigator.pop(context);
                  }
                },
                child: VisibilityDetector(
                  key: const Key(Routes.profile_screen),
                  onVisibilityChanged: (visibilityInfo) async {
                    var visiblePercentage =
                        visibilityInfo.visibleFraction * 100;
                    if (visiblePercentage == 100) {
                      token_type = await SharedPref.getStringPreference(
                          Constants.sp_TOKENTYPE);
                      access_token = await SharedPref.getStringPreference(
                          Constants.sp_AccessTOEKN);

                      token = "$token_type $access_token";
                      profileScreenBloc.getprofileData(context);
                    }
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: ColorName.ColorBagroundPrimary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          width: Sizeconfig.getWidth(context),
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              /*userName == ""
                                  ? Shimmerui.shimmer_for_profileLogo(context, 0)
                                  :*/
                              Image.asset(
                                Imageconstants.ondoor_logo,
                                width: 80,
                                height: 80,
                              ),
                              10.toSpace,
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    userName != ""
                                        ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                StringContants.lbl_welcome,
                                                softWrap: true,
                                                // maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Appwidgets()
                                                    .commonTextStyle(
                                                        ColorName.grey_chateau)
                                                    .copyWith(
                                                        fontSize:
                                                            userName.length > 10
                                                                ? 13
                                                                : 17,
                                                        fontWeight:
                                                            FontWeight.w600),
                                              ),
                                              Text(
                                                userName,
                                                softWrap: true,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Appwidgets()
                                                    .commonTextStyle(
                                                        ColorName.tuna)
                                                    .copyWith(
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.w600),
                                              ),
                                            ],
                                          )
                                        : Shimmerui.shimmer_for_profile(context,
                                            Sizeconfig.getWidth(context) * 0.3),
                                    5.toSpace,
                                    userMobileNumber == "" || userLocality == ""
                                        ? const SizedBox.shrink()
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .phone_android_outlined,
                                                    color:
                                                        ColorName.ColorPrimary,
                                                    size: 17,
                                                  ),
                                                  5.toSpace,
                                                  Text(
                                                    userMobileNumber,
                                                    style: Appwidgets()
                                                        .commonTextStyle(
                                                            ColorName
                                                                .grey_chateau)
                                                        .copyWith(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.location_pin,
                                                    color:
                                                        ColorName.ColorPrimary,
                                                    size: 17,
                                                  ),
                                                  5.toSpace,
                                                  Text(
                                                    userLocality.split(', ')[0],
                                                    style: Appwidgets()
                                                        .commonTextStyle(
                                                            ColorName
                                                                .grey_chateau)
                                                        .copyWith(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: ColorName.ColorBagroundPrimary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          width: Sizeconfig.getWidth(context),
                          padding: EdgeInsets.all(10),
                          margin:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Column(
                            children: [
                              profileSectionItem(
                                StringContants.lbl_home,
                                Imageconstants.home_logo,
                                () {
                                  Navigator.pop(context);
                                },
                              ),
                              10.toSpace,
                              profileSectionItem(
                                StringContants.lbl_my_orders,
                                Imageconstants.my_orders,
                                () async {
                                  customer_id =
                                      await SharedPref.getStringPreference(
                                          Constants.sp_CustomerId);
                                  token_type =
                                      await SharedPref.getStringPreference(
                                          Constants.sp_TOKENTYPE);
                                  access_token =
                                      await SharedPref.getStringPreference(
                                          Constants.sp_AccessTOEKN);

                                  token = "$token_type $access_token";
                                  if (token.trim().isEmpty &&
                                      customer_id == '') {
                                    routetoRegister(
                                        Routes.order_history, context);
                                  } else {
                                    // profileScreenBloc.getprofileData(context);
                                    Navigator.pushNamed(
                                        context, Routes.order_history);
                                  }
                                },
                              ),
                              /* 10.toSpace,
                              profileSectionItem(
                                StringContants.lbl_shopping_list,
                                Imageconstants.shopping_list,
                                () async {
                                  customer_id =
                                      await SharedPref.getStringPreference(
                                          Constants.sp_CustomerId);
                                  token_type = await SharedPref.getStringPreference(
                                      Constants.sp_TOKENTYPE);
                                  access_token =
                                      await SharedPref.getStringPreference(
                                          Constants.sp_AccessTOEKN);

                                  token = "$token_type $access_token";
                                  if (token == ' ' && customer_id == '') {
                                    routetoRegister(Routes.shopping_list, context);

                                    // await SharedPref.setStringPreference(
                                    //     Constants.sp_VerifyRoute,
                                    //     Routes.shopping_list);
                                    // Navigator.pushNamed(
                                    //         context, Routes.register_screen,
                                    //         arguments: Routes.profile_screen)
                                    //     .then(
                                    //   (value) {
                                    //     Appwidgets.setStatusBarColor();
                                    //   },
                                    // );
                                  } else {
                                    Navigator.pushNamed(
                                        context, Routes.shopping_list);
                                  }
                                },
                              ),*/
                              10.toSpace,
                              profileSectionItem(
                                StringContants.lbl_edit_profile,
                                Imageconstants.edit_profile,
                                () async {
                                  customer_id =
                                      await SharedPref.getStringPreference(
                                          Constants.sp_CustomerId);
                                  token_type =
                                      await SharedPref.getStringPreference(
                                          Constants.sp_TOKENTYPE);
                                  access_token =
                                      await SharedPref.getStringPreference(
                                          Constants.sp_AccessTOEKN);

                                  token = "$token_type $access_token";
                                  print("token ${token}");
                                  print("Customer id ${customer_id}");
                                  if (token == ' ' && customer_id == '') {
                                    routetoRegister(
                                        Routes.edit_profile, context);

                                    // await SharedPref.setStringPreference(
                                    //     Constants.sp_VerifyRoute,
                                    //     Routes.edit_profile);
                                    // Navigator.pushNamed(
                                    //         context, Routes.register_screen,
                                    //         arguments: Routes.profile_screen)
                                    //     .then(
                                    //   (value) {
                                    //     Appwidgets.setStatusBarColor();
                                    //   },
                                    // );
                                  } else {
                                    // profileScreenBloc.getprofileData(context);

                                    Navigator.pushNamed(
                                        context, Routes.edit_profile);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: ColorName.ColorBagroundPrimary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          width: Sizeconfig.getWidth(context),
                          padding: EdgeInsets.all(10),
                          margin:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Column(
                            children: [
                              profileSectionItem(
                                StringContants.lbl_my_address,
                                Imageconstants.my_address_icon,
                                () async {
                                  customer_id =
                                      await SharedPref.getStringPreference(
                                          Constants.sp_CustomerId);
                                  token_type =
                                      await SharedPref.getStringPreference(
                                          Constants.sp_TOKENTYPE);
                                  access_token =
                                      await SharedPref.getStringPreference(
                                          Constants.sp_AccessTOEKN);

                                  token = "$token_type $access_token";
                                  if (token == ' ' && customer_id == '') {
                                    routetoRegister(
                                        Routes.change_address, context);

                                    // await SharedPref.setStringPreference(
                                    //     Constants.sp_VerifyRoute,
                                    //     Routes.change_address);
                                    // Navigator.pushNamed(
                                    //         context, Routes.register_screen,
                                    //         arguments: Routes.profile_screen)
                                    //     .then(
                                    //   (value) {
                                    //     Appwidgets.setStatusBarColor();
                                    //   },
                                    // );
                                  } else {
                                    // profileScreenBloc.getprofileData(context);

                                    Navigator.pushNamed(
                                        context, Routes.change_address,
                                        arguments: Routes.profile_screen);
                                  }
                                },
                              ),
                              10.toSpace,
                              profileSectionItem(
                                StringContants.lbl_change_location,
                                Imageconstants.change_location_icon,
                                () async {
                                  customer_id =
                                      await SharedPref.getStringPreference(
                                          Constants.sp_CustomerId);
                                  token_type =
                                      await SharedPref.getStringPreference(
                                          Constants.sp_TOKENTYPE);
                                  access_token =
                                      await SharedPref.getStringPreference(
                                          Constants.sp_AccessTOEKN);

                                  token = "$token_type $access_token";
                                  if (token == ' ' && customer_id == '') {
                                    routetoRegister(
                                        Routes.location_screen, context);

                                    // await SharedPref.setStringPreference(
                                    //     Constants.sp_VerifyRoute,
                                    //     Routes.location_screen);
                                    // Navigator.pushNamed(
                                    //         context, Routes.register_screen,
                                    //         arguments: Routes.profile_screen)
                                    //     .then(
                                    //   (value) {
                                    //     Appwidgets.setStatusBarColor();
                                    //   },
                                    // );
                                  } else {
                                    // profileScreenBloc.getprofileData(context);

                                    Navigator.pushNamed(
                                        context, Routes.location_screen,
                                        arguments: Routes.profile_screen);
                                  }
                                },
                              ),
                              10.toSpace,
                              profileSectionItem(
                                StringContants.lbl_order_on_phone,
                                Imageconstants.order_on_phone,
                                () {
                                  Navigator.pushNamed(
                                      context, Routes.order_by_phone);
                                },
                              ),
                              10.toSpace,
                              profileSectionItem(
                                StringContants.lbl_notifications,
                                Imageconstants.notification_bell,
                                () async {
                                  customer_id =
                                      await SharedPref.getStringPreference(
                                          Constants.sp_CustomerId);
                                  token_type =
                                      await SharedPref.getStringPreference(
                                          Constants.sp_TOKENTYPE);
                                  access_token =
                                      await SharedPref.getStringPreference(
                                          Constants.sp_AccessTOEKN);

                                  token = "$token_type $access_token";
                                  if (token == ' ' && customer_id == '') {
                                    routetoRegister(
                                        Routes.notification_center, context);

                                    // await SharedPref.setStringPreference(
                                    //     Constants.sp_VerifyRoute,
                                    //     Routes.notification_center);
                                    // Navigator.pushNamed(
                                    //         context, Routes.register_screen,
                                    //         arguments: Routes.profile_screen)
                                    //     .then(
                                    //   (value) {
                                    //     Appwidgets.setStatusBarColor();
                                    //   },
                                    // );
                                  } else {
                                    Navigator.pushNamed(
                                        context, Routes.notification_center);
                                  }
                                },
                              ),
                              10.toSpace,
                              profileSectionItem(
                                StringContants.lbl_contact_us,
                                Imageconstants.contact_us,
                                () async {
                                  customer_id =
                                      await SharedPref.getStringPreference(
                                          Constants.sp_CustomerId);
                                  token_type =
                                      await SharedPref.getStringPreference(
                                          Constants.sp_TOKENTYPE);
                                  access_token =
                                      await SharedPref.getStringPreference(
                                          Constants.sp_AccessTOEKN);

                                  token = "$token_type $access_token";
                                  if (token == ' ' && customer_id == '') {
                                    routetoRegister(Routes.contact_us, context);
                                    // Navigator.pushNamed(
                                    //         context, Routes.register_screen,
                                    //         arguments: Routes.profile_screen)
                                    //     .then(
                                    //   (value) {
                                    //     Appwidgets.setStatusBarColor();
                                    //   },
                                    // );
                                  } else {
                                    // profileScreenBloc.getprofileData(context);

                                    Navigator.pushNamed(
                                        context, Routes.contact_us, arguments: {
                                      "userName": userName,
                                      "email": email,
                                      "telephone": userMobileNumber
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: ColorName.ColorBagroundPrimary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          width: Sizeconfig.getWidth(context),
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.fromLTRB(10, 5, 10, 10),
                          child: Column(
                            children: [
                              ExpansionTile(
                                tilePadding: EdgeInsets.zero,
                                childrenPadding:
                                    const EdgeInsets.symmetric(horizontal: 50),
                                collapsedIconColor: ColorName.pale_sky,
                                iconColor: ColorName.pale_sky,
                                dense: true,
                                initiallyExpanded: false,
                                controlAffinity:
                                    ListTileControlAffinity.trailing,
                                expandedAlignment: Alignment.centerLeft,
                                expandedCrossAxisAlignment:
                                    CrossAxisAlignment.start,
                                visualDensity: VisualDensity.comfortable,
                                shape: const RoundedRectangleBorder(
                                    side: BorderSide.none),
                                title: Row(
                                  children: [
                                    10.toSpace,
                                    Image.asset(
                                      Imageconstants.company_info,
                                      width: 20,
                                      height: 20,
                                    ),
                                    20.toSpace,
                                    Text(
                                      StringContants.lbl_company,
                                      style: Appwidgets()
                                          .commonTextStyle(ColorName.black)
                                          .copyWith(
                                            fontSize: 16,
                                            fontFamily:
                                                Fontconstants.fc_family_sf,
                                            fontWeight: Fontconstants
                                                .SF_Pro_Display_Regular,
                                          ),
                                    ),
                                  ],
                                ),
                                children: [
                                  5.toSpace,
                                  GestureDetector(
                                    onTap: () {
                                      // arguements is page id for company info

                                      Navigator.pushNamed(
                                          context, Routes.company_info_page,
                                          arguments: "4");
                                    },
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Text(
                                        StringContants.lbl_about_us,
                                        style: Appwidgets()
                                            .commonTextStyle(ColorName.black)
                                            .copyWith(
                                              fontSize: 16,
                                              fontFamily:
                                                  Fontconstants.fc_family_sf,
                                              fontWeight: Fontconstants
                                                  .SF_Pro_Display_Regular,
                                            ),
                                      ),
                                    ),
                                  ),
                                  15.toSpace,
                                  GestureDetector(
                                    onTap: () {
                                      // arguements is page id for company info

                                      Navigator.pushNamed(
                                          context, Routes.company_info_page,
                                          arguments: "3");
                                    },
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Text(
                                        StringContants.lbl_privacy_policy,
                                        style: Appwidgets()
                                            .commonTextStyle(ColorName.black)
                                            .copyWith(
                                              fontSize: 16,
                                              fontFamily:
                                                  Fontconstants.fc_family_sf,
                                              fontWeight: Fontconstants
                                                  .SF_Pro_Display_Regular,
                                            ),
                                      ),
                                    ),
                                  ),
                                  15.toSpace,
                                  GestureDetector(
                                    onTap: () {
                                      // arguements is page id for company info
                                      Navigator.pushNamed(
                                          context, Routes.company_info_page,
                                          arguments: "5");
                                    },
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Text(
                                        StringContants.lbl_terms_and_conditions,
                                        style: Appwidgets()
                                            .commonTextStyle(ColorName.black)
                                            .copyWith(
                                              fontSize: 16,
                                              fontFamily:
                                                  Fontconstants.fc_family_sf,
                                              fontWeight: Fontconstants
                                                  .SF_Pro_Display_Regular,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              10.toSpace,
                              profileSectionItem(
                                StringContants.lbl_share_App,
                                Imageconstants.share_app_logo,
                                () async {
                                  Share.share(StringContants.lbl_share_text);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget profileSectionItem(
      String sectionTitle, String sectionIcon, Function()? onpress) {
    return GestureDetector(
      onTap: onpress,
      child: Container(
        color: ColorName.ColorBagroundPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              sectionIcon,
              width: 20,
              height: 20,
            ),
            20.toSpace,
            Text(
              sectionTitle,
              style: Appwidgets().commonTextStyle(ColorName.black).copyWith(
                    fontSize: 16,
                    fontFamily: Fontconstants.fc_family_sf,
                    fontWeight: Fontconstants.SF_Pro_Display_Regular,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    CommanLoader().dismissEasyLoader();
    super.dispose();
  }

  routetoRegister(String routeName, BuildContext context) async {
    await SharedPref.setStringPreference(Constants.sp_VerifyRoute, routeName);
    Navigator.pushNamed(context, Routes.register_screen,
            arguments: Routes.profile_screen)
        .then(
      (value) {
        Appwidgets.setStatusBarColor();
        profileScreenBloc.getprofileData(context);
      },
    );
  }
}
