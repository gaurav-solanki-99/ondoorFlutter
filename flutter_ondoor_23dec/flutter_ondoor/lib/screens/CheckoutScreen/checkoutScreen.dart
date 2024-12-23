import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ondoor/constants/Constant.dart';
import 'package:ondoor/models/GetTimeSlotsResponse.dart';
import 'package:ondoor/models/ShippingCharges.dart';
import 'package:ondoor/models/get_coco_code_response.dart';
import 'package:ondoor/screens/AuthScreen/Register/RegisterdBloc/registerd_bloc.dart';
import 'package:ondoor/screens/CheckoutScreen/CheckoutBloc/checkout_bloc.dart';
import 'package:ondoor/screens/CheckoutScreen/CheckoutBloc/checkout_event.dart';
import 'package:ondoor/screens/CheckoutScreen/CheckoutBloc/checkout_state.dart';
import 'package:ondoor/services/ApiServices.dart';
import 'package:ondoor/services/Navigation/routes.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/SizeConfig.dart';
import 'package:ondoor/utils/sharedpref.dart';
import 'package:ondoor/widgets/login_widget_dialog/login_widget_dialog.dart';
import 'package:ondoor/widgets/select_time_slot_dialog.dart';
import 'package:proste_bezier_curve/proste_bezier_curve.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../constants/FontConstants.dart';
import '../../constants/ImageConstants.dart';
import '../../constants/StringConstats.dart';
import '../../database/database_helper.dart';
import '../../database/dbconstants.dart';
import '../../models/AllProducts.dart';
import '../../models/TopProducts.dart';
import '../../models/address_list_response.dart';
import '../../models/locationvalidationmodel.dart';
import '../../utils/Connection.dart';
import '../../utils/Utility.dart';
import '../../utils/colors.dart';
import '../../utils/shimmerUi.dart';
import '../../utils/themeData.dart';
import '../../utils/validator.dart';
import '../../widgets/AppWidgets.dart';
import '../../widgets/CheckoutWidgets.dart';
import '../../widgets/HomeWidgetConst.dart';
import '../../widgets/MyDialogs.dart';
import '../AddCard/card_bloc.dart';
import '../AddCard/card_event.dart';
import '../AddCard/card_state.dart';
import '../AuthScreen/Register/RegisterdBloc/registerd_event.dart';
import '../AuthScreen/Register/RegisterdBloc/registerd_state.dart';
import '../FeaturedProduct/FeatuuredBloc/featured_bloc.dart';
import '../shop_by_category/shop_by_category_bloc/shop_by_category_bloc.dart';

class Checkoutscreen extends StatefulWidget {
  List<ProductUnit> freeProducts = [];
  List<ProductUnit> c_offerlist = [];
  Checkoutscreen(
      {super.key, required this.freeProducts, required this.c_offerlist});

  @override
  State<Checkoutscreen> createState() => _CheckoutscreenState();
}

class _CheckoutscreenState extends State<Checkoutscreen> {
  List<TopProducts> listTopProducts = [
    TopProducts(
        imageUrl: Imageconstants.img_featured,
        name: StringContants.lbl_featuredprod,
        quantitiy: 0),
    TopProducts(
        imageUrl: Imageconstants.img_heavydiscount,
        name: StringContants.lbl_heavydis,
        quantitiy: 0),
    TopProducts(
        imageUrl: Imageconstants.img_newarrivals,
        name: StringContants.lbl_newarr,
        quantitiy: 0),
    // TopProducts(imageUrl: Imageconstants.img_offers, name: StringContants.lbl_offrs),
  ];

