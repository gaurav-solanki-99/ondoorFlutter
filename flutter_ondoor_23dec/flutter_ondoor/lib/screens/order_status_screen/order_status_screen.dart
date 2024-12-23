import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:intl/intl.dart';
import 'package:ondoor/constants/Constant.dart';
import 'package:ondoor/constants/ImageConstants.dart';
import 'package:ondoor/constants/StringConstats.dart';
import 'package:ondoor/database/database_helper.dart';
import 'package:ondoor/screens/NewAnimation/animation_bloc.dart';
import 'package:ondoor/screens/order_status_screen/order_status_bloc/order_status_bloc.dart';
import 'package:ondoor/screens/order_status_screen/order_status_bloc/order_status_events.dart';
import 'package:ondoor/screens/order_status_screen/order_status_bloc/order_status_state.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/SizeConfig.dart';
import 'package:ondoor/utils/colors.dart';
import 'package:ondoor/utils/sharedpref.dart';
import 'package:ondoor/widgets/AppWidgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/FontConstants.dart';
import '../../services/Navigation/route_generator.dart';
import '../../services/Navigation/routes.dart';
import '../../utils/Comman_Loader.dart';
import '../../utils/Utility.dart';
import '../../widgets/Custom_Widgets.dart';
import '../NewAnimation/animation_state.dart';

class OrderStatusScreen extends StatefulWidget {
  bool success;
  int order_id;
  String message;
  String paid_by;
  String coupon_id;
  String delivery_location;
  String rating_redirect_url;
  String selected_time_slot;
  String selected_date_slot;
  dynamic amount;
  OrderStatusScreen({
    super.key,
    required this.success,
    required this.order_id,
    required this.message,
    required this.paid_by,
    required this.rating_redirect_url,
    required this.coupon_id,
    required this.amount,
    required this.delivery_location,
    required this.selected_time_slot,
    required this.selected_date_slot,
  });

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController animationController;
  late AnimationController dataAppearenceController;
  late Animation<double> _animation;
  Animation<double>? _imageSizeAnimation; // Animation for image size
  Animation<double>? _dataAppearenceAnimation; // Animation for image size
  late Animation<Offset> _slideAnimation;
  OrderStatusBloc orderStatusBloc = OrderStatusBloc();
  DatabaseHelper dbHelper = DatabaseHelper();
  final InAppReview inAppReview = InAppReview.instance;
  double screenHeight = 0.0;
  double screenWidth = 0.0;
  double size = 0.0;
  bool isRatedonPlayStore = false;
  int DURATION_IN_SECONDS = 2;
  bool _isDialogShowing = false;

