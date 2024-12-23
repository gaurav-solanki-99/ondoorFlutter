import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:ondoor/constants/Constant.dart';
import 'package:ondoor/constants/ImageConstants.dart';
import 'package:ondoor/constants/StringConstats.dart';
import 'package:ondoor/models/AllProducts.dart';
import 'package:ondoor/models/get_order_history_response.dart';
import 'package:ondoor/screens/FeaturedProduct/FeatuuredBloc/featured_bloc.dart';
import 'package:ondoor/screens/HomeScreen/HomeBloc/home_page_bloc.dart';
import 'package:ondoor/screens/order_history_screen/order_history_bloc/order_history_bloc.dart';
import 'package:ondoor/screens/order_history_screen/order_history_bloc/order_history_event.dart';
import 'package:ondoor/screens/order_history_screen/order_history_bloc/order_history_state.dart';
import 'package:ondoor/screens/shop_by_category/shop_by_category_bloc/shop_by_category_bloc.dart';
import 'package:ondoor/services/ApiServices.dart';
import 'package:ondoor/utils/Connection.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/SizeConfig.dart';
import 'package:ondoor/utils/colors.dart';
import 'package:ondoor/utils/sharedpref.dart';
import 'package:ondoor/utils/shimmerUi.dart';
import 'package:ondoor/widgets/AppWidgets.dart';
import 'package:ondoor/widgets/MyDialogs.dart';
import 'package:ondoor/widgets/common_cached_image_widget.dart';
import 'package:ondoor/widgets/common_loading_widget.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../database/database_helper.dart';
import '../../services/Navigation/routes.dart';
import '../AddCard/card_bloc.dart';
import '../HomeScreen/HomeBloc/home_page_event.dart';
import '../HomeScreen/HomeBloc/home_page_state.dart';
import '../NewAnimation/animation_bloc.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  OrderHistoryBloc orderHistoryBloc = OrderHistoryBloc();
  OrderHistoryData orderHistoryDataForRating = OrderHistoryData();
  HomePageBloc homePageBloc2 = HomePageBloc();
  List<OrderHistoryData> orderHistoryList = [];
  bool bottomviewstatus = false;
  bool isOpenBottomview = false;
  bool isLoading = false;
  String selectedDurationName = "Last 6 months";
  String selectedarchiveId = "0";
  String error_Message = "0";
  String userName = "";
  String email = "";
  String userMobileNumber = "";
  final dbHelper = DatabaseHelper();
  CardBloc cardBloc = CardBloc();
  var animationsizebottom = 0.0;
  AnimationBloc animationBloc = AnimationBloc();
  @override
  void initState() {
    Appwidgets.setStatusBarColor();
    initializedDb();
    // orderHistoryBloc.getData(context);
    getUserDetails();
    super.initState();
  }

  void getUserDetails() async {
    String firstName =
        await SharedPref.getStringPreference(Constants.sp_FirstNAME);
    String lastName =
        await SharedPref.getStringPreference(Constants.sp_LastName);
    email = await SharedPref.getStringPreference(Constants.sp_EMAIL);
    userMobileNumber =
        await SharedPref.getStringPreference(Constants.sp_MOBILE_NO);
    userName = "$firstName $lastName";
  }

  initializedDb() async {
    await dbHelper.init();
    dbHelper.loadAddCardProducts(cardBloc);

    // if (selectedTimeSlot == "" || selectedDateSlot == "") {
    //   debugPrint("*****Gaurav***************");
    //   getCocoApi(latitude, longitude, city, userstate);
    // }

    debugPrint("Cardbloc State ${cardBloc.state}");
    Appwidgets.setStatusBarDynamicLightColor(color: Colors.transparent);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: ColorName.ColorPrimary,
      ),
      child: MediaQuery(
        data: Appwidgets().mediaqueryDataforWholeApp(context: context),
        child: SafeArea(
          child: VisibilityDetector(
            key: Key("order_history_screen"),
            onVisibilityChanged: (info) {
              var visibilityInfo = info.visibleFraction * 100;
              if (visibilityInfo == 100) {
                print("ORDERHISTORY RESPONSE GGGG");
                orderHistoryBloc.getOrderHistory(context, selectedarchiveId);
              }
            },
            child: Scaffold(
                backgroundColor: ColorName.whiteSmokeColor,
                appBar: Appwidgets.MyAppBar(
                  context,
                  "Order History",
                  () {},
                ),
                body: Container(
                  height: Sizeconfig.getHeight(context),
                  child: Stack(
                    children: [
                      BlocBuilder(
                        bloc: orderHistoryBloc,
                        builder: (context, state) {
                          if (state is OrderHistoryInitialState) {
                            // orderHistoryBloc.getOrderHistory(
                            //     context, selectedarchiveId);
                          }
                          if (state is OrderHistoryLoadedState) {
                            isLoading = false;
                            orderHistoryList = state.orderHistoryList;
                          }
                          if (state is RateUsTappedState) {
                            isLoading = false;
                            orderHistoryDataForRating = state.orderHistoryData;
                          }
                          if (state is OrderHistoryLoadingState) {
                            isLoading = true;
                          }
                          if (state is OrderHistoryErrorState) {
                            isLoading = false;
                            error_Message = state.errorString;
                            orderHistoryList = [];
                          }
                          if (state is DurationChangeState) {
                            isLoading = false;
                            selectedDurationName = state.selectedDurationName;
                            selectedarchiveId = state.selectedarchiveId;
                            if (selectedDurationName ==
                                StringContants.lbl_last_six_months) {
                              selectedarchiveId = "0";
                              orderHistoryBloc.getOrderHistory(
                                  context, selectedarchiveId);
                            }
                            if (selectedDurationName ==
                                StringContants.lbl_check_history) {
                              selectedarchiveId = "1";
                              orderHistoryBloc.getOrderHistory(
                                  context, selectedarchiveId);
                            }
                          }
                          return Column(
                            children: [
                              Container(
                                height: 50,
                                color: ColorName.lightGey,
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      selectedDurationName ==
                                              StringContants.lbl_check_history
                                          ? StringContants.lbl_last_six_months
                                          : StringContants.lbl_check_history,
                                      style: Appwidgets()
                                          .commonTextStyle(ColorName.black)
                                          .copyWith(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        print(
                                            "selectedDurationNameselectedDurationName ${selectedDurationName}");
                                        if (selectedDurationName ==
                                            StringContants
                                                .lbl_last_six_months) {
                                          orderHistoryBloc.add(
                                              DurationChangeEvent(
                                                  selectedDurationName:
                                                      StringContants
                                                          .lbl_check_history,
                                                  selectedarchiveId:
                                                      selectedarchiveId));
                                        } else {
                                          orderHistoryBloc.add(
                                              DurationChangeEvent(
                                                  selectedDurationName:
                                                      StringContants
                                                          .lbl_last_six_months,
                                                  selectedarchiveId:
                                                      selectedarchiveId));
                                        }
                                      },
                                      child: Text(
                                        selectedDurationName ==
                                                StringContants.lbl_check_history
                                            ? "History"
                                            : StringContants
                                                .lbl_last_six_months,
                                        style: Appwidgets()
                                            .commonTextStyle(
                                                ColorName.ColorPrimary)
                                            .copyWith(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              isLoading
                                  ? Container(
                                      height:
                                          Sizeconfig.getHeight(context) * .8,
                                      child:
                                          Shimmerui.orderHistoryListUi(context),
                                    )
                                  : Container(
                                      height:
                                          Sizeconfig.getHeight(context) * .8,
                                      child: orderHistoryList.isEmpty &&
                                              error_Message.isNotEmpty && state== OrderHistoryLoadedState
                                          ? emptyListWidget()
                                          : orderHistoryListWidget()),
                            ],
                          );
                        },
                      ),
                      BlocProvider(
                          create: (context) => homePageBloc2,
                          child: BlocBuilder(
                            bloc: homePageBloc2,
                            builder: (BuildContext context, state) {
                              if (state is HomeBottomSheetState) {
                                bottomviewstatus = state.status;

                                debugPrint(
                                    "HomeBottomSheetState ${state.status}");
                              }

                              return bottomviewstatus
                                  ? Container(
                                      height: Sizeconfig.getHeight(context),
                                      color: Colors.black12.withOpacity(0.2),
                                    )
                                  : SizedBox.shrink();
                            },
                          )),
                      Container(
                          alignment: Alignment.bottomCenter,
                          child: Appwidgets.ShowBottomView33(
                              true,
                              context,
                              cardBloc,
                              FeaturedBloc(),
                              ShopByCategoryBloc(),
                              animationBloc,
                              animationsizebottom,
                              0,
                              "",
                              true,
                              dbHelper,
                              () async {
                                debugPrint(
                                    "OrderSummary Screen back >>>>>1 ${animationsizebottom}");

                                Appwidgets.setStatusBarDynamicLightColor(
                                    color: Colors.transparent);

                                // SystemChrome.setSystemUIOverlayStyle(
                                //     SystemUiOverlayStyle(
                                //   statusBarColor: Colors
                                //       .transparent, // transparent status bar
                                //   statusBarIconBrightness: Brightness
                                //       .light, // dark icons on the status bar
                                // ));

                                await dbHelper
                                    .queryAllRowsCardProducts()
                                    .then((value) {
                                  debugPrint(
                                      "OrderSummary Screen back >>>>>1 ${value}");

                                  if (value.length == 0) {
                                    //gotoHomepage();
                                  }
                                });
                              },
                              () {
                                debugPrint("OrderSummary Screen back >>>>>2");
                                // gotoHomepage();
                              },
                              () {
                                debugPrint("OrderSummary Screen back >>>>>3");
                              },
                              false,
                              (value) {
                                debugPrint("HomePage Screen back >>>>>");
                                isOpenBottomview = value;
                                homePageBloc2.add(HomeNullEvent());
                                homePageBloc2
                                    .add(HomeBottomSheetEvent(status: value));
                              },
                              (height) {
                                debugPrint("GGheight >> $height");
                                animationsizebottom = 70.0;
                              })),
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }

  Widget orderHistoryListWidget() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: orderHistoryList.length,
      itemBuilder: (context, index) {
        var orderHistoryData = orderHistoryList[index];
        DateTime dateTime = DateTime.parse(orderHistoryData.orderDate!);
        String formattedDate =
            DateFormat('dd MMMM yyyy, hh:mm a').format(dateTime);
        bool isFirstOccurrence = orderHistoryList.indexWhere(
              (element) => element.orderId == orderHistoryData.orderId,
            ) ==
            index;
        orderHistoryList.forEach(
          (element) {
            if (element.orderId == orderHistoryData.orderId) {
              element.imageArray.add(orderHistoryData.image ?? "");
              element.imageArray = element.imageArray.toSet().toList();
              orderHistoryBloc.add(OrderHistoryImageArrayEvent(
                  orderHistoryList: orderHistoryList));
            }
          },
        );
        return isFirstOccurrence
            ? Stack(
                children: [
                  // orderHistoryDataForRating == orderHistoryData
                  //     ? Container(
                  //         height: Sizeconfig.getHeight(context) * .35,
                  //         margin: EdgeInsets.all(10),
                  //         decoration: BoxDecoration(
                  //             color: ColorName.ColorBagroundPrimary,
                  //             borderRadius: BorderRadius.circular(10)),
                  //         child: Column(
                  //           crossAxisAlignment: CrossAxisAlignment.center,
                  //           children: [
                  //             Spacer(),
                  //             RatingBar(
                  //               initialRating: 2.4,
                  //               direction: Axis.horizontal,
                  //               isHalfAllowed: true,
                  //               halfFilledIcon: Icons.star_half,
                  //               alignment: Alignment.center,
                  //               emptyColor: ColorName.yellow,
                  //               filledColor: ColorName.yellow,
                  //               filledIcon: Icons.star,
                  //               emptyIcon: Icons.star_border,
                  //               onRatingChanged: (p0) {},
                  //             ),
                  //             10.toSpace,
                  //             Appwidgets.ButtonSecondary(
                  //               "Submit",
                  //               () {
                  //                 orderHistoryDataForRating =
                  //                     OrderHistoryData();
                  //                 orderHistoryBloc.add(RateUsTappedEvent(
                  //                     orderHistoryData: orderHistoryData));
                  //               },
                  //             ),
                  //             10.toSpace
                  //           ],
                  //         ),
                  //       )
                  //     : const SizedBox.shrink(),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    color: ColorName.ColorBagroundPrimary,
                    margin: EdgeInsets.only(right: 10, top: 10, left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                          child: InkWell(
                            overlayColor: WidgetStateProperty.all(
                                ColorName.ColorBagroundPrimary),
                            onTap: () async {
                              var updateme = await Navigator.pushNamed(
                                  context, Routes.order_history_detail,
                                  arguments: {
                                    "order_id": orderHistoryData.orderId!,
                                    "order_type": orderHistoryData.type!,
                                  });
                              print("ORDER HISTORY PRINT ${updateme}");
                              if (updateme != null && updateme == true) {
                                orderHistoryBloc
                                    .add(OrderHistoryInitialEvent());
                              }
                            },
                            child: Container(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    fit: BoxFit.fill,
                                    getimagePath(
                                        statusName:
                                            orderHistoryData.orderStatusName!),
                                    width: 30,
                                    height: 30,
                                  ),
                                  10.toSpace,
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        orderHistoryData.orderStatusName!,
                                        style: Appwidgets()
                                            .commonTextStyle(ColorName.mirage)
                                            .copyWith(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        formattedDate.toUpperCase(),
                                        style: Appwidgets()
                                            .commonTextStyle(
                                                ColorName.mist_blue)
                                            .copyWith(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  // Expanded(
                                  //   child:
                                  // ),
                                  // Icon(
                                  //   Icons.arrow_forward,
                                  //   color: ColorName.mediumGrey,
                                  // )
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Divider(),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 60,
                                width: getWidthofTheBox(
                                    orderHistoryData.imageArray.length,
                                    context),
                                child: DynamicOverlappingImages(
                                    imageUrls: orderHistoryData.imageArray),
                              ),
                              5.toSpace,
                              orderHistoryData.imageArray.length <= 4
                                  ? SizedBox()
                                  : SizedBox(
                                      height: 30,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "+ ${orderHistoryData.imageArray.length - 4} More",
                                          style: Appwidgets()
                                              .commonTextStyle(
                                                  ColorName.lightGey)
                                              .copyWith(
                                                fontSize: 14,
                                              ),
                                        ),
                                      ),
                                    ),
                              Spacer(),
                              Text(
                                Constants.ruppessymbol +
                                    double.parse(orderHistoryData.totals!)
                                        .toStringAsFixed(2),
                                style: Appwidgets()
                                    .commonTextStyle(ColorName.mirage)
                                    .copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                        10.toSpace,
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                          child: Row(
                            children: [
                              Appwidgets.CommonButtonWidget(
                                  childWidget: Center(
                                    child: Text(
                                      "Detail",
                                      style: Appwidgets()
                                          .commonTextStyle(
                                              ColorName.ColorPrimary)
                                          .copyWith(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10)),
                                  onpress: () {
                                    var updateme = Navigator.pushNamed(
                                        context, Routes.order_history_detail,
                                        arguments: {
                                          "order_id": orderHistoryData.orderId!,
                                          "order_type": orderHistoryData.type!,
                                        });
                                    if (updateme == true) {
                                      orderHistoryBloc
                                          .add(OrderHistoryInitialEvent());
                                    }
                                    // if (orderHistoryDataForRating !=
                                    //     orderHistoryData) {
                                    //   orderHistoryDataForRating =
                                    //       orderHistoryData;
                                    // } else {
                                    //   orderHistoryDataForRating =
                                    //       OrderHistoryData();
                                    // }
                                    // orderHistoryBloc.add(RateUsTappedEvent(
                                    //     orderHistoryData:
                                    //         orderHistoryDataForRating));
                                  },
                                  buttonText: "Product Detail",
                                  borderColor: ColorName.ColorPrimary,
                                  buttonColor: ColorName.ColorBagroundPrimary),
                              16.toSpace,
                              orderHistoryData.reOrder.toString() == "0"
                                  ? Container()
                                  : Appwidgets.CommonButtonWidget(
                                      childWidget: Center(
                                        child: Text(
                                          "REORDER",
                                          style: Appwidgets()
                                              .commonTextStyle(ColorName
                                                  .ColorBagroundPrimary)
                                              .copyWith(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      // textColor: ColorName.ColorBagroundPrimary,
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(10)),
                                      onpress: () async {
                                        if (await Network.isConnected()) {
                                          reOrderAPi(orderHistoryData.orderId!);
                                        } else {
                                          MyDialogs.showInternetDialog(context,
                                              () {
                                            Navigator.pop(context);
                                            reOrderAPi(
                                                orderHistoryData.orderId!);
                                          });
                                        }
                                      },
                                      buttonText: "REORDER",
                                      borderColor: ColorName.ColorPrimary,
                                      buttonColor: ColorName.ColorPrimary),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              )
            : SizedBox.shrink();
      },
    );
  }

  double getWidthofTheBox(int length, BuildContext context) {
    double width = length >= 5
        ? Sizeconfig.getWidth(context) * .35
        : length == 4
            ? Sizeconfig.getWidth(context) * .335
            : length == 3
                ? Sizeconfig.getWidth(context) * .28
                : length == 2
                    ? Sizeconfig.getWidth(context) * .195
                    : Sizeconfig.getWidth(context) * .14;
    return width;
  }

  String getimagePath({required String statusName}) {
    return statusName == "Delivered" || statusName == "Shipped"
        ? Imageconstants.green_tick
        : statusName == "Pending"
            ? Imageconstants.pending
            : Imageconstants.cancel;
  }

  void reOrderAPi(String orderId) async {
    ProductsModel reorderResponse =
        await ApiProvider().reOrderAPI(orderId, () async {
      reOrderAPi(orderId);
    });
    if (reorderResponse.success == true) {
      log("reOrderAPiGG ${reorderResponse.toJson()}");

      List<ProductUnit> unitlist = [];
      for (var x in reorderResponse.data!) {
        unitlist.add(x.unit![0]);
      }

      Appwidgets().showReorderProductsListing(
          context,
          CardBloc(),
          orderId,
          unitlist,
          FeaturedBloc(),
          ShopByCategoryBloc(),
          () {},
          Routes.order_history, () async {
        await dbHelper.loadAddCardProducts(cardBloc);
      });
    } else {}
  }

  Widget emptyListWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Appwidgets.Text_20(error_Message, ColorName.black),
        20.toSpace,
        Appwidgets.ButtonSecondary(
          StringContants.lbl_check_history,
          () {
            if (selectedarchiveId == "1") {
              selectedarchiveId = "0";
              orderHistoryBloc.add(DurationChangeEvent(
                  selectedDurationName: StringContants.lbl_last_six_months,
                  selectedarchiveId: selectedarchiveId));
            } else {
              selectedarchiveId = "1";
              orderHistoryBloc.add(DurationChangeEvent(
                  selectedDurationName: StringContants.lbl_last_six_months,
                  selectedarchiveId: selectedarchiveId));
            }
          },
        )
      ],
    );
  }
}

class DynamicOverlappingImages extends StatelessWidget {
  final List<String> imageUrls;

  DynamicOverlappingImages({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Sizeconfig.getHeight(context) * .067,
      color: Colors.transparent,
      child: Stack(
        children: imageUrls.asMap().entries.map((entry) {
          int index = entry.key;
          String url = entry.value;
          return index >= 4
              ? const SizedBox.shrink()
              : Positioned(
                  left: index * Sizeconfig.getWidth(context) * .07,
                  child: CachedNetworkImage(
                    imageUrl: url,
                    width: Sizeconfig.getWidth(context) * .14,
                    height: Sizeconfig.getHeight(context) * .067,
                    filterQuality: FilterQuality.high,
                    errorWidget: (context, url, error) =>
                        Image.asset(Imageconstants.ondoor_logo),
                    placeholder: (context, url) =>
                        Shimmerui.shimmerForProductImageWidget(
                            context: context, height: 50, width: 50),
                  ),
                );
        }).toList(),
      ),
    );
  }
}
