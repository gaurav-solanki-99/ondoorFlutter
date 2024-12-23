import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:ondoor/constants/Constant.dart';
import 'package:ondoor/constants/ImageConstants.dart';
import 'package:ondoor/constants/StringConstats.dart';
import 'package:ondoor/database/database_helper.dart';
import 'package:ondoor/database/dbconstants.dart';
import 'package:ondoor/screens/change_address_screen/change_address_bloc/change_address_bloc.dart';
import 'package:ondoor/screens/location_screen/location_bloc/location_bloc.dart';
import 'package:ondoor/screens/location_screen/location_bloc/location_event.dart';
import 'package:ondoor/screens/location_screen/location_bloc/location_state.dart';
import 'package:ondoor/services/ApiServices.dart';
import 'package:ondoor/utils/Connection.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/SizeConfig.dart';
import 'package:ondoor/utils/colors.dart';
import 'package:ondoor/utils/sharedpref.dart';
import 'package:ondoor/utils/shimmerUi.dart';
import 'package:ondoor/utils/themeData.dart';
import 'package:ondoor/widgets/AppWidgets.dart';
import 'package:ondoor/widgets/MyDialogs.dart';
import 'package:ondoor/widgets/common_loading_widget.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../constants/FontConstants.dart';
import '../../models/MyAddress.dart';
import '../../models/address_list_response.dart';
import '../../services/Navigation/routes.dart';
import '../../utils/Comman_Loader.dart';
import '../change_address_screen/change_address_bloc/change_address_event.dart';
import '../change_address_screen/change_address_bloc/change_address_state.dart';

class LocationScreen extends StatefulWidget {
  Object args;
  LocationScreen({super.key, required this.args});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final LocationBloc locationBloc = LocationBloc();
  ScrollController predictionScrollController = ScrollController();
  ScrollController addressListScrollController = ScrollController();
  List<Prediction> predictionList = [];
  final dbHelper = DatabaseHelper();
  List<AddressData> addressListFromAPi = [];
  bool isLoading = false;
  bool isLogin = false;
  List<Map<String, dynamic>> addressFromLocal = [];
  String servingCityText = "";
  String token = "";
  List<MyAddress> placeList = [];
  bool isSearchingOn = false;
  int maxVisibleItems = 4;
  bool isDialogOpen = false;
  bool isAddressDialogOpen = false;
  double screenHeight = 0.0;
  ChangeAddressBloc changeAddressBloc = ChangeAddressBloc();
  Prediction predictionData = Prediction();
  final _debouncer = Debouncer(milliseconds: 600);

  bool ontaplist = true;

  @override
  void dispose() {
    locationBloc.mapControllerCompleter = Completer();
    locationBloc.searchController.dispose();
    if (locationBloc.mapController != null) {
      locationBloc.mapController!.dispose();
    }
    CommanLoader().dismissEasyLoader();
    super.dispose();
  }

  initializedDb() async {
    locationBloc.userCurrentAddress = "";
    locationBloc.usercity = "";
    locationBloc.userState = "";
    locationBloc.userCurrentCameraPosition =
        CameraPosition(target: locationBloc.bhopalLocation, zoom: 8);
    await dbHelper.init();
    Appwidgets.setStatusBarColor();
    retrieveFromLocal();
  }

  retrieveFromLocal() async {
    addressFromLocal = await dbHelper.retrieveAddressFromLocal();
  }

