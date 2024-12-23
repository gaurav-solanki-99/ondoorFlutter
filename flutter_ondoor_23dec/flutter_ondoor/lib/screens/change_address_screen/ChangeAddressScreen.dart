import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ondoor/constants/ImageConstants.dart';
import 'package:ondoor/models/address_list_response.dart';
import 'package:ondoor/screens/CheckoutScreen/CheckoutBloc/checkout_bloc.dart';
import 'package:ondoor/screens/change_address_screen/change_address_bloc/change_address_bloc.dart';
import 'package:ondoor/screens/change_address_screen/change_address_bloc/change_address_event.dart';
import 'package:ondoor/screens/change_address_screen/change_address_bloc/change_address_state.dart';
import 'package:ondoor/services/ApiServices.dart';
import 'package:ondoor/utils/Connection.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/SizeConfig.dart';
import 'package:ondoor/utils/colors.dart';
import 'package:ondoor/utils/sharedpref.dart';
import 'package:ondoor/utils/shimmerUi.dart';
import 'package:ondoor/widgets/MyDialogs.dart';
import 'package:ondoor/widgets/user_location_dialog.dart';

import '../../constants/Constant.dart';
import '../../constants/FontConstants.dart';
import '../../constants/StringConstats.dart';
import '../../database/database_helper.dart';
import '../../models/geo_coder_response.dart';
import '../../models/geo_data.dart';
import '../../services/Navigation/routes.dart';
import '../../widgets/AppWidgets.dart';

class Changeaddressscreen extends StatefulWidget {
  String args;
  Changeaddressscreen({super.key, required this.args});

  @override
  State<Changeaddressscreen> createState() => _ChangeaddressscreenState();
}

class _ChangeaddressscreenState extends State<Changeaddressscreen> {
  ChangeAddressBloc changeAddressBloc = ChangeAddressBloc();
  CheckoutBloc checkoutBloc = CheckoutBloc();
  final dbHelper = DatabaseHelper();
  bool hasPermission = false;
  bool isLoading = false;
  double latitude = 0.0;
  double longitude = 0.0;
  String placedId = "";
  String street = "";
  String addressID = "";
  String locality = "";
  String city = "";
  String initialSelectedCity = "";
  String initialSelectedLocation = "";
  String state = "";
  String token = "";
  String tokenType = "";
  AddressData selectedAddressData = AddressData();
  List<AddressData> addressListFromAPi = [];
  late GeoData fetch;
  CameraPosition userCurrentCameraPosition = CameraPosition(
      target: LatLng(22.71767630209697, 75.87414333207185),
      zoom: Constants.MAP_ZOOM_LEVEL);

  getSavedAddress() async {
    street = await SharedPref.getStringPreference(Constants.SAVED_ADDRESS);
    city = await SharedPref.getStringPreference(Constants.SAVED_CITY);
    addressID = await SharedPref.getStringPreference(Constants.ADDRESS_ID);
    state = await SharedPref.getStringPreference(Constants.SAVED_STATE);
    initialSelectedCity = city;
    initialSelectedLocation = street;
    selectedAddressData.areaDetail = street;
    if (addressID.isNotEmpty) {
      selectedAddressData.addressId = addressID;
      debugPrint("addressID  >>   ${addressID}");
    } else {
      initialSelectedCity =
          await SharedPref.getStringPreference(Constants.LOCALITY);
      initialSelectedLocation =
          await SharedPref.getStringPreference(Constants.ADDRESS);
      debugPrint("Constants.LOCALITY  ${initialSelectedCity}");
    }
    selectedAddressData.city = city;
    selectedAddressData.zone = state;
    selectedAddressData.latitude =
        await SharedPref.getStringPreference(Constants.SELECTED_LOCATION_LAT);
    selectedAddressData.longitude =
        await SharedPref.getStringPreference(Constants.SELECTED_LOCATION_LONG);
    debugPrint("Selected ADdress Data  >>   ${selectedAddressData.toJson()}");
  }

