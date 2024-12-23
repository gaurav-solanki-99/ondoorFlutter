import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:developer';
// import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ondoor/constants/Constant.dart';
import 'package:ondoor/constants/FontConstants.dart';
import 'package:ondoor/constants/StringConstats.dart';
import 'package:ondoor/database/database_helper.dart';
import 'package:ondoor/main.dart';
import 'package:ondoor/models/MyAddress.dart';
import 'package:ondoor/models/geo_coder_response.dart';
import 'package:ondoor/screens/location_screen/location_bloc/location_event.dart';
import 'package:ondoor/screens/location_screen/location_bloc/location_state.dart';
import 'package:ondoor/utils/Connection.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/sharedpref.dart';
import 'package:ondoor/widgets/AppWidgets.dart';
import 'package:ondoor/widgets/MyDialogs.dart';
import 'package:path/path.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:uuid/uuid.dart';
import '../../../constants/ImageConstants.dart';
import '../../../database/dbconstants.dart';
import '../../../models/AllProducts.dart';
import '../../../models/address_list_response.dart';
import '../../../models/geo_data.dart';
import '../../../models/get_coco_code_response.dart';
import '../../../models/locationvalidationmodel.dart';
import '../../../services/ApiServices.dart';
import '../../../services/Navigation/routes.dart';
import '../../../utils/colors.dart';
import '../../../utils/themeData.dart';
import '../../../widgets/user_location_dialog.dart';
import '../../AddCard/card_bloc.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  GoogleMapController? mapController;
  Completer<GoogleMapController> mapControllerCompleter = Completer();
  String userCurrentAddress = "";
  String placeId = "";
  String street = "";
  String postalCode = "";
  String landMark = "";
  String userState = "";
  String coustomerId = '';
  String token = ' ';
  String access_token = '';
  String token_type = '';
  bool settingSavedaddress = false;
  double latitude = 0.0;
  double longitude = 0.0;
  double ZOOM_CONSTANT = 8.2;
  bool searchingOn = false;
  bool shouldIAnimate = true;
  FocusNode focusNode = FocusNode(canRequestFocus: true);
  var usercity = "";
  List<MyAddress> list = [];
  bool hasPermission = false;
  bool isFocus = false;
  bool initialStage = true;
  bool isuserAtCurrentPosition = false;
  bool isLocationServiceEnabled = false;
  bool noLocationFoundError = false;
  AddressData selectedAddressData = AddressData();

  TextEditingController searchController = TextEditingController();
  var uuid = const Uuid();
  List<dynamic> placeList = [];
  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();
  // 24.3645059,78.061459
  LatLng bhopalLocation = const LatLng(23.240971520584846, 77.41411498238797);
  CameraPosition userCurrentCameraPosition = CameraPosition(
      target: LatLng(23.240971520584846, 77.41411498238797), zoom: 2);

  LocationBloc() : super(LocationInitialState()) {
    on<CurrentLocationEvent>((event, emit) {
      emit(MapLoadingState());
      emit(CurrentLocationState(event.cameraPosition));
    });
    on<MapLoadingEvent>(
      (event, emit) => emit(MapLoadingState()),
    );
    on<LocationInitialEvent>(
      (event, emit) => emit(LocationInitialState()),
    );
    on<LocationUserLoginEvent>(
      (event, emit) {
        // emit(LocationNullState());
        emit(LocationUserLoginState(isLogin: event.isLogin));
      },
    );
    on<LocationNullEvent>(
      (event, emit) => emit(LocationNullState()),
    );
    on<LocationNullEvent2>(
      (event, emit) => emit(LocationNullState2()),
    );
    on<SearchingPlacesEvent>(
      (event, emit) {
        emit(MapLoadingState());
        emit(SearchingPlacesState(
            searchingOn: event.searchingOn, prediction: event.prediction));
      },
    );
    on<GetCocoCodeEvent>(
      (event, emit) => emit(GetCocoCodeState()),
    );
    on<NoLocationFoundEvent>(
      (event, emit) {
        emit(LocationNullState2());
        emit(NoLocationFoundState(event.noLocationFoundText));
      },
    );
    on<CurrentLocationErrorEvent>(
      (event, emit) {
        emit(LocationNullState2());
        (event, emit) => emit(CurrentLocationErrorState(event.error));
      },
    );
    on<NoInternetEvent>(
      (event, emit) {
        emit(LocationNullState2());

        emit(NoInternetState());
      },
    );
  }

  void oncameraMove(position) {
    userCurrentAddress = '';

    userCurrentCameraPosition = position;
  }

  void onMapCreated() {
    if (!mapControllerCompleter.isCompleted) {
      mapControllerCompleter.complete(mapController);
    }
  }

  void onCameraIdle() async {
    if (mapController == null) return;

    latitude = userCurrentCameraPosition.target.latitude;
    longitude = userCurrentCameraPosition.target.longitude;
    if (userCurrentCameraPosition.zoom <= ZOOM_CONSTANT) {
      userCurrentAddress = "";
      userState = "";
    } else {
      setALlData();
    }
  }

  void setALlData() async {
    if (await Network.isConnected()) {
      var fetchGeocoder = await fetchData(latitude, longitude);
      String cityName = fetchGeocoder.city.replaceAll("Division", '');
      String stateName = fetchGeocoder.state;
      String country = fetchGeocoder.country;
      String streetNumber = fetchGeocoder.streetNumber;
      String postalcode = fetchGeocoder.postalCode;
      placeId = fetchGeocoder.placeId;
      userCurrentAddress = fetchGeocoder.address;
      debugPrint("USER FULL ADDRESS ${userCurrentAddress}");
      debugPrint("USER FULL ADDRESS ${stateName}");
      debugPrint("USER FULL ADDRESS ${country}");
      debugPrint("USER FULL ADDRESS ${streetNumber}");
      debugPrint("USER FULL ADDRESS ${postalCode}");
      debugPrint("USER FULL ADDRESS ${cityName}");
      if (userCurrentAddress.length >= 2) {
        landMark =
            "${userCurrentAddress.split(', ')[0]}, ${userCurrentAddress.split(', ')[1]}";
      }

      userCurrentAddress = userCurrentAddress.replaceAll(stateName, "");
      userCurrentAddress = userCurrentAddress.replaceAll(country, "");
      userCurrentAddress = userCurrentAddress.replaceAll(streetNumber, "");
      userCurrentAddress = userCurrentAddress.replaceAll(postalCode, "");
      userCurrentAddress = userCurrentAddress.replaceAll(cityName, "");
      userCurrentAddress = userCurrentAddress.trim();
      userCurrentAddress = userCurrentAddress.replaceAll(",  ", '');
      userCurrentAddress = userCurrentAddress.replaceAll("  ,", '');
      userCurrentAddress = userCurrentAddress.replaceAll(", ,", '');
      userCurrentAddress =
          userCurrentAddress.replaceAll(RegExp(r'^,+|,+$'), '');
      userCurrentAddress = userCurrentAddress.replaceAll(
          RegExp(r'\s+'), ' '); // Replace multiple spaces with single space
      if (userCurrentAddress.startsWith(", ")) {
        userCurrentAddress = userCurrentAddress.replaceFirst(', ', '');
      }
      // userCurrentAddress = removeInitialCode(userCurrentAddress);

      usercity = cityName;
      userState = stateName;
      postalCode = postalcode;
      debugPrint("USER FINAL ADDRESS ${userCurrentAddress}");
      // landMark = userCurrentAddress.split(', ')[0];

      add(CurrentLocationEvent(userCurrentCameraPosition));
    } else {
      add(NoInternetEvent());
    }
  }

  Future<bool> handleLocationPermission(context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    isLocationServiceEnabled = serviceEnabled;
    if (!serviceEnabled) {
      add(CurrentLocationErrorEvent(StringContants.LOCATION_SERVICE_DISABLED));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        add(CurrentLocationErrorEvent(
            StringContants.LOCATION_PERMISSION_DENIED));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (state is! CurrentLocationErrorState) {
        add(CurrentLocationErrorEvent(
            StringContants.LOCATION_PERMISSION_PERMANENTLY_DENIED));
        return false;
      }
    }
    add(LocationInitialEvent());
    return true;
  }

  String removeInitialCode(String address) {
    String regexPattern =
        r"^[^,]+,\s"; // Regex pattern to match the initial code

    RegExp regExp = RegExp(regexPattern);
    return address.replaceFirst(regExp, '');
  }

  locationValidation(
      BuildContext context,
      String store_id1,
      String store_name1,
      String wms_store_id1,
      String location_id1,
      String store_code1,
      double lat,
      double long,
      GetCocoCodeByLatLngResponse response) async {
    CardBloc cardBloc = CardBloc();
    DatabaseHelper dbHelper = DatabaseHelper();
    await dbHelper.init();
    List<ProductUnit> cartlist = await dbHelper.getAllCarts(cardBloc);

    debugPrint("Load Data GGG ${cartlist.length}");

    // String location_id = await SharedPref.getStringPreference(Constants.LOCATION_ID);
    // String coustomerId = await SharedPref.getStringPreference(Constants.sp_CustomerId);
    // String token_type = await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
    // String access_token = await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);
    // String store_id = await SharedPref.getStringPreference(Constants.STORE_ID);
    // String store_code = await SharedPref.getStringPreference(Constants.STORE_CODE);
    // String store_name = await SharedPref.getStringPreference(Constants.STORE_Name);
    // String wms_store_id = await SharedPref.getStringPreference(Constants.WMS_STORE_ID);

    if (cartlist.length == 0) {
      sendHomescree(context, lat, long, response);
    } else {
      loadLocationValidation(
          store_id1 ?? "",
          store_name1 ?? "",
          wms_store_id1 ?? "",
          location_id1 ?? "",
          store_code1 ?? "",
          cartlist,
          dbHelper,
          context,
          lat,
          long,
          response);
    }

    //ApiProvider()
    //     .productValidationcheckout(cartlist,
    //   store_id ?? "",
    //   store_name??"",
    //   wms_store_id ?? "",
    //   location_id?? "",
    //   store_code ?? "",
    //
    // )
    //     .then((value) {
    //   if (value != "") {
    //     if (value
    //         .toString()
    //         .contains("change_address_message")) {
    //       final responseData =
    //       jsonDecode(value.toString());
    //       var  change_address_message = responseData["change_address_message"];
    //       debugPrint("change_address_message ${change_address_message}");
    //
    //
    //       MyDialogs.showAlertDialog(context, change_address_message, "Yes", "No", (){
    //
    //         loadLocationValidation(
    //           store_id ?? "",
    //           store_name??"",
    //           wms_store_id ?? "",
    //           location_id?? "",
    //           store_code ?? "",
    //           cartlist
    //         );
    //         Navigator.pop(context);
    //       }, (){
    //         Navigator.pop(context);
    //       });
    //
    //       // showDialog(
    //       //   context: context,
    //       //   barrierDismissible: false,
    //       //   builder: (context) => WillPopScope(
    //       //     onWillPop: () async {
    //       //       return false;
    //       //     },
    //       //     child: AlertDialog(
    //       //
    //       //       shape: RoundedRectangleBorder(
    //       //           borderRadius:
    //       //           BorderRadius.circular(
    //       //               12)),
    //       //       title: Text(
    //       //         "${change_address_message}",
    //       //         style: Appwidgets()
    //       //             .commonTextStyle(
    //       //             ColorName.black),
    //       //       ),
    //       //       actions: [
    //       //         GestureDetector(
    //       //             onTap: () async {
    //       //               loadLocationValidation(
    //       //                 selectedAddressData.storeId ?? "",
    //       //                 selectedAddressData.storeName??"",
    //       //                 selectedAddressData.wmsStoreId ?? "",
    //       //                 selectedAddressData.locationId ?? "",
    //       //                 selectedAddressData.storeCode ?? "",
    //       //               );
    //       //              Navigator.pop(context);
    //       //
    //       //             },
    //       //             child: Text("Yes",
    //       //                 style: Appwidgets()
    //       //                     .commonTextStyle(
    //       //                     ColorName
    //       //                         .ColorPrimary))),
    //       //
    //       //         GestureDetector(
    //       //             onTap: () async {
    //       //
    //       //               Navigator.pop(context);
    //       //
    //       //             },
    //       //             child: Text("No",
    //       //                 style: Appwidgets()
    //       //                     .commonTextStyle(
    //       //                     ColorName
    //       //                         .black))),
    //       //
    //       //
    //       //       ],
    //       //     ),
    //       //   ),
    //       // );
    //     }
    //
    //
    //   }
    // });
  }

  sendHomescree(BuildContext context1, double lat, double long,
      GetCocoCodeByLatLngResponse response) async {
    await SharedPref.setStringPreference(
        Constants.WMS_STORE_ID, response.data!.wmsStoreId!);
    await SharedPref.setStringPreference(
        Constants.STORE_CODE, response.data!.storeCode!);
    await SharedPref.setStringPreference(
        Constants.STORE_ID, response.data!.storeId!);
    await SharedPref.setStringPreference(
        Constants.STORE_Name, response.data!.storeName!);

    await SharedPref.setStringPreference(
        Constants.LOCATION_ID, response.data!.locationId!);
    await SharedPref.setdoublePreference(Constants.LOCATION_LAT, lat);
    await SharedPref.setdoublePreference(Constants.LOCATION_LONG, long);

    if (street.trim().isNotEmpty &&
        usercity.trim().isNotEmpty &&
        userState.trim().isNotEmpty) {
      if (settingSavedaddress) {
        // selectedAddressData.addressId =
        await SharedPref.setStringPreference(
            Constants.ADDRESS_ID, selectedAddressData.addressId ?? "");
        // selectedAddressData.addressType =
        await SharedPref.setStringPreference(Constants.SELECTED_ADDRESS_TYPE,
            selectedAddressData.addressType ?? "");
        // selectedAddressData.locationId =
        await SharedPref.setStringPreference(
            Constants.LOCATION_ID, selectedAddressData.locationId ?? "");
        // selectedAddressData.wmsStoreId =
        await SharedPref.setStringPreference(
            Constants.WMS_STORE_ID, selectedAddressData.wmsStoreId ?? "");
        // selectedAddressData.storeCode =
        await SharedPref.setStringPreference(
            Constants.STORE_CODE, selectedAddressData.storeCode ?? "");
        // selectedAddressData.storeName =
        await SharedPref.setStringPreference(
            Constants.STORE_Name, selectedAddressData.storeName ?? "");
        // selectedAddressData.storeId =
        await SharedPref.setStringPreference(
            Constants.STORE_ID, selectedAddressData.storeId ?? "");
        // selectedAddressData.flatSectorApartment =
        await SharedPref.setStringPreference(Constants.SAVED_FLatNumberAddress,
            selectedAddressData.flatSectorApartment ?? "");
        // selectedAddressData.postcode =
        await SharedPref.setStringPreference(
            Constants.PostalCode, selectedAddressData.postcode ?? "");
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
        await SharedPref.setStringPreference(Constants.SAVED_ADDRESS, street);
        await SharedPref.setStringPreference(
            Constants.AREA_DETAIL, selectedAddressData.areaDetail ?? "");
        await SharedPref.setStringPreference(
            Constants.SAVED_CITY, selectedAddressData.city ?? "");
        await SharedPref.setStringPreference(
            Constants.SAVED_STATE, selectedAddressData.zone ?? "");
        SharedPref.setStringPreference(Constants.SELECTED_DELIVERY_ADDRESS,
            selectedAddressData.deliveryAddress ?? "");

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
        SharedPref.setStringPreference(
            Constants.ADDRESS_1, selectedAddressData.address1 ?? "");
        SharedPref.setStringPreference(
            Constants.ADDRESS_2, selectedAddressData.address2 ?? "");
        // if (selectedAddressData.addressId != null &&
        //     selectedAddressData.addressId != "null" &&
        //     selectedAddressData.addressId != "") {
        //   await SharedPref.setStringPreference(
        //       Constants.ADDRESS_ID, selectedAddressData.addressId ?? "");
        // }
        // if (selectedAddressData.zone != null &&
        //     selectedAddressData.zone != "null" &&
        //     selectedAddressData.zone != "") {
        //   await SharedPref.setStringPreference(
        //       Constants.SAVED_STATE, selectedAddressData.zone ?? "");
        // }
        // if (selectedAddressData.city != null &&
        //     selectedAddressData.city != "null" &&
        //     selectedAddressData.city != "") {
        //   await SharedPref.setStringPreference(
        //       Constants.SAVED_CITY, selectedAddressData.city ?? "");
        // }
        // if (selectedAddressData.flatSectorApartment != null &&
        //     selectedAddressData.flatSectorApartment != "null" &&
        //     selectedAddressData.flatSectorApartment != "") {
        //   await SharedPref.setStringPreference(
        //       Constants.SAVED_FLatNumberAddress,
        //       selectedAddressData.flatSectorApartment ?? "");
        // }
        //
        // await SharedPref.setStringPreference(
        //     Constants.SELECTED_LOCATION_LAT, lat.toString());
        // await SharedPref.setStringPreference(
        //     Constants.SELECTED_LOCATION_LONG, long.toString());
      } else {
        await SharedPref.setStringPreference(Constants.ADDRESS_ID, "");
        // selectedAddressData.addressType =
        await SharedPref.setStringPreference(
            Constants.SELECTED_ADDRESS_TYPE, "");
        // selectedAddressData.flatSectorApartment =
        await SharedPref.setStringPreference(
            Constants.SAVED_FLatNumberAddress, "");
        // selectedAddressData.postcode =
        await SharedPref.setStringPreference(Constants.PostalCode, "");
        await SharedPref.setStringPreference(Constants.SAVED_ADDRESS, "");
        await SharedPref.setStringPreference(Constants.SAVED_ADDRESS, "");
        await SharedPref.setStringPreference(Constants.SAVED_CITY, "");
        await SharedPref.setStringPreference(Constants.SAVED_STATE, "");
        await SharedPref.setStringPreference(
            Constants.SELECTED_LOCATION_LAT, lat.toString());
        await SharedPref.setStringPreference(
            Constants.SELECTED_LOCATION_LONG, long.toString());
        SharedPref.setStringPreference(Constants.ADDRESS, street);
        SharedPref.setStringPreference(
            Constants.LOCALITY, "$usercity, $userState");
      }
      initialStage = false;
      Navigator.of(navigationService.navigatorKey.currentContext!)
          .pushReplacementNamed(Routes.home_page);
    } else {
      getCurrentPosition(context);
      debugPrint("STREETEMPTY ${street.trim()}");
      debugPrint("CITYEMPTY ${usercity.trim()}");
      debugPrint("STATEEMPTY ${userState.trim()}");
    }
  }

  loadLocationValidation(
      String store_id1,
      String store_name1,
      String wms_store_id1,
      String location_id1,
      String store_code1,
      List<ProductUnit> cartitesmList,
      DatabaseHelper dbHelper,
      BuildContext context,
      double lat,
      double long,
      GetCocoCodeByLatLngResponse response) {
    ApiProvider().locationproductValidation(cartitesmList, store_id1,
        store_name1, wms_store_id1, location_id1, store_code1, () {
      loadLocationValidation(
          store_id1,
          store_name1,
          wms_store_id1,
          location_id1,
          store_code1,
          cartitesmList,
          dbHelper,
          context,
          lat,
          long,
          response);
    }).then((value) {
      debugPrint("ONADDRESSCHANGE locationproductValidation 1 $value");

      if (value != null && value != "") {
        LocationProductsModel locationProduucts =
            LocationProductsModel.fromJson(value.toString());

        if (locationProduucts.success == false) {
          debugPrint("ONADDRESSCHANGE result ${locationProduucts.toJson()}");

          MyDialogs.showLocationProductsDialog(context, locationProduucts,
              (updatelist) async {
            for (int i = 0; i < cartitesmList.length; i++) {
              debugPrint("i******   ${cartitesmList[i].name}");
              for (int j = 0; j < updatelist.length; j++) {
                debugPrint("j******   ${updatelist[j].name}");
                debugPrint("j******GG   ${updatelist[j].toJson()}");

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

                  //   Navigator.pop(context);
                  updateCard(cartitesmList[i], i, cartitesmList, dbHelper,
                      context, lat, long, response);
                } else if ((updatelist[j].outOfStock == "1" &&
                    updatelist[j].productId == cartitesmList[i].productId)) {
                  debugPrint("GCondition 2");
                  await dbHelper
                      .deleteCard(int.parse(cartitesmList[i].productId!))
                      .then((value) {
                    //  Navigator.of(context).pushReplacementNamed(Routes.home_page);

                    sendHomescree(context, lat, long, response);
                  });
                }
              }
            }
          }, () async {
            await dbHelper.cleanCartDatabase().then((value) {
              // dbHelper
              //     .loadAddCardProducts(
              //     cardBloc);

              sendHomescree(context, lat, long, response);
            });
          });
        } else {
          sendHomescree(context, lat, long, response);
        }
      }
    });
  }

  updateCard(
      ProductUnit model,
      int index,
      var list,
      DatabaseHelper dbHelper,
      BuildContext context,
      double lat,
      double long,
      GetCocoCodeByLatLngResponse response) async {
    int status = await dbHelper.updateCard({
      DBConstants.PRODUCT_ID: int.parse(model.productId!),
      DBConstants.QUANTITY: model.addQuantity,
      DBConstants.PRICE: model.price,
      DBConstants.SORT_PRICE: model.sortPrice,
      DBConstants.SPECIAL_PRICE: model.specialPrice,
    });

    debugPrint("Update Product Status $status");

    //  Navigator.pop(context);
    sendHomescree(context, lat, long, response);
  }

  void useThisLocation(context) async {
    // userCurrentAddress = removeInitialCode(userCurrentAddress);

    street = userCurrentAddress;
    street = street.replaceAll(RegExp(r'^,+|,+$'), "");
    if (street != "" || usercity != "" || userState != "") {
      debugPrint("userthisLOcation ${street}");
      debugPrint("useThisLocation ${usercity}");
      debugPrint("Usethislocation ${userState}");
      double lat = userCurrentCameraPosition.target.latitude;
      double long = userCurrentCameraPosition.target.longitude;
      debugPrint("LATITUDE ${lat} LONGITUDE :- ${long}");
      if (await Network.isConnected()) {
        add(GetCocoCodeEvent());
        var response = await ApiProvider()
            .getCocoCodeByLatLngApi(lat, long, usercity, userState);
        debugPrint(
            "COCOC DETAILS ${lat},, ${lat},, ${usercity},, ${userState},, ${response.data!.locationId},,");

        debugPrint("useThisLocation** 1  $response");
        // debugPrint("LOCATION ID +_+_+_+_+_>>  ${response.data!.locationId!}");

        if (response.success) {
          debugPrint("useThisLocation** 3 ");

          if (street.trim().isNotEmpty &&
              usercity.trim().isNotEmpty &&
              userState.trim().isNotEmpty) {
            debugPrint("useThisLocation** 2 $response");
            SharedPref.setStringPreference(Constants.ADDRESS, street);
            SharedPref.setStringPreference(
                Constants.LOCALITY, "$usercity, $userState");
          }
          // SharedPref.setStringPreference(Constants.WMS_STORE_ID, response.data!.wmsStoreId!);
          // SharedPref.setStringPreference(Constants.STORE_CODE, response.data!.storeCode!);
          // SharedPref.setStringPreference(Constants.STORE_ID, response.data!.storeId!);
          // SharedPref.setStringPreference(Constants.STORE_Name, response.data!.storeName!);
          //
          // SharedPref.setStringPreference(Constants.LOCATION_ID, response.data!.locationId!);
          // SharedPref.setdoublePreference(Constants.LOCATION_LAT, lat);
          // SharedPref.setdoublePreference(Constants.LOCATION_LONG, long);
          noLocationFoundError = false;

          var checkCreditWithoutLogin = await ApiProvider()
              .checkCreditRequestWithoutLogin(response.data!.locationId!,
                  response.data!.storeCode!, response.data!.storeId!);

          debugPrint("GGGLocation");
          locationValidation(
              context,
              response.data!.storeId!,
              response.data!.storeName!,
              response.data!.wmsStoreId!,
              response.data!.locationId!,
              response.data!.storeCode!,
              lat,
              long,
              response);
          //
          // if (checkCreditWithoutLogin.success == true) {
          //
          //
          //
          //   locationValidation(context);
          //
          //
          //   // Navigator.of(context).pushReplacementNamed(Routes.home_page);
          // } else {
          //   debugPrint("object");
          // }
        } else if (response.message ==
            "We are not providing service in your area.") {
          initialStage = false;
          debugPrint("useThisLocation** 4 ");
          noLocationFoundError = true;
          OndoorThemeData.keyBordDow();
          add(NoLocationFoundEvent(response.message));
        } else {
          initialStage = false;
          debugPrint("Response ${response.message}");
          if (isFocus) {
            // OndoorThemeData.keyBordDow();
            add(NoLocationFoundEvent(response.message));
          } else {
            add(NoLocationFoundEvent(response.message));
          }
        }
      } else {
        debugPrint("useThisLocation** 5 ");
        MyDialogs.showInternetDialog(context, () {
          Navigator.pop(context);
          useThisLocation(context);
        });
      }
    } else {
      debugPrint("useThisLocation** 4 ");
      Appwidgets.showToastMessage("Fetching Location...");
      debugPrint("ROhit 571 bloc");
      getCurrentPosition(context);
    }
  }

  Future<GeoData> fetchData(double latitude, double longitude) async {
    // Replace with your Google Geocoding API key
    const String apiKey = Constants.API_KEY;
    const String language = 'en';

    final Dio dio = Dio();
    const String url = 'https://maps.googleapis.com/maps/api/geocode/json';

    try {
      final response = await dio.get(
        url,
        queryParameters: {
          'latlng': '$latitude,$longitude',
          'key': apiKey,
          'language': language,
        },
      );
      dio.interceptors.add(PrettyDioLogger());
      // Handle response data
      if (response.statusCode == 200) {
        final fetch = FetchGeocoder.fromJson(response.data);
        final results = fetch.results;
        debugPrint(
            'LATTITUDE $latitude,LONGITUDE $longitude ${results.length}');
        if (results.isNotEmpty) {
          final addressComponents = results.first.addressComponents;

          String city = "";
          String country = "";
          String postalCode = "";
          String subLocality = "";
          String placeId = "";
          String state = "";
          String streetNumber = "";
          String countryCode = "";
          for (var component in addressComponents) {
            List<String> types = component.types;

            if (types.contains("administrative_area_level_3")) {
              city = component.longName ?? "";
            }
            if (types.contains("sublocality_level_1")) {
              subLocality = component.longName ?? "";
            }
            if (types.contains("country")) {
              country = component.longName ?? "";
              countryCode = component.shortName ?? "";
            }
            if (types.contains("postal_code")) {
              postalCode = component.longName ?? "";
            }
            if (types.contains("administrative_area_level_1")) {
              state = component.longName ?? "";
            }
            if (types.contains("street_number")) {
              streetNumber = component.longName ?? "";
            }
          }
          debugPrint(
              "ADDRESS COMPONENTS ${jsonEncode(fetch.results.first.addressComponents)}");
          debugPrint(
              "FOORMATTED ADDRESS ${fetch.results.first.formattedAddress}");
          debugPrint(
              "FOORMATTED ADDRESS ${fetch.results.first.addressComponents.first.longName}");
          debugPrint("TYPES ${fetch.results.first.types}");
          debugPrint("PLACEID  ${fetch.results.first.placeId}");
          log("GEOMETRY  ${jsonEncode(fetch)}");
          return GeoData(
            address: fetch.results.first.addressComponents.first.longName
                    .contains("+")
                ? results.first.formattedAddress.replaceAll(
                    fetch.results.first.addressComponents.first.longName, "")
                : results.first.formattedAddress,
            city: city,
            placeId: results.first.placeId ?? "",
            subLocality: subLocality,
            country: country,
            postalCode: postalCode,
            state: state,
            streetNumber: streetNumber,
            countryCode: countryCode,
            latitude: latitude.toString(),
            longitude: longitude.toString(),
          );
        } else {
          return GeoData(
            address: '',
            city: '',
            placeId: "",
            subLocality: "",
            country: '',
            latitude: latitude.toString(),
            longitude: longitude.toString(),
            postalCode: "",
            state: "",
            streetNumber: "",
            countryCode: '',
          );
        }
      } else {
        debugPrint('Failed to load data: ${response.statusCode}');
        return GeoData(
          address: '',
          city: '',
          subLocality: "",
          country: '',
          placeId: "",
          latitude: latitude.toString(),
          longitude: longitude.toString(),
          postalCode: "",
          state: "",
          streetNumber: "",
          countryCode: '',
        );
      }
    } catch (e) {
      debugPrint("EXCEPTIOn ${e}");
      return GeoData(
        address: '',
        city: '',
        country: '',
        placeId: "",
        subLocality: "",
        latitude: latitude.toString(),
        longitude: longitude.toString(),
        postalCode: "",
        state: "",
        streetNumber: "",
        countryCode: '',
      );
    }
  }

  getToken() async {
    coustomerId = await SharedPref.getStringPreference(Constants.sp_CustomerId);
    token_type = await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
    access_token =
        await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);
    token = "$token_type $access_token";
    debugPrint("TOKEN $token");
  }

