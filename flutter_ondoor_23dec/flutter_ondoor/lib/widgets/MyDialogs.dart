import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import 'package:ondoor/constants/StringConstats.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/colors.dart';
import 'package:ondoor/widgets/common_cached_image_widget.dart';
import '../constants/Constant.dart';
import '../constants/FontConstants.dart';

import '../constants/ImageConstants.dart';
import '../models/AllProducts.dart';
import '../models/locationvalidationmodel.dart';
import '../utils/SizeConfig.dart';
import 'AppDialogs.dart';
import 'AppWidgets.dart';
import 'ondoor_loader_widget.dart';

class MyDialogs {
  static const double padding = 16.0;
  static const double avatarRadius = 45.0;
  static offersDialogMain(BuildContext context, String image_url) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => Dialog(
              insetPadding: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: Sizeconfig.getHeight(context) * 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              child: dialogContent(context, image_url),
            ));
  }

  static dialogContent(BuildContext context, String url) {
    return IntrinsicHeight(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: const Offset(0.0, 10.0),
            ),
          ],
        ),
        width: Sizeconfig.getWidth(context),
        //  height: Sizeconfig.getHeight(context) * 0.7,
        padding: EdgeInsets.symmetric(vertical: 0),
        child: Column(
          children: [
            Container(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                      child: CommonCachedImageWidget(
                        imgUrl: url,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(5),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          child: Image.asset(
                            Imageconstants.img_shadow_cross,
                            height: 30,
                            width: 30,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                        color: ColorName.ColorPrimary,
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(10.0),
                          bottomLeft: Radius.circular(10.0),
                        )),
                    child: Center(
                      child: Appwidgets.TextSemiBold(
                          StringContants.lbl_know_more,
                          Colors.white,
                          TextAlign.center),
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }

  static commonDialog({
    required BuildContext context,
    required Function()? actionTap,
    required String titleText,
    required String actionText,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: ()async{
            return false;
          },
          child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              titleText,
              style: Appwidgets().commonTextStyle(ColorName.black),
            ),
            actions: [
              ElevatedButton(
                  onPressed: actionTap,
                  child: Text(
                    actionText,
                    style: Appwidgets()
                        .commonTextStyle(ColorName.ColorBagroundPrimary),
                  ))
            ],
          ),
        );
      },
    );
  }

  static commonDialogwithBarreirDissmissable({
    required BuildContext context,
    required Function()? actionTap,
    required String titleText,
    required String actionText,
  }) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              titleText,
              style: Appwidgets().commonTextStyle(ColorName.black),
            ),
            actions: [
              ElevatedButton(
                  onPressed: actionTap,
                  child: Text(
                    actionText,
                    style: Appwidgets()
                        .commonTextStyle(ColorName.ColorBagroundPrimary),
                  ))
            ],
          ),
        );
      },
    );
  }

  static commonDialogwithtwoActionButtons({
    required BuildContext context,
    required Function()? actionTap,
    required String titleText,
    required String actionText,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            titleText,
            style: Appwidgets().commonTextStyle(ColorName.black),
          ),
          actions: [
            ElevatedButton(
                onPressed: actionTap,
                child: Text(
                  actionText,
                  style: Appwidgets()
                      .commonTextStyle(ColorName.ColorBagroundPrimary),
                )),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "No",
                  style: Appwidgets()
                      .commonTextStyle(ColorName.ColorBagroundPrimary),
                )),
          ],
        );
      },
    );
  }

  static Future<ProductUnit> optionDialog(
      BuildContext context, List<ProductUnit> listproduct, ProductUnit model) {
    // var size = list_option.length;
    var size = listproduct.length;

    var selectedDecoration = const BoxDecoration(
      color: ColorName.lightPink,
      borderRadius: BorderRadius.all(
        Radius.circular(10.0),
      ),
    );
    var unSelectedDecoration = const BoxDecoration(
      color: ColorName.ColorBagroundPrimary,
      borderRadius: BorderRadius.all(
        Radius.circular(10.0),
      ),
    );
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) => StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                shadowColor: Colors.transparent,
                insetPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: Sizeconfig.getHeight(context) * 0.1),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                contentPadding: EdgeInsets.zero,
                content: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    width: MediaQuery.of(context).size.width,
                    //  height:double.infinity,
                    height: 90 +
                        ((Sizeconfig.getWidth(context) * 0.15) *
                            listproduct.length),
                    //       (((size + 1) * (Sizeconfig.getWidth(context) * 0.2))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                              color: ColorName.ColorPrimary,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                topRight: Radius.circular(10.0),
                              )),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(),
                                Center(
                                  child: Appwidgets.TextLagre(
                                      StringContants.lbl_pack_size,
                                      Colors.white),
                                ),
                                Align(
                                  child: InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Icon(
                                        Icons.cancel,
                                        color: Colors.white,
                                      )),
                                )
                              ],
                            ),
                          ),
                        ),
                        ListView.separated(
                          shrinkWrap: true,
                          itemCount: listproduct.length,
                          itemBuilder: (context, index) {
                            double specialPrice = 0.0;
                            String specialPriceStr = "";
                            if (listproduct[index].specialPrice != null ||
                                listproduct[index].specialPrice != "") {
                              // specialPrice = double.parse(
                              //     list_option[index].specialPrice);
                              // specialPriceStr =
                              //     specialPrice.toStringAsFixed(2);
                            }
                            double price =
                                double.parse(listproduct[index].price!);

                            String priceStr = price.toStringAsFixed(2);
                            return InkWell(
                              onTap: () {
                                Navigator.pop(context, listproduct[index]);
                              },
                              child: Container(
                                decoration: model.productId ==
                                        listproduct[index].productId
                                    ? selectedDecoration
                                    : unSelectedDecoration,
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                margin: EdgeInsets.symmetric(horizontal: 10.0),
                                height: Sizeconfig.getWidth(context) * 0.15,
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Container(
                                            child: Appwidgets.TextLagre(
                                                listproduct[index]
                                                        .productWeight
                                                        .toString() +
                                                    " " +
                                                    listproduct[index]
                                                        .productWeightUnit!
                                                        .toLowerCase(),
                                                ColorName.black))),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          listproduct[index].specialPrice == ""
                                              ? "₹ ${double.parse(listproduct[index].sortPrice!).toStringAsFixed(2)}"
                                              : "₹ ${double.parse(listproduct[index].specialPrice!).toStringAsFixed(2)}",
                                          style: TextStyle(
                                              fontSize: Constants.Sizelagre,
                                              fontFamily:
                                                  Fontconstants.fc_family_sf,
                                              fontWeight: Fontconstants
                                                  .SF_Pro_Display_Bold,
                                              color: ColorName.black),
                                        ),
                                        10.toSpace,
                                        Text(
                                          listproduct[index].specialPrice == ""
                                              ? ""
                                              : "₹ ${double.parse(listproduct[index].price!).toStringAsFixed(2)}",
                                          style: TextStyle(
                                              fontSize: Constants.SizeSmall,
                                              fontFamily:
                                                  Fontconstants.fc_family_sf,
                                              fontWeight: Fontconstants
                                                  .SF_Pro_Display_Medium,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              decorationColor:
                                                  ColorName.textlight,
                                              color: ColorName.textlight),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return SizedBox(height: 5.0);
                          },
                        ),
                        Container()
                      ],
                    )),
              );
            })).then((value) {
      return value;
    });
  }

  static showAlertDialog(
      BuildContext context,
      String title,
      String positiveText,
      String negativeText,
      Function positive,
      Function negative) {
    debugPrint("showTimeAlert>>>>>>>");
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Container(
          child: Container(
            decoration: new BoxDecoration(
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
            height: Sizeconfig.getHeight(context) * .35,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    10.toSpace,
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
                    Divider(
                      color: ColorName.aquaHazeColor,
                    ),
                    Container(
                      padding: EdgeInsets.all(12),
                      child: Center(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: Constants.SizeMidium,
                            fontFamily: Fontconstants.fc_family_proxima,
                            fontWeight: FontWeight.w500,
                            color: ColorName.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                4.toSpace,
                Container(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: negativeText == ""
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () async {
                          positive();
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
                              positiveText,
                              style: TextStyle(
                                fontFamily: Fontconstants.fc_family_sf,
                                fontWeight:
                                    Fontconstants.SF_Pro_Display_SEMIBOLD,
                              ),
                            ))),
                      ),
                      negativeText == ""
                          ? Container()
                          : SizedBox(
                              height: 5,
                            ),
                      negativeText == ""
                          ? Container()
                          : InkWell(
                              onTap: () async {
                                negative();
                              },
                              child: Container(
                                  width: Sizeconfig.getWidth(context) * 0.35,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      color: ColorName.aquaHazeColor),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  child: Center(
                                      child: Text(
                                    negativeText,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: Fontconstants.fc_family_sf,
                                      fontWeight:
                                          Fontconstants.SF_Pro_Display_SEMIBOLD,
                                    ),
                                  ))),
                            ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  static showAlertDialogNew(
      BuildContext context,
      String title,
      String positiveText,
      String negativeText,
      Function positive,
      Function negative) {
    debugPrint("showTimeAlert>>>>>>>");
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: Container(
            child: Container(
              padding: EdgeInsets.all(15),
              decoration: new BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: const Offset(0.0, 10.0),
                  ),
                ],
              ),
              width: Sizeconfig.getWidth(context),
              height: Sizeconfig.getHeight(context) * .2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(),
                      Container(
                        child: Text(
                          "Alert",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: Fontconstants.fc_family_sf,
                            fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Container(),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: Sizeconfig.getWidth(context) * .68,
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: Fontconstants.fc_family_proxima,
                                fontWeight: FontWeight.w500,
                                color: ColorName.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container()
                    ],
                  ),
                  4.toSpace,
                  Center(
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: negativeText == ""
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.center,
                            children: [
                              negativeText == ""
                                  ? Container()
                                  : InkWell(
                                      onTap: () async {
                                        negative();
                                      },
                                      child: Container(
                                          width: Sizeconfig.getWidth(context) *
                                              0.30,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 6),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5.0)),
                                              color: ColorName.aquaHazeColor),
                                          child: Center(
                                              child: Text(
                                            negativeText,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.black,
                                              fontFamily:
                                                  Fontconstants.fc_family_sf,
                                              fontWeight: Fontconstants
                                                  .SF_Pro_Display_SEMIBOLD,
                                            ),
                                          ))),
                                    ),
                              20.toSpace,
                              InkWell(
                                onTap: () async {
                                  positive();
                                },
                                child: Container(
                                    width: Sizeconfig.getWidth(context) * 0.30,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0)),
                                        color: ColorName.ColorPrimary),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 6),
                                    child: Center(
                                        child: Text(
                                      positiveText,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontFamily:
                                              Fontconstants.fc_family_sf,
                                          fontWeight: Fontconstants
                                              .SF_Pro_Display_SEMIBOLD,
                                          color: ColorName.white_card),
                                    ))),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static showInternetDialog(BuildContext context, Function callback) {
    debugPrint("showTimeAlert>>>>>>>");
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CustomDialog(
        title: StringContants.lbl_network,
        description: StringContants.lbl_no_internet,
        buttonText: "Okay",
        image: Imageconstants.img_no_internet,
        onTap: callback,
        colors: ColorName.ColorPrimary,
      ),
    );
  }

  static showProductOffersDialog(
      BuildContext context, String message, Function callback) {
    debugPrint("showTimeAlert>>>>>>>");
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Consts.padding),
              ),
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              child: Container(
                child: Container(
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(Consts.padding),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                        offset: Offset(0.0, 10.0),
                      ),
                    ],
                  ),
                  width: Sizeconfig.getWidth(context),
                  height: Sizeconfig.getHeight(context) * 0.6,
                  child: Stack(
                    children: [
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 9,
                              child: Container(
                                child: Column(
                                  children: [
                                    Container(
                                        width: Sizeconfig.getWidth(context),
                                        height:
                                            Sizeconfig.getHeight(context) * 0.2,
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft:
                                                Radius.circular(Consts.padding),
                                            topRight:
                                                Radius.circular(Consts.padding),
                                          ),
                                          child: Image.asset(
                                            Imageconstants.img_offerbanner,
                                            height:
                                                Sizeconfig.getHeight(context) *
                                                    0.2,
                                            width: Sizeconfig.getWidth(context),
                                            fit: BoxFit.cover,
                                          ),
                                        )),
                                    Container(
                                      color: ColorName.ColorPrimary,
                                      height:
                                          Sizeconfig.getHeight(context) * 0.003,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Container(
                                        child: HtmlWidget(
                                          message,
                                          textStyle: const TextStyle(
                                              color: ColorName.black),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                width: Sizeconfig.getWidth(context),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: InkWell(
                                        onTap: () async {
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                            decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(5.0)),
                                                color: ColorName.ColorPrimary),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 8),
                                            child: Center(
                                                child: Text(StringContants
                                                    .lbl_shopMore))),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: InkWell(
                                        onTap: () async {
                                          callback();
                                        },
                                        child: Container(
                                            margin: EdgeInsets.only(
                                                left: Sizeconfig.getHeight(
                                                        context) *
                                                    0.001),
                                            decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                    bottomRight:
                                                        Radius.circular(5.0)),
                                                color: ColorName.ColorPrimary),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 8),
                                            child: Center(
                                                child: Text(
                                                    StringContants.lbl_skip))),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      // Align(
                      //   alignment: Alignment.topRight,
                      //   child: InkWell(
                      //     onTap: () {
                      //
                      //      callback();
                      //     },
                      //     child: Container(
                      //       padding: EdgeInsets.symmetric(
                      //           horizontal: 15, vertical: 5),
                      //       child: Text(StringContants.lbl_skip,
                      //           style: TextStyle(
                      //               fontSize: Constants.SizeMidium,
                      //               fontFamily: Fontconstants.fc_family_sf,
                      //               fontWeight:
                      //                   Fontconstants.SF_Pro_Display_SEMIBOLD,
                      //               color: ColorName.ColorPrimary)),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ));
  }

  static showLocationProductsDialog(
      BuildContext context,
      LocationProductsModel data,
      Function(List<CartData>) update,
      Function remove) {
    debugPrint("showTimeAlert>>>>>>>");
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => WillPopScope(
              onWillPop: () async {
                Navigator.pop(context);
                return false;
              },
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0.0,
                backgroundColor: Colors.transparent,
                insetPadding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: Sizeconfig.getHeight(context) * 0.1),
                child: Container(
                  padding: EdgeInsets.all(0), // Adjust padding as needed
                  width: MediaQuery.of(context)
                      .size
                      .width, // Set width to full screen
                  child: Container(
                    decoration: new BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10.0,
                          offset: Offset(0.0, 10.0),
                        ),
                      ],
                    ),
                    width: Sizeconfig.getWidth(context),
                    height: data.data.length < 5
                        ? (Sizeconfig.getHeight(context) * 0.09) *
                                data.data.length +
                            (Sizeconfig.getHeight(context) * 0.23)
                        : (Sizeconfig.getHeight(context) * 0.09) * 5 +
                            (Sizeconfig.getHeight(context) * 0.23),
                    //  height: Sizeconfig.getHeight(context) * 0.6,
                    child: Stack(
                      children: [
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                // flex: 9,
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                              height: Sizeconfig.getHeight(
                                                      context) *
                                                  0.12,
                                              decoration: const BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  10),
                                                          topRight:
                                                              Radius.circular(
                                                                  10)),
                                                  color:
                                                      ColorName.ColorPrimary),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 8),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    Center(
                                                      child: Text(
                                                        StringContants
                                                            .lbl_update_cart,
                                                        style: TextStyle(
                                                            fontSize: Constants
                                                                .SizeButton,
                                                            fontFamily:
                                                                Fontconstants
                                                                    .fc_family_sf,
                                                            fontWeight:
                                                                Fontconstants
                                                                    .SF_Pro_Display_Bold,
                                                            color:
                                                                Colors.white),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                    Divider(
                                                      height: 0.5,
                                                      color: Colors.grey
                                                          .withOpacity(0.6),
                                                    ),
                                                    Center(
                                                        child: Text(
                                                      data.locationChangeMessage,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize:
                                                            Constants.SizeSmall,
                                                        fontFamily:
                                                            Fontconstants
                                                                .fc_family_sf,
                                                        fontWeight: Fontconstants
                                                            .SF_Pro_Display_Regular,
                                                        color: Colors.white,
                                                      ),
                                                    ))
                                                  ],
                                                ),
                                              )),
                                        ],
                                      ),

                                      Container(
                                        //  height: Sizeconfig.getHeight(context)*0.32,
                                        height: data.data.length < 5
                                            ? (Sizeconfig.getHeight(context) *
                                                    0.09) *
                                                data.data.length
                                            : (Sizeconfig.getHeight(context) *
                                                    0.09) *
                                                5,
                                        child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: data.data.length,
                                            itemBuilder: (context, index) {
                                              CartData cartdata =
                                                  data.data[index];
                                              print(
                                                  "cartdata.newPrice  ${cartdata.newPrice}");
                                              return Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 5),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            width: Sizeconfig
                                                                    .getWidth(
                                                                        context) *
                                                                0.5,
                                                            child: Text(
                                                                cartdata.name,
                                                                maxLines: 2,
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
                                                                    color: Colors
                                                                        .black)),
                                                          ),
                                                          Text(
                                                              "Qty : " +
                                                                  cartdata.qty,
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
                                                                  color: Colors
                                                                      .black)),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 2,
                                                    ),
                                                    cartdata.outOfStock == "1"
                                                        ? Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        5),
                                                            child: Appwidgets
                                                                .TextRegular(
                                                                    'Out of stock',
                                                                    ColorName
                                                                        .ColorPrimary),
                                                          )
                                                        : Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        5),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Appwidgets.TextRegular(
                                                                        'Old Price : ',
                                                                        Colors
                                                                            .black),
                                                                    Appwidgets.TextRegular(
                                                                        "${Constants.ruppessymbol} ${cartdata.oldPrice}",
                                                                        Colors
                                                                            .black),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Container(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              5),
                                                                  decoration: BoxDecoration(
                                                                      color: ColorName
                                                                          .aquaHazeColor,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5)),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        "New Price : ",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                Constants.SizeSmall,
                                                                            fontFamily: Fontconstants.fc_family_sf,
                                                                            fontWeight: Fontconstants.SF_Pro_Display_Medium,
                                                                            color: ColorName.shamrock_green),
                                                                      ),
                                                                      Text(
                                                                        "${Constants.ruppessymbol} ${double.parse(cartdata.newPrice == null || cartdata.newPrice == "null" || cartdata.newPrice == "" ? "0.0" : cartdata.newPrice).toStringAsFixed(2)}",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                Constants.SizeSmall,
                                                                            fontFamily: Fontconstants.fc_family_sf,
                                                                            fontWeight: Fontconstants.SF_Pro_Display_Medium,
                                                                            color: ColorName.shamrock_green),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    data.data.length - 1 ==
                                                            index
                                                        ? Container()
                                                        : Divider(
                                                            color: ColorName
                                                                .aquaHazeColor,
                                                            height: 1,
                                                          ),
                                                  ],
                                                ),
                                              );
                                            }),
                                      ),

                                      // Container(
                                      //   decoration: BoxDecoration(
                                      //       color: ColorName.lightPink
                                      //   ),
                                      //   padding:  EdgeInsets.symmetric(horizontal: 5),
                                      //   child:
                                      //
                                      //
                                      //   Column(
                                      //     children: [
                                      //       Appwidgets.TextRegular("Note",Colors.black),
                                      //       Appwidgets.TextRegular("Cart will be updated and out of stock product will be removed from your cart.", ColorName.ColorPrimary,)   ,
                                      //
                                      //
                                      //     ],
                                      //   )
                                      //  ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: Sizeconfig.getWidth(context),
                                height: Sizeconfig.getHeight(context) * 0.10,
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: InkWell(
                                        onTap: () async {
                                          List<CartData> list = data.data;
                                          for (int index = 0;
                                              index < list.length;
                                              index++) {
                                            CartData data = list[index];
                                          }

                                          update(data.data);
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                            height: 35,
                                            margin: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0)),
                                                color: ColorName.yellow),
                                            child: Center(
                                                child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  Imageconstants.img_updatecart,
                                                  height: 15,
                                                  width: 15,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  StringContants.lbl_update,
                                                  style: TextStyle(
                                                      fontSize:
                                                          Constants.SizeMidium,
                                                      fontFamily: Fontconstants
                                                          .fc_family_sf,
                                                      fontWeight: Fontconstants
                                                          .SF_Pro_Display_Bold,
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ))),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: InkWell(
                                        onTap: () async {
                                          remove();
                                        },
                                        child: Container(
                                            height: 35,
                                            margin: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0)),
                                                color: ColorName.ColorPrimary),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  Imageconstants.img_deletecart,
                                                  height: 15,
                                                  width: 15,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Center(
                                                    child: Text(
                                                  StringContants.lbl_remove,
                                                  style: TextStyle(
                                                      fontSize:
                                                          Constants.SizeMidium,
                                                      fontFamily: Fontconstants
                                                          .fc_family_sf,
                                                      fontWeight: Fontconstants
                                                          .SF_Pro_Display_Bold,
                                                      color: Colors.white),
                                                )),
                                              ],
                                            )),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Align(
                        //   alignment: Alignment.topRight,
                        //   child: InkWell(
                        //     onTap: () {
                        //
                        //      callback();
                        //     },
                        //     child: Container(
                        //       padding: EdgeInsets.symmetric(
                        //           horizontal: 15, vertical: 5),
                        //       child: Text(StringContants.lbl_skip,
                        //           style: TextStyle(
                        //               fontSize: Constants.SizeMidium,
                        //               fontFamily: Fontconstants.fc_family_sf,
                        //               fontWeight:
                        //                   Fontconstants.SF_Pro_Display_SEMIBOLD,
                        //               color: ColorName.ColorPrimary)),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ));
  }

  static void showLoadingDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false, // Prevent dismissal by tapping outside
      context: context,

      builder: (BuildContext context) {
        return Container(
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            // contentPadding: EdgeInsets.symmetric(horizontal: 400),
            insetPadding: EdgeInsets.symmetric(
                horizontal: (Sizeconfig.getWidth(context) - 100) / 2),
            contentPadding: EdgeInsets.all(0),
            content: Material(
              type: MaterialType.transparency, // Ensure no extra padding

              child: Container(
                height: 100,
                child: Center(
                  child: OndoorLoaderWidget(), // Your loader widget here
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
