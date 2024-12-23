import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondoor/constants/StringConstats.dart';
import 'package:ondoor/models/contact_us_reason_list_response.dart';
import 'package:ondoor/models/contact_us_response.dart';
import 'package:ondoor/models/get_latest_order_response.dart';
import 'package:ondoor/screens/contact_us_screen/contact_us_bloc/contact_us_bloc.dart';
import 'package:ondoor/screens/contact_us_screen/contact_us_bloc/contact_us_event.dart';
import 'package:ondoor/screens/contact_us_screen/contact_us_bloc/contact_us_state.dart';
import 'package:ondoor/services/ApiServices.dart';
import 'package:ondoor/services/Navigation/routes.dart';
import 'package:ondoor/utils/Connection.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/colors.dart';
import 'package:ondoor/widgets/AppWidgets.dart';
import 'package:ondoor/widgets/MyDialogs.dart';
import 'package:ondoor/widgets/common_loading_widget.dart';

import '../../constants/Constant.dart';
import '../../utils/sharedpref.dart';
import 'package:html/parser.dart' show parse;

class ContactUsScreen extends StatefulWidget {
  String userName = "";
  String email = "";
  String telephone = "";
  ContactUsScreen(
      {super.key,
      required this.userName,
      required this.email,
      required this.telephone});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  Contact_Us_Bloc contact_us_bloc = Contact_Us_Bloc();
  List<ContactUsReasonCategory> reasonCategoryList = [];
  List<ContactUsReasonSubCategory> reasonsubCategoryList = [];
  List<LatestOrderData> latestOrderdata = [];
  ContactUsReasonCategory? selectedCategory;
  ContactUsReasonSubCategory? selectedsubCategory;
  LatestOrderData? selectedOrderData;
  String selectedReasonCategory = '';
  String description = '';
  bool isLoading = false;
  TextEditingController commentController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    callReasonlistApi();
    // getLatestOrder();
    super.initState();
  }

  callReasonlistApi() async {
    if (await Network.isConnected()) {
      contact_us_bloc.add(ContactUsLoadingEvent());
      ContactUsReasonListResponse contactUsReasonListResponse =
          await ApiProvider().getContactReasons();
      description = contactUsReasonListResponse.description!;

      reasonCategoryList = contactUsReasonListResponse.categories!;
      // selectedCategory = reasonCategoryList.first;
      contact_us_bloc.add(ContactUsInitialEvent());
    } else {
      MyDialogs.showInternetDialog(context, () {
        Navigator.pop(context);
        callReasonlistApi();
      });
    }
  }

  getOrderData(String id) async {
    if (await Network.isConnected()) {
      GetLatestOrderResponse getLatestOrderResponse =
          await ApiProvider().getLatestOrderResponse(id, () {
        getOrderData(id);
      });
      if (getLatestOrderResponse.data is List) {
        latestOrderdata = getLatestOrderResponse.data!;

        if (latestOrderdata.isNotEmpty) {
          contact_us_bloc.add(ContactUsInitialEvent());
        } else {
          var data = parse(getLatestOrderResponse.message ?? "");
          Appwidgets.showToastMessage(data.body!.text ?? "");
          contact_us_bloc.add(ContactUsInitialEvent());
        }
      } else {
        Appwidgets.showToastMessage(getLatestOrderResponse.message!);
        print("MESSAGE FROM LATEST ORDER 1 ${getLatestOrderResponse.message}");
        contact_us_bloc.add(ContactUsInitialEvent());
      }
    } else {
      MyDialogs.showInternetDialog(context, () {
        Navigator.pop(context);
        getOrderData(id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: contact_us_bloc,
      builder: (context, state) {
        Appwidgets.setStatusBarColor();

        print("selectedCategory  ${selectedCategory?.toJson()}");
        if (state is First_Reason_Selected_State) {
          isLoading = false;
          selectedCategory = state.selectedCategory;
          selectedsubCategory = null;
          selectedOrderData = null;
          reasonsubCategoryList = selectedCategory!.subCategories!;
        }
        if (state is Second_Reason_Selected_State) {
          isLoading = false;
          selectedsubCategory = state.selectedSubCategory;
          selectedOrderData = null;
          getOrderData(selectedsubCategory!.id!);
        }
        if (state is Order_ID_Selected_State) {
          isLoading = false;
          selectedOrderData = state.selectedOrderData;
        }
        if (state is ContactUsInitialState) {
          isLoading = false;
        }
        if (state is ContactUsLoadingState) {
          isLoading = true;
        }

        return SafeArea(
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: Appwidgets.MyAppBar(
                context, StringContants.lbl_contact_us, () {}),
            body: isLoading
                ? const CommonLoadingWidget()
                : Padding(
                    padding: const EdgeInsets.all(10),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello ${widget.userName}",
                            style: Appwidgets()
                                .commonTextStyle(ColorName.black)
                                .copyWith(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "how may we help you?",
                            style: Appwidgets()
                                .commonTextStyle(ColorName.mediumGrey)
                                .copyWith(
                                    fontSize: 23, fontWeight: FontWeight.bold),
                          ),
                          5.toSpace,
                          Text(
                            description,
                            style: Appwidgets()
                                .commonTextStyle(ColorName.black)
                                .copyWith(
                                    fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                          5.toSpace,
                          selectedCategory?.name == null ||
                                  selectedCategory?.name == ""
                              ? const SizedBox.shrink()
                              : Text(
                                  "Reason",
                                  style: Appwidgets()
                                      .commonTextStyle(ColorName.black)
                                      .copyWith(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600),
                                ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: ColorName.mediumGrey)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<ContactUsReasonCategory>(
                                  value: selectedCategory,
                                  hint: Text(
                                    "Please Select Reason",
                                    style: Appwidgets()
                                        .commonTextStyle(ColorName.mediumGrey)
                                        .copyWith(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400),
                                  ),
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: selectedCategory?.name == null ||
                                            selectedCategory?.name == ""
                                        ? ColorName.lightGey
                                        : ColorName.black,
                                  ),
                                  isExpanded: true,
                                  items: reasonCategoryList == null ||
                                          reasonCategoryList.isEmpty
                                      ? []
                                      : reasonCategoryList
                                          .map((ContactUsReasonCategory items) {
                                          return DropdownMenuItem(
                                            value: items,
                                            child: Text(
                                              items.name!,
                                              style: Appwidgets()
                                                  .commonTextStyle(
                                                      ColorName.black)
                                                  .copyWith(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500),
                                            ),
                                          );
                                        }).toList(),
                                  onChanged:
                                      (ContactUsReasonCategory? newValue) {
                                    // dropdownvalue = newValue!;
                                    if (newValue!.name !=
                                        "Please Select Category") {
                                      selectedCategory = newValue!;
                                      contact_us_bloc.add(
                                          First_Reason_Selected_Event(
                                              selectedCategory:
                                                  selectedCategory!));
                                    } else {}
                                  }),
                            ),
                          ),
                          selectedsubCategory?.name == null ||
                                  selectedsubCategory?.name == ""
                              ? const SizedBox.shrink()
                              : Text(
                                  "Description",
                                  style: Appwidgets()
                                      .commonTextStyle(ColorName.black)
                                      .copyWith(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600),
                                ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: ColorName.mediumGrey)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<ContactUsReasonSubCategory>(
                                  hint: Text(
                                    "Please Tell us More",
                                    style: Appwidgets()
                                        .commonTextStyle(ColorName.mediumGrey)
                                        .copyWith(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400),
                                  ),
                                  isExpanded: true,
                                  value: selectedsubCategory,
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: selectedsubCategory?.name == null ||
                                            selectedsubCategory?.name == ""
                                        ? ColorName.lightGey
                                        : ColorName.black,
                                  ),
                                  items: reasonsubCategoryList.isEmpty
                                      ? []
                                      : reasonsubCategoryList.map(
                                          (ContactUsReasonSubCategory items) {
                                          return DropdownMenuItem(
                                            value: items,
                                            child: Text(
                                              items.name!,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: Appwidgets()
                                                  .commonTextStyle(
                                                      ColorName.black)
                                                  .copyWith(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500),
                                            ),
                                          );
                                        }).toList(),
                                  onChanged:
                                      (ContactUsReasonSubCategory? newValue) {
                                    selectedsubCategory = newValue!;

                                    contact_us_bloc.add(
                                        Second_Reason_Selected_Event(
                                            selectedSubCategory:
                                                selectedsubCategory!));
                                  }),
                            ),
                          ),
                          selectedOrderData?.name == null ||
                                  selectedOrderData?.name == "" ||
                                  selectedsubCategory?.orderidRequired == "0"
                              ? const SizedBox.shrink()
                              : Text(
                                  "Order ID",
                                  style: Appwidgets()
                                      .commonTextStyle(ColorName.black)
                                      .copyWith(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600),
                                ),
                          selectedsubCategory?.orderidRequired == "0" ||
                                  latestOrderdata.isEmpty
                              ? const SizedBox.shrink()
                              : Container(
                                  width: double.infinity,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: ColorName.mediumGrey)),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<LatestOrderData>(
                                        hint: Text(
                                          "Please Select Order ID",
                                          style: Appwidgets()
                                              .commonTextStyle(
                                                  ColorName.mediumGrey)
                                              .copyWith(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w400),
                                        ),
                                        value: selectedOrderData,
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: selectedOrderData?.name ==
                                                      null ||
                                                  selectedOrderData?.name == ""
                                              ? ColorName.lightGey
                                              : ColorName.black,
                                        ),
                                        items: latestOrderdata
                                            .map((LatestOrderData items) {
                                          return DropdownMenuItem(
                                            value: items,
                                            child: HtmlWidget(
                                              items.name ?? "",
                                              textStyle: Appwidgets()
                                                  .commonTextStyle(
                                                      ColorName.black)
                                                  .copyWith(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (LatestOrderData? newValue) {
                                          selectedOrderData = newValue!;
                                          contact_us_bloc.add(
                                              Order_ID_Selected_Event(
                                                  selectedOrderData:
                                                      selectedOrderData!));
                                        }),
                                  ),
                                ),
                          5.toSpace,
                          TextFormField(
                            controller: commentController,
                            maxLength: 250,
                            maxLines: 6,
                            style:
                                Appwidgets().commonTextStyle(ColorName.black),
                            keyboardType: TextInputType.text,
                            scrollPadding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom +
                                        20),
                            decoration: InputDecoration(
                                hintText: "Comment",
                                errorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: ColorName.mediumGrey, width: 1),
                                    borderRadius: BorderRadius.circular(6)),
                                counterText: "",
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                fillColor: Colors.transparent,
                                focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: ColorName.mediumGrey),
                                    borderRadius: BorderRadius.circular(6)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: ColorName.mediumGrey),
                                    borderRadius: BorderRadius.circular(6))),
                          ),
                          10.toSpace,
                          Center(
                            child: Appwidgets.MyButton(
                              "Submit",
                              200,
                              () {
                                if (selectedCategory?.id != null &&
                                    selectedsubCategory?.id != null &&
                                    selectedCategory?.id != "" &&
                                    selectedsubCategory?.id != "") {
                                  contactUsApi();
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  void contactUsApi() async {
    if (await Network.isConnected()) {
      EasyLoading.show();
      ContactUsResponse contactUsResponse = await ApiProvider().contactUsApi(
          userName: widget.userName,
          email: widget.email,
          telephone: widget.telephone,
          category_id: selectedCategory!.id!,
          comment_box: commentController.text,
          complain_type: selectedsubCategory!.name!,
          enquiry: selectedCategory!.category!,
          enquiryfor: selectedCategory!.name!,
          isProduct: selectedCategory!.isProduct!,
          order_id: selectedOrderData?.orderId ?? "",
          sub_category_id: selectedsubCategory!.id!);
      EasyLoading.dismiss();
      if (contactUsResponse.success == true) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              title: HtmlWidget(
                contactUsResponse.message!,
                textStyle: Appwidgets()
                    .commonTextStyle(ColorName.black)
                    .copyWith(fontWeight: FontWeight.w500),
              ),
              // title: Text(
              //   contactUsResponse.message!,
              // ),
              actions: [
                Appwidgets().buttonPrimary(
                  StringContants.lbl_continue_shopping,
                  () {
                    Navigator.of(context)
                        .pushReplacementNamed(Routes.home_page);
                  },
                )
              ],
            );
          },
        );
      } else {
        print("CONTACT USR RESPO ${contactUsResponse.message}");
        if (contactUsResponse.message != null &&
            contactUsResponse.message != "") {
          Appwidgets.showToastMessage(contactUsResponse.message!);
        }
      }
    } else {
      MyDialogs.showInternetDialog(context, () {
        contactUsApi();
        Navigator.pop(context);
      });
    }
  }
}
