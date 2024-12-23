import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:ondoor/constants/Constant.dart';
import 'package:ondoor/constants/ImageConstants.dart';
import 'package:ondoor/constants/StringConstats.dart';
import 'package:ondoor/database/database_helper.dart';
import 'package:ondoor/database/dbconstants.dart';
import 'package:ondoor/main.dart';
import 'package:ondoor/screens/AddCard/card_bloc.dart';
import 'package:ondoor/screens/AddCard/card_event.dart';
import 'package:ondoor/screens/AddCard/card_state.dart';
import 'package:ondoor/screens/FeaturedProduct/FeatuuredBloc/featured_bloc.dart';
import 'package:ondoor/screens/HomeScreen/HomeBloc/home_page_bloc.dart';
import 'package:ondoor/screens/NewAnimation/animation_bloc.dart';
import 'package:ondoor/screens/NewAnimation/animation_event.dart';
import 'package:ondoor/screens/NewAnimation/animation_state.dart';
import 'package:ondoor/screens/shop_by_category/shop_by_category_bloc/shop_by_category_bloc.dart';
import 'package:ondoor/services/ApiServices.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/SizeConfig.dart';
import 'package:ondoor/utils/colors.dart';
import 'package:ondoor/utils/sharedpref.dart';
import 'package:ondoor/widgets/MyDialogs.dart';
import 'package:ondoor/widgets/common_cached_image_widget.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../constants/FontConstants.dart';
import '../models/AllProducts.dart';
import '../models/OrderSummaryProducts.dart';
import '../models/shop_by_category_response.dart';
import '../screens/FeaturedProduct/FeatuuredBloc/featured_event.dart';
import '../screens/FeaturedProduct/FeatuuredBloc/featured_state.dart';
import '../screens/HomeScreen/HomeBloc/home_page_event.dart';
import '../services/Navigation/routes.dart';
import '../utils/Commantextwidget.dart';
import '../utils/Connection.dart';
import '../utils/themeData.dart';
import 'ProductValidationsWidgets.dart';

class Appwidgets {
  //For Toast
  static showToastMessage(String message) {
    return Fluttertoast.showToast(
        msg: message,
        backgroundColor: ColorName.ColorPrimary,
        textColor: Colors.white);
  }

  static showToastMessagefromHtml(String message) {
    message = message.replaceAll('<br>', '');

    return Fluttertoast.showToast(
        msg: message,
        // msg: HtmlParser.parseHTML(message).text,
        backgroundColor: ColorName.ColorPrimary,
        textColor: ColorName.ColorBagroundPrimary);
  }

  // For Heading Text
  static TextLagre(String text, var color) {
    return Text(
      text,
      style: TextStyle(
          fontSize: Constants.Sizelagre,
          fontFamily: Fontconstants.fc_family_sf,
          fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
          color: color),
    );
  }

  // For Heading Text
  static TextExtraLagre(String text, var color) {
    return Text(
      text,
      style: TextStyle(
          // fontSize: Constants.SizeExtralagre,
          fontFamily: Fontconstants.fc_family_proxima,
          letterSpacing: 0,
          fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
          color: color),
    );
  }

  // For Heading Text
  static TextSmall(String text, var color) {
    return Text(
      text,
      style: TextStyle(
          fontSize: Constants.SizeSmall,
          fontFamily: Fontconstants.fc_family_sf,
          fontWeight: Fontconstants.SF_Pro_Display_Medium,
          color: color),
    );
  }

  // For Heading Text
  static TextSemiBold(String text, var color, TextAlign alignment) {
    return Text(
      text,
      textAlign: alignment,
      style: TextStyle(
          letterSpacing: 0,
          fontSize: Constants.SizeSmall,
          fontFamily: Fontconstants.fc_family_sf,
          fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
          color: color),
    );
  }

  static TextMedium(String text, var color) {
    return Text(
      text,
      style: TextStyle(
          fontSize: Constants.SizeMidium,
          fontFamily: Fontconstants.fc_family_sf,
          fontWeight: Fontconstants.SF_Pro_Display_Medium,
          color: color),
    );
  }

  static TextRegular(String text, var color) {
    return Text(
      text,
      style: TextStyle(
          fontSize: Constants.SizeSmall,
          fontFamily: Fontconstants.fc_family_sf,
          fontWeight: Fontconstants.SF_Pro_Display_Regular,
          color: color),
    );
  }