  List<ProductUnit> list_cOffers = [];
  List<ProductUnit> cartitesmList = [];
  List<ProductUnit> freeProducts = [];
  List<PaymentGetway> paymentGetway = [];
  bool loadProductValidation = false;
  GetTimeSlotResponse getTimeSlotResponse = GetTimeSlotResponse();
  final dbHelper = DatabaseHelper();
  CardBloc cardBloc = CardBloc();
  CheckoutBloc checkoutBloc = CheckoutBloc();
  double subtotal = 0;
  int cartListLength = 3;
  ShippingCharge? shippingChargeResp;
  double subtotalcross = 0;
  double grandtotal = 0;
  double remaingAmountonFreeDelivery = 0;
  double freeDeliveryAmount = 0;
  double savingamount = 0;
  double shippingCharge = 0;
  bool isShowShipping = false;
  bool loadshippingAmount = false;
  // String street = "";
  // String locality = "";
  String token = "";
  // String city = "";
  // String userstate = "";
  // String selectedTimeSlot = "";
  String access_token = "";
  // String selectedDateSlot = "";
  // double latitude = 0.0;
  // double longitude = 0.0;
  bool _isDialogShowing = false;
  AnimationController? animationController;
  // AddressData selectedAddressData = AddressData();
  // GetCocoCodeByLatLngResponse? cocoCodeByLatLngResponse;
  @override
  void initState() {
    debugPrint("Checkout screen Free products ${widget.freeProducts}");

    // if(widget.freeProducts.length!=0)
    //   {
    //     for (var x in widget.freeProducts) {
    //       if (x.addQuantity != 0) {
    //
    //         cartitesmList.add(x);
    //       }
    //     }
    //   }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Appwidgets.setStatusBarColor();
      getSavedAddress();
      initializedDb();
      // retrieveAddressList();
    });

    super.initState();
  }

  checkAdressupdate() async {
    bool status =
        await SharedPref.getBooleanPreference(Constants.locationupdate);
    if (status) {
      loadAddress();
    }
  }

  initializedDb() async {
    await dbHelper.init();
    dbHelper.loadAddCardProducts(cardBloc);
    readUserLogin();
    debugPrint("sp_AccessTOEKN ${access_token}");
    // if (selectedTimeSlot == "" || selectedDateSlot == "") {
    //   debugPrint("*****Gaurav***************");
    //   getCocoApi(latitude, longitude, city, userstate);
    // }
  }

  readUserLogin() async {
    String tokenType =
        await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
    access_token =
        await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);
    token = "$tokenType $access_token";
  }

  getSavedAddress() async {
    debugPrint("getsavedAddress");
    String latitudeStr =
        await SharedPref.getStringPreference(Constants.SELECTED_LOCATION_LAT);
    String longitudeStr =
        await SharedPref.getStringPreference(Constants.SELECTED_LOCATION_LONG);
    // street = await SharedPref.getStringPreference(Constants.SAVED_ADDRESS);
    // city = await SharedPref.getStringPreference(Constants.SAVED_CITY);
    // userstate = await SharedPref.getStringPreference(Constants.SAVED_STATE);
    // selectedAddressData.addressId =
    //     await SharedPref.getStringPreference(Constants.ADDRESS_ID);
    // selectedAddressData.locationId =
    //     await SharedPref.getStringPreference(Constants.LOCATION_ID);
    // selectedAddressData.wmsStoreId =
    //     await SharedPref.getStringPreference(Constants.WMS_STORE_ID);
    // selectedAddressData.storeCode =
    //     await SharedPref.getStringPreference(Constants.STORE_CODE);
    // selectedAddressData.storeName =
    //     await SharedPref.getStringPreference(Constants.STORE_Name);
    // selectedAddressData.storeId =
    //     await SharedPref.getStringPreference(Constants.STORE_ID);
    if (latitudeStr != "" && longitudeStr != "") {
      print("LATITUDE >>>>  ${latitudeStr}");
      print("LONGITUDE >>>> ${longitudeStr}");
      // latitude = double.parse(latitudeStr);
      // longitude = double.parse(longitudeStr);
    }
    // locality = "$city $userstate";
    // selectedAddressData.latitude = latitudeStr;
    // selectedAddressData.longitude = longitudeStr;
    // selectedAddressData.city = city;
    // selectedAddressData.zone = userstate;
    // selectedAddressData.areaDetail = street;
    // checkoutBloc.add(GetAddressEvent(street: street, locality: locality));
    checkAdressupdate();
    // getCocoApi(latitude, longitude, city, userstate);
  }

  updateCard(ProductUnit model, int index, var list) async {
    int status = await dbHelper.updateCard({
      DBConstants.PRODUCT_ID: int.parse(model.productId!),
      DBConstants.QUANTITY: model.addQuantity,
      DBConstants.PRICE: model.price,
      DBConstants.SORT_PRICE: model.sortPrice,
      DBConstants.SPECIAL_PRICE: model.specialPrice,
    });

    debugPrint("Update Product Status " + status.toString());

    Navigator.of(context).pushReplacementNamed(Routes.home_page);
  }

  loadLocationValidation(
    String store_id1,
    String store_name1,
    String wms_store_id1,
    String location_id1,
    String store_code1,
  ) {
    ApiProvider().locationproductValidation(cartitesmList, store_id1,
        store_name1, wms_store_id1, location_id1, store_code1, () {
      loadLocationValidation(
          store_id1, store_name1, wms_store_id1, location_id1, store_code1);
    }).then((value) {
      // debugPrint(
      //     "ONADDRESSCHANGE locationproductValidation ${selectedAddressData.toJson()}");

      if (value != "") {
        LocationProductsModel locationProduucts =
            LocationProductsModel.fromJson(value.toString());
        debugPrint("ONADDRESSCHANGE locationproductValidation 2 ${value}");
        if (locationProduucts.success == false) {
          debugPrint("ONADDRESSCHANGE result ${locationProduucts.toJson()}");

          MyDialogs.showLocationProductsDialog(context, locationProduucts,
              (updatelist) async {
            for (int i = 0; i < cartitesmList.length; i++) {
              debugPrint("i******   ${cartitesmList[i].name}");
              for (int j = 0; j < updatelist.length; j++) {
                debugPrint("j******   ${updatelist[j].name}");

                if (updatelist[j].outOfStock == "0" &&
                    updatelist[j].productId == cartitesmList[i].productId) {
                  debugPrint("GCondition 1");
                  cartitesmList[i].addQuantity =
                      int.parse(updatelist[j].qty ?? "0");
                  cartitesmList[i].price = updatelist[j].price;
                  cartitesmList[i].sortPrice = updatelist[j].newPrice;
                  cartitesmList[i].specialPrice = updatelist[j].newPrice;
                  //  cartitesmList[i].specialPrice=updatelist[j];

                  debugPrint(
                      "Updatecart Items call ${cartitesmList[i].toJson()}");

                  updateCard(cartitesmList[i], i, cartitesmList);
                } else if ((updatelist[j].outOfStock == "1" &&
                    updatelist[j].productId == cartitesmList[i].productId)) {
                  debugPrint("GCondition 2");
                  await dbHelper
                      .deleteCard(int.parse(cartitesmList[i].productId!))
                      .then((value) {
                    routestoHomeOrLocation();
                  });
                }
              }
            }
          }, () async {
            await dbHelper.cleanCartDatabase().then((value) {
              dbHelper.loadAddCardProducts(cardBloc);

              routestoHomeOrLocation();
            });
          });
        }
      }
    });
  }

  routestoHomeOrLocation() async {
    // // street = await SharedPref.getStringPreference(Constants.ADDRESS);
    // // locality = await SharedPref.getStringPreference(Constants.LOCALITY);
    // // if (isAddressEmpty()) {
    //   Navigator.pushNamed(context, Routes.location_screen,
    //       arguments: Routes.checkoutscreen);
    // } else {
    Navigator.of(context).pushReplacementNamed(Routes.home_page);
    // }
  }

  loadAddress() {
    print("Product validation");
    getShippingCharges("1");
  }

  void getShippingCharges(String number) {
    print("Number ${number}");
    if (subtotal != 0) {
      ApiProvider().getShippingCharges(subtotal, 0, () {
        getShippingCharges(number);
      }).then((value) async {
        if (value != null) {
          shippingChargeResp = value;
          debugPrint("Shipping Charges $subtotal " + value.data.toString());

          if (value.data.toString() == "null") {
            shippingCharge = double.parse("0");
          } else {
            shippingCharge = double.parse(value.data! ?? "0");
          }

          if (value.data.toString() != "null" &&
              double.parse(value.data!) == 0) {
            isShowShipping = false;
            debugPrint("Shipping Charges Not Available ");
          } else {
            isShowShipping = true;
            debugPrint("Shipping Charges " + value.data.toString());
            debugPrint("Shipping Charges GrandTotal" + grandtotal.toString());

            freeDeliveryAmount = double.parse(value.offer!.freeDeliveryAmount!);
          }
          paymentGetway = value.paymentGetway!;
          debugPrint("Shipping Charges GrandTotal" + grandtotal.toString());
          checkoutBloc.add(CheckoutNullEvent());

          checkoutBloc.add(CheckoutShipingAmountEvent(
              isShow: isShowShipping,
              shippingCharges: shippingCharge,
              freeDeliveryAmount: freeDeliveryAmount));
        }
      });
    }
    // checkoutBloc.add(GetAddressEvent(street: street, locality: locality));
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: Appwidgets().mediaqueryDataforWholeApp(context: context),
      child: SafeArea(
        child: VisibilityDetector(
          key: const Key('CheckoutScreen'),
          onVisibilityChanged: (visibilityInfo) {
            // Appwidgets.setStatusBarColor();
            var visiblePercentage = visibilityInfo.visibleFraction * 100;
            print("visiblePercentage ${visiblePercentage}");
            print("visibleFraction ${visibilityInfo.visibleFraction}");
            if (visiblePercentage == 100) {
              readUserLogin();
              getSavedAddress();
              getShippingCharges("2");
              // checkAdressupdate();
            }
          },
          child: WillPopScope(
            onWillPop: () async {
              EasyLoading.dismiss();
              Navigator.pop(context);
              return false;
            },
            child: Scaffold(
                backgroundColor: ColorName.whiteSmokeColor,
                appBar: Appwidgets.MyAppBarWithHome(
                  context,
                  StringContants.lbl_final_Order,
                ),
                body: SingleChildScrollView(
                  child: Container(
                      color: ColorName.aquaHazeColor,
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: BlocBuilder(
                        bloc: checkoutBloc,
                        builder: (context, state) {
                          // print("checkout State ${state}  ${shippingChargeResp}");
                          if (state is CheckoutShippingLoadState) {
                            loadshippingAmount = true;
                          }
                          if (state is CheckoutPriceUpdateState) {
                            // debugPrint("CheckoutPriceUpdateState " +
                            //     state.subtotoal.toString());
                            // debugPrint("CheckoutPriceUpdateState " +
                            //     state.subtotoalcross.toString());

                            subtotal = state.subtotoal;
                            subtotalcross = state.subtotoalcross;
                            if (subtotalcross > subtotal) {
                              savingamount = subtotalcross - subtotal;
                            }

                            // debugPrint("CheckoutPriceUpdateState savingamount" +
                            //     savingamount.toString());
                            // debugPrint("CheckoutPriceUpdateState subtotalcross" +
                            //     subtotalcross.toString());
                            // debugPrint("CheckoutPriceUpdateState subtotal" +
                            //     subtotal.toString());

                            checkoutBloc.add(CheckoutShippingLoadEvent());
                            //ROHITT
                            // ApiProvider()
                            //     .getShippingCharges(subtotal, 0)
                            //     .then((value) async {
                            //   if (value != null) {
                            //     paymentGetway = value.paymentGetway!;
                            //     debugPrint("Shipping Charges $subtotal " +
                            //         value.data.toString());
                            //
                            //     if (value.data.toString() == "null") {
                            //       shippingCharge = double.parse("0");
                            //     } else {
                            //       shippingCharge =
                            //           double.parse(value.data! ?? "0");
                            //     }
                            //
                            //     if (value.data.toString() !=
                            //         "null") if (double.parse(
                            //             value.data!) ==
                            //         0) {
                            //       isShowShipping = false;
                            //       debugPrint(
                            //           "Shipping Charges Not Available ");
                            //     } else {
                            //       isShowShipping = true;
                            //       debugPrint("Shipping Charges " +
                            //           value.data.toString());
                            //       debugPrint("Shipping Charges GrandTotal" +
                            //           grandtotal.toString());
                            //
                            //       freeDeliveryAmount = double.parse(
                            //           value.offer!.freeDeliveryAmount!);
                            //     }
                            //     checkoutBloc.add(CheckoutNullEvent());
                            //
                            //     checkoutBloc.add(CheckoutShipingAmountEvent(
                            //         isShow: isShowShipping,
                            //         shippingCharges: shippingCharge,
                            //         freeDeliveryAmount:
                            //             freeDeliveryAmount));
                            //   }
                            // });
                            // print("apiCalled  ${apiCalled}");
                            if (shippingChargeResp == null) {
                              getShippingCharges("3");
                            }
                          }
                          if (state is CheckoutShipingAmountState) {
                            isShowShipping = state.isShow;
                            shippingCharge = state.shippingCharges;
                            grandtotal = subtotal + shippingCharge;

                            double remaingOnfreeDelivery =
                                state.freeDeliveryAmount - subtotal;
                            remaingAmountonFreeDelivery = remaingOnfreeDelivery;
                          }
                          if (state is CheckoutInitial) {
                            // getSavedAddress();
                          }
                          if (state is GetTimeSlotState) {
                            getTimeSlotResponse = state.timeSlotResponse;
                          }
                          if (state is CheckoutSeeAllState) {
                            cartListLength = state.cartListLength;
                          }
                          if (state is CheckoutPriceUpdateState) {
                            subtotal = state.subtotoal;
                            subtotalcross = state.subtotoalcross;
                            grandtotal = subtotal + shippingCharge;
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              10.toSpace,
                              Checkoutwidgets.SavingCardView(
                                  context,
                                  "Your total saving",
                                  isShowShipping
                                      ? "Shop For ${Constants.ruppessymbol} ${remaingAmountonFreeDelivery.toStringAsFixed(2)} more to get FREE delivery"
                                      : "Yah! you got Free Delivery",
                                  "${Constants.ruppessymbol} ${savingamount.toStringAsFixed(2)}"),
                              BlocProvider(
                                create: (context) => cardBloc,
                                child: BlocBuilder(
                                    bloc: cardBloc,
                                    builder: (context, state) {
                                      if (cartitesmList.isNotEmpty) {
                                        if (state is CardValidationLoadState) {
                                          loadProductValidation =
                                              state.validationload;
                                        }
                                      }
                                      if (state is AddCardProductState) {
                                        cartitesmList = state.listProduct;

                                        if (widget.freeProducts.length != 0) {
                                          for (var x in widget.freeProducts) {
                                            if (x.addQuantity != 0 &&
                                                !cartitesmList.contains(x)) {
                                              cartitesmList.add(x);
                                            }
                                          }
                                        }

                                        if (widget.c_offerlist.length != 0) {
                                          for (var x in widget.c_offerlist) {
                                            if (x.addQuantity != 0 &&
                                                !cartitesmList.contains(x)) {
                                              cartitesmList.add(x);
                                            }
                                          }
                                        }

                                        if (loadProductValidation) {
                                          list_cOffers.clear();
                                          freeProducts.clear();
                                          widget.c_offerlist.clear();
                                          widget.freeProducts.clear();

                                          print(
                                              "***cartitesmList api ${cartitesmList.length}");
                                          print(
                                              "***cartitesmList api ${widget.c_offerlist.length}");
                                          print(
                                              "***cartitesmList api ${widget.freeProducts.length}");
                                          print(
                                              "***cartitesmList api ${widget.c_offerlist.length}");

                                          print(
                                              "***cartitesmList api ** ${cartitesmList.length}");

                                          productvalidationApi();
                                          loadProductValidation = false;
                                          cardBloc.add(CardValidationLoadEvent(
                                              validationload:
                                                  loadProductValidation));
                                        }
                                      }
                                      Appwidgets.setStatusBarColor();
                                      return Container(
                                        margin: EdgeInsets.only(top: 10),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Appwidgets.lables(
                                                StringContants
                                                    .lbl_product_sumary,
                                                10,
                                                5),
                                            Checkoutwidgets
                                                .productDetailsListFinal(
                                                    context,
                                                    cartitesmList,
                                                    freeProducts,
                                                    list_cOffers,
                                                    cardBloc,
                                                    dbHelper,
                                                    checkoutBloc,
                                                    cartitesmList.length < 3
                                                        ? cartitesmList.length
                                                        : cartListLength),
                                          ],
                                        ),
                                      );
                                    }),
                              ),
                              5.toSpace,
                              cartitesmList.length <= 3 || cartListLength != 3
                                  ? SizedBox.shrink()
                                  : Align(
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                        onTap: () {
                                          print(
                                              "CART ITEM LIST LENGTH ${cartitesmList.length}");
                                          cartListLength = cartitesmList.length;
                                          checkoutBloc.add(CheckoutSeeAllEvent(
                                              cartListLength: cartListLength));
                                        },
                                        child: Text(
                                          "See All",
                                          style: Appwidgets()
                                              .commonTextStyle(
                                                  ColorName.ColorPrimary)
                                              .copyWith(
                                                fontWeight: Fontconstants
                                                    .SF_Pro_Display_Bold,
                                                fontSize: 15,
                                              ),
                                        ),
                                      ),
                                    ),
                              // 10.toSpace,
                              // Card(
                              //   color: Colors.white,
                              //   child: Column(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     children: [
                              //       Appwidgets.lables(
                              //           StringContants.lbl_before_your, 10, 10),
                              //       const SizedBox(
                              //         height: 0,
                              //       ),
                              //       Homewidgetconst().topSellingList(
                              //           context, listTopProducts, () {}, () {}),
                              //     ],
                              //   ),
                              // ),
                              /*   10.toSpace,
                        Container(
                          width: Sizeconfig.getWidth(context),
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                              color: ColorName.ColorBagroundPrimary,
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    height: 30,
                                    width: 30,
                                    child:
                                        Image.asset(Imageconstants.img_coupons),
                                  ),
                                  Appwidgets.lables(
                                      StringContants.lbl_view_all_coupons,
                                      10,
                                      10),
                                ],
                              ),
                              const SizedBox(
                                height: 0,
                              ),
                            ],
                          ),
                        ),*/
                              5.toSpace,
                              Container(
                                width: Sizeconfig.getWidth(context),
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                decoration: BoxDecoration(
                                    color: ColorName.ColorBagroundPrimary,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Appwidgets.lables(
                                        StringContants.lbl_bill_details, 0, 0),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              height: 15,
                                              width: 15,
                                              child: Image.asset(
                                                  Imageconstants.img_sub_total),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              StringContants.lbl_sub_totol,
                                              style: TextStyle(
                                                  fontSize:
                                                      Constants.SizeButton,
                                                  fontFamily: Fontconstants
                                                      .fc_family_sf,
                                                  fontWeight: Fontconstants
                                                      .SF_Pro_Display_Medium,
                                                  color: Colors.black),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            subtotal == 0.0
                                                ? SizedBox.shrink()
                                                : "${subtotal.toStringAsFixed(2)}" ==
                                                            "${subtotalcross.toStringAsFixed(2)}" ||
                                                        (subtotalcross <
                                                            subtotal)
                                                    ? Container()
                                                    : Text(
                                                        Constants.ruppessymbol +
                                                            "${subtotalcross.toStringAsFixed(2)}",
                                                        style: TextStyle(
                                                            fontSize: Constants
                                                                .SizeSmall,
                                                            fontFamily:
                                                                Fontconstants
                                                                    .fc_family_sf,
                                                            fontWeight:
                                                                Fontconstants
                                                                    .SF_Pro_Display_Bold,
                                                            letterSpacing: 0,
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                            decorationColor:
                                                                ColorName
                                                                    .textlight,
                                                            color: ColorName
                                                                .textlight),
                                                      ),
                                            10.toSpace,
                                            Text(
                                              subtotal == 0.0
                                                  ? Constants.ruppessymbol +
                                                      "${subtotalcross.toStringAsFixed(2)}"
                                                  : Constants.ruppessymbol +
                                                      "${subtotal.toStringAsFixed(2)}",
                                              style: TextStyle(
                                                  fontSize:
                                                      Constants.SizeButton,
                                                  fontFamily: Fontconstants
                                                      .fc_family_sf,
                                                  fontWeight: Fontconstants
                                                      .SF_Pro_Display_Bold,
                                                  letterSpacing: 0,
                                                  color: ColorName.black),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              height: 15,
                                              width: 15,
                                              child: Image.asset(
                                                  Imageconstants.img_delivery),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              StringContants
                                                  .lbl_delivery_charges,
                                              style: TextStyle(
                                                  fontSize:
                                                      Constants.SizeButton,
                                                  fontFamily: Fontconstants
                                                      .fc_family_sf,
                                                  fontWeight: Fontconstants
                                                      .SF_Pro_Display_Medium,
                                                  color: Colors.black),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            /*   Text(
                                              Constants.ruppessymbol + "519",
                                              style: TextStyle(
                                                  fontSize: Constants.SizeSmall,
                                                  fontFamily:
                                                      Fontconstants.fc_family_sf,
                                                  fontWeight: Fontconstants
                                                      .SF_Pro_Display_Bold,
                                                  letterSpacing: 0,
                                                  decoration:
                                                      TextDecoration.lineThrough,
                                                  decorationColor:
                                                      ColorName.textlight,
                                                  color: ColorName.textlight),
                                            ),*/
                                            // 10.toSpace,
                                            isShowShipping == false
                                                ? Row(
                                                    children: [
                                                      Text(
                                                        "${Constants.ruppessymbol}${shippingCharge.toStringAsFixed(2)}",
                                                        style: Appwidgets()
                                                            .commonTextStyle(
                                                                ColorName
                                                                    .textlight)
                                                            .copyWith(
                                                                fontSize: Constants
                                                                    .SizeSmall,
                                                                fontFamily: Fontconstants
                                                                    .fc_family_sf,
                                                                fontWeight:
                                                                    Fontconstants
                                                                        .SF_Pro_Display_Bold,
                                                                letterSpacing:
                                                                    0,
                                                                decoration:
                                                                    TextDecoration
                                                                        .lineThrough,
                                                                decorationColor:
                                                                    ColorName
                                                                        .textlight,
                                                                color: ColorName
                                                                    .textlight),
                                                      ),
                                                      5.toSpace,
                                                      Text(
                                                        StringContants.lbl_free,
                                                        style: TextStyle(
                                                            fontSize: Constants
                                                                .SizeButton,
                                                            fontFamily:
                                                                Fontconstants
                                                                    .fc_family_sf,
                                                            fontWeight:
                                                                Fontconstants
                                                                    .SF_Pro_Display_Bold,
                                                            letterSpacing: 0,
                                                            color:
                                                                ColorName.blue),
                                                      ),
                                                    ],
                                                  )
                                                : Appwidgets.TextLagre(
                                                    "${Constants.ruppessymbol} ${shippingCharge.toStringAsFixed(2)}",
                                                    Colors.black),
                                          ],
                                        )
                                      ],
                                    ),
                                    // SizedBox(
                                    //   height: 8,
                                    // ),
                                    // Row(
                                    //   mainAxisAlignment:
                                    //       MainAxisAlignment.spaceBetween,
                                    //   children: [
                                    //     Row(
                                    //       children: [
                                    //         SizedBox(
                                    //           height: 12,
                                    //           width: 12,
                                    //           child: Image.asset(
                                    //               Imageconstants.img_handling),
                                    //         ),
                                    //         SizedBox(
                                    //           width: 5,
                                    //         ),
                                    //         Text(
                                    //           StringContants
                                    //               .lbl_handling_charges,
                                    //           style: TextStyle(
                                    //               fontSize:
                                    //                   Constants.SizeButton,
                                    //               fontFamily: Fontconstants
                                    //                   .fc_family_sf,
                                    //               fontWeight: Fontconstants
                                    //                   .SF_Pro_Display_Medium,
                                    //               color: Colors.black),
                                    //         )
                                    //       ],
                                    //     ),
                                    //     Text("${Constants.ruppessymbol}0.00",
                                    //         style: TextStyle(
                                    //             fontSize: Constants.SizeButton,
                                    //             fontFamily:
                                    //                 Fontconstants.fc_family_sf,
                                    //             fontWeight: Fontconstants
                                    //                 .SF_Pro_Display_Bold,
                                    //             color: Colors.black)),
                                    //   ],
                                    // ),
                                    4.toSpace,
                                    Divider(
                                      height: .5,
                                    ),
                                    4.toSpace,
                                    Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Appwidgets.TextLagre(
                                              StringContants.lbl_grand_total,
                                              Colors.black),
                                          Appwidgets.TextLagre(
                                              "${Constants.ruppessymbol} ${grandtotal.toStringAsFixed(2)}",
                                              Colors.black),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              /*    BlocBuilder(
                              bloc: checkoutBloc,
                              builder: (context, state) {
                                debugPrint(
                                    "ROHITT CHECKOUT Bill Details State ${state}");
                                if (state is CheckoutPriceUpdateState) {
                                  debugPrint("CheckoutPriceUpdateState " +
                                      state.subtotoal.toString());
                                  debugPrint("CheckoutPriceUpdateState " +
                                      state.subtotoalcross.toString());

                                  subtotal = state.subtotoal;
                                  subtotalcross = state.subtotoalcross;
                                  grandtotal = subtotal + shippingCharge;
                                }

                                return ;
                              }),*/
                              10.toSpace,
                              /*    Container(
                          width: Sizeconfig.getWidth(context),
                          padding:
                              EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          decoration: BoxDecoration(
                              color: ColorName.ColorBagroundPrimary,
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Appwidgets.lables(
                                  StringContants.lbl_tip_your_delivery, 0, 0),
                              Appwidgets.TextRegular(
                                  StringContants.lbl_dumy2, Colors.black),
                              10.toSpace,
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    border: Border.all(
                                        color: ColorName.lightGey, width: 0.5)),
                                padding: EdgeInsets.all(5),
                                child: Wrap(
                                  alignment: WrapAlignment.start,
                                  direction: Axis.horizontal,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(top: 1),
                                      child: SizedBox(
                                        height: 15,
                                        width: 15,
                                        child:
                                            Image.asset(Imageconstants.img_emoji),
                                      ),
                                    ),
                                    10.toSpace,
                                    Appwidgets.TextMediumBold(
                                        "${Constants.ruppessymbol}10",
                                        Colors.black)
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        10.toSpace,*/
                            ],
                          );
                        },
                      )),
                ),
                bottomNavigationBar: BlocBuilder(
                    bloc: checkoutBloc,
                    builder: (context, state) {
                      Appwidgets.setStatusBarColor();

                      readUserLogin();

                      if (state is CheckoutShippingLoadEvent) {
                        loadshippingAmount = true;
                      }
                      // else
                      // {
                      //   loadshippingAmount=false;
                      // }
                      if (state is CheckoutPriceUpdateState) {
                        subtotal = state.subtotoal;
                        subtotalcross = state.subtotoalcross;
                        if (subtotalcross > subtotal) {
                          savingamount = subtotalcross - subtotal;
                        }
                        grandtotal = subtotal + shippingCharge;
                      }

                      if (state is CheckoutShipingAmountState) {
                        isShowShipping = state.isShow;
                        shippingCharge = state.shippingCharges;
                        grandtotal = subtotal + shippingCharge;
                      }
                      return Container(
                        padding: EdgeInsets.only(bottom: 10),
                        color: Colors.transparent,
                        child: true
                            ? Container(
                                padding: EdgeInsets.only(left: 10, right: 10),
                                height: 55,
                                child: Row(
                                  children: [
                                    // Container(
                                    //  //   flex:3,
                                    //     child: Container(
                                    //       padding: EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                                    //   decoration: BoxDecoration(
                                    //       borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                    //       color: ColorName.ColorPrimary),
                                    //
                                    //       child: Column(
                                    //         crossAxisAlignment: CrossAxisAlignment.start,
                                    //
                                    //
                                    //         children: [
                                    //
                                    //
                                    //           Container(
                                    //             width: Sizeconfig.getWidth(context)*0.3,
                                    //             child: Row(
                                    //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //               children: [
                                    //
                                    //                 Image.asset(Imageconstants.img_gpay,height: 20,width: 25,),
                                    //                 Icon(Icons.arrow_drop_up_sharp),
                                    //               ],
                                    //             ),
                                    //           ),
                                    //
                                    //
                                    //           Text(StringContants.lbl_google_pay_upi, style: TextStyle(
                                    //             fontSize: Constants.Sizelagre,
                                    //             fontFamily: Fontconstants.fc_family_sf,
                                    //             fontWeight: Fontconstants.SF_Pro_Display_Regular,
                                    //
                                    //           ),),
                                    //         ],
                                    //       ),
                                    //
                                    //
                                    // )),
                                    // SizedBox(width: 10,),
                                    Expanded(
                                        flex: 1,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0)),
                                              color: ColorName.ColorPrimary),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 0),
                                          child:
                                              state is CheckoutShippingLoadEvent &&
                                                      loadProductValidation
                                                  ? Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              StringContants
                                                                  .lbl_total_pay,
                                                              style: TextStyle(
                                                                fontSize: Constants
                                                                    .Sizelagre,
                                                                fontFamily:
                                                                    Fontconstants
                                                                        .fc_family_sf,
                                                                fontWeight:
                                                                    Fontconstants
                                                                        .SF_Pro_Display_Regular,
                                                              ),
                                                            ),
                                                            Text(
                                                              "${Constants.ruppessymbol} ${grandtotal.toStringAsFixed(2)}",
                                                              style: TextStyle(
                                                                fontSize: Constants
                                                                    .SizeMidium,
                                                                fontFamily:
                                                                    Fontconstants
                                                                        .fc_family_sf,
                                                                fontWeight:
                                                                    Fontconstants
                                                                        .SF_Pro_Display_Bold,
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        10.toSpace,
                                                        InkWell(
                                                          onTap: () async {
                                                            // bool
                                                            //     isTimeSlotEmpty =
                                                            //     selectedTimeSlot
                                                            //             .isEmpty ||
                                                            //         selectedDateSlot
                                                            //             .isEmpty;
                                                            access_token =
                                                                await SharedPref
                                                                    .getStringPreference(
                                                                        Constants
                                                                            .sp_AccessTOEKN);
                                                            if (access_token
                                                                .isEmpty) {
                                                              debugPrint(
                                                                  "sp_AccessTOEKN asdha ${access_token}");
                                                              // if (isAddressEmpty()) {
                                                              //   await SharedPref
                                                              //       .setStringPreference(
                                                              //           Constants
                                                              //               .sp_VerifyRoute,
                                                              //           Routes
                                                              //               .change_address);
                                                              // } else {
                                                              //   // await SharedPref
                                                              //   //     .setStringPreference(
                                                              //   //         Constants
                                                              //   //             .SELECTED_DATE_SLOT,
                                                              //   //         selectedDateSlot);
                                                              //   // await SharedPref
                                                              //   //     .setStringPreference(
                                                              //   //         Constants
                                                              //   //             .SELECTED_TIME_SLOT,
                                                              //   //         selectedTimeSlot);
                                                              //   // await SharedPref
                                                              //   //     .setStringPreference(
                                                              //   //         Constants
                                                              //   //             .sp_VerifyRoute,
                                                              //   //         Routes
                                                              //   //             .payment_option);
                                                              // }
                                                              await SharedPref
                                                                  .setStringPreference(
                                                                      Constants
                                                                          .sp_VerifyRoute,
                                                                      Routes
                                                                          .checkoutscreen);
                                                              Navigator.pushNamed(
                                                                      context,
                                                                      Routes
                                                                          .register_screen,
                                                                      arguments:
                                                                          Routes
                                                                              .checkoutscreen)
                                                                  .then(
                                                                      (value) {
                                                                // Appwidgets
                                                                //     .setStatusBarColor();
                                                              });
                                                            }
                                                            /*else if (isAddressEmpty()) {
                                                            // String customer_id =
                                                            //     await SharedPref
                                                            //         .getStringPreference(
                                                            //             Constants
                                                            //                 .sp_CustomerId);
                                                            // String token_type =
                                                            //     await SharedPref
                                                            //         .getStringPreference(
                                                            //             Constants
                                                            //                 .sp_TOKENTYPE);
                                                            //
                                                            // token =
                                                            //     "$token_type $access_token";
                                                            // if (token == ' ' &&
                                                            //     customer_id ==
                                                            //         '') {
                                                            //   await SharedPref
                                                            //       .setStringPreference(
                                                            //           Constants
                                                            //               .sp_VerifyRoute,
                                                            //           Routes
                                                            //               .change_address);
                                                            //   Navigator.pushReplacementNamed(
                                                            //           context,
                                                            //           Routes
                                                            //               .register_screen,
                                                            //           arguments:
                                                            //               Routes
                                                            //                   .checkoutscreen)
                                                            //       .then(
                                                            //     (value) {},
                                                            //   );
                                                            // } else {
                                                            //
                                                            // }
                                                            var data = await Navigator
                                                                .pushNamed(
                                                                    context,
                                                                    Routes
                                                                        .change_address,
                                                                    arguments:
                                                                        Routes
                                                                            .checkoutscreen);
                                                            print(
                                                                "ROHITTTT ${data}");
                                                            if (data != null) {
                                                              selectedAddressData =
                                                                  data
                                                                      as AddressData;
                                                              getCocoApi(
                                                                  double.parse(
                                                                      selectedAddressData
                                                                          .latitude!),
                                                                  double.parse(
                                                                      selectedAddressData
                                                                          .longitude!),
                                                                  selectedAddressData
                                                                      .city!,
                                                                  selectedAddressData
                                                                      .zone!);
                                                              var address = selectedAddressData
                                                                  .areaDetail!
                                                                  .replaceAll(
                                                                      "${selectedAddressData.city!}, ",
                                                                      "");
                                                              address = address
                                                                  .replaceAll(
                                                                      selectedAddressData
                                                                          .zone!,
                                                                      "");
                                                              address = address
                                                                  .replaceAll(
                                                                      "${selectedAddressData.postcode!}, ",
                                                                      "");
                                                              address = address
                                                                  .replaceAll(
                                                                      selectedAddressData
                                                                          .country!,
                                                                      "");
                                                              street =
                                                                  address;
                                                              locality =
                                                                  "${selectedAddressData.city!}, ${selectedAddressData.zone!}";
                                                              SharedPref.setStringPreference(
                                                                  Constants
                                                                      .SAVED_ADDRESS,
                                                                  address);
                                                              SharedPref.setStringPreference(
                                                                  Constants
                                                                      .SELECTED_LOCATION_LAT,
                                                                  selectedAddressData
                                                                      .latitude!);
                                                              SharedPref.setStringPreference(
                                                                  Constants
                                                                      .SELECTED_LOCATION_LONG,
                                                                  selectedAddressData
                                                                      .longitude!);
                                                              SharedPref.setStringPreference(
                                                                  Constants
                                                                      .ADDRESS_ID,
                                                                  selectedAddressData
                                                                      .addressId!);
                                                              SharedPref.setStringPreference(
                                                                  Constants
                                                                      .SAVED_CITY,
                                                                  selectedAddressData
                                                                          .city ??
                                                                      "");
                                                              SharedPref.setStringPreference(
                                                                  Constants
                                                                      .SAVED_STATE,
                                                                  selectedAddressData
                                                                          .zone ??
                                                                      "");
                                                              //ROHITT
                                                              print(
                                                                  "place order button");

                                                              getShippingCharges();
                                                              // ApiProvider()
                                                              //     .getShippingCharges(
                                                              //         subtotal,
                                                              //         0)
                                                              //     .then(
                                                              //         (value) async {
                                                              //   if (value !=
                                                              //       null) {
                                                              //     paymentGetway =
                                                              //         value
                                                              //             .paymentGetway!;
                                                              //     debugPrint("Shipping Charges $subtotal " +
                                                              //         value
                                                              //             .data
                                                              //             .toString());
                                                              //
                                                              //     if (value
                                                              //             .data
                                                              //             .toString() ==
                                                              //         "null") {
                                                              //       shippingCharge =
                                                              //           double.parse(
                                                              //               "0");
                                                              //     } else {
                                                              //       shippingCharge =
                                                              //           double.parse(value.data! ??
                                                              //               "0");
                                                              //     }
                                                              //
                                                              //     if (value
                                                              //             .data
                                                              //             .toString() !=
                                                              //         "null") if (double.parse(
                                                              //             value.data!) ==
                                                              //         0) {
                                                              //       isShowShipping =
                                                              //           false;
                                                              //       debugPrint(
                                                              //           "Shipping Charges Not Available ");
                                                              //     } else {
                                                              //       isShowShipping =
                                                              //           true;
                                                              //       debugPrint("Shipping Charges " +
                                                              //           value
                                                              //               .data
                                                              //               .toString());
                                                              //       debugPrint(
                                                              //           "Shipping Charges GrandTotal" +
                                                              //               grandtotal.toString());
                                                              //
                                                              //       freeDeliveryAmount = double.parse(value
                                                              //           .offer!
                                                              //           .freeDeliveryAmount!);
                                                              //     }
                                                              //     checkoutBloc
                                                              //         .add(
                                                              //             CheckoutNullEvent());
                                                              //
                                                              //     checkoutBloc.add(CheckoutShipingAmountEvent(
                                                              //         isShow:
                                                              //             isShowShipping,
                                                              //         shippingCharges:
                                                              //             shippingCharge,
                                                              //         freeDeliveryAmount:
                                                              //             freeDeliveryAmount));
                                                              //   }
                                                              // });
                                                              //
                                                              // checkoutBloc.add(
                                                              //     GetAddressEvent(
                                                              //         street:
                                                              //             street,
                                                              //         locality:
                                                              //             locality));
                                                            }
                                                          } else if (isTimeSlotEmpty) {
                                                            debugPrint(
                                                                "*****Gaurav***************");
                                                            getCocoApi(
                                                                latitude,
                                                                longitude,
                                                                city,
                                                                userstate);
                                                          } */
                                                            else {
                                                              /*
                                                            if (selectedTimeSlot == "Please Select") {
                                                              print(
                                                                  "SELECTED TIME SLOT ${selectedTimeSlot}");
                                                              Appwidgets
                                                                  .showToastMessage(
                                                                      "Please Select the Time Slot");
                                                            }
              */
                                                              // await SharedPref
                                                              //     .setStringPreference(
                                                              //         Constants
                                                              //             .SELECTED_DATE_SLOT,
                                                              //         selectedDateSlot);
                                                              // await SharedPref
                                                              //     .setStringPreference(
                                                              //         Constants
                                                              //             .SELECTED_TIME_SLOT,
                                                              //         selectedTimeSlot);
                                                              checkoutBloc
                                                                  .close();
                                                              Navigator.pushReplacementNamed(
                                                                  context,
                                                                  Routes
                                                                      .payment_option,
                                                                  arguments: {
                                                                    "cart_item_list":
                                                                        cartitesmList,
                                                                    "shipping_charge":
                                                                        shippingCharge,
                                                                    "saving_amount":
                                                                        savingamount,
                                                                    "sub_total":
                                                                        subtotal,
                                                                    "grand_total":
                                                                        grandtotal,
                                                                    "payment_gateways":
                                                                        paymentGetway
                                                                  }).then(
                                                                (value) {
                                                                  checkoutBloc
                                                                      .close();
                                                                  Appwidgets
                                                                      .setStatusBarColor();
                                                                },
                                                              );
                                                            }
                                                          },
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                token
                                                                        .trim()
                                                                        .isEmpty
                                                                    ? "Login"
                                                                    : "${StringContants.lbl_place_order} ",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      Constants
                                                                          .Sizelagre,
                                                                  fontFamily:
                                                                      Fontconstants
                                                                          .fc_family_sf,
                                                                  fontWeight:
                                                                      Fontconstants
                                                                          .SF_Pro_Display_SEMIBOLD,
                                                                ),
                                                              ),
                                                              10.toSpace,
                                                              token
                                                                      .trim()
                                                                      .isEmpty
                                                                  ? Icon(
                                                                      Icons
                                                                          .arrow_forward_ios,
                                                                      size: 12,
                                                                    )
                                                                  : Image.asset(
                                                                      Imageconstants
                                                                          .img_arrowright,
                                                                      height:
                                                                          10,
                                                                      width: 10,
                                                                    )
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                        )),
                                  ],
                                ),
                              )
                            : Appwidgets.MyButton(
                                StringContants.lbl_add_your_address,
                                Sizeconfig.getWidth(context),
                                () {}),
                      );
                    })),
          ),
        ),
      ),
    );
  }

  productvalidationApi() {
    ApiProvider()
        .productValidation(cartitesmList, context, () {})
        .then((value) {
      if (value != "") {
        if (value.toString().contains("sub_products")) {
          final responseData = jsonDecode(value.toString());

          List<dynamic> jsonDataList = responseData["final_products"];

          for (var finalproduct in jsonDataList) {
            if (finalproduct["sub_product"]
                .toString()
                .contains("sub_products")) {
              List<dynamic> subproducts =
                  finalproduct["sub_product"]["sub_products"];

              debugPrint("Final Products Found 1 ${subproducts}");

              for (var unitproduct in subproducts) {
                var c_offer_info = unitproduct['c_offer_info'];
                var add_item = unitproduct['add_item'];
                var quantity = unitproduct['quantity'];
                var total = unitproduct['total'];
                var orp = unitproduct['orp'];

                ProductUnit unit =
                    ProductUnit.fromJson(jsonEncode(unitproduct));

                SubProduct sub = SubProduct();
                sub.cOfferInfo = c_offer_info;
                unit.subProduct = sub;
                unit.addQuantity = int.parse(add_item.toString() ?? "0");
                unit.quantity = quantity.toString();
                unit.specialPrice = total;
                unit.price = total;

                log("coffersProducts11" + unit.toJson());
                list_cOffers.add(unit);
                debugPrint("Final Products Found ${list_cOffers.length}");
                // cardBloc.add(
                //     CardAddcOfferProdutsEvent(
                //         unit: unit));
                // list_cOffers.add(unit);
                debugPrint("Dialog close here ${list_cOffers.length}");
                cardBloc.add(AddCardProductEvent(listProduct: cartitesmList));
              }
            }
          }
        }

        if (value.toString().contains("offer_alert")) {
          final responseData = jsonDecode(value.toString());
          String offerAlert = responseData["offer_alert"].toString();
          if (offerAlert == "true") {
            if (value.toString().contains("message")) {
              String offerMessage = responseData["message"].toString();
              debugPrint(" offerMessage >>${offerMessage}");
              MyDialogs.showProductOffersDialog(context, offerMessage, () {
                Navigator.pop(context);
              });
            }
          }
        } else if (value.toString().contains("free_bies")) {
          List<ProductUnit> list_product_offer = [];
          final responseData = jsonDecode(value.toString());

          List<dynamic> jsonDataList =
              responseData["offer"]["free_bies"]["products"];

          debugPrint("offer json productlist >>${jsonEncode(jsonDataList)}");

          for (var jsonmodel in jsonDataList) {
            ProductUnit unit = ProductUnit.fromJson(jsonEncode(jsonmodel));
            list_product_offer.add(unit);
          }
          debugPrint("offer productlist >>${list_product_offer.length}");

          Appwidgets.showToastMessage("Free Product Available ");
          var subtitile = responseData["offer"]["free_bies"]["total_items_msg"];
          loadProductValidation = false;
          cardBloc.add(
              CardValidationLoadEvent(validationload: loadProductValidation));

          Appwidgets.showFreeProductDialog(subtitile, context, cardBloc,
              list_product_offer, FeaturedBloc(), ShopByCategoryBloc(), () {
            debugPrint("Dialog close here ${list_cOffers.length}");
            cardBloc.add(AddCardProductEvent(listProduct: cartitesmList));
          }, () {
            // dbHelper.loadAddCardProducts(cardBloc);
          }, (value) {
            debugPrint("MyFreeProducts " + value.length.toString());
            bool isQuanitiyAdded = false;

            for (var x in value) {
              if (x.addQuantity != 0 && !cartitesmList.contains(x)) {
                isQuanitiyAdded = true;
                cartitesmList.add(x);
              }
            }

            if (isQuanitiyAdded) {
              freeProducts = value;
              cardBloc.add(AddCardProductEvent(listProduct: cartitesmList));
              Navigator.pop(context);
            } else {
              debugPrint("MyFreeProducts ${isQuanitiyAdded}");

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  title: Text(
                    "Are you sure you don't want to add free products ?",
                    style: Appwidgets().commonTextStyle(ColorName.black),
                  ),
                  actions: [
                    GestureDetector(
                        onTap: () async {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Text("Yes",
                            style: Appwidgets()
                                .commonTextStyle(ColorName.ColorPrimary))),
                    const SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text("No",
                          style: Appwidgets()
                              .commonTextStyle(ColorName.ColorPrimary)),
                    ),
                  ],
                ),
              );
            }
          });
        } else {
          // Navigator.pushNamed(context,
          //     Routes.checkoutscreen)
          //     .then((value) {
          //   callback();
          //   dbhelper
          //       .loadAddCardProducts(cardBloc);
          //
          //   if (isup == false) {
          //     Navigator.pop(context);
          //   }
          // });
        }
      }
    });
  }

  // updateAddress() {
  //   // getCocoApi(
  //   //     double.parse(selectedAddressData.latitude!),
  //   //     double.parse(selectedAddressData.longitude!),
  //   //     selectedAddressData.city!,
  //   //     selectedAddressData.zone!);
  //   // var address = selectedAddressData.areaDetail!
  //   //     .replaceAll("${selectedAddressData.city!}, ", "");
  //   // address = address.replaceAll(selectedAddressData.zone!, "");
  //   // address = address.replaceAll("${selectedAddressData.postcode!}, ", "");
  //   // address = address.replaceAll(selectedAddressData.country!, "");
  //   // street = address;
  //   // locality = "${selectedAddressData.city!}, ${selectedAddressData.zone!}";
  //   // SharedPref.setStringPreference(Constants.SAVED_ADDRESS, address);
  //   // SharedPref.setStringPreference(
  //   //     Constants.SELECTED_LOCATION_LAT, selectedAddressData.latitude!);
  //   // SharedPref.setStringPreference(
  //   //     Constants.SELECTED_LOCATION_LONG, selectedAddressData.longitude!);
  //   // SharedPref.setStringPreference(
  //   //     Constants.ADDRESS_ID, selectedAddressData.addressId!);
  //   // SharedPref.setStringPreference(
  //   //     Constants.SAVED_CITY, selectedAddressData.city ?? "");
  //   // SharedPref.setStringPreference(
  //   //     Constants.SAVED_STATE, selectedAddressData.zone ?? "");
  //   //ROHITT
  //   // ApiProvider().getShippingCharges(subtotal, 0).then((value) async {
  //   //   if (value != null) {
  //   //     debugPrint("Shipping Charges $subtotal " + value.data.toString());
  //   //
  //   //     if (value.data.toString() == "null") {
  //   //       shippingCharge = double.parse("0");
  //   //     } else {
  //   //       shippingCharge = double.parse(value.data! ?? "0");
  //   //     }
  //   //
  //   //     if (value.data.toString() != "null") if (double.parse(value.data!) ==
  //   //         0) {
  //   //       isShowShipping = false;
  //   //       debugPrint("Shipping Charges Not Available ");
  //   //     } else {
  //   //       isShowShipping = true;
  //   //       debugPrint("Shipping Charges " + value.data.toString());
  //   //       debugPrint("Shipping Charges GrandTotal" + grandtotal.toString());
  //   //
  //   //       freeDeliveryAmount = double.parse(value.offer!.freeDeliveryAmount!);
  //   //     }
  //   //
  //   //     checkoutBloc.add(CheckoutShipingAmountEvent(
  //   //         isShow: isShowShipping,
  //   //         shippingCharges: shippingCharge,
  //   //         freeDeliveryAmount: freeDeliveryAmount));
  //   //   }
  //   // });
  //   //
  //   // checkoutBloc.add(GetAddressEvent(street: street, locality: locality));
  //   print("update address ");
  //   getShippingCharges("4");
  // }
}
