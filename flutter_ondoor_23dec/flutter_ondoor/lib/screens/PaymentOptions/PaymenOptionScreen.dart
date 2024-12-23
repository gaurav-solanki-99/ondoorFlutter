import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_upi_payment/easy_upi_payment.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_upi_pay/Src/payment.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:ondoor/constants/Constant.dart';
import 'package:ondoor/constants/ImageConstants.dart';
import 'package:ondoor/database/database_helper.dart';
import 'package:ondoor/models/AllProducts.dart';
import 'package:ondoor/models/get_coco_code_response.dart';
import 'package:ondoor/models/save_order_to_database_response.dart';
import 'package:ondoor/screens/AddCard/card_bloc.dart';
import 'package:ondoor/screens/AddCard/card_event.dart';
import 'package:ondoor/screens/CheckoutScreen/CheckoutBloc/checkout_bloc.dart';
import 'package:ondoor/screens/PaymentOptions/payment_options_bloc/payment_option_bloc.dart';
import 'package:ondoor/screens/PaymentOptions/payment_options_bloc/payment_option_event.dart';
import 'package:ondoor/screens/PaymentOptions/payment_options_bloc/payment_option_state.dart';
import 'package:ondoor/screens/change_address_screen/change_address_bloc/change_address_bloc.dart';
import 'package:ondoor/services/ApiServices.dart';
import 'package:ondoor/services/Endpoints.dart';
import 'package:ondoor/services/Navigation/routes.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/SizeConfig.dart';
import 'package:ondoor/utils/colors.dart';
import 'package:ondoor/utils/sharedpref.dart';
import 'package:ondoor/utils/shimmerUi.dart';
import 'package:ondoor/widgets/MyDialogs.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../constants/FontConstants.dart';
import '../../constants/StringConstats.dart';
import '../../database/dbconstants.dart';
import '../../models/CheckSumResponse.dart';
import '../../models/GetTimeSlotsResponse.dart';
import '../../models/ShippingCharges.dart';
import '../../models/address_list_response.dart';
import '../../models/locationvalidationmodel.dart';
import '../../services/Navigation/route_generator.dart';
import '../../utils/Comman_Loader.dart';
import '../../utils/Commantextwidget.dart';
import '../../utils/Connection.dart';
import '../../widgets/AppWidgets.dart';
import '../../widgets/common_loading_widget.dart';
import '../../widgets/login_widget_dialog/login_widget_dialog.dart';
import '../../widgets/select_time_slot_dialog.dart';
import '../../widgets/user_location_dialog.dart';
import '../CheckoutScreen/CheckoutBloc/checkout_event.dart';
import '../CheckoutScreen/CheckoutBloc/checkout_state.dart';
import '../change_address_screen/change_address_bloc/change_address_event.dart';
import '../change_address_screen/change_address_bloc/change_address_state.dart';
import 'UpiHandler.dart';

class PaymentOptionScreen extends StatefulWidget {
  List<ProductUnit> cartitesmList = [];
  PaymentOptionScreen({
    super.key,
    required this.cartitesmList,
  });

  @override
  State<PaymentOptionScreen> createState() => _PaymentOptionScreenState();
}