  static TextMediumBold(String text, var color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: Constants.SizeMidium,
        fontFamily: Fontconstants.fc_family_sf,
        fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
        color: color,
      ),
    );
  }

  static Text_15(String text, var color, TextAlign textAlign) {
    return Text(
      text,
      maxLines: 5,
      textAlign: textAlign,
      style: TextStyle(
          overflow: TextOverflow.ellipsis,
          fontSize: Constants.SizeButton,
          fontFamily: Fontconstants.fc_family_sf,
          fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
          color: color),
    );
  }

  static Text_15_AlignJustify(String text, var color) {
    return Text(
      text,
      maxLines: 5,
      textAlign: TextAlign.justify,
      style: TextStyle(
          overflow: TextOverflow.ellipsis,
          fontSize: Constants.SizeButton,
          fontFamily: Fontconstants.fc_family_sf,
          fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
          color: color),
    );
  }

  static Text_18(String text, var color) {
    return Text(
      text,
      maxLines: 5,
      textAlign: TextAlign.center,
      style: TextStyle(
          overflow: TextOverflow.ellipsis,
          fontSize: Constants.SizeButton,
          fontFamily: Fontconstants.fc_family_sf,
          fontWeight: Fontconstants.SF_Pro_Display_Regular,
          color: color),
    );
  }

  static Text_20(String text, var color) {
    return Text(
      text,
      maxLines: 5,
      textAlign: TextAlign.center,
      style: TextStyle(
          overflow: TextOverflow.ellipsis,
          fontSize: Constants.Size_20,
          fontFamily: Fontconstants.fc_family_sf,
          fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
          color: color),
    );
  }

  static Text_10(String text, var color) {
    return Text(
      text,
      style: TextStyle(
          fontSize: Constants.Size_10,
          fontFamily: Fontconstants.fc_family_sf,
          fontWeight: Fontconstants.SF_Pro_Display_Medium,
          color: color),
    );
  }

  static Text_12(String text, var color) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
          fontSize: Constants.SizeSmall,
          fontFamily: Fontconstants.fc_family_sf,
          fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
          color: color),
    );
  }

  static Text_7(String text, var color) {
    return Text(
      text,
      style: TextStyle(
          fontSize: Constants.Size_7,
          fontFamily: Fontconstants.fc_family_sf,
          fontWeight: Fontconstants.SF_Pro_Display_Medium,
          color: color),
    );
  }

  static Text_10_Regular(String text, var color) {
    return Text(
      text,
      style: TextStyle(
          fontSize: Constants.Size_10,
          fontFamily: Fontconstants.fc_family_sf,
          fontWeight: Fontconstants.SF_Pro_Display_Regular,
          color: color),
    );
  }

  static AppUpdationText(String text, var color) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
          overflow: TextOverflow.ellipsis,
          fontWeight: FontWeight.normal,
          color: color),
    );
  }

  static navigationIndicator(context) {
    return Container(
      height: Sizeconfig.getWidth(context) * .25,
      width: 4,
      decoration: const BoxDecoration(
          color: ColorName.watermelonRed,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
    );
  }

  static googlePlaceWidgetDecoration() {
    return OutlineInputBorder(
      borderSide: BorderSide(
          color: ColorName.mediumGrey.withOpacity(.4),
          width: 1), // Red border when focused
      borderRadius: BorderRadius.circular(10.0),
    );
  }

  static specialWidgetforproductCategory(
      {required String url, required double height, required double width}) {
    return CachedNetworkImage(
        errorWidget: (context, url, error) =>
            Image.asset(Imageconstants.ondoor_logo),
        useOldImageOnUrlChange: true,
        cacheKey: url,
        colorBlendMode: BlendMode.clear,
        repeat: ImageRepeat.repeat,
        filterQuality: FilterQuality.medium,
        height: height,
        width: width,
        fit: BoxFit.fill,
        imageUrl: url,
        placeholder: (context, url) => const Center(
                child: Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: CupertinoActivityIndicator(),
            )));
  }

  MediaQueryData mediaqueryDataforWholeApp({required BuildContext context}) {
    return MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.2));
  }

  static commonTextForField(
      {required TextEditingController controller,
      required String hintText,
      Function()? onTap,
      required BuildContext context,
      required int maxLength,
      required int maxlines,
      required TextInputType textInputType,
      required String? Function(String?)? validatorFunc}) {
    return TextFormField(
      onTap: onTap,
      controller: controller,
      validator: validatorFunc,
      maxLength: maxLength,
      maxLines: maxlines,
      style: const TextStyle(color: ColorName.black),
      onChanged: (value) {
        controller.text = value.replaceAll("  ", " ");
      },
      keyboardType: textInputType,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(
            r'''^[\w\'\’\"_,.()&!*|:/\\–%-]+(?:\s[\w\'\’\"_,.()&!*|:/\\–%-]+)*?\s?$'''))
      ],
      scrollPadding: EdgeInsets.only(
          bottom: hintText == StringContants.lbl_flat_house_building_number
              ? 0
              : MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: InputDecoration(
          hintText: hintText,
          errorBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: ColorName.ColorPrimary, width: 1),
              borderRadius: BorderRadius.circular(6)),
          counterText: "",
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          fillColor: Colors.transparent,
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: ColorName.lightGey, width: 1),
              borderRadius: BorderRadius.circular(6)),
          enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: ColorName.lightGey, width: 1),
              borderRadius: BorderRadius.circular(6))),
    );
  }

  static commonTextForFieldAuth(
      {required TextEditingController controller,
      required String hintText,
      required int maxLength,
      required int maxlines,
      required TextInputType textInputType,
      required String img_form_email,
      required List<TextInputFormatter>? inputformaters,
      required String? Function(String?)? validatorFunc,
      required String? Function(String?)? onchanged}) {
    return TextFormField(
      controller: controller,
      validator: validatorFunc,
      onChanged: (value) {
        onchanged!(value);
      },
      maxLength: maxLength,
      maxLines: maxlines,
      inputFormatters: inputformaters,
      style: const TextStyle(color: ColorName.black),
      keyboardType: textInputType,
      decoration: InputDecoration(
          hintText: hintText,
          errorBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: ColorName.ColorPrimary, width: 1),
              borderRadius: BorderRadius.circular(6)),
          counterText: "",
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          // contentPadding: EdgeInsets.all(4),
          fillColor: Colors.white,
          hintStyle: TextStyle(
              fontSize: Constants.SizeMidium, color: ColorName.grey_chateau),
          prefixIcon: Container(
              padding: EdgeInsets.all(13.0),
              child: Image.asset(
                img_form_email,
                height: 5,
                width: 5,
                color: Colors.black,
              )),
          focusedBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: ColorName.ColorPrimary, width: 1),
              borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(10))),
    );
  }

  static commonTextForFieldAuth2({
    required FocusNode focusNode,
    required TextEditingController controller,
    required String hintText,
    required int maxLength,
    required int maxLines,
    required TextInputType textInputType,
    required String imgFormEmail,
    required List<TextInputFormatter>? inputFormatters,
    required String? Function(String?)? validatorFunc,
    required void Function(String)? onChanged,
  }) {
    // Create a FocusNode to monitor focus state
    FocusNode myFocusNode = new FocusNode();

    return TextFormField(
      controller: controller,
      validator: validatorFunc,
      onChanged: onChanged,
      maxLength: maxLength,
      maxLines: maxLines,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: ColorName.black),
      keyboardType: textInputType,
      // focusNode: myFocusNode, // Assign the FocusNode to the TextFormField
      decoration: InputDecoration(
        hintText: "Enter $hintText",
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: ColorName.ColorPrimary, width: 1),
          borderRadius: BorderRadius.circular(6),
        ),
        counterText: "",
        labelText: hintText,
        labelStyle: TextStyle(
          color: myFocusNode.hasFocus
              ? ColorName.ColorPrimary
              : ColorName.black, // Change color based on focus
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        fillColor: Colors.white,
        hintStyle: TextStyle(
          fontSize: Constants.SizeMidium,
          color: ColorName.darkGrey.withOpacity(.5),
        ),
        prefixIcon: Container(
          padding: EdgeInsets.all(13.0),
          child: Image.asset(
            imgFormEmail,
            height: 5,
            width: 5,
            color: ColorName.darkGrey.withOpacity(.9),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: ColorName.ColorPrimary, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: ColorName.darkGrey.withOpacity(.5), width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  static commonTextForFieldforEditProfile(
      {required TextEditingController controller,
      required String hintText,
      required int maxLength,
      required BuildContext context,
      required int maxlines,
      required TextInputType textInputType,
      required List<TextInputFormatter> inputFormatters,
      required String? Function(String?)? validatorFunc}) {
    return TextFormField(
      controller: controller,
      validator: validatorFunc,
      maxLength: maxLength,
      enabled: hintText != "Enter Mobile number",
      maxLines: maxlines,
      inputFormatters: inputFormatters,
      onChanged: (value) {
        controller.text = value.replaceAll("  ", " ");
      },
      scrollPadding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      style: const TextStyle(color: ColorName.black),
      keyboardType: textInputType,
      decoration: InputDecoration(
          hintText: hintText,
          errorBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: ColorName.ColorPrimary, width: 1),
              borderRadius: BorderRadius.circular(6)),
          counterText: "",
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          fillColor: ColorName.aquaHazeColor,
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: ColorName.lightGey, width: 1),
              borderRadius: BorderRadius.circular(6)),
          disabledBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: ColorName.aquaHazeColor, width: 1),
              borderRadius: BorderRadius.circular(6)),
          enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: ColorName.lightGey, width: 1),
              borderRadius: BorderRadius.circular(6))),
    );
  }

  buttonPrimary(String text, Function() onpress) {
    return InkWell(
      onTap: onpress,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
        margin: EdgeInsets.only(left: 7),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            color: ColorName.ColorPrimary),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
                fontSize: Constants.SizeSmall,
                fontFamily: Fontconstants.fc_family_sf,
                fontWeight: Fontconstants.SF_Pro_Display_Bold,
                color: Colors.white),
          ),
        ),
      ),
    );
  }

  buttonPrimaryDetails(BuildContext context, String text, Function() onpress) {
    return InkWell(
      onTap: onpress,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        width: Sizeconfig.getHeight(context) * 0.18,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            color: ColorName.ColorPrimary),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
                fontSize: Constants.SizeMidium,
                fontFamily: Fontconstants.fc_family_sf,
                fontWeight: Fontconstants.SF_Pro_Display_Bold,
                color: Colors.white),
          ),
        ),
      ),
    );
  }

  double getwidthForText(String text, context) {
    return text.length >= 60
        ? Sizeconfig.getWidth(context) * .16 + text.length
        : text.length <= 60 && text.length >= 50
            ? Sizeconfig.getWidth(context) * .46 + text.length
            : text.length <= 50 && text.length >= 40
                ? Sizeconfig.getWidth(context) * .45 + text.length
                : text.length <= 40 && text.length >= 30
                    ? Sizeconfig.getWidth(context) * .4 + text.length
                    : text.length <= 30 && text.length >= 20
                        ? Sizeconfig.getWidth(context) * .38 + text.length
                        : text.length <= 20 && text.length >= 10
                            ? Sizeconfig.getWidth(context) * .29 + text.length
                            : text.length <= 10 && text.length >= 5
                                ? Sizeconfig.getWidth(context) * .2 +
                                    text.length
                                : 20;
    // return text.length >= 60
    //     ? Sizeconfig.getWidth(context) * .38 + text.length
    //     : text.length >= 40 && text.length < 60
    //         ? Sizeconfig.getWidth(context) * .45 + text.length
    //         : text.length >= 20 && text.length < 40
    //             ? Sizeconfig.getWidth(context) * .5 + text.length
    //             : text.length < 10
    //                 ? text.length < 5
    //                     ? Sizeconfig.getWidth(context) * .03 + text.length
    //                     : Sizeconfig.getWidth(context) * .07 + text.length
    //                 : Sizeconfig.getWidth(context) * .3 + text.length;
  }

  static MyButton(String text, double width, Function() onpress) {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: InkWell(
        onTap: onpress,
        child: Container(
          width: width - 20,
          padding: EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              color: ColorName.ColorPrimary),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: Constants.Sizelagre,
                fontFamily: Fontconstants.fc_family_sf,
                fontWeight: Fontconstants.SF_Pro_Display_Bold,
                color: Colors.white),
          ),
        ),
      ),
    );
  }

  static MyUiButton(BuildContext context, String text, var bgcolor,
      var textcolor, double width, Function() onpress) {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
      child: InkWell(
        onTap: onpress,
        child: Container(
          width: width - 20,
          height: Sizeconfig.getHeight(context) * 0.06,
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(18.0)),
              color: bgcolor),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    fontFamily: Fontconstants.fc_family_popins,
                    fontWeight: Fontconstants.SF_Pro_Display_Medium,
                    color: textcolor),
              ),
              Center(
                  child: Padding(
                padding: EdgeInsets.zero,
                child: Icon(
                  Icons.arrow_right_sharp,
                  color: textcolor,
                  size: 20,
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }

  static CommonButtonWidget({
    required Function() onpress,
    required String buttonText,
    required BorderRadiusGeometry borderRadius,
    required Color buttonColor,
    required Widget childWidget,
    required Color borderColor,
  }) {
    return Expanded(
        child: InkWell(
      onTap: onpress,
      child: Container(
        height: 30,
        decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: borderColor)),
        child: childWidget,
      ),
    ));
  }

  static AddQuantityButton(
      String text, int quantity, Function() onincress, Function() ondecrease) {
    return InkWell(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        margin: EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            color: ColorName.ColorPrimary),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
                onTap: ondecrease,
                child: Container(
                    child: Icon(Icons.remove, size: Constants.SizeButton))
                /*    Text(
                "  -  ",
                style: TextStyle(
                    fontSize: Constants.SizeButton,
                    fontFamily: Fontconstants.fc_family_sf,
                    fontWeight: Fontconstants.SF_Pro_Display_Bold,
                    color: Colors.white),
              ),*/
                ),
            Container(
              child: Text(
                "$quantity",
                style: TextStyle(
                    fontSize: Constants.SizeMidium,
                    fontFamily: Fontconstants.fc_family_sf,
                    fontWeight: Fontconstants.SF_Pro_Display_Bold,
                    color: Colors.white),
              ),
            ),
            InkWell(
                onTap: onincress,
                child: Container(
                    child: Icon(
                  Icons.add,
                  size: Constants.SizeButton,
                ))

                /*  Text(
                "  +  ",
                style: TextStyle(
                    fontSize: Constants.SizeButton,
                    fontFamily: Fontconstants.fc_family_sf,
                    fontWeight: Fontconstants.SF_Pro_Display_Bold,
                    color: Colors.white),
                // ),
              ),*/
                ),
          ],
        ),
      ),
    );
  }

  static AddQuantityButtonDetails(BuildContext context, String text,
      int quantity, Function() onincress, Function() ondecrease) {
    return InkWell(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        width: Sizeconfig.getHeight(context) * 0.18,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            color: ColorName.ColorPrimary),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              onTap: ondecrease,
              child: Container(child: Icon(Icons.remove)),
            ),
            Container(
              child: Text(
                "$quantity",
                style: TextStyle(
                    fontSize: Constants.SizeMidium,
                    fontFamily: Fontconstants.fc_family_sf,
                    fontWeight: Fontconstants.SF_Pro_Display_Bold,
                    color: Colors.white),
              ),
            ),
            InkWell(
              onTap: onincress,
              child: Container(child: Icon(Icons.add)),
            ),
          ],
        ),
      ),
    );
  }

  static ButtonSecondary(String text, Function() onpress) {
    return InkWell(
      onTap: onpress,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            color: ColorName.ColorPrimary),
        child: Text(
          text,
          style: TextStyle(
              fontSize: Constants.Sizelagre,
              fontFamily: Fontconstants.fc_family_sf,
              fontWeight: Fontconstants.SF_Pro_Display_Bold,
              color: Colors.white),
        ),
      ),
    );
  }

  static ButtonSecondaryForOrderModification(String text, Function() onpress) {
    return InkWell(
      onTap: onpress,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            color: ColorName.ColorPrimary),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
                fontSize: Constants.Sizelagre,
                fontFamily: Fontconstants.fc_family_sf,
                fontWeight: Fontconstants.SF_Pro_Display_Bold,
                color: Colors.white),
          ),
        ),
      ),
    );
  }

  static ButtonSecondarywhite(String text, Function() onpress) {
    return InkWell(
      onTap: onpress,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            color: Colors.white),
        child: Text(
          text,
          style: TextStyle(
              fontSize: Constants.Sizelagre,
              fontFamily: Fontconstants.fc_family_sf,
              fontWeight: Fontconstants.SF_Pro_Display_Bold,
              color: ColorName.ColorPrimary),
        ),
      ),
    );
  }

  static orangeThemeButton(String text, Function() onpress) {
    return InkWell(
      onTap: onpress,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            color: ColorName.orange),
        child: Text(
          text,
          style: TextStyle(
              fontSize: Constants.Sizelagre,
              fontFamily: Fontconstants.fc_family_sf,
              fontWeight: Fontconstants.SF_Pro_Display_Bold,
              color: Colors.white),
        ),
      ),
    );
  }

  static MyAppBar(BuildContext context, String title, Function() onpress) {
    return AppBar(
      title: Text(title,
          style: TextStyle(
              fontSize: 17,
              fontFamily: Fontconstants.fc_family_sf,
              fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
              color: Colors.white)),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
    );
  }

  static MyAppBarWithHome(BuildContext context, String title) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 17,
          fontFamily: Fontconstants.fc_family_sf,
          fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
          color: Colors.white,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.home, color: Colors.white),
          onPressed: () {
            try {
              Navigator.of(context).pushReplacementNamed(Routes.home_page);
            } catch (e) {
              debugPrint("Exeption " + e.toString());
            }
          },
        ),
      ],
    );
  }

  AppBar MyappBar(BuildContext context, String title, Function() onpress,
      SystemUiOverlayStyle systemuiOverlayStyle) {
    return AppBar(
      systemOverlayStyle: systemuiOverlayStyle,
      title: Text(title,
          style: TextStyle(
              fontSize: 17,
              fontFamily: Fontconstants.fc_family_sf,
              fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
              color: Colors.white)),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
    );
  }

  static MyAppBar2(BuildContext context, String title, Function() onpress) {
    return AppBar(
      title: Text(title,
          style: TextStyle(
              fontSize: 17,
              fontFamily: Fontconstants.fc_family_sf,
              fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
              color: Colors.white)),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () {
          onpress();
        },
      ),
      centerTitle: true,
    );
  }

  static shoppingListAppBar(
      BuildContext context, String title, List<Widget> actionWidgets) {
    return AppBar(
      actions: actionWidgets,
      // actions: [
      //   GestureDetector(
      //     onTap: () {
      //       shoppingListBloc.addShoppingListDialog(context);
      //     },
      //     child: const Icon(
      //       Icons.add,
      //       color: ColorName.ColorBagroundPrimary,
      //     ),
      //   )
      // ],
      title: Appwidgets.TextExtraLagre(title, Colors.white),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
    );
  }

  static lables(String labels, double horizantal, double verticle) {
    return Padding(
        padding:
            EdgeInsets.symmetric(horizontal: horizantal, vertical: verticle),
        child:

            // Text(labels,
            //     style: TextStyle(
            //         fontSize: Constants.SizeMidium,
            //         fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
            //         color: ColorName.darkGrey)
            //
            // ),
            CommanTextWidget.subheading(labels, ColorName.black));
  }

  static appUpdateDialogButton(String text, Function() onPress, Color color) {
    return Expanded(
        child: GestureDetector(
      onTap: onPress,
      child: Card(
        elevation: 2,
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Appwidgets.Text_15(
              text, ColorName.ColorBagroundPrimary, TextAlign.center),
        ),
      ),
    ));
  }

  TextStyle commonTextStyle(Color color) {
    return TextStyle(
        fontSize: Constants.Sizelagre,
        fontFamily: Fontconstants.fc_family_sf,
        fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
        color: color);
  }

  static View_categoryitem(BuildContext context, var height) {
    var width = Sizeconfig.getWidth(context) / 4;

    return Container(
        padding: EdgeInsets.all(4.0),
        width: width,
        child: Container(
          child: Stack(
            children: [
              Align(
                  alignment: Alignment.bottomCenter,
                  //TODO to change image to svg
                  child: Image.asset(
                    Imageconstants.img_categorybackground,
                    height: height * 0.6,
                    width: width,
                    fit: BoxFit.fill,
                  )),
              Container(
                height: height,
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: width,
                        height: height * 0.4,
                        child: Image.asset(
                          Imageconstants.img_product,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }

  static categoryItemView(
      bool deleteuinit,
      bool fromchekcout,
      BuildContext context,
      List<ProductUnit> list,
      ProductUnit dummyData,
      dynamic state,
      int index,
      Function increase,
      Function decrease,
      Function delete,
      Function refresh,
      bool isShowBottomMessage,
      bool ischeckbox,
      Function chekbox,
      bool isOfferdialog,
      FeaturedBloc featurebloc) {
    //debugPrint("CategoryItems " + jsonEncode(dummyData));

    // Show prices with quanitity
    var crossprice;
    var showprice;
    var showprice2;
    bool showWarningMessage = false;
    bool offerAppilied = false;
    if (dummyData.specialPrice != "Free") {
      debugPrint("specialPrice ${dummyData.specialPrice}");
      debugPrint("sortPrice ${dummyData.sortPrice}");
      debugPrint("price ${dummyData.price}");

      var sortPrice = (double.parse(dummyData.sortPrice == null ||
                      dummyData.sortPrice == "null" ||
                      dummyData.sortPrice == ""
                  ? "0.0"
                  : dummyData.sortPrice!) *
              dummyData.addQuantity)
          .toString();
      var specialPrice = (double.parse(dummyData.specialPrice == null ||
                      dummyData.specialPrice == "null" ||
                      dummyData.specialPrice == ""
                  ? "0.0"
                  : dummyData.specialPrice!) *
              dummyData.addQuantity)
          .toString();
      var price = (double.parse(dummyData.price == null ||
                      dummyData.price == "null" ||
                      dummyData.price == ""
                  ? "0.0"
                  : dummyData.price!) *
              dummyData.addQuantity)
          .toString();

      debugPrint("specialPrice 2 ${specialPrice}");
      debugPrint("sortPrice 2 ${sortPrice}");
      debugPrint("price 2 ${price}");
      debugPrint("dummyData.specialPrice ${dummyData.specialPrice}");

      crossprice = dummyData.specialPrice == ""
          ? ""
          : "₹ ${double.parse(price).toStringAsFixed(2)}";
      showprice = dummyData.specialPrice == ""
          ? "₹ ${double.parse(sortPrice ?? "0.0").toStringAsFixed(2)}"
          : "₹ ${double.parse(specialPrice ?? "0.0").toStringAsFixed(2)}";

      // Show unit price only

      var sortPrice2 = (double.parse(dummyData.sortPrice == null ||
                  dummyData.sortPrice == "null" ||
                  dummyData.sortPrice == ""
              ? "0.0"
              : dummyData.sortPrice!))
          .toString();
      var specialPrice2 = (double.parse(dummyData.specialPrice == null ||
                  dummyData.specialPrice == "null" ||
                  dummyData.specialPrice == ""
              ? "0.0"
              : dummyData.specialPrice!))
          .toString();
      showprice2 = dummyData.specialPrice == ""
          ? "₹ ${double.parse(sortPrice2 ?? "0.0").toStringAsFixed(2)}"
          : "₹ ${double.parse(specialPrice2).toStringAsFixed(2)}";
    } else {
      crossprice = "₹ ${double.parse(dummyData.price!).toStringAsFixed(2)}";
      showprice = "Free";
      showprice2 = "";
    }

    debugPrint("showprice2 $showprice2");
    debugPrint("dummyData.specialPrice ${dummyData.specialPrice}");
    debugPrint("ShowPrice $showprice");
    debugPrint("Cross $crossprice");

    int totalAdded = 0;

    debugPrint("On Add Total Quanitiyt ${totalAdded}");

    int remainingQuanityt = 0;
    int buy_quantity = 0;
    String applied = "";
    String warningtitle = "";
    String offerinfo = "";
    List<String> addquanityId = [];

    if (dummyData.subProduct != null && dummyData!.subProduct!.buyQty != null) {
      debugPrint(
          "KKKKKK " + jsonEncode(dummyData.subProduct!.subProductDetail!));
      for (var x in dummyData.subProduct!.subProductDetail!) {
        // if(x.productId==dummyData.productId)
        // {
        //   totalAdded=totalAdded+dummyData.addQuantity;
        //   addquanityId.add(x.productId!);
        // }
        // else {
        //   totalAdded = totalAdded + x.addQuantity;
        //   addquanityId.add(x.productId!);
        // }

        for (var y in list) {
          if (x.productId == y.productId) {
            debugPrint(
                "Subproducts item match in list ${x.name}  ${y.addQuantity}");
            // if(list.contains(y.productId)==false)
            //   {
            totalAdded = totalAdded + y.addQuantity;
            //}
          }
        }
      }

      if (totalAdded == 0) {
        totalAdded = dummyData.addQuantity;
        addquanityId.add(dummyData.productId!);
      }

      debugPrint("TotalAdded Quantity ${totalAdded}");

      applied = dummyData!.subProduct!.cOfferApplied!;
      offerinfo = dummyData!.subProduct!.cOfferInfo!;
      warningtitle = dummyData!.subProduct!.offerWarning!;
      buy_quantity = int.parse(dummyData!.subProduct!.buyQty! ?? "0");
      if (totalAdded == 0) {
        showWarningMessage = false;
        offerAppilied = false;
      } else if (totalAdded < buy_quantity) {
        remainingQuanityt = buy_quantity - totalAdded;
        showWarningMessage = true;
        offerAppilied = false;
      } else {
        showWarningMessage = false;
        offerAppilied = true;
      }

      debugPrint(
          "Feature product listing showWarningMessage ${totalAdded} ${showWarningMessage}");
      debugPrint("Feature product listing offerAppilied ${offerAppilied}");
    }

    productclick() {
      if (isOfferdialog) {
        Appwidgets.ShowDialogDescription(context, dummyData);
      } else {
        int isMoreUnitIndex = 0;
        List<ProductUnit> list = [];
        list.add(dummyData);
        for (int i = 0; i < list.length!; i++) {
          if (dummyData.productId == list[i].productId!) {
            list[i] = dummyData;
            index = i;
          }
        }

        // Navigator.pop(context);
        Navigator.pushNamed(
          context,
          Routes.product_Detail_screen,
          arguments: {
            'fromchekcout': fromchekcout,
            'list': list,
            'index': index
          },
        ).then((value) async {
          ProductUnit unit = value as ProductUnit;
          debugPrint(
              ">>>>>ProductDetailsBack ${unit.addQuantity} ${unit.name}");
          featurebloc.add(ProductUnitEvent(unit: unit));
          OndoorThemeData.setStatusBarColor();
          // refresh();

          // value = value as ProductUnit;
          //  bloc.add(ProductUpdateQuantityEvent(quanitity:value.addQuantity!, index: index));
          //  bloc.add(ProductChangeEvent(model: value));
        });
      }
    }

    return Container(
      child: Column(
        children: [
          Container(
            // height: Sizeconfig.getHeight(context) * 0.11,

            margin: EdgeInsets.only(right: 10, left: 10, top: 0),
            padding: EdgeInsets.only(top: 0, bottom: 0, left: 5, right: 5),

            decoration: BoxDecoration(
              // color: ColorName.ColorPrimary,
              color: ColorName.ColorBagroundPrimary,
              borderRadius: (dummyData!.cOfferId != 0 &&
                      dummyData.cOfferId != null &&
                      dummyData.subProduct != null &&
                      (showWarningMessage != false || offerAppilied != false))
                  ? BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10))
                  : BorderRadius.circular(10),
              // border: Border.all(color: ColorName.lightGey),
            ),
            // margin:  EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            child: Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Expanded(
                    //   flex: 3,
                    //   child:
                    // ),
                    (ischeckbox && (dummyData!.mandatory ?? false) == false)
                        ? Positioned(
                            bottom: 0,
                            right: 0,
                            child: Checkbox(
                                checkColor: ColorName.white_card,
                                activeColor: ColorName.ColorPrimary,
                                value: dummyData.isChecked,
                                onChanged: (value) {
                                  chekbox();
                                }))
                        : SizedBox.shrink(),
                    Container(
                      child: Padding(
                        padding: EdgeInsets.zero,
                        child: Stack(
                          children: [
                            InkWell(
                              onTap: () {
                                productclick();
                              },
                              child: Container(
                                child: Container(
                                  color: ColorName.ColorBagroundPrimary,
                                  //color: ColorName.ColorPrimary,
                                  height: Sizeconfig.getHeight(context) * .12,
                                  padding: EdgeInsets.all(5),
                                  width: Sizeconfig.getWidth(context) * .2,
                                  child: Image.network(
                                    dummyData.image!,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                                top: 5,
                                left: 0,
                                child: InkWell(
                                    onTap: () {
                                      delete();
                                    },
                                    child: Icon(Icons.cancel,
                                        color: ColorName.ColorPrimary))),
                            (dummyData.discountText ?? "") == ""
                                ? Container()
                                : Positioned(
                                    right: 5,
                                    top: 5,
                                    child: Container(
                                      child: Visibility(
                                        visible: (dummyData!.discountText !=
                                                "" ||
                                            dummyData!.discountText != null),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              // left: 7,

                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Image.asset(
                                                    Imageconstants
                                                        .img_detailoffer,
                                                    height: 25,
                                                    width: 25,
                                                    fit: BoxFit.fill,
                                                  ),
                                                  Align(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      dummyData.discountText ??
                                                          "",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                      style: const TextStyle(
                                                        color: ColorName.black,
                                                        fontSize: 5,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container()
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 9,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    productclick();
                                  },
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        8.toSpace,
                                        Container(
                                          //GG99

                                          // height:
                                          //     Sizeconfig.getHeight(context) *
                                          //         0.04,
                                          child: CommanTextWidget.regularBold(
                                            dummyData.name!,
                                            Colors.black,
                                            maxline: 2,
                                            trt: TextStyle(
                                              fontSize: 13,
                                              height: 1.05,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            textalign: TextAlign.start,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 0, vertical: 5),
                                          width: Sizeconfig.getWidth(context) *
                                              .22,
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  dummyData.productWeight
                                                          .toString()! +
                                                      " ${dummyData.productWeightUnit}",
                                                  style: TextStyle(
                                                    fontSize: Constants.Size_10,
                                                    fontFamily: Fontconstants
                                                        .fc_family_sf,
                                                    fontWeight: Fontconstants
                                                        .SF_Pro_Display_Bold,
                                                    color: ColorName.textlight,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                flex: 3,
                              ),
                              (ischeckbox)
                                  ? Container(
                                      child: Appwidgets.TextSemiBold(
                                          "Qty : ${dummyData!.quantity ?? ""}",
                                          ColorName.ColorPrimary,
                                          TextAlign.right),
                                    )
                                  : (dummyData!.mandatory ?? false)
                                      ? Container(
                                          child: Appwidgets.TextSemiBold(
                                              "Qty : ${dummyData!.max_quantity ?? ""}",
                                              ColorName.ColorPrimary,
                                              TextAlign.right),
                                        )
                                      : Expanded(
                                          child: dummyData.addQuantity != 0
                                              ? Container(
                                                  alignment: Alignment.topRight,
                                                  width: Sizeconfig.getWidth(
                                                          context) *
                                                      0.05,
                                                  padding:
                                                      EdgeInsets.only(left: 15),
                                                  margin: EdgeInsets.only(
                                                      top: 10, right: 10),
                                                  child: Appwidgets
                                                      .AddQuantityButton(
                                                          StringContants
                                                              .lbl_add,
                                                          dummyData.addQuantity!
                                                              as int, () {
                                                    if (dummyData.addQuantity ==
                                                        int.parse(dummyData
                                                            .orderQtyLimit!
                                                            .toString())) {
                                                      Fluttertoast.showToast(
                                                          msg: StringContants
                                                              .msg_quanitiy);
                                                    } else {
                                                      increase();
                                                    }
                                                  }, () {
                                                    decrease();
                                                  }),
                                                )
                                              : Container(
                                                  padding:
                                                      EdgeInsets.only(left: 20),
                                                  margin: EdgeInsets.only(
                                                      top: 10, right: 10),
                                                  child: Appwidgets()
                                                      .buttonPrimary(
                                                    StringContants.lbl_add,
                                                    () {
                                                      // dummyData.addQuantity =
                                                      //     dummyData.addQuantity + 1;
                                                      increase();
                                                    },
                                                  ),
                                                ),
                                          flex: 2,
                                        )
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 5, right: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  showprice2,
                                  style: TextStyle(
                                    fontSize: Constants.Size_10,
                                    fontFamily: Fontconstants.fc_family_sf,
                                    fontWeight:
                                        Fontconstants.SF_Pro_Display_Bold,
                                    color: ColorName.textlight,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        // Text(
                                        //   crossprice,
                                        //   style: TextStyle(
                                        //       fontSize: Constants.Size_10,
                                        //       fontFamily:
                                        //           Fontconstants.fc_family_sf,
                                        //       fontWeight: Fontconstants
                                        //           .SF_Pro_Display_Medium,
                                        //       letterSpacing: 0,
                                        //       decoration:
                                        //           TextDecoration.lineThrough,
                                        //       decorationColor:
                                        //           ColorName.textlight,
                                        //       color: ColorName.textlight),
                                        // ),

                                        CommanTextWidget.regularBold(
                                          crossprice,
                                          ColorName.textlight,
                                          maxline: 2,
                                          trt: TextStyle(
                                            fontSize: 11,
                                            decoration:
                                                TextDecoration.lineThrough,
                                            decorationColor:
                                                ColorName.textlight,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textalign: TextAlign.start,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          flex: 0,
                                          child:
                                              // Text(showprice,
                                              //     style: TextStyle(
                                              //       fontSize: Constants.Size_10,
                                              //       fontFamily:
                                              //           Fontconstants.fc_family_sf,
                                              //       fontWeight: Fontconstants
                                              //           .SF_Pro_Display_SEMIBOLD,
                                              //       color: Colors.black,
                                              //     )),

                                              CommanTextWidget.regularBold(
                                            showprice,
                                            Colors.black,
                                            maxline: 1,
                                            trt: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            textalign: TextAlign.start,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          isShowBottomMessage
              ? ((dummyData!.cOfferId != 0 &&
                      dummyData.cOfferId != null &&
                      dummyData.subProduct != null &&
                      (showWarningMessage != false || offerAppilied != false))
                  ? Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 10.0,
                      ),
                      padding: EdgeInsets.only(bottom: 1),
                      decoration: BoxDecoration(
                        color: showWarningMessage
                            ? Colors.red.shade400
                            : Colors.green,
                        borderRadius: (dummyData!.cOfferId != 0 &&
                                dummyData.cOfferId != null &&
                                dummyData.subProduct != null &&
                                (showWarningMessage != false ||
                                    offerAppilied != false))
                            ? BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10))
                            : BorderRadius.circular(10),
                        // border: Border.all(color: ColorName.lightGey),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(),
                              Column(
                                children: [
                                  showWarningMessage == false
                                      ? Container()
                                      : Container(
                                          width: Sizeconfig.getWidth(context),
                                          decoration: BoxDecoration(
                                              color: Colors.red.shade400,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0))),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 10),
                                          alignment: Alignment.center,
                                          child: Marquee(
                                            child: Text(
                                                warningtitle.replaceAll("@#\$",
                                                    "${remainingQuanityt}"),
                                                maxLines: 1,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10)),
                                          )),
                                  Visibility(
                                    visible: offerAppilied,
                                    child: Container(
                                        width: Sizeconfig.getWidth(context),
                                        // margin: EdgeInsets.symmetric(
                                        //     horizontal: 10, vertical: 10),

                                        child: Marquee(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                Imageconstants.img_offer,
                                                height: 20,
                                                width: 20,
                                                color: Colors.white,
                                              ),
                                              5.toSpace,
                                              Container(
                                                // width:
                                                //     Sizeconfig.getWidth(context) *
                                                //         0.8,
                                                child: Text(
                                                  applied.replaceAll("@#\$",
                                                      buy_quantity.toString()),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10),
                                                ),
                                              )
                                            ],
                                          ),
                                        )),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ))
                  : Container())
              : Container(),
        ],
      ),
    );
  }

  static categoryItemView2(
      BuildContext context,
      List<ProductUnit> list,
      ProductUnit dummyData,
      dynamic state,
      int index,
      Function increase,
      Function decrease,
      Function delete,
      Function refresh,
      bool isShowBottomMessage,
      bool ischeckbox,
      Function chekbox,
      bool isOfferdialog,
      FeaturedBloc featurebloc) {
    //debugPrint("CategoryItems " + jsonEncode(dummyData));

    // Show prices with quanitity
    var crossprice;
    var showprice;
    var showprice2;
    bool showWarningMessage = false;
    bool offerAppilied = false;
    if (dummyData.specialPrice != "Free") {
      debugPrint("specialPrice ${dummyData.specialPrice}");
      debugPrint("sortPrice ${dummyData.sortPrice}");
      debugPrint("price ${dummyData.price}");

      var sortPrice = (double.parse(dummyData.sortPrice == null ||
                      dummyData.sortPrice == "null" ||
                      dummyData.sortPrice == ""
                  ? "0.0"
                  : dummyData.sortPrice!) *
              dummyData.addQuantity)
          .toString();
      var specialPrice = (double.parse(dummyData.specialPrice == null ||
                      dummyData.specialPrice == "null" ||
                      dummyData.specialPrice == ""
                  ? "0.0"
                  : dummyData.specialPrice!) *
              dummyData.addQuantity)
          .toString();
      var price = (double.parse(dummyData.price == null ||
                      dummyData.price == "null" ||
                      dummyData.price == ""
                  ? "0.0"
                  : dummyData.price!) *
              dummyData.addQuantity)
          .toString();

      debugPrint("specialPrice 2 ${specialPrice}");
      debugPrint("sortPrice 2 ${sortPrice}");
      debugPrint("price 2 ${price}");
      debugPrint("dummyData.specialPrice ${dummyData.specialPrice}");

      crossprice = dummyData.specialPrice == ""
          ? ""
          : "₹ ${double.parse(price).toStringAsFixed(2)}";
      showprice = dummyData.specialPrice == null || dummyData.specialPrice == ""
          ? "₹ ${double.parse(price ?? "0.0").toStringAsFixed(2)}"
          : "₹ ${double.parse(specialPrice ?? "0.0").toStringAsFixed(2)}";

      // Show unit price only

      var sortPrice2 = (double.parse(dummyData.sortPrice == null ||
                  dummyData.sortPrice == "null" ||
                  dummyData.sortPrice == ""
              ? dummyData.price ?? ""
              : dummyData.sortPrice!))
          .toString();
      var specialPrice2 = (double.parse(dummyData.specialPrice == null ||
                  dummyData.specialPrice == "null" ||
                  dummyData.specialPrice == ""
              ? "0.0"
              : dummyData.specialPrice!))
          .toString();
      showprice2 =
          dummyData.specialPrice == null || dummyData.specialPrice == ""
              ? "₹ ${double.parse(sortPrice2 ?? "0.0").toStringAsFixed(2)}"
              : "₹ ${double.parse(specialPrice2).toStringAsFixed(2)}";
      debugPrint("ROHITT special Price ${dummyData.specialPrice}");
      debugPrint("ROHITT showprice2 ${showprice2}");
      debugPrint("ROHITT showprice ${showprice}");
      debugPrint("ROHITT crossprice ${crossprice}");
      debugPrint("ROHITT specialPrice2 ${specialPrice2}");
      debugPrint("ROHITT sortPrice2 ${sortPrice2}");
      debugPrint("ROHITT price ${price}");
    } else {
      crossprice = "₹ ${double.parse(dummyData.price!).toStringAsFixed(2)}";
      showprice = "Free";
      showprice2 = "";
    }

    debugPrint("showprice2 $showprice2");
    debugPrint("dummyData.specialPrice ${dummyData.specialPrice}");
    debugPrint("ShowPrice $showprice");
    debugPrint("Cross $crossprice");

    int totalAdded = 0;

    debugPrint("On Add Total Quanitiyt ${totalAdded}");

    int remainingQuanityt = 0;
    int buy_quantity = 0;
    String applied = "";
    String warningtitle = "";
    String offerinfo = "";
    List<String> addquanityId = [];

    if (dummyData.subProduct != null && dummyData!.subProduct!.buyQty != null) {
      debugPrint(
          "KKKKKK " + jsonEncode(dummyData.subProduct!.subProductDetail!));
      for (var x in dummyData.subProduct!.subProductDetail!) {
        // if(x.productId==dummyData.productId)
        // {
        //   totalAdded=totalAdded+dummyData.addQuantity;
        //   addquanityId.add(x.productId!);
        // }
        // else {
        //   totalAdded = totalAdded + x.addQuantity;
        //   addquanityId.add(x.productId!);
        // }

        for (var y in list) {
          if (x.productId == y.productId) {
            debugPrint(
                "Subproducts item match in list ${x.name}  ${y.addQuantity}");
            // if(list.contains(y.productId)==false)
            //   {
            totalAdded = totalAdded + y.addQuantity;
            //}
          }
        }
      }

      if (totalAdded == 0) {
        totalAdded = dummyData.addQuantity;
        addquanityId.add(dummyData.productId!);
      }

      debugPrint("TotalAdded Quantity ${totalAdded}");

      applied = dummyData!.subProduct!.cOfferApplied!;
      offerinfo = dummyData!.subProduct!.cOfferInfo!;
      warningtitle = dummyData!.subProduct!.offerWarning!;
      buy_quantity = int.parse(dummyData!.subProduct!.buyQty! ?? "0");
      if (totalAdded == 0) {
        showWarningMessage = false;
        offerAppilied = false;
      } else if (totalAdded < buy_quantity) {
        remainingQuanityt = buy_quantity - totalAdded;
        showWarningMessage = true;
        offerAppilied = false;
      } else {
        showWarningMessage = false;
        offerAppilied = true;
      }

      debugPrint(
          "Feature product listing showWarningMessage ${totalAdded} ${showWarningMessage}");
      debugPrint("Feature product listing offerAppilied ${offerAppilied}");
    }

    productclick() {
      if (isOfferdialog) {
        Appwidgets.ShowDialogDescription(context, dummyData);
      } else {
        int isMoreUnitIndex = 0;
        List<ProductUnit> list = [];
        list.add(dummyData);
        for (int i = 0; i < list.length!; i++) {
          if (dummyData.productId == list[i].productId!) {
            list[i] = dummyData;
            index = i;
          }
        }

        // Navigator.pop(context);
        Navigator.pushNamed(
          context,
          Routes.product_Detail_screen,
          arguments: {'fromchekcout': false, 'list': list, 'index': index},
        ).then((value) async {
          ProductUnit unit = value as ProductUnit;
          debugPrint(
              ">>>>>ProductDetailsBack ${unit.addQuantity} ${unit.name}");
          featurebloc.add(ProductUnitEvent(unit: unit));
          OndoorThemeData.setStatusBarColor();
          refresh();

          // value = value as ProductUnit;
          //  bloc.add(ProductUpdateQuantityEvent(quanitity:value.addQuantity!, index: index));
          //  bloc.add(ProductChangeEvent(model: value));
        });
      }
    }

    return Container(
      child: Column(
        children: [
          Container(
            // height: Sizeconfig.getHeight(context) * 0.11,

            margin: EdgeInsets.only(right: 10, left: 10, top: 0),
            padding: EdgeInsets.only(top: 0, bottom: 0, left: 5, right: 5),

            decoration: BoxDecoration(
              // color: ColorName.ColorPrimary,
              color: ColorName.ColorBagroundPrimary,
              borderRadius: (dummyData!.cOfferId != 0 &&
                      dummyData.cOfferId != null &&
                      dummyData.subProduct != null &&
                      (showWarningMessage != false || offerAppilied != false))
                  ? BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10))
                  : BorderRadius.circular(10),
              // border: Border.all(color: ColorName.lightGey),
            ),
            // margin:  EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            child: Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Expanded(
                    //   flex: 3,
                    //   child:
                    // ),
                    (ischeckbox && (dummyData!.mandatory ?? false) == false)
                        ? Positioned(
                            bottom: 0,
                            right: 0,
                            child: Checkbox(
                                checkColor: ColorName.white_card,
                                activeColor: ColorName.ColorPrimary,
                                value: dummyData.isChecked,
                                onChanged: (value) {
                                  chekbox();
                                }))
                        : SizedBox.shrink(),
                    Container(
                      child: Padding(
                        padding: EdgeInsets.zero,
                        child: Stack(
                          children: [
                            InkWell(
                              onTap: () {
                                productclick();
                              },
                              child: Container(
                                child: Container(
                                  color: ColorName.ColorBagroundPrimary,
                                  //color: ColorName.ColorPrimary,
                                  height: Sizeconfig.getHeight(context) * .12,
                                  padding: EdgeInsets.all(5),
                                  width: Sizeconfig.getWidth(context) * .2,
                                  child: Image.network(
                                    dummyData.image!,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 9,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    productclick();
                                  },
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        8.toSpace,
                                        Container(
                                          height:
                                              Sizeconfig.getHeight(context) *
                                                  0.04,
                                          child: CommanTextWidget.regularBold(
                                            dummyData.name!,
                                            Colors.black,
                                            maxline: 2,
                                            trt: TextStyle(
                                              fontSize: 13,
                                              height: 1.05,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            textalign: TextAlign.start,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 0, vertical: 5),
                                          width: Sizeconfig.getWidth(context) *
                                              .22,
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  dummyData.productWeight
                                                          .toString()! +
                                                      " ${dummyData.productWeightUnit}",
                                                  style: TextStyle(
                                                    fontSize: Constants.Size_10,
                                                    fontFamily: Fontconstants
                                                        .fc_family_sf,
                                                    fontWeight: Fontconstants
                                                        .SF_Pro_Display_Bold,
                                                    color: ColorName.textlight,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                flex: 3,
                              ),
                              (ischeckbox)
                                  ? Container(
                                      child: Appwidgets.TextSemiBold(
                                          "Qty : ${dummyData!.quantity ?? ""}",
                                          ColorName.ColorPrimary,
                                          TextAlign.right),
                                    )
                                  : (dummyData!.mandatory ?? false)
                                      ? Container(
                                          child: Appwidgets.TextSemiBold(
                                              "Qty : ${dummyData!.max_quantity ?? ""}",
                                              ColorName.ColorPrimary,
                                              TextAlign.right),
                                        )
                                      : Expanded(
                                          child: dummyData.addQuantity != 0
                                              ? Container(
                                                  alignment: Alignment.topRight,
                                                  width: Sizeconfig.getWidth(
                                                          context) *
                                                      0.05,
                                                  padding:
                                                      EdgeInsets.only(left: 15),
                                                  margin: EdgeInsets.only(
                                                      top: 10, right: 10),
                                                  child: Appwidgets
                                                      .AddQuantityButton(
                                                          StringContants
                                                              .lbl_add,
                                                          dummyData.addQuantity!
                                                              as int, () {
                                                    if (dummyData.addQuantity ==
                                                        int.parse(dummyData
                                                            .orderQtyLimit!
                                                            .toString())) {
                                                      Fluttertoast.showToast(
                                                          msg: StringContants
                                                              .msg_quanitiy);
                                                    } else {
                                                      increase();
                                                    }
                                                  }, () {
                                                    decrease();
                                                  }),
                                                )
                                              : Container(
                                                  padding:
                                                      EdgeInsets.only(left: 20),
                                                  margin: EdgeInsets.only(
                                                      top: 10, right: 10),
                                                  child: Appwidgets()
                                                      .buttonPrimary(
                                                    StringContants.lbl_add,
                                                    () {
                                                      // dummyData.addQuantity =
                                                      //     dummyData.addQuantity + 1;
                                                      increase();
                                                    },
                                                  ),
                                                ),
                                          flex: 2,
                                        )
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 5, right: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  showprice2,
                                  style: TextStyle(
                                    fontSize: Constants.Size_10,
                                    fontFamily: Fontconstants.fc_family_sf,
                                    fontWeight:
                                        Fontconstants.SF_Pro_Display_Bold,
                                    color: ColorName.textlight,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        // Text(
                                        //   crossprice,
                                        //   style: TextStyle(
                                        //       fontSize: Constants.Size_10,
                                        //       fontFamily:
                                        //           Fontconstants.fc_family_sf,
                                        //       fontWeight: Fontconstants
                                        //           .SF_Pro_Display_Medium,
                                        //       letterSpacing: 0,
                                        //       decoration:
                                        //           TextDecoration.lineThrough,
                                        //       decorationColor:
                                        //           ColorName.textlight,
                                        //       color: ColorName.textlight),
                                        // ),

                                        CommanTextWidget.regularBold(
                                          crossprice,
                                          ColorName.textlight,
                                          maxline: 2,
                                          trt: TextStyle(
                                            fontSize: 11,
                                            decoration:
                                                TextDecoration.lineThrough,
                                            decorationColor:
                                                ColorName.textlight,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textalign: TextAlign.start,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          flex: 0,
                                          child:
                                              // Text(showprice,
                                              //     style: TextStyle(
                                              //       fontSize: Constants.Size_10,
                                              //       fontFamily:
                                              //           Fontconstants.fc_family_sf,
                                              //       fontWeight: Fontconstants
                                              //           .SF_Pro_Display_SEMIBOLD,
                                              //       color: Colors.black,
                                              //     )),

                                              CommanTextWidget.regularBold(
                                            showprice,
                                            Colors.black,
                                            maxline: 1,
                                            trt: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            textalign: TextAlign.start,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                (dummyData.discountText ?? "") == ""
                    ? Container()
                    : Positioned(
                        left: 0,
                        right: 0,
                        top: 5,
                        child: Container(
                          child: Visibility(
                            visible: (dummyData!.discountText != "" ||
                                dummyData!.discountText != null),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  // left: 7,

                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.asset(
                                        Imageconstants.img_detailoffer,
                                        height: 25,
                                        width: 25,
                                        fit: BoxFit.fill,
                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          dummyData.discountText ?? "",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: const TextStyle(
                                            color: ColorName.black,
                                            fontSize: 5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container()
                              ],
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
          isShowBottomMessage
              ? ((dummyData!.cOfferId != 0 &&
                      dummyData.cOfferId != null &&
                      dummyData.subProduct != null &&
                      (showWarningMessage != false || offerAppilied != false))
                  ? Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 10.0,
                      ),
                      padding: EdgeInsets.only(bottom: 1),
                      decoration: BoxDecoration(
                        color: showWarningMessage
                            ? Colors.red.shade400
                            : Colors.green,
                        borderRadius: (dummyData!.cOfferId != 0 &&
                                dummyData.cOfferId != null &&
                                dummyData.subProduct != null &&
                                (showWarningMessage != false ||
                                    offerAppilied != false))
                            ? BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10))
                            : BorderRadius.circular(10),
                        // border: Border.all(color: ColorName.lightGey),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(),
                              Column(
                                children: [
                                  showWarningMessage == false
                                      ? Container()
                                      : Container(
                                          width: Sizeconfig.getWidth(context),
                                          decoration: BoxDecoration(
                                              color: Colors.red.shade400,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0))),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 10),
                                          alignment: Alignment.center,
                                          child: Marquee(
                                            child: Text(
                                                warningtitle.replaceAll("@#\$",
                                                    "${remainingQuanityt}"),
                                                maxLines: 1,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10)),
                                          )),
                                  Visibility(
                                    visible: offerAppilied,
                                    child: Container(
                                        width: Sizeconfig.getWidth(context),
                                        // margin: EdgeInsets.symmetric(
                                        //     horizontal: 10, vertical: 10),

                                        child: Marquee(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                Imageconstants.img_offer,
                                                height: 20,
                                                width: 20,
                                                color: Colors.white,
                                              ),
                                              5.toSpace,
                                              Container(
                                                // width:
                                                //     Sizeconfig.getWidth(context) *
                                                //         0.8,
                                                child: Text(
                                                  applied.replaceAll("@#\$",
                                                      buy_quantity.toString()),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10),
                                                ),
                                              )
                                            ],
                                          ),
                                        )),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ))
                  : Container())
              : Container(),
        ],
      ),
    );
  }

  static categoryItemViewproductValidationold(
    BuildContext context,
    List<ProductUnit> list,
    ProductUnit dummyData,
    dynamic state,
    int index,
    Function increase,
    Function decrease,
    Function delete,
    Function refresh,
    bool isShowBottomMessage,
    bool ischeckbox,
    Function chekbox,
    bool isOfferdialog,
  ) {
    //debugPrint("CategoryItems " + jsonEncode(dummyData));

    // Show prices with quanitity
    var crossprice;
    var showprice;
    var showprice2;
    bool showWarningMessage = false;
    bool offerAppilied = false;
    if (dummyData.specialPrice != "Free") {
      debugPrint("specialPrice ${dummyData.specialPrice}");
      debugPrint("sortPrice ${dummyData.sortPrice}");
      debugPrint("price ${dummyData.price}");

      var sortPrice = (double.parse(dummyData.sortPrice == null ||
                      dummyData.sortPrice == "null" ||
                      dummyData.sortPrice == ""
                  ? "0.0"
                  : dummyData.sortPrice!) *
              dummyData.addQuantity)
          .toString();
      var specialPrice = (double.parse(dummyData.specialPrice == null ||
                      dummyData.specialPrice == "null" ||
                      dummyData.specialPrice == ""
                  ? "0.0"
                  : dummyData.specialPrice!) *
              dummyData.addQuantity)
          .toString();
      var price = (double.parse(dummyData.price == null ||
                      dummyData.price == "null" ||
                      dummyData.price == ""
                  ? "0.0"
                  : dummyData.price!) *
              dummyData.addQuantity)
          .toString();

      debugPrint("specialPrice 2 ${specialPrice}");
      debugPrint("sortPrice 2 ${sortPrice}");
      debugPrint("price 2 ${price}");

      crossprice = dummyData.specialPrice == ""
          ? ""
          : "₹ ${double.parse(price).toStringAsFixed(2)}";
      showprice = dummyData.specialPrice == ""
          ? "₹ ${double.parse(sortPrice ?? "0.0").toStringAsFixed(2)}"
          : "₹ ${double.parse(specialPrice ?? "0.0").toStringAsFixed(2)}";

      // Show unit price only

      var sortPrice2 = (double.parse(dummyData.sortPrice == null ||
                  dummyData.sortPrice == "null" ||
                  dummyData.sortPrice == ""
              ? "0.0"
              : dummyData.sortPrice!))
          .toString();
      var specialPrice2 = (double.parse(dummyData.specialPrice == null ||
                  dummyData.specialPrice == "null" ||
                  dummyData.specialPrice == ""
              ? "0.0"
              : dummyData.specialPrice!))
          .toString();
      showprice2 = dummyData.specialPrice == ""
          ? "₹ ${double.parse(sortPrice2 ?? "0.0").toStringAsFixed(2)}"
          : "₹ ${double.parse(specialPrice2).toStringAsFixed(2)}";
    } else {
      crossprice = "₹ ${double.parse(dummyData.price!).toStringAsFixed(2)}";
      showprice = "Free";
      showprice2 = "";
    }

    debugPrint("ShowPrice $showprice");
    debugPrint("Cross $crossprice");

    int totalAdded = 0;

    debugPrint("On Add Total Quanitiyt ${totalAdded}");

    int remainingQuanityt = 0;
    int buy_quantity = 0;
    String applied = "";
    String warningtitle = "";
    String offerinfo = "";
    List<String> addquanityId = [];

    if (dummyData.subProduct != null && dummyData!.subProduct!.buyQty != null) {
      for (var x in dummyData.subProduct!.subProductDetail!) {
        // if(x.productId==dummyData.productId)
        // {
        //   totalAdded=totalAdded+dummyData.addQuantity;
        //   addquanityId.add(x.productId!);
        // }
        // else {
        //   totalAdded = totalAdded + x.addQuantity;
        //   addquanityId.add(x.productId!);
        // }

        for (var y in list) {
          if (x.productId == y.productId) {
            debugPrint(
                "Subproducts item match in list ${x.name}  ${y.addQuantity}");
            // if(list.contains(y.productId)==false)
            //   {
            totalAdded = totalAdded + y.addQuantity;
            //}
          }
        }
      }

      if (totalAdded == 0) {
        totalAdded = dummyData.addQuantity;
        addquanityId.add(dummyData.productId!);
      }

      debugPrint("TotalAdded Quantity ${totalAdded}");

      applied = dummyData!.subProduct!.cOfferApplied!;
      offerinfo = dummyData!.subProduct!.cOfferInfo!;
      warningtitle = dummyData!.subProduct!.offerWarning!;
      buy_quantity = int.parse(dummyData!.subProduct!.buyQty! ?? "0");
      if (totalAdded == 0) {
        showWarningMessage = false;
        offerAppilied = false;
      } else if (totalAdded < buy_quantity) {
        remainingQuanityt = buy_quantity - totalAdded;
        showWarningMessage = true;
        offerAppilied = false;
      } else {
        showWarningMessage = false;
        offerAppilied = true;
      }

      debugPrint(
          "Feature product listing showWarningMessage ${totalAdded} ${showWarningMessage}");
      debugPrint("Feature product listing offerAppilied ${offerAppilied}");
    }

    productclick() {
      if (isOfferdialog) {
        Appwidgets.ShowDialogDescription(context, dummyData);
      } else {
        int isMoreUnitIndex = 0;
        List<ProductUnit> list = [];
        list.add(dummyData);
        for (int i = 0; i < list.length!; i++) {
          if (dummyData.productId == list[i].productId!) {
            list[i] = dummyData;
            index = i;
          }
        }

        // Navigator.pop(context);
        Navigator.pushNamed(
          context,
          Routes.product_Detail_screen,
          arguments: {'fromchekcout': false, 'list': list, 'index': index},
        ).then((value) async {
          OndoorThemeData.setStatusBarColor();
          refresh();

          // value = value as ProductUnit;
          //  bloc.add(ProductUpdateQuantityEvent(quanitity:value.addQuantity!, index: index));
          //  bloc.add(ProductChangeEvent(model: value));
        });
      }
    }

    return InkWell(
      onTap: () {
        // if (isOfferdialog) {
        //   Appwidgets.ShowDialogDescription(context, dummyData);
        // } else {
        //   int isMoreUnitIndex = 0;
        //   List<ProductUnit> list = [];
        //   list.add(dummyData);
        //   for (int i = 0; i < list.length!; i++) {
        //     if (dummyData.productId == list[i].productId!) {
        //       list[i] = dummyData;
        //       index = i;
        //     }
        //   }
        //
        //   // Navigator.pop(context);
        //   Navigator.pushNamed(
        //     context,
        //     Routes.product_Detail_screen,
        //     arguments: {
        //     'fromchekcout': false,
        //     'list': list, 'index': index},
        //   ).then((value) async {
        //     OndoorThemeData.setStatusBarColor();
        //     refresh();
        //
        //     // value = value as ProductUnit;
        //     //  bloc.add(ProductUpdateQuantityEvent(quanitity:value.addQuantity!, index: index));
        //     //  bloc.add(ProductChangeEvent(model: value));
        //   });
        // }
      },
      child: Container(
        color: Colors.yellow,
        child: Column(
          children: [
            Container(
              // height: Sizeconfig.getHeight(context) * 0.11,

              margin: EdgeInsets.only(right: 0, left: 0, top: 0),
              padding: EdgeInsets.only(top: 0, bottom: 0, left: 5, right: 10),

              decoration: BoxDecoration(
                color: ColorName.ColorBagroundPrimary,
                border: Border(
                  bottom: BorderSide(
                    color:
                        Colors.grey.withOpacity(0.5), // Set your desired color
                    width: 0.5, // Set the thickness of the border
                  ),
                ),
                // borderRadius: (dummyData!.cOfferId != 0 &&
                //     dummyData.cOfferId != null &&
                //     dummyData.subProduct != null &&
                //     (showWarningMessage != false || offerAppilied != false))
                //     ? BorderRadius.only(
                //     topRight: Radius.circular(10),
                //     topLeft: Radius.circular(10))
                //     : BorderRadius.circular(10),
                // border: Border.all(color: ColorName.lightGey),
              ),
              // margin:  EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Expanded(
                      //   flex: 3,
                      //   child:
                      // ),
                      (ischeckbox && (dummyData!.mandatory ?? false) == false)
                          ? Container(
                              height: Sizeconfig.getHeight(context) * .12,
                              margin: EdgeInsets.only(right: 5),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(),
                                  Container(
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: Checkbox(
                                          checkColor: ColorName.white_card,
                                          activeColor: ColorName.ColorPrimary,
                                          visualDensity: VisualDensity
                                              .compact, // Reduce padding
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          value: dummyData.isChecked,
                                          onChanged: (value) {
                                            chekbox();
                                          }),
                                    ),
                                  ),
                                  Container(),
                                ],
                              ),
                            )
                          : Container(),
                      Container(
                        child: Padding(
                          padding: EdgeInsets.zero,
                          child: Stack(
                            children: [
                              InkWell(
                                onTap: () {
                                  productclick();
                                },
                                child: Container(
                                  child: Container(
                                    //color: ColorName.ColorPrimary,
                                    height: Sizeconfig.getHeight(context) * .12,
                                    padding: EdgeInsets.all(1),
                                    width: Sizeconfig.getWidth(context) * .2,
                                    child: Image.network(
                                      dummyData.image!,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 9,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        8.toSpace,
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                productclick();
                                              },
                                              child: Container(
                                                height: Sizeconfig.getHeight(
                                                        context) *
                                                    0.04,
                                                width: Sizeconfig.getWidth(
                                                        context) *
                                                    0.5,
                                                child: CommanTextWidget
                                                    .regularBold(
                                                  dummyData.name!,
                                                  Colors.black,
                                                  maxline: 2,
                                                  trt: TextStyle(
                                                    fontSize: 13,
                                                    height: 1.05,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                  textalign: TextAlign.start,
                                                ),
                                              ),
                                            ),
                                            (ischeckbox)
                                                ? Container(
                                                    child: CommanTextWidget
                                                        .regularBold(
                                                      "Qty : ${dummyData!.quantity ?? ""}",
                                                      ColorName.ColorPrimary,
                                                      maxline: 1,
                                                      trt: TextStyle(
                                                        fontSize: 13,
                                                        height: 1.05,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                      textalign:
                                                          TextAlign.start,
                                                    ),
                                                  )
                                                : (dummyData!.mandatory ??
                                                        false)
                                                    ? Container(
                                                        child: CommanTextWidget
                                                            .regularBold(
                                                          "Qty : ${dummyData!.max_quantity ?? ""}",
                                                          ColorName
                                                              .ColorPrimary,
                                                          maxline: 1,
                                                          trt: TextStyle(
                                                            fontSize: 13,
                                                            height: 1.05,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                          textalign:
                                                              TextAlign.start,
                                                        ),
                                                      )
                                                    : Expanded(
                                                        child: dummyData
                                                                    .addQuantity !=
                                                                0
                                                            ? Container(
                                                                alignment:
                                                                    Alignment
                                                                        .topRight,
                                                                width: Sizeconfig
                                                                        .getWidth(
                                                                            context) *
                                                                    0.05,
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            15),
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        top: 0,
                                                                        right:
                                                                            0),
                                                                child: Appwidgets.AddQuantityButton(
                                                                    StringContants
                                                                        .lbl_add,
                                                                    dummyData
                                                                            .addQuantity!
                                                                        as int,
                                                                    () {
                                                                  if (dummyData
                                                                          .addQuantity ==
                                                                      int.parse(dummyData
                                                                          .orderQtyLimit!
                                                                          .toString())) {
                                                                    Fluttertoast
                                                                        .showToast(
                                                                            msg:
                                                                                StringContants.msg_quanitiy);
                                                                  } else {
                                                                    increase();
                                                                  }
                                                                }, () {
                                                                  decrease();
                                                                }),
                                                              )
                                                            : Container(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            20),
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        top: 0,
                                                                        right:
                                                                            0),
                                                                child: Appwidgets()
                                                                    .buttonPrimary(
                                                                  StringContants
                                                                      .lbl_add,
                                                                  () {
                                                                    // dummyData.addQuantity =
                                                                    //     dummyData.addQuantity + 1;
                                                                    increase();
                                                                  },
                                                                ),
                                                              ),
                                                        flex: 2,
                                                      )
                                          ],
                                        ),
                                        InkWell(
                                          onTap: () {
                                            productclick();
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 0, vertical: 5),
                                            width:
                                                Sizeconfig.getWidth(context) *
                                                    .22,
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    dummyData.productWeight
                                                            .toString()! +
                                                        " ${dummyData.productWeightUnit}",
                                                    style: TextStyle(
                                                      fontSize:
                                                          Constants.Size_10,
                                                      fontFamily: Fontconstants
                                                          .fc_family_sf,
                                                      fontWeight: Fontconstants
                                                          .SF_Pro_Display_Bold,
                                                      color:
                                                          ColorName.textlight,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin:
                                              EdgeInsets.only(top: 5, right: 0),
                                          child: Row(
                                            mainAxisAlignment: showprice2 == ""
                                                ? MainAxisAlignment.spaceBetween
                                                : MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                showprice2,
                                                style: TextStyle(
                                                  fontSize: Constants.Size_10,
                                                  fontFamily: Fontconstants
                                                      .fc_family_sf,
                                                  fontWeight: Fontconstants
                                                      .SF_Pro_Display_Bold,
                                                  color: ColorName.textlight,
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Row(
                                                    children: [
                                                      CommanTextWidget
                                                          .regularBold(
                                                        crossprice,
                                                        ColorName.textlight,
                                                        maxline: 2,
                                                        trt: TextStyle(
                                                          fontSize: 11,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough,
                                                          decorationColor:
                                                              ColorName
                                                                  .textlight,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        textalign:
                                                            TextAlign.start,
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Expanded(
                                                        flex: 0,
                                                        child: CommanTextWidget
                                                            .regularBold(
                                                          showprice,
                                                          Colors.black,
                                                          maxline: 1,
                                                          trt: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                          textalign:
                                                              TextAlign.start,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  flex: 3,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  (dummyData.discountText ?? "") == ""
                      ? Container()
                      : Positioned(
                          left: 0,
                          right: 0,
                          top: 5,
                          child: Container(
                            child: Visibility(
                              visible: (dummyData!.discountText != "" ||
                                  dummyData!.discountText != null),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    // left: 7,

                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.asset(
                                          Imageconstants.img_detailoffer,
                                          height: 25,
                                          width: 25,
                                          fit: BoxFit.fill,
                                        ),
                                        Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            dummyData.discountText ?? "",
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: const TextStyle(
                                              color: ColorName.black,
                                              fontSize: 5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container()
                                ],
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
            isShowBottomMessage
                ? ((dummyData!.cOfferId != 0 &&
                        dummyData.cOfferId != null &&
                        dummyData.subProduct != null &&
                        (showWarningMessage != false || offerAppilied != false))
                    ? Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 10.0,
                        ),
                        padding: EdgeInsets.only(bottom: 1),
                        decoration: BoxDecoration(
                          color: showWarningMessage
                              ? Colors.red.shade400
                              : Colors.green,
                          borderRadius: (dummyData!.cOfferId != 0 &&
                                  dummyData.cOfferId != null &&
                                  dummyData.subProduct != null &&
                                  (showWarningMessage != false ||
                                      offerAppilied != false))
                              ? BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10))
                              : BorderRadius.circular(10),
                          // border: Border.all(color: ColorName.lightGey),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(),
                                Column(
                                  children: [
                                    showWarningMessage == false
                                        ? Container()
                                        : Container(
                                            width: Sizeconfig.getWidth(context),
                                            decoration: BoxDecoration(
                                                color: Colors.red.shade400,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10.0))),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 4, horizontal: 10),
                                            alignment: Alignment.center,
                                            child: Marquee(
                                              child: Text(
                                                  warningtitle.replaceAll(
                                                      "@#\$",
                                                      "${remainingQuanityt}"),
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10)),
                                            )),
                                    Visibility(
                                      visible: offerAppilied,
                                      child: Container(
                                          width: Sizeconfig.getWidth(context),
                                          // margin: EdgeInsets.symmetric(
                                          //     horizontal: 10, vertical: 10),

                                          child: Marquee(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  Imageconstants.img_offer,
                                                  height: 20,
                                                  width: 20,
                                                  color: Colors.white,
                                                ),
                                                5.toSpace,
                                                Container(
                                                  // width:
                                                  //     Sizeconfig.getWidth(context) *
                                                  //         0.8,
                                                  child: Text(
                                                    applied.replaceAll(
                                                        "@#\$",
                                                        buy_quantity
                                                            .toString()),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10),
                                                  ),
                                                )
                                              ],
                                            ),
                                          )),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ))
                    : Container())
                : Container(),
          ],
        ),
      ),
    );
  }

  static categoryItemViewproductValidation(
    BuildContext context,
    List<ProductUnit> list,
    ProductUnit dummyData,
    dynamic state,
    int index,
    Function increase,
    Function decrease,
    Function delete,
    Function refresh,
    bool isShowBottomMessage,
    bool ischeckbox,
    Function chekbox,
    bool isOfferdialog,
  ) {
    //debugPrint("CategoryItems " + jsonEncode(dummyData));

    // Show prices with quanitity
    var crossprice;
    var showprice;
    var showprice2;
    bool showWarningMessage = false;
    bool offerAppilied = false;
    if (dummyData.specialPrice != "Free") {
      debugPrint("specialPrice ${dummyData.specialPrice}");
      debugPrint("sortPrice ${dummyData.sortPrice}");
      debugPrint("price ${dummyData.price}");

      var sortPrice = (double.parse(dummyData.sortPrice == null ||
                      dummyData.sortPrice == "null" ||
                      dummyData.sortPrice == ""
                  ? "0.0"
                  : dummyData.sortPrice!) *
              dummyData.addQuantity)
          .toString();
      var specialPrice = (double.parse(dummyData.specialPrice == null ||
                      dummyData.specialPrice == "null" ||
                      dummyData.specialPrice == ""
                  ? "0.0"
                  : dummyData.specialPrice!) *
              dummyData.addQuantity)
          .toString();
      var price = (double.parse(dummyData.price == null ||
                      dummyData.price == "null" ||
                      dummyData.price == ""
                  ? "0.0"
                  : dummyData.price!) *
              dummyData.addQuantity)
          .toString();

      debugPrint("specialPrice 2 ${specialPrice}");
      debugPrint("sortPrice 2 ${sortPrice}");
      debugPrint("price 2 ${price}");

      crossprice = dummyData.specialPrice == ""
          ? ""
          : "₹ ${double.parse(price).toStringAsFixed(2)}";
      showprice = dummyData.specialPrice == ""
          ? "₹ ${double.parse(sortPrice ?? "0.0").toStringAsFixed(2)}"
          : "₹ ${double.parse(specialPrice ?? "0.0").toStringAsFixed(2)}";

      // Show unit price only

      var sortPrice2 = (double.parse(dummyData.sortPrice == null ||
                  dummyData.sortPrice == "null" ||
                  dummyData.sortPrice == ""
              ? "0.0"
              : dummyData.sortPrice!))
          .toString();
      var specialPrice2 = (double.parse(dummyData.specialPrice == null ||
                  dummyData.specialPrice == "null" ||
                  dummyData.specialPrice == ""
              ? "0.0"
              : dummyData.specialPrice!))
          .toString();
      showprice2 = dummyData.specialPrice == ""
          ? "₹ ${double.parse(sortPrice2 ?? "0.0").toStringAsFixed(2)}"
          : "₹ ${double.parse(specialPrice2).toStringAsFixed(2)}";
    } else {
      crossprice = "₹ ${double.parse(dummyData.price!).toStringAsFixed(2)}";
      showprice = "Free";
      showprice2 = "";
    }

    debugPrint("ShowPrice $showprice");
    debugPrint("Cross $crossprice");

    int totalAdded = 0;

    debugPrint("On Add Total Quanitiyt ${totalAdded}");

    int remainingQuanityt = 0;
    int buy_quantity = 0;
    String applied = "";
    String warningtitle = "";
    String offerinfo = "";
    List<String> addquanityId = [];

    if (dummyData.subProduct != null && dummyData!.subProduct!.buyQty != null) {
      for (var x in dummyData.subProduct!.subProductDetail!) {
        // if(x.productId==dummyData.productId)
        // {
        //   totalAdded=totalAdded+dummyData.addQuantity;
        //   addquanityId.add(x.productId!);
        // }
        // else {
        //   totalAdded = totalAdded + x.addQuantity;
        //   addquanityId.add(x.productId!);
        // }

        for (var y in list) {
          if (x.productId == y.productId) {
            debugPrint(
                "Subproducts item match in list ${x.name}  ${y.addQuantity}");
            // if(list.contains(y.productId)==false)
            //   {
            totalAdded = totalAdded + y.addQuantity;
            //}
          }
        }
      }

      if (totalAdded == 0) {
        totalAdded = dummyData.addQuantity;
        addquanityId.add(dummyData.productId!);
      }

      debugPrint("TotalAdded Quantity ${totalAdded}");

      applied = dummyData!.subProduct!.cOfferApplied!;
      offerinfo = dummyData!.subProduct!.cOfferInfo!;
      warningtitle = dummyData!.subProduct!.offerWarning!;
      buy_quantity = int.parse(dummyData!.subProduct!.buyQty! ?? "0");
      if (totalAdded == 0) {
        showWarningMessage = false;
        offerAppilied = false;
      } else if (totalAdded < buy_quantity) {
        remainingQuanityt = buy_quantity - totalAdded;
        showWarningMessage = true;
        offerAppilied = false;
      } else {
        showWarningMessage = false;
        offerAppilied = true;
      }

      debugPrint(
          "Feature product listing showWarningMessage ${totalAdded} ${showWarningMessage}");
      debugPrint("Feature product listing offerAppilied ${offerAppilied}");
    }

    productclick() {
      if (isOfferdialog) {
        Appwidgets.ShowDialogDescription(context, dummyData);
      } else {
        int isMoreUnitIndex = 0;
        List<ProductUnit> list = [];
        list.add(dummyData);
        for (int i = 0; i < list.length!; i++) {
          if (dummyData.productId == list[i].productId!) {
            list[i] = dummyData;
            index = i;
          }
        }

        // Navigator.pop(context);
        Navigator.pushNamed(
          context,
          Routes.product_Detail_screen,
          arguments: {'fromchekcout': false, 'list': list, 'index': index},
        ).then((value) async {
          OndoorThemeData.setStatusBarColor();
          refresh();

          // value = value as ProductUnit;
          //  bloc.add(ProductUpdateQuantityEvent(quanitity:value.addQuantity!, index: index));
          //  bloc.add(ProductChangeEvent(model: value));
        });
      }
    }

    return InkWell(
      onTap: () {
        // if (isOfferdialog) {
        //   Appwidgets.ShowDialogDescription(context, dummyData);
        // } else {
        //   int isMoreUnitIndex = 0;
        //   List<ProductUnit> list = [];
        //   list.add(dummyData);
        //   for (int i = 0; i < list.length!; i++) {
        //     if (dummyData.productId == list[i].productId!) {
        //       list[i] = dummyData;
        //       index = i;
        //     }
        //   }
        //
        //   // Navigator.pop(context);
        //   Navigator.pushNamed(
        //     context,
        //     Routes.product_Detail_screen,
        //     arguments: {
        //     'fromchekcout': false,'list': list, 'index': index},
        //   ).then((value) async {
        //     OndoorThemeData.setStatusBarColor();
        //     refresh();
        //
        //     // value = value as ProductUnit;
        //     //  bloc.add(ProductUpdateQuantityEvent(quanitity:value.addQuantity!, index: index));
        //     //  bloc.add(ProductChangeEvent(model: value));
        //   });
        // }
      },
      child: Container(
        color: Colors.yellow,
        child: Column(
          children: [
            Container(
              // height: Sizeconfig.getHeight(context) * 0.11,

              margin: EdgeInsets.only(right: 0, left: 0, top: 0),
              padding: EdgeInsets.only(top: 0, bottom: 0, left: 5, right: 10),

              decoration: BoxDecoration(
                color: ColorName.ColorBagroundPrimary,
                border: Border(
                  bottom: BorderSide(
                    color:
                        Colors.grey.withOpacity(0.5), // Set your desired color
                    width: 0.5, // Set the thickness of the border
                  ),
                ),
                // borderRadius: (dummyData!.cOfferId != 0 &&
                //     dummyData.cOfferId != null &&
                //     dummyData.subProduct != null &&
                //     (showWarningMessage != false || offerAppilied != false))
                //     ? BorderRadius.only(
                //     topRight: Radius.circular(10),
                //     topLeft: Radius.circular(10))
                //     : BorderRadius.circular(10),
                // border: Border.all(color: ColorName.lightGey),
              ),
              // margin:  EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Expanded(
                      //   flex: 3,
                      //   child:
                      // ),
                      /*  (ischeckbox && (dummyData!.mandatory ?? false) == false)
                          ? Container(
                              height: Sizeconfig.getHeight(context) * .12,
                              margin: EdgeInsets.only(right: 5),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(),
                                  Container(
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: Checkbox(
                                          checkColor: ColorName.white_card,
                                          activeColor: ColorName.ColorPrimary,
                                          visualDensity: VisualDensity
                                              .compact, // Reduce padding
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          value: dummyData.isChecked,
                                          onChanged: (value) {
                                            chekbox();
                                          }),
                                    ),
                                  ),
                                  Container(),
                                ],
                              ),
                            )
                          : Container(),*/
                      Container(
                        child: Padding(
                          padding: EdgeInsets.zero,
                          child: Stack(
                            children: [
                              InkWell(
                                onTap: () {
                                  productclick();
                                },
                                child: Container(
                                  child: Container(
                                    //color: ColorName.ColorPrimary,
                                    height: Sizeconfig.getHeight(context) * .12,
                                    padding: EdgeInsets.all(1),
                                    width: Sizeconfig.getWidth(context) * .2,
                                    child: Image.network(
                                      dummyData.image!,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 9,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        8.toSpace,
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                productclick();
                                              },
                                              child: Container(
                                                height: Sizeconfig.getHeight(
                                                        context) *
                                                    0.04,
                                                width: Sizeconfig.getWidth(
                                                        context) *
                                                    0.5,
                                                child: CommanTextWidget
                                                    .regularBold(
                                                  dummyData.name!,
                                                  Colors.black,
                                                  maxline: 2,
                                                  trt: TextStyle(
                                                    fontSize: 13,
                                                    height: 1.05,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                  textalign: TextAlign.start,
                                                ),
                                              ),
                                            ),
                                            (ischeckbox &&
                                                    (dummyData!.mandatory ??
                                                            false) ==
                                                        false)
                                                ? Container(
                                                    margin: EdgeInsets.only(
                                                        right: 5),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        // Container(
                                                        //   child: SizedBox(
                                                        //     height: 20,
                                                        //     width: 20,
                                                        //     child: Checkbox(
                                                        //         checkColor: ColorName.white_card,
                                                        //         activeColor: ColorName.ColorPrimary,
                                                        //         visualDensity: VisualDensity
                                                        //             .compact, // Reduce padding
                                                        //         materialTapTargetSize:
                                                        //         MaterialTapTargetSize.shrinkWrap,
                                                        //         value: dummyData.isChecked,
                                                        //         onChanged: (value) {
                                                        //           chekbox();
                                                        //         }),
                                                        //   ),
                                                        // ),

                                                        /*   Container(
                                                    child: SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child: Transform.scale(
                                                        scale: 1.2, // Adjust scale as needed
                                                        child: Checkbox(
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(50), // Makes it circular
                                                          ),
                                                          checkColor: ColorName.white_card,
                                                          activeColor: ColorName.ColorPrimary,
                                                          visualDensity: VisualDensity.compact, // Reduce padding
                                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                          value: dummyData.isChecked,
                                                          onChanged: (value) {
                                                            chekbox();
                                                          },
                                                        ),
                                                      ),
                                                    ),



                                                  ),*/

                                                        SizedBox(
                                                          // color: Colors.red,
                                                          width: 20,
                                                          height: 20,
                                                          child: Radio(
                                                            value: dummyData
                                                                .isChecked,
                                                            groupValue: true,
                                                            toggleable: true,
                                                            onChanged:
                                                                (value) async {
                                                              chekbox();
                                                            },
                                                          ),
                                                        ),
                                                        Container(),
                                                      ],
                                                    ),
                                                  )
                                                : (ischeckbox)
                                                    ? Container(
                                                        child: CommanTextWidget
                                                            .regularBold(
                                                          "Qty : ${dummyData!.quantity ?? ""}",
                                                          ColorName
                                                              .ColorPrimary,
                                                          maxline: 1,
                                                          trt: TextStyle(
                                                            fontSize: 13,
                                                            height: 1.05,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                          textalign:
                                                              TextAlign.start,
                                                        ),
                                                      )
                                                    : (dummyData!.mandatory ??
                                                            false)
                                                        ? Container(
                                                            child:
                                                                CommanTextWidget
                                                                    .regularBold(
                                                              "Qty : ${dummyData!.max_quantity ?? ""}",
                                                              ColorName
                                                                  .ColorPrimary,
                                                              maxline: 1,
                                                              trt: TextStyle(
                                                                fontSize: 13,
                                                                height: 1.05,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                              textalign:
                                                                  TextAlign
                                                                      .start,
                                                            ),
                                                          )
                                                        : Expanded(
                                                            child: dummyData
                                                                        .addQuantity !=
                                                                    0
                                                                ? Container(
                                                                    alignment:
                                                                        Alignment
                                                                            .topRight,
                                                                    width: Sizeconfig.getWidth(
                                                                            context) *
                                                                        0.05,
                                                                    padding: EdgeInsets
                                                                        .only(
                                                                            left:
                                                                                15),
                                                                    margin: EdgeInsets.only(
                                                                        top: 0,
                                                                        right:
                                                                            0),
                                                                    child: Appwidgets.AddQuantityButton(
                                                                        StringContants
                                                                            .lbl_add,
                                                                        dummyData.addQuantity!
                                                                            as int,
                                                                        () {
                                                                      if (dummyData
                                                                              .addQuantity ==
                                                                          int.parse(dummyData
                                                                              .orderQtyLimit!
                                                                              .toString())) {
                                                                        Fluttertoast.showToast(
                                                                            msg:
                                                                                StringContants.msg_quanitiy);
                                                                      } else {
                                                                        increase();
                                                                      }
                                                                    }, () {
                                                                      decrease();
                                                                    }),
                                                                  )
                                                                : Container(
                                                                    padding: EdgeInsets
                                                                        .only(
                                                                            left:
                                                                                20),
                                                                    margin: EdgeInsets.only(
                                                                        top: 0,
                                                                        right:
                                                                            0),
                                                                    child: Appwidgets()
                                                                        .buttonPrimary(
                                                                      StringContants
                                                                          .lbl_add,
                                                                      () {
                                                                        // dummyData.addQuantity =
                                                                        //     dummyData.addQuantity + 1;
                                                                        increase();
                                                                      },
                                                                    ),
                                                                  ),
                                                            flex: 2,
                                                          )
                                          ],
                                        ),
                                        (ischeckbox &&
                                                dummyData!.mandatory == true)
                                            ? Container()
                                            : (ischeckbox)
                                                ? Container(
                                                    child: CommanTextWidget
                                                        .regularBold(
                                                      "Qty : ${dummyData!.quantity ?? ""}",
                                                      ColorName.ColorPrimary,
                                                      maxline: 1,
                                                      trt: TextStyle(
                                                        fontSize: 13,
                                                        height: 1.05,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                      textalign:
                                                          TextAlign.start,
                                                    ),
                                                  )
                                                : (dummyData!.mandatory ??
                                                        false)
                                                    ? Container(
                                                        child: CommanTextWidget
                                                            .regularBold(
                                                          "Qty : ${dummyData!.max_quantity ?? ""}",
                                                          ColorName
                                                              .ColorPrimary,
                                                          maxline: 1,
                                                          trt: TextStyle(
                                                            fontSize: 13,
                                                            height: 1.05,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                          textalign:
                                                              TextAlign.start,
                                                        ),
                                                      )
                                                    : Container(),
                                        5.toSpace,
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                productclick();
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 0, vertical: 5),
                                                width: Sizeconfig.getWidth(
                                                        context) *
                                                    .22,
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        dummyData.productWeight
                                                                .toString()! +
                                                            " ${dummyData.productWeightUnit}",
                                                        style: TextStyle(
                                                          fontSize:
                                                              Constants.Size_10,
                                                          fontFamily:
                                                              Fontconstants
                                                                  .fc_family_sf,
                                                          fontWeight: Fontconstants
                                                              .SF_Pro_Display_Bold,
                                                          color: ColorName
                                                              .textlight,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(
                                                  top: 5, right: 0),
                                              child: Row(
                                                mainAxisAlignment: showprice2 ==
                                                        ""
                                                    ? MainAxisAlignment
                                                        .spaceBetween
                                                    : MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    showprice2,
                                                    style: TextStyle(
                                                      fontSize:
                                                          Constants.Size_10,
                                                      fontFamily: Fontconstants
                                                          .fc_family_sf,
                                                      fontWeight: Fontconstants
                                                          .SF_Pro_Display_Bold,
                                                      color:
                                                          ColorName.textlight,
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          CommanTextWidget
                                                              .regularBold(
                                                            crossprice,
                                                            ColorName.textlight,
                                                            maxline: 2,
                                                            trt: TextStyle(
                                                              fontSize: 11,
                                                              decoration:
                                                                  TextDecoration
                                                                      .lineThrough,
                                                              decorationColor:
                                                                  ColorName
                                                                      .textlight,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                            textalign:
                                                                TextAlign.start,
                                                          ),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Expanded(
                                                            flex: 0,
                                                            child:
                                                                CommanTextWidget
                                                                    .regularBold(
                                                              showprice,
                                                              Colors.black,
                                                              maxline: 1,
                                                              trt: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                              textalign:
                                                                  TextAlign
                                                                      .start,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  flex: 3,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  (dummyData.discountText ?? "") == ""
                      ? Container()
                      : Positioned(
                          left: 0,
                          right: 0,
                          top: 5,
                          child: Container(
                            child: Visibility(
                              visible: (dummyData!.discountText != "" ||
                                  dummyData!.discountText != null),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    // left: 7,

                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.asset(
                                          Imageconstants.img_detailoffer,
                                          height: 25,
                                          width: 25,
                                          fit: BoxFit.fill,
                                        ),
                                        Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            dummyData.discountText ?? "",
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: const TextStyle(
                                              color: ColorName.black,
                                              fontSize: 5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container()
                                ],
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
            isShowBottomMessage
                ? ((dummyData!.cOfferId != 0 &&
                        dummyData.cOfferId != null &&
                        dummyData.subProduct != null &&
                        (showWarningMessage != false || offerAppilied != false))
                    ? Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 10.0,
                        ),
                        padding: EdgeInsets.only(bottom: 1),
                        decoration: BoxDecoration(
                          color: showWarningMessage
                              ? Colors.red.shade400
                              : Colors.green,
                          borderRadius: (dummyData!.cOfferId != 0 &&
                                  dummyData.cOfferId != null &&
                                  dummyData.subProduct != null &&
                                  (showWarningMessage != false ||
                                      offerAppilied != false))
                              ? BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10))
                              : BorderRadius.circular(10),
                          // border: Border.all(color: ColorName.lightGey),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(),
                                Column(
                                  children: [
                                    showWarningMessage == false
                                        ? Container()
                                        : Container(
                                            width: Sizeconfig.getWidth(context),
                                            decoration: BoxDecoration(
                                                color: Colors.red.shade400,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10.0))),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 4, horizontal: 10),
                                            alignment: Alignment.center,
                                            child: Marquee(
                                              child: Text(
                                                  warningtitle.replaceAll(
                                                      "@#\$",
                                                      "${remainingQuanityt}"),
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10)),
                                            )),
                                    Visibility(
                                      visible: offerAppilied,
                                      child: Container(
                                          width: Sizeconfig.getWidth(context),
                                          // margin: EdgeInsets.symmetric(
                                          //     horizontal: 10, vertical: 10),

                                          child: Marquee(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  Imageconstants.img_offer,
                                                  height: 20,
                                                  width: 20,
                                                  color: Colors.white,
                                                ),
                                                5.toSpace,
                                                Container(
                                                  // width:
                                                  //     Sizeconfig.getWidth(context) *
                                                  //         0.8,
                                                  child: Text(
                                                    applied.replaceAll(
                                                        "@#\$",
                                                        buy_quantity
                                                            .toString()),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10),
                                                  ),
                                                )
                                              ],
                                            ),
                                          )),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ))
                    : Container())
                : Container(),
          ],
        ),
      ),
    );
  }

  static ShowBottomView(
    BuildContext context,
    CardBloc cardBloc,
    FeaturedBloc blocFeatured,
    ShopByCategoryBloc blocShopby,
    AnimationBloc animationBloc,
    var animatedSize,
    int count,
    String image,
    bool isup,
    DatabaseHelper dbhelper,
    Function callback,
    bool validate,
  ) {
    List<ProductUnit> cartitesmList = [];

    List<ProductUnit> list_cOffers = [];
    List<ProductUnit> freeProducts = [];
    bool loadProductValidation = true;

    double totalAmount = 0;
    updateCard(ProductUnit model, int index, var list) async {
      int status = await dbhelper.updateCard({
        DBConstants.PRODUCT_ID: int.parse(model.productId!),
        DBConstants.QUANTITY: model.addQuantity,
      });

      debugPrint("Update Product Status " + status.toString());

      cardBloc.add(CardUpdateQuantityEvent(
          quantity: model.addQuantity, index: index, listProduct: list));

      dbhelper.loadAddCardProducts(cardBloc);
    }

    double height = 0;
    return BlocProvider(
      create: (context) => cardBloc,
      child: BlocBuilder(
          bloc: cardBloc,
          builder: (context, state) {
            debugPrint("ShowBottomView ***   $state $animatedSize");

            if (state is AddCardState) {
              count = state.count;
            }
            if (state is AddCardProductState) {
              cartitesmList = state.listProduct;
              count = state.listProduct.length;
              image = state.listProduct.first.image!;
              debugPrint(
                  "Cart Items list ***" + cartitesmList.length.toString());
              debugPrint("Cart Items list ***" + image);

              if (animatedSize == 0) {
                //animationBloc.add(AnimatedNullEvent());
                //animationBloc.add(AnimatedNullEvent());
                animationBloc.add(AnimationCartEvent(size: 70.0));
              }

              // //setAnimation(animationBloc,70.0);
              // Future.delayed(Duration(seconds: 1),(){
              //
              //
              //   print("ajhhasdhadla");
              //
              //
              // });

              totalAmount = 0;

              for (var dummyData in cartitesmList) {
                debugPrint(
                    "GGGNull Exception${dummyData.name} ${dummyData.sortPrice == "null"}");
                var sortPrice = (double.parse(dummyData.sortPrice == null ||
                                dummyData.sortPrice == "null" ||
                                dummyData.sortPrice == ""
                            ? "0.0"
                            : dummyData.sortPrice!) *
                        dummyData.addQuantity)
                    .toString();
                var specialPrice = (double.parse(
                            dummyData.specialPrice == null ||
                                    dummyData.specialPrice == "null" ||
                                    dummyData.specialPrice == ""
                                ? "0.0"
                                : dummyData.specialPrice!) *
                        dummyData.addQuantity)
                    .toString();
                var price = (double.parse(dummyData.price == null ||
                                dummyData.price == "null" ||
                                dummyData.price == ""
                            ? "0.0"
                            : dummyData.price!) *
                        dummyData.addQuantity)
                    .toString();

                debugPrint("specialPrice 2 ${specialPrice}");
                debugPrint("sortPrice 2 ${sortPrice}");
                debugPrint("price 2 ${price}");

                var crossprice = dummyData.specialPrice == ""
                    ? ""
                    : "₹ ${double.parse(price).toStringAsFixed(2)}";
                var showprice = dummyData.specialPrice == ""
                    ? " ${double.parse(sortPrice ?? "0.0").toStringAsFixed(2)}"
                    : "${double.parse(specialPrice).toStringAsFixed(2)}";

                totalAmount = totalAmount + double.parse(showprice);
              }
              debugPrint("CartTotal amount ${totalAmount}");
            }

            if (state is CardUpdateQuanitiyState) {
              debugPrint(" CARD UPDATE ${state.listProduct.length}");
              image = state.listProduct.first.image!;
              debugPrint(" CARD UPDATE ${image}");
              cartitesmList = state.listProduct;

              // count=state.listProduct.length;
              // image=state.listProduct.first.image!;
            }
            if (cartitesmList.isEmpty) {
              return Container(
                height: 0,
              );
            }
            if (state is CardEmptyState) {
              //animationBloc.add(AnimatedNullEvent());
              animationBloc.add(AnimationCartEvent(size: 0.0));
              return Container(
                height: 0,
              );
            }
            if (state is CardDeleteSatate) {
              debugPrint("CardDeleteSatate >>>>>  ${state.listProduct.length}");
              cartitesmList = state.listProduct;
            }

            return BlocProvider(
              create: (context) => animationBloc,
              child: BlocBuilder(
                  bloc: animationBloc,
                  builder: (context, state2) {
                    debugPrint(
                        "Animation Cart State  1 ${state2} $animatedSize");

                    if (state2 is AnimationCartState) {
                      animatedSize = state2.size;
                      debugPrint(
                          "Animation Cart State ${state2} $animatedSize");

                      if (cartitesmList.length == 1) {
                        height = cartitesmList.length *
                            (MediaQuery.of(context).copyWith().size.height *
                                0.30);
                      } else if (cartitesmList.length > 2) {
                        height =
                            (MediaQuery.of(context).copyWith().size.height *
                                0.53);
                      } else {
                        height =
                            (MediaQuery.of(context).copyWith().size.height *
                                0.54);
                      }
                    }

                    return AnimatedContainer(
                      height: double.parse(animatedSize.toString()),

                      duration: const Duration(seconds: 2),
                      // Provide an optional curve to make the animation feel smoother.
                      curve: Curves.fastOutSlowIn,
                      child: VisibilityDetector(
                        key: const Key('ondoor.widget'),
                        onVisibilityChanged: (visibilityInfo) async {
                          var visiblePercentage =
                              visibilityInfo.visibleFraction * 100;
                          debugPrint(
                              'Widgetnew ${visibilityInfo.key} is $visiblePercentage% visible');
                          dbhelper.loadAddCardProducts(cardBloc);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 0),
                          child: StatefulBuilder(builder: ((context, setState) {
                            return Container(
                              height: animatedSize,
                              //height:animatedSize>70? Sizeconfig.getHeight(context):animatedSize,

                              child: Stack(
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: ColorName.aquaHazeColor,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        ),
                                      ),
                                      child: Scaffold(
                                        body: WillPopScope(
                                          onWillPop: () async {
                                            Navigator.pop(context);
                                            return false;
                                          },
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                top: Radius.circular(25),
                                              ),
                                              color: ColorName.aquaHazeColor,
                                            ),
                                            child: Container(
                                              child: Column(
                                                children: [
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10),
                                                    child: Text(
                                                      "Your cart (${cartitesmList.length} ${cartitesmList.length > 1 ? 'items' : 'item'})",
                                                      style: TextStyle(
                                                          fontSize: Constants
                                                              .SizeMidium,
                                                          fontFamily:
                                                              Fontconstants
                                                                  .fc_family_sf,
                                                          fontWeight: Fontconstants
                                                              .SF_Pro_Display_SEMIBOLD,
                                                          color: ColorName
                                                              .ColorPrimary),
                                                    ),
                                                  ),
                                                  cartitesmList.length == 0
                                                      ? Container()
                                                      : Container(
                                                          child: Expanded(
                                                            // height: height - 130,
                                                            child: ListView
                                                                .separated(
                                                              shrinkWrap: true,
                                                              itemCount:
                                                                  cartitesmList
                                                                      .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                var dummyData =
                                                                    cartitesmList[
                                                                        index];

                                                                if (state
                                                                    is CardUpdateQuanitiyState) {
                                                                  debugPrint(
                                                                      "CardUpdateQuantity");
                                                                  cartitesmList[state
                                                                              .index]
                                                                          .addQuantity =
                                                                      state
                                                                          .quantity;
                                                                }

                                                                return categoryItemView(
                                                                    false,
                                                                    false,
                                                                    context,
                                                                    cartitesmList,
                                                                    dummyData,
                                                                    null,
                                                                    0, () {
                                                                  dummyData
                                                                          .addQuantity =
                                                                      dummyData
                                                                              .addQuantity +
                                                                          1;

                                                                  debugPrint(
                                                                      "${dummyData.addQuantity}");

                                                                  updateCard(
                                                                      dummyData,
                                                                      index,
                                                                      cartitesmList);

                                                                  blocShopby.add(
                                                                      ShopByNullEvent());
                                                                  blocShopby.add(
                                                                      ShopbyProductChangeEvent(
                                                                          model:
                                                                              dummyData));

                                                                  blocFeatured.add(
                                                                      ProductUpdateQuantityEventBYModel(
                                                                          model:
                                                                              dummyData));

                                                                  blocFeatured.add(
                                                                      ProductChangeEvent(
                                                                          model:
                                                                              dummyData));

                                                                  debugPrint(
                                                                      "Increase cart ");
                                                                }, () async {
                                                                  if (dummyData
                                                                          .addQuantity ==
                                                                      1) {
                                                                    dummyData
                                                                        .addQuantity = 0;
                                                                    blocFeatured.add(
                                                                        ProductUpdateQuantityEventBYModel(
                                                                            model:
                                                                                dummyData));
                                                                    blocShopby.add(
                                                                        ShopByNullEvent());
                                                                    blocShopby.add(
                                                                        ShopbyProductChangeEvent(
                                                                            model:
                                                                                dummyData));
                                                                    await dbhelper
                                                                        .deleteCard(int.parse(dummyData
                                                                            .productId!))
                                                                        .then(
                                                                            (value) {
                                                                      debugPrint(
                                                                          "Delete Product $value ");
                                                                      cardBloc.add(CardDeleteEvent(
                                                                          model: cartitesmList[
                                                                              index],
                                                                          listProduct:
                                                                              cartitesmList));
                                                                      dbhelper.loadAddCardProducts(
                                                                          cardBloc);

                                                                      cartitesmList
                                                                          .removeAt(
                                                                              index);

                                                                      if (cartitesmList
                                                                              .length ==
                                                                          0) {
                                                                        cardBloc
                                                                            .add(CardEmptyEvent());
                                                                        Navigator.pop(
                                                                            context);
                                                                      }
                                                                    });
                                                                  } else if (dummyData
                                                                          .addQuantity !=
                                                                      0) {
                                                                    dummyData
                                                                            .addQuantity =
                                                                        dummyData.addQuantity -
                                                                            1;

                                                                    updateCard(
                                                                        dummyData,
                                                                        index,
                                                                        cartitesmList);
                                                                    blocFeatured.add(
                                                                        ProductUpdateQuantityEventBYModel(
                                                                            model:
                                                                                dummyData));
                                                                    blocShopby.add(
                                                                        ShopByNullEvent());
                                                                    blocFeatured.add(
                                                                        ProductChangeEvent(
                                                                            model:
                                                                                dummyData));
                                                                    blocShopby.add(
                                                                        ShopByNullEvent());
                                                                    blocShopby.add(
                                                                        ShopbyProductChangeEvent(
                                                                            model:
                                                                                dummyData));
                                                                  }
                                                                }, () async {
                                                                  dummyData
                                                                      .addQuantity = 0;
                                                                  blocFeatured.add(
                                                                      ProductUpdateQuantityEventBYModel(
                                                                          model:
                                                                              dummyData));
                                                                  blocShopby.add(
                                                                      ShopByNullEvent());
                                                                  blocShopby.add(
                                                                      ShopbyProductChangeEvent(
                                                                          model:
                                                                              dummyData));
                                                                  await dbhelper
                                                                      .deleteCard(int.parse(
                                                                          dummyData
                                                                              .productId!))
                                                                      .then(
                                                                          (value) {
                                                                    debugPrint(
                                                                        "Delete Product $value ");
                                                                    cardBloc.add(CardDeleteEvent(
                                                                        model: cartitesmList[
                                                                            index],
                                                                        listProduct:
                                                                            cartitesmList));
                                                                    dbhelper.loadAddCardProducts(
                                                                        cardBloc);

                                                                    cartitesmList
                                                                        .removeAt(
                                                                            index);

                                                                    if (cartitesmList
                                                                            .length ==
                                                                        0) {
                                                                      cardBloc.add(
                                                                          CardEmptyEvent());
                                                                      Navigator.pop(
                                                                          context);
                                                                    }
                                                                  });
                                                                }, () {
                                                                  dbhelper.loadAddCardProducts(
                                                                      cardBloc);
                                                                  //   refresh();
                                                                },
                                                                    true,
                                                                    false,
                                                                    () {},
                                                                    false,
                                                                    blocFeatured);
                                                              },
                                                              separatorBuilder:
                                                                  (BuildContext
                                                                          context,
                                                                      int index) {
                                                                return Padding(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              8.0),
                                                                  child: SizedBox(
                                                                      height:
                                                                          2.0),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        // translate the FAB up by 30
                                        floatingActionButton: animatedSize > 70
                                            ? Container(
                                                transform:
                                                    Matrix4.translationValues(
                                                        0.0,
                                                        -60,
                                                        0.0), // translate up by 30
                                                child: InkWell(
                                                    onTap: () {
                                                      // do stuff
                                                      debugPrint('doing stuff');
                                                      animationBloc.add(
                                                          AnimationCartEvent(
                                                              size: 0));
                                                    },
                                                    child: Image.asset(
                                                      Imageconstants
                                                          .img_roud_cross,
                                                      height: 40,
                                                      width: 40,
                                                    )),
                                              )
                                            : Container(),
                                        floatingActionButtonLocation:
                                            FloatingActionButtonLocation
                                                .centerTop,

                                        //  bottomNavigationBar: Appwidgets.ShowBottomView(
                                        //      context,
                                        //      cardBloc,
                                        //      blocFeatured,
                                        //      blocShopby,
                                        //      AnimationBloc(),
                                        //      70.0,
                                        //      cartitesmList.length,
                                        //      cartitesmList.isEmpty
                                        //          ? ""
                                        //          : cartitesmList[0].image!,
                                        //      false,
                                        //      dbhelper, () {
                                        // //   refresh();
                                        //    Navigator.pop(context);
                                        //  }, validate),
                                      )),
                                  Positioned(
                                    bottom: 0,
                                    child: Container(
                                      width: Sizeconfig.getWidth(context),
                                      decoration: BoxDecoration(
                                        // color: Colors.white,

                                        color: ColorName.ColorPrimary,

                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(
                                              animatedSize > 70 ? 0 : 10),
                                          topRight: Radius.circular(
                                              animatedSize > 70 ? 0 : 10),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            spreadRadius: 1,
                                            blurRadius: 5,
                                            offset: Offset(0,
                                                -2), // Changes position of shadow
                                          ),
                                        ],
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 1,
                                            width: Sizeconfig.getWidth(context),
                                            color: ColorName.textlight
                                                .withOpacity(0.1),
                                          ),
                                          Container(
                                            height: 69,
                                            child: InkWell(
                                              onTap: () {
                                                if (isup) {
                                                  //animationBloc.add(AnimatedNullEvent());
                                                  //animationBloc.add(AnimatedNullEvent());

                                                  animationBloc.add(AnimationCartEvent(
                                                      size: (cartitesmList
                                                                  .length *
                                                              Sizeconfig
                                                                  .getHeight(
                                                                      context) *
                                                              0.13) +
                                                          Sizeconfig.getHeight(
                                                                  context) *
                                                              0.16));
                                                  debugPrint("Action GG 1");
                                                  isup = false;
                                                  // Appwidgets.ShowDialogBottom(
                                                  //     context,
                                                  //     cardBloc,
                                                  //     cartitesmList,
                                                  //     blocFeatured,
                                                  //     blocShopby, () {
                                                  //   dbhelper.loadAddCardProducts(
                                                  //       cardBloc);
                                                  //   callback();
                                                  // }, validate);
                                                } else {
                                                  //animationBloc.add(AnimatedNullEvent());
                                                  //animationBloc.add(AnimatedNullEvent());

                                                  animationBloc.add(
                                                      AnimationCartEvent(
                                                          size: 70.00));
                                                  //   Navigator.pop(context);
                                                  debugPrint("Action GG 2");
                                                  isup = true;
                                                }
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        child: Container(
                                                          height: Sizeconfig
                                                                  .getWidth(
                                                                      context) *
                                                              0.13,
                                                          width: Sizeconfig
                                                                  .getWidth(
                                                                      context) *
                                                              0.13,

                                                          child: Stack(
                                                            children: [
                                                              Positioned(
                                                                bottom: 0,
                                                                left: 0,
                                                                child:
                                                                    Container(
                                                                  child: Image
                                                                      .asset(
                                                                    height: Sizeconfig.getWidth(
                                                                            context) *
                                                                        0.10,
                                                                    width: Sizeconfig.getWidth(
                                                                            context) *
                                                                        0.11,
                                                                    fit: BoxFit
                                                                        .fill,
                                                                    Imageconstants
                                                                        .img_cartnewicon,
                                                                  ),
                                                                ),
                                                              ),
                                                              Positioned(
                                                                right: 0,
                                                                child:
                                                                    Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              12),
                                                                  height: 18,
                                                                  width: 18,
                                                                  decoration: BoxDecoration(
                                                                      color: ColorName
                                                                          .darkBlue,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10.0)),
                                                                  child: Center(
                                                                    child: Text(
                                                                      "${count}",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              10,
                                                                          fontFamily: Fontconstants
                                                                              .fc_family_sf,
                                                                          fontWeight: Fontconstants
                                                                              .SF_Pro_Display_Regular,
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          // child: Icon(
                                                          //   Icons
                                                          //       .shopping_cart_outlined,
                                                          //   color: Colors.black,
                                                          //   size:
                                                          //   Sizeconfig.getWidth(
                                                          //       context) *
                                                          //       0.10,
                                                          // )

                                                          //     CommonCachedImageWidget(
                                                          //   imgUrl: image,
                                                          // ),
                                                          // color: Colors.red,
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                            left: 15),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                    StringContants
                                                                        .lbl_viewcart,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            Constants
                                                                                .Sizelagre,
                                                                        fontFamily:
                                                                            Fontconstants
                                                                                .fc_family_popins,
                                                                        fontWeight:
                                                                            Fontconstants
                                                                                .SF_Pro_Display_Bold,
                                                                        color: Colors
                                                                            .white)),
                                                                Container(
                                                                    margin: EdgeInsets.only(
                                                                        left:
                                                                            10),
                                                                    child: isup
                                                                        ? Container(
                                                                            // gray box
                                                                            child:
                                                                                new Center(
                                                                              child: RotationTransition(
                                                                                child: Image.asset(isup ? Imageconstants.img_dropdownarrow : Imageconstants.img_dropdownarrow, height: 16, width: 16, fit: BoxFit.fill, color: Colors.white),
                                                                                alignment: FractionalOffset.center,
                                                                                turns: new AlwaysStoppedAnimation(180 / 360),
                                                                              ),
                                                                            ),
                                                                          )
                                                                        : Image.asset(
                                                                            Imageconstants
                                                                                .img_dropdownarrow,
                                                                            height:
                                                                                16,
                                                                            width:
                                                                                16,
                                                                            fit:
                                                                                BoxFit.fill,
                                                                            color: Colors.white))
                                                              ],
                                                            ),
                                                            Text(
                                                              "Total : ${Constants.ruppessymbol}" +
                                                                  totalAmount
                                                                      .toString() +
                                                                  " ",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      Constants
                                                                          .SizeSmall,
                                                                  fontFamily:
                                                                      Fontconstants
                                                                          .fc_family_popins,
                                                                  fontWeight:
                                                                      Fontconstants
                                                                          .SF_Pro_Display_Bold,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                    ],
                                                  ),
                                                  Container(
                                                    child: Appwidgets
                                                        .ButtonSecondarywhite(
                                                            validate
                                                                ? StringContants
                                                                    .lbl_checkout
                                                                : StringContants
                                                                    .lbl_next,
                                                            () {
                                                      debugPrint(
                                                          "Product validation count ${validate}");

                                                      if (isup == false) {
                                                        // Navigator.pop(context);
                                                      }

                                                      if (validate) {
                                                        Productvalidationswidgets
                                                            .loadProductValication(
                                                                dbhelper,
                                                                context,
                                                                cartitesmList,
                                                                () {
                                                          debugPrint(
                                                              "isup%%%**  ${isup}");
                                                          callback();
                                                          dbhelper
                                                              .loadAddCardProducts(
                                                                  cardBloc);
                                                        });
                                                      } else {
                                                        String id = "";
                                                        for (var x
                                                            in cartitesmList) {
                                                          id = id +
                                                              x.productId! +
                                                              ",";
                                                        }

                                                        if (id.endsWith(',')) {
                                                          id = id.substring(
                                                              0, id.length - 1);
                                                        }

                                                        debugPrint(
                                                            "ProductsIds ${id}");
                                                        ApiProvider()
                                                            .beforeYourCheckout(
                                                                id, 1, context)
                                                            .then(
                                                                (value) async {
                                                          if (value != "") {
                                                            log("ROHIT Log 22  ${value}");
                                                            Navigator.pushNamed(
                                                              context,
                                                              Routes
                                                                  .ordersummary_screen,
                                                              arguments: {
                                                                "ProductsIds":
                                                                    id,
                                                                "response":
                                                                    value,
                                                              },
                                                            ).then((value) {
                                                              callback();
                                                            });
                                                          } else {
                                                            print(
                                                                "ROHIT Log 2");
                                                          }
                                                        });
                                                      }
                                                    }),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          })),
                        ),
                      ),
                    );
                  }),
            );
          }),
    );
  }

  static buildCustomBottomView({Color backgroundColor = Colors.white}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 0.5,
            blurRadius: 1,
            offset: Offset(0, -2), // Changes position of shadow
          ),
        ],
      ),

      // Apply the background color here
      height: 100, // Set the height of your bottom view
      child: Center(
        child: Text(
          'Custom Bottom View',
          style: TextStyle(color: Colors.white), // Text color
        ),
      ),
    );
  }

  static ShowBottomView33(
    bool fromchekcout,
    BuildContext context,
    CardBloc cardBloc,
    FeaturedBloc blocFeatured,
    ShopByCategoryBloc blocShopby,
    AnimationBloc animationBloc,
    var animatedSize,
    int count,
    String image,
    bool isup,
    DatabaseHelper dbhelper,
    Function callback,
    Function reloadpage,
    Function functiontoCloseAnimation,
    bool validate,
    Function(bool) isopen,
    Function(double) getheight,
  ) {
    List<ProductUnit> cartitesmList = [];

    List<ProductUnit> list_cOffers = [];
    List<ProductUnit> freeProducts = [];
    bool loadProductValidation = true;

    // double animatedSize=animatedSize1;
    double totalAmount = 0;
    updateCard(ProductUnit model, int index, var list) async {
      int status = await dbhelper.updateCard({
        DBConstants.PRODUCT_ID: int.parse(model.productId!),
        DBConstants.QUANTITY: model.addQuantity,
      });

      debugPrint("Update Product Status " + status.toString());

      cardBloc.add(CardUpdateQuantityEvent(
          quantity: model.addQuantity, index: index, listProduct: list));

      //dbhelper.loadAddCardProducts(cardBloc);
    }

    double height = 0;
    return BlocProvider(
      create: (context) => cardBloc,
      child: BlocBuilder(
          bloc: cardBloc,
          builder: (context, state) {
            debugPrint("ShowBottomView ***   $state $animatedSize");
            debugPrint("ShowBottomView ***  $validate");

            if (state is AddCardState) {
              count = state.count;
            }
            if (state is AddCardProductState) {
              cartitesmList = state.listProduct;
              count = state.listProduct.length;
              image = state.listProduct.first.image!;
              debugPrint("Cart Items list *** ${animatedSize}" +
                  cartitesmList.length.toString());
              debugPrint("Cart Items list ***" + image);

              if (animatedSize == 0) {
                animatedSize = 70.0;
                debugPrint("ggggggg**");
                getheight(animatedSize);

                animationBloc.add(AnimationCartEvent(size: animatedSize));
                //animationBloc.add(AnimatedNullEvent());
                //animationBloc.add(AnimatedNullEvent());
              }

              totalAmount = 0;

              for (var dummyData in cartitesmList) {
                debugPrint(
                    "GGGNull Exception${dummyData.name} ${dummyData.sortPrice == "null"}");
                var sortPrice = (double.parse(dummyData.sortPrice == null ||
                                dummyData.sortPrice == "null" ||
                                dummyData.sortPrice == ""
                            ? "0.0"
                            : dummyData.sortPrice!) *
                        dummyData.addQuantity)
                    .toString();
                var specialPrice = (double.parse(
                            dummyData.specialPrice == null ||
                                    dummyData.specialPrice == "null" ||
                                    dummyData.specialPrice == ""
                                ? "0.0"
                                : dummyData.specialPrice!) *
                        dummyData.addQuantity)
                    .toString();
                var price = (double.parse(dummyData.price == null ||
                                dummyData.price == "null" ||
                                dummyData.price == ""
                            ? "0.0"
                            : dummyData.price!) *
                        dummyData.addQuantity)
                    .toString();

                debugPrint("specialPrice 2 ${specialPrice}");
                debugPrint("sortPrice 2 ${sortPrice}");
                debugPrint("price 2 ${price}");

                var crossprice = dummyData.specialPrice == ""
                    ? ""
                    : "₹ ${double.parse(price).toStringAsFixed(2)}";
                var showprice = dummyData.specialPrice == null ||
                        dummyData.specialPrice == "null" ||
                        dummyData.specialPrice == ""
                    ? " ${double.parse(sortPrice ?? "0.0").toStringAsFixed(2)}"
                    : "${double.parse(specialPrice).toStringAsFixed(2)}";

                totalAmount = totalAmount + double.parse(showprice);
              }
              debugPrint("CartTotal amount ${totalAmount}");
            }

            if (state is CardUpdateQuanitiyState) {
              debugPrint(" CARD UPDATE ${state.listProduct.length}");
              image = state.listProduct.first.image!;
              debugPrint(" CARD UPDATE ${image}");
              cartitesmList = state.listProduct;
              totalAmount = 0;
              for (var dummyData in cartitesmList) {
                debugPrint(
                    "GGGNull Exception${dummyData.name} ${dummyData.sortPrice == "null"}");
                var sortPrice = (double.parse(dummyData.sortPrice == null ||
                                dummyData.sortPrice == "null" ||
                                dummyData.sortPrice == ""
                            ? "0.0"
                            : dummyData.sortPrice!) *
                        dummyData.addQuantity)
                    .toString();
                var specialPrice = (double.parse(
                            dummyData.specialPrice == null ||
                                    dummyData.specialPrice == "null" ||
                                    dummyData.specialPrice == ""
                                ? "0.0"
                                : dummyData.specialPrice!) *
                        dummyData.addQuantity)
                    .toString();
                var price = (double.parse(dummyData.price == null ||
                                dummyData.price == "null" ||
                                dummyData.price == ""
                            ? "0.0"
                            : dummyData.price!) *
                        dummyData.addQuantity)
                    .toString();

                debugPrint("specialPrice 2 ${specialPrice}");
                debugPrint("sortPrice 2 ${sortPrice}");
                debugPrint("price 2 ${price}");

                var crossprice = dummyData.specialPrice == ""
                    ? ""
                    : "₹ ${double.parse(price).toStringAsFixed(2)}";
                var showprice = dummyData.specialPrice == ""
                    ? " ${double.parse(sortPrice ?? "0.0").toStringAsFixed(2)}"
                    : "${double.parse(specialPrice).toStringAsFixed(2)}";

                totalAmount = totalAmount + double.parse(showprice);
              }
            }
            // if (cartitesmList.length==0) {
            //
            //   return Container(
            //     height: 0,
            //   );
            // }
            if (state is CardEmptyState) {
              animatedSize = 0;
              cartitesmList.clear();
              isopen(false);
              animationBloc.add(AnimationCartEvent(size: 0));

              //animationBloc.add(AnimatedNullEvent());

              // animationBloc.add(AnimationCartEvent(size: 0.0));
              //  return Container(
              //    height: 0,
              //  );
            }
            if (state is CardDeleteSatate) {
              debugPrint("CardDeleteSatate >>>>>  ${state.listProduct.length}");
              cartitesmList = state.listProduct;

              animationBloc.add(AnimatedNullEvent());
              switch (cartitesmList.length) {
                case 0:
                  isopen(false);
                  animationBloc.add(AnimationCartEvent(size: 0));

                case 1:
                  animationBloc.add(AnimationCartEvent(
                      size: (cartitesmList.length * 150) + 240));
                // animationBloc.add(AnimationCartEvent(
                //     size: (cartitesmList.length * 150) + 120));
                case 2:
                  animationBloc.add(AnimationCartEvent(
                      size: (cartitesmList.length * 130) + 120));
                case 3:
                  animationBloc.add(AnimationCartEvent(
                      size: (cartitesmList.length * 120) + 120));
                case 4:
                  animationBloc.add(AnimationCartEvent(
                      size: (cartitesmList.length * 120) + 120));
                default:
                  animationBloc.add(AnimationCartEvent(size: (4 * 120) + 120));
              }
            }

            return BlocProvider(
              create: (context) => animationBloc,
              child: BlocBuilder(
                  bloc: animationBloc,
                  builder: (context, state2) {
                    debugPrint(
                        "Animation Cart State  1 ${state2} $animatedSize");

                    if (state2 is AnimationCartState) {
                      animatedSize = state2.size;
                      if (animatedSize == 70) {
                        isup = true;
                      }
                      debugPrint(
                          "Animation Cart State ${state2} $animatedSize");

                      if (cartitesmList.length >= 5) {
                        height = 100.0 * 4;
                      } else if (cartitesmList.length == 1) {
                        height = 200.0 * cartitesmList.length;
                      } else {
                        height = 100.0 * cartitesmList.length;
                      }
/*
                      if (cartitesmList.length == 1) {
                        height = cartitesmList.length *
                            (MediaQuery.of(context)
                                .copyWith()
                                .size
                                .height *
                                0.30);
                      }
                      else if (cartitesmList.length > 2) {
                        height = (MediaQuery.of(context)
                            .copyWith()
                            .size
                            .height *
                            0.53);
                      } else {
                        height = (MediaQuery.of(context)
                            .copyWith()
                            .size
                            .height *
                            0.54);
                      }*/
                      //animationBloc.add(AnimatedNullEvent());
                      //animationBloc.add(AnimatedNullEvent());
                    }

                    return Container(
                      child: AnimatedContainer(
                        height: double.parse(animatedSize.toString()),
                        decoration: BoxDecoration(
                          // color: Colors.white,

                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        duration: const Duration(seconds: 1),
                        // Provide an optional curve to make the animation feel smoother.
                        curve: Curves.fastOutSlowIn,
                        child: VisibilityDetector(
                          key: const Key('ondoor.widget'),
                          onVisibilityChanged: (visibilityInfo) async {
                            var visiblePercentage =
                                visibilityInfo.visibleFraction * 100;
                            debugPrint(
                                'Widgetnew ${visibilityInfo.key} is $visiblePercentage% visible');
                            dbhelper.loadAddCardProducts(cardBloc);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 0),
                            child: Container(
                              height: Sizeconfig.getHeight(context),
                              child: StatefulBuilder(
                                  builder: ((context, setState) {
                                return Container(
                                  height: double.parse(animatedSize.toString()),
                                  child: Stack(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(top: 50),
                                        height: double.parse(
                                            animatedSize.toString()),
                                        color: Colors.white,
                                      ),
                                      Container(
                                        // height: animatedSize,

                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width:
                                                  Sizeconfig.getWidth(context),
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: InkWell(
                                                      onTap: () {
                                                        isopen(false);
                                                        //animationBloc.add(AnimatedNullEvent());
                                                        //animationBloc.add(AnimatedNullEvent());

                                                        animationBloc.add(
                                                            AnimationCartEvent(
                                                                size: 70.00));
                                                        //   Navigator.pop(context);
                                                        debugPrint(
                                                            "Action GG 2");
                                                        isup = true;
                                                      },
                                                      child: Image.asset(
                                                        Imageconstants
                                                            .img_roud_cross,
                                                        height: 36,
                                                        width: 36,
                                                      )),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,

                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10),
                                                ),
                                                // boxShadow: [
                                                //   BoxShadow(
                                                //     color: Colors.black.withOpacity(0.2),
                                                //     spreadRadius: 1,
                                                //     blurRadius: 5,
                                                //     offset: Offset(0, -2), // Changes position of shadow
                                                //   ),
                                                // ],
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          10.toSpace,
                                                          Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical: 0,
                                                                    horizontal:
                                                                        10),
                                                            child: Text(
                                                              // "Your cart (${cartitesmList.length} ${cartitesmList.length > 1 ? 'items' : 'item'})",
                                                              "Cart Items",
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontFamily:
                                                                      Fontconstants
                                                                          .fc_family_sf,
                                                                  fontWeight:
                                                                      Fontconstants
                                                                          .SF_Pro_Display_Bold,
                                                                  color: ColorName
                                                                      .ColorPrimary),
                                                            ),
                                                          ),
                                                          Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical: 0,
                                                                    horizontal:
                                                                        10),
                                                            child: Text(
                                                              // "Your cart (${cartitesmList.length} ${cartitesmList.length > 1 ? 'items' : 'item'})",
                                                              "Ready for your next step?",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontFamily:
                                                                      Fontconstants
                                                                          .fc_family_sf,
                                                                  fontWeight:
                                                                      Fontconstants
                                                                          .SF_Pro_Display_Medium,
                                                                  color: ColorName
                                                                      .textsecondary),
                                                            ),
                                                          ),
                                                          10.toSpace,
                                                        ],
                                                      ),
                                                      InkWell(
                                                        onTap: () async {
                                                          MyDialogs.showAlertDialog(
                                                              context,
                                                              "Clear Cart\nAre you sure you want to clear your cart items ?",
                                                              "Yes",
                                                              "No", () async {
                                                            await dbhelper
                                                                .cleanCartDatabase()
                                                                .then((value) {
                                                              isopen(false);
                                                              callback();
                                                              cardBloc.add(
                                                                  CardEmptyEvent());
                                                              reloadpage();
                                                              Navigator.pop(
                                                                  navigationService
                                                                      .navigatorKey
                                                                      .currentContext!);
                                                            });
                                                          }, () {
                                                            Navigator.pop(
                                                                navigationService
                                                                    .navigatorKey
                                                                    .currentContext!);
                                                          });
                                                        },
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 10,
                                                                  horizontal:
                                                                      20),
                                                          child: Text(
                                                            // "Your cart (${cartitesmList.length} ${cartitesmList.length > 1 ? 'items' : 'item'})",
                                                            "Clear",
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                fontFamily:
                                                                    Fontconstants
                                                                        .fc_family_sf,
                                                                fontWeight:
                                                                    Fontconstants
                                                                        .SF_Pro_Display_Bold,
                                                                color: ColorName
                                                                    .ColorPrimary),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  cartitesmList.length == 0
                                                      ? Container()
                                                      : Container(
                                                          child: Container(
                                                            height: height + 17,
                                                            padding:
                                                                EdgeInsets.only(
                                                                    bottom: 10),
                                                            //  height:200,
                                                            child: ListView
                                                                .separated(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(0),
                                                              shrinkWrap: true,
                                                              itemCount:
                                                                  cartitesmList
                                                                      .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                var dummyData =
                                                                    cartitesmList[
                                                                        index];

                                                                if (state
                                                                    is CardUpdateQuanitiyState) {
                                                                  debugPrint(
                                                                      "CardUpdateQuantity");
                                                                  cartitesmList[state
                                                                              .index]
                                                                          .addQuantity =
                                                                      state
                                                                          .quantity;
                                                                }
                                                                // ShowBottomView33List
                                                                return categoryItemView(
                                                                    true,
                                                                    fromchekcout,
                                                                    context,
                                                                    cartitesmList,
                                                                    dummyData,
                                                                    null,
                                                                    0, () {
                                                                  dummyData
                                                                          .addQuantity =
                                                                      dummyData
                                                                              .addQuantity +
                                                                          1;

                                                                  debugPrint(
                                                                      "${dummyData.addQuantity}");

                                                                  updateCard(
                                                                          dummyData,
                                                                          index,
                                                                          cartitesmList)
                                                                      .then(
                                                                          (value) {
                                                                    blocShopby.add(
                                                                        ShopByNullEvent());
                                                                    blocShopby.add(
                                                                        ShopbyProductChangeEvent(
                                                                            model:
                                                                                dummyData));
                                                                    blocFeatured
                                                                        .add(
                                                                            ProductNullEvent());
                                                                    blocFeatured.add(
                                                                        ProductUpdateQuantityEventBYModel(
                                                                            model:
                                                                                dummyData));
                                                                    blocFeatured.add(
                                                                        ProductChangeEvent(
                                                                            model:
                                                                                dummyData));
                                                                    debugPrint(
                                                                        "Increase cart ");
                                                                  });
                                                                }, () async {
                                                                  if (dummyData
                                                                          .addQuantity ==
                                                                      1) {
                                                                    dummyData
                                                                        .addQuantity = 0;
                                                                    blocFeatured.add(
                                                                        ProductUpdateQuantityEventBYModel(
                                                                            model:
                                                                                dummyData));
                                                                    blocShopby.add(
                                                                        ShopByNullEvent());
                                                                    blocShopby.add(
                                                                        ShopbyProductChangeEvent(
                                                                            model:
                                                                                dummyData));
                                                                    await dbhelper
                                                                        .deleteCard(int.parse(dummyData
                                                                            .productId!))
                                                                        .then(
                                                                            (value) {
                                                                      debugPrint(
                                                                          "Delete Product GG$value ");
                                                                      cardBloc.add(CardDeleteEvent(
                                                                          model: cartitesmList[
                                                                              index],
                                                                          listProduct:
                                                                              cartitesmList));
                                                                      // dbhelper.loadAddCardProducts(
                                                                      //     cardBloc);

                                                                      cartitesmList
                                                                          .removeAt(
                                                                              index);

                                                                      if (cartitesmList
                                                                              .length ==
                                                                          0) {
                                                                        isopen(
                                                                            false);
                                                                        callback();
                                                                        cardBloc
                                                                            .add(CardEmptyEvent());
                                                                        // Navigator.pop(
                                                                        //     context);
                                                                      }
                                                                    });
                                                                  } else if (dummyData
                                                                          .addQuantity !=
                                                                      0) {
                                                                    dummyData
                                                                            .addQuantity =
                                                                        dummyData.addQuantity -
                                                                            1;

                                                                    updateCard(
                                                                            dummyData,
                                                                            index,
                                                                            cartitesmList)
                                                                        .then(
                                                                            (value) {
                                                                      blocFeatured.add(ProductUpdateQuantityEventBYModel(
                                                                          model:
                                                                              dummyData));
                                                                      blocShopby
                                                                          .add(
                                                                              ShopByNullEvent());
                                                                      blocFeatured
                                                                          .add(
                                                                              ProductNullEvent());
                                                                      blocFeatured.add(ProductChangeEvent(
                                                                          model:
                                                                              dummyData));
                                                                      blocShopby
                                                                          .add(
                                                                              ShopByNullEvent());
                                                                      blocShopby.add(ShopbyProductChangeEvent(
                                                                          model:
                                                                              dummyData));
                                                                    });
                                                                  }
                                                                }, () async {
                                                                  dummyData
                                                                      .addQuantity = 0;
                                                                  blocFeatured.add(
                                                                      ProductUpdateQuantityEventBYModel(
                                                                          model:
                                                                              dummyData));
                                                                  blocShopby.add(
                                                                      ShopByNullEvent());
                                                                  blocShopby.add(
                                                                      ShopbyProductChangeEvent(
                                                                          model:
                                                                              dummyData));
                                                                  await dbhelper
                                                                      .deleteCard(int.parse(
                                                                          dummyData
                                                                              .productId!))
                                                                      .then(
                                                                          (value) {
                                                                    debugPrint(
                                                                        "Delete Product $value ");
                                                                    cardBloc.add(CardDeleteEvent(
                                                                        model: cartitesmList[
                                                                            index],
                                                                        listProduct:
                                                                            cartitesmList));
                                                                    dbhelper.loadAddCardProducts(
                                                                        cardBloc);

                                                                    cartitesmList
                                                                        .removeAt(
                                                                            index);

                                                                    if (cartitesmList
                                                                            .length ==
                                                                        0) {
                                                                      cardBloc.add(
                                                                          CardEmptyEvent());
                                                                      // Navigator.pop(
                                                                      //     context);
                                                                    }
                                                                  });
                                                                }, () async {
                                                                  {
                                                                    dummyData
                                                                        .addQuantity = 0;
                                                                    blocFeatured.add(
                                                                        ProductUpdateQuantityEventBYModel(
                                                                            model:
                                                                                dummyData));
                                                                    blocShopby.add(
                                                                        ShopByNullEvent());
                                                                    blocShopby.add(
                                                                        ShopbyProductChangeEvent(
                                                                            model:
                                                                                dummyData));
                                                                    await dbhelper
                                                                        .deleteCard(int.parse(dummyData
                                                                            .productId!))
                                                                        .then(
                                                                            (value) {
                                                                      debugPrint(
                                                                          "Delete Product GG$value ");
                                                                      cardBloc.add(CardDeleteEvent(
                                                                          model: cartitesmList[
                                                                              index],
                                                                          listProduct:
                                                                              cartitesmList));
                                                                      // dbhelper.loadAddCardProducts(
                                                                      //     cardBloc);

                                                                      cartitesmList
                                                                          .removeAt(
                                                                              index);

                                                                      if (cartitesmList
                                                                              .length ==
                                                                          0) {
                                                                        isopen(
                                                                            false);
                                                                        //  callback();
                                                                        // cardBloc
                                                                        //     .add(CardEmptyEvent());
                                                                        // Navigator.pop(
                                                                        //     context);
                                                                      }
                                                                    });
                                                                  }

                                                                  // dbhelper.loadAddCardProducts(
                                                                  //     cardBloc);
                                                                  // isopen(isup);
                                                                  // //animationBloc.add(AnimatedNullEvent());
                                                                  // //animationBloc.add(AnimatedNullEvent());
                                                                  //
                                                                  //
                                                                  //
                                                                  // animationBloc.add(
                                                                  //     AnimationCartEvent(
                                                                  //         size:
                                                                  //             70.00));
                                                                  // //   Navigator.pop(context);
                                                                  // debugPrint(
                                                                  //     "Action GG 2");
                                                                  // isup = true;
                                                                },
                                                                    true,
                                                                    false,
                                                                    () {},
                                                                    false,
                                                                    blocFeatured);
                                                              },
                                                              separatorBuilder:
                                                                  (BuildContext
                                                                          context,
                                                                      int index) {
                                                                return index ==
                                                                        cartitesmList.length -
                                                                            1
                                                                    ? Container(
                                                                        height:
                                                                            75,
                                                                      )
                                                                    : Padding(
                                                                        padding:
                                                                            EdgeInsets.symmetric(horizontal: 0.0),
                                                                        child: Container(
                                                                            color:
                                                                                ColorName.aquaHazeColor,
                                                                            height: 2.0),
                                                                      );
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        child: Container(
                                          width: Sizeconfig.getWidth(context),
                                          decoration: BoxDecoration(
                                            // color: Colors.white,

                                            color: ColorName.ColorPrimary,

                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                spreadRadius: 1,
                                                blurRadius: 5,
                                                offset: Offset(0,
                                                    -2), // Changes position of shadow
                                              ),
                                            ],
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Column(
                                            children: [
                                              Container(
                                                height: 1,
                                                width: Sizeconfig.getWidth(
                                                    context),
                                                color: ColorName.textlight
                                                    .withOpacity(0.1),
                                              ),
                                              Container(
                                                height: 69,
                                                child: InkWell(
                                                  onTap: () {
                                                    isopen(isup);
                                                    if (isup) {
                                                      //animationBloc.add(AnimatedNullEvent());
                                                      //animationBloc.add(AnimatedNullEvent());

                                                      switch (cartitesmList
                                                          .length) {
                                                        case 1:
                                                          animationBloc.add(
                                                              AnimationCartEvent(
                                                                  size: (cartitesmList
                                                                              .length *
                                                                          150) +
                                                                      240));
                                                        case 2:
                                                          animationBloc.add(
                                                              AnimationCartEvent(
                                                                  size: (cartitesmList
                                                                              .length *
                                                                          130) +
                                                                      120));
                                                        case 3:
                                                          animationBloc.add(
                                                              AnimationCartEvent(
                                                                  size: (cartitesmList
                                                                              .length *
                                                                          120) +
                                                                      120));
                                                        case 4:
                                                          animationBloc.add(
                                                              AnimationCartEvent(
                                                                  size: (cartitesmList
                                                                              .length *
                                                                          120) +
                                                                      100));
                                                        default:
                                                          animationBloc.add(
                                                              AnimationCartEvent(
                                                                  size: (4 *
                                                                          120) +
                                                                      100));
                                                      }

                                                      debugPrint("Action GG 1");
                                                      isup = false;

                                                      // Appwidgets.ShowDialogBottom(
                                                      //     context,
                                                      //     cardBloc,
                                                      //     cartitesmList,
                                                      //     blocFeatured,
                                                      //     blocShopby, () {
                                                      //   dbhelper.loadAddCardProducts(
                                                      //       cardBloc);
                                                      //   callback();
                                                      // }, validate);
                                                    } else {
                                                      //animationBloc.add(AnimatedNullEvent());
                                                      //animationBloc.add(AnimatedNullEvent());

                                                      animationBloc.add(
                                                          AnimationCartEvent(
                                                              size: 70.00));
                                                      //   Navigator.pop(context);
                                                      debugPrint("Action GG 2");
                                                      isup = true;
                                                    }
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Container(
                                                            child: Container(
                                                              height: Sizeconfig
                                                                      .getWidth(
                                                                          context) *
                                                                  0.13,
                                                              width: Sizeconfig
                                                                      .getWidth(
                                                                          context) *
                                                                  0.13,

                                                              child: Stack(
                                                                children: [
                                                                  Positioned(
                                                                    bottom: 0,
                                                                    left: 0,
                                                                    child:
                                                                        Container(
                                                                      child: Image
                                                                          .asset(
                                                                        height: Sizeconfig.getWidth(context) *
                                                                            0.10,
                                                                        width: Sizeconfig.getWidth(context) *
                                                                            0.11,
                                                                        fit: BoxFit
                                                                            .fill,
                                                                        Imageconstants
                                                                            .img_cartnewicon,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Positioned(
                                                                    right: 0,
                                                                    child:
                                                                        Container(
                                                                      margin: EdgeInsets.only(
                                                                          left:
                                                                              12),
                                                                      height:
                                                                          18,
                                                                      width: 18,
                                                                      decoration: BoxDecoration(
                                                                          color: Colors
                                                                              .white,
                                                                          borderRadius:
                                                                              BorderRadius.circular(10.0)),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          "${cartitesmList.length}",
                                                                          style: TextStyle(
                                                                              fontSize: 10,
                                                                              fontFamily: Fontconstants.fc_family_sf,
                                                                              fontWeight: Fontconstants.SF_Pro_Display_Bold,
                                                                              color: ColorName.ColorPrimary),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                              // child: Icon(
                                                              //   Icons
                                                              //       .shopping_cart_outlined,
                                                              //   color: Colors.black,
                                                              //   size:
                                                              //   Sizeconfig.getWidth(
                                                              //       context) *
                                                              //       0.10,
                                                              // )

                                                              //     CommonCachedImageWidget(
                                                              //   imgUrl: image,
                                                              // ),
                                                              // color: Colors.red,
                                                            ),
                                                          ),
                                                          Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: 15),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                        StringContants
                                                                            .lbl_viewcart,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                Constants.Sizelagre,
                                                                            fontFamily: Fontconstants.fc_family_popins,
                                                                            fontWeight: Fontconstants.SF_Pro_Display_Bold,
                                                                            color: Colors.white)),
                                                                    Container(
                                                                        margin: EdgeInsets.only(
                                                                            left:
                                                                                10),
                                                                        child: isup
                                                                            ? new Container(
                                                                                // gray box
                                                                                child: new Center(
                                                                                  child: RotationTransition(
                                                                                    child: Image.asset(isup ? Imageconstants.img_dropdownarrow : Imageconstants.img_dropdownarrow, height: 16, width: 16, fit: BoxFit.fill, color: Colors.white),
                                                                                    alignment: FractionalOffset.center,
                                                                                    turns: new AlwaysStoppedAnimation(180 / 360),
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            : Image.asset(Imageconstants.img_dropdownarrow, height: 16, width: 16, fit: BoxFit.fill, color: Colors.white))
                                                                  ],
                                                                ),
                                                                Text(
                                                                  "Total : ${Constants.ruppessymbol}" +
                                                                      totalAmount
                                                                          .toString() +
                                                                      " ",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          Constants
                                                                              .SizeSmall,
                                                                      fontFamily:
                                                                          Fontconstants
                                                                              .fc_family_popins,
                                                                      fontWeight:
                                                                          Fontconstants
                                                                              .SF_Pro_Display_Bold,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                        ],
                                                      ),
                                                      Container(
                                                        child: Appwidgets
                                                            .ButtonSecondarywhite(
                                                                /* validate
                                                                  ? StringContants
                                                                  .lbl_checkout
                                                                  : StringContants.lbl_next*/
                                                                StringContants
                                                                    .lbl_checkout,
                                                                () async {
                                                          functiontoCloseAnimation();
                                                          debugPrint(
                                                              "Product validation count ${validate}");

                                                          if (isup == false) {
                                                            // Navigator.pop(context);
                                                          }

                                                          if (validate) {
                                                            if (await Network
                                                                .isConnected()) {
                                                              Productvalidationswidgets
                                                                  .loadProductValication(
                                                                      dbhelper,
                                                                      context,
                                                                      cartitesmList,
                                                                      () {
                                                                debugPrint(
                                                                    "isup%%%**  ${isup}");
                                                                callback();
                                                                dbhelper
                                                                    .loadAddCardProducts(
                                                                        cardBloc);
                                                              });
                                                            } else {
                                                              MyDialogs
                                                                  .showInternetDialog(
                                                                      context,
                                                                      () {
                                                                Navigator.pop(
                                                                    context);
                                                              });
                                                            }
                                                          } else {
                                                            String id = "";
                                                            for (var x
                                                                in cartitesmList) {
                                                              id = id +
                                                                  x.productId! +
                                                                  ",";
                                                            }

                                                            if (id.endsWith(
                                                                ',')) {
                                                              id = id.substring(
                                                                  0,
                                                                  id.length -
                                                                      1);
                                                            }

                                                            debugPrint(
                                                                "ProductsIds ${id}");
                                                            ApiProvider()
                                                                .beforeYourCheckout(
                                                                    id,
                                                                    1,
                                                                    context)
                                                                .then(
                                                                    (value) async {
                                                              if (value != "") {
                                                                log("ROHIT Log 32  ${value}");
                                                                Navigator
                                                                    .pushNamed(
                                                                  context,
                                                                  Routes
                                                                      .ordersummary_screen,
                                                                  arguments: {
                                                                    "ProductsIds":
                                                                        id,
                                                                    "response":
                                                                        value,
                                                                  },
                                                                ).then((value) {
                                                                  callback();
                                                                });
                                                              } else {
                                                                print(
                                                                    "ROHIT Log 3");
                                                              }
                                                            });
                                                          }
                                                        }),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              })),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            );
          }),
    );
  }

/*
  static ShowBottomView22(
      BuildContext context,
      CardBloc cardBloc,
      FeaturedBloc blocFeatured,
      ShopByCategoryBloc blocShopby,
      AnimationBloc animationBloc,
      var animatedSize,
      int count,
      String image,
      bool isup,
      DatabaseHelper dbhelper,
      Function callback,
      bool validate,

      ) {
    List<ProductUnit> cartitesmList = [];

    List<ProductUnit> list_cOffers = [];
    List<ProductUnit> freeProducts = [];
    bool loadProductValidation = true;

    double totalAmount = 0;

    return BlocProvider(
      create: (context) => cardBloc,
      child: BlocBuilder(
          bloc: cardBloc,
          builder: (context, state) {
            debugPrint("ShowBottomView ***   $state $animatedSize");

            if (state is AddCardState) {
              count = state.count;
            }
            if (state is AddCardProductState) {
              cartitesmList = state.listProduct;
              count = state.listProduct.length;
              image = state.listProduct.first.image!;
              debugPrint(
                  "Cart Items list ***" + cartitesmList.length.toString());
              debugPrint("Cart Items list ***" + image);

              // if(animatedSize!=70.0)
              // {
              //animationBloc.add(AnimatedNullEvent());
              //animationBloc.add(AnimatedNullEvent());
              animationBloc.add(AnimationCartEvent(size: 70.0));

              // }

              // //setAnimation(animationBloc,70.0);
              // Future.delayed(Duration(seconds: 1),(){
              //
              //
              //   print("ajhhasdhadla");
              //
              //
              // });

              totalAmount = 0;

              for (var dummyData in cartitesmList) {
                debugPrint(
                    "GGGNull Exception${dummyData.name} ${dummyData.sortPrice == "null"}");
                var sortPrice = (double.parse(dummyData.sortPrice == null ||
                    dummyData.sortPrice == "null" ||
                    dummyData.sortPrice == ""
                    ? "0.0"
                    : dummyData.sortPrice!) *
                    dummyData.addQuantity)
                    .toString();
                var specialPrice = (double.parse(
                    dummyData.specialPrice == null ||
                        dummyData.specialPrice == "null" ||
                        dummyData.specialPrice == ""
                        ? "0.0"
                        : dummyData.specialPrice!) *
                    dummyData.addQuantity)
                    .toString();
                var price = (double.parse(dummyData.price == null ||
                    dummyData.price == "null" ||
                    dummyData.price == ""
                    ? "0.0"
                    : dummyData.price!) *
                    dummyData.addQuantity)
                    .toString();

                debugPrint("specialPrice 2 ${specialPrice}");
                debugPrint("sortPrice 2 ${sortPrice}");
                debugPrint("price 2 ${price}");

                var crossprice = dummyData.specialPrice == ""
                    ? ""
                    : "₹ ${double.parse(price).toStringAsFixed(2)}";
                var showprice = dummyData.specialPrice == ""
                    ? " ${double.parse(sortPrice ?? "0.0").toStringAsFixed(2)}"
                    : "${double.parse(specialPrice).toStringAsFixed(2)}";

                totalAmount = totalAmount + double.parse(showprice);
              }
              debugPrint("CartTotal amount ${totalAmount}");
            }

            if (state is CardUpdateQuanitiyState) {
              debugPrint(" CARD UPDATE ${state.listProduct.length}");
              image = state.listProduct.first.image!;
              debugPrint(" CARD UPDATE ${image}");
              cartitesmList = state.listProduct;

              // count=state.listProduct.length;
              // image=state.listProduct.first.image!;
            }
            if (cartitesmList.isEmpty) {
              return Container(
                height: 0,
              );
            }
            if (state is CardEmptyState) {
              //animationBloc.add(AnimatedNullEvent());
              animationBloc.add(AnimationCartEvent(size: 0.0));
              return Container(
                height: 0,
              );
            }
            if (state is CardDeleteSatate) {
              debugPrint("CardDeleteSatate >>>>>  ${state.listProduct.length}");
              cartitesmList = state.listProduct;
            }

            return BlocProvider(
              create: (context) => animationBloc,
              child: BlocBuilder(
                  bloc: animationBloc,
                  builder: (context, state2) {
                    debugPrint(
                        "Animation Cart State  1 ${state2} $animatedSize");

                    if (state2 is AnimationCartState) {
                      animatedSize = state2.size;
                      debugPrint(
                          "Animation Cart State ${state2} $animatedSize");
                    }

                    return AnimatedContainer(
                      height: animatedSize,
                      duration: const Duration(seconds: 2),
                      // Provide an optional curve to make the animation feel smoother.
                      curve: Curves.fastOutSlowIn,
                      child: VisibilityDetector(
                        key: const Key('ondoor.widget'),
                        onVisibilityChanged: (visibilityInfo) async {
                          var visiblePercentage =
                              visibilityInfo.visibleFraction * 100;
                          debugPrint(
                              'Widgetnew ${visibilityInfo.key} is $visiblePercentage% visible');
                          dbhelper.loadAddCardProducts(cardBloc);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 0),
                          child: StatefulBuilder(builder: ((context, setState) {
                            return SingleChildScrollView(
                              child: Container(
                                color: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                height: animatedSize,
                                child: Column(
                                  children: [
                                    Container(
                                      height: 1,
                                      width: Sizeconfig.getWidth(context),
                                      color:
                                      ColorName.textlight.withOpacity(0.1),
                                    ),
                                    Container(
                                      height: 69,
                                      child: InkWell(
                                        onTap: () {
                                          if (isup) {
                                            debugPrint("Action GG 1");
                                            Appwidgets.ShowDialogBottom(
                                                context,
                                                cardBloc,
                                                cartitesmList,
                                                blocFeatured,
                                                blocShopby, () {
                                              dbhelper.loadAddCardProducts(
                                                  cardBloc);
                                              callback();
                                            }, validate);
                                          } else {
                                            Navigator.pop(context);
                                            debugPrint("Action GG 2");
                                          }
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                Card(
                                                  elevation: 0.1,
                                                  color: Colors.white,
                                                  child: Container(
                                                      height:
                                                      Sizeconfig.getWidth(
                                                          context) *
                                                          0.15,
                                                      width:
                                                      Sizeconfig.getWidth(
                                                          context) *
                                                          0.15,
                                                      child: Icon(
                                                        Icons
                                                            .shopping_cart_outlined,
                                                        color: Colors.black,
                                                        size:
                                                        Sizeconfig.getWidth(
                                                            context) *
                                                            0.10,
                                                      )

                                                    //     CommonCachedImageWidget(
                                                    //   imgUrl: image,
                                                    // ),
                                                    // color: Colors.red,
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Appwidgets.TextLagre(
                                                            count.toString() +
                                                                " " +
                                                                StringContants
                                                                    .lbl_item,
                                                            Colors.black),
                                                        Icon(
                                                          isup
                                                              ? Icons
                                                              .arrow_drop_up_sharp
                                                              : Icons
                                                              .arrow_drop_down_sharp,
                                                          size: 25,
                                                          color: ColorName
                                                              .ColorPrimary,
                                                        )
                                                      ],
                                                    ),
                                                    Text(
                                                      "${Constants.ruppessymbol}" +
                                                          totalAmount
                                                              .toString() +
                                                          " ",
                                                      style: TextStyle(
                                                          fontSize: Constants
                                                              .SizeMidium,
                                                          fontFamily:
                                                          Fontconstants
                                                              .fc_family_sf,
                                                          fontWeight: Fontconstants
                                                              .SF_Pro_Display_Bold,
                                                          color: ColorName
                                                              .ColorPrimary),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                              ],
                                            ),
                                            Container(
                                              child: Appwidgets.ButtonSecondary(
                                                  validate
                                                      ? StringContants
                                                      .lbl_checkout
                                                      : StringContants.lbl_next,
                                                      () {
                                                    debugPrint(
                                                        "Product validation count ${validate}");

                                                    if (isup == false) {
                                                      // Navigator.pop(context);
                                                    }

                                                    if (validate) {
                                                      Productvalidationswidgets
                                                          .loadProductValication(
                                                          context,
                                                          cartitesmList, () {
                                                        debugPrint(
                                                            "isup%%%**  ${isup}");
                                                        callback();
                                                        dbhelper
                                                            .loadAddCardProducts(
                                                            cardBloc);
                                                      });
                                                    } else {
                                                      String id = "";
                                                      for (var x in cartitesmList) {
                                                        id =
                                                            id + x.productId! + ",";
                                                      }

                                                      if (id.endsWith(',')) {
                                                        id = id.substring(
                                                            0, id.length - 1);
                                                      }

                                                      debugPrint(
                                                          "ProductsIds ${id}");
                                                      ApiProvider()
                                                          .beforeYourCheckout(id, 1)
                                                          .then((value) async {
                                                        if (value != "") {
                                                          Navigator.pushNamed(
                                                            context,
                                                            Routes
                                                                .ordersummary_screen,
                                                            arguments: {
                                                              "ProductsIds": id,
                                                              "response": value,
                                                            },
                                                          ).then((value) {
                                                            callback();
                                                          });
                                                        }
                                                      });
                                                    }
                                                  }),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          })),
                        ),
                      ),
                    );
                  }),
            );
          }),
    );
  }*/

  static setAnimation(AnimationBloc animationBloc, var size) {
    Future.delayed(Duration(seconds: 1), () {
      animationBloc.add(AnimationCartEvent(size: size));
    });
  }

  static ShowDialogBottom(
      BuildContext context,
      CardBloc cardBloc,
      List<ProductUnit> listProduct,
      FeaturedBloc blocFeatured,
      ShopByCategoryBloc blocShopby,
      Function refresh,
      bool validate) async {
    HomePageBloc homePageBloc2 = HomePageBloc();
    bool isOpenBottomview = false;
    AnimationBloc animationBloc = AnimationBloc();
    var animationsizebottom = 0.0;
    DatabaseHelper dbhelper = DatabaseHelper();

    await dbhelper.init();

    dbhelper.loadAddCardProducts(cardBloc);

    updateCard(ProductUnit model, int index, var list) async {
      int status = await dbhelper.updateCard({
        DBConstants.PRODUCT_ID: int.parse(model.productId!),
        DBConstants.QUANTITY: model.addQuantity,
      });

      debugPrint("Update Product Status " + status.toString());

      cardBloc.add(CardUpdateQuantityEvent(
          quantity: model.addQuantity, index: index, listProduct: list));

      dbhelper.loadAddCardProducts(cardBloc);
    }

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
        builder: (context) {
          // using a scaffold helps to more easily position the FAB
          return BlocProvider(
            create: (context) => cardBloc,
            child: BlocBuilder(
                bloc: cardBloc,
                builder: (context, state) {
                  debugPrint("Bottom Dialog state $state");
                  if (state is CardDeleteSatate) {
                    debugPrint("CardDeleteSatate >>>>>  ");

                    listProduct.remove(state.model);
                  }

                  if (state is CardUpdateQuanitiyState) {
                    debugPrint(
                        "CCardUpdateQuanitiyStateGG  ${state.listProduct.length.toString()}");

                    listProduct = state.listProduct;
                  }

                  int size = listProduct.length;

                  double height = 0;

                  animationBloc.add(AnimationCartEvent(size: height));

                  return BlocProvider(
                    create: (context) => animationBloc,
                    child: BlocBuilder(
                        bloc: animationBloc,
                        builder: (context, state2) {
                          if (state2 is AnimationCartState) {
                            height = state2.size;
                            if (size == 1) {
                              height = listProduct.length *
                                  (MediaQuery.of(context)
                                          .copyWith()
                                          .size
                                          .height *
                                      0.30);
                            } else if (size > 2) {
                              height = (MediaQuery.of(context)
                                      .copyWith()
                                      .size
                                      .height *
                                  0.53);
                            } else {
                              height = (listProduct.length *
                                  (MediaQuery.of(context)
                                          .copyWith()
                                          .size
                                          .height *
                                      0.21));
                            }
                          }
                          return AnimatedContainer(
                            height: height,
                            duration: const Duration(seconds: 2),
                            // Provide an optional curve to make the animation feel smoother.
                            curve: Curves.fastOutSlowIn,
                            child: Container(
                              height: height,
                              child: Scaffold(
                                backgroundColor: Colors.transparent,

                                body: Container(
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(25),
                                    ),
                                    color: ColorName.aquaHazeColor,
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: Text(
                                            "Your cart (${listProduct.length} ${listProduct.length > 1 ? 'items' : 'item'})",
                                            style: TextStyle(
                                                fontSize: Constants.SizeMidium,
                                                fontFamily:
                                                    Fontconstants.fc_family_sf,
                                                fontWeight: Fontconstants
                                                    .SF_Pro_Display_SEMIBOLD,
                                                color: ColorName.ColorPrimary),
                                          ),
                                        ),
                                        height == 0
                                            ? Container()
                                            : Container(
                                                child: Expanded(
                                                  // height: height - 130,
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        listProduct.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      var dummyData =
                                                          listProduct[index];

                                                      if (state
                                                          is CardUpdateQuanitiyState) {
                                                        debugPrint(
                                                            "CardUpdateQuantity");
                                                        listProduct[state.index]
                                                                .addQuantity =
                                                            state.quantity;
                                                      }

                                                      return categoryItemView(
                                                          false,
                                                          false,
                                                          context,
                                                          listProduct,
                                                          dummyData,
                                                          null,
                                                          0, () {
                                                        dummyData.addQuantity =
                                                            dummyData
                                                                    .addQuantity +
                                                                1;

                                                        debugPrint(
                                                            "${dummyData.addQuantity}");

                                                        updateCard(dummyData,
                                                            index, listProduct);

                                                        blocShopby.add(
                                                            ShopByNullEvent());
                                                        blocShopby.add(
                                                            ShopbyProductChangeEvent(
                                                                model:
                                                                    dummyData));

                                                        blocFeatured.add(
                                                            ProductUpdateQuantityEventBYModel(
                                                                model:
                                                                    dummyData));

                                                        blocFeatured.add(
                                                            ProductChangeEvent(
                                                                model:
                                                                    dummyData));

                                                        debugPrint(
                                                            "Increase cart ");
                                                      }, () async {
                                                        if (dummyData
                                                                .addQuantity ==
                                                            1) {
                                                          dummyData
                                                              .addQuantity = 0;
                                                          blocFeatured.add(
                                                              ProductUpdateQuantityEventBYModel(
                                                                  model:
                                                                      dummyData));
                                                          blocShopby.add(
                                                              ShopByNullEvent());
                                                          blocShopby.add(
                                                              ShopbyProductChangeEvent(
                                                                  model:
                                                                      dummyData));
                                                          await dbhelper
                                                              .deleteCard(int
                                                                  .parse(dummyData
                                                                      .productId!))
                                                              .then((value) {
                                                            debugPrint(
                                                                "Delete Product $value ");
                                                            cardBloc.add(CardDeleteEvent(
                                                                model:
                                                                    listProduct[
                                                                        index],
                                                                listProduct:
                                                                    listProduct));
                                                            dbhelper
                                                                .loadAddCardProducts(
                                                                    cardBloc);

                                                            listProduct
                                                                .removeAt(
                                                                    index);

                                                            if (listProduct
                                                                    .length ==
                                                                0) {
                                                              cardBloc.add(
                                                                  CardEmptyEvent());
                                                              Navigator.pop(
                                                                  context);
                                                            }
                                                          });
                                                        } else if (dummyData
                                                                .addQuantity !=
                                                            0) {
                                                          dummyData
                                                                  .addQuantity =
                                                              dummyData
                                                                      .addQuantity -
                                                                  1;

                                                          updateCard(
                                                              dummyData,
                                                              index,
                                                              listProduct);
                                                          blocFeatured.add(
                                                              ProductUpdateQuantityEventBYModel(
                                                                  model:
                                                                      dummyData));
                                                          blocShopby.add(
                                                              ShopByNullEvent());
                                                          blocFeatured.add(
                                                              ProductChangeEvent(
                                                                  model:
                                                                      dummyData));
                                                          blocShopby.add(
                                                              ShopByNullEvent());
                                                          blocShopby.add(
                                                              ShopbyProductChangeEvent(
                                                                  model:
                                                                      dummyData));
                                                        }
                                                      }, () async {
                                                        dummyData.addQuantity =
                                                            0;
                                                        blocFeatured.add(
                                                            ProductUpdateQuantityEventBYModel(
                                                                model:
                                                                    dummyData));
                                                        blocShopby.add(
                                                            ShopByNullEvent());
                                                        blocShopby.add(
                                                            ShopbyProductChangeEvent(
                                                                model:
                                                                    dummyData));
                                                        await dbhelper
                                                            .deleteCard(int
                                                                .parse(dummyData
                                                                    .productId!))
                                                            .then((value) {
                                                          debugPrint(
                                                              "Delete Product $value ");
                                                          cardBloc.add(CardDeleteEvent(
                                                              model:
                                                                  listProduct[
                                                                      index],
                                                              listProduct:
                                                                  listProduct));
                                                          dbhelper
                                                              .loadAddCardProducts(
                                                                  cardBloc);

                                                          listProduct
                                                              .removeAt(index);

                                                          if (listProduct
                                                                  .length ==
                                                              0) {
                                                            cardBloc.add(
                                                                CardEmptyEvent());
                                                            Navigator.pop(
                                                                context);
                                                          }
                                                        });
                                                      }, () {
                                                        dbhelper
                                                            .loadAddCardProducts(
                                                                cardBloc);
                                                        refresh();
                                                      }, true, false, () {},
                                                          false, blocFeatured);
                                                    },
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                                // translate the FAB up by 30
                                floatingActionButton: Container(
                                  transform: Matrix4.translationValues(
                                      0.0, -60, 0.0), // translate up by 30
                                  child: InkWell(
                                      onTap: () {
                                        // do stuff
                                        debugPrint('doing stuff');
                                        animationBloc
                                            .add(AnimationCartEvent(size: 0));
                                      },
                                      child: Image.asset(
                                        Imageconstants.img_roud_cross,
                                        height: 40,
                                        width: 40,
                                      )),
                                ),
                                floatingActionButtonLocation:
                                    FloatingActionButtonLocation.centerTop,
                                // bottomNavigationBar:
                                //     Appwidgets.ShowBottomView33(
                                //         context,
                                //         cardBloc,
                                //         blocFeatured,
                                //         ShopByCategoryBloc(),
                                //         animationBloc,
                                //         animationsizebottom,
                                //         0,
                                //         "",
                                //         false,
                                //         dbhelper,
                                //         () async {
                                //           debugPrint(
                                //               "OrderSummary Screen back >>>>>");
                                //           Appwidgets
                                //               .setStatusBarDynamicLightColor(
                                //                   color: Colors.transparent);
                                //
                                //           // SystemChrome.setSystemUIOverlayStyle(
                                //           //     SystemUiOverlayStyle(
                                //           //   statusBarColor: Colors
                                //           //       .transparent, // transparent status bar
                                //           //   statusBarIconBrightness: Brightness
                                //           //       .light, // dark icons on the status bar
                                //           // ));
                                //         },
                                //         () {},
                                //         true,
                                //         (value) {
                                //           debugPrint(
                                //               "HomePage Screen back >>>>>");
                                //           isOpenBottomview = value;
                                //
                                //           homePageBloc2.add(HomeNullEvent());
                                //           homePageBloc2.add(
                                //               HomeBottomSheetEvent(
                                //                   status: value));
                                //         },
                                //         (height) {
                                //           debugPrint("GGheight >> $height");
                                //           animationsizebottom = 70.0;
                                //         }),

                                bottomNavigationBar: Appwidgets.ShowBottomView(
                                    context,
                                    cardBloc,
                                    blocFeatured,
                                    blocShopby,
                                    animationBloc,
                                    animationsizebottom,
                                    listProduct.length,
                                    listProduct.isEmpty
                                        ? ""
                                        : listProduct[0].image!,
                                    false,
                                    dbhelper, () {
                                  refresh();
                                  Navigator.pop(context);
                                }, validate),
                              ),
                            ),
                          );
                        }),
                  );
                }),
          );
        }).then((value) {
      debugPrint("Colse Bottom View $value");
    });
  }

  static showFreeProductDialog(
      String subtitle,
      BuildContext context,
      CardBloc cardBloc,
      List<ProductUnit> listProduct,
      FeaturedBloc blocFeatured,
      ShopByCategoryBloc blocShopby,
      Function closedialog,
      Function refresh,
      Function(List<ProductUnit>) navigate) async {
    DatabaseHelper dbhelper = DatabaseHelper();

    await dbhelper.init();

    dbhelper.loadAddCardProducts(cardBloc);

    updateCard(ProductUnit model, int index, var list) async {
      int status = await dbhelper.updateCard({
        DBConstants.PRODUCT_ID: int.parse(model.productId!),
        DBConstants.QUANTITY: model.addQuantity,
      });

      debugPrint("Update Product Status " + status.toString());

      cardBloc.add(CardUpdateQuantityEvent(
          quantity: model.addQuantity, index: index, listProduct: list));

      dbhelper.loadAddCardProducts(cardBloc);
    }

    showDialog(
        barrierColor: Colors.black.withOpacity(0.4),
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          // using a scaffold helps to more easily position the FAB
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            insetPadding: EdgeInsets.symmetric(
                horizontal: 15, vertical: Sizeconfig.getHeight(context) * 0.1),
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            child: BlocProvider(
              create: (context) => cardBloc,
              child: BlocBuilder(
                  bloc: cardBloc,
                  builder: (context, state) {
                    debugPrint("Bottom Dialog state $state");
                    if (state is CardDeleteSatate) {
                      debugPrint("CardDeleteSatate >>>>>  ");

                      listProduct.remove(state.model);
                    }

                    if (state is CardUpdateQuanitiyState) {
                      debugPrint(
                          "CCardUpdateQuanitiyStateGG  ${state.listProduct.length.toString()}");

                      listProduct = state.listProduct;
                    }

                    int size = listProduct.length;

                    return Container(
                      // height: size == 1
                      //     ? (listProduct.length *
                      //     (MediaQuery.of(context).copyWith().size.height *
                      //         0.28))
                      //     : size > 2
                      //     ? (MediaQuery.of(context).copyWith().size.height *
                      //     0.62)
                      //     : (listProduct.length *
                      //     (MediaQuery.of(context).copyWith().size.height *
                      //         0.22)),
                      height: (MediaQuery.of(context).size.height * 0.5) +
                          (Sizeconfig.getHeight(context) * 0.1) *
                              listProduct.length,
                      child: Scaffold(
                        backgroundColor: Colors.transparent,
                        body: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                            color: ColorName.aquaHazeColor,
                          ),
                          child: Container(
                            padding: EdgeInsets.only(top: 0),
                            child: Container(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                      width: Sizeconfig.getWidth(context),
                                      height:
                                          Sizeconfig.getHeight(context) * 0.2,
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
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
                                  Appwidgets.TextSemiBold(subtitle,
                                      ColorName.ColorPrimary, TextAlign.center),
                                  Container(
                                    height:
                                        (Sizeconfig.getHeight(context) * 0.16) *
                                            listProduct.length,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: listProduct.length,
                                      itemBuilder: (context, index) {
                                        var dummyData = listProduct[index];

                                        if (state is CardUpdateQuanitiyState) {
                                          debugPrint("CardUpdateQuantity");
                                          listProduct[state.index].addQuantity =
                                              state.quantity;
                                        }

                                        return categoryItemView(
                                            false,
                                            false,
                                            context,
                                            listProduct,
                                            dummyData,
                                            null,
                                            0, () {
                                          dummyData.addQuantity =
                                              dummyData.addQuantity + 1;

                                          debugPrint(
                                              "${dummyData.addQuantity}");

                                          updateCard(
                                              dummyData, index, listProduct);

                                          blocShopby.add(ShopByNullEvent());
                                          blocShopby.add(
                                              ShopbyProductChangeEvent(
                                                  model: dummyData));

                                          blocFeatured.add(
                                              ProductUpdateQuantityEventBYModel(
                                                  model: dummyData));

                                          blocFeatured.add(ProductChangeEvent(
                                              model: dummyData));

                                          debugPrint("Increase cart ");
                                        }, () async {
                                          if (dummyData.addQuantity == 1) {
                                            dummyData.addQuantity = 0;
                                            blocFeatured.add(
                                                ProductUpdateQuantityEventBYModel(
                                                    model: dummyData));
                                            blocShopby.add(ShopByNullEvent());
                                            blocShopby.add(
                                                ShopbyProductChangeEvent(
                                                    model: dummyData));
                                            await dbhelper
                                                .deleteCard(int.parse(
                                                    dummyData.productId!))
                                                .then((value) {
                                              debugPrint(
                                                  "Delete Product $value ");
                                              cardBloc.add(CardDeleteEvent(
                                                  model: listProduct[index],
                                                  listProduct: listProduct));
                                              dbhelper.loadAddCardProducts(
                                                  cardBloc);

                                              listProduct.removeAt(index);

                                              if (listProduct.length == 0) {
                                                cardBloc.add(CardEmptyEvent());
                                                Navigator.pop(context);
                                              }
                                            });
                                          } else if (dummyData.addQuantity !=
                                              0) {
                                            dummyData.addQuantity =
                                                dummyData.addQuantity - 1;

                                            updateCard(
                                                dummyData, index, listProduct);
                                            blocFeatured.add(
                                                ProductUpdateQuantityEventBYModel(
                                                    model: dummyData));
                                            blocShopby.add(ShopByNullEvent());
                                            blocFeatured.add(ProductChangeEvent(
                                                model: dummyData));
                                            blocShopby.add(ShopByNullEvent());
                                            blocShopby.add(
                                                ShopbyProductChangeEvent(
                                                    model: dummyData));
                                          }
                                        }, () async {
                                          dummyData.addQuantity = 0;
                                          blocFeatured.add(
                                              ProductUpdateQuantityEventBYModel(
                                                  model: dummyData));
                                          blocShopby.add(ShopByNullEvent());
                                          blocShopby.add(
                                              ShopbyProductChangeEvent(
                                                  model: dummyData));
                                          await dbhelper
                                              .deleteCard(int.parse(
                                                  dummyData.productId!))
                                              .then((value) {
                                            debugPrint(
                                                "Delete Product $value ");
                                            cardBloc.add(CardDeleteEvent(
                                                model: listProduct[index],
                                                listProduct: listProduct));
                                            dbhelper
                                                .loadAddCardProducts(cardBloc);

                                            listProduct.removeAt(index);

                                            if (listProduct.length == 0) {
                                              cardBloc.add(CardEmptyEvent());
                                              Navigator.pop(context);
                                            }
                                          });
                                        }, () {
                                          dbhelper
                                              .loadAddCardProducts(cardBloc);
                                          refresh();
                                        }, true, false, () {}, false,
                                            blocFeatured);
                                      },
                                    ),
                                  ),
                                  Container(
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
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    5.0)),
                                                    color:
                                                        ColorName.ColorPrimary),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15,
                                                        vertical: 8),
                                                child: Center(
                                                    child: Text(StringContants
                                                        .lbl_shopMore))),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: InkWell(
                                            onTap: () async {
                                              navigate(listProduct);
                                            },
                                            child: Container(
                                                margin: EdgeInsets.only(
                                                    left: Sizeconfig.getHeight(
                                                            context) *
                                                        0.001),
                                                decoration: const BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            bottomRight:
                                                                Radius.circular(
                                                                    5.0)),
                                                    color:
                                                        ColorName.ColorPrimary),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 15,
                                                    vertical: 8),
                                                child: Center(
                                                    child:
                                                        Text(StringContants.lbl_continue))),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          );
        }).then((value) {
      debugPrint("Colse Bottom View $value");
      closedialog();
    });
  }

  static showSubProductsOffer(
      int buy_quanitty,
      String applied,
      String subtitle,
      String warningtitle,
      BuildContext context,
      CardBloc cardBloc,
      List<ProductUnit> listProduct,
      FeaturedBloc blocFeatured,
      ShopByCategoryBloc blocShopby,
      Function refresh,
      Function(List<ProductUnit>) navigate) async {
    int totalAddedQuantity = 0;
    bool showWarningMessage = false;
    bool offerAppilied = false;
    DatabaseHelper dbhelper = DatabaseHelper();
    int remainingQuanityt = 0;

    await dbhelper.init();

    dbhelper.loadAddCardProducts(cardBloc);

    updateCard(ProductUnit model, int index, var list) async {
      int status = await dbhelper.updateCard({
        DBConstants.PRODUCT_ID: int.parse(model.productId!),
        DBConstants.QUANTITY: model.addQuantity,
      });

      debugPrint("Update Product Status " + status.toString());

      cardBloc.add(CardUpdateQuantityEvent(
          quantity: model.addQuantity, index: index, listProduct: list));

      dbhelper.loadAddCardProducts(cardBloc);
    }

    int size = listProduct.length;
    showModalBottomSheet(
        barrierColor: Colors.black.withOpacity(0.4),
        context: context,
        //  barrierDismissible: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(8),
          ),
        ),
        builder: (context) {
          // using a scaffold helps to more easily position the FAB
          return Container(
            // shape: RoundedRectangleBorder(
            //
            // height: size == 1
            //     ? (listProduct.length *
            //         (MediaQuery.of(context).copyWith().size.height * 0.28))
            //     : size > 2
            //         ? (MediaQuery.of(context).copyWith().size.height * 0.62)
            //         : (listProduct.length *
            //             (MediaQuery.of(context).copyWith().size.height * 0.22)),
            child: BlocProvider(
              create: (context) => cardBloc,
              child: BlocBuilder(
                  bloc: cardBloc,
                  builder: (context, state) {
                    debugPrint("Bottom Dialog state $state");

                    if (state is CardDeleteSatate) {
                      debugPrint("CardDeleteSatate >>>>>  ");

                      // listProduct.remove(state.model);
                    }

                    if (state is AddCardProductState) {
                      int totalAdded = 0;
                      for (var x in listProduct) {
                        totalAdded = totalAdded + x.addQuantity;
                      }

                      debugPrint("On Add Total Quanitiyt ${totalAdded}");

                      if (totalAdded == 0) {
                        showWarningMessage = false;
                        offerAppilied = false;
                      } else if (totalAdded < buy_quanitty) {
                        remainingQuanityt = buy_quanitty - totalAdded;
                        showWarningMessage = true;
                        offerAppilied = false;
                      } else {
                        showWarningMessage = false;
                        offerAppilied = true;
                      }
                    }

                    if (state is CardUpdateQuanitiyState) {
                      debugPrint(
                          "CCardUpdateQuanitiyStateGG  ${state.listProduct.length.toString()}");

                      listProduct = state.listProduct;

                      int totalAdded = 0;
                      for (var x in listProduct) {
                        totalAdded = totalAdded + x.addQuantity;
                      }

                      debugPrint("On Add Total Quanitiyt ${totalAdded}");

                      if (totalAdded == 0) {
                        showWarningMessage = false;
                        offerAppilied = false;
                      } else if (totalAdded < buy_quanitty) {
                        remainingQuanityt = buy_quanitty - totalAdded;
                        showWarningMessage = true;
                        offerAppilied = false;
                      } else {
                        showWarningMessage = false;
                        offerAppilied = true;
                      }
                    }

                    int size = listProduct.length;

                    var height = size == 1
                        ? (listProduct.length *
                            (MediaQuery.of(context).copyWith().size.height *
                                0.28))
                        : size > 2
                            ? (MediaQuery.of(context).copyWith().size.height *
                                0.62)
                            : (listProduct.length *
                                (MediaQuery.of(context).copyWith().size.height *
                                    0.22));
                    return Container(
                      // height: (MediaQuery.of(context).size.height*0.5)+(Sizeconfig.getHeight(context) * 0.1)* listProduct.length,
                      height: height +
                          ((showWarningMessage == true || offerAppilied == true)
                              ? 100
                              : 0),
                      child: Scaffold(
                        backgroundColor: Colors.transparent,
                        body: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                            color: ColorName.aquaHazeColor,
                          ),
                          child: Container(
                            padding: EdgeInsets.only(top: 0),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 60,
                                    width: Sizeconfig.getWidth(context),
                                    decoration: BoxDecoration(
                                        color: ColorName.darkBlue,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(8),
                                        )),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10.0),
                                    child: Center(
                                        child: Text(subtitle,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: Constants.SizeMidium,
                                                fontFamily:
                                                    Fontconstants.fc_family_sf,
                                                fontWeight: Fontconstants
                                                    .SF_Pro_Display_SEMIBOLD,
                                                color: Colors.white))),
                                  ),
                                  showWarningMessage == false
                                      ? Container()
                                      : Container(
                                          width: Sizeconfig.getWidth(context),
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          decoration: BoxDecoration(
                                              color: Colors.red.shade400,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0))),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 10),
                                          child: TextSemiBold(
                                              warningtitle.replaceAll("@#\$",
                                                  "${remainingQuanityt}"),
                                              ColorName.white_card,
                                              TextAlign.center)),
                                  Visibility(
                                    visible: offerAppilied,
                                    child: Container(
                                        width: Sizeconfig.getWidth(context),
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                        decoration: BoxDecoration(
                                            color: Colors.green.shade400,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0))),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              Imageconstants.img_offer,
                                              height: 25,
                                              width: 25,
                                              color: Colors.white,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Container(
                                              width:
                                                  Sizeconfig.getWidth(context) *
                                                      0.7,
                                              child: Appwidgets.TextSemiBold(
                                                  applied.replaceAll("@#\$",
                                                      buy_quanitty.toString()),
                                                  Colors.white,
                                                  TextAlign.center),
                                            ),
                                          ],
                                        )),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: listProduct.length,
                                      itemBuilder: (context, index) {
                                        var dummyData = listProduct[index];

                                        if (state is CardUpdateQuanitiyState) {
                                          listProduct[state.index].addQuantity =
                                              state.quantity;
                                        }

                                        debugPrint(
                                            "total added quantity $totalAddedQuantity");

                                        if (state is CardUpdateQuanitiyState) {
                                          debugPrint(
                                              "CCardUpdateQuanitiyStateGG  ${state.listProduct.length.toString()}");

                                          listProduct = state.listProduct;
                                        }

                                        return categoryItemView(
                                            false,
                                            false,
                                            context,
                                            listProduct,
                                            dummyData,
                                            null,
                                            0, () {
                                          if (dummyData.addQuantity == 0) {
                                            dbhelper.addCard(
                                                dummyData, cardBloc);
                                          }

                                          dummyData.addQuantity =
                                              dummyData.addQuantity + 1;

                                          debugPrint(
                                              "${dummyData.addQuantity}");

                                          updateCard(
                                              dummyData, index, listProduct);

                                          blocShopby.add(ShopByNullEvent());
                                          blocShopby.add(
                                              ShopbyProductChangeEvent(
                                                  model: dummyData));

                                          blocFeatured.add(
                                              ProductUpdateQuantityEventBYModel(
                                                  model: dummyData));

                                          blocFeatured.add(ProductChangeEvent(
                                              model: dummyData));

                                          debugPrint("Increase cart ");
                                        }, () async {
                                          if (dummyData.addQuantity == 1) {
                                            dummyData.addQuantity = 0;
                                            blocFeatured.add(
                                                ProductUpdateQuantityEventBYModel(
                                                    model: dummyData));
                                            blocShopby.add(ShopByNullEvent());
                                            blocShopby.add(
                                                ShopbyProductChangeEvent(
                                                    model: dummyData));
                                            await dbhelper
                                                .deleteCard(int.parse(
                                                    dummyData.productId!))
                                                .then((value) {
                                              debugPrint(
                                                  "Delete Product $value ");
                                              cardBloc.add(CardDeleteEvent(
                                                  model: listProduct[index],
                                                  listProduct: listProduct));
                                              dbhelper.loadAddCardProducts(
                                                  cardBloc);

                                              // listProduct.removeAt(index);

                                              if (listProduct.length == 0) {
                                                cardBloc.add(CardEmptyEvent());
                                                Navigator.pop(context);
                                              }
                                            });
                                          } else if (dummyData.addQuantity !=
                                              0) {
                                            dummyData.addQuantity =
                                                dummyData.addQuantity - 1;

                                            updateCard(
                                                dummyData, index, listProduct);
                                            blocFeatured.add(
                                                ProductUpdateQuantityEventBYModel(
                                                    model: dummyData));
                                            blocShopby.add(ShopByNullEvent());
                                            blocFeatured.add(ProductChangeEvent(
                                                model: dummyData));
                                            blocShopby.add(ShopByNullEvent());
                                            blocShopby.add(
                                                ShopbyProductChangeEvent(
                                                    model: dummyData));
                                          }

                                          debugPrint(
                                              "  ${listProduct.length.toString()}");

                                          listProduct = listProduct;

                                          cardBloc.add(CardUpdateQuantityEvent(
                                              quantity: dummyData.addQuantity,
                                              index: index,
                                              listProduct: listProduct));
                                        }, () async {
                                          dummyData.addQuantity = 0;
                                          blocFeatured.add(
                                              ProductUpdateQuantityEventBYModel(
                                                  model: dummyData));
                                          blocShopby.add(ShopByNullEvent());
                                          blocShopby.add(
                                              ShopbyProductChangeEvent(
                                                  model: dummyData));
                                          await dbhelper
                                              .deleteCard(int.parse(
                                                  dummyData.productId!))
                                              .then((value) {
                                            debugPrint(
                                                "Delete Product $value ");
                                            cardBloc.add(CardDeleteEvent(
                                                model: listProduct[index],
                                                listProduct: listProduct));
                                            dbhelper
                                                .loadAddCardProducts(cardBloc);

                                            listProduct.removeAt(index);

                                            if (listProduct.length == 0) {
                                              cardBloc.add(CardEmptyEvent());
                                              Navigator.pop(context);
                                            }
                                          });
                                        }, () {
                                          dbhelper
                                              .loadAddCardProducts(cardBloc);
                                          refresh();
                                        }, false, false, () {}, false,
                                            blocFeatured);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        floatingActionButton: Container(
                          transform: Matrix4.translationValues(
                              0.0, -60, 0.0), // translate up by 30
                          child: InkWell(
                              onTap: () {
                                // do stuff
                                debugPrint('doing stuff');
                              },
                              child: Image.asset(
                                Imageconstants.img_roud_cross,
                                height: 40,
                                width: 40,
                              )),
                        ),
                        floatingActionButtonLocation:
                            FloatingActionButtonLocation.centerTop,
                      ),
                    );
                  }),
            ),
          );
        }).then((value) {
      debugPrint("Colse Bottom View $value");
      refresh();
    });
  }

  updateCardreorder(
      ProductUnit model, DatabaseHelper dbhelper, CardBloc cardBloc) async {
    int status = await dbhelper.updateCard({
      DBConstants.PRODUCT_ID: int.parse(model.productId!),
      DBConstants.QUANTITY: model.addQuantity,
    });

    dbhelper.loadAddCardProducts(cardBloc);
  }

  updateCard(ProductUnit model, int index, var list, DatabaseHelper dbhelper,
      CardBloc cardBloc) async {
    int status = await dbhelper.updateCard({
      DBConstants.PRODUCT_ID: int.parse(model.productId!),
      DBConstants.QUANTITY: model.addQuantity,
    });

    debugPrint("Update Product Status " + status.toString());

    cardBloc.add(CardUpdateQuantityEvent(
        quantity: model.addQuantity, index: index, listProduct: list));

    dbhelper.loadAddCardProducts(cardBloc);
  }

  showReorderProductsListing(
      BuildContext context,
      CardBloc cardBloc,
      String orderId,
      List<ProductUnit> listProduct,
      FeaturedBloc blocFeatured,
      ShopByCategoryBloc blocShopby,
      Function refresh,
      String route,
      Function callback) async {
    int totalAddedQuantity = 0;
    bool showWarningMessage = false;
    bool offerAppilied = false;
    DatabaseHelper dbhelper = DatabaseHelper();
    int remainingQuanityt = 0;
    var animationsizebottom = 0.0;
    AnimationBloc animationBloc = AnimationBloc();

    await dbhelper.init();

    dbhelper.loadAddCardProducts(cardBloc);

    int size = listProduct.length;
    showModalBottomSheet(
        // isScrollControlled: true,
        backgroundColor: ColorName.whiteSmokeColor,
        barrierColor: Colors.black.withOpacity(0.4),
        context: context,
        //  barrierDismissible: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25),
          ),
        ),
        builder: (context) {
          // using a scaffold helps to more easily position the FAB
          return Container(
            child: BlocProvider(
              create: (context) => cardBloc,
              child: BlocBuilder(
                  bloc: cardBloc,
                  builder: (context, state) {
                    debugPrint("Bottom Dialog state rrrrr $state");
                    if (state is CardDeleteSatate) {
                      debugPrint("CardDeleteSatate >>>>>  ");

                      // listProduct.remove(state.model);
                    }

                    if (state is AddCardProductState) {
                      log("AddCardProductStateGGG ${json.encode(state.listProduct)}");
                      int totalAdded = 0;
                      //   listProduct = state.listProduct!;
                    }

                    if (state is CardUpdateQuanitiyState) {
                      debugPrint(
                          "CCardUpdateQuanitiyStateGG  ${state.listProduct.length.toString()}");

                      listProduct = state.listProduct;
                    }

                    if (state is AddCardOrderProductState) {
                     // listProduct = state.listProduct;
                      log("message list ${listProduct.length}");
                      log("message list ${json.encode(listProduct)}");
/*

                      for(int i=0;i<state.listProduct.length;i++)
                        {
                          for(int j=0;j<listProduct.length;j++)
                            {

                              if(state.listProduct[i].productId==listProduct[j].productId)
                                {
                                  log("message list>>>> ${listProduct[i].addQuantity} ${listProduct[i].quantity}");
                                  listProduct[j].quantity=state.listProduct[i].addQuantity.toString();
                                }
                              else
                                {
                                  listProduct.add(state.listProduct[i]);
                                }
                            }




                        }
*/


                      for (var stateProduct in state.listProduct) {
                        bool productExists = false;

                        for (int i = 0; i < listProduct.length; i++) {
                          if (stateProduct.productId == listProduct[i].productId) {
                            // Update the quantity if the product exists
                            listProduct[i].quantity = stateProduct.addQuantity.toString();

                            productExists = true;
                            break;
                          }
                        }

                        if (!productExists) {
                          // Add the product if it doesn't exist
                          stateProduct.quantity=stateProduct.addQuantity.toString();
                          listProduct.add(stateProduct);
                        }
                      }
                      log(json.encode(listProduct));
                    }
                    var height =
                        calculateBottomSheetHeight(listProduct.length, context);
                    return Container(
                      // height: (MediaQuery.of(context).size.height*0.5)+(Sizeconfig.getHeight(context) * 0.1)* listProduct.length,
                      height: height,
                      // +
                      // ((showWarningMessage == true || offerAppilied == true)
                      //     ? 100
                      //     : 0),
                      child: Scaffold(
                        backgroundColor: Colors.transparent,
                        body: Wrap(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              margin: EdgeInsets.symmetric(horizontal: 40.0),
                              child: Center(
                                  child: Appwidgets.TextLagre(
                                StringContants.lbl_reorder,
                                ColorName.ColorPrimary,
                              )),
                            ),
                            SizedBox(
                              height: listProduct.length >= 4
                                  ? height * .56
                                  : listProduct.length == 3
                                      ? height * .55
                                      : height,
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: listProduct.length,
                                physics: AlwaysScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  var dummyData = listProduct[index];
                                  listProduct[index].addQuantity = int.parse(
                                      listProduct[index].quantity ?? "0");
                                  log("total added quantity ${dummyData.toMap()}");
                                  log("total added quantityGGGGG ${dummyData.addQuantity!}");
                                  if (state is CardUpdateQuanitiyState) {
                                    if (route == Routes.order_history) {
                                      listProduct[state.index].addQuantity =
                                          state.quantity;
                                    } else {
                                      listProduct[state.index].addQuantity =
                                          state.quantity;
                                    }
                                  }



                                  if (state is CardUpdateQuanitiyState) {
                                    debugPrint(
                                        "CCardUpdateQuanitiyStateGG  ${state.listProduct.length.toString()}");

                                    listProduct = state.listProduct;
                                  }
                                  if (route == Routes.order_history) {
                                    dummyData.addQuantity =
                                        int.parse(dummyData.quantity ?? "0");
                                  } else {}
                                  return BlocBuilder(
                                    bloc: blocFeatured,
                                    builder: (context, state) {
                                      print("FEATURE STAET ${state}");
                                      if (state is ProductChangeState) {

                                        print(
                                            "state productId ${state.model.productId}");
                                        print(
                                            "dummyData productId ${state.model.addQuantity}");
                                        if (dummyData.productId ==
                                            state.model.productId) {
                                          dummyData = state.model;
                                          listProduct[index].addQuantity =
                                              state.model.addQuantity;
                                          listProduct[index].quantity = state
                                              .model.addQuantity
                                              .toString();
                                        }

                                        blocFeatured.add(ProductNullEvent());
                                      }
                                      return Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 5),
                                        child: categoryItemView2(
                                            context,
                                            listProduct,
                                            dummyData,
                                            null,
                                            0, () {
                                          if (dummyData.addQuantity ==
                                              int.parse(dummyData.orderQtyLimit!
                                                  .toString())) {
                                            Fluttertoast.showToast(
                                                msg: StringContants
                                                    .msg_quanitiy);
                                          } else {
                                            // if (dummyData.addQuantity == 0) {
                                            //   dbhelper.addCard(
                                            //       dummyData, cardBloc);
                                            // }
                                            dummyData.addQuantity =
                                                dummyData.addQuantity + 1;
                                            blocFeatured.add(
                                                ProductUpdateQuantityEvent(
                                                    quanitity:
                                                        dummyData.addQuantity!,
                                                    index: index));
                                            blocFeatured.add(ProductChangeEvent(
                                                model: dummyData));
                                            //   updateCardreorder(dummyData);
                                            debugPrint("Scroll Event1111 ");
                                          }
                                        }, () async {
                                          if (dummyData.addQuantity == 1) {
                                            dummyData.addQuantity = 0;
                                            blocFeatured.add(
                                                ProductUpdateQuantityEventBYModel(
                                                    model: dummyData));
                                          } else if (dummyData.addQuantity !=
                                              0) {
                                            dummyData.addQuantity =
                                                dummyData.addQuantity - 1;

                                            blocFeatured.add(
                                                ProductUpdateQuantityEventBYModel(
                                                    model: dummyData));

                                            blocFeatured.add(ProductChangeEvent(
                                                model: dummyData));
                                          }

                                          // debugPrint(
                                          //     "  ${listProduct.length.toString()}");
                                          //
                                          // listProduct = listProduct;

                                          // cardBloc.add(CardUpdateQuantityEvent(
                                          //     quantity: dummyData.addQuantity,
                                          //     index: index,
                                          //     listProduct: listProduct));
                                        }, () async {
                                          // dummyData.addQuantity = 0;
                                          // blocFeatured.add(
                                          //     ProductUpdateQuantityEventBYModel(
                                          //         model: dummyData));
                                          // blocShopby.add(ShopByNullEvent());
                                          // blocShopby.add(
                                          //     ShopbyProductChangeEvent(
                                          //         model: dummyData));
                                          // await dbhelper
                                          //     .deleteCard(int.parse(
                                          //         dummyData.productId!))
                                          //     .then((value) {
                                          //   debugPrint(
                                          //       "Delete Product $value ");
                                          //   cardBloc.add(CardDeleteEvent(
                                          //       model: listProduct[index],
                                          //       listProduct: listProduct));
                                          //   dbhelper
                                          //       .loadAddCardProducts(cardBloc);
                                          //
                                          //   listProduct.removeAt(index);
                                          //
                                          //   if (listProduct.length == 0) {
                                          //     cardBloc.add(CardEmptyEvent());
                                          //     Navigator.pop(context);
                                          //   }
                                          // });
                                        }, () {
                                          // dbhelper
                                          //     .loadAddCardProducts(cardBloc);
                                          // refresh();
                                        }, false, false, () {}, false,
                                            blocFeatured),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        // body: Container(
                        //   height: height,
                        //   decoration: const BoxDecoration(
                        //     borderRadius: BorderRadius.vertical(
                        //       top: Radius.circular(25),
                        //     ),
                        //     color: ColorName.aquaHazeColor,
                        //   ),
                        //   child: Container(
                        //     padding: EdgeInsets.only(top: 0),
                        //     height: height,
                        //     child:
                        //   ),
                        // ),
                        floatingActionButtonLocation:
                            FloatingActionButtonLocation.centerDocked,
                        floatingActionButton: route ==
                                Routes.order_history_detail
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    10.toSpace,
                                    Expanded(
                                        child:
                                            ButtonSecondaryForOrderModification(
                                      "Update Order",
                                      () async {
                                        // ToDO work on this Flow 30 oct 24

                                        /*await Future.forEach(listProduct,
                                            (element) async {
                                          element.specialPrice =
                                              element.price_plain;

                                          bool exists = await checkItemId(
                                              element.productId!, dbhelper);
                                          if (!exists) {
                                            dbhelper.addCard(element, cardBloc);
                                          } else {
                                            await dbhelper.updateCard({
                                              DBConstants.PRODUCT_ID:
                                                  int.parse(element.productId!),
                                              DBConstants.QUANTITY:
                                                  element.addQuantity,
                                            });
                                          }
                                        });*/
                                        /*  await Future listProduct.forEach(
                                          (element) {
                                            element.specialPrice =
                                                element.price_plain;
                                            checkItemId(element.productId!,
                                                    dbhelper)
                                                .then(
                                              (value) async {
                                                if (value == false) {
                                                  dbhelper.addCard(
                                                      element, cardBloc);
                                                } else {
                                                  log("PRODUCT ELEMENT >>  ${element.productId}");
                                                  // dbhelper.updateCard(
                                                  //     element.toMap());

                                                  int status = await dbhelper
                                                      .updateCard({
                                                    DBConstants.PRODUCT_ID:
                                                        int.parse(
                                                            element.productId!),
                                                    DBConstants.QUANTITY:
                                                        element.addQuantity,
                                                  });
                                                }
                                              },
                                            );
                                          },
                                        );*/

                                        int i = 0;
                                        for (i; i < listProduct.length; i++) {
                                          var element = listProduct[
                                              i]; // Access the current product using the index `i`
                                          print(
                                              "EditOrdeQuntity ${element.addQuantity}");
                                          print(
                                              "EditOrdeQuntity ${element.quantity} \n\n");
                                          element.specialPrice =
                                              element.price_plain;

                                          bool exists = await checkItemId(
                                              element.productId!, dbhelper);

                                          if (!exists) {
                                            await dbhelper.addCard(
                                                element, cardBloc);
                                          } else {
                                            await dbhelper.updateCard({
                                              DBConstants.PRODUCT_ID:
                                                  int.parse(element.productId!),
                                              DBConstants.QUANTITY:
                                                  element.addQuantity,
                                            });
                                          }

                                          print(
                                              "Processed product at index: $i ${i == (listProduct.length - 1)}");
                                          // Log the current index

                                          if (i == (listProduct.length - 1)) {
                                            log("JINDAGI ${json.encode(listProduct)}");

                                            await Future.delayed(
                                                Duration(seconds: 1), () {
                                              Productvalidationswidgets()
                                                  .loadProductValicationforReorder(
                                                      context,
                                                      listProduct,
                                                      orderId,
                                                      cardBloc,
                                                      dbhelper, () {
                                                // dbhelper.loadAddCardProducts(
                                                //     cardBloc);
                                              });
                                            });

                                            break;
                                          }
                                        }
                                        //   print("JINDAGI $i");
                                      },
                                    )),
                                    10.toSpace,
                                    Expanded(
                                        child:
                                            ButtonSecondaryForOrderModification(
                                      "Add Products",
                                      () async {
                                        List<ProductData> productDatalist = [];
                                        await SharedPref.setBooleanPreference(
                                            "EditOrder", true);
                                        await SharedPref.setStringPreference(
                                            "OrderId", orderId);
                                        Navigator.pushNamed(
                                            context, Routes.featuredProduct,
                                            arguments: {
                                              "key": StringContants.lbl_search,
                                              "list": productDatalist,
                                              "paninatinUrl": ""
                                            }).then((value) {
                                          if (value != null) {
                                            List<ProductUnit> listFromSearch =
                                                value as List<ProductUnit>;

                                            print("DONE LIST >>>>>> ${listFromSearch.length}");

                                            cardBloc.add(
                                                AddCardOrderProductEvent(
                                                    listProduct: listFromSearch));
                                            // listFromSearch.forEach(
                                            //   (element) {
                                            //     log("DATA FROM SEARCH SCREEN ${element.addQuantity} NAme ${element.name} ${element.quantity}");
                                            //     if (!listProduct
                                            //         .contains(element)) {
                                            //       listProduct.add(element);
                                            //       cardBloc.add(
                                            //           AddCardOrderProductEvent(
                                            //               listProduct:
                                            //                   listProduct));
                                            //     }
                                            //   },
                                            // );
                                          }

                                          // if (value != null) {
                                          //   List<ProductUnit> listFromSearch =
                                          //       value as List<ProductUnit>;
                                          //   listFromSearch.forEach(
                                          //     (element) {
                                          //       log("DATA FROM SEARCH SCREEN ${element.addQuantity} NAme ${element.name}");
                                          //       //   log("DATA FROM SEARCH SCREEN ${listFromSearch.length}");
                                          //
                                          //       //  dbhelper.loadAddCardProducts(cardBloc);
                                          //
                                          //       //listProduct=listFromSearch;
                                          //       //  blocFeatured.add(LoadedUnitEvent(list: listFromSearch));
                                          //       // if (!listProduct
                                          //       //     .contains(element)) {
                                          //       //   listProduct.add(element);
                                          //       //   cardBloc.add(
                                          //       //       CardUpdateQuantityEvent(
                                          //       //           quantity: element
                                          //       //               .addQuantity,
                                          //       //           index: element
                                          //       //               .selectedUnitIndex,
                                          //       //           listProduct:
                                          //       //               listProduct));
                                          //       // }
                                          //     },
                                          //   );
                                          // }
                                        });
                                      },
                                    )),
                                    10.toSpace,
                                  ],
                                ),
                              )
                            : InkWell(
                                onTap: () async {
                                  int i = 0;
                                  for (i = 0; i < listProduct.length; i++) {
                                    await dbhelper
                                        .getQuanityt(listProduct[i].productId!)
                                        .then((value) {
                                      ProductUnit unit = listProduct[i];
                                      log("GETQUANITITY ${value}");
                                      if (value == 0) {
                                        log("REORDERG Add ");
                                        dbhelper.addCard(unit, CardBloc());
                                      } else {
                                        if (unit.addQuantity != value) {
                                          // listProduct[i].addQuantity =
                                          //     listProduct[i].addQuantity +
                                          //         value;
                                          dbhelper.updateCard2(
                                              listProduct[i], CardBloc());
                                        }

                                        log("REORDERG UPDATE ");
                                      }
                                    });
                                  }

                                  if (i == listProduct.length) {
                                    await dbhelper
                                        .loadAddCardProducts(cardBloc);
                                    //
                                    // print("ONREORDERGG ${cardBloc.state}");
                                    // print("ONREORDERGG ${state}");
                                    callback();
                                    Navigator.pop(context);
                                    //
                                    // showModalBottomSheet(
                                    //     barrierColor:
                                    //         Colors.black.withOpacity(0.4),
                                    //     elevation: 0,
                                    //     context: context,
                                    //     isScrollControlled: true,
                                    //     shape: const RoundedRectangleBorder(
                                    //       borderRadius: BorderRadius.vertical(
                                    //         top: Radius.circular(25),
                                    //       ),
                                    //     ),
                                    //     builder: (context) {
                                    //       // using a scaffold helps to more easily position the FAB
                                    //       return Appwidgets.ShowBottomView33(
                                    //           true,
                                    //           context,
                                    //           cardBloc,
                                    //           FeaturedBloc(),
                                    //           ShopByCategoryBloc(),
                                    //           animationBloc,
                                    //           animationsizebottom,
                                    //           0,
                                    //           "",
                                    //           true,
                                    //           dbhelper,
                                    //           () async {
                                    //             debugPrint(
                                    //                 "OrderSummary Screen back >>>>>1 ${animationsizebottom}");
                                    //
                                    //             await dbhelper
                                    //                 .queryAllRowsCardProducts()
                                    //                 .then((value) {
                                    //               debugPrint(
                                    //                   "OrderSummary Screen back >>>>>1 ${value}");
                                    //
                                    //               if (value.length == 0) {
                                    //                 //gotoHomepage();
                                    //               }
                                    //             });
                                    //           },
                                    //           () {
                                    //             debugPrint(
                                    //                 "OrderSummary Screen back >>>>>2");
                                    //             // gotoHomepage();
                                    //           },
                                    //           () {
                                    //             debugPrint(
                                    //                 "OrderSummary Screen back >>>>>3");
                                    //           },
                                    //           true,
                                    //           (value) {
                                    //             // debugPrint("HomePage Screen back >>>>>");
                                    //             // isOpenBottomview = value;
                                    //             // homePageBloc2.add(HomeNullEvent());
                                    //             // homePageBloc2
                                    //             //     .add(HomeBottomSheetEvent(status: value));
                                    //           },
                                    //           (height) {
                                    //             debugPrint(
                                    //                 "GGheight >> $height");
                                    //             animationsizebottom = 70.0;
                                    //           });
                                    //     }).then((value) {
                                    //   debugPrint("Colse Bottom View $value");
                                    // });
                                    // List<ProductUnit> cartItems = [];

                                    //
                                    // if (state is AddCardProductState) {
                                    //   cartItems = state.listProduct;
                                    //
                                    //
                                    //   // Appwidgets.ShowDialogBottom(
                                    //   //     context,
                                    //   //     cardBloc,
                                    //   //     cartItems,
                                    //   //     blocFeatured,
                                    //   //     blocShopby,
                                    //   //     () {},
                                    //   //     false);
                                    // }
                                  }
                                },
                                child: Container(
                                  width: Sizeconfig.getWidth(context),
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                      color: ColorName.ColorPrimary),
                                  child: Text(
                                    "Add to Cart",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: Constants.Sizelagre,
                                        fontFamily: Fontconstants.fc_family_sf,
                                        fontWeight:
                                            Fontconstants.SF_Pro_Display_Bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                        // floatingActionButton: Container(
                        //   transform: Matrix4.translationValues(
                        //       0.0, -60, 0.0), // translate up by 30
                        //   child: InkWell(
                        //       onTap: () {
                        //         // do stuff
                        //         debugPrint('doing stuff');
                        //       },
                        //       child: Image.asset(
                        //         Imageconstants.img_roud_cross,
                        //         height: 40,
                        //         width: 40,
                        //       )),
                        // ),
                        // floatingActionButtonLocation:
                        //     FloatingActionButtonLocation.centerTop,
                      ),
                    );
                  }),
            ),
          );
        }).then((value) {
      debugPrint("Colse Bottom View $value");

      refresh();
    });
  }

  Future<bool> checkItemId(String id, DatabaseHelper dbHelper) async {
    final allRows = await dbHelper.queryAllRowsCardProducts();
    for (final row in allRows) {
      String id2 = row[DBConstants.PRODUCT_ID].toString();

      if (id == id2) {
        return true;
      }
    }
    return false;
  }

  static double calculateBottomSheetHeight(int size, BuildContext context) {
    double baseHeight = Sizeconfig.getHeight(context);

    /*  if (size >= 5) {
      return baseHeight * 0.95;
    } else if (size == 4) {
      return baseHeight * 0.81;
    } */
    if (size >= 3) {
      return baseHeight * 0.8; // Adjusted to fit within the modal better
    } else if (size == 2) {
      return baseHeight * 0.45;
    } else if (size == 1) {
      return baseHeight * 0.3;
    } else {
      // Handle unexpected cases or default
      return baseHeight * 0.32;
    }
  }

  static cacheNetworkImage(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.fill,
      placeholder: (context, url) => Image.asset(Imageconstants.img_loader),
    );
  }

  Widget noPlaceFoundWidget(state) {
    return Center(
      child: Appwidgets.Text_20(state.noLocationFoundText, ColorName.black),
    );
  }

  static setStatusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
        statusBarColor: ColorName.ColorPrimary,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light));
  }

  static setStatusBarColorWhite() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: ColorName.ColorBagroundPrimary,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark // optional
        ));
  }

  static setStatusBarDynamicLightColor({required Color color}) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
        statusBarColor: color,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light // optional
        ));
  }

  static setStatusBarDynamicDarkColor({required Color color}) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: color,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark // optional
        ));
  }

  static showExitDialog(BuildContext context, String title, String description,
      Function onpress) async {
    showModalBottomSheet(
        barrierColor: Colors.black.withOpacity(0.4),
        elevation: 0,
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        builder: (context) {
          // using a scaffold helps to more easily position the FAB
          return Container(
            height: 140,
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            width: Sizeconfig.getWidth(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: Constants.SizeExtralagre,
                      fontFamily: Fontconstants.fc_family_sf,
                      fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(
                  child: Text(
                    description,
                    style: TextStyle(
                      fontSize: Constants.Sizelagre,
                      fontFamily: Fontconstants.fc_family_sf,
                      fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () async {
                        onpress();
                      },
                      child: Container(
                          width: (Sizeconfig.getWidth(context) / 2) * 0.85,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              color: ColorName.grey),
                          padding:
                              EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                          child: Center(child: Text(StringContants.lbl_exit))),
                    ),
                    InkWell(
                      onTap: () async {
                        Navigator.pop(context);
                      },
                      child: Container(
                          width: (Sizeconfig.getWidth(context) / 2) * 0.85,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              color: ColorName.ColorPrimary),
                          padding:
                              EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                          child:
                              Center(child: Text(StringContants.lbl_cancel))),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).then((value) {
      debugPrint("Colse Bottom View $value");
    });
  }

  static ShowDialogDescription(BuildContext context, ProductUnit model) async {
    AnimationBloc animationBloc = AnimationBloc();
    var animationsizebottom = 0.0;

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
        builder: (context) {
          // using a scaffold helps to more easily position the FAB
          return Container(
            height: Sizeconfig.getHeight(context) * 0.5,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Container(
                height: Sizeconfig.getHeight(context) * 0.5,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                  color: Colors.white,
                ),
                child: SingleChildScrollView(
                  // height: Sizeconfig.getHeight(context) * 0.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: Sizeconfig.getHeight(context) * .2,
                        width: Sizeconfig.getWidth(context),
                        padding: EdgeInsets.only(top: 10),
                        child: Center(
                          child: Image.network(
                            model.image!,
                            height: Sizeconfig.getHeight(context) * .2,
                            width: Sizeconfig.getWidth(context) / 2,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          StringContants.lbl_product_details,
                          style: Appwidgets().commonTextStyle(ColorName.black),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        child: Container(
                          child: HtmlWidget(
                            model!.description!,
                            textStyle: const TextStyle(color: ColorName.black),
                            // style: {
                            //   "*": Style(
                            //     color: Colors.black,
                            //   ),
                            // },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // translate the FAB up by 30
              floatingActionButton: Container(
                transform: Matrix4.translationValues(
                    0.0, -60, 0.0), // translate up by 30
                child: InkWell(
                    onTap: () {
                      // do stuff
                      debugPrint('doing stuff');
                      animationBloc.add(AnimationCartEvent(size: 0));
                    },
                    child: Image.asset(
                      Imageconstants.img_roud_cross,
                      height: 40,
                      width: 40,
                    )),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerTop,
            ),
          );
        }).then((value) {
      debugPrint("Colse Bottom View $value");
    });
  }
}

class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