  @override
  void initState() {
    getFcmToken();
    super.initState();
    Appwidgets.setStatusBarDynamicDarkColor(color: ColorName.sugarCane);
    dbHelper.init();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: DURATION_IN_SECONDS),
    );
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: DURATION_IN_SECONDS),
    );
    dataAppearenceController =
        AnimationController(vsync: this, duration: Duration(seconds: 5));
    // Initialize the size animation
    dataAppearenceController.forward();
    animationController.forward();
    _controller.forward();
  }

  isRatedonPlayStoreFun() async {
    // print("isRatedonPlayStore<<<<<<  ${isRatedonPlayStore}");
    SharedPref.getBooleanPreference(Constants.isRatedonPlayStore).then(
      (value) {
        isRatedonPlayStore = value;
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    animationController.dispose();
    dataAppearenceController.dispose();
    CommanLoader().dismissEasyLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = Sizeconfig.getHeight(context);
    screenWidth = Sizeconfig.getWidth(context);
    Appwidgets.setStatusBarDynamicDarkColor(color: ColorName.sugarCane);
    return WillPopScope(
      onWillPop: () async {
        navigateToHomeScreen();
        return false;
      },
      child: SafeArea(
          child: Scaffold(
        backgroundColor: ColorName.sugarCane,
        body: BlocBuilder<OrderStatusBloc, OrderStatusState>(
          bloc: orderStatusBloc,
          builder: (context, state) {
            Appwidgets.setStatusBarDynamicDarkColor(color: ColorName.sugarCane);
            isRatedonPlayStoreFun();
            if (state is OrderStatusInitialState) {
              size = screenHeight * .028;

              Future.delayed(Duration(seconds: 2), () {
                startAnimation(context, size);
              });
              Appwidgets.setStatusBarDynamicDarkColor(
                  color: ColorName.sugarCane);

              return Center(
                child: _orderSuccessIcon(),
              );
            } else if (state is OrderStatusAnimationState) {
              _animation = state.animation;
              _slideAnimation = state.slideAnimation;
              _dataAppearenceAnimation = state.dataAppearenceAnimation;
              if (_dataAppearenceAnimation == null) {
                dataAppearenceFunction();
              }
              double opacity = _dataAppearenceAnimation?.value ?? 0.0;
              if (_dataAppearenceAnimation != null) {
                print("OPACITY ${opacity}");
                print(
                    "OPACITY DATA APPEARENCE ${_dataAppearenceAnimation!.status}");
                if (isRatedonPlayStore == false &&
                    _slideAnimation.status == AnimationStatus.completed) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (timeStamp) {
                      Future.delayed(
                        Duration(seconds: 3),
                        () {
                          if (_isDialogShowing == false) {
                            /// showRateUsDialog();
                            showRateUsBottomSheet();
                          }
                        },
                      );
                    },
                  );
                }
              }
              // Use a post-frame callback to show the dialog
              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    SlideTransition(
                      position: _slideAnimation,
                      child: Align(
                        alignment: Alignment.center,
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            double size = 20 + (_animation.value / 1000) * 50;
                            return Transform.scale(
                              scale: _imageSizeAnimation!.value,
                              child: _orderSuccessIcon(),
                            );
                          },
                        ),
                      ),
                    ),
                    AnimatedOpacity(
                      duration: Duration(seconds: 1),
                      opacity: opacity,
                      child: _orderWidget(
                        title: widget.message,
                        orderId: widget.order_id,
                        amount: double.parse(widget.amount.toString()),
                        paidBy: widget.paid_by,
                        couponId: widget.coupon_id,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink(); // Fallback case
          },
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Appwidgets.MyButton(
            StringContants.lbl_continue_shopping,
            Sizeconfig.getWidth(context) * .5,
            () {
              navigateToHomeScreen();
            },
          ),
        ),
      )),
    );
  }

  navigateToHomeScreen() {
    dbHelper.cleanCartDatabase().then(
      (value) {
        _controller.dispose();
        animationController.dispose();
        dataAppearenceController.dispose();
        Navigator.of(context).pushReplacementNamed(Routes.home_page).then(
          (value) {
            Appwidgets.setStatusBarColor();
          },
        );
      },
    );
  }

  showRateUsDialog() {
    print("IS DIALOG SHOWING ${_isDialogShowing}");
    if (_isDialogShowing) return;
    _isDialogShowing = true;
    orderStatusBloc.add(OrderStatusNullEvent());
    showGeneralDialog(
      context: context,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        late Offset begin;
        late Offset end;

        // Determine the begin and end positions based on the direction
        SlideDirection.bottomToTop;
        begin = const Offset(0.0, 1.0); // Start off screen at the bottom
        end = Offset.zero;

        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: screenHeight,
                  width: screenWidth,
                  color: Colors.black.withOpacity(0.1),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: screenWidth,
                  height: screenHeight * 0.35,
                  decoration: BoxDecoration(
                    color: ColorName.ColorBagroundPrimary,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      topLeft: Radius.circular(12),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        10.toSpace,
                        Text(
                          StringContants.lbl_enjoying_our_app,
                          textAlign: TextAlign.center,
                          style: Appwidgets()
                              .commonTextStyle(ColorName.black)
                              .copyWith(
                                  letterSpacing: 0.45,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            StringContants.lbl_we_Love_to_Hear,
                            textAlign: TextAlign.center,
                            style: Appwidgets()
                                .commonTextStyle(ColorName.black)
                                .copyWith(
                                    letterSpacing: 0.45,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            dbHelper.cleanCartDatabase().then(
                              (value) {
                                Navigator.of(context)
                                    .pushReplacementNamed(Routes.home_page)
                                    .then(
                                  (value) {
                                    // Appwidgets.setStatusBarColor();
                                  },
                                );
                                openPlayStore();
                              },
                            );
                          },
                          child: Container(
                            width: screenWidth,
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            padding: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                color: ColorName.ColorPrimary),
                            child: Text(
                              "Rate us",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: Constants.Sizelagre,
                                  fontFamily: Fontconstants.fc_family_sf,
                                  fontWeight: Fontconstants.SF_Pro_Display_Bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            "Maybe Later",
                            style: Appwidgets()
                                .commonTextStyle(ColorName.ColorPrimary)
                                .copyWith(
                                    fontSize: 14,
                                    fontWeight:
                                        Fontconstants.SF_Pro_Display_SEMIBOLD),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: screenWidth * .25,
                right: screenWidth * .25,
                bottom: (screenHeight * 0.35) - 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: ColorName.ColorBagroundPrimary,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(
                        child: Image.asset(
                          Imageconstants.rating_image,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showRateUsBottomSheet() {
    if (_isDialogShowing) return;
    _isDialogShowing = true;
    showModalBottomSheet(
        barrierColor: Colors.black.withOpacity(0.4),
        elevation: 0,
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25),
          ),
        ),
        backgroundColor: Colors.transparent,
        builder: (context) {
          // using a scaffold helps to more easily position the FAB
          return Container(
            height: Sizeconfig.getHeight(context) * 0.45,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: screenHeight,
                    width: screenWidth,
                    color: Colors.transparent,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: screenWidth,
                    height: screenHeight * 0.35,
                    decoration: BoxDecoration(
                      color: ColorName.ColorBagroundPrimary,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        topLeft: Radius.circular(12),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          10.toSpace,
                          Text(
                            StringContants.lbl_enjoying_our_app,
                            textAlign: TextAlign.center,
                            style: Appwidgets()
                                .commonTextStyle(ColorName.black)
                                .copyWith(
                                    letterSpacing: 0.45,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              StringContants.lbl_we_Love_to_Hear,
                              textAlign: TextAlign.center,
                              style: Appwidgets()
                                  .commonTextStyle(ColorName.black)
                                  .copyWith(
                                      letterSpacing: 0.45,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              dbHelper.cleanCartDatabase().then(
                                (value) {
                                  Navigator.of(context)
                                      .pushReplacementNamed(Routes.home_page)
                                      .then(
                                    (value) {
                                      // Appwidgets.setStatusBarColor();
                                    },
                                  );
                                  openPlayStore();
                                },
                              );
                            },
                            child: Container(
                              width: screenWidth,
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              padding: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  color: ColorName.ColorPrimary),
                              child: Text(
                                "Rate us",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: Constants.Sizelagre,
                                    fontFamily: Fontconstants.fc_family_sf,
                                    fontWeight:
                                        Fontconstants.SF_Pro_Display_Bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              "Maybe Later",
                              style: Appwidgets()
                                  .commonTextStyle(ColorName.ColorPrimary)
                                  .copyWith(
                                      fontSize: 14,
                                      fontWeight: Fontconstants
                                          .SF_Pro_Display_SEMIBOLD),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: screenWidth * .25,
                  right: screenWidth * .25,
                  bottom: (screenHeight * 0.35) - 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: ColorName.ColorBagroundPrimary,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: Image.asset(
                            Imageconstants.rating_image,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).then((value) {
      debugPrint("Colse Bottom View $value");
    });
  }

  showRateUsDialogNew(
    AnimationBloc animationBloc,
    var animatedSize,
  ) {
    return BlocProvider(
      create: (context) => animationBloc,
      child: BlocBuilder(
          bloc: animationBloc,
          builder: (context, state2) {
            debugPrint("Animation Cart State  1 ${state2} $animatedSize");

            if (state2 is AnimationCartState) {
              animatedSize = state2.size;
            }

            return GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Stack(
                children: [
                  Container(
                    height: screenHeight,
                    width: screenWidth,
                    color: Colors.black.withOpacity(0.1),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: screenWidth,
                      height: screenHeight * 0.35,
                      decoration: BoxDecoration(
                        color: ColorName.ColorBagroundPrimary,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          topLeft: Radius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            10.toSpace,
                            Text(
                              StringContants.lbl_enjoying_our_app,
                              textAlign: TextAlign.center,
                              style: Appwidgets()
                                  .commonTextStyle(ColorName.black)
                                  .copyWith(
                                    letterSpacing: 0.45,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                StringContants.lbl_we_Love_to_Hear,
                                textAlign: TextAlign.center,
                                style: Appwidgets()
                                    .commonTextStyle(ColorName.black)
                                    .copyWith(
                                      letterSpacing: 0.45,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                dbHelper.cleanCartDatabase().then(
                                  (value) {
                                    Navigator.of(context)
                                        .pushReplacementNamed(Routes.home_page)
                                        .then(
                                      (value) {
                                        // Appwidgets.setStatusBarColor();
                                      },
                                    );
                                    openPlayStore();
                                  },
                                );
                              },
                              child: Container(
                                width: screenWidth,
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                padding: EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  color: ColorName.ColorPrimary,
                                ),
                                child: Text(
                                  "Rate us",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: Constants.Sizelagre,
                                    fontFamily: Fontconstants.fc_family_sf,
                                    fontWeight:
                                        Fontconstants.SF_Pro_Display_Bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                "Maybe Later",
                                style: Appwidgets()
                                    .commonTextStyle(ColorName.ColorPrimary)
                                    .copyWith(
                                      fontSize: 14,
                                      fontWeight:
                                          Fontconstants.SF_Pro_Display_SEMIBOLD,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: screenWidth * .25,
                    right: screenWidth * .25,
                    bottom: (screenHeight * 0.35) - 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          alignment: Alignment.topCenter,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: ColorName.ColorBagroundPrimary,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Center(
                            child: Image.asset(
                              Imageconstants.rating_image,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }

  void openPlayStore() async {
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        final url = Uri.parse(widget.rating_redirect_url);
        SharedPref.setBooleanPreference(Constants.isRatedonPlayStore, true);
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } on PlatformException catch (e) {
        debugPrint('Failed to launch URL: ${e.message}');
        // Handle error in UI or retry logic
      }
    }
  }

  dataAppearenceFunction() {
    print("SLIDE ANIMATION STATUS ${_slideAnimation.value}");
    double dx = 0.0;
    double dy = 1.0;
    print("SLIDE ANIMATION DX ${dx} DY ${dy}");
    if (_slideAnimation.status == AnimationStatus.completed) {
      _dataAppearenceAnimation = Tween<double>(begin: dx, end: dy).animate(
        CurvedAnimation(
          parent: dataAppearenceController,
          curve: Curves.easeInOut,
        ),
      );
      orderStatusBloc.add(OrderStatusAnimationEvent(
          animation: _animation,
          slideAnimation: _slideAnimation,
          dataAppearenceAnimation: _dataAppearenceAnimation));
    }
  }

  Widget _orderSuccessIcon() {
    final double imageHeight = screenHeight * 0.24;
    final double imageHeight2 = screenHeight * 0.3;
    final double successIconHeight = screenHeight * 0.08;
    final double successIconWidth = screenWidth * 0.17;
    final double tickIconSize = screenWidth * 0.2;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 20),
          height: imageHeight2,
          // color: Colors.red,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                Imageconstants.order_success_image,
                width: screenWidth * 0.67,
                height: imageHeight,
                fit: BoxFit.fill,
              ),
              // Positioned(
              //   bottom: screenHeight * 0.05,
              //   child: Container(
              //     width: successIconWidth,
              //     height: successIconHeight,
              //     decoration: BoxDecoration(
              //       border:
              //           Border.all(color: ColorName.malachiteGreen, width: 0.8),
              //       borderRadius: BorderRadius.circular(80),
              //       color: ColorName.ColorBagroundPrimary,
              //     ),
              //   ),
              // ),
              Positioned(
                bottom: screenHeight * 0.04,
                child: SizedBox(
                  width: tickIconSize,
                  height: tickIconSize,
                  child: Image.asset(
                    Imageconstants.verified,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10), // Use SizedBox for spacing
        Text(
          StringContants.lbl_order_placed_successfully,
          style: Appwidgets()
              .commonTextStyle(ColorName.black)
              .copyWith(fontSize: 15),
        ),
      ],
    );
  }

  Future<void> startAnimation(BuildContext context, double initialSize) async {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: DURATION_IN_SECONDS),
    );
    _animation =
        Tween<double>(begin: initialSize, end: 1000).animate(_controller);

    // Reverse the slide animation
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.35), // Start from below
      end: Offset(0, 0), // End at the center
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.addListener(() {
      double dx = _slideAnimation.value.dx;
      double dy = _slideAnimation.value.dy;
      print("SLIDE ANIMATION 1>>>  ${dx}, ${dy}");
      double remain = 1.0 - dy;
      dy = dy + remain;
      // dy = dy + 1;
      print("SLIDE ANIMATION<<<<< ${dx}, ${dy}");
      _imageSizeAnimation = Tween<double>(begin: dx, end: dy).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Curves.easeIn,
        ),
      );
      orderStatusBloc.add(OrderStatusAnimationEvent(
          animation: _animation,
          slideAnimation: _slideAnimation,
          dataAppearenceAnimation: _dataAppearenceAnimation));
    });

    await _controller.forward();
  }

  getFcmToken() async {
    String fcmToken = await SharedPref.getStringPreference(Constants.fcmToken);
    String serverToken = await MyUtility.getServerToken();

    print("FCM TOKEN ${fcmToken}");
    print("serverToken ${serverToken}");
  }

  Widget _orderWidget({
    required String title,
    required int orderId,
    required double amount,
    required String paidBy,
    required String couponId,
  }) {
    double totalAmount = double.parse(widget.amount.toString());
    return SizedBox(
      height: Sizeconfig.getHeight(context),
      width: Sizeconfig.getWidth(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          10.toSpace,
          Text(
            "${Constants.ruppessymbol} ${totalAmount.toStringAsFixed(2)}",
            style: Appwidgets()
                .commonTextStyle(ColorName.ColorPrimary)
                .copyWith(fontWeight: FontWeight.w700, fontSize: 20),
          ),
          10.toSpace,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: const Divider(height: .5, color: ColorName.napierGreen),
          ),
          20.toSpace,
          _buildOrderDetails(orderId, paidBy, couponId),
          10.toSpace,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 3,
              style: Appwidgets().commonTextStyle(ColorName.black).copyWith(
                  letterSpacing: 0, fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
          10.toSpace
        ],
      ),
    );
  }

  Widget _buildOrderDetails(int orderId, String paidBy, String couponId) {
    return Card(
      elevation: 1,
      color: ColorName.ColorBagroundPrimary,
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            _orderDetail(title: "Order Id", value: "$orderId"),
            const Divider(color: ColorName.whiteSmokeColor),
            _orderDetail(title: "Payment Mode", value: paidBy),
            const Divider(color: ColorName.whiteSmokeColor),
            _orderDetail(title: "Order Date", value: widget.selected_date_slot),
            const Divider(color: ColorName.whiteSmokeColor),
            _orderDetail(title: "Order Slot", value: widget.selected_time_slot),
            const Divider(color: ColorName.whiteSmokeColor),
            _orderDetail(
                title: "Delivery Location", value: widget.delivery_location),
            if (couponId.isNotEmpty && couponId != "Coupon not apply") ...[
              const Divider(color: ColorName.whiteSmokeColor),
              _orderDetail(title: "Coupon ID", value: couponId),
            ],
          ],
        ),
      ),
    );
  }

  Widget _orderDetail({required String title, String? value}) {
    double screenwidth = Sizeconfig.getWidth(context);
    return value != null && value.isNotEmpty
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              10.toSpace,
              Text(
                "$title ",
                style: Appwidgets()
                    .commonTextStyle(ColorName.darkGrey)
                    .copyWith(fontWeight: FontWeight.w500, fontSize: 15),
              ),
              const Spacer(),
              Text(
                ":",
                style: Appwidgets().commonTextStyle(ColorName.black).copyWith(
                      fontWeight: FontWeight.w400,
                    ),
              ),
              10.toSpace,
              Container(
                alignment: Alignment.centerRight,
                width: screenwidth * 0.45,
                child: Text(
                  value,
                  maxLines: title == "Delivery Location" ? 3 : 1,
                  textAlign: TextAlign.end,
                  style: Appwidgets().commonTextStyle(ColorName.black).copyWith(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              10.toSpace,
            ],
          )
        : const SizedBox.shrink();
  }
}