class _PaymentOptionScreenState extends State<PaymentOptionScreen>
    with TickerProviderStateMixin {
  List<PaymentGetway> payment_gateways = [];
  PaymentGetway selectedPaymentGateway = PaymentGetway();
  PaymentGetway cod_PG = PaymentGetway();
  SaveOrdertoDatabaseResponse saveOrdertoDatabaseResponse =
      SaveOrdertoDatabaseResponse();
  PaymentOptionBloc paymentOptionBloc = PaymentOptionBloc();
  GetCocoCodeByLatLngResponse? cocoCodeByLatLngResponse;
  GetTimeSlotResponse getTimeSlotResponse = GetTimeSlotResponse();
  AnimationController? animationController;
  late AnimationController shrinkanimationController;
  Animation<double>? shrinkAnimation;
  CheckoutBloc checkoutBloc = CheckoutBloc();
  List<Map<String, dynamic>> contentlist = [];
  Map<String, Map<String, Object?>> data = {};
  List<Map<String, dynamic>> subProductList = [];
  String selectedTimeSlot = "Please Select";
  String selectedDateSlot = "Please Select";
  String selectedDateSlotText = "";
  String locality = "";
  String orderId = "";
  String order_placeFlow = "";
  String street = "";
  String city = "";
  String userstate = "";
  String firstName = "";
  String txt_select_an_address = "";
  String plsSelecteADdressTxt = "";
  String lastName = "";
  String userName = "";
  String mobileNumber = "";
  double latitude = 0.0;
  double subtotal = 0.0;
  double subtotalcross = 0.0;
  double grandtotal = 0.0;
  double longitude = 0.0;
  double screenHeight = 0.0;
  double screenWidth = 0.0;
  int recent_check_passed = 0;
  bool loadshippingAmount = false;
  bool _isDialogShowing = false;
  bool _isAnimationEnd = false;
  bool isLoading = false;
  bool storeIDmatched = false;
  bool isPaytmPaymentSuccess = false;
  List<AddressData> addressListFromAPi = [];
  String initialSelectedCity = "";
  String initialSelectedLocation = "";
  AddressListResponse addressListResponse = AddressListResponse();
  AddressData selectedAddressData = AddressData();
  ChangeAddressBloc changeAddressBloc = ChangeAddressBloc();
  final dbHelper = DatabaseHelper();
  CardBloc cardBloc = CardBloc();
  double shippingCharge = 0;
  bool isShowShipping = false;
  bool apiCalled = false;
  bool saveOrderApiCalled = false;
  double remaingAmountonFreeDelivery = 0;
  double freeDeliveryAmount = 0;
  ScrollController mainScrollController = ScrollController();
  String offer_id = "";
  FlutterPayment flutterPayment = FlutterPayment();

  @override
  void initState() {
    initializeDatabase();
    print("payment_gateways  ${jsonEncode(payment_gateways)}");
    print("cartitesmList  ${jsonEncode(widget.cartitesmList)}");
    // shrinkanimationController!.forward();

    shrinkanimationController = AnimationController(
      vsync: this,
      animationBehavior: AnimationBehavior.normal,
      duration: Duration(milliseconds: 10),
    )..addListener(
        () async {
          shrinkanimationController.forward();
          if (shrinkAnimation != null) {
            paymentOptionBloc.add(
                PaymentOptionAnimationEvent(shrinkAnimation: shrinkAnimation!));
          }
          if (shrinkAnimation != null) {
            if (shrinkAnimation!.status == AnimationStatus.completed) {
              log("SHRINK ANIMATION VALUE bsdhnjf ${selectedPaymentGateway.paymentMethod}");
              Future.delayed(
                Duration(seconds: 3),
                () {
                  if (!saveOrderApiCalled) {
                    if (order_placeFlow == "Order Edited") {
                      editOrderApi();
                    } else {
                      saveOrderToDatabase(
                          paymentMethod: selectedPaymentGateway);
                    }

                    // Navigator.pushNamed(context, Routes.order_status_screen,
                    //     arguments: {
                    //       "success": true,
                    //       "message": "saveOrdertoDatabaseResponse.message",
                    //       "order_id": 12,
                    //       "amount": "1200.2",
                    //       "paid_by": "selectedPaymentGateway.paymentMethod",
                    //       "coupon_id": "saveOrdertoDatabaseResponse.coupon",
                    //       "rating_redirect_url":
                    //           "saveOrdertoDatabaseResponse.ratings!.ratingRiderctUrl",
                    //       "delivery_location": "finalAddress",
                    //       "selected_time_slot": selectedTimeSlot,
                    //       "selected_date_slot": selectedDateSlot,
                    //     }).then(
                    //   (value) {
                    //     shrinkAnimation = null;
                    //     Appwidgets.setStatusBarDynamicDarkColor(
                    //         color: ColorName.sugarCane);
                    //   },
                    // );
                  }
                },
              );

              // if (selectedPaymentGateway.paymentMethod == "Cash on delivery") {
              //
              // }
              // else if(selectedPaymentGateway.paymentMethod=="paytmupi") {
              //   log("SHRINK ANIMATION VALUE GGGGGG ${shrinkAnimation}");
              //
              // }
              // else {
              //   log("SHRINK ANIMATION VALUE GGGHHH ${shrinkAnimation}");
              // }
            }
          }
        },
      );
    getSelectedData();
    getSavedAddress();
    getShippingCharges(203);
    //selectpaymentCodUpdateOrder();

    super.initState();
  }

  //
  // selectpaymentCodUpdateOrder() async {
  //   await SharedPref
  //       .setStringPreference(
  //       Constants
  //           .selected_payment_Method,
  //       cod_PG.paymentMethod!).then((value){
  //     paymentOptionBloc.add(
  //         PaymentOptionSelectedEvent(
  //             selectedPaymentGateway:
  //             cod_PG));
  //   });
  //
  // }
  upipayment(CheckSumResponse response, Function callback) async {
    try {
      var upiId = response.vpa;
      var name = response.vpaname;
      var amount = response.amount;
      var currency = response.currency.toUpperCase();

      debugPrint("upipayment ${upiId} ${name} ${amount} ${amount} ${currency}");

      /* final result = await flutterPayment.launchUpi(
          upiId: upiId,
          name: name,
          amount: amount,
          message: "Ondoor",
          currency: currency);*/
/*
       var result = await flutterPayment.launchUpi(
          upiId: "paytm-14661518@ptybl",
          name: "Ondoor",
          amount: "1",
          message: "Ondoor",
          currency: currency);*/
      try {
        final res = await EasyUpiPaymentPlatform.instance.startPayment(
          EasyUpiPaymentModel(
            payeeVpa: upiId,
            payeeName: name,
            amount: 1.00, //double.parse(amount),
            description: 'Ondoor',
          ),
        );
        // TODO: add your success logic here
        print("Result >>>>>>>>>>>>>${res}");

        if (res!.responseCode == "S") {
          callback();
        } else {
          MyDialogs.showAlertDialogNew(context, "Transaction Failed", "Yes", "",
              () {
            Navigator.pop(context);
          }, () {
            Navigator.pop(context);
          });
        }
      } on EasyUpiPaymentException {
        // TODO: add your exception logic here

        MyDialogs.showAlertDialogNew(context, "Something went wrong", "Yes", "",
            () {
          Navigator.pop(context);
        }, () {
          Navigator.pop(context);
        });
      }

      // String url =
      //     'upi://pay?pa=$upiId&pn=$name&am=$amount&tn=Ondoor&cu=$currency';
      // var result = await launchUrl(Uri.parse(url)).then((value){
      //   print("Upiresult **  ${value}");
      //
      // });

      /* if(result!=null) {
        print("Upiresult ${result}");
        if (result) {
          callback();
        }
        else {
          MyDialogs.showAlertDialog(context, "Transaction Failed", "Yes", "",
                  () {
                Navigator.pop(context);
              }, () {
                Navigator.pop(context);
              });
        }
      }*/
      // final result = await flutterPayment.launchUpi(
      //     upiId: "ondoorconceptsprivatelimited98.paytm@hdfcbank",
      //     name: "Ondoor",
      //     amount: "1",
      //     message: "Ondoor",
      //     currency: "INR");

      // if (result != null) {
      //   if (result.status == 'SUCCESS') {
      //     // Payment successful
      //     print("Upiresult Payment Successful: ${result.message}");
      //     callback();
      //     // Perform actions such as updating the UI or database
      //   } else if (result.status == 'FAILURE') {
      //     // Payment failed
      //     print("Upiresult Payment Failed: ${result.message}");
      //
      //     MyDialogs.showAlertDialog(context, "${result.message}", "Yes", "",
      //         () {
      //       Navigator.pop(context);
      //     }, () {
      //       Navigator.pop(context);
      //     });
      //     // Handle failure case
      //   } else {
      //     // Payment status not recognized
      //     print("Upiresult Payment Status Unknown: ${result.message}");
      //     MyDialogs.showAlertDialog(context, "${result.message}", "Yes", "",
      //         () {
      //       Navigator.pop(context);
      //     }, () {
      //       Navigator.pop(context);
      //     });
      //   }
      // } else {
      //   print("Upiresult No response from UPI payment.");
      //   // MyDialogs.showAlertDialog(
      //   //     context, "No response from UPI payment.", "Yes", "", () {
      //   //   Navigator.pop(context);
      //   // }, () {
      //   //   Navigator.pop(context);
      //   // });
      // }
    } catch (e, stackTrace) {
      print("Upiresult No Found ${e}");
      print("Upiresult No Found ${stackTrace}");

      // MyDialogs.showAlertDialog(context, "No Upi Found", "Yes", "", () {
      //   Navigator.pop(context);
      // }, () {
      //   Navigator.pop(context);
      // });
    }
  }

  nativeUpiAndroid(CheckSumResponse response, Function callback) async {
    var upiId = response.vpa;
    var name = response.vpaname;
    var amount = response.amount;
    var currency = response.currency.toUpperCase();
    var deeplink = response.deeplink;

    // String url =    'upi://pay?pa=$upiId&pn=$name&am=$amount&tn=Ondoor&cu=$currency';
    print("nativeUpiAndroid ${deeplink}");
    var result =
        await UpiHandler.getUpiAppsInstalled(context, deeplink, callback)
            .then((value) {});
  }

  void _launchURL(CheckSumResponse response, Function callback) async {
    // String _url="upi://pay?pa=paytm-14661518@paytm&pn=Ondoor&mc=5411&am=1.00&tr=2819454&tn=ondoor";
    // String _url="upi://pay?pa=paytm-14661518@paytm&pn=Ondoor&mc=5411&am=1.00&tr=2819454&tn=ondoor";
    print("${response.deeplink}");
    String _url = response.deeplink;
    var result = await launch(_url);
    debugPrint("_launchURL Result " + result.toString());
    if (result == true) {
      callback();
      print("Done");
    } else if (result == false) {
      print("Fail");
    }
  }

  getSelectedData() async {
    order_placeFlow =
        await SharedPref.getStringPreference(Constants.OrderPlaceFlow);
    orderId =
        await SharedPref.getStringPreference(Constants.OrderidForEditOrder);

    print("orderIdStart $orderId");
    // if(orderId!="")
    //   {
    //
    //     print("orderIdStart2 $orderId");
    //     print("");
    //     await SharedPref
    //         .setStringPreference(
    //         Constants
    //             .selected_payment_Method,
    //         cod_PG.paymentMethod!);
    //     paymentOptionBloc.add(
    //         PaymentOptionSelectedEvent(
    //             selectedPaymentGateway:
    //             cod_PG));
    //   }
    selectedTimeSlot =
        await SharedPref.getStringPreference(Constants.selectedTimeSlot);
    selectedDateSlot =
        await SharedPref.getStringPreference(Constants.selectedDateSlot);
    selectedDateSlotText =
        await SharedPref.getStringPreference(Constants.selected_date_Text);
    if (selectedTimeSlot.trim().isNotEmpty &&
        selectedTimeSlot != "Please Select" &&
        selectedDateSlot.trim().isNotEmpty &&
        selectedDateSlot != "Please Select" &&
        selectedDateSlotText.trim().isNotEmpty) {
      checkoutBloc.add(TimeSlotSelectedEvent(
          selectedTimeSlot: selectedTimeSlot,
          selected_date_Text: selectedDateSlotText,
          selectedDateSlot: selectedDateSlot));
    }
    SharedPref.getStringPreference(Constants.selected_payment_Method).then(
      (selectedPaymentMethod) {
        print("SELECTED PAYMENT METHOD <<<<<     ${selectedPaymentMethod}");
        if (selectedPaymentMethod != "" && payment_gateways.isNotEmpty) {
          for (var element in payment_gateways) {
            if (element.paymentMethod == selectedPaymentMethod) {
              selectedPaymentGateway = element;
              paymentOptionBloc.add(PaymentOptionSelectedEvent(
                  selectedPaymentGateway: selectedPaymentGateway));
              break;
            }
          }
        }
      },
    );
  }

  initializeDatabase() async {
    await dbHelper.init();
    firstName = await SharedPref.getStringPreference(Constants.sp_FirstNAME);
    lastName = await SharedPref.getStringPreference(Constants.sp_LastName);
    mobileNumber = await SharedPref.getStringPreference(Constants.sp_MOBILE_NO);
    userName = "$firstName $lastName";
    var nameArr = userName.split(' ');
    if (nameArr.isNotEmpty) {
      if (nameArr.length == 1) {
        userName = userName.capitalize();
      } else {
        userName = userName.capitalizeByWord();
      }
    }
  }

  getSavedAddress() async {
    debugPrint("getsavedAddress");
    String latitudeStr =
        await SharedPref.getStringPreference(Constants.SELECTED_LOCATION_LAT);
    String longitudeStr =
        await SharedPref.getStringPreference(Constants.SELECTED_LOCATION_LONG);
    street = await SharedPref.getStringPreference(Constants.SAVED_ADDRESS);
    city = await SharedPref.getStringPreference(Constants.SAVED_CITY);
    userstate = await SharedPref.getStringPreference(Constants.SAVED_STATE);
    selectedAddressData.addressId =
        await SharedPref.getStringPreference(Constants.ADDRESS_ID);
    selectedAddressData.addressType =
        await SharedPref.getStringPreference(Constants.SELECTED_ADDRESS_TYPE);
    selectedAddressData.locationId =
        await SharedPref.getStringPreference(Constants.LOCATION_ID);
    selectedAddressData.wmsStoreId =
        await SharedPref.getStringPreference(Constants.WMS_STORE_ID);
    selectedAddressData.storeCode =
        await SharedPref.getStringPreference(Constants.STORE_CODE);
    selectedAddressData.storeName =
        await SharedPref.getStringPreference(Constants.STORE_Name);
    selectedAddressData.storeId =
        await SharedPref.getStringPreference(Constants.STORE_ID);
    selectedAddressData.flatSectorApartment =
        await SharedPref.getStringPreference(Constants.SAVED_FLatNumberAddress);
    selectedAddressData.postcode =
        await SharedPref.getStringPreference(Constants.PostalCode);
    selectedAddressData.address1 =
        await SharedPref.getStringPreference(Constants.ADDRESS_1);
    selectedAddressData.address2 =
        await SharedPref.getStringPreference(Constants.ADDRESS_2);
    selectedAddressData.areaDetail =
        await SharedPref.getStringPreference(Constants.AREA_DETAIL);
    selectedAddressData.deliveryAddress = await SharedPref.getStringPreference(
        Constants.SELECTED_DELIVERY_ADDRESS);
    if (latitudeStr != "" && longitudeStr != "") {
      print("LATITUDE >>>>  ${latitudeStr}");
      print("LONGITUDE >>>> ${longitudeStr}");
      latitude = double.parse(latitudeStr);
      longitude = double.parse(longitudeStr);
    }
    locality = "$city $userstate";
    selectedAddressData.latitude = latitudeStr;
    selectedAddressData.longitude = longitudeStr;
    selectedAddressData.city = city;
    selectedAddressData.zone = userstate;
    selectedAddressData.areaDetail = street;
    print("SELECTED SAVED ADDRESS DATA  ${jsonEncode(selectedAddressData)}");
    paymentOptionBloc.add(PaymentOptionAddressChangeEvent(
        selectedAddressData: selectedAddressData));
    checkAdressupdate();
    getCocoApi(latitude, longitude, city, userstate);
    retrieveAddressList();
    // if (isAddressIdempty() && _isDialogShowing == false) {
    //   ////
    // }
  }

  isAddressIdempty() {
    print("STORE ID isAddressIdempty ${selectedAddressData.storeId}");
    if ((selectedAddressData.addressId == null ||
            selectedAddressData.addressId == '') &&
        (selectedAddressData.storeId != null &&
            selectedAddressData.storeId != "")) {
      for (var addressData in addressListFromAPi) {
        if (selectedAddressData.storeId == addressData.storeId) {
          print("STORE ID MATCHED  ${addressData.storeId}");
          selectedAddressData = addressData;
          storeIDmatched = true;
          paymentOptionBloc.add(PaymentOptionAddressChangeEvent(
              selectedAddressData: selectedAddressData));
          showAddressSheet();
          break;
        } else {
          print("STORE ID NOT MATCHED  ${addressData.storeId}");
          storeIDmatched = false;
          if (_isDialogShowing) {
            break;
          } else {
            showAddressSheet();
            break;
          }
        }
      }
      print("STOREID $storeIDmatched");
      if (!storeIDmatched) {
        productValidationforCheckoutApi();
      }
    }
  }

  checkAdressupdate() async {
    bool status =
        await SharedPref.getBooleanPreference(Constants.locationupdate);
    print("Location Update Status ${status}");
    if (status) {
      getCocoApi(
          double.parse(selectedAddressData.latitude ?? "0.0"),
          double.parse(selectedAddressData.latitude ?? "0.0"),
          selectedAddressData.city ?? "",
          selectedAddressData.zone ?? "");
      loadAddress();
    }
  }

  loadAddress() {
    print("selectedAddressData ${selectedAddressData.storeId}");
    ApiProvider().productValidationcheckout(
        widget.cartitesmList,
        selectedAddressData.storeId ?? "",
        selectedAddressData.storeName ?? "",
        selectedAddressData.wmsStoreId ?? "",
        selectedAddressData.locationId ?? "",
        selectedAddressData.storeCode ?? "", () {
      loadAddress();
    }).then((value) async {
      log("Value from product Validation  ${value}");
      if (value != "") {
        var productValidationData = jsonDecode(value!);
        log("productValidationData ${productValidationData['success']}");
        if (productValidationData['success'] == false) {
          final responseData = jsonDecode(value.toString());
          var change_address_message = responseData["change_address_message"];
          debugPrint("responseData productValidationcheckout ${responseData}");
          debugPrint(
              "selectedAddressData productValidationcheckout ${responseData}");
          String storecodefromcoco =
              cocoCodeByLatLngResponse!.data!.storeId ?? "";
          debugPrint(
              "selectedAddressData selectedAddressData ${storecodefromcoco}");
          debugPrint(
              "selectedAddressData selectedAddressData ${selectedAddressData.storeId}");

          if (selectedAddressData.storeId != storecodefromcoco) {
            await SharedPref.setBooleanPreference(
                Constants.locationupdate, false);

            MyDialogs.showAlertDialogNew(
                context, change_address_message, "Yes", "No", () {
              loadLocationValidation(
                selectedAddressData.storeId ?? "",
                selectedAddressData.storeName ?? "",
                selectedAddressData.wmsStoreId ?? "",
                selectedAddressData.locationId ?? "",
                selectedAddressData.storeCode ?? "",
              );
              Navigator.pop(context);
            }, () {
              Navigator.pop(context);
            });
          }

          // showDialog(
          //   context: context,
          //   barrierDismissible: false,
          //   builder: (context) => WillPopScope(
          //     onWillPop: () async {
          //       return false;
          //     },
          //     child: AlertDialog(
          //
          //       shape: RoundedRectangleBorder(
          //           borderRadius:
          //           BorderRadius.circular(
          //               12)),
          //       title: Text(
          //         "${change_address_message}",
          //         style: Appwidgets()
          //             .commonTextStyle(
          //             ColorName.black),
          //       ),
          //       actions: [
          //         GestureDetector(
          //             onTap: () async {
          //               loadLocationValidation(
          //                 selectedAddressData.storeId ?? "",
          //                 selectedAddressData.storeName??"",
          //                 selectedAddressData.wmsStoreId ?? "",
          //                 selectedAddressData.locationId ?? "",
          //                 selectedAddressData.storeCode ?? "",
          //               );
          //              Navigator.pop(context);
          //
          //             },
          //             child: Text("Yes",
          //                 style: Appwidgets()
          //                     .commonTextStyle(
          //                     ColorName
          //                         .ColorPrimary))),
          //
          //         GestureDetector(
          //             onTap: () async {
          //
          //               Navigator.pop(context);
          //
          //             },
          //             child: Text("No",
          //                 style: Appwidgets()
          //                     .commonTextStyle(
          //                     ColorName
          //                         .black))),
          //
          //
          //       ],
          //     ),
          //   ),
          // );
        }
      }
    });
    getShippingCharges(588);
    //ROHITT
    // ApiProvider().getShippingCharges(subtotal, 0).then((value) async {
    //   if (value != null) {
    //     debugPrint("Shipping Charges $subtotal " + value.data.toString());
    //
    //     if (value.data.toString() == "null") {
    //       shippingCharge = double.parse("0");
    //     } else {
    //       shippingCharge = double.parse(value.data! ?? "0");
    //     }
    //
    //     if (value.data.toString() != "null") if (double.parse(value.data!) ==
    //         0) {
    //       isShowShipping = false;
    //       debugPrint("Shipping Charges Not Available ");
    //     } else {
    //       isShowShipping = true;
    //       debugPrint("Shipping Charges " + value.data.toString());
    //       debugPrint("Shipping Charges GrandTotal" + grandtotal.toString());
    //
    //       freeDeliveryAmount = double.parse(value.offer!.freeDeliveryAmount!);
    //     }
    //     paymentGetway = value.paymentGetway!;
    //     debugPrint("Shipping Charges GrandTotal" + grandtotal.toString());
    //     checkoutBloc.add(CheckoutNullEvent());
    //
    //     checkoutBloc.add(CheckoutShipingAmountEvent(
    //         isShow: isShowShipping,
    //         shippingCharges: shippingCharge,
    //         freeDeliveryAmount: freeDeliveryAmount));
    //   }
    // });
    //
    // checkoutBloc.add(GetAddressEvent(street: street, locality: locality));
  }

  Widget commonButtonForAddressChangeFeature() {
    return InkWell(
      onTap: () async {
        _isDialogShowing = false;
        retrieveAddressList();
        showAddressSheet();

        // Navigator.pushNamed(context, Routes.change_address,
        //         arguments: Routes.payment_option)
        //     .then(
        //   (data) async {
        //     apiCalled = false;
        //     paymentOptionBloc.add(PaymentOptionNullEvent());
        //     if (data != null) {
        //       getShippingCharges("2");
        //
        //       log("DATA FROM CHANGE ADDRESS ${selectedAddressData.toJson()}");
        //       data = data as AddressData;
        //       if (data.addressId == selectedAddressData.addressId) {
        //       } else {
        //         selectedAddressData = data as AddressData;
        //
        //         ApiProvider()
        //             .productValidationcheckout(
        //           widget.cartitesmList,
        //           selectedAddressData.storeId ?? "",
        //           selectedAddressData.storeName ?? "",
        //           selectedAddressData.wmsStoreId ?? "",
        //           selectedAddressData.locationId ?? "",
        //           selectedAddressData.storeCode ?? "",
        //         )
        //             .then((value) {
        //           if (value != "") {
        //             log("productValidationcheckout $value");
        //
        //             if (value.toString().contains("change_address_message")) {
        //               final responseData = jsonDecode(value.toString());
        //               var change_address_message =
        //                   responseData["change_address_message"];
        //               debugPrint(
        //                   "change_address_message ${change_address_message}");
        //
        //               MyDialogs.showAlertDialog(
        //                   context, change_address_message, "Yes", "No", () {
        //                 loadLocationValidation(
        //                   selectedAddressData.storeId ?? "",
        //                   selectedAddressData.storeName ?? "",
        //                   selectedAddressData.wmsStoreId ?? "",
        //                   selectedAddressData.locationId ?? "",
        //                   selectedAddressData.storeCode ?? "",
        //                 );
        //                 Navigator.pop(context);
        //               }, () {
        //                 Navigator.pop(context);
        //               });
        //
        //               // showDialog(
        //               //   context: context,
        //               //   barrierDismissible: false,
        //               //   builder: (context) => WillPopScope(
        //               //     onWillPop: () async {
        //               //       return false;
        //               //     },
        //               //     child: AlertDialog(
        //               //
        //               //       shape: RoundedRectangleBorder(
        //               //           borderRadius:
        //               //           BorderRadius.circular(
        //               //               12)),
        //               //       title: Text(
        //               //         "${change_address_message}",
        //               //         style: Appwidgets()
        //               //             .commonTextStyle(
        //               //             ColorName.black),
        //               //       ),
        //               //       actions: [
        //               //         GestureDetector(
        //               //             onTap: () async {
        //               //               loadLocationValidation(
        //               //                 selectedAddressData.storeId ?? "",
        //               //                 selectedAddressData.storeName??"",
        //               //                 selectedAddressData.wmsStoreId ?? "",
        //               //                 selectedAddressData.locationId ?? "",
        //               //                 selectedAddressData.storeCode ?? "",
        //               //               );
        //               //              Navigator.pop(context);
        //               //
        //               //             },
        //               //             child: Text("Yes",
        //               //                 style: Appwidgets()
        //               //                     .commonTextStyle(
        //               //                     ColorName
        //               //                         .ColorPrimary))),
        //               //
        //               //         GestureDetector(
        //               //             onTap: () async {
        //               //
        //               //               Navigator.pop(context);
        //               //
        //               //             },
        //               //             child: Text("No",
        //               //                 style: Appwidgets()
        //               //                     .commonTextStyle(
        //               //                     ColorName
        //               //                         .black))),
        //               //
        //               //
        //               //       ],
        //               //     ),
        //               //   ),
        //               // );
        //             }
        //           }
        //         });
        //         //ROHITT
        //         // ApiProvider()
        //         //     .getShippingCharges(
        //         //         subtotal, 0)
        //         //     .then(
        //         //         (value) async {
        //         //   if (value != null) {
        //         //     paymentGetway = value
        //         //         .paymentGetway!;
        //         //     debugPrint(
        //         //         "Shipping Charges $subtotal " +
        //         //             value.data
        //         //                 .toString());
        //         //
        //         //     if (value.data
        //         //             .toString() ==
        //         //         "null") {
        //         //       shippingCharge =
        //         //           double.parse(
        //         //               "0");
        //         //     } else {
        //         //       shippingCharge =
        //         //           double.parse(
        //         //               value.data! ??
        //         //                   "0");
        //         //     }
        //         //
        //         //     if (value.data
        //         //             .toString() !=
        //         //         "null") if (double
        //         //             .parse(value
        //         //                 .data!) ==
        //         //         0) {
        //         //       isShowShipping =
        //         //           false;
        //         //       debugPrint(
        //         //           "Shipping Charges Not Available ");
        //         //     } else {
        //         //       isShowShipping =
        //         //           true;
        //         //       debugPrint(
        //         //           "Shipping Charges " +
        //         //               value
        //         //                   .data
        //         //                   .toString());
        //         //       debugPrint(
        //         //           "Shipping Charges GrandTotal" +
        //         //               grandtotal
        //         //                   .toString());
        //         //
        //         //       freeDeliveryAmount =
        //         //           double.parse(value
        //         //               .offer!
        //         //               .freeDeliveryAmount!);
        //         //     }
        //         //     checkoutBloc.add(
        //         //         CheckoutNullEvent());
        //         //
        //         //     checkoutBloc.add(CheckoutShipingAmountEvent(
        //         //         isShow:
        //         //             isShowShipping,
        //         //         shippingCharges:
        //         //             shippingCharge,
        //         //         freeDeliveryAmount:
        //         //             freeDeliveryAmount));
        //         //   }
        //         // });
        //         //
        //         // checkoutBloc.add(
        //         //     GetAddressEvent(
        //         //         street:
        //         //             street,
        //         //         locality:
        //         //             locality));
        //         print("ROHIT PRINT 3");
        //       }
        //     } else {
        //       data = await Navigator.pushNamed(context, Routes.change_address,
        //           arguments: Routes.payment_option);
        //       apiCalled = false;
        //       paymentOptionBloc.add(PaymentOptionNullEvent());
        //     }
        //   },
        // );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        decoration: BoxDecoration(
          color: ColorName.ColorPrimary,
          borderRadius: BorderRadius.circular(4),
          // border: Border.all(color: ColorName.textlight, width: 1),
        ),
        child: Center(
          child: Appwidgets.TextSemiBold(StringContants.lbl_change,
              ColorName.ColorBagroundPrimary, TextAlign.center),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    CommanLoader().dismissEasyLoader();
    if (animationController != null) {
      animationController!.dispose();
    }
    mainScrollController.dispose();
    SharedPref.setStringPreference(Constants.OrderidForEditOrder, "");
    SharedPref.setStringPreference(Constants.OrderPlaceFlow, "");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = Sizeconfig.getHeight(context);
    screenWidth = Sizeconfig.getWidth(context);
    return MediaQuery(
      data: Appwidgets().mediaqueryDataforWholeApp(context: context),
      child: SafeArea(
          child: WillPopScope(
        onWillPop: () async {
          return shrinkanimationController.isAnimating || _isAnimationEnd
              ? false
              : true;
        },
        child: Scaffold(
          backgroundColor: ColorName.whiteSmokeColor,
          appBar: Appwidgets.MyAppBarWithHome(
            context,
            StringContants.lbl_order_confirmation,
          ),
          body: BlocBuilder(
              bloc: paymentOptionBloc,
              builder: (context, state) {
                print("Payment State ${state}");
                print("Payment State ${locality}, ${street}");
                if (state is PaymentOptionInitialState) {}
                if (state is PaymentOptionAddressChangeState) {
                  _isDialogShowing = false;
                  selectedAddressData = state.selectedAddressData;
                  if (selectedAddressData.firstname != null &&
                      selectedAddressData.firstname!.trim().isNotEmpty &&
                      selectedAddressData.lastname != null &&
                      selectedAddressData.lastname!.trim().isNotEmpty) {
                    userName =
                        "${selectedAddressData.firstname ?? ""} ${selectedAddressData.lastname ?? ""}";
                  }
                  String title = '';
                  print(
                      "SELECTED ADDRESS DATA ${jsonEncode(selectedAddressData)}");
                  print("SELECTED ADDRESS DATA ${selectedAddressData.zone}");
                  if (selectedAddressData.title != null &&
                      selectedAddressData.title != "") {
                    title = "${selectedAddressData.title!} ,";
                  }
                  if (selectedAddressData.subtitle != null &&
                      selectedAddressData.subtitle != "") {
                    street = title + selectedAddressData.subtitle!;
                  }
                  if ((selectedAddressData.title == null ||
                          selectedAddressData.title == "") &&
                      (selectedAddressData.subtitle == null ||
                          selectedAddressData.subtitle == "")) {
                    street =
                        "${selectedAddressData.address1!} ${selectedAddressData.address2!}";
                  }
                  locality = selectedAddressData.city ??
                      ", ${selectedAddressData.zone ?? ""}";
                  saveAddress();
                  // getTimeSlotsApi("903");
                }
                if (state is PaymentStatusState) {
                  saveOrdertoDatabaseResponse =
                      state.saveOrdertoDatabaseResponse;
                }
                if (state is PaymentOptionSelectedState) {
                  selectedPaymentGateway = state.selectedPaymentGateway;
                }
                if (state is PaymentOptionAnimationState) {
                  shrinkAnimation = state.shrinkAnimation;
                }
                if (state is PaymentOptionSuccessState) {
                  saveOrdertoDatabaseResponse = state.resjsondata;
                  isPaytmPaymentSuccess = true;
                }
                if (state is PaymentOptionFailureState) {
                  saveOrdertoDatabaseResponse =
                      state.saveOrdertoDatabaseResponse;
                  if (!_isDialogShowing) {
                    errorDialog(
                        saveOrdertoDatabaseResponse:
                            saveOrdertoDatabaseResponse);
                  }
                }
                calculateAmount(widget.cartitesmList);
                return VisibilityDetector(
                  key: Key("payment_option"),
                  onVisibilityChanged: (visibilityInfo) async {
                    var visiblePercentage =
                        visibilityInfo.visibleFraction * 100;
                    print("${visiblePercentage}");
                    if (visiblePercentage == 100) {
                      print("ROHIT PRINT 4");
                      // Future.delayed(
                      //   Duration(milliseconds: 800),
                      //   () {
                      //
                      //   },
                      // );
                      // checkAdressupdate();
                    }
                    Appwidgets.setStatusBarColor();
                  },
                  child: BlocProvider(
                    create: (context) => checkoutBloc,
                    child: BlocBuilder(
                        bloc: checkoutBloc,
                        builder: (context, state) {
                          Appwidgets.setStatusBarColor();
                          debugPrint(
                              "Checkout CardBloc PAYMENT SCREEN  ${state}");

                          if (state is CheckoutShippingLoadEvent) {
                            loadshippingAmount = true;
                          }

                          if (state is CheckoutInitial) {
                            // getSavedAddress();
                          }
                          // if (state is GetAddressState) {
                          //   debugPrint("ONADDRESSCHANGE");
                          //
                          //   locality = state.locality;
                          //   street = state.street;
                          //   // if (isAddressEmpty() == false) {
                          //   //   getCocoApi(latitude, longitude, city, userstate);
                          //   // }
                          // }
                          if (state is GetTimeSlotState) {
                            getTimeSlotResponse = state.timeSlotResponse;
                          }
                          if (state is TimeSlotSelectedState) {
                            selectedTimeSlot = state.selectedTimeSlot;
                            selectedDateSlot = state.selectedDateSlot;
                            selectedDateSlotText = state.selected_date_Text;
                            SharedPref.setStringPreference(
                                Constants.selectedTimeSlot, selectedTimeSlot);
                            SharedPref.setStringPreference(
                                Constants.selectedDateSlot, selectedDateSlot);
                            SharedPref.setStringPreference(
                                Constants.selected_date_Text,
                                selectedDateSlotText);
                            print(
                                "SELECTED TIME ${selectedTimeSlot} ,,,SELECTED DATE ${selectedDateSlot}");
                          }
                          if (state is CheckoutShipingAmountState) {
                            isShowShipping = state.isShow;
                            shippingCharge = state.shippingCharges;
                            grandtotal = subtotal + shippingCharge;

                            double remaingOnfreeDelivery =
                                state.freeDeliveryAmount - subtotal;
                            debugPrint(
                                "Shipping Charges  $remaingOnfreeDelivery");
                            remaingAmountonFreeDelivery = remaingOnfreeDelivery;
                          }
                          log("SELECTED TIME ${selectedAddressData.toJson()}");
                          return Scaffold(
                            backgroundColor: ColorName.whiteSmokeColor,
                            body: SingleChildScrollView(
                              controller: mainScrollController,
                              child: Column(
                                children: [
                                  // 10.toSpace,
                                  // commonWidgetforPaymentOption(
                                  //     child: Padding(
                                  //   padding: const EdgeInsets.symmetric(
                                  //       vertical: 8, horizontal: 8),
                                  //   child: Row(
                                  //     mainAxisAlignment:
                                  //         MainAxisAlignment.spaceBetween,
                                  //     children: [
                                  //       Column(
                                  //         crossAxisAlignment:
                                  //             CrossAxisAlignment.start,
                                  //         children: [
                                  //           Text(
                                  //             StringContants.lbl_bill_total,
                                  //             style: Appwidgets().commonTextStyle(
                                  //                 ColorName.darkGrey),
                                  //           ),
                                  //           Text(
                                  //             "Includes ${widget.saving_amount.toStringAsFixed(0)} saving through free delivery",
                                  //             style: Appwidgets()
                                  //                 .commonTextStyle(
                                  //                     ColorName.darkGrey)
                                  //                 .copyWith(
                                  //                     fontWeight: FontWeight.w500,
                                  //                     fontSize: 12),
                                  //           ),
                                  //         ],
                                  //       ),
                                  //       Text(
                                  //         "Rs ${widget.grand_total.toStringAsFixed(2)}",
                                  //         style: Appwidgets()
                                  //             .commonTextStyle(ColorName.black),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // )),
                                  10.toSpace,
                                  userName.trim().isNotEmpty
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 10),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          decoration: BoxDecoration(
                                              color: ColorName
                                                  .ColorBagroundPrimary,
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 7,
                                                child: Text(
                                                  userName,
                                                  maxLines: 1,
                                                  style: Appwidgets()
                                                      .commonTextStyle(
                                                          ColorName.black),
                                                ),
                                              ),
                                              Spacer(),
                                              Image.asset(
                                                Imageconstants.phone,
                                                height: 20,
                                                width: 20,
                                              ),
                                              5.toSpace,
                                              Text(
                                                mobileNumber,
                                                style: Appwidgets()
                                                    .commonTextStyle(
                                                        ColorName.black),
                                              ),
                                            ],
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(
                                        top: 10, left: 10, right: 10),
                                    decoration: BoxDecoration(
                                        color: ColorName.ColorBagroundPrimary,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        7.toSpace,
                                        Appwidgets.lables(
                                            "${StringContants.lbl_delivering_to_home} ${selectedAddressData.addressType ?? ""}",
                                            10,
                                            0),
                                        5.toSpace,
                                        isAddressEmpty()
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "Select Address",
                                                      style: Appwidgets()
                                                          .commonTextStyle(
                                                              ColorName
                                                                  .textlight2)
                                                          .copyWith(
                                                              fontWeight:
                                                                  Fontconstants
                                                                      .SF_Pro_Display_Medium),
                                                    ),
                                                    Spacer(),
                                                    commonButtonForAddressChangeFeature()
                                                  ],
                                                ),
                                              )
                                            : Padding(
                                                padding:
                                                    const EdgeInsets.all(0),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    5.toSpace,
                                                    Container(
                                                      child: Image.asset(
                                                        Imageconstants
                                                            .location_icon_for_checkout,
                                                        height: 40,
                                                        width: 40,
                                                      ),
                                                    ),
                                                    10.toSpace,
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            street,
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                                letterSpacing:
                                                                    0,
                                                                fontSize: Constants
                                                                    .SizeMidium,
                                                                fontFamily:
                                                                    Fontconstants
                                                                        .fc_family_sf,
                                                                fontWeight:
                                                                    Fontconstants
                                                                        .SF_Pro_Display_SEMIBOLD,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                          Text(
                                                              "${selectedAddressData.city ?? ""}, ${selectedAddressData.zone ?? ""}",
                                                              style: TextStyle(
                                                                  letterSpacing:
                                                                      0,
                                                                  fontSize:
                                                                      Constants
                                                                          .SizeSmall,
                                                                  fontFamily:
                                                                      Fontconstants
                                                                          .fc_family_sf,
                                                                  fontWeight:
                                                                      Fontconstants
                                                                          .SF_Pro_Display_Medium,
                                                                  color:
                                                                      ColorName
                                                                          .dark))
                                                        ],
                                                      ),
                                                    ),
                                                    commonButtonForAddressChangeFeature(),
                                                    5.toSpace,
                                                  ],
                                                ),
                                              ),
                                        5.toSpace,
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: 10, left: 10, right: 10),
                                    decoration: BoxDecoration(
                                        color: ColorName.ColorBagroundPrimary,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 5, 5, 0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Appwidgets.lables(
                                                  StringContants
                                                      .lbl_delivery_slot,
                                                  0,
                                                  0),
                                              InkWell(
                                                onTap: () async {
                                                  if (isAddressEmpty()) {
                                                    _isDialogShowing = false;
                                                    showAddressSheet();
                                                  } else {
                                                    getTimeSlotDialog();
                                                    _updateAddressData(
                                                        addressData:
                                                            selectedAddressData);
                                                  }
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 2,
                                                      horizontal: 8),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        ColorName.ColorPrimary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    // border: Border.all(color: ColorName.textlight, width: 1),
                                                  ),
                                                  child: Center(
                                                    child: Appwidgets.TextSemiBold(
                                                        StringContants
                                                            .lbl_change_slot,
                                                        ColorName
                                                            .ColorBagroundPrimary,
                                                        TextAlign.center),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        isAddressEmpty()
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "Select Time Slot",
                                                      style: Appwidgets()
                                                          .commonTextStyle(
                                                              ColorName
                                                                  .textlight2)
                                                          .copyWith(
                                                              fontWeight:
                                                                  Fontconstants
                                                                      .SF_Pro_Display_Medium),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Padding(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          /*       Text(
                                                              "Delivery Date",
                                                              style: Appwidgets()
                                                                  .commonTextStyle(
                                                                      ColorName
                                                                          .black)
                                                                  .copyWith(
                                                                      fontSize: 15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                            ),*/
                                                          CommanTextWidget
                                                              .regularBold(
                                                            "Delivery Date",
                                                            ColorName.black,
                                                            maxline: 1,
                                                            trt: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                            textalign: TextAlign
                                                                .center,
                                                          ),
                                                          5.toSpace,
                                                          GestureDetector(
                                                            onTap: () {
                                                              getTimeSlotsApi(
                                                                  "1088");
                                                              getTimeSlotDialog();
                                                            },
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  color: ColorName.aquaHazeColor,
                                                                  // border: Border.all(
                                                                  //     color:
                                                                  //         ColorName.black,
                                                                  //     width: 1),
                                                                  borderRadius: BorderRadius.circular(5)),
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          2,
                                                                      horizontal:
                                                                          8),
                                                              child: Center(
                                                                child: CommanTextWidget
                                                                    .regularBold(
                                                                  selectedDateSlot ==
                                                                          ""
                                                                      ? "Please Select"
                                                                      : selectedDateSlotText,
                                                                  ColorName
                                                                      .ColorPrimary,
                                                                  maxline: 1,
                                                                  trt:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                  textalign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    10.toSpace,
                                                    Container(
                                                      color:
                                                          ColorName.textlight,
                                                      width: 1,
                                                      height: 40,
                                                    ),
                                                    15.toSpace,
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          // Text(
                                                          //   "Delivery Time",
                                                          //   style: Appwidgets()
                                                          //       .commonTextStyle(
                                                          //           ColorName
                                                          //               .black)
                                                          //       .copyWith(
                                                          //           fontSize: 15,
                                                          //           fontWeight:
                                                          //               FontWeight
                                                          //                   .w500),
                                                          // ),
                                                          CommanTextWidget
                                                              .regularBold(
                                                            "Delivery Time",
                                                            ColorName.black,
                                                            maxline: 1,
                                                            trt: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                            textalign: TextAlign
                                                                .center,
                                                          ),
                                                          5.toSpace,
                                                          GestureDetector(
                                                            onTap: () {
                                                              getTimeSlotsApi(
                                                                  "1179");
                                                              getTimeSlotDialog();
                                                            },
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  color: ColorName.aquaHazeColor,
                                                                  // border: Border.all(
                                                                  //     color:
                                                                  //         ColorName.black,
                                                                  //     width: 1),
                                                                  borderRadius: BorderRadius.circular(5)),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          2,
                                                                      horizontal:
                                                                          8),
                                                              child: Center(
                                                                child: CommanTextWidget
                                                                    .regularBold(
                                                                  selectedTimeSlot ==
                                                                          ""
                                                                      ? "Please Select"
                                                                      : selectedTimeSlot,
                                                                  ColorName
                                                                      .ColorPrimary,
                                                                  maxline: 1,
                                                                  trt:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                  textalign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                  // 10.toSpace,
                                  cod_PG.paymentMethod == null ||
                                          cod_PG.paymentMethod == ""
                                      ? SizedBox.shrink()
                                      : 10.toSpace,
                                  // cash on delivery Payment gateway
                              // orderId!=""?Container():
                              cod_PG.paymentMethod == null ||
                                          cod_PG.paymentMethod == ""
                                      ? SizedBox.shrink()
                                      : commonWidgetforPaymentOption(
                                          child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8, left: 8),
                                              child: Text(
                                                "Pay on Delivery",
                                                style: Appwidgets()
                                                    .commonTextStyle(
                                                        ColorName.black)
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        fontSize: 15),
                                              ),
                                            ),
                                            commonWidgetforPaymentMethods(
                                              paymentGatewayData: cod_PG,
                                              onpress: () async {


                                                await SharedPref
                                                    .setStringPreference(
                                                        Constants
                                                            .selected_payment_Method,
                                                        cod_PG.paymentMethod!);
                                                paymentOptionBloc.add(
                                                    PaymentOptionSelectedEvent(
                                                        selectedPaymentGateway:
                                                            cod_PG));
                                              },
                                            )
                                          ],
                                        )),
                                  // Other payment gateway
                                  // orderId!=""?Container():
                                  payment_gateways.isEmpty ||
                                          (payment_gateways.length == 1 &&
                                              payment_gateways[0]
                                                      .paymentMethod ==
                                                  "Cash on delivery")
                                      ? const SizedBox.shrink()
                                      : 10.toSpace,

                                  // orderId!=""?Container():
                                  commonWidgetforPaymentOption(
                                      child: payment_gateways.isEmpty ||
                                              (payment_gateways.length == 1 &&
                                                  payment_gateways[0]
                                                          .paymentMethod ==
                                                      "Cash on delivery")
                                          ? const SizedBox.shrink()
                                          : Wrap(
                                              // crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8, left: 8),
                                                  child: Text(
                                                    "Recommended",
                                                    style: Appwidgets()
                                                        .commonTextStyle(
                                                            ColorName.black)
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            fontSize: 15),
                                                  ),
                                                ),
                                                // commonDivider(),
                                                ListView.separated(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  separatorBuilder: (context,
                                                          index) =>
                                                      index == 0
                                                          ? SizedBox.shrink()
                                                          : commonDivider(),
                                                  itemCount:
                                                      payment_gateways.length,
                                                  shrinkWrap: true,
                                                  itemBuilder:
                                                      (context, index) {
                                                    var paymentGatewayData =
                                                        payment_gateways[index];
                                                    return paymentGatewayData
                                                                .paymentMethod ==
                                                            "Cash on delivery"
                                                        ? const SizedBox()
                                                        : commonWidgetforPaymentMethods(
                                                            paymentGatewayData:
                                                                paymentGatewayData,
                                                            onpress: () async {
                                                              await SharedPref.setStringPreference(
                                                                  Constants
                                                                      .selected_payment_Method,
                                                                  paymentGatewayData
                                                                      .paymentMethod!);
                                                              paymentOptionBloc.add(
                                                                  PaymentOptionSelectedEvent(
                                                                      selectedPaymentGateway:
                                                                          paymentGatewayData));
                                                            },
                                                          );
                                                  },
                                                )
                                              ],
                                            )),

                                  10.toSpace,
                                  BlocBuilder(
                                      bloc: checkoutBloc,
                                      builder: (context, state) {
                                        if (state is CheckoutPriceUpdateState) {
                                          subtotal = state.subtotoal;
                                          subtotalcross = state.subtotoalcross;
                                          grandtotal =
                                              subtotal + shippingCharge;
                                        }
                                        if (state
                                            is CheckoutShipingAmountState) {
                                          isShowShipping = state.isShow;
                                          shippingCharge =
                                              state.shippingCharges;
                                          grandtotal =
                                              subtotal + shippingCharge;

                                          double remaingOnfreeDelivery =
                                              state.freeDeliveryAmount -
                                                  subtotal;
                                          debugPrint(
                                              "Shipping Charges  $remaingOnfreeDelivery");
                                          remaingAmountonFreeDelivery =
                                              remaingOnfreeDelivery;
                                        }
                                        return Container(
                                          width: Sizeconfig.getWidth(context),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 10),
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          decoration: BoxDecoration(
                                              color: ColorName
                                                  .ColorBagroundPrimary,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Appwidgets.lables(
                                                  StringContants
                                                      .lbl_bill_details,
                                                  0,
                                                  0),
                                              8.toSpace,
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      SizedBox(
                                                        height: 15,
                                                        width: 15,
                                                        child: Image.asset(
                                                            Imageconstants
                                                                .img_sub_total),
                                                      ),
                                                      5.toSpace,
                                                      Text(
                                                        StringContants
                                                            .lbl_sub_totol,
                                                        style: TextStyle(
                                                            fontSize: Constants
                                                                .SizeButton,
                                                            fontFamily:
                                                                Fontconstants
                                                                    .fc_family_sf,
                                                            fontWeight:
                                                                Fontconstants
                                                                    .SF_Pro_Display_SEMIBOLD,
                                                            color:
                                                                Colors.black),
                                                      )
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      subtotalcross == subtotal
                                                          ? const SizedBox
                                                              .shrink()
                                                          : Text(
                                                              "${Constants.ruppessymbol} ${subtotalcross.toStringAsFixed(2)}",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      Constants
                                                                          .SizeSmall,
                                                                  fontFamily:
                                                                      Fontconstants
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
                                                      10.toSpace,
                                                      Text(
                                                        "${Constants.ruppessymbol} ${subtotal.toStringAsFixed(2)}",
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
                                                            color: ColorName
                                                                .black),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                              8.toSpace,
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      SizedBox(
                                                        height: 15,
                                                        width: 15,
                                                        child: Image.asset(
                                                            Imageconstants
                                                                .img_delivery),
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        StringContants
                                                            .lbl_delivery_charges,
                                                        style: TextStyle(
                                                            fontSize: Constants
                                                                .SizeButton,
                                                            fontFamily:
                                                                Fontconstants
                                                                    .fc_family_sf,
                                                            fontWeight:
                                                                Fontconstants
                                                                    .SF_Pro_Display_SEMIBOLD,
                                                            color:
                                                                Colors.black),
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
                                                                  style: Appwidgets().commonTextStyle(ColorName.textlight).copyWith(
                                                                      fontSize:
                                                                          Constants
                                                                              .SizeSmall,
                                                                      fontFamily:
                                                                          Fontconstants
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
                                                                  StringContants
                                                                      .lbl_free,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          Constants
                                                                              .SizeButton,
                                                                      fontFamily:
                                                                          Fontconstants
                                                                              .fc_family_sf,
                                                                      fontWeight:
                                                                          Fontconstants
                                                                              .SF_Pro_Display_Bold,
                                                                      letterSpacing:
                                                                          0,
                                                                      color: ColorName
                                                                          .blue),
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
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    StringContants
                                                        .lbl_grand_total,
                                                    style: Appwidgets()
                                                        .commonTextStyle(
                                                            ColorName.black)
                                                        .copyWith(
                                                            fontWeight:
                                                                Fontconstants
                                                                    .SF_Pro_Display_Bold),
                                                  ),
                                                  Appwidgets.TextLagre(
                                                      "${Constants.ruppessymbol}${grandtotal.toStringAsFixed(2)}",
                                                      Colors.black),
                                                ],
                                              )
                                            ],
                                          ),
                                        );
                                      }),
                                  // 5.toSpace,
                                  10.toSpace,
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context, Routes.edit_profile);
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 5),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                color: ColorName.ColorPrimary),
                                            child: Text(
                                              "Add GST Details",
                                              style: Appwidgets()
                                                  .commonTextStyle(ColorName
                                                      .ColorBagroundPrimary)
                                                  .copyWith(fontSize: 12),
                                            ),
                                          ),
                                        ),
                                        8.toSpace,
                                        GestureDetector(
                                          onTap: () async {
                                            ApiProvider().getpages("26").then(
                                              (data) {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    double screenHeight =
                                                        Sizeconfig.getHeight(
                                                            context);

                                                    return SizedBox(
                                                      height: screenHeight * .4,
                                                      child: Dialog(
                                                        insetPadding: EdgeInsets.symmetric(
                                                            horizontal: 15,
                                                            vertical: Sizeconfig
                                                                    .getHeight(
                                                                        context) *
                                                                0.1),
                                                        child: Wrap(
                                                          children: [
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                vertical: 5,
                                                              ),
                                                              color: ColorName
                                                                  .ColorPrimary,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Container(
                                                                    width: Sizeconfig.getWidth(
                                                                            context) *
                                                                        0.1,
                                                                  ),
                                                                  Container(
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          HtmlWidget(
                                                                        data.data!
                                                                            .title
                                                                            .toString(),
                                                                        textStyle:
                                                                            Appwidgets().commonTextStyle(ColorName.ColorBagroundPrimary),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: Sizeconfig.getWidth(
                                                                            context) *
                                                                        0.1,
                                                                    margin: EdgeInsets.only(
                                                                        right:
                                                                            10),
                                                                    child:
                                                                        Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerRight,
                                                                      child: InkWell(
                                                                          onTap: () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child: Icon(
                                                                            Icons.cancel_outlined,
                                                                            color:
                                                                                Colors.white,
                                                                            size:
                                                                                20,
                                                                          )),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(10),
                                                              child: Container(
                                                                height: Sizeconfig
                                                                        .getHeight(
                                                                            context) *
                                                                    0.6,
                                                                child:
                                                                    SingleChildScrollView(
                                                                  child: Column(
                                                                    children: [
                                                                      HtmlWidget(
                                                                        data.data!
                                                                            .description!,
                                                                        enableCaching:
                                                                            true,
                                                                        buildAsync:
                                                                            true,
                                                                        onLoadingBuilder: (context,
                                                                            element,
                                                                            loadingProgress) {
                                                                          return Container(
                                                                            height:
                                                                                Sizeconfig.getHeight(context) * 0.7,
                                                                            child:
                                                                                Column(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Container(),
                                                                                Container(
                                                                                  height: screenHeight * .4,
                                                                                  child: CommonLoadingWidget(),
                                                                                ),
                                                                                Container()
                                                                              ],
                                                                            ),
                                                                          );
                                                                        },
                                                                        onTapUrl:
                                                                            (p0) async {
                                                                          print(
                                                                              "TAPPEDJJFHHFHH ${p0}");
                                                                          try {
                                                                            await launchUrl(Uri.parse(p0));
                                                                          } catch (e) {
                                                                            print("Error While Loading url $e");
                                                                          }
                                                                          return true;
                                                                        },
                                                                        textStyle:
                                                                            TextStyle(color: ColorName.black),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            );
                                          },
                                          child: const Icon(
                                            Icons.info,
                                            size: 18,
                                            color: ColorName.ColorPrimary,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  10.toSpace,
                                  commonWidgetforPaymentOption(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Review your Order to avoid cancellations",
                                            style: Appwidgets()
                                                .commonTextStyle(
                                                    ColorName.darkGrey)
                                                .copyWith(
                                                  fontSize: 12,
                                                ),
                                          ),
                                          5.toSpace,
                                          RichText(
                                            overflow: TextOverflow.clip,
                                            textAlign: TextAlign.end,
                                            textDirection: TextDirection.rtl,
                                            softWrap: true,
                                            textScaleFactor: 1,
                                            text: TextSpan(
                                              text: 'NOTE:',
                                              style: Appwidgets()
                                                  .commonTextStyle(
                                                      ColorName.ColorPrimary)
                                                  .copyWith(
                                                    fontSize: 11,
                                                  ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text:
                                                      ' Orders cannot be cancelled and are non-refundable once packed for delivery',
                                                  style: Appwidgets()
                                                      .commonTextStyle(
                                                          ColorName.darkGrey)
                                                      .copyWith(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                          ),
                                          5.toSpace,
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(context,
                                                  Routes.company_info_page,
                                                  arguments: "5");
                                            },
                                            child: Text(
                                              "Read Cancellation Policy",
                                              style: Appwidgets()
                                                  .commonTextStyle(
                                                      ColorName.ColorPrimary)
                                                  .copyWith(
                                                    decorationColor:
                                                        ColorName.ColorPrimary,
                                                    decoration: TextDecoration
                                                        .underline,
                                                    decorationThickness: 5,
                                                    decorationStyle:
                                                        TextDecorationStyle
                                                            .dashed,
                                                    fontSize: 12,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  10.toSpace,
                                ],
                              ),
                            ),
                            bottomNavigationBar: Wrap(
                              // crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    double scrollextent = 0.0;
                                    if (mainScrollController.hasClients) {
                                      scrollextent = mainScrollController
                                          .position.maxScrollExtent;
                                    }
                                    _scrollme(scrollextent: scrollextent);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.zero,
                                    color: ColorName.orange.withOpacity(.15),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2, horizontal: 10),
                                      child: Row(
                                        children: [
                                          CommanTextWidget.regularBold(
                                            "To Pay : ${Constants.ruppessymbol} $grandtotal",
                                            ColorName.darkGrey,
                                            maxline: 1,
                                            trt: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            textalign: TextAlign.center,
                                          ),
                                          2.toSpace,
                                          // grandtotal ==
                                          //         (subtotalcross +
                                          //             shippingCharge)
                                          //     ? SizedBox.shrink()
                                          //     : Text(
                                          //         "${Constants.ruppessymbol}${(subtotalcross + shippingCharge).toString()}"
                                          //             .trim(),
                                          //         style: Appwidgets()
                                          //             .commonTextStyle(
                                          //                 ColorName.textlight2)
                                          //             .copyWith(
                                          //                 fontSize: 13,
                                          //                 decorationColor:
                                          //                     ColorName
                                          //                         .textlight2,
                                          //                 decoration:
                                          //                     TextDecoration
                                          //                         .lineThrough),
                                          //       ),
                                          Spacer(),
                                          CommanTextWidget.regularBold(
                                            "View Detailed Bill",
                                            ColorName.orange,
                                            maxline: 1,
                                            trt: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textalign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  color: ColorName.ColorBagroundPrimary,
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Align(
                                        alignment: Alignment.center,
                                        child: shrinkAnimation == null
                                            ? submitButton()
                                            : _isAnimationEnd
                                                ? Container(
                                                    width: 45,
                                                    height: 45,
                                                    decoration: BoxDecoration(
                                                        color: ColorName
                                                            .ColorPrimary,
                                                        shape: BoxShape.circle),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: ColorName
                                                            .ColorBagroundPrimary,
                                                        strokeWidth: 2,
                                                      ),
                                                    ),
                                                  )
                                                : AnimatedContainer(
                                                    onEnd: () {
                                                      print(
                                                          "Animation ENdss...");
                                                      _isAnimationEnd = true;
                                                      paymentOptionBloc.add(
                                                          PaymentOptionNullEvent());
                                                    },
                                                    width:
                                                        shrinkAnimation?.value,
                                                    curve: Curves.easeIn,
                                                    duration: Duration(
                                                        milliseconds: 1000),
                                                    child: submitButton(),
                                                  )),
                                  ),
                                )
                              ],
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

  Widget submitButton() {
    if (shrinkAnimation != null) {
      log("SHRINK ANIMATION VALUE ${shrinkAnimation?.value}");
    }
    return GestureDetector(
      onTap: () async {
      /*  if(orderId.trim().isNotEmpty){
          selectedPaymentGateway=cod_PG;
          paymentOptionBloc.add(
              PaymentOptionSelectedEvent(
                  selectedPaymentGateway:
                  cod_PG));
        }*/
        debugPrint(
            "selectedPaymentGatewayG ${selectedPaymentGateway.paymentMethod}");
        if (isAddressEmpty()) {
          // await _handleChangeAddress();
          _isDialogShowing = false;
          showAddressSheet();
        } else if (_isTimeSlotInvalid()) {
          getTimeSlotDialog();
        } else if (!_isPaymentMethodSelected()) {
          _scrollme(scrollextent: 0);
          Appwidgets.showToastMessage("Please Select Payment Method");
        } else {
          if (shrinkAnimation == null) {
            shrinkanimationController.stop();
            shrinkanimationController.reset();
          }
          _startAnimation();

          // if (selectedPaymentGateway.paymentMethod == cod_PG.paymentMethod) {
          //   _startAnimation();
          // }
          // else if(selectedPaymentGateway.paymentMethod=="paytmupi"){
          //   _startAnimation();
          //
          // }
          // else {
          //   Appwidgets.showToastMessage("Working Under Process");
          // }
        }
      },
      child: Container(
        width: shrinkAnimation == null
            ? Sizeconfig.getWidth(context)
            : shrinkAnimation?.value,
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(80)),
            color: ColorName.ColorPrimary),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isAddressEmpty()
                  ? "Please Select Address"
                  : selectedTimeSlot.contains("Please Select") ||
                          selectedDateSlot.contains("Please Select")
                      ? "Please Select Slot"
                      : selectedPaymentGateway.title == null
                          ? "Select Payment Method"
                          : /*shrinkAnimation != null &&
                                  shrinkAnimation!.value < 41
                              ? ""
                              : */
                          StringContants.lbl_place_order,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: Constants.Sizelagre,
                  fontFamily: Fontconstants.fc_family_sf,
                  fontWeight: Fontconstants.SF_Pro_Display_Bold,
                  color: Colors.white),
            ),
            isAddressEmpty() ||
                    selectedTimeSlot.contains("Please Select") ||
                    selectedDateSlot.contains("Please Select") ||
                    selectedPaymentGateway.title == null
                ? Icon(Icons.arrow_right)
                : SizedBox.shrink()
          ],
        ),
      ),
    );
  }

  _updateAddressData({required AddressData addressData}) async {
    double latitude = double.parse(addressData.latitude!);
    double longitude = double.parse(addressData.longitude!);
    getCocoApi(latitude, longitude, addressData.city!, addressData.zone!);
    print("SUBTITLE ${addressData.subtitle}");
    String title = "";
    if (selectedAddressData.title != null && selectedAddressData.title != "") {
      title = "${selectedAddressData.title!} ,";
    }
    if (selectedAddressData.subtitle != null &&
        selectedAddressData.subtitle != "") {
      street = title + selectedAddressData.subtitle!;
    }
    if ((selectedAddressData.title == null ||
            selectedAddressData.title == "") &&
        (selectedAddressData.subtitle == null ||
            selectedAddressData.subtitle == "")) {
      street =
          "${selectedAddressData.address1!} ${selectedAddressData.address2!}";
    }
    locality = "${addressData.city!}, ${addressData.zone!}";
    print("STREET UPDATE ADDRESS ${street}");
    print("LOCALITY UPDATE ADDRESS ${locality}");

    await SharedPref.setStringPreference(Constants.SAVED_ADDRESS, street);
    await SharedPref.setStringPreference(
        Constants.SELECTED_LOCATION_LAT, addressData.latitude!);
    await SharedPref.setStringPreference(
        Constants.SELECTED_ADDRESS_TYPE, addressData.addressType!);
    await SharedPref.setStringPreference(
        Constants.SELECTED_LOCATION_LONG, addressData.longitude!);
    await SharedPref.setStringPreference(
        Constants.ADDRESS_ID, addressData.addressId!);
    await SharedPref.setStringPreference(
        Constants.SAVED_CITY, addressData.city ?? "");
    await SharedPref.setStringPreference(
        Constants.SAVED_STATE, addressData.zone ?? "");
    paymentOptionBloc.add(PaymentOptionNullEvent());
  }

  void _scrollme({required double scrollextent}) {
    if (mainScrollController.hasClients) {
      mainScrollController.animateTo(scrollextent,
          duration: Duration(milliseconds: 200), curve: Curves.easeIn);
      paymentOptionBloc.add(PaymentOptionNullEvent());
    }
  }

  _startAnimation() async {
    print("Start Animation");
    shrinkAnimation =
        Tween<double>(begin: Sizeconfig.getWidth(context), end: 40).animate(
      CurvedAnimation(
        parent: shrinkanimationController,
        curve: Curves.easeIn,
      ),
    );
    if (shrinkAnimation != null) {
      shrinkanimationController.forward();
      paymentOptionBloc
          .add(PaymentOptionAnimationEvent(shrinkAnimation: shrinkAnimation!));
    } else {
      shrinkanimationController.stop();
      shrinkanimationController.reset();
    }
  }

  bool _isTimeSlotInvalid() {
    return selectedTimeSlot.contains("Please Select") ||
        selectedDateSlot.contains("Please Select") ||
        selectedDateSlotText.contains("Please Select Date");
  }

  bool _isPaymentMethodSelected() {
    return selectedPaymentGateway.paymentMethod != null;
  }

  Widget companyInfoLoader(context) {
    return SizedBox(child: const Center(child: CommonLoadingWidget()));
  }

  calculateAmount(List<ProductUnit> list) {
    double subtotalshow = 0;
    double subtotalcross = 0;

    for (var dummyData in list) {
      if (dummyData.specialPrice == "Free") {
      } else {
        // dummyData.price ?? "0.0" added by Rohit before it was "0.0"
        var sortPrice = (double.parse(dummyData.sortPrice == null ||
                        dummyData.sortPrice == "null" ||
                        dummyData.sortPrice == ""
                    ? "0.0"
                    : dummyData.sortPrice!) *
                dummyData.addQuantity)
            .toString();
        var specialPrice = (double.parse(
                    dummyData.specialPrice.toString() == null ||
                            dummyData.specialPrice.toString() == "null" ||
                            dummyData.specialPrice.toString() == ""
                        ? "0.0"
                        : dummyData.specialPrice!.toString()) *
                dummyData.addQuantity)
            .toString();
        var price = (double.parse(dummyData.price == null ||
                        dummyData.price == "null" ||
                        dummyData.price == ""
                    ? "0.0"
                    : dummyData.price!) *
                dummyData.addQuantity)
            .toString();
        var crossprice = dummyData.specialPrice == null ||
                dummyData.specialPrice == "null" ||
                dummyData.specialPrice == ""
            ? "₹ ${double.parse(price).toStringAsFixed(2)}"
            : "₹ ${double.parse(price).toStringAsFixed(2)}";
        var showprice = dummyData.specialPrice == null ||
                dummyData.specialPrice == "null" ||
                dummyData.specialPrice == ""
            ? "₹ ${double.parse(sortPrice).toStringAsFixed(2)}"
            : "₹ ${double.parse(specialPrice).toStringAsFixed(2)}";

        subtotalshow =
            subtotalshow + double.parse(showprice.replaceAll('₹ ', ""));

        subtotalcross =
            subtotalcross + double.parse(crossprice.replaceAll('₹ ', ""));
      }
    }

    checkoutBloc.add(CheckoutPriceUpdateEvent(
        subtotoal: subtotalshow, subtotoalcross: subtotalcross));
  }

  bool isAddressEmpty() {
    print("STREET ${street}");
    print("LOCALITY ${locality}");
    return selectedAddressData.addressId == null ||
            selectedAddressData.addressId!.trim().isEmpty
        ? true
        : false;
  }

  void saveOrderToDatabase({required PaymentGetway paymentMethod}) async {
    print(
        "ADDRESS 1 === ${selectedAddressData.address1} \nADDRESS 2 ${selectedAddressData.address1}");
    subProductList!.clear();
    saveOrderApiCalled = true;
    _isDialogShowing = false;
    EasyLoading.show();
    double total = 0.0;
    String customer_ID =
        await SharedPref.getStringPreference(Constants.sp_CustomerId) ?? "";

    List<Map<String, dynamic>> contentlist = [];
    for (int i = 0; i < widget.cartitesmList.length; i++) {
      var cartitemData = widget.cartitesmList[i];
      print("CART ITEM DATA ${cartitemData.toMap()}");
      print("CART ITEM specialPrice ${cartitemData.specialPrice}");
      print("CART ITEM price ${cartitemData.price}");
      String productPrice = "0.0";
      if (cartitemData.specialPrice == null ||
          cartitemData.specialPrice == "null" ||
          cartitemData.specialPrice == "" ||
          cartitemData.specialPrice == "0" ||
          cartitemData.specialPrice == 0) {
        productPrice = cartitemData.price ?? "0.0";
        print("price   ${productPrice}");
      } else {
        productPrice = cartitemData.specialPrice.toString();
      }

      total = total +
          (double.parse(productPrice == "Free" ? "0.0" : productPrice) *
              cartitemData.addQuantity);
      if (productPrice != "Free") {
        contentlist.add({
          "index": i.toString(),
          "productID": cartitemData.productId,
          "productName": cartitemData.name,
          "product_id": cartitemData.productId,
          "name": cartitemData.name,
          "add_item": cartitemData.addQuantity,
          "image": cartitemData.image,
          "quantity": cartitemData.addQuantity,
          "model": cartitemData.model,
          "subtract": cartitemData.subtract,
          "message_on_card": cartitemData.messageOnCard,
          "message_on_cake": cartitemData.messageOnCake,
          "is_option": cartitemData.isOption,
          "special_price": cartitemData.specialPrice,
          "shipping_option": "",
          "shipping_charge": "",
          "gift_item": "",
          "option": cartitemData.options ?? [],
          "custom_msg": cartitemData.customMsg,
          "price": productPrice,
          "price_total": productPrice,
          "total": productPrice == "Free"
              ? total = total + (0 * cartitemData.addQuantity)
              : double.parse(productPrice) * cartitemData.addQuantity,
          "discount_label": cartitemData.discountLabel,
          "discount_text": cartitemData.discountText,
          "c_offer_id": cartitemData.cOfferId == null
              ? "0"
              : cartitemData.cOfferId.toString(),
          "offer_product_id": null,
          "offer_eligible": 0,
          "sub_product": cartitemData.subProduct ?? []
        });
      }
      if (productPrice == "Free") {
        var subProductItem = {
          "productID": cartitemData.productId,
          "offer_id": cartitemData.offer_id,
          "productName": cartitemData.name,
          "model": cartitemData.model,
          "quantity": cartitemData.quantity,
          "subtract": cartitemData.subtract,
          "price": productPrice,
          "total": productPrice,
          "mandatory": cartitemData.mandatory,
          "is_customer_offer": ""
        };
        offer_id = cartitemData.offer_id.toString();
        if (!subProductList.contains(subProductItem)) {
          subProductList.add(subProductItem);
        }
      }
      // }
    }
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    var data = {
      "data": {
        "shipping": shippingCharge,
        "surcharge": "0",
        "discount_amount": "0.0",
        "discount_type": "0",
        "discount_code": "0",
        "tax": "0",
        "reward_amount": "0",
        "promo_wallet_used": 0,
        "campaign_id": "0",
        "reward": "0",
        "store_id": selectedAddressData.storeId,
        "store_name": selectedAddressData.storeName,
        "store_url": Endpoints.BASE_URL,
        "address_id": selectedAddressData.addressId,
        "store_code": selectedAddressData.storeCode,
        "firstname": firstName,
        "lastname": lastName,
        "company": "",
        "flat_sector_apartment": selectedAddressData.flatSectorApartment,
        "landmark": selectedAddressData.landmark,
        "area_detail": selectedAddressData.areaDetail,
        "city": selectedAddressData.city,
        "postcode": selectedAddressData.postcode,
        "zone": selectedAddressData.zone,
        "zone_id": selectedAddressData.zoneId,
        "country": "India",
        "country_id": "99",
        "address_format": "",
        "custom_field": "",
        "customer_id": customer_ID,
        "payment_firstname": firstName,
        "payment_lastname": lastName,
        "payment_company": "",
        "payment_address_1": selectedAddressData.address1,
        "payment_address_2": selectedAddressData.address2,
        "payment_telephone": mobileNumber,
        "payment_city": selectedAddressData.city,
        "payment_postcode": selectedAddressData.postcode,
        "payment_zone": selectedAddressData.zone,
        "payment_address_format": "",
        "payment_custom_field": "",
        "telephone": mobileNumber,
        "seller_product": "0",
        "payment_method": selectedPaymentGateway.paymentMethod,
        "payment_code": selectedPaymentGateway.paymentCode,
        "delivery_time": selectedTimeSlot,
        "delivery_date": selectedDateSlot,
        "location_id": selectedAddressData.locationId,
        "total": total,
        "order_offer_total": 0,
        "order_status": "",
        "comment": "afdsfa",
        "user_agent": "app-android-${packageInfo.version}",
        "contents": contentlist,
        "offer_product": subProductList.toSet().toList(),
        "offer_id": offer_id,
        "discount": "0",
        "sodexo_amount": "",
        "recent_check_passed": recent_check_passed,
        "gst_include": 0
      }
    };
    saveOrdertoDatabaseResponse =
        await ApiProvider().saveOrdertoDataBase(data, () {
      saveOrderToDatabase(paymentMethod: paymentMethod);
    });
    EasyLoading.dismiss();
    paymentOptionBloc.add(PaymentStatusEvent(
        saveOrdertoDatabaseResponse: saveOrdertoDatabaseResponse));
    if (saveOrdertoDatabaseResponse.success == true) {
      shrinkAnimation = null;
      _isAnimationEnd = false;
      saveOrderApiCalled = false;
      if (selectedPaymentGateway.paymentMethod == "Cash on delivery") {
        String title = "";
        if (selectedAddressData.title != null &&
            selectedAddressData.title != "") {
          title = "${selectedAddressData.title!} ,";
        }
        if (selectedAddressData.subtitle != null &&
            selectedAddressData.subtitle != "") {
          street = title + selectedAddressData.subtitle!;
        }
        if ((selectedAddressData.title == null ||
                selectedAddressData.title == "") &&
            (selectedAddressData.subtitle == null ||
                selectedAddressData.subtitle == "")) {
          street =
              "${selectedAddressData.address1!} ${selectedAddressData.address2!}";
        }
        Navigator.pushNamed(context, Routes.order_status_screen, arguments: {
          "success": true,
          "message": saveOrdertoDatabaseResponse.message,
          "order_id": saveOrdertoDatabaseResponse.orderId ?? 0,
          "amount": saveOrdertoDatabaseResponse.total,
          "paid_by": selectedPaymentGateway.paymentMethod,
          "coupon_id": saveOrdertoDatabaseResponse.coupon ?? "",
          "rating_redirect_url":
              saveOrdertoDatabaseResponse.ratings!.ratingRiderctUrl ?? "",
          "delivery_location": street + city + userstate,
          "selected_time_slot": selectedTimeSlot,
          "selected_date_slot": selectedDateSlot,
        }).then(
          (value) {
            shrinkanimationController.stop();
            shrinkanimationController.reset();
            shrinkAnimation = null;
            Appwidgets.setStatusBarDynamicDarkColor(color: ColorName.sugarCane);
          },
        );
      } else if (selectedPaymentGateway.paymentMethod == "paytmupi") {
        log("SHRINK ANIMATION VALUE GGGGGG ${shrinkAnimation}");

        generateCheckumapi();
      }
      if (selectedPaymentGateway.paymentCode == "paytm") {
        shrinkAnimation = null;
        String title = "";
        if (selectedAddressData.title != null &&
            selectedAddressData.title != "") {
          title = "${selectedAddressData.title!} ,";
        }
        if (selectedAddressData.subtitle != null &&
            selectedAddressData.subtitle != "") {
          street = title + selectedAddressData.subtitle!;
        }
        if ((selectedAddressData.title == null ||
                selectedAddressData.title == "") &&
            (selectedAddressData.subtitle == null ||
                selectedAddressData.subtitle == "")) {
          street =
              "${selectedAddressData.address1!} ${selectedAddressData.address2!}";
        }
        paymentOptionBloc.add(InitilizedPaytmPaymentEvent(
            resjsondata: saveOrdertoDatabaseResponse,
            context: context,
            finalAddress: street + city + userstate,
            selectedDateSlot: selectedDateSlot,
            selectedTimeSlot: selectedTimeSlot));
      } else {
        log("SHRINK ANIMATION VALUE GGGHHH ${shrinkAnimation}");
      }
    } else {
      shrinkAnimation = null;
      _isAnimationEnd = false;
      saveOrderApiCalled = false;
      shrinkanimationController.stop();
      shrinkanimationController.reset();
      // print("SAVE ORDER TO DATABASE ${saveOrdertoDatabaseResponse.toJson()}");
      // print("SAVE ORDER TO DATABASE ${saveOrdertoDatabaseResponse.data}");
      if (saveOrdertoDatabaseResponse.error != null &&
          saveOrdertoDatabaseResponse.error != "") {
        errorDialog(saveOrdertoDatabaseResponse: saveOrdertoDatabaseResponse);
      }
    }
  }

  generateCheckumapi() async {
    await ApiProvider().generateChecksumupiApi(
        saveOrdertoDatabaseResponse.orderId.toString(),
        saveOrdertoDatabaseResponse.total.toString(), () {
      generateCheckumapi();
    }).then((value) {
      if (value != null) {
        // _launchURL(value,(){
        //   Navigator.pushNamed(context, Routes.order_status_screen, arguments: {
        //     "success": true,
        //     "message": saveOrdertoDatabaseResponse.message,
        //     "order_id": saveOrdertoDatabaseResponse.orderId ?? 0,
        //     "amount": saveOrdertoDatabaseResponse.total,
        //     "paid_by": selectedPaymentGateway.paymentMethod,
        //     "coupon_id": saveOrdertoDatabaseResponse.coupon ?? "",
        //     "rating_redirect_url":
        //     saveOrdertoDatabaseResponse.ratings!.ratingRiderctUrl ?? "",
        //     "delivery_location": finalAddress,
        //     "selected_time_slot": selectedTimeSlot,
        //     "selected_date_slot": selectedDateSlot,
        //   }).then(
        //         (value) {
        //       shrinkAnimation = null;
        //       Appwidgets.setStatusBarDynamicDarkColor(color: ColorName.sugarCane);
        //     },
        //   );
        // });
        nativeUpiAndroid(value, () {
          checkonlinePayment();
        });
      }
    });
  }

  checkonlinePayment() {
    ApiProvider()
        .checkOnlinePayment(saveOrdertoDatabaseResponse.orderId.toString(), () {
      checkonlinePayment();
    }).then((value) {
      if (value.success == true) {
        String title = "";
        if (selectedAddressData.title != null &&
            selectedAddressData.title != "") {
          title = "${selectedAddressData.title!} ,";
        }
        if (selectedAddressData.subtitle != null &&
            selectedAddressData.subtitle != "") {
          street = title + selectedAddressData.subtitle!;
        }
        if ((selectedAddressData.title == null ||
                selectedAddressData.title == "") &&
            (selectedAddressData.subtitle == null ||
                selectedAddressData.subtitle == "")) {
          street =
              "${selectedAddressData.address1!} ${selectedAddressData.address2!}";
        }
        Navigator.pushNamed(context, Routes.order_status_screen, arguments: {
          "success": true,
          "message": saveOrdertoDatabaseResponse.message,
          "order_id": saveOrdertoDatabaseResponse.orderId ?? 0,
          "amount": saveOrdertoDatabaseResponse.total,
          "paid_by": selectedPaymentGateway.paymentMethod,
          "coupon_id": saveOrdertoDatabaseResponse.coupon ?? "",
          "rating_redirect_url":
              saveOrdertoDatabaseResponse.ratings!.ratingRiderctUrl ?? "",
          "delivery_location": street + city + userstate,
          "selected_time_slot": selectedTimeSlot,
          "selected_date_slot": selectedDateSlot,
        }).then(
          (value) {
            shrinkAnimation = null;
            shrinkanimationController.stop();
            shrinkanimationController.reset();
            Appwidgets.setStatusBarDynamicDarkColor(color: ColorName.sugarCane);
          },
        );
      } else {
        Appwidgets.showToastMessage(value.message!);
      }
    });
  }

  void editOrderApi() async {
    subProductList.clear();
    double total = 0.0;

    String locationId =
        await SharedPref.getStringPreference(Constants.LOCATION_ID) ?? "";

    String customer_ID =
        await SharedPref.getStringPreference(Constants.sp_CustomerId) ?? "";

    String mobileNumber =
        await SharedPref.getStringPreference(Constants.sp_MOBILE_NO) ?? "";
    List<Map<String, dynamic>> contentlist = [];
    for (int i = 0; i < widget.cartitesmList.length; i++) {
      var cartitemData = widget.cartitesmList[i];
      String productPrice = "0.0";
      if (cartitemData.specialPrice == null ||
          cartitemData.specialPrice == "null" ||
          cartitemData.specialPrice == "" ||
          cartitemData.specialPrice == "0" ||
          cartitemData.specialPrice == 0) {
        productPrice = cartitemData.price ?? "0.0";
        print("price   ${productPrice}");
      } else {
        productPrice = cartitemData.specialPrice.toString();
      }

      total = total +
          (double.parse(productPrice == "Free" ? "0.0" : productPrice) *
              cartitemData.addQuantity);
      if (productPrice != "Free") {
        contentlist.add({
          "index": i.toString(),
          "productID": cartitemData.productId,
          "productName": cartitemData.name,
          "product_id": cartitemData.productId,
          "name": cartitemData.name,
          "add_item": cartitemData.addQuantity,
          "image": cartitemData.image,
          "quantity": cartitemData.addQuantity,
          "model": cartitemData.model,
          "subtract": cartitemData.subtract,
          "message_on_card": cartitemData.messageOnCard,
          "message_on_cake": cartitemData.messageOnCake,
          "is_option": cartitemData.isOption,
          "special_price": cartitemData.specialPrice,
          "shipping_option": "",
          "shipping_charge": "",
          "gift_item": "",
          "option": cartitemData.options ?? [],
          "custom_msg": cartitemData.customMsg,
          "price": productPrice,
          "price_total": productPrice,
          "total": productPrice == "Free"
              ? total = total + (0 * cartitemData.addQuantity)
              : double.parse(productPrice) * cartitemData.addQuantity,
          "discount_label": cartitemData.discountLabel,
          "discount_text": cartitemData.discountText,
          "c_offer_id": cartitemData.cOfferId == null
              ? "0"
              : cartitemData.cOfferId.toString(),
          "offer_product_id": null,
          "offer_eligible": 0,
          "sub_product": cartitemData.subProduct ?? []
        });
      }
      if (productPrice == "Free") {
        offer_id = cartitemData.offer_id.toString();
        subProductList.add({
          "productID": cartitemData.productId,
          "offer_id": cartitemData.offer_id,
          "productName": cartitemData.name,
          "model": cartitemData.model,
          "quantity": cartitemData.quantity,
          "subtract": cartitemData.subtract,
          "price": productPrice,
          "total": productPrice,
          "mandatory": cartitemData.mandatory,
          "is_customer_offer": ""
        });
      }
      // }
    }
    var data = {
      "data": {
        "shipping": shippingCharge,
        "wallet_refund_amount": "0.00",
        "reward_refund_amount": "0.00",
        "order_id": orderId,
        "promo_wallet_used": 0,
        "campaign_id": "0",
        "customer_id": customer_ID,
        "payment_method": selectedPaymentGateway.paymentMethod,
        "payment_code": selectedPaymentGateway.paymentCode,
        "telephone": mobileNumber,
        "total": total,
        "order_status": "",
        "comment": order_placeFlow,
        "location_id": locationId,
        "contents": contentlist,
        "discount": "0",
        "order_offer_total": 0,
        "offer_product": [],
        "offer_id": ""
      }
    };
    ApiProvider().editOrderResponse(data, () {
      editOrderApi();
    }).then(
      (value) {
        SharedPref.setStringPreference(Constants.OrderidForEditOrder, "");
        SharedPref.setStringPreference(Constants.OrderPlaceFlow, "");
        if (value.success == true) {
          shrinkAnimation = null;
          _isAnimationEnd = false;
          saveOrderApiCalled = false;
          paymentOptionBloc.add(PaymentOptionInitialEvent());
          MyDialogs.commonDialog(
              context: context,
              actionTap: () {
                dbHelper.cleanCartDatabase().then(
                  (value) {
                    Navigator.pushReplacementNamed(context, Routes.home_page);
                  },
                );
              },
              titleText: value.message ?? "",
              actionText: "Continue Shopping");
        } else {
          shrinkAnimation = null;
          _isAnimationEnd = false;
          saveOrderApiCalled = false;

          paymentOptionBloc.add(PaymentOptionInitialEvent());
          Appwidgets.showToastMessage(value.message ?? "");
        }
      },
    );
  }

  getShippingCharges(int lineNumber) async {
    print("LINE NUMBER ${lineNumber}");
    bool value =
        await SharedPref.getBooleanPreference(Constants.locationupdate);
    print("LOCATION UPDATE VALUE ${value}");
    if (subtotal != 0) {
      ApiProvider().getShippingCharges(subtotal, 0, () {
        getShippingCharges(lineNumber);
      }).then((value) async {
        print("ROHIT SHIPPING CHARGE VAL ${value!.data.toString()}");
        if (value != null) {
          if (value.data.toString() == "null") {
            // shippingCharge = double.parse("0");
            // shippingCharge = double.parse(value.data.toString());
          } /*else {
          shippingCharge = double.parse(value.data! ?? "0");
        }*/

          if (value.data.toString() != "null") if (double.parse(value.data!) ==
              0) {
            isShowShipping = false;
            debugPrint("Shipping Charges Not Available ");
          } else {
            isShowShipping = true;
            shippingCharge = double.parse(value.data.toString());
            print("ROHIT SHIPPING CHARGE VAL ${value.data.toString()}");
            debugPrint("Shipping Charges " + shippingCharge.toString());
            // debugPrint("Shipping Charges GrandTotal" + grandtotal.toString());

            freeDeliveryAmount = double.parse(value.offer!.freeDeliveryAmount!);
          }
          payment_gateways = value.paymentGetway!;
          payment_gateways.forEach(
            (element) {
              if (element.paymentMethod == "Cash on delivery") {
                cod_PG = element;
              }
            },
          );
          grandtotal = subtotal + shippingCharge;
          debugPrint("Shipping Charges GrandTotal " + grandtotal.toString());
          checkoutBloc.add(CheckoutNullEvent());

          checkoutBloc.add(CheckoutShipingAmountEvent(
              isShow: isShowShipping,
              shippingCharges: shippingCharge,
              freeDeliveryAmount: freeDeliveryAmount));
        }
      });
      paymentOptionBloc.add(PaymentOptionAddressChangeEvent(
          selectedAddressData: selectedAddressData));
      // checkoutBloc.add(GetAddressEvent(street: street, locality: locality));
      _updateAddressData(addressData: selectedAddressData);
    }
  }

  void retrieveAddressList() async {
    String customerId =
        await SharedPref.getStringPreference(Constants.sp_CustomerId);

    await dbHelper.init();
    changeAddressBloc.add(FetchAddressLoadingEvent());
    if (await Network.isConnected()) {
      addressListResponse =
          await ApiProvider().getAddressListApi(customerId, "0", () async {
        retrieveAddressList();
      });
      if (addressListResponse.success == true) {
        txt_select_an_address = addressListResponse.txtSelectAnAddress ?? "";
        plsSelecteADdressTxt = addressListResponse.message ?? "";
        addressListFromAPi = addressListResponse.data!;

        if (addressListFromAPi.length == 1) {
          selectedAddressData = addressListFromAPi[0];
          paymentOptionBloc.add(PaymentOptionAddressChangeEvent(
              selectedAddressData: selectedAddressData));
        }
        isAddressIdempty();
      } else {
        addressListFromAPi = [];
      }
      changeAddressBloc.add(FetchAddressEvent(addressListFromAPi));
    } else {
      MyDialogs.showInternetDialog(context, () {});
    }
  }

  showAddressSheet() {
    if (_isDialogShowing) return;
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
        _isDialogShowing = true;
        return MediaQuery(
          data: Appwidgets().mediaqueryDataforWholeApp(context: context),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            bottomSheet: Container(
              decoration: BoxDecoration(
                color: ColorName.whiteSmokeColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  topLeft: Radius.circular(12),
                ),
              ),
              child: Wrap(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Text(
                      storeIDmatched
                          ? txt_select_an_address
                          : plsSelecteADdressTxt,
                      maxLines: 2,
                      style: Appwidgets()
                          .commonTextStyle(ColorName.black)
                          .copyWith(
                            fontSize: 16,
                            fontFamily: Fontconstants.fc_family_proxima,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Row(
                    children: [
                      // Appwidgets.lables("Select Address", 10, 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        child: Text(
                          "Saved Address",
                          style: Appwidgets()
                              .commonTextStyle(ColorName.black)
                              .copyWith(
                                fontSize: 18,
                                fontFamily: Fontconstants.fc_family_proxima,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.close,
                            color: ColorName.black,
                          )),
                      5.toSpace
                    ],
                  ),
                  Divider(
                    height: .5,
                  ),
                  ShowAddressWidget(),
                  Appwidgets.MyButton(
                    addressListResponse != null &&
                            addressListResponse.success == true
                        ? addressListResponse.txtAddAddress!
                        : "Add Address",
                    double.infinity,
                    () {
                      Navigator.pop(context);
                      addAddress();
                    },
                  ),
                  10.toSpace
                ],
              ),
            ),
          ),
        );
      },
      // pageBuilder: (context, animation, secondaryAnimation) {      },
    );
  }

  addAddress() async {
    String cityName = await SharedPref.getStringPreference(Constants.LOCALITY);
    print("CITY NAME ${cityName}");
    bool result = await showDialog(
          context: context,
          builder: (context) => UserLocationDialog(
              firstName: firstName,
              lastName: lastName,
              flat_Sector_apartMent: "",
              houseAddress: "",
              cityName: cityName.split(', ')[0],
              pinCode: "",
              landmark: "",
              // placeId: fetch.placeId,
              state: "",
              latitude: "$latitude",
              action: "Add",
              longitude: "$longitude",
              routeName: Routes.change_address,
              addresstype: "Home",
              addressID: ""),
        ) ??
        false;
    print("CITY NAME ${result}");
    if (result == true) {
      retrieveAddressList();
      showAddressSheet();
    }
    debugPrint("RESULT $result");
  }

  Widget ShowAddressWidget() {
    return SizedBox(
      height: screenHeight * .5,
      child: BlocBuilder(
        bloc: changeAddressBloc,
        builder: (context, state) {
          debugPrint("ADDRESS LIST ${state}");

          if (state is FetchAddressInitialState) {
            isLoading = false;
            retrieveAddressList();
          }
          if (state is FetchAddressLoadingState) {
            isLoading = true;
          }
          if (state is FetchAddressState) {
            isLoading = false;
            addressListFromAPi = state.addresslist;
          }
          if (state is SelectAddressState) {
            isLoading = false;
            selectedAddressData = state.addressData;
          }
          return isLoading
              ? Shimmerui.addressListUi(context, 80)
              : addressListFromAPi.isEmpty
                  ? Center(
                      child: Text(
                        "No Address Found",
                        style: Appwidgets()
                            .commonTextStyle(ColorName.black)
                            .copyWith(
                                fontWeight: FontWeight.w700, fontSize: 18),
                      ),
                    )
                  : ListView.separated(
                      separatorBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Divider(
                          height: .1,
                        ),
                      ),
                      shrinkWrap: true,
                      itemCount: addressListFromAPi.length,
                      itemBuilder: (context, index) => addressCard(
                          addressData: addressListFromAPi[index], index: index),
                    );
        },
      ),
    );
  }

  errorDialog(
      {required SaveOrdertoDatabaseResponse saveOrdertoDatabaseResponse}) {
    if (_isDialogShowing) return;

    _isDialogShowing = true;
    showDialog(
      context: context,

      builder: (context) {
        print(
            "saveOrdertoDatabaseResponse ${saveOrdertoDatabaseResponse.errorStatus}");
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: AlertDialog(

            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text(
              saveOrdertoDatabaseResponse.errorStatus == "3" ||
                      saveOrdertoDatabaseResponse.errorStatus == "6" ||
                      saveOrdertoDatabaseResponse.errorStatus == "8" ||
                      saveOrdertoDatabaseResponse.errorStatus == "9" ||
                      saveOrdertoDatabaseResponse.errorStatus == "10"
                  ? "Go Back to Cart"
                  : saveOrdertoDatabaseResponse.error ?? "",
              textAlign: TextAlign.center,
              style: Appwidgets()
                  .commonTextStyle(ColorName.black)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: saveOrdertoDatabaseResponse.errorStatus == "3" ||
                    saveOrdertoDatabaseResponse.errorStatus == "6" ||
                    saveOrdertoDatabaseResponse.errorStatus == "8" ||
                    saveOrdertoDatabaseResponse.errorStatus == "9" ||
                    saveOrdertoDatabaseResponse.errorStatus == "10"
                ? [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          saveOrdertoDatabaseResponse.errorStatus == "7"
                              ? "Change Date"
                              : saveOrdertoDatabaseResponse.errorStatus == "6"
                                  ? "Remove Product"
                                  : "Okay",
                          style: Appwidgets()
                              .commonTextStyle(ColorName.ColorBagroundPrimary),
                        ))
                  ]
                : saveOrdertoDatabaseResponse.errorStatus == "11"
                    ? [
                        ElevatedButton(
                            onPressed: () {
                              recent_check_passed = 1;
                              Navigator.pop(context);
                              paymentOptionBloc.add(PaymentOptionNullEvent());
                              saveOrderToDatabase(
                                  paymentMethod: selectedPaymentGateway);
                            },
                            child: Text(
                              "Yes",
                              style: Appwidgets().commonTextStyle(
                                  ColorName.ColorBagroundPrimary),
                            )),
                        ElevatedButton(
                            onPressed: () {
                              recent_check_passed = 0;
                              Navigator.pop(context);
                            },
                            child: Text(
                              "No",
                              style: Appwidgets().commonTextStyle(
                                  ColorName.ColorBagroundPrimary),
                            ))
                      ]
                    : [
                        ElevatedButton(
                            onPressed: () {
                              print(
                                  "SAVE ORDER TO DATABASE >>>  ${saveOrdertoDatabaseResponse.toJson()}");
                              if (saveOrdertoDatabaseResponse.errorStatus ==
                                  "7") {
                                Navigator.pop(context);
                                getTimeSlotDialog();
                              } else {
                                Navigator.pop(context);
                              }
                            },
                            child: Text(
                              saveOrdertoDatabaseResponse.errorStatus == "7"
                                  ? "Change Date"
                                  : saveOrdertoDatabaseResponse.errorStatus == "6"
                                      ? "Remove Product"
                                      : "Okay",
                              style: Appwidgets().commonTextStyle(
                                  ColorName.ColorBagroundPrimary),
                            ))
                      ],
          ),
        );
      },
    );
  }

  askProductRemoveDialog({required String productName}) {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Container(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: const Offset(0.0, 10.0),
                ),
              ],
            ),
            width: Sizeconfig.getWidth(context),
            height: 200,
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  child: Center(
                    child: Text(
                      "Alert",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 19,
                        fontFamily: Fontconstants.fc_family_sf,
                        fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Container(
                  child: Center(
                    child: Text(
                      "Are You Sure you want to remove this Item from the cart ??",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: Constants.SizeMidium,
                        fontFamily: Fontconstants.fc_family_sf,
                        fontWeight: Fontconstants.SF_Pro_Display_Medium,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                10.toSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () async {
                        for (var productUnit in widget.cartitesmList) {
                          print("Product Name ${productName}");
                          print("Product Name ${productUnit.name}");
                          if (productName == productUnit.name) {
                            print("Product Matched");
                            dbHelper
                                .deleteCard(int.parse(productUnit.productId!));

                            cardBloc.add(CardDeleteEvent(
                                model: productUnit,
                                listProduct: widget.cartitesmList));
                            dbHelper.loadAddCardProducts(cardBloc);
                            Navigator.pop(context);
                            if (order_placeFlow == "Order Edited") {
                              editOrderApi();
                            } else {
                              saveOrderToDatabase(
                                  paymentMethod: selectedPaymentGateway);
                            }
                            break;
                          }
                        }
                      },
                      child: Container(
                          width: Sizeconfig.getWidth(context) * 0.35,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              color: ColorName.ColorPrimary),
                          padding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: Center(
                              child: Text(
                            "Yes",
                            style: TextStyle(
                              fontFamily: Fontconstants.fc_family_sf,
                              fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
                            ),
                          ))),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    InkWell(
                      onTap: () async {
                        Navigator.pop(context);
                      },
                      child: Container(
                          width: Sizeconfig.getWidth(context) * 0.35,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              color: ColorName.aquaHazeColor),
                          padding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: Center(
                              child: Text(
                            "No",
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: Fontconstants.fc_family_sf,
                              fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
                            ),
                          ))),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String removeLastComma(String strng) {
    var n = strng.lastIndexOf(",");
    var a = strng.substring(0, n);
    return a;
  }

  Widget commonDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Divider(
        thickness: .4,
      ),
    );
  }

  String getIconPath({required String addressType}) {
    return addressType == "Work"
        ? Imageconstants.briefCaseIcon
        : addressType == "Other"
            ? Imageconstants.address_type_other
            : Imageconstants.home_icon;
  }

  Widget addressCard({required AddressData addressData, required int index}) {
    String userAddress = '';
    if (addressData.title == "" && addressData.subtitle == "") {
      userAddress = "${addressData.address1!} ${addressData.address2!}";
    } else {
      userAddress = "${addressData.title} ${addressData.subtitle}";
    }
    return GestureDetector(
      onTap: () async {
        addressChangeFunction(addressData: addressData);
      },
      child: Container(
        color: ColorName.whiteSmokeColor,
        // decoration: BoxDecoration(
        //     color: ColorName.ColorBagroundPrimary,
        //     borderRadius: BorderRadius.circular(5)),
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  // Imageconstants.briefCaseIcon,
                  getIconPath(addressType: addressData.addressType!),
                  height: 20,
                  width: 20,
                ),
                8.toSpace,
                Text(
                  (addressData.addressType == null ||
                          addressData.addressType == "")
                      ? "Home".toUpperCase()
                      : addressData.addressType!.toUpperCase(),
                  style: Appwidgets().commonTextStyle(Colors.black).copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: Constants.SizeMidium,
                      fontFamily: Fontconstants.fc_family_proxima),
                ),
                Spacer(),
                SizedBox(
                  // color: Colors.red,
                  width: 30,
                  height: 30,
                  child: Radio(
                    value:
                        selectedAddressData.addressId == addressData.addressId,
                    groupValue: true,
                    toggleable: true,
                    onChanged: (value) async {
                      addressChangeFunction(addressData: addressData);
                    },
                  ),
                ),
              ],
            ),
            addressData.flatSectorApartment == ""
                ? SizedBox.shrink()
                : Text(
                    "${addressData.flatSectorApartment}",
                    maxLines: 1,
                    style: Appwidgets()
                        .commonTextStyle(ColorName.black)
                        .copyWith(
                            fontWeight: Fontconstants.SF_Pro_Display_Regular,
                            fontSize: 15),
                  ),
            // Text(
            //   addressData.landmark!.toUpperCase(),
            //   overflow: TextOverflow.ellipsis,
            //   style: TextStyle(
            //       fontSize: 13,
            //       fontFamily: Fontconstants.fc_family_proxima,
            //       fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
            //       color: ColorName.black),
            // ),
            2.toSpace,
            SizedBox(
              width: Sizeconfig.getWidth(context) * .8,
              child: Text(
                userAddress,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: Constants.SizeSmall,
                    fontFamily: Fontconstants.fc_family_proxima,
                    fontWeight: Fontconstants.SF_Pro_Display_Regular,
                    color: ColorName.textlight),
              ),
            )
            // Row(
            //   children: [],
            // )
          ],
        ),
        // child: Row(
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   children: [
        //     Expanded(
        //       flex: 8,
        //       child: Column(
        //         mainAxisAlignment: MainAxisAlignment.spaceAround,
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: [
        //           Row(
        //             children: [
        //               Expanded(
        //                 flex: 9,
        //                 child: Container(
        //                   child: Text(
        //                     addressData.addressType!.toUpperCase(),
        //                     style: Appwidgets()
        //                         .commonTextStyle(Colors.black)
        //                         .copyWith(
        //                             fontWeight:
        //                                 Fontconstants.SF_Pro_Display_SEMIBOLD,
        //                             fontFamily: Fontconstants.fc_family_proxima),
        //                   ),
        //                 ),
        //               ),
        //               5.toSpace,
        //               Expanded(
        //                 flex: 3,
        //                 child: Row(
        //                   mainAxisAlignment: MainAxisAlignment.end,
        //                   children: [
        //                     GestureDetector(
        //                       onTap: () async {
        //                         print(
        //                             "addressData.flatSectorApartment  ${addressData.flatSectorApartment}");
        //                         var data = await showDialog(
        //                           context: context,
        //                           builder: (context) => UserLocationDialog(
        //                             flat_Sector_apartMent:
        //                                 addressData.flatSectorApartment ?? "",
        //                             addresstype: addressData.addressType ?? "",
        //                             houseAddress: addressData.address2!,
        //                             action: "Update",
        //                             cityName: addressData.city!,
        //                             pinCode: addressData.postcode!,
        //                             landmark: addressData.landmark!,
        //                             state: addressData.zone!,
        //                             latitude: "${addressData.latitude}",
        //                             longitude: "${addressData.longitude}",
        //                             routeName: Routes.change_address,
        //                             addressID: addressData.addressId!,
        //                           ),
        //                         );
        //                         if (data ==
        //                             "Thank You! <br> Your address updated sucessfully") {
        //                           retrieveAddressList();
        //                         }
        //                         // print("CHANGE ADDRESS SCREEN ${data}");
        //                       },
        //                       child: Image.asset(
        //                         Imageconstants.edit_icon,
        //                         height: 20,
        //                         width: 20,
        //                       ),
        //                     ),
        //                     15.toSpace,
        //                     GestureDetector(
        //                       onTap: () {
        //                         showDialog(
        //                           context: context,
        //                           builder: (context) => AlertDialog(
        //                             backgroundColor:
        //                                 ColorName.ColorBagroundPrimary,
        //                             shape: RoundedRectangleBorder(
        //                                 borderRadius: BorderRadius.circular(12)),
        //                             title: Text(
        //                               "Are you sure you want to delete this address ?",
        //                               style: Appwidgets()
        //                                   .commonTextStyle(ColorName.black),
        //                             ),
        //                             actions: [
        //                               GestureDetector(
        //                                   onTap: () async {
        //                                     if (await Network.isConnected()) {
        //                                       deleteAddressApi(
        //                                           addressData.addressId!);
        //                                     } else {
        //                                       MyDialogs.showInternetDialog(
        //                                           context, () {
        //                                         Navigator.pop(context);
        //                                       });
        //                                     }
        //                                   },
        //                                   child: Text("Yes",
        //                                       style: Appwidgets().commonTextStyle(
        //                                           ColorName.black))),
        //                               20.toSpace,
        //                               GestureDetector(
        //                                 onTap: () {
        //                                   Navigator.pop(context);
        //                                 },
        //                                 child: Text("No",
        //                                     style: Appwidgets().commonTextStyle(
        //                                         ColorName.black)),
        //                               ),
        //                             ],
        //                           ),
        //                         );
        //                       },
        //                       child: Image.asset(
        //                         Imageconstants.delete_icon,
        //                         height: 20,
        //                         width: 20,
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //               ),
        //             ],
        //           ),
        //           5.toSpace,
        //           Text(
        //             addressData.subtitle!,
        //             maxLines: 2,
        //             overflow: TextOverflow.ellipsis,
        //             style: TextStyle(
        //                 fontSize: Constants.SizeSmall,
        //                 fontFamily: Fontconstants.fc_family_proxima,
        //                 fontWeight: Fontconstants.SF_Pro_Display_Regular,
        //                 color: ColorName.textlight),
        //           )
        //         ],
        //       ),
        //     ),
        //     10.toSpace,
        //   ],
        // ),
      ),
    );
  }

  addressChangeFunction({required AddressData addressData}) async {
    print("INTIAL STORE ID ${selectedAddressData.storeId}");
    if (selectedAddressData.storeId != addressData.storeId) {
      await SharedPref.setBooleanPreference(Constants.locationupdate, true);
      selectedAddressData = addressData;
      _isDialogShowing = false;
      Navigator.pop(context, true);
      String storeid = await SharedPref.getStringPreference(Constants.STORE_ID);
      print("IS DIALOG SHOWING 1 ${storeid}");
      print("IS DIALOG SHOWING 1 ${selectedAddressData.storeId}");
      getTimeSlotsApi("3110");
      productValidationforCheckoutApi();
      // }
    } else {
      SharedPref.setBooleanPreference(Constants.locationupdate, false);
      String storeid = await SharedPref.getStringPreference(Constants.STORE_ID);
      selectedAddressData = addressData;
      print("STORE ID ${selectedAddressData.storeId}");
      // getTimeSlotsApi("3203");
      paymentOptionBloc.add(PaymentOptionAddressChangeEvent(
          selectedAddressData: selectedAddressData));
      Navigator.pop(context);
    }
    saveAddress();
    getTimeSlotsApi("3891");
  }

  productValidationforCheckoutApi() {
    ApiProvider().productValidationcheckout(
        widget.cartitesmList,
        selectedAddressData.storeId ?? "",
        selectedAddressData.storeName ?? "",
        selectedAddressData.wmsStoreId ?? "",
        selectedAddressData.locationId ?? "",
        selectedAddressData.storeCode ?? "", () {
      productValidationforCheckoutApi();
    }).then((value) {
      if (value != null && value != "") {
        var productValidationData = jsonDecode(value);
        log("productValidationData ${productValidationData['success']}");
        if (productValidationData['success'] == false) {
          final responseData = jsonDecode(value.toString());
          var change_address_message = responseData["change_address_message"];
          SharedPref.setBooleanPreference(Constants.locationupdate, true);
          MyDialogs.showAlertDialogNew(
              context, change_address_message, "Okay", "", () {
            loadLocationValidation(
              selectedAddressData.storeId ?? "",
              selectedAddressData.storeName ?? "",
              selectedAddressData.wmsStoreId ?? "",
              selectedAddressData.locationId ?? "",
              selectedAddressData.storeCode ?? "",
            );
            Navigator.pop(context);
          }, () {
            Navigator.pop(context);
          });

          // showDialog(
          //   context: context,
          //   barrierDismissible: false,
          //   builder: (context) => WillPopScope(
          //     onWillPop: () async {
          //       return false;
          //     },
          //     child: AlertDialog(
          //
          //       shape: RoundedRectangleBorder(
          //           borderRadius:
          //           BorderRadius.circular(
          //               12)),
          //       title: Text(
          //         "${change_address_message}",
          //         style: Appwidgets()
          //             .commonTextStyle(
          //             ColorName.black),
          //       ),
          //       actions: [
          //         GestureDetector(
          //             onTap: () async {
          //               loadLocationValidation(
          //                 selectedAddressData.storeId ?? "",
          //                 selectedAddressData.storeName??"",
          //                 selectedAddressData.wmsStoreId ?? "",
          //                 selectedAddressData.locationId ?? "",
          //                 selectedAddressData.storeCode ?? "",
          //               );
          //              Navigator.pop(context);
          //
          //             },
          //             child: Text("Yes",
          //                 style: Appwidgets()
          //                     .commonTextStyle(
          //                     ColorName
          //                         .ColorPrimary))),
          //
          //         GestureDetector(
          //             onTap: () async {
          //
          //               Navigator.pop(context);
          //
          //             },
          //             child: Text("No",
          //                 style: Appwidgets()
          //                     .commonTextStyle(
          //                     ColorName
          //                         .black))),
          //
          //
          //       ],
          //     ),
          //   ),
          // );
        }
      }
    });
  }

  Widget commonWidgetforPaymentOption({required Widget child}) {
    return Container(
      margin: EdgeInsets.only(/*top: 10,*/ right: 10, left: 10),
      decoration: BoxDecoration(
          color: ColorName.ColorBagroundPrimary,
          borderRadius: BorderRadius.circular(10)),
      child: child,
    );
  }

  Widget commonWidgetforPaymentMethods(
      {required PaymentGetway paymentGatewayData,
      required Function() onpress}) {
    print("PAYMENT METHOD ${paymentGatewayData.paymentMethod}");
    print("SELECTED PAYMENT METHOD ${selectedPaymentGateway.paymentMethod}");
    return GestureDetector(
      onTap: onpress,
      child: Container(
        decoration: BoxDecoration(
            color: ColorName.ColorBagroundPrimary,
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10))),
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            10.toSpace,
            paymentGatewayData.imageLocation != null &&
                    paymentGatewayData.imageLocation != ""
                ? CachedNetworkImage(
                    imageUrl: paymentGatewayData.imageLocation!,
                    // width: 60,
                    height: 20,
                    errorWidget: (context, url, error) =>
                        Image.asset(Imageconstants.ondoor_logo),
                    placeholder: (context, url) =>
                        Shimmerui.shimmerForProductImageWidget(
                            context: context, height: 20, width: 50),
                  )
                : Text(
                    (paymentGatewayData.paymentMethod ?? "")
                        .capitalizeByWord()
                        .toString(),
                    style: Appwidgets()
                        .commonTextStyle(ColorName.black)
                        .copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            fontFamily: Fontconstants.fc_family_proxima),
                  ),
            const Spacer(),
            Radio(
              value: paymentGatewayData.paymentMethod ==
                      selectedPaymentGateway.paymentMethod
                  ? true
                  : false,
              groupValue: true,
              toggleable: true,
              onChanged: (value) async {
                await SharedPref.setStringPreference(
                    Constants.selected_payment_Method,
                    paymentGatewayData.paymentMethod!);
                paymentOptionBloc.add(PaymentOptionSelectedEvent(
                    selectedPaymentGateway: paymentGatewayData));
              },
            ),
            10.toSpace
          ],
        ),
      ),
    );
  }

  getCocoApi(double latitude, double longitude, String cityName,
      String stateName) async {
    if (apiCalled == false) {
      apiCalled = true;
      paymentOptionBloc.add(PaymentOptionNullEvent());
      cocoCodeByLatLngResponse = await ApiProvider()
          .getCocoCodeByLatLngApi(latitude, longitude, cityName, stateName);

      if (cocoCodeByLatLngResponse!.success == true) {
        await SharedPref.setStringPreference(Constants.WMS_STORE_ID,
            cocoCodeByLatLngResponse!.data!.wmsStoreId!);
        await SharedPref.setStringPreference(
            Constants.STORE_CODE, cocoCodeByLatLngResponse!.data!.storeCode!);
        await SharedPref.setStringPreference(
            Constants.STORE_ID, cocoCodeByLatLngResponse!.data!.storeId!);
        await SharedPref.setStringPreference(
            Constants.STORE_Name, cocoCodeByLatLngResponse!.data!.storeName!);

        await SharedPref.setStringPreference(
            Constants.LOCATION_ID, cocoCodeByLatLngResponse!.data!.locationId!);
        await SharedPref.setdoublePreference(
            Constants.LOCATION_LAT, cocoCodeByLatLngResponse!.data!.inputLat!);
        await SharedPref.setdoublePreference(
            Constants.LOCATION_LONG, cocoCodeByLatLngResponse!.data!.inputLng);
        print(
            "selectedAddressData  cocoCodeByLatLngResponse ${cocoCodeByLatLngResponse!.data!.storeId}");

        getTimeSlotsApi("3669");
      }
    }
  }

  getTimeSlotsApi(String al) async {
    print("LOCALITY ${cocoCodeByLatLngResponse!.data!.cityName}");
    print("LOCALITY ${cocoCodeByLatLngResponse!.data!.locationId}");
    print("Location of Time SLot APi  $al");
    print("Street  $street");
    print("Locality  $locality");
    String addressId =
        await SharedPref.getStringPreference(Constants.ADDRESS_ID);
    String locationId =
        await SharedPref.getStringPreference(Constants.LOCATION_ID);
    String startDate = DateTime.now().toLocal().toString();
    getTimeSlotResponse = await ApiProvider().getTimeSlots(
        selectedAddressData.locationId ?? "",
        selectedAddressData.addressId ?? "",
        startDate, () {
      getTimeSlotsApi("4050");
    });

    if (getTimeSlotResponse.statusCode != null &&
        getTimeSlotResponse.success == true) {
      getShippingCharges(3957);
      if (getTimeSlotResponse.data != null &&
          getTimeSlotResponse.data!.isNotEmpty) {
        selectedDateSlot = getTimeSlotResponse.data![0].date ?? "Please Select";
        selectedDateSlotText =
            getTimeSlotResponse.data![0].selectDateText ?? "Please Select";
        if (getTimeSlotResponse.data![0].timeslots != null &&
            getTimeSlotResponse.data![0].timeslots!.isNotEmpty) {
          int index = getTimeSlotResponse.data![0].timeslots!.indexWhere(
            (element) => element.status == 1,
          );
          if (index > 0) {
            selectedTimeSlot =
                getTimeSlotResponse.data![0].timeslots![index].timeSlotText ??
                    "Please Select";
            checkoutBloc.add(TimeSlotSelectedEvent(
                selectedTimeSlot: selectedTimeSlot,
                selected_date_Text: selectedDateSlotText,
                selectedDateSlot: selectedDateSlot));
          } else {
            var selectedTimeSlot1 = await SharedPref.getStringPreference(
                Constants.selectedTimeSlot);
            if (selectedTimeSlot1 == "") {
              selectedTimeSlot = "Please Select";
              selectedDateSlotText = "Please Select Date";
            }
          }
        }
      }

      checkoutBloc.add(GetTimeSlotEvent(timeSlotResponse: getTimeSlotResponse));
    }
    if (getTimeSlotResponse.statusCode != null &&
        getTimeSlotResponse.statusText == "Unauthorized") {
      selectedTimeSlot = "Please Select Time";
      selectedDateSlot = "Please Select Date";
      selectedDateSlotText = "Please Select Date";
      checkoutBloc.add(GetTimeSlotEvent(timeSlotResponse: getTimeSlotResponse));
      _showLoginDialog(context);
    }
  }

  void _showLoginDialog(BuildContext context) {
    if (_isDialogShowing) return;
    animationController == AnimationController(vsync: this);

    _isDialogShowing = true;
    showModalBottomSheet(
      transitionAnimationController: animationController,
      useSafeArea: true,
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            Appwidgets.setStatusBarColor();
            return true;
          },
          child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: const LoginWidget()),
        );
      },
    );
  }

  loadLocationValidation(
    String store_id1,
    String store_name1,
    String wms_store_id1,
    String location_id1,
    String store_code1,
  ) {
    ApiProvider().locationproductValidation(widget.cartitesmList, store_id1,
        store_name1, wms_store_id1, location_id1, store_code1, () {
      loadLocationValidation(
          store_id1, store_name1, wms_store_id1, location_id1, store_code1);
    }).then((value) {
      debugPrint(
          "ONADDRESSCHANGE locationproductValidation ${selectedAddressData.toJson()}");
      debugPrint("ONADDRESSCHANGE locationproductValidation 2 ${value}");
      if (value != "") {
        LocationProductsModel locationProduucts =
            LocationProductsModel.fromJson(value.toString());

        if (locationProduucts.success == false) {
          debugPrint("ONADDRESSCHANGE result ${locationProduucts.toJson()}");
          MyDialogs.showLocationProductsDialog(context, locationProduucts,
              (updatelist) async {
            for (int i = 0; i < widget.cartitesmList.length; i++) {
              debugPrint("i******   ${widget.cartitesmList[i].name}");
              for (int j = 0; j < updatelist.length; j++) {
                debugPrint("j******   ${updatelist[j].name}");

                if (updatelist[j].outOfStock == "0" &&
                    updatelist[j].productId ==
                        widget.cartitesmList[i].productId) {
                  debugPrint("GCondition 1");
                  widget.cartitesmList[i].addQuantity =
                      int.parse(updatelist[j].qty ?? "0");
                  widget.cartitesmList[i].price = updatelist[j].price;
                  widget.cartitesmList[i].sortPrice = updatelist[j].newPrice;
                  widget.cartitesmList[i].specialPrice = updatelist[j].newPrice;
                  // widget.cartitesmList[i].specialPrice=updatelist[j];

                  debugPrint(
                      "Updatecart Items call ${widget.cartitesmList[i].toJson()}");

                  updateCard(widget.cartitesmList[i], i, widget.cartitesmList);
                } else if ((updatelist[j].outOfStock == "1" &&
                    updatelist[j].productId ==
                        widget.cartitesmList[i].productId)) {
                  saveAddress();
                  debugPrint("GCondition 2");
                  await dbHelper
                      .deleteCard(int.parse(widget.cartitesmList[i].productId!))
                      .then((value) {
                    routestoHomeOrLocation(context: context);
                  });
                }
              }
            }
          }, () async {
            saveAddress();

            await dbHelper.cleanCartDatabase().then((value) {
              dbHelper.loadAddCardProducts(cardBloc);

              routestoHomeOrLocation(context: context);
            });
          });
        } else {
          apiCalled = false;
          paymentOptionBloc.add(PaymentOptionNullEvent());
          saveAddress();
        }
      }
    });
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

    saveAddress();
    Navigator.of(context).pushReplacementNamed(Routes.home_page);
  }

  routestoHomeOrLocation({required BuildContext context}) async {
    street = await SharedPref.getStringPreference(Constants.ADDRESS);
    locality = await SharedPref.getStringPreference(Constants.LOCALITY);
    if (isAddressEmpty()) {
      Navigator.pushNamed(context, Routes.location_screen,
          arguments: Routes.checkoutscreen);
    } else {
      Navigator.pushReplacementNamed(context, Routes.home_page);
    }
  }

  saveAddress() {
    debugPrint("saveAddress call ${selectedAddressData.toJson()}");
    getCocoApi(
        double.parse(selectedAddressData.latitude ?? "0.0"),
        double.parse(selectedAddressData.longitude ?? "0.0"),
        selectedAddressData.city ?? "",
        selectedAddressData.zone ?? "");
    String title = "";
    if (selectedAddressData.title != null && selectedAddressData.title != "") {
      title = "${selectedAddressData.title!} ,";
    }
    if (selectedAddressData.subtitle != null &&
        selectedAddressData.subtitle != "") {
      street = title + selectedAddressData.subtitle!;
    }
    if ((selectedAddressData.title == null ||
            selectedAddressData.title == "") &&
        (selectedAddressData.subtitle == null ||
            selectedAddressData.subtitle == "")) {
      street =
          "${selectedAddressData.address1!} ${selectedAddressData.address2!}";
    }
    locality =
        "${selectedAddressData.city ?? ""}, ${selectedAddressData.zone ?? ""}";
    SharedPref.setStringPreference(Constants.SAVED_ADDRESS, street);
    SharedPref.setStringPreference(
        Constants.ADDRESS_ID, selectedAddressData.addressId ?? "");
    SharedPref.setStringPreference(
        Constants.SAVED_SUB_ADDRESS, selectedAddressData.address2 ?? "");
    SharedPref.setStringPreference(
        Constants.SAVED_LANDMARK, selectedAddressData.landmark ?? "");
    SharedPref.setStringPreference(
        Constants.PostalCode, selectedAddressData.postcode ?? "");
    SharedPref.setStringPreference(
        Constants.SAVED_STATE_ID, selectedAddressData.zoneId ?? "");
    SharedPref.setStringPreference(
        Constants.SELECTED_LOCATION_LAT, selectedAddressData.latitude ?? "");
    SharedPref.setStringPreference(
        Constants.SELECTED_ADDRESS_TYPE, selectedAddressData.addressType ?? "");
    SharedPref.setStringPreference(
        Constants.SELECTED_LOCATION_LONG, selectedAddressData.longitude ?? "");
    SharedPref.setStringPreference(
        Constants.SAVED_CITY, selectedAddressData.city ?? "");
    SharedPref.setStringPreference(
        Constants.SAVED_STATE, selectedAddressData.zone ?? "");
    SharedPref.setStringPreference(
        Constants.WMS_STORE_ID, selectedAddressData.wmsStoreId ?? "");
    SharedPref.setStringPreference(
        Constants.STORE_CODE, selectedAddressData.storeCode ?? "");
    SharedPref.setStringPreference(
        Constants.STORE_ID, selectedAddressData.storeId ?? "");
    SharedPref.setStringPreference(
        Constants.STORE_Name, selectedAddressData.storeName ?? "");
    SharedPref.setStringPreference(Constants.SAVED_FLatNumberAddress,
        selectedAddressData.flatSectorApartment ?? "");
    SharedPref.setStringPreference(
        Constants.AREA_DETAIL, selectedAddressData.areaDetail ?? "");
    SharedPref.setStringPreference(
        Constants.ADDRESS_1, selectedAddressData.address1 ?? "");
    SharedPref.setStringPreference(
        Constants.ADDRESS_2, selectedAddressData.address2 ?? "");
    SharedPref.setStringPreference(Constants.SELECTED_DELIVERY_ADDRESS,
        selectedAddressData.deliveryAddress ?? "");
    SharedPref.setStringPreference(
        Constants.LOCATION_ID, selectedAddressData.locationId ?? "");
    SharedPref.setdoublePreference(Constants.LOCATION_LAT,
        double.parse(selectedAddressData.latitude ?? ""));
    SharedPref.setdoublePreference(Constants.LOCATION_LONG,
        double.parse(selectedAddressData.longitude ?? ""));

    if (selectedAddressData.address1 != null &&
        selectedAddressData.address1!.trim().isNotEmpty) {
      SharedPref.setStringPreference(
          Constants.ADDRESS, selectedAddressData.address1 ?? "");
    } else if (selectedAddressData.address2 != null &&
        selectedAddressData.address2!.trim().isNotEmpty) {
      SharedPref.setStringPreference(
          Constants.ADDRESS, selectedAddressData.address2 ?? "");
    }
    SharedPref.setStringPreference(Constants.LOCALITY,
        "${selectedAddressData.city ?? ""}, ${selectedAddressData.zone ?? ""}");
  }

  void getTimeSlotDialog() async {
    if (getTimeSlotResponse.data != null &&
        getTimeSlotResponse.data!.isNotEmpty) {
      var selectedTimeSlot = await showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: SelectTimeSlotDialog(
              getTimeSlotResponse: getTimeSlotResponse,
            ),
          );
        },
      );
      if (selectedTimeSlot != null) {
        await SharedPref.setStringPreference(
            Constants.selectedTimeSlot, selectedTimeSlot['selected_Time']);
        await SharedPref.setStringPreference(
            Constants.selectedDateSlot, selectedTimeSlot['selected_Time']);
        await SharedPref.setStringPreference(Constants.selected_date_Text,
            selectedTimeSlot['selected_Date_Text']);
        log("SELECTED TIME SLOT ${selectedTimeSlot as Map}");
        checkoutBloc.add(TimeSlotSelectedEvent(
            selectedTimeSlot: selectedTimeSlot['selected_Time'],
            selectedDateSlot: selectedTimeSlot['selected_date'],
            selected_date_Text: selectedTimeSlot['selected_Date_Text']));
      }
    } else {
      getTimeSlotsApi("4336");
    }
  }

  upipaymentMethode() async {
    final res = await EasyUpiPaymentPlatform.instance.startPayment(
      EasyUpiPaymentModel(
        payeeVpa: 'gaurav.jajoo@upi',
        payeeName: 'Gaurav Jajoo',
        amount: 1.0,
        description: 'Testing payment',
      ),
    );
    // TODO: add your success logic here
    print(res);
  }

  void showRateUsBottomSheet() {
    if (_isDialogShowing) return;
    _isDialogShowing = true;
    upipaymentMethode();
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
          );
        }).then((value) {
      debugPrint("Colse Bottom View $value");
    });
  }
}