  readToken() async {
    String acesstoken =
        await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);
    String tokenType =
        await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
    token = "$tokenType $acesstoken";
  }

  @override
  Widget build(BuildContext context) {
    locationBloc.getToken();
    locationBloc.isFocus = MediaQuery.of(context).viewInsets.vertical > 0;
    screenHeight = Sizeconfig.getHeight(context);
    return MediaQuery(
      data: Appwidgets().mediaqueryDataforWholeApp(context: context),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: WillPopScope(
          onWillPop: () async {
            debugPrint("widget.args>>>> ${widget.args}");

            if (locationBloc.noLocationFoundError) {
              locationBloc.getCurrentPosition(context);
              return false;
            } else {
              if (widget.args == Routes.splashscreen) {
                Appwidgets.showExitDialog(
                    context,
                    StringContants.lbl_exit_question,
                    StringContants.lbl_exit_message, () {
                  exit(1);
                });
              } else {
                Navigator.pop(context);
              }
              return true;
            }
          },
          child: VisibilityDetector(
            key: const Key("location Screen"),
            onVisibilityChanged: (visibilityInfo) {
              var visiblePercentage = visibilityInfo.visibleFraction * 100;
              getPermissionStatus(
                  context: context, visibilityPercentage: visiblePercentage);
            },
            child: BlocBuilder(
              bloc: locationBloc,
              builder: (context, state) {
                // getPermissionStatus();
                readToken();
                debugPrint("Location State ${state}");
                debugPrint(
                    "ZOOM ${locationBloc.userCurrentCameraPosition.zoom}");
                if (predictionScrollController.hasClients) {
                  predictionScrollController.animateTo(
                      predictionScrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 1),
                      curve: Curves.easeIn);
                }
                if (addressListScrollController.hasClients) {
                  addressListScrollController.animateTo(0,
                      duration: const Duration(milliseconds: 1),
                      curve: Curves.easeIn);
                }
                // locationBloc.ZOOM_CONSTANT =
                //     locationBloc.userCurrentCameraPosition.zoom;
                if (state is LocationUserLoginState) {
                  isLogin = state.isLogin;
                  if (widget.args != Routes.change_address &&
                      !locationBloc.isFocus &&
                      addressListFromAPi.isNotEmpty) {
                    // WidgetsBinding.instance.addPostFrameCallback((_) {
                    //   showAddressSheet();
                    // });
                  }
                }
                if (state is LocationNullState2) {
                  if (locationBloc.searchController.text.isEmpty &&
                      locationBloc.shouldIAnimate) {
                    debugPrint("ROhit 153");
                    locationBloc.getCurrentPosition(context);
                  }
                }
                if (state is LocationInitialState) {
                  EasyLoading.show();
                  if (token.trim().isNotEmpty) {
                    retrieveAddressList();
                  }
                  debugPrint(
                      "isFocus ${locationBloc.latitude}, ${locationBloc.longitude}");
                  locationBloc.userCurrentAddress = "";
                  locationBloc.usercity = "";
                  locationBloc.userState = "";

                  if (locationBloc.hasPermission &&
                      !locationBloc.isuserAtCurrentPosition &&
                      locationBloc.shouldIAnimate) {
                    debugPrint("ROhit 166");
                    locationBloc.getCurrentPosition(context);
                  } else {
                    //bhopal Location
                    locationBloc.userCurrentCameraPosition = CameraPosition(
                        target: locationBloc.bhopalLocation, zoom: 8.3);
                    locationBloc.add(LocationInitialEvent());
                  }
                  if (EasyLoading.isShow) {
                    EasyLoading.dismiss();
                  }
                  return mapWidget(state, context);
                }
                if (state is NoLocationFoundState ||
                    state is MapLoadingState ||
                    state is GetCocoCodeState) {
                  return mapWidget(state, context);
                }
                if (state is SearchingPlacesState) {
                  isSearchingOn = state.searchingOn;
                }
                if (state is CurrentLocationErrorState) {
                  debugPrint("LOCATION ERROR ${state.error}");
                  if (state.error ==
                      StringContants.LOCATION_SERVICE_DISABLED) {}
                  if (state.error ==
                      StringContants.LOCATION_PERMISSION_PERMANENTLY_DENIED) {
                    locationBloc.openSettingsDialog(
                        context: context, isDialogOpen: isDialogOpen);
                  }
                }
                if (state is NoLocationFoundState) {
                  ontaplist = true;
                  locationBloc.noLocationFoundError = true;
                }

                return mapWidget(state, context);
              },
            ),
          ),
        ),
      ),
    );
  }

  getPermissionStatus(
      {required BuildContext context,
      required double visibilityPercentage}) async {
    if (!locationBloc.hasPermission) {
      locationBloc.handleLocationPermission(context).then(
        (value) {
          debugPrint("Location Permissions $value");
          debugPrint("Location Permissions ${locationBloc.hasPermission}");
          debugPrint("Location Permissions ${widget.args}");
          debugPrint(
              "Location Permissions ${locationBloc.isuserAtCurrentPosition}");
          locationBloc.hasPermission = value;
          if ((widget.args == Routes.home_page) ||
              (locationBloc.hasPermission &&
                  widget.args == Routes.splashscreen)) {
            debugPrint("ROhit 222");
            if (!locationBloc.isuserAtCurrentPosition) {
              locationBloc.getCurrentPosition(context);
            }
          } else {
            if (!locationBloc.isuserAtCurrentPosition) {
              locationBloc.add(LocationNullEvent2());
            }
          }
        },
      );
    }
  }

  bool emptyPredictionList() {
    return predictionData.id == null &&
            predictionData.description == null &&
            predictionData.placeId == null &&
            predictionData.lat == null &&
            predictionData.lng == null
        ? true
        : false;
  }

  @override
  void initState() {
    // TODO: implement initState
    initializedDb();
    super.initState();
  }

  Widget mapWidget(state, context) {
    // if (!isFocus) {
    //   locationBloc.focusNode.unfocus();
    // }
    return Stack(
      children: [
        /*locationBloc.userCurrentCameraPosition.zoom < locationBloc.ZOOM_CONSTANT
            ? Image.asset(
                Imageconstants.map_image,
                width: Sizeconfig.getWidth(context),
                height: Sizeconfig.getHeight(context),
                fit: BoxFit.cover,
              )
            :*/
        GoogleMap(
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          mapType: MapType.normal,
          onCameraIdle: () => locationBloc.onCameraIdle(),
          onCameraMove: (position) => locationBloc.oncameraMove(position),
          initialCameraPosition: state is CurrentLocationState
              ? state.cameraPosition
              : locationBloc.userCurrentCameraPosition,
          onMapCreated: (GoogleMapController controller) {
            locationBloc.mapController = controller;
            locationBloc.onMapCreated();
          },
        ),
        state is MapLoadingState ? const CommonLoadingWidget() : markerWidget(),
        locationBloc.isFocus
            ? const SizedBox.shrink()
            : goToLiveLocationWidget(context, state),
        headerSearchView(context, state),
      ],
    );
  }

  Widget headerSearchView(context, state) {
    return Positioned(
      top: 40,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        child: placesAutoCompleteTextField(state),
      ),
    );
  }

  placesAutoCompleteTextField(state) {
    locationBloc.searchController.addListener(
      () {
        if (locationBloc.searchController.text == "") {
          predictionList.clear();
          locationBloc.add(SearchingPlacesEvent(
              searchingOn: false, prediction: predictionList));
        }
      },
    );
    debugPrint("SCREEN HEIGHT $screenHeight");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        10.toSpace,
        GooglePlaceAutoCompleteTextField(
          countries: const ["in"],
          containerVerticalPadding: 0,
          focusNode: locationBloc.focusNode,
          showError: true,
          textEditingController: locationBloc.searchController,
          googleAPIKey: Constants.API_KEY,
          boxDecoration: BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: Appwidgets().commonTextStyle(ColorName.black),
          inputDecoration: InputDecoration(
            hintText: StringContants.lbl_search_your_Location,
            hintStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            border: Appwidgets.googlePlaceWidgetDecoration(),
            enabledBorder: Appwidgets.googlePlaceWidgetDecoration(),
            focusedBorder: Appwidgets.googlePlaceWidgetDecoration(),
            errorBorder: Appwidgets.googlePlaceWidgetDecoration(),
            disabledBorder: Appwidgets.googlePlaceWidgetDecoration(),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0), // Padding around the text
            prefixIcon:
                widget.args == Routes.splashscreen || locationBloc.token == " "
                    ? null
                    : GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.arrow_back_ios),
                      ),
            suffixIcon: isSearchingOn
                ? GestureDetector(
                    onTap: () {
                      OndoorThemeData.keyBordDow();
                      locationBloc.searchController.clear();
                      predictionList.clear();
                      locationBloc.focusNode.unfocus();
                      // Resetting the state
                      isSearchingOn = false;
                      locationBloc.isFocus = false;
                      predictionData = Prediction(); // Clear prediction data
                      locationBloc.add(SearchingPlacesEvent(
                          searchingOn: false, prediction: const []));
                    },
                    child: const Icon(Icons.close, color: ColorName.black),
                  )
                : GestureDetector(
                    onTap: () {
                      FocusScope.of(context)
                          .requestFocus(locationBloc.focusNode);
                      // FocusManager.instance.primaryFocus!
                      //     .requestFocus(locationBloc.focusNode);
                    },
                    child: const Icon(Icons.search, color: ColorName.black)),
          ),
          debounceTime: 1,
          isLatLngRequired: false,
          getPlaceDetailWithLatLng: (prediction) {
            debugPrint("placeDetails $prediction");
          },
          seperatedBuilder: const SizedBox.shrink(),
          itemBuilder: (context, index, prediction) {
            debugPrint("predictionlistlength ${predictionList.length}");
            if (predictionList.length <= 8 &&
                locationBloc.searchController.text != "") {
              if (!predictionList.contains(prediction)) {
                predictionList.add(prediction);
              }
              locationBloc.add(SearchingPlacesEvent(
                  searchingOn: true, prediction: predictionList));
            } else {
              predictionList.clear();
            }
            predictionList = predictionList.toSet().toList();
            return const SizedBox();
          },
          isCrossBtnShown: false,
        ),
        isSearchingOn
            ? Container(
                decoration: BoxDecoration(
                    color: ColorName.ColorBagroundPrimary,
                    borderRadius: BorderRadius.circular(12)),
                child: ListView.separated(
                  shrinkWrap: true,
                  separatorBuilder: (context, index) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Divider(height: 0.5),
                  ),
                  padding: EdgeInsets.zero,
                  itemCount: predictionList.length,
                  itemBuilder: (context, index) {
                    var prediction = Prediction();
                    String subAddress = "";
                    if (index >= predictionList.length) {
                      return const SizedBox.shrink();
                    }
                    if (predictionList.isNotEmpty) {
                      prediction = predictionList[index];
                      if (prediction.terms!.length == 1) {
                        debugPrint(
                            "prediction.terms![0].value! ${prediction.terms![0].value!}");
                        subAddress = prediction.terms![0].value!;
                      }
                      if (prediction.terms!.length > 1) {
                        subAddress = prediction.terms![1].value!;
                      }
                      if (prediction.terms!.length > 2) {
                        subAddress =
                            "$subAddress, ${prediction.terms![2].value!}";
                      }
                    }
                    return predictionList.isEmpty
                        ? const SizedBox.shrink()
                        : InkWell(
                            onTap: () => ontapFunctionForPrediction(prediction),
                            child: commonWidgetforPlacesList(
                                addressDescription:
                                    prediction.terms?[0].value ?? "",
                                subAddress: subAddress,
                                searchingState: isSearchingOn,
                                index: index),
                          );
                  },
                ),
              )
            : locationBloc.isFocus || locationBloc.initialStage
                ? Container(
                    decoration: BoxDecoration(
                        color: ColorName.ColorBagroundPrimary,
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            locationBloc.handleLocationPermission(context);
                            if (locationBloc.hasPermission == false) {
                              debugPrint("ROHITTTT 2cvnklbncv ");
                              isDialogOpen = false;
                              locationBloc.openSettingsDialog(
                                  context: context, isDialogOpen: isDialogOpen);
                            } else {
                              if (locationBloc.isFocus == true ||
                                  locationBloc.focusNode.hasFocus) {
                                locationBloc.focusNode.unfocus();
                              }
                              // debugPrint("ROhit 1183");
                              locationBloc.initialStage = false;

                              _debouncer.run(() {
                                locationBloc.settingSavedaddress = false;

                                locationBloc.getCurrentPosition(context);
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 4),
                            width: Sizeconfig.getWidth(context),
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 5),
                            decoration: BoxDecoration(
                                boxShadow: [
                                  const BoxShadow(
                                      color: ColorName.black,
                                      blurStyle: BlurStyle.outer),
                                  BoxShadow(
                                      color: ColorName.black.withOpacity(.5),
                                      blurStyle: BlurStyle.outer),
                                  BoxShadow(
                                      color: ColorName.black.withOpacity(.2),
                                      blurStyle: BlurStyle.outer)
                                ],
                                color: ColorName.ColorBagroundPrimary,
                                border: Border.all(
                                    color: ColorName.ColorPrimary, width: .5),
                                borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.gps_fixed,
                                  size: 15,
                                  color: ColorName.ColorPrimary,
                                ),
                                10.toSpace,
                                Text(
                                  StringContants.lbl_go_toLive_Location,
                                  style: Appwidgets()
                                      .commonTextStyle(ColorName.ColorPrimary)
                                      .copyWith(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: locationBloc.isFocus
                              ? screenHeight > 800
                                  ? screenHeight * .55
                                  : screenHeight * .45
                              : screenHeight > 800
                                  ? screenHeight * .82
                                  : screenHeight * .78,
                          decoration: BoxDecoration(
                              color: ColorName.ColorBagroundPrimary,
                              borderRadius: BorderRadius.circular(12)),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                addressFromLocal.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: Text(
                                          "Recent Search",
                                          style: Appwidgets()
                                              .commonTextStyle(ColorName.dark)
                                              .copyWith(
                                                  fontWeight: FontWeight.w500),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                                addressFromLocal.isNotEmpty
                                    ? Wrap(
                                        children: addressFromLocal.map(
                                          (item) {
                                            log("item Address ${item}");
                                            return InkWell(
                                              onTap: () async {
                                                debugPrint(
                                                    "on tap list ${ontaplist}");
                                                if (ontaplist) {
                                                  ontaplist = false;
                                                  locationBloc.initialStage =
                                                      false;
                                                  locationBloc.shouldIAnimate =
                                                      false;

                                                  if (widget.args ==
                                                      Routes.change_address) {
                                                    debugPrint(
                                                        "Tap Location 1");
                                                    if (await Network
                                                        .isConnected()) {
                                                      var cityListApi =
                                                          await ApiProvider()
                                                              .getCityListApi();
                                                      for (int i = 0;
                                                          i <
                                                              cityListApi
                                                                  .data!.length;
                                                          i++) {
                                                        locationBloc.usercity =
                                                            item[DBConstants
                                                                .CITY];
                                                        debugPrint(
                                                            "INDEX ${i} DATA LENGTH ${cityListApi.data!.length}");
                                                        debugPrint(
                                                            "USER CITY  ${locationBloc.usercity} DATA NAME ${cityListApi.data![i].name}");
                                                        if (cityListApi.data![i]
                                                                .name ==
                                                            locationBloc
                                                                .usercity) {
                                                          double latitude =
                                                              double.parse(item[
                                                                  DBConstants
                                                                      .LAT]!);
                                                          double longitude =
                                                              double.parse(item[
                                                                  DBConstants
                                                                      .LNG]!);
                                                          isAddressDialogOpen =
                                                              false;
                                                          locationBloc
                                                                  .userCurrentAddress =
                                                              item[DBConstants
                                                                      .LANDMARK] ??
                                                                  '';

                                                          locationBloc
                                                                  .userState =
                                                              item[DBConstants
                                                                  .STATE];
                                                          locationBloc
                                                                  .postalCode =
                                                              item[DBConstants
                                                                  .POSTALCODE];
                                                          locationBloc
                                                                  .userCurrentCameraPosition =
                                                              CameraPosition(
                                                                  target: LatLng(
                                                                      latitude,
                                                                      longitude));
                                                          var addressData = {
                                                            "latitude": locationBloc
                                                                .userCurrentCameraPosition
                                                                .target
                                                                .latitude,
                                                            "longitude":
                                                                locationBloc
                                                                    .userCurrentCameraPosition
                                                                    .target
                                                                    .longitude,
                                                            "userCurrentAddress":
                                                                locationBloc
                                                                    .userCurrentAddress,
                                                            "city": locationBloc
                                                                .usercity,
                                                            "state":
                                                                locationBloc
                                                                    .userState,
                                                            "postalCode":
                                                                locationBloc
                                                                    .postalCode
                                                          };
                                                          log("CITY MATCHED ${addressData}");
                                                          Navigator.pop(context,
                                                              addressData);
                                                          break;
                                                        }
                                                        if (i ==
                                                                cityListApi
                                                                        .data!
                                                                        .length -
                                                                    1 &&
                                                            cityListApi.data![i]
                                                                    .name !=
                                                                locationBloc
                                                                    .usercity) {
                                                          Appwidgets
                                                              .showToastMessage(
                                                                  "We do not provide service in this City!!");
                                                          locationBloc.add(
                                                              LocationInitialEvent());
                                                          locationBloc.add(
                                                              NoLocationFoundEvent(
                                                                  "We do not provide service in this City!!"));
                                                        } else {}
                                                      }
                                                    } else {
                                                      ontaplist = true;
                                                      MyDialogs
                                                          .showInternetDialog(
                                                              context, () {
                                                        Navigator.pop(context);
                                                      });
                                                    }
                                                  } else {
                                                    debugPrint(
                                                        "Tap Location 2 $item");

                                                    locationBloc
                                                            .settingSavedaddress =
                                                        false;
                                                    ontaplist = true;

                                                    double latitude =
                                                        double.parse(item[
                                                            DBConstants.LAT]!);
                                                    double longitude =
                                                        double.parse(item[
                                                            DBConstants.LNG]!);
                                                    isAddressDialogOpen = false;
                                                    locationBloc
                                                            .userCurrentAddress =
                                                        item[DBConstants
                                                                .LANDMARK] ??
                                                            '';
                                                    locationBloc.userState =
                                                        item[DBConstants.STATE];
                                                    locationBloc.usercity =
                                                        item[DBConstants.CITY];
                                                    locationBloc
                                                            .userCurrentCameraPosition =
                                                        CameraPosition(
                                                            target: LatLng(
                                                                latitude,
                                                                longitude));

                                                    _debouncer.run(() {
                                                      locationBloc
                                                              .settingSavedaddress =
                                                          false;
                                                      locationBloc
                                                          .useThisLocation(
                                                              context);
                                                    });
                                                  }
                                                }
                                              },
                                              child: widgetForAddressDataWidget(
                                                addressDescription: item[
                                                        DBConstants.LANDMARK] ??
                                                    '',
                                                subAddress:
                                                    '${item[DBConstants.CITY]}, ${item[DBConstants.STATE]}',
                                              ),
                                            );
                                          },
                                        ).toList(),
                                      )
                                    : const SizedBox.shrink(),
                                addressListFromAPi.isNotEmpty &&
                                        addressFromLocal.isNotEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Divider(
                                          height: .5,
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                                addressListFromAPi.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            right: 15, left: 15, top: 10),
                                        child: Text(
                                          "Saved Addresses",
                                          style: Appwidgets()
                                              .commonTextStyle(ColorName.dark)
                                              .copyWith(
                                                  fontWeight: FontWeight.w500),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                                BlocBuilder(
                                  bloc: changeAddressBloc,
                                  builder: (context, state) {
                                    debugPrint("ADDRESS LIST ${state}");

                                    if (state is FetchAddressInitialState) {
                                      isLoading = false;
                                      if (token.trim().isNotEmpty) {
                                        retrieveAddressList();
                                      }
                                    }
                                    if (state is FetchAddressLoadingState) {
                                      isLoading = true;
                                    }
                                    if (state is FetchAddressState) {
                                      isLoading = false;
                                      addressListFromAPi = state.addresslist;
                                    }
                                    // if (state is SelectAddressState) {
                                    //   isLoading = false;
                                    //   selectedAddressData = state.addressData;
                                    // }

                                    return isLoading
                                        ? Shimmerui.addressListUi(context, 80)
                                        : Wrap(
                                            children: addressListFromAPi.map(
                                              (addressData) {
                                                return addressCard(
                                                    addressData: addressData);
                                              },
                                            ).toList(),
                                          );
                                    /*    return */ /*isLoading
                                                  ? Shimmerui.addressListUi(context, 80)
                                                  :*/ /*
                                              Expanded(
                                            child: ListView.separated(
                                              separatorBuilder:
                                                  (context, index) =>
                                                      const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10),
                                                child: Divider(
                                                  height: .1,
                                                ),
                                              ),
                                              shrinkWrap: true,
                                              padding: EdgeInsets.zero,
                                              physics:
                                                  AlwaysScrollableScrollPhysics(),
                                              itemCount:
                                                  addressListFromAPi.length,
                                              itemBuilder: (context, index) =>
                                                  addressCard(
                                                      addressData:
                                                          addressListFromAPi[
                                                              index]),
                                            ),
                                          );*/
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
      ],
    );
  }

  double getPredictionListHeight(context) {
    return predictionList.length == 4
        ? Sizeconfig.getHeight(context) * .27
        : predictionList.length == 3
            ? Sizeconfig.getHeight(context) * .2
            : predictionList.length == 2
                ? Sizeconfig.getHeight(context) * .135
                : predictionList.length == 1
                    ? Sizeconfig.getHeight(context) * .067
                    : predictionList.isEmpty
                        ? 0
                        : Sizeconfig.getHeight(context) * .27;
  }

  void retrieveAddressList() async {
    String customerId =
        await SharedPref.getStringPreference(Constants.sp_CustomerId);

    await dbHelper.init();

    changeAddressBloc.add(FetchAddressLoadingEvent());
    if (await Network.isConnected()) {
      var addressListResponse =
          await ApiProvider().getAddressListApi(customerId, "0", () async {
        retrieveAddressList();
      });
      if (addressListResponse.success != null &&
          addressListResponse.success == true) {
        addressListFromAPi = addressListResponse.data!;
        locationBloc.add(LocationUserLoginEvent(
            isLogin: addressListResponse.success ?? true));
      } else {
        addressListFromAPi = [];
      }
      changeAddressBloc.add(FetchAddressEvent(addressListFromAPi));
    } else {
      MyDialogs.showInternetDialog(context, () {});
    }
  }

  Widget widgetForStoredAddressData() {
    double screenHeight = Sizeconfig.getHeight(context);
    return /* addressFromLocal.length == maxVisibleItems
        ? Container(
            decoration: BoxDecoration(
                color: ColorName.ColorBagroundPrimary,
                borderRadius: BorderRadius.circular(12)),
            child: recentAddressWidget(),
          )
        :*/
        Container(
      // height: (addressFromLocal.length > maxVisibleItems
      //     ? screenHeight * .27
      //     : (addressFromLocal.length * screenHeight * .067) +
      //         (addressFromLocal.length - 1) * 0.5),
      decoration: BoxDecoration(
          color: ColorName.ColorBagroundPrimary,
          borderRadius: BorderRadius.circular(12)),
      child: recentAddressWidget(),
    );
  }

  Widget recentAddressWidget() {
    return Wrap(
      // mainAxisAlignment: MainAxisAlignment.start,
      // crossAxisAlignment: CrossAxisAlignment.start,
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.start,
      runAlignment: WrapAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            "Recent Search",
            style: Appwidgets()
                .commonTextStyle(ColorName.dark)
                .copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        ListView.separated(
          controller: predictionScrollController,
          shrinkWrap: true,
          reverse: true,
          padding: EdgeInsets.zero,
          itemCount: addressFromLocal.length,
          separatorBuilder: (context, index) => const Divider(
            endIndent: .5,
            thickness: .5,
            indent: .5,
            height: .5,
          ),
          itemBuilder: (context, index) {
            final item = addressFromLocal[index];
            log("address from local item $item");

            return InkWell(
              onTap: () async {
                log("Tapped on address from local item ${item}");
                if (widget.args == Routes.change_address) {
                  if (await Network.isConnected()) {
                    var cityListApi = await ApiProvider().getCityListApi();
                    for (int i = 0; i < cityListApi.data!.length; i++) {
                      locationBloc.usercity = item[DBConstants.CITY];
                      debugPrint(
                          "INDEX ${i} DATA LENGTH ${cityListApi.data!.length}");
                      debugPrint(
                          "USER CITY  ${locationBloc.usercity} DATA NAME ${cityListApi.data![i].name}");
                      if (cityListApi.data![i].name == locationBloc.usercity) {
                        double latitude = double.parse(item[DBConstants.LAT]!);
                        double longitude = double.parse(item[DBConstants.LNG]!);
                        isAddressDialogOpen = false;
                        locationBloc.userCurrentAddress =
                            item[DBConstants.LANDMARK] ?? '';

                        locationBloc.userState = item[DBConstants.STATE];
                        locationBloc.postalCode = item[DBConstants.POSTALCODE];
                        locationBloc.userCurrentCameraPosition =
                            CameraPosition(target: LatLng(latitude, longitude));
                        var addressData = {
                          "latitude": locationBloc
                              .userCurrentCameraPosition.target.latitude,
                          "longitude": locationBloc
                              .userCurrentCameraPosition.target.longitude,
                          "userCurrentAddress": locationBloc.userCurrentAddress,
                          "city": locationBloc.usercity,
                          "state": locationBloc.userState,
                          "postalCode": locationBloc.postalCode
                        };
                        log("CITY MATCHED ${addressData}");
                        Navigator.pop(context, addressData);
                        break;
                      }
                      if (i == cityListApi.data!.length - 1 &&
                          cityListApi.data![i].name != locationBloc.usercity) {
                        Appwidgets.showToastMessage(
                            "We do not provide service in this City!!");
                        locationBloc.add(LocationInitialEvent());
                        locationBloc.add(NoLocationFoundEvent(
                            "We do not provide service in this City!!"));
                      } else {}
                    }
                  } else {
                    MyDialogs.showInternetDialog(context, () {
                      Navigator.pop(context);
                    });
                  }
                } else {
                  locationBloc.settingSavedaddress = false;
                  double latitude = double.parse(item[DBConstants.LAT]!);
                  double longitude = double.parse(item[DBConstants.LNG]!);
                  isAddressDialogOpen = false;
                  locationBloc.userCurrentAddress =
                      item[DBConstants.LANDMARK] ?? '';

                  locationBloc.userState = item[DBConstants.STATE];
                  locationBloc.usercity = item[DBConstants.CITY];
                  locationBloc.userCurrentCameraPosition =
                      CameraPosition(target: LatLng(latitude, longitude));
                  locationBloc.useThisLocation(context);
                }
                /*if (widget.args == Routes.change_address) {
                  // var addressData = {
                  //   "latitude": locationBloc
                  //       .userCurrentCameraPosition.target.latitude,
                  //   "longitude": locationBloc
                  //       .userCurrentCameraPosition.target.longitude,
                  //   "userCurrentAddress": locationBloc.userCurrentAddress,
                  //   "city": locationBloc.usercity,
                  //   "state": locationBloc.userState,
                  //   "postalCode": locationBloc.postalCode
                  // };
                  // Navigator.pop(context, addressData);
                }*/
                // double latitude =
                //     double.parse(item[DBConstants.LAT]!);
                // double longitude =
                //     double.parse(item[DBConstants.LNG]!);
                // locationBloc.animatetoSearchedPlace(
                //   latitude,
                //   longitude,
                //   // item[DBConstants.ADDRESS]!,
                //   // item[DBConstants.CITY]!,
                //   // item[DBConstants.STATE]!,
                // );
              },
              child: widgetForAddressDataWidget(
                  addressDescription: item[DBConstants.LANDMARK] ?? '',
                  subAddress:
                      '${item[DBConstants.CITY]}, ${item[DBConstants.STATE]}'),
            );
          },
        ),
      ],
    );
  }

  ontapFunctionForPrediction(Prediction prediction) async {
    OndoorThemeData.keyBordDow();
    predictionList.clear();
    if (await Network.isConnected()) {
      // FocusManager.instance.primaryFocus!.unfocus();
      // String city = "";
      // String state = "";
      debugPrint("PLACE ID ${jsonEncode(prediction)}");
      debugPrint("PLACE ID ${prediction.placeId}");
      locationBloc.initialStage = false;
      locationBloc.settingSavedaddress = false;

      var data = await locationBloc.getAddressGeoCorder(prediction.placeId!);
      locationBloc.searchController.text = prediction.description ?? "";
      locationBloc.searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: prediction.description?.length ?? 0));
      Map<String, dynamic> mapData = jsonDecode(data);
      String cityName = "";
      String stateName = "";
      String postal_code = "";
      // Access the latitude and longitude
      double latitude = mapData['result']['geometry']['location']['lat'];
      double longitude = mapData['result']['geometry']['location']['lng'];
      List<dynamic> addressComponents = mapData['result']['address_components'];
      log("ADDRESS COMPONENTS ${jsonEncode(addressComponents)}");
      for (var component in addressComponents) {
        List<dynamic> types = component['types'];
        if (types.contains('locality') ||
            types.contains('administrative_area_level_3')) {
          cityName = component['long_name'];
        }
        if (types.contains('administrative_area_level_1')) {
          stateName = component['long_name'];
        }
        if (types.contains('postal_code')) {
          postal_code = component['long_name'];
        }
      }
      log("MAP DATA ${jsonEncode(mapData)}");
      debugPrint("prediction.description! ${prediction.toJson()}");

      Map<String, dynamic> row = {
        DBConstants.ADDRESS: prediction.description!,
        DBConstants.LANDMARK: prediction.description!.split(', ')[0].trim(),
        DBConstants.PLACEID: prediction.placeId,
        DBConstants.LAT: latitude,
        DBConstants.LNG: longitude,
        DBConstants.CITY: cityName ?? "",
        DBConstants.STATE: stateName,
        DBConstants.INSERTED_DATE: DateTime.now().toString(),
        DBConstants.POSTALCODE: postal_code,
        DBConstants.ADDRESS_TYPE: "selectedLabel"
      };
      // if(){
      //
      // }
      var result = addressFromLocal.any(
        (element) {
          return element[DBConstants.ADDRESS] == prediction.description!;
        },
      );
      debugPrint("ISNERTION STATUS ${result}");
      if (result == false) {
        int status = await dbHelper.insertAddress(row);
        retrieveFromLocal();
      }
      debugPrint("LatLongs  ${latitude} ${longitude}");
      locationBloc.userCurrentCameraPosition = CameraPosition(
          target: LatLng(latitude, longitude), zoom: Constants.MAP_ZOOM_LEVEL);
      locationBloc.animatetoSearchedPlace(latitude,
          longitude /*, prediction.description!, cityName, stateName*/);
      // Navigator.pop(context, prediction);
    } else {
      locationBloc.add(NoInternetEvent());
    }
  }

  Widget useThisLocationButton(context) {
    return GestureDetector(
      onTap: () async {
        if (widget.args == Routes.change_address) {
          if (await Network.isConnected()) {
            var cityListApi = await ApiProvider().getCityListApi();
            for (int i = 0; i < cityListApi.data!.length; i++) {
              debugPrint("INDEX ${i} DATA LENGTH ${cityListApi.data!.length}");
              debugPrint(
                  "USER CITY  ${locationBloc.usercity} DATA NAME ${cityListApi.data![i].name}");
              if (cityListApi.data![i].name == locationBloc.usercity) {
                debugPrint("CITY MATCHED ");
                var addressData = {
                  "latitude":
                      locationBloc.userCurrentCameraPosition.target.latitude,
                  "longitude":
                      locationBloc.userCurrentCameraPosition.target.longitude,
                  "userCurrentAddress": locationBloc.userCurrentAddress,
                  "city": locationBloc.usercity,
                  "state": locationBloc.userState,
                  "postalCode": locationBloc.postalCode
                };
                Navigator.pop(context, addressData);
                break;
              }
              if (i == cityListApi.data!.length - 1 &&
                  cityListApi.data![i].name != locationBloc.usercity) {
                locationBloc.add(LocationInitialEvent());
                OndoorThemeData.keyBordDow();
                locationBloc.add(NoLocationFoundEvent(
                    "We do not provide service in this City!!"));
              }
            }
          } else {
            MyDialogs.showInternetDialog(context, () {
              Navigator.pop(context);
            });
          }
        } else {
          _debouncer.run(() {
            locationBloc.useThisLocation(context);
          });
        }
      },
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: ColorName.ColorPrimary,
          ),
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Center(
              child: Text(
            "Use this Location",
            style: TextStyle(
                fontSize: Constants.SizeButton,
                fontFamily: Fontconstants.fc_family_sf,
                fontWeight: Fontconstants.SF_Pro_Display_Bold,
                color: Colors.white),
          ))),
    );
  }

  Widget commonWidgetforPlacesList({
    required String addressDescription,
    required String subAddress,
    required bool searchingState,
    required int index,
  }) {
    return Container(
      decoration: const BoxDecoration(
          // color: ColorName.ColorBagroundPrimary,
          /*       borderRadius: index == 0
              ? BorderRadius.only(
                  topRight: Radius.circular(12), topLeft: Radius.circular(12))
              : index == predictionList.length - 1
                  ? BorderRadius.only(
                      bottomRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12))
                  : BorderRadius.zero*/
          ),
      padding: const EdgeInsets.only(right: 10, left: 10, top: 0, bottom: 5),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: [
          const Icon(
            Icons.location_on,
            color: ColorName.ColorPrimary,
          ),
          10.toSpace,
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                addressDescription,
                style: Appwidgets().commonTextStyle(ColorName.black),
              ),
              subAddress == ""
                  ? const SizedBox.shrink()
                  : Text(
                      subAddress,
                      style: Appwidgets()
                          .commonTextStyle(ColorName.black)
                          .copyWith(fontSize: 15, fontWeight: FontWeight.w400),
                    ),
              /*prediction.terms!.length > 2
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prediction.terms![1].value!,
                                  style: Appwidgets()
                                      .commonTextStyle(ColorName.black)
                                      .copyWith(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400),
                                ),
                                prediction.terms!.length > 2
                                    ? Expanded(
                                        child: Text(
                                          ", ${prediction.terms![2].value!}",
                                          style: Appwidgets()
                                              .commonTextStyle(ColorName.black)
                                              .copyWith(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w400),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            )
                          : SizedBox.shrink(),*/
            ],
          ))
        ],
      ),
    );
  }

  Widget widgetForAddressDataWidget({
    required String addressDescription,
    required String subAddress,
  }) {
    return Container(
      height: 90,
      padding: const EdgeInsets.only(right: 10, left: 10, bottom: 5),
      decoration: const BoxDecoration(
          color: ColorName.ColorBagroundPrimary,
          borderRadius: BorderRadius.zero),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Center(
            child: Icon(
              Icons.location_on,
              color: ColorName.ColorPrimary,
            ),
          ),
          10.toSpace,
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                addressDescription,
                style: Appwidgets().commonTextStyle(ColorName.black),
              ),
              subAddress == ""
                  ? const SizedBox.shrink()
                  : Text(
                      subAddress,
                      style: Appwidgets()
                          .commonTextStyle(ColorName.black)
                          .copyWith(fontSize: 15, fontWeight: FontWeight.w400),
                    ),
              /*prediction.terms!.length > 2
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prediction.terms![1].value!,
                                  style: Appwidgets()
                                      .commonTextStyle(ColorName.black)
                                      .copyWith(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400),
                                ),
                                prediction.terms!.length > 2
                                    ? Expanded(
                                        child: Text(
                                          ", ${prediction.terms![2].value!}",
                                          style: Appwidgets()
                                              .commonTextStyle(ColorName.black)
                                              .copyWith(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w400),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            )
                          : SizedBox.shrink(),*/
            ],
          ))
        ],
      ),
    );
  }

  Widget goToLiveLocationWidget(context, state) {
    return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                locationBloc.handleLocationPermission(context);
                if (locationBloc.hasPermission == false) {
                  debugPrint("ROHITTTT 2cvnklbncv ");
                  isDialogOpen = false;
                  locationBloc.openSettingsDialog(
                      context: context, isDialogOpen: isDialogOpen);
                } else {
                  if (locationBloc.isFocus == true ||
                      locationBloc.focusNode.hasFocus) {
                    locationBloc.focusNode.unfocus();
                  }
                  debugPrint("ROhit 1183");
                  _debouncer.run(() {
                    locationBloc.settingSavedaddress = false;

                    locationBloc.getCurrentPosition(context);
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                width: Sizeconfig.getWidth(context) * .52,
                decoration: BoxDecoration(
                    boxShadow: [
                      const BoxShadow(
                          color: ColorName.black, blurStyle: BlurStyle.outer),
                      BoxShadow(
                          color: ColorName.black.withOpacity(.5),
                          blurStyle: BlurStyle.outer),
                      BoxShadow(
                          color: ColorName.black.withOpacity(.2),
                          blurStyle: BlurStyle.outer)
                    ],
                    color: ColorName.ColorBagroundPrimary,
                    border:
                        Border.all(color: ColorName.ColorPrimary, width: .5),
                    borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Icon(
                      Icons.gps_fixed,
                      size: 13,
                      color: ColorName.ColorPrimary,
                    ),
                    Text(
                      StringContants.lbl_go_toLive_Location,
                      style: Appwidgets()
                          .commonTextStyle(ColorName.ColorPrimary)
                          .copyWith(fontSize: 13, fontWeight: FontWeight.w500),
                    )
                  ],
                ),
              ),
            ),
            /* isLogin
                ? BlocBuilder(
                    bloc: changeAddressBloc,
                    builder: (context, state) {
                      return Container(
                          height: Sizeconfig.getHeight(context) * .55,
                          padding: EdgeInsets.zero,
                          margin: EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: ColorName.black,
                                blurStyle: BlurStyle.outer,
                              ),
                              BoxShadow(
                                color: Colors.black12,
                                blurStyle: BlurStyle.outer,
                              ),
                            ],
                            color: ColorName.ColorBagroundPrimary,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  "Saved Address",
                                  style: Appwidgets()
                                      .commonTextStyle(ColorName.black)
                                      .copyWith(fontSize: 20),
                                ),
                              ),
                              isLoading
                                  ? Shimmerui.addressListUi(context, 80)
                                  : addressListFromAPi.isEmpty
                                      ? Center(
                                          child: Text(
                                            "No Address Found",
                                            style: Appwidgets()
                                                .commonTextStyle(
                                                    ColorName.black)
                                                .copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 18,
                                                ),
                                          ),
                                        )
                                      : Container(
                                          height: 250,
                                          child: ListView.separated(
                                            physics: BouncingScrollPhysics(),
                                            separatorBuilder:
                                                (context, index) => Divider(
                                              height: .1,
                                            ),
                                            itemCount:
                                                addressListFromAPi.length,
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) {
                                              var addressData =
                                                  addressListFromAPi[index];
                                              return addressCard(
                                                  addressData: addressData);
                                            },
                                          ),
                                        ),
                            ],
                          ));
                    },
                  )
                : */
            state is GetCocoCodeState
                ? Shimmerui.locationloadingWidget(context)
                : state is NoLocationFoundState
                    ? noLocationFoundWidget(context, state)
                    : Container(
                        width: Sizeconfig.getWidth(context),
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        decoration: const BoxDecoration(
                            color: ColorName.ColorBagroundPrimary,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  StringContants.lbl_set_delivery_location,
                                  style: Appwidgets()
                                      .commonTextStyle(ColorName.black)
                                      .copyWith(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            5.toSpace,
                            state is LocationInitialState &&
                                    locationBloc
                                            .userCurrentCameraPosition.zoom ==
                                        .5
                                ? servingCitiesWidget()
                                : Container(
                                    padding: const EdgeInsets.all(10),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    decoration: BoxDecoration(
                                        color: ColorName.lightGreyShade
                                            .withOpacity(.3),
                                        border: Border.all(
                                            color: ColorName.lightGreyShade),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        locationBloc.userCurrentAddress == "" ||
                                                locationBloc.userState == "" ||
                                                locationBloc.usercity == ""
                                            ? Shimmerui
                                                .shimmer_for_locationMarker(
                                                    context, 40)
                                            : const Icon(
                                                Icons.location_on,
                                                color: ColorName.ColorPrimary,
                                              ),
                                        10.toSpace,
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            locationBloc.userCurrentAddress ==
                                                        "" ||
                                                    locationBloc.userState ==
                                                        "" ||
                                                    locationBloc.usercity == ""
                                                ? Shimmerui
                                                    .shimmer_for_street_and_city_location(
                                                        context, 100)
                                                : SizedBox(
                                                    width: Sizeconfig.getWidth(
                                                            context) *
                                                        .7,
                                                    child: Text(
                                                      locationBloc
                                                          .userCurrentAddress,
                                                      maxLines: 2,
                                                      style: Appwidgets()
                                                          .commonTextStyle(
                                                              ColorName.black)
                                                          .copyWith(
                                                              fontSize: 15),
                                                    ),
                                                  ),
                                            getLocationText(state) == ""
                                                ? const SizedBox.shrink()
                                                : Appwidgets.TextSmall(
                                                    getLocationText(state),
                                                    ColorName.black)
                                          ],
                                        ),
                                        const Spacer(),
                                        // locationBloc.token == ' '
                                        //     ? const SizedBox.shrink()
                                        //     : GestureDetector(
                                        //         onTap: () => locationBloc
                                        //             .addAddressDialog(
                                        //                 context),
                                        //         child: Icon(
                                        //           Icons.add_circle_outline,
                                        //           color: ColorName
                                        //               .ColorPrimary,
                                        //         ),
                                        //       )
                                      ],
                                    ),
                                  ),
                            Center(
                              child: useThisLocationButton(context),
                            ),
                          ],
                        ),
                      )
            /*widget.args == Routes.splashscreen
                        ? Container(
                            width: Sizeconfig.getWidth(context),
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            decoration: const BoxDecoration(
                                color: ColorName.ColorBagroundPrimary,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12))),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      StringContants.lbl_set_delivery_location,
                                      style: Appwidgets()
                                          .commonTextStyle(ColorName.black)
                                          .copyWith(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                                5.toSpace,
                                state is LocationInitialState &&
                                        locationBloc.userCurrentCameraPosition
                                                .zoom ==
                                            .5
                                    ? servingCitiesWidget()
                                    : Container(
                                        padding: const EdgeInsets.all(10),
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        decoration: BoxDecoration(
                                            color: ColorName.lightGreyShade
                                                .withOpacity(.3),
                                            border: Border.all(
                                                color:
                                                    ColorName.lightGreyShade),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            locationBloc.userCurrentAddress ==
                                                        "" ||
                                                    locationBloc.userState ==
                                                        "" ||
                                                    locationBloc.usercity == ""
                                                ? Shimmerui
                                                    .shimmer_for_locationMarker(
                                                        context, 40)
                                                : Icon(
                                                    Icons.location_on,
                                                    color:
                                                        ColorName.ColorPrimary,
                                                  ),
                                            10.toSpace,
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                locationBloc
                                                                .userCurrentAddress ==
                                                            "" ||
                                                        locationBloc
                                                                .userState ==
                                                            "" ||
                                                        locationBloc.usercity ==
                                                            ""
                                                    ? Shimmerui
                                                        .shimmer_for_street_and_city_location(
                                                            context, 100)
                                                    : SizedBox(
                                                        width:
                                                            Sizeconfig.getWidth(
                                                                    context) *
                                                                .7,
                                                        child: Text(
                                                          locationBloc
                                                              .userCurrentAddress,
                                                          maxLines: 2,
                                                          style: Appwidgets()
                                                              .commonTextStyle(
                                                                  ColorName
                                                                      .black)
                                                              .copyWith(
                                                                  fontSize: 15),
                                                        ),
                                                      ),
                                                getLocationText(state) == ""
                                                    ? const SizedBox.shrink()
                                                    : Appwidgets.TextSmall(
                                                        getLocationText(state),
                                                        ColorName.black)
                                              ],
                                            ),
                                            Spacer(),
                                            // locationBloc.token == ' '
                                            //     ? const SizedBox.shrink()
                                            //     : GestureDetector(
                                            //         onTap: () => locationBloc
                                            //             .addAddressDialog(
                                            //                 context),
                                            //         child: Icon(
                                            //           Icons.add_circle_outline,
                                            //           color: ColorName
                                            //               .ColorPrimary,
                                            //         ),
                                            //       )
                                          ],
                                        ),
                                      ),
                                Center(
                                  child: useThisLocationButton(context),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            width: Sizeconfig.getWidth(context),
                            margin: EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              color: ColorName.ColorBagroundPrimary,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Appwidgets.Text_20(
                                      StringContants.lbl_delivering_your_order,
                                      ColorName.black),
                                ),
                                Divider(
                                  height: 1,
                                  color: ColorName.lightGey,
                                  thickness: 1,
                                ),
                                Container(
                                  margin: EdgeInsets.all(10),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: ColorName.lightGreyShade
                                          .withOpacity(.3),
                                      border: Border.all(
                                          color: ColorName.lightGreyShade),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      locationBloc.userCurrentAddress == "" ||
                                              locationBloc.usercity == "" ||
                                              locationBloc.userState == ""
                                          ? Shimmerui
                                              .shimmer_for_locationMarker(
                                                  context, 50)
                                          : Image.asset(
                                              Imageconstants.location_icon,
                                              height: 50,
                                              width: 50,
                                            ),
                                      10.toSpace,
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          locationBloc.userCurrentAddress ==
                                                      "" ||
                                                  locationBloc.usercity == "" ||
                                                  locationBloc.userState == ""
                                              ? Shimmerui
                                                  .shimmer_for_street_and_city_location(
                                                      context, 100)
                                              : SizedBox(
                                                  width: Sizeconfig.getWidth(
                                                          context) *
                                                      .5,
                                                  child: Text(
                                                      locationBloc
                                                          .userCurrentAddress,
                                                      maxLines: 2,
                                                      style: Appwidgets()
                                                          .commonTextStyle(
                                                              ColorName
                                                                  .ColorPrimary)
                                                          .copyWith(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          )),
                                                ),
                                          4.toSpace, // Adjust spacing as needed
                                          getLocationText(state) == "" ||
                                                  locationBloc
                                                          .userCurrentAddress ==
                                                      "" ||
                                                  locationBloc.usercity == "" ||
                                                  locationBloc.userState == ""
                                              ? const SizedBox.shrink()
                                              : Text(getLocationText(state),
                                                  maxLines: 2,
                                                  style: Appwidgets()
                                                      .commonTextStyle(ColorName
                                                          .ColorPrimary)
                                                      .copyWith(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      )),
                                        ],
                                      ),
                                      Spacer(),
                                      // locationBloc.token == ' ' ||
                                      //         widget.args ==
                                      //             Routes.change_address
                                      //     ? const SizedBox.shrink()
                                      //     : GestureDetector(
                                      //         onTap: () => locationBloc
                                      //             .addAddressDialog(context),
                                      //         child: const Icon(
                                      //           Icons.add_circle_outline,
                                      //           color: ColorName.ColorPrimary,
                                      //         ),
                                      //       )
                                    ],
                                  ),
                                ),
                                Center(
                                  child: useThisLocationButton(context),
                                ),
                              ],
                            ),
                          )*/
            ,
          ],
        ));
  }

  Widget addressCard({required AddressData addressData}) {
    String userAddress = '';
    if (addressData.title == "" && addressData.subtitle == "") {
      userAddress = "${addressData.address1!} ${addressData.address2!}";
    } else {
      userAddress = "${addressData.title} ${addressData.subtitle}";
    }
    return InkWell(
      onTap: () {
        log("Selected Address Data ${addressData.toJson()}");
        isAddressDialogOpen = false;
        locationBloc.settingSavedaddress = true;
        locationBloc.shouldIAnimate = false;
        if (addressData.subtitle == null ||
            addressData.subtitle == "null" ||
            addressData.subtitle == "") {
          locationBloc.userCurrentAddress = userAddress;
        } else {
          locationBloc.userCurrentAddress = addressData.subtitle ?? "";
        }
        // locationBloc.street = addressData.subtitle ?? "";
        locationBloc.userState = addressData.zone ?? "";
        locationBloc.usercity = addressData.city ?? "";
        double lat = double.parse(addressData.latitude ?? "0.0");
        double long = double.parse(addressData.longitude ?? "0.0");
        debugPrint("STREET ${locationBloc.street}");
        debugPrint(
            "userCurrentAddressuserCurrentAddress ${locationBloc.userCurrentAddress}");
        debugPrint("STATE ${locationBloc.userState}");
        debugPrint("CITY ${locationBloc.usercity}");
        locationBloc.selectedAddressData = addressData;
        locationBloc.userCurrentCameraPosition =
            CameraPosition(target: LatLng(lat, long));
        if (locationBloc.userCurrentAddress.trim().isNotEmpty &&
            locationBloc.userState.trim().isNotEmpty &&
            locationBloc.usercity.trim().isNotEmpty) {
          // locationBloc.initialStage = false;

          _debouncer.run(() {
            locationBloc.useThisLocation(context);
          });
        } else {}
        // if (widget.args == Routes.change_address) {
        //   var addressData = {
        //     "latitude": locationBloc.userCurrentCameraPosition.target.latitude,
        //     "longitude":
        //         locationBloc.userCurrentCameraPosition.target.longitude,
        //     "userCurrentAddress": locationBloc.userCurrentAddress,
        //     "city": locationBloc.usercity,
        //     "state": locationBloc.userState,
        //     "postalCode": locationBloc.postalCode
        //   };
        //   Navigator.pop(context, addressData);
        // } else {
        //
        // }

        // Navigator.pop(context);
        // locationBloc.userCurrentCameraPosition = CameraPosition(
        //     zoom: Constants.MAP_ZOOM_LEVEL,
        //     target: LatLng(double.parse(addressData.latitude ?? "0.0"),
        //         double.parse(addressData.longitude ?? "0.0")));
        // locationBloc.animatetoSearchedPlace(
        //     double.parse(addressData.latitude ?? "0.0"),
        //     double.parse(addressData.longitude ?? "0.0"));
        // locationBloc
        //     .add(CurrentLocationEvent(locationBloc.userCurrentCameraPosition));
      },
      child: Container(
        color: ColorName.ColorBagroundPrimary,
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  // Imageconstants.briefCaseIcon,
                  getIconPath(addressType: addressData.addressType ?? ""),
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
              ],
            ),
            // 4.toSpace,
            // Text(
            //   "${addressData.firstname} ${addressData.lastname}",
            //   style: Appwidgets().commonTextStyle(ColorName.black).copyWith(
            //       fontWeight: Fontconstants.SF_Pro_Display_Regular,
            //       fontSize: 15),
            // ),
            4.toSpace,
            addressData.flatSectorApartment == ""
                ? const SizedBox.shrink()
                : Text(
                    "${addressData.flatSectorApartment}",
                    maxLines: 1,
                    style: Appwidgets()
                        .commonTextStyle(ColorName.black)
                        .copyWith(
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
              width: Sizeconfig.getWidth(context),
              child: Text(
                userAddress /*addressData.subtitle == null ||
                        addressData.subtitle == "null" ||
                        addressData.subtitle == ""
                    ? userAddress
                    : addressData.subtitle!*/
                ,
                maxLines: 3,
                textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: true,
                    applyHeightToLastDescent: true,
                    leadingDistribution: TextLeadingDistribution.even),
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
        //                         debugPrint(
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
        //                         // debugPrint("CHANGE ADDRESS SCREEN ${data}");
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

  String getIconPath({required String addressType}) {
    return addressType == "Work"
        ? Imageconstants.briefCaseIcon
        : addressType == "Other"
            ? Imageconstants.address_type_other
            : Imageconstants.home_icon;
  }

  Widget servingCitiesWidget() {
    return Column(
      children: [
        Appwidgets.Text_15("We Are Serving in Following Cities",
            ColorName.black.withOpacity(.5), TextAlign.center),
        Appwidgets.Text_15("Bhopal, Indore, Lucknow, Jabalpur, Satna",
            ColorName.black, TextAlign.center),
      ],
    );
  }

  Widget noLocationFoundWidget(context, NoLocationFoundState state) {
    return Container(
      width: Sizeconfig.getWidth(context),
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: const BoxDecoration(
          color: ColorName.ColorBagroundPrimary,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          10.toSpace,
          Text(
            state.noLocationFoundText.replaceAll(".", ""),
            style: Appwidgets().commonTextStyle(ColorName.black),
          ),
          8.toSpace,
          Text(
            StringContants.lbl_ondoor_isNot_Available,
            textAlign: TextAlign.center,
            style: Appwidgets()
                .commonTextStyle(ColorName.black)
                .copyWith(fontWeight: FontWeight.w500, fontSize: 12),
          ),
          8.toSpace,
          SizedBox(
            height: 45,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Appwidgets().buttonPrimary(
                StringContants.lbl_go_toLive_Location,
                () {
                  debugPrint("ROHITTTT");
                  OndoorThemeData.keyBordDow();
                  debugPrint("ROhit 1841");

                  _debouncer.run(() {
                    locationBloc.settingSavedaddress = false;
                    locationBloc.getCurrentPosition(context);
                  });
                },
              ),
            ),
          ),
          8.toSpace,
          GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus!
                  .requestFocus(locationBloc.focusNode);
            },
            child: Text(
              "Select Location Manually",
              style: Appwidgets().commonTextStyle(ColorName.ColorPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget markerWidget() {
    return Align(
      alignment: Alignment.center,
      child: Image.asset(
        Imageconstants.markerImage,
        height: 50,
        width: 50,
      ),
    );
  }

  String getLocationText(state) {
    return state is CurrentLocationState
        ? locationBloc.usercity == "" ||
                locationBloc.userCurrentAddress == locationBloc.usercity
            ? locationBloc.userState
            : locationBloc.userState == ""
                ? locationBloc.usercity
                : "${locationBloc.usercity}, ${locationBloc.userState}"
        : "";
  }
}
