import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:ondoor/constants/Constant.dart';
import 'package:ondoor/constants/ImageConstants.dart';
import 'package:ondoor/models/cancel_order_response.dart';
import 'package:ondoor/models/locationvalidationmodel.dart';
import 'package:ondoor/models/order_by_order_id_response.dart';
import 'package:ondoor/models/time_slot_response.dart';
import 'package:ondoor/screens/order_history_detail/order_history_detail_bloc/order_history_detail_bloc.dart';
import 'package:ondoor/screens/order_history_detail/order_history_detail_bloc/order_history_detail_event.dart';
import 'package:ondoor/screens/order_history_detail/order_history_detail_bloc/order_history_detail_state.dart';
import 'package:ondoor/services/ApiServices.dart';
import 'package:ondoor/utils/Connection.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/SizeConfig.dart';
import 'package:ondoor/utils/change_delivery_bloc/change_delivery_slot_bloc.dart';
import 'package:ondoor/utils/change_delivery_bloc/change_delivery_slot_event.dart';
import 'package:ondoor/utils/change_delivery_bloc/change_delivery_slot_state.dart';
import 'package:ondoor/utils/colors.dart';
import 'package:ondoor/utils/sharedpref.dart';
import 'package:ondoor/utils/shimmerUi.dart';
import 'package:ondoor/widgets/AppWidgets.dart';
import 'package:ondoor/widgets/MyDialogs.dart';
import 'package:ondoor/widgets/common_loading_widget.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../models/GetTimeSlotsResponse.dart';
import '../../models/order_history_detail_response.dart';
import '../../services/Navigation/routes.dart';
import '../../widgets/select_time_slot_dialog.dart';
import '../AddCard/card_bloc.dart';
import '../FeaturedProduct/FeatuuredBloc/featured_bloc.dart';
import '../shop_by_category/shop_by_category_bloc/shop_by_category_bloc.dart';

class OrderHistoryDetailScreen extends StatefulWidget {
  String order_id;
  String order_type;

  OrderHistoryDetailScreen(
      {super.key, required this.order_id, required this.order_type});

  @override
  State<OrderHistoryDetailScreen> createState() =>
      _OrderHistoryDetailScreenState();
}

class _OrderHistoryDetailScreenState extends State<OrderHistoryDetailScreen> {
  OrderHistoryDetailBloc orderHistoryDetailBloc = OrderHistoryDetailBloc();
  ChangeDeliverySlotBloc changeDeliverySlotBloc = ChangeDeliverySlotBloc();
  bool isLoading = false;
  bool isOrderCancelled = false;
  int currentTabIndex = 0;
  late TabController tabController;
  String orderDate = '';
  String deliveryDate = '';
  String firstName = '';
  String lastName = '';
  String email = '';
  String userMobileNumber = '';
  String deliveryTime = '';
  String errorMessage = '';
  String selectedDateSlot = '';
  String selectedTimeSlot = '';
  String locationId = '';
  CardBloc cardBloc = CardBloc();
  FeaturedBloc featuredBloc = FeaturedBloc();
  ShopByCategoryBloc shopByCategoryBloc = ShopByCategoryBloc();
  TimeSlotResponse getTimeSlotResponse = TimeSlotResponse();
  OrderHistoryDetailData orderHistoryDetailData = OrderHistoryDetailData();
  @override
  void initState() {
    Appwidgets.setStatusBarColor();
    cleanSp();
    super.initState();
  }