/*  void openSettingsDialog(
      {required BuildContext context, required bool isDialogOpen}) {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //
    // });
    if (isDialogOpen || hasPermission) return;
    isDialogOpen = true;
    Timer.periodic(
      Duration(milliseconds: 900),
      (timer) async {
        hasPermission = await handleLocationPermission(context);
        if (hasPermission) {
          if (isDialogOpen) {
            timer.cancel();
            isDialogOpen = false;
          }
        }
      },
    );

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            decoration: BoxDecoration(
              color: ColorName.ColorBagroundPrimary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
              runSpacing: 5,
              runAlignment: WrapAlignment.spaceAround,
              children: [
                Center(
                  child: Image.asset(
                    Imageconstants.enable_location_image,
                    fit: BoxFit.fill,
                    width: 350,
                  ),
                ),
                Center(
                  child: Text(
                    "Allow Location for Accurate\nDeliveries",
                    textAlign: TextAlign.center,
                    style: Appwidgets()
                        .commonTextStyle(ColorName.black)
                        .copyWith(
                            fontSize: 18,
                            fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: Text(
                      StringContants.lbl_enable_location_text,
                      textAlign: TextAlign.center,
                      style: Appwidgets()
                          .commonTextStyle(ColorName.cinder)
                          .copyWith(
                              fontWeight: Fontconstants.SF_Pro_Display_Regular,
                              fontSize: 14),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    try {
                      if (!isLocationServiceEnabled) {
                        Geolocator.openLocationSettings();
                      } else {
                        Geolocator.openAppSettings();
                      }
                    } catch (exception, trace) {
                      debugPrint("exception trace $exception");
                      debugPrint("location Trace $trace");
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: ColorName.ColorPrimary,
                        borderRadius: BorderRadius.circular(8)),
                    child: Center(
                      child: Text(
                        "ENABLE LOCATION",
                        style: Appwidgets()
                            .commonTextStyle(ColorName.ColorBagroundPrimary)
                            .copyWith(
                                fontWeight: Fontconstants.SF_Pro_Display_Bold,
                                fontSize: 16),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "CANCEL",
                        style: Appwidgets().commonTextStyle(ColorName.black),
                      )),
                ),
                5.toSpace,
              ],
            ),
          ),
        );
      },
    );
  }*/
  void openSettingsDialog(
      {required BuildContext context, required bool isDialogOpen}) {
    // Early exit if dialog is already open or permission is granted
    debugPrint("Dialog open $isDialogOpen has Permission $hasPermission");
    if (isDialogOpen || hasPermission) return;

    isDialogOpen = true; // Set dialog open state
    // Timer.periodic(
    //   Duration(milliseconds: 900),
    //   (timer) async {
    //     hasPermission = await handleLocationPermission(context);
    //
    //     if (hasPermission) {
    //       // Schedule dialog dismissal after the current frame is rendered
    //       WidgetsBinding.instance.addPostFrameCallback((_) {
    //         if (isDialogOpen) {
    //           timer.cancel();
    //           isDialogOpen = false;
    //           Navigator.pop(context); // Close the dialog
    //         }
    //       });
    //     }
    //   },
    // );

    // Show the dialog
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            decoration: BoxDecoration(
              color: ColorName.ColorBagroundPrimary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
              runSpacing: 5,
              runAlignment: WrapAlignment.spaceAround,
              children: [
                Center(
                  child: Image.asset(
                    Imageconstants.enable_location_image,
                    fit: BoxFit.fill,
                    width: 350,
                  ),
                ),
                Center(
                  child: Text(
                    "Allow Location for Accurate\nDeliveries",
                    textAlign: TextAlign.center,
                    style: Appwidgets()
                        .commonTextStyle(ColorName.black)
                        .copyWith(
                            fontSize: 18,
                            fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: Text(
                      StringContants.lbl_enable_location_text,
                      textAlign: TextAlign.center,
                      style: Appwidgets()
                          .commonTextStyle(ColorName.cinder)
                          .copyWith(
                              fontWeight: Fontconstants.SF_Pro_Display_Regular,
                              fontSize: 14),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    // try {
                    debugPrint("EnableLocation 1");
                    LocationPermission permission =
                        await Geolocator.checkPermission();

                    if (permission == LocationPermission.denied) {
                      debugPrint("EnableLocation 2");

                      AppSettings.openAppSettings(
                              type: AppSettingsType.settings)
                          .then(
                        (value) async {
                          LocationPermission permission =
                              await Geolocator.checkPermission();
                          debugPrint("EnableLocation $permission");
                          if (permission == LocationPermission.denied) {
                            permission = await Geolocator.requestPermission();
                          }
                          if (permission == LocationPermission.whileInUse ||
                              permission == LocationPermission.always) {
                            if (!isLocationServiceEnabled) {
                              debugPrint("EnableLocation 5");
                              Geolocator.openLocationSettings();
                            } else {
                              debugPrint("EnableLocation 6");
                              isDialogOpen = true;
                              hasPermission = true;
                              getCurrentPosition(context);

                              Navigator.pop(context);
                            }
                          } else {
                            permission = await Geolocator.checkPermission();
                            debugPrint("EnableLocation 7 $permission");
                            if (permission == LocationPermission.whileInUse ||
                                permission == LocationPermission.always) {
                              isDialogOpen = true;
                              hasPermission = true;
                              getCurrentPosition(context);
                              Navigator.pop(context);
                            }
                          }
                        },
                      );
                    } else {
                      hasPermission = true;
                      getCurrentPosition(context);

                      // add(LocationInitialEvent());
                      // add(LocationNullEvent2());

                      Navigator.pop(context);
                    }

                    // handleLocationPermission(context);
                    /*  if (!isLocationServiceEnabled) {
                       // Geolocator.openLocationSettings();
                      }
                      else {
                        // Geolocator.openAppSettings().then(
                        //   (value) async {
                        //     debugPrint("open app settings ${value}");
                        //     if (value) {
                        //       hasPermission =
                        //           await handleLocationPermission(context);
                        //       if (hasPermission) {
                        //         add(LocationInitialEvent());
                        //         Navigator.pop(context);
                        //       }
                        //     }
                        //   },
                        // );

                        // AppSettings.openAppSettings(
                        //         type: AppSettingsType.location)
                        //     .then(
                        //   (value) async {
                        //     hasPermission =
                        //         await handleLocationPermission(context);
                        //   },
                        // );
                        */
                    /*     bool openedSettings =
                            await Geolocator.openAppSettings();

                        if (openedSettings) {
                          // Close the dialog after success
                          // After opening app settings, check permission again

                          if (hasPermission) {
                            add(LocationInitialEvent());
                            Navigator.pop(
                                context); // Close the dialog after success
                          } else {
                            Navigator.pop(context);
                            // Geolocator.openAppSettings();
                            debugPrint("Permission not granted.");
                          }
                        } else {}*/ /*
                      }*/
                    // } catch (exception, trace) {
                    //   debugPrint("exception trace $exception");
                    //   debugPrint("location Trace $trace");
                    // }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.all(10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: ColorName.ColorPrimary,
                        borderRadius: BorderRadius.circular(8)),
                    child: Center(
                      child: Text(
                        "ENABLE LOCATION",
                        style: Appwidgets()
                            .commonTextStyle(ColorName.ColorBagroundPrimary)
                            .copyWith(
                                fontWeight: Fontconstants.SF_Pro_Display_Bold,
                                fontSize: 16),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Close dialog on cancel
                      },
                      child: Text(
                        "CANCEL",
                        style: Appwidgets().commonTextStyle(ColorName.black),
                      )),
                ),
                5.toSpace,
              ],
            ),
          ),
        );
      },
    );
  }
