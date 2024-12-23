import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ondoor/constants/StringConstats.dart';
import 'package:ondoor/database/dbconstants.dart';
import 'package:ondoor/models/get_city_response.dart';
import 'package:ondoor/screens/location_screen/location_bloc/location_bloc.dart';
import 'package:ondoor/services/Navigation/routes.dart';
import 'package:ondoor/utils/Connection.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/sharedpref.dart';
import 'package:ondoor/utils/themeData.dart';
import 'package:ondoor/widgets/MyDialogs.dart';

import '../constants/Constant.dart';
import '../database/database_helper.dart';
import '../services/ApiServices.dart';
import '../utils/SizeConfig.dart';
import '../utils/colors.dart';
import 'AppWidgets.dart';
import 'common_box_widget.dart';

class UserLocationDialog extends StatefulWidget {
  String flat_Sector_apartMent;
  String houseAddress;
  String cityName;
  String pinCode;
  String landmark;
  String state;
  String firstName;
  String lastName;
  String latitude;
  String longitude;
  String action;
  String routeName;
  String addresstype;
  String addressID;
  UserLocationDialog({
    super.key,
    required this.flat_Sector_apartMent,
    required this.houseAddress,
    required this.cityName,
    required this.firstName,
    required this.lastName,
    required this.pinCode,
    required this.landmark,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.action,
    required this.routeName,
    required this.addresstype,
    required this.addressID,
  });

  @override
  State<UserLocationDialog> createState() => _UserLocationDialogState();
}

class _UserLocationDialogState extends State<UserLocationDialog> {
  List<String> addressLabelList = [];
  TextEditingController houseAddressController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController addressDetailController = TextEditingController();
  TextEditingController pinCodecontroller = TextEditingController();
  TextEditingController landMarkController = TextEditingController();
  List<CityData> cityList = [];
  CityData selectedCity = CityData();
  String selectedLabel = "";
  // String firstName = "";
  // String lastName = "";
  String customer_id = "";
  String companyName = "";
  Map<String, dynamic> addressDataFromLocationScreen = {};
  final dbHelper = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    initializedDb();
    addressLabelList.add("Home");
    addressLabelList.add("Work");
    addressLabelList.add("Other");
    selectedLabel = addressLabelList[0];
    houseAddressController.text = widget.flat_Sector_apartMent;
    firstNameController.text = widget.firstName;
    lastNameController.text = widget.lastName;
    if (widget.action != "Add") {
      addressDetailController.text = widget.houseAddress;
    }
    if (widget.routeName == Routes.location_screen) {
      addressDetailController.text = widget.houseAddress;
    }
    landMarkController.text = widget.landmark;
    pinCodecontroller.text = widget.pinCode;