  cleanSp() async {
    await SharedPref.setStringPreference(Constants.sp_notificationdata, "");
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key("OrderHistoryDetail"),
      onVisibilityChanged: (visibilityInfo) {
        var visiblePercentage = visibilityInfo.visibleFraction * 100;
        if (visiblePercentage == 100) {
          getAddressData();
        }
      },
      child: BlocBuilder<OrderHistoryDetailBloc, OrderHistoryDetailState>(
        bloc: orderHistoryDetailBloc,
        builder: (context, state) {
          if (state is OrderHistoryDetailInitialState) {
            isLoading = false;
            orderHistoryDetailBloc.getOrderbyOrderId(
                context, widget.order_id, widget.order_type);
            errorMessage = "";
          }
          if (state is OrderHistoryDetailLoadingState) {
            isLoading = true;
            errorMessage = "";
          }
          if (state is ErrorState) {
            isLoading = true;
            errorMessage = state.errorMessage;
          }
          if (state is OrderHistoryDetailTabChangeState) {
            isLoading = false;
            errorMessage = "";
            currentTabIndex = state.tabIndex;
          }
          if (state is OrderHistoryDetailLoadedState) {
            isLoading = false;
            errorMessage = "";
            orderHistoryDetailData = state.orderHistoryData;
          }
          convertDates();
          readUserDetails();
          return MediaQuery(
            data: Appwidgets().mediaqueryDataforWholeApp(context: context),
            child: SafeArea(
              child: WillPopScope(
                onWillPop: () async {
                  Navigator.pop(context, isOrderCancelled);
                  return false;
                },
                child: Scaffold(
                  appBar: AppBar(
                    centerTitle: false,
                    leading: GestureDetector(
                        onTap: () {
                          Navigator.pop(context, isOrderCancelled);
                        },
                        child: Icon(Icons.arrow_back_ios)),
                    titleSpacing: -15,
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          orderHistoryDetailData.orderId == null ||
                                  orderHistoryDetailData.orderId == ''
                              ? ""
                              : "Order ID #${orderHistoryDetailData.orderId ?? ""}",
                          style: Appwidgets()
                              .commonTextStyle(ColorName.ColorBagroundPrimary)
                              .copyWith(
                                  fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          orderDate == "" ? "" : "Order at $orderDate",
                          style: Appwidgets()
                              .commonTextStyle(ColorName.ColorBagroundPrimary)
                              .copyWith(
                                  fontWeight: FontWeight.w400, fontSize: 13),
                        ),
                      ],
                    ),
                    actions: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, Routes.contact_us,
                              arguments: {
                                "userName": "$firstName $lastName",
                                "email": email,
                                "telephone": userMobileNumber
                              });
                        },
                        child: Text(
                          "Help ?",
                          style: Appwidgets()
                              .commonTextStyle(ColorName.ColorBagroundPrimary),
                        ),
                      ),
                      10.toSpace
                    ],
                  ),
                  backgroundColor: ColorName.whiteSmokeColor,
                  body: SingleChildScrollView(
                    child: isLoading
                        ? Container(
                            height: Sizeconfig.getHeight(context),
                            child: CommonLoadingWidget())
                        : errorMessage.isNotEmpty
                            ? Center(
                                child: Text(
                                  errorMessage,
                                  style: Appwidgets()
                                      .commonTextStyle(ColorName.black),
                                ),
                              )
                            : Column(
                                children: [
                                  10.toSpace,
                                  userDetailsWidget(),
                                  10.toSpace,
                                  productListWidget(),
                                  10.toSpace,
                                  paymentDetailsWidget(),
                                  SizedBox(
                                    height: getSpacingForProducts(
                                        context, orderHistoryDetailData),
                                  ),
                                  // orderHistoryDetailData.orderStatusName ==
                                  //         "Pending"
                                  //     ? widgetforDownloadReciept()
                                  //     : SizedBox.shrink(),
                                ],
                              ),
                  ),
                  bottomNavigationBar:
                      orderHistoryDetailData.orderStatusName != "Pending"
                          ? const SizedBox.shrink()
                          : SizedBox(
                              height: 40,
                              width: Sizeconfig.getWidth(context),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  BottomWidgets(
                                    buttonText: "Cancel Order",
                                    onTap: () => MyDialogs.showAlertDialog(
                                        context,
                                        "Are you Sure you want to cancel this Order ?",
                                        "Yes",
                                        "No",
                                        () => cancelOrderApi(),
                                        () => Navigator.pop(context)),
                                  ),
                                  2.toSpace,
                                  BottomWidgets(
                                    buttonText: "Modify Order",
                                    onTap: () {
                                      getOrderByOrderId();
                                    },
                                  ),
                                  2.toSpace,
                                  BottomWidgets(
                                    buttonText: "Change Delivery Slot",
                                    onTap: () {
                                      changeDeliverySlot();
                                    },
                                  ),
                                ],
                              ),
                            ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  changeDeliverySlot() {
    showDialog(
      context: context,
      builder: (context) {
        return BlocBuilder(
          bloc: changeDeliverySlotBloc,
          builder: (context, state) {
            print("Change Delivery Slot State ${state}");
            if (state is ChangeDeliverySlotSelectedDateState) {
              selectedDateSlot = state.selectedDate;
              getTimeSLots(
                  locationId: locationId, selectedDate: selectedDateSlot);
            }
            if (state is ChangeDeliverySlotSelectedTimeState) {
              selectedTimeSlot = state.selectedTimeSlot;
            }
            return Dialog(
              child: Wrap(
                children: [
                  Container(
                    height: 50,
                    color: ColorName.ColorPrimary,
                    child: Center(
                      child: Text(
                        "Change Delivery Slot",
                        style: Appwidgets()
                            .commonTextStyle(ColorName.ColorBagroundPrimary)
                            .copyWith(),
                      ),
                    ),
                  ),
                  5.toSpace,
                  GestureDetector(
                    onTap: () {
                      showDatePicker(
                        context: context,
                        initialEntryMode:
                            DatePickerEntryMode.calendarOnly, // <- this
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 10)),
                        selectableDayPredicate: (DateTime val) => true,
                      ).then(
                        (value) async {
                          if (value != null) {
                            String day = "";
                            String month = "";
                            day = value.day.toString();
                            month = value.month.toString();
                            if (value.day <= 9) {
                              day = "0${value.day}";
                            }
                            if (value.month <= 9) {
                              month = "0${value.month}";
                            }
                            selectedDateSlot = "${value.year}-$month-$day";
                            changeDeliverySlotBloc.add(
                                ChangeDeliverySlotSelectedDateEvent(
                                    selectedDate: selectedDateSlot));
                          }
                        },
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: ColorName.darkGrey)),
                      child: Row(
                        children: [
                          Text(
                            selectedDateSlot == ""
                                ? "Please Select Date"
                                : selectedDateSlot,
                            style: Appwidgets().commonTextStyle(
                                selectedDateSlot == ""
                                    ? ColorName.textlight2
                                    : ColorName.dark),
                          ),
                          Spacer(),
                          Icon(
                            Icons.calendar_month,
                            color: ColorName.black,
                          )
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (getTimeSlotResponse.data != null) {
                        showDialog(
                          barrierColor: Colors.transparent,
                          context: context,
                          builder: (context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: Wrap(
                                children: [
                                  Container(
                                    height: 50,
                                    color: ColorName.ColorPrimary,
                                    child: Center(
                                      child: Text(
                                        "Select Time Slot",
                                        style: Appwidgets()
                                            .commonTextStyle(
                                                ColorName.ColorBagroundPrimary)
                                            .copyWith(),
                                      ),
                                    ),
                                  ),
                                  Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    runAlignment: WrapAlignment.center,
                                    children: getTimeSlotResponse.data!.map(
                                      (timeSlots) {
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                            changeDeliverySlotBloc.add(
                                                ChangeDeliverySlotSelectedTimeEvent(
                                                    selectedTimeSlot:
                                                        timeSlots.timeSlot ??
                                                            ""));
                                          },
                                          child: Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Row(
                                              children: [
                                                Radio(
                                                  value: selectedTimeSlot ==
                                                      timeSlots.timeSlot,
                                                  groupValue: true,
                                                  toggleable: true,
                                                  onChanged: (value) {
                                                    selectedTimeSlot =
                                                        timeSlots.timeSlot ??
                                                            "";
                                                    Navigator.pop(context);
                                                    changeDeliverySlotBloc.add(
                                                        ChangeDeliverySlotSelectedTimeEvent(
                                                            selectedTimeSlot:
                                                                timeSlots
                                                                        .timeSlot ??
                                                                    ""));
                                                  },
                                                ),
                                                Text(
                                                  timeSlots.timeSlot ?? "",
                                                  style: Appwidgets()
                                                      .commonTextStyle(
                                                          ColorName.black),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    },
                    child: Container(
                      width: Sizeconfig.getWidth(context),
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: ColorName.darkGrey)),
                      child: Text(
                        selectedTimeSlot == ""
                            ? "Please Select"
                            : selectedTimeSlot,
                        style: Appwidgets().commonTextStyle(
                            selectedTimeSlot == ""
                                ? ColorName.textlight2
                                : ColorName.dark),
                      ),
                    ),
                  ),
                  5.toSpace,
                  Center(
                    child: Appwidgets.orangeThemeButton(
                      "Submit",
                      () {
                        if (selectedDateSlot != "" && selectedTimeSlot != "") {
                          changeDeliverySlotApi();
                        } else {
                          Appwidgets.showToastMessage(
                              "Please Select required Fields");
                        }
                      },
                    ),
                  ),
                  10.toSpace
                ],
              ),
            );
          },
        );
      },
    );
  }

  changeDeliverySlotApi() async {
    ApiProvider()
        .changeDeliverySlotApi(
            deliveryTimeSlot: selectedTimeSlot,
            deliveryDateSlot: selectedDateSlot,
            orderId: widget.order_id,
            callback: () => changeDeliverySlotApi())
        .then(
      (value) {
        if (value.success == true) {
          // selectedTimeSlot = "";
          // selectedDateSlot = "";
          Navigator.pop(context);
          orderHistoryDetailBloc.add(OrderHistoryDetailInitialEvent());
        } else {
          Appwidgets.showToastMessage(value.message ?? "");
        }
      },
    );
  }

  getAddressData() async {
    locationId = await SharedPref.getStringPreference(Constants.LOCATION_ID);
    orderHistoryDetailBloc.add(OrderHistoryDetailNullEvent());
  }

  getTimeSLots(
      {required String locationId, required String selectedDate}) async {
    getTimeSlotResponse =
        await ApiProvider().getTimeSlots2(locationId, selectedDate, () {
      getTimeSLots(locationId: locationId, selectedDate: selectedDate);
    });
    if (getTimeSlotResponse.success == true) {
      selectedTimeSlot = getTimeSlotResponse.data![0].timeSlot ?? "";
    }
  }

  getOrderByOrderId() async {
    if (await Network.isConnected()) {
      OrderbyOrderIdResponse orderbyOrderIdResponse =
          await ApiProvider().getOrderbyOrderId(
              orderId: widget.order_id,
              callback: () {
                getOrderByOrderId();
              });
      if (orderbyOrderIdResponse.success == true) {
        Appwidgets().showReorderProductsListing(
            context,
            cardBloc,
            widget.order_id,
            orderbyOrderIdResponse.data!.products!,
            featuredBloc,
            shopByCategoryBloc,
            () {

              //featuredBloc=FeaturedBloc();
            },
            Routes.order_history_detail,
            () {});
      }
    } else {
      MyDialogs.showInternetDialog(context, () {
        Navigator.pop(context);
      });
    }
  }

  cancelOrderApi() async {
    EasyLoading.show();
    CancelOrderbyOrderIdResponse cancelOrderbyOrderIdResponse =
        await ApiProvider().cancelOrder(
            mobileNumber: userMobileNumber,
            orderId: widget.order_id,
            callback: () async {
              cancelOrderApi();
            });
    EasyLoading.dismiss();
    Navigator.pop(context);
    isOrderCancelled = cancelOrderbyOrderIdResponse.success ?? false;
    if (cancelOrderbyOrderIdResponse.success == true) {
      MyDialogs.commonDialog(
          context: context,
          actionTap: () {
            Navigator.pop(context);
            orderHistoryDetailBloc.add(OrderHistoryDetailInitialEvent());
          },
          titleText: cancelOrderbyOrderIdResponse.message!,
          actionText: "Okay");
    } else {}
  }

  Widget BottomWidgets(
      {required String buttonText, required Function() onTap}) {
    return Expanded(
        child: GestureDetector(
      onTap: onTap,
      child: Container(
        color: ColorName.ColorPrimary,
        child: Center(
            child: Text(
          buttonText,
          textAlign: TextAlign.center,
          style: Appwidgets()
              .commonTextStyle(ColorName.ColorBagroundPrimary)
              .copyWith(fontSize: 13),
        )),
      ),
    ));
  }

  double getSpacingForProducts(
      BuildContext context, OrderHistoryDetailData orderHistoryDetailData) {
    if (orderHistoryDetailData.products == null) {
      return 10.0;
    }

    int productCount = orderHistoryDetailData.products!.length;

    switch (productCount) {
      case 3:
        return 10.0;
      case 2:
        return 2.0;
      case 1:
        return Sizeconfig.getHeight(context) * 0.10;
      default:
        return 10.0;
    }
  }

  Widget widgetforDownloadReciept() {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: ColorName.ColorBagroundPrimary,
          border: Border.all(color: ColorName.cloudColor, width: 1),
          borderRadius: BorderRadius.circular(10)),
      child: Wrap(
        spacing: 10,
        direction: Axis.horizontal,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Image.asset(
            Imageconstants.download_icon,
            width: 14,
            height: 14,
          ),
          Text(
            "DOWNLOAD RECIEPT",
            style: Appwidgets()
                .commonTextStyle(ColorName.salmonPink)
                .copyWith(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget productListWidget() {
    return Container(
      decoration: BoxDecoration(
          color: ColorName.ColorBagroundPrimary,
          borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Items in order',
                style: Appwidgets()
                    .commonTextStyle(ColorName.firefly)
                    .copyWith(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              Text(
                orderHistoryDetailData.products == null
                    ? ""
                    : '${orderHistoryDetailData.products!.length} Items',
                style: Appwidgets()
                    .commonTextStyle(ColorName.mediumGrey)
                    .copyWith(fontWeight: FontWeight.w400, fontSize: 14),
              ),
            ],
          ),
          const Divider(),
          orderHistoryDetailData.products == null ||
                  orderHistoryDetailData.products!.isEmpty
              ? const SizedBox.shrink()
              : ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) => const Divider(),
                  shrinkWrap: true,
                  itemCount: orderHistoryDetailData.products!.length,
                  itemBuilder: (context, index) {
                    var productData = orderHistoryDetailData.products![index];
                    double mrp_price = double.parse(
                        productData.mrp_price!.replaceAll("Rs ", ''));
                    print(
                        "PRODCUT DATA ${Sizeconfig.getWidth(context) * .168}");
                    var productWeightarr = productData.weight_unit!.split(' ');
                    print("productWeightarr $productWeightarr");

                    return Container(
                      child: Row(
                        children: [
                          // CommonCachedImageWidget(
                          //   imgUrl: productData.image ?? "",
                          //   height: Sizeconfig.getHeight(context) * .08,
                          //   width: Sizeconfig.getWidth(context) * .168,
                          // ),
                          CachedNetworkImage(
                            height: Sizeconfig.getHeight(context) * .08,
                            width: Sizeconfig.getWidth(context) * .168,
                            imageUrl: productData.image ?? "",
                            placeholder: (context, url) =>
                                Shimmerui.shimmerForProductImageWidget(
                              context: context,
                              height: Sizeconfig.getHeight(context) * .08,
                              width: Sizeconfig.getWidth(context) * .168,
                            ),
                            errorWidget: (context, url, error) =>
                                Image.asset(Imageconstants.ondoor_logo),
                          ),

                          10.toSpace,
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productData.name!,
                                  softWrap: true,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: Appwidgets()
                                      .commonTextStyle(ColorName.black)
                                      .copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    productWeightarr.toString() == "[]"
                                        ? Container()
                                        : Text(
                                            "${double.parse(productWeightarr[0]).toStringAsFixed(0)} ${productWeightarr[1]}",
                                            style: Appwidgets()
                                                .commonTextStyle(
                                                    ColorName.black)
                                                .copyWith(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w500),
                                          ),
                                    Spacer(),
                                    productData.price == "Free"
                                        ? const SizedBox.shrink()
                                        : Text(
                                            "${productData.price!.replaceAll("Rs", Constants.ruppessymbol)} x ${productData.quantity}",
                                            style: Appwidgets()
                                                .commonTextStyle(ColorName.grey)
                                                .copyWith(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w500),
                                          ),
                                    10.toSpace,
                                    mrp_price == 0.0
                                        ? SizedBox.shrink()
                                        : Text(
                                            Constants.ruppessymbol +
                                                mrp_price.toStringAsFixed(2),
                                            style: Appwidgets()
                                                .commonTextStyle(ColorName
                                                    .firefly
                                                    .withOpacity(.5))
                                                .copyWith(
                                                    decorationColor: ColorName
                                                        .firefly
                                                        .withOpacity(.4),
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14),
                                          ),
                                    10.toSpace,
                                    Text(
                                      productData.total!.replaceAll(
                                          "Rs", Constants.ruppessymbol),
                                      style: Appwidgets()
                                          .commonTextStyle(ColorName.black)
                                          .copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget paymentDetailsWidget() {
    return Container(
      decoration: BoxDecoration(
          color: ColorName.ColorBagroundPrimary,
          borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Payment Details",
            style: Appwidgets().commonTextStyle(ColorName.black),
          ),
          commonWidgetforDelievryDetails(
              title: "Payment Mode",
              titleValue: orderHistoryDetailData.paymentMethod ?? "",
              context: context),
          commonWidgetforDelievryDetails(
              title: "Subtotal",
              titleValue:
                  "${Constants.ruppessymbol} ${orderHistoryDetailData.totals?[0].subTotal}" ??
                      "",
              context: context),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Discount : ",
                style: Appwidgets()
                    .commonTextStyle(ColorName.artyClickDeepSkyBlue)
                    .copyWith(fontWeight: FontWeight.w500),
              ),
              Text(
                "${Constants.ruppessymbol} ${orderHistoryDetailData.discount}" ??
                    "",
                style: Appwidgets()
                    .commonTextStyle(ColorName.artyClickDeepSkyBlue)
                    .copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          commonWidgetforDelievryDetails(
              title: "Shipping",
              titleValue: orderHistoryDetailData.totals?[0].flatShippingRate ==
                      ""
                  ? "${Constants.ruppessymbol} 0.00"
                  : "${Constants.ruppessymbol} ${orderHistoryDetailData.totals?[0].flatShippingRate}",
              context: context),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total",
                style: Appwidgets().commonTextStyle(ColorName.black),
              ),
              Text(
                "${Constants.ruppessymbol} ${orderHistoryDetailData.totals?[0].total}",
                style: Appwidgets().commonTextStyle(ColorName.black),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget userDetailsWidget() {
    return Container(
      decoration: BoxDecoration(
          color: ColorName.ColorBagroundPrimary,
          borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Container(
            // color: Color(0xFFFEFBEA),
            decoration: BoxDecoration(
                color: Color(0xFFF2F7E0),
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${orderHistoryDetailData.orderStatusName}",
                          style: Appwidgets()
                              .commonTextStyle(ColorName.firefly)
                              .copyWith(
                                  fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                        Row(
                          children: [
                            Text(
                              "Delivered on - ",
                              style: Appwidgets()
                                  .commonTextStyle(ColorName.black)
                                  .copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15),
                            ),
                            Text(
                              "$deliveryDate,",
                              style: Appwidgets()
                                  .commonTextStyle(ColorName.black)
                                  .copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "Slot - ",
                              style: Appwidgets()
                                  .commonTextStyle(ColorName.black)
                                  .copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15),
                            ),
                            Text(
                              orderHistoryDetailData.deliveryTime ?? "",
                              style: Appwidgets()
                                  .commonTextStyle(ColorName.black)
                                  .copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Image.asset(
                  Imageconstants.ondoor_grocery_product_icon,
                  height: 80,
                  width: 80,
                  fit: BoxFit.fill,
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$firstName $lastName",
                        style: Appwidgets()
                            .commonTextStyle(ColorName.black)
                            .copyWith(
                                fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      Text(
                        orderHistoryDetailData.paymentAddress ?? "",
                        style: Appwidgets()
                            .commonTextStyle(ColorName.firefly)
                            .copyWith(
                                fontWeight: FontWeight.w400, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  Imageconstants.location_icon,
                  height: 40,
                  width: 40,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void convertDates() {
    if (orderHistoryDetailData.orderDate != null) {
      DateTime dateTime =
          DateTime.parse(orderHistoryDetailData.orderDate.toString());
      final DateFormat formatter = DateFormat('dd MMM yyyy, hh:mm a');
      String formattedDate = formatter.format(dateTime);
      orderDate = formattedDate;
    }
    if (orderHistoryDetailData.deliveryDate != null &&
        orderHistoryDetailData.deliveryTime != null) {
      String dateTime = orderHistoryDetailData.deliveryDate!.toString();
      deliveryDate = dateTime.split(" ")[0];
      deliveryTime = dateTime.split(" ")[1];
      final DateFormat inputFormat = DateFormat("HH:mm:ss.SSS");
      final DateTime dateTime1 = inputFormat.parse(deliveryTime);
      final DateFormat outputFormat = DateFormat("h:mm");
      final String formattedTime = outputFormat.format(dateTime1);
      deliveryTime = formattedTime;
      var datearr = deliveryDate.split('-');
      deliveryDate = "${datearr[2]}.${datearr[1]}.${datearr[0]}";
    }
  }

  readUserDetails() async {
    firstName = await SharedPref.getStringPreference(Constants.sp_FirstNAME);
    lastName = await SharedPref.getStringPreference(Constants.sp_LastName);
    email = await SharedPref.getStringPreference(Constants.sp_EMAIL);
    userMobileNumber =
        await SharedPref.getStringPreference(Constants.sp_MOBILE_NO);
  }

  Widget commonWidgetforDelievryDetails(
      {required String title,
      required String titleValue,
      required BuildContext context}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$title : ",
          style: Appwidgets()
              .commonTextStyle(ColorName.firefly)
              .copyWith(fontWeight: FontWeight.w500),
        ),
        Text(
          titleValue,
          style: Appwidgets()
              .commonTextStyle(ColorName.black.withOpacity(.8))
              .copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