  void retrieveAddressList() async {
    String customerId =
        await SharedPref.getStringPreference(Constants.sp_CustomerId);

    await dbHelper.init();
    getCurrentPosition(context);

    changeAddressBloc.add(FetchAddressLoadingEvent());
    if (await Network.isConnected()) {
      var addressListResponse =
          await ApiProvider().getAddressListApi(customerId, "0", () async {
        retrieveAddressList();
      });
      if (addressListResponse.success == true) {
        addressListFromAPi = addressListResponse.data!;
      } else {
        addressListFromAPi = [];
      }
      changeAddressBloc.add(FetchAddressEvent(addressListFromAPi));
    } else {
      MyDialogs.showInternetDialog(context, () {});
    }
  }

  @override
  void initState() {
    super.initState();
  }

  readToken() async {
    tokenType = await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
    token = await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);
    token = "$tokenType $token";
  }

  @override
  Widget build(BuildContext context) {
    Appwidgets.setStatusBarColor();
    return MediaQuery(
      data: Appwidgets().mediaqueryDataforWholeApp(context: context),
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return false;
        },
        child: SafeArea(
          child: BlocBuilder(
            bloc: changeAddressBloc,
            builder: (context, state) {
              readToken();
              debugPrint("ADDRESS LIST ${state}");

              if (state is FetchAddressInitialState) {
                isLoading = false;
                getSavedAddress();
                retrieveAddressList();
              }
              if (state is FetchAddressLoadingState) {
                isLoading = true;
              }
              if (state is FetchAddressState) {
                isLoading = false;
                addressListFromAPi = state.addresslist;
                if (addressListFromAPi.isNotEmpty) {
                  for (var element in addressListFromAPi) {
                    debugPrint("ELEMENT ${element.toJson()}");
                    debugPrint("STREET ${street}");
                    debugPrint("STREET ${city}");
                    if (selectedAddressData.address1 == null &&
                        (element.city == initialSelectedCity.split(', ')[0] ||
                            element.address1!
                                .contains(initialSelectedLocation))) {
                      selectedAddressData = element;
                    }
                  }
                }
              }
              if (state is SelectAddressState) {
                isLoading = false;
                selectedAddressData = state.addressData;
              }
              return Scaffold(
                backgroundColor: ColorName.whiteSmokeColor,
                appBar: AppBar(
                  title: Text(
                    widget.args == Routes.payment_option
                        ? StringContants.lbl_add_new_address
                        : StringContants.lbl_my_address,
                    style: Appwidgets()
                        .commonTextStyle(
                          ColorName.ColorBagroundPrimary,
                        )
                        .copyWith(
                            fontSize: 18,
                            fontFamily: Fontconstants.fc_family_proxima,
                            fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD),
                  ),
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: ColorName.ColorBagroundPrimary,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  centerTitle: true,
                  actions: [
                    GestureDetector(
                        onTap: () => addAddress(),
                        child: Icon(
                          Icons.add,
                          color: ColorName.ColorBagroundPrimary,
                        )),
                    10.toSpace
                  ],
                ),
                // appBar: Appwidgets.MyAppBar(
                //     context, StringContants.lbl_change_location, () {}),
                body: isLoading
                    ? Shimmerui.addressListUi(context, 80)
                    : addressListFromAPi.isEmpty
                        ? Center(
                            child: Text(
                              "No Address Found",
                              style: Appwidgets()
                                  .commonTextStyle(ColorName.black)
                                  .copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18),
                            ),
                          )
                        : ListView.separated(
                            separatorBuilder: (context, index) => Divider(
                                  height: .1,
                                ),
                            itemCount: addressListFromAPi.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              var addressData = addressListFromAPi[index];
                              return addressCard(addressData: addressData);
                            }), /*
                  bottomNavigationBar: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: widget.args == Routes.payment_option &&
                              addressListFromAPi.isNotEmpty
                          ? Appwidgets.MyButton(
                              "Add Address", Sizeconfig.getWidth(context),
                              () async {
                              if (widget.args == Routes.payment_option) {
                                if (selectedAddressData.address1 == "" ||
                                    selectedAddressData.city == "") {
                                  Appwidgets.showToastMessage(
                                      "Please Select Address!!");
                                } else {

                                  // Navigator.of(context).pop(selectedAddressData);
                                }
                              } else {
                                debugPrint(
                                    "SELECTED ADDRESS 2 ${selectedAddressData.toJson()}");
                                Navigator.pop(context, selectedAddressData);
                              }
                            })
                          : const SizedBox.shrink())*/
              );
            },
          ),
        ),
      ),
    );
  }

  addAddress() async {
    getCurrentPosition(context);
    fetch = await fetchData(latitude, longitude);
    debugPrint("FETCH ${fetch.toJson()}");
    bool result = await showDialog(
          context: context,
          builder: (context) => UserLocationDialog(
              firstName: "",
              lastName: "",
              flat_Sector_apartMent: "",
              houseAddress: fetch.address,
              cityName: fetch.city,
              pinCode: fetch.postalCode,
              landmark: "", //fetch.streetNumber,
              // placeId: fetch.placeId,
              state: fetch.state,
              latitude: "$latitude",
              action: "Add",
              longitude: "$longitude",
              routeName: Routes.change_address,
              addresstype: "Home",
              addressID: ""),
        ) ??
        false;
    if (result == true) {
      retrieveAddressList();
    }
    debugPrint("RESULT $result");
  }

  Future<void> getCurrentPosition(context) async {
    hasPermission = await handleLocationPermission(context);
    if (!hasPermission) return;
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      userCurrentCameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: Constants.MAP_ZOOM_LEVEL);
      latitude = userCurrentCameraPosition.target.latitude;
      longitude = userCurrentCameraPosition.target.longitude;
      debugPrint("LOCATIONS ${latitude}  ${longitude}");
    }).onError(
      (error, stackTrace) {
        debugPrint("GEO ERROR ${error}");
      },
    );
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
          debugPrint("TYPES ${fetch.results.first.types}");
          debugPrint("PLACEID  ${fetch.results.first.placeId}");
          debugPrint("GEOMETRY  ${fetch.results.first.geometry.toJson()}");
          return GeoData(
            address: results.first.formattedAddress ?? "",
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

  Future<bool> handleLocationPermission(context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  Widget addressCard({required AddressData addressData}) {
/*    log("ADDRESS DATA ${addressData.toJson()}");
    String userAddress = '';
    if (addressData.subtitle == "") {
      if (addressData.areaDetail != null &&
          addressData.areaDetail != "null" &&
          addressData.areaDetail != "") {
        userAddress = addressData.areaDetail!;
      }
      if (addressData.city != null &&
          addressData.city != "null" &&
          addressData.city != "") {
        userAddress = "$userAddress, ${addressData.city!}";
      }
      if (addressData.postcode != null &&
          addressData.postcode != "null" &&
          addressData.postcode != "") {
        userAddress = "$userAddress, ${addressData.postcode!}";
      }
    }*/
    String userAddress = '';
    if (addressData.title == "" && addressData.subtitle == "") {
      userAddress = "${addressData.address1!} ${addressData.address2!}";
    } else {
      userAddress = "${addressData.title} ${addressData.subtitle}";
    }
    return Container(
      // decoration: BoxDecoration(
      //     color: ColorName.ColorBagroundPrimary,
      //     borderRadius: BorderRadius.circular(5)),
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      padding: EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    fontWeight: Fontconstants.SF_Pro_Display_Bold,
                    fontSize: Constants.SizeSmall,
                    fontFamily: Fontconstants.fc_family_proxima),
              ),
              Spacer(),
              GestureDetector(
                onTap: () async {
                  debugPrint(
                      "addressData.flatSectorApartment  ${addressData.flatSectorApartment}");
                  var data = await showDialog(
                    context: context,
                    builder: (context) => UserLocationDialog(
                      firstName: addressData.firstname ?? "",
                      lastName: addressData.lastname ?? "",
                      flat_Sector_apartMent:
                          addressData.flatSectorApartment ?? "",
                      addresstype: addressData.addressType ?? "",
                      houseAddress: addressData.address2!,
                      action: "Update",
                      cityName: addressData.city!,
                      pinCode: addressData.postcode!,
                      landmark: addressData.landmark!,
                      state: addressData.zone!,
                      latitude: "${addressData.latitude}",
                      longitude: "${addressData.longitude}",
                      routeName: Routes.change_address,
                      addressID: addressData.addressId!,
                    ),
                  );
                  if (data ==
                      "Thank You! <br> Your address updated sucessfully") {
                    retrieveAddressList();
                  }
                  // debugPrint("CHANGE ADDRESS SCREEN ${data}");
                },
                child: Image.asset(
                  Imageconstants.edit_icon,
                  height: 18,
                  width: 18,
                ),
              ),
              5.toSpace,
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: ColorName.ColorBagroundPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      title: Text(
                        "Are you sure you want to delete this address ?",
                        style: Appwidgets().commonTextStyle(ColorName.black),
                      ),
                      actions: [
                        GestureDetector(
                            onTap: () async {
                              deleteAddressApi(addressData.addressId!);
                            },
                            child: Text("Yes",
                                style: Appwidgets()
                                    .commonTextStyle(ColorName.black))),
                        20.toSpace,
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text("No",
                              style: Appwidgets()
                                  .commonTextStyle(ColorName.black)),
                        ),
                      ],
                    ),
                  );
                },
                child: Image.asset(
                  Imageconstants.delete_icon,
                  height: 18,
                  width: 18,
                ),
              ),
            ],
          ),
          4.toSpace,
          Text(
            "${addressData.firstname} ${addressData.lastname}",
            style: Appwidgets().commonTextStyle(ColorName.black).copyWith(
                fontWeight: Fontconstants.SF_Pro_Display_Regular, fontSize: 15),
          ),
          addressData.flatSectorApartment == ""
              ? SizedBox.shrink()
              : Text(
                  "${addressData.flatSectorApartment}",
                  maxLines: 1,
                  style: Appwidgets().commonTextStyle(ColorName.black).copyWith(
                      fontWeight: Fontconstants.SF_Pro_Display_Regular,
                      fontSize: 15),
                ),
          // 4.toSpace,
          // Text(
          //   addressData.landmark == "" || addressData.landmark == null
          //       ? addressData.title!.toUpperCase()
          //       : addressData.landmark!.toUpperCase(),
          //   overflow: TextOverflow.ellipsis,
          //   style: TextStyle(
          //       fontSize: Constants.SizeSmall,
          //       fontFamily: Fontconstants.fc_family_proxima,
          //       fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
          //       color: ColorName.black),
          // ),
          2.toSpace,
          SizedBox(
            width: Sizeconfig.getWidth(context) * .8,
            child: Text(
              userAddress /*addressData.subtitle == null ||
                      addressData.subtitle == "null" ||
                      addressData.subtitle == ""
                  ? userAddress
                  : addressData.subtitle!*/
              ,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Appwidgets().commonTextStyle(ColorName.black).copyWith(
                  fontWeight: Fontconstants.SF_Pro_Display_Regular,
                  fontSize: 14),
            ),
          )
          // Row(
          //   children: [],
          // )
        ],
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

  void deleteAddressApi(String addressId) async {
    if (await Network.isConnected()) {
      Navigator.pop(context);
      var deleteAddressAPi =
          await ApiProvider().deleteAddressApi(addressId, () {
        deleteAddressApi(addressId);
      });
      if (deleteAddressAPi.success == true) {
        Appwidgets.showToastMessagefromHtml(deleteAddressAPi.message!);

        retrieveAddressList();
      }
    } else {
      MyDialogs.showInternetDialog(context, () {
        Navigator.pop(context);
      });
    }
  }
}