    if (widget.routeName == Routes.change_address) {
      setState(() {
        selectedLabel = widget.addresstype;
      });
    }
    readUserDetails();
    super.initState();
  }

  readUserDetails() async {
    // firstName = await SharedPref.getStringPreference(Constants.sp_FirstNAME);
    // lastName = await SharedPref.getStringPreference(Constants.sp_LastName);
    customer_id = await SharedPref.getStringPreference(Constants.sp_CustomerId);
    companyName =
        await SharedPref.getStringPreference(Constants.sp_Company_Name);
    // Constants.sp_FirstNAME
    // Constants.sp_LastName,
  }

  initializedDb() async {
    await dbHelper.init();
    if (await Network.isConnected()) {
      var cityListApi = await ApiProvider().getCityListApi();
      setState(() {
        cityList = cityListApi.data!;

        for (var cityData in cityList) {
          if (cityData.name.toString() == widget.cityName) {
            selectedCity = cityData;
            pinCodecontroller.text = widget.pinCode;
            break;
          } else {}
        }
        // if (cityMatched) {
        int index = cityList.indexWhere(
          (element) {
            return element.name == selectedCity.name;
          },
        );
        selectedCity = cityList[index];
        // } else {
        //   selectedCity = cityList[0];
        // }
      });
    } else {
      MyDialogs.showInternetDialog(context, () {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: PopScope(
        canPop: true,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            // padding: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
                color: ColorName.ColorBagroundPrimary,
                borderRadius: BorderRadius.circular(10)),
            width: Sizeconfig.getWidth(context),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Wrap(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          25.toSpace,
                          Spacer(),
                          Center(
                            child: Appwidgets.Text_20(
                                "Enter Complete Address", ColorName.black),
                          ),
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(
                                  Icons.close,
                                  color: ColorName.black,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1,
                      color: ColorName.lightGey,
                      thickness: 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          5.toSpace,
                          commonLabelWidget(
                              "${StringContants.lbl_first_name} *",
                              EdgeInsets.zero),
                          5.toSpace,
                          Appwidgets.commonTextForField(
                            onTap: () {},
                            maxLength: 80,
                            maxlines: 1,
                            context: context,
                            controller: firstNameController,
                            hintText: StringContants.lbl_first_name,
                            textInputType: TextInputType.text,
                            validatorFunc: (p0) {
                              if (p0!.trim().isEmpty) {
                                return 'Please enter valid data';
                              }
                            },
                          ),
                          5.toSpace,
                          commonLabelWidget("${StringContants.lbl_last_name} *",
                              EdgeInsets.zero),
                          5.toSpace,
                          Appwidgets.commonTextForField(
                            onTap: () {},
                            maxLength: 80,
                            maxlines: 1,
                            context: context,
                            controller: lastNameController,
                            hintText: StringContants.lbl_last_name,
                            textInputType: TextInputType.text,
                            validatorFunc: (p0) {
                              if (p0!.trim().isEmpty) {
                                return 'Please enter valid data';
                              }
                            },
                          ),
                          5.toSpace,
                          commonLabelWidget(
                              "${StringContants.lbl_flat_house_building_number} *",
                              EdgeInsets.zero),
                          5.toSpace,
                          Appwidgets.commonTextForField(
                            onTap: () {},
                            maxLength: 80,
                            maxlines: 1,
                            context: context,
                            controller: houseAddressController,
                            hintText:
                                StringContants.lbl_flat_house_building_number,
                            textInputType: TextInputType.text,
                            validatorFunc: (p0) {
                              if (p0!.trim().isEmpty) {
                                return 'Please enter valid info';
                              }
                            },
                          ),
                          5.toSpace,
                          commonLabelWidget(
                              "${StringContants.lbl_address_detail} *",
                              EdgeInsets.zero),
                          5.toSpace,
                          Appwidgets.commonTextForField(
                              onTap: () async {
                                if (addressDetailController.text == "") {
                                  OndoorThemeData.keyBordDow();
                                  var data = await Navigator.pushNamed(
                                      context, Routes.location_screen,
                                      arguments: Routes.change_address);
                                  if (data != null) {
                                    FocusManager.instance.primaryFocus!
                                        .requestFocus();

                                    addressDataFromLocationScreen =
                                        data as Map<String, dynamic>;
                                    GetCityResponse cityListApi =
                                        GetCityResponse();
                                    if (await Network.isConnected()) {
                                      cityListApi =
                                          await ApiProvider().getCityListApi();
                                      setState(() {
                                        cityList = cityListApi.data!;
                                        addressDetailController.text =
                                            addressDataFromLocationScreen[
                                                'userCurrentAddress'];
                                        pinCodecontroller.text =
                                            addressDataFromLocationScreen[
                                                'postalCode'];
                                        selectedCity.name =
                                            addressDataFromLocationScreen[
                                                "city"];
                                        widget.state =
                                            addressDataFromLocationScreen[
                                                'state'];
                                        widget.latitude =
                                            addressDataFromLocationScreen[
                                                    'latitude']
                                                .toString();
                                        widget.longitude =
                                            addressDataFromLocationScreen[
                                                    'longitude']
                                                .toString();

                                        if (cityList.isNotEmpty) {
                                          for (var cityData in cityList) {
                                            if (selectedCity.name ==
                                                cityData.name) {
                                              selectedCity.locationId =
                                                  cityData.locationId;
                                              selectedCity = cityData;

                                              break;
                                            }
                                          }
                                        }

                                        landMarkController.text = '';
                                        // houseAddressController.text = "";
                                      });
                                    } else {
                                      MyDialogs.showInternetDialog(context, () {
                                        Navigator.pop(context);
                                      });
                                    }
                                  } else {
                                    await Navigator.pushNamed(
                                        context, Routes.location_screen,
                                        arguments: Routes.change_address);
                                  }
                                } else {}
                              },
                              maxlines: 1,
                              controller: addressDetailController,
                              hintText:
                                  "${StringContants.lbl_address_detail} *",
                              context: context,
                              maxLength: 50,
                              textInputType: TextInputType.text,
                              validatorFunc: (p0) {
                                if (p0!.trim().isEmpty) {
                                  return 'Please enter valid';
                                }
                              }),
                          5.toSpace,
                          commonLabelWidget("${StringContants.lbl_landMark}",
                              EdgeInsets.zero),
                          5.toSpace,
                          Appwidgets.commonTextForField(
                              maxlines: 1,
                              controller: landMarkController,
                              hintText: "${StringContants.lbl_landMark}",
                              context: context,
                              maxLength: 50,
                              textInputType: TextInputType.text,
                              validatorFunc: (p0) {
                                // if (p0!.isEmpty) {
                                //   return 'Please enter valid landmark';
                                // }
                              }),
                          5.toSpace,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    commonLabelWidget(
                                        "${StringContants.lbl_city} *",
                                        EdgeInsets.zero),
                                    10.toSpace,
                                    Container(
                                      height: 50,
                                      width: Sizeconfig.getWidth(context),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: ColorName.lightGey,
                                              width: 1),
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                      child: Center(
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<CityData>(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            value: selectedCity,
                                            onChanged: (newValue) {
                                              setState(() {
                                                selectedCity = newValue!;
                                              });
                                            },
                                            icon: SizedBox(),
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12.0),
                                            selectedItemBuilder:
                                                (BuildContext context) {
                                              return cityList
                                                  .map((CityData value) {
                                                return SizedBox(
                                                  width: Sizeconfig.getWidth(
                                                          context) *
                                                      .35,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Appwidgets.Text_12(
                                                          value.name!,
                                                          ColorName.black),
                                                      Icon(
                                                        Icons
                                                            .keyboard_arrow_down,
                                                        color: ColorName.black,
                                                      )
                                                    ],
                                                  ),
                                                );
                                              }).toList();
                                            },
                                            items: cityList.map<
                                                    DropdownMenuItem<CityData>>(
                                                (CityData value) {
                                              return DropdownMenuItem<CityData>(
                                                value: value,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 5),
                                                  child: Appwidgets.Text_12(
                                                      value.name!,
                                                      ColorName.black),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    /*     Appwidgets.commonTextForField(
                                        maxlines: 1,
                                        controller: cityNameController,
                                        maxLength: 10,
                                        hintText: StringContants.lbl_city,
                                        textInputType: TextInputType.text,
                                        validatorFunc: (p0) {
                                          if (p0!.isEmpty) {
                                            return 'Please enter valid City';
                                          }
                                        })*/
                                  ],
                                ),
                              ),
                              10.toSpace,
                              Expanded(
                                flex: 2,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    commonLabelWidget(
                                        "${StringContants.lbl_pincode} *",
                                        EdgeInsets.zero),
                                    10.toSpace,
                                    Appwidgets.commonTextForField(
                                        controller: pinCodecontroller,
                                        maxlines: 1,
                                        context: context,
                                        hintText: StringContants.lbl_pincode,
                                        maxLength: 6,
                                        textInputType: TextInputType.number,
                                        validatorFunc: (p0) {
                                          if (p0!.trim().isEmpty) {
                                            return 'Please Enter\npincode';
                                          } else if (p0!.trim() == "000000" ||
                                              p0!.trim().length != 6) {
                                            return 'Please Enter\n valid pincode';
                                          }
                                        })
                                  ],
                                ),
                              ),
                            ],
                          ),
                          5.toSpace,
                          commonLabelWidget(
                              StringContants.lbl_labelAs, EdgeInsets.zero),
                          5.toSpace,
                          SizedBox(
                            height: 30,
                            width: Sizeconfig.getWidth(context),
                            child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: addressLabelList.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedLabel = addressLabelList[index];
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                        color: addressLabelList[index] ==
                                                selectedLabel
                                            ? ColorName.ColorPrimary
                                            : ColorName.ColorBagroundPrimary,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: addressLabelList[index] ==
                                                    selectedLabel
                                                ? ColorName.ColorPrimary
                                                : ColorName.lightGey)),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 2, horizontal: 15),
                                    child: Center(
                                      child: Appwidgets.Text_15(
                                          addressLabelList[index],
                                          addressLabelList[index] ==
                                                  selectedLabel
                                              ? ColorName.ColorBagroundPrimary
                                              : ColorName.black,
                                          TextAlign.center),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          5.toSpace
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          if (widget.routeName == Routes.change_address) {
                            if (widget.action == "Update") {
                              updateAddress(context);
                            } else if (widget.action == "Add") {
                              addAddress(context);
                            }
                          } else {
                            addAddress(context);
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: ColorName.ColorPrimary,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Appwidgets.Text_15(
                              widget.routeName == Routes.change_address
                                  ? "${widget.action} Address"
                                  : StringContants.lbl_Save_Address,
                              ColorName.ColorBagroundPrimary,
                              TextAlign.center),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget commonLabelWidget(String labelName, EdgeInsetsGeometry padding) {
    return Padding(
      padding: padding,
      child: Appwidgets.Text_12(labelName, ColorName.black),
    );
  }

  //function to add Address Via Api
  void addAddress(BuildContext context) async {
    if (await Network.isConnected()) {
      var body = {
        "customer_id": customer_id,
        "firstname": firstNameController.text.trim(),
        "lastname": lastNameController.text.trim(),
        "company": companyName,
        "flat_sector_apartment": houseAddressController.text,
        "landmark": landMarkController.text,
        "postcode": pinCodecontroller.text,
        "city": selectedCity.name!,
        "country_id": "",
        "zone_id": "1492",
        "state": widget.state,
        "custom_field": "",
        "location_id": selectedCity.locationId,
        "latitude": widget.latitude,
        "longitude": widget.longitude,
        "area_detail": addressDetailController.text,
        "address_type": selectedLabel
      };
      var result = await ApiProvider().addAddressApi(body, () {
        addAddress(context);
      });
      if (result.success == true) {
        Appwidgets.showToastMessagefromHtml(result.message!);
        Navigator.pop(context, result.success!);
        // Navigator.pop(context, result.message ?? "");
        // Navigator.pushNamed(context, result.message!);
      } else {
        Navigator.pop(context, false);
        if (result.data != null) {
          Appwidgets.showToastMessagefromHtml(result.data!);
        }
      }
    } else {
      MyDialogs.showInternetDialog(context, () {
        Navigator.pop(context);
      });
    }
  }

  //function to add Address Via Api
  void updateAddress(BuildContext context) async {
    if (await Network.isConnected()) {
      var body = {
        "customer_id": customer_id,
        "firstname": firstNameController.text,
        "lastname": lastNameController.text,
        "company": companyName,
        "location_id": selectedCity.locationId,
        "address_id": widget.addressID,
        "flat_sector_apartment": houseAddressController.text,
        "landmark": landMarkController.text,
        "postcode": pinCodecontroller.text,
        "city": selectedCity.name!,
        "country_id": "",
        "zone_id": "1492",
        "state": widget.state,
        "custom_field": "",
        "latitude": widget.latitude,
        "longitude": widget.longitude,
        "area_detail": addressDetailController.text,
        "address_type": selectedLabel
      };
      print("BODY ${body}");

      var result = await ApiProvider().addAddressApi(body, () {
        addAddress(context);
      });
      if (result.success == true) {
        Appwidgets.showToastMessagefromHtml(result.message!);
        Navigator.pop(context, result.message!);
      } else {
        Navigator.pop(context, false);
      }
    } else {
      MyDialogs.showInternetDialog(context, () {
        Navigator.pop(context);
      });
    }
  }
}