/*  void openSettingsDialog(
      {required BuildContext context, required bool isDialogOpen}) {
    // Early exit if dialog is already open or permission is granted
    if (isDialogOpen || hasPermission) return;

    // Set dialog open state
    isDialogOpen = true;

    // Show the dialog
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevents closing the dialog by tapping outside
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            decoration: BoxDecoration(
              color: ColorName.ColorBagroundPrimary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
              runSpacing: 5,
              runAlignment: WrapAlignment.spaceAround,
              children: [
                Center(
                  child: Image.asset(
                    Imageconstants.enable_location_image,
                    fit: BoxFit.fill,
                    width: 350,
                  ),
                ),
                Center(
                  child: Text(
                    "Allow Location for Accurate\nDeliveries",
                    textAlign: TextAlign.center,
                    style: Appwidgets()
                        .commonTextStyle(ColorName.black)
                        .copyWith(
                            fontSize: 18,
                            fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: Text(
                      StringContants.lbl_enable_location_text,
                      textAlign: TextAlign.center,
                      style: Appwidgets()
                          .commonTextStyle(ColorName.cinder)
                          .copyWith(
                              fontWeight: Fontconstants.SF_Pro_Display_Regular,
                              fontSize: 14),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    try {
                      // Check if location service is enabled
                      if (!isLocationServiceEnabled) {
                        Geolocator.openLocationSettings();
                      } else {
                        debugPrint("Opening app settings...");
                        bool openedSettings =
                            await Geolocator.openAppSettings();

                        if (openedSettings) {
                          // After opening app settings, check permission again
                          hasPermission =
                              await handleLocationPermission(context);

                          if (hasPermission) {
                            // Update state and dismiss dialog
                            add(LocationInitialEvent());
                            Navigator.pop(
                                context); // Close the dialog after success
                          } else {
                            // Show some message or retry logic if permission is not granted
                            debugPrint("Permission not granted.");
                          }
                        }
                      }
                    } catch (exception, trace) {
                      debugPrint("Error opening settings: $exception");
                      debugPrint("Stack trace: $trace");
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: ColorName.ColorPrimary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        "ENABLE LOCATION",
                        style: Appwidgets()
                            .commonTextStyle(ColorName.ColorBagroundPrimary)
                            .copyWith(
                                fontWeight: Fontconstants.SF_Pro_Display_Bold,
                                fontSize: 16),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Close the dialog on cancel
                    },
                    child: Text(
                      "CANCEL",
                      style: Appwidgets().commonTextStyle(ColorName.black),
                    ),
                  ),
                ),
                SizedBox(height: 5),
              ],
            ),
          ),
        );
      },
    );
  }*/

  void getCurrentPosition(context) async {
    debugPrint("STATE >>>>>   ${state}");
    debugPrint("HasPermission >>>>>   ${hasPermission}");
    handleLocationPermission(context).then(
      (value) {
        hasPermission = value;
      },
    );
    debugPrint("hasPermission >>>>>   ${hasPermission}");

    if (!hasPermission) return;
    if (searchController != null) {
      searchController.clear();
    }
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      isuserAtCurrentPosition = true;
      userCurrentCameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: Constants.MAP_ZOOM_LEVEL);
      latitude = userCurrentCameraPosition.target.latitude;
      longitude = userCurrentCameraPosition.target.longitude;
      userCurrentAddress = "";
      usercity = "";
      userState = "";
      debugPrint("USER CAMERA ZOOM ${userCurrentCameraPosition.zoom}");
      debugPrint("ZOOM CONSTAT  ${ZOOM_CONSTANT}");
      if (userCurrentCameraPosition.zoom < ZOOM_CONSTANT) {
        setALlData();
      }
      if (mapController != null) {
        try {
          mapController!.animateCamera(
            CameraUpdate.newCameraPosition(CameraPosition(
              target: LatLng(latitude, longitude),
              zoom: Constants.MAP_ZOOM_LEVEL, // Adjust zoom level as needed
            )),
          );
        } catch (exception, stackTrace) {
          debugPrint("ERROR HAI ${exception.toString()}");
          debugPrint("TRACE HAI ${stackTrace.toString()}");

          add(CurrentLocationErrorEvent(exception.toString()));
        }
      }
    }).onError(
      (error, stackTrace) {
        debugPrint("${error}");

        add(CurrentLocationErrorEvent(error.toString()));
      },
    );
  }

  void animatetoSearchedPlace(double latitude, double longitude) {
    CameraPosition cameraPosition =
        CameraPosition(target: LatLng(latitude, longitude));
    if (mapController != null) {
      mapController!.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: cameraPosition.target, zoom: Constants.MAP_ZOOM_LEVEL)));
    }
    // setALlData();
    add(CurrentLocationEvent(cameraPosition));
  }

  @override
  Future<void> close() {
    // TODO: implement close
    return super.close();
  }

  Future<String> getAddressGeoCorder(String placeId) async {
    try {
      debugPrint("PLACE ID ADDRESS CODER ${placeId}");
      Dio dio = Dio();
      final response = await dio.get(
          "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${Constants.API_KEY}");
      dio.options.receiveTimeout = const Duration(seconds: 3);

      if (response.statusCode == 200) {
        final responseBody = response.toString();
        log("response addeeess ${jsonEncode(responseBody)}");
        return responseBody;
      } else if (response.statusCode == 401) {
        return "";
      } else {
        debugPrint("getAddressGeoCorder Else" + response.data);
        return "";
      }
    } catch (e) {
      debugPrint("EXCEPTION ${e}");
      return "";
    }
  }

  void addAddressDialog(context) {
    //PLACEID LAT LNG STATE
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return UserLocationDialog(
          firstName: "",
          lastName: "",
          flat_Sector_apartMent: "",
          houseAddress: userCurrentAddress,
          cityName: usercity,
          landmark: landMark,
          pinCode: postalCode,
          addresstype: "",
          action: "Add",
          latitude: latitude.toString(),
          longitude: longitude.toString(),
          // placeId: placeId,
          state: userState,
          routeName: Routes.location_screen,
          addressID: "",
        );
      },
    );
  }
}
