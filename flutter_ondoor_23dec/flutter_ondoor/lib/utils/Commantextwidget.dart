import 'package:flutter/material.dart';

import '../constants/Constant.dart';
import '../constants/FontConstants.dart';

class CommanTextWidget {
  // static headingText(String heading, double size, Color clr,
  //     {TextAlign? align, double? wspacing}) =>
  //     Text(
  //       heading,
  //       textAlign: align ?? TextAlign.start,
  //       style: robototextStyle(clr, size, FontWeight.w600, wspacing ?? 0),
  //     );
  // static subheadingText(String heading, Color clr,
  //     {TextAlign? align,
  //       double? size,
  //       FontWeight? weight,
  //       double? wspacing}) =>
  //     Text(
  //       heading,
  //       textAlign: align ?? TextAlign.start,
  //       style: robototextStyle(
  //           clr, size ?? 14, weight ?? FontWeight.w500, wspacing ?? 0),
  //     );
  //
  // static mainText(String heading, double? wspacing) => Text(
  //   heading,
  //   style: robototextStyle(
  //       MyColor.textBlack, 12, FontWeight.w500, wspacing ?? 0),
  // );
  //
  //
  // static poppinstextStyle(Color color, double size, FontWeight weight) =>
  //     GoogleFonts.poppins(color: color, fontSize: size, fontWeight: weight);
  // static opensanstextStyle(Color color, double size, FontWeight weight) =>
  //     GoogleFonts.openSans(color: color, fontSize: size, fontWeight: weight);
  // static robototextStyle(
  //     Color color, double size, FontWeight weight, double? spacing,
  //     {TextStyle? trt}) =>
  //    FontStyle.(
  //         color: color,
  //         fontSize: size,
  //         fontWeight: weight,
  //         letterSpacing: spacing).copyWith(trt!);

  static const double Sizelagre = 18.0;
  static const double SizeSmall = 12.0;
  static const double Sizesubheading2 = 14.0;
  static const double Sizesubheading = 16.0;
  static const double SizeExtralagre = 20.0;
  // Button text: 16–18 px (depending on the button size)
  // Captions and small labels: 13 px (avoid going below 12px for readability)
  // MediaQuery.of(context).size.width * 0.05, // Responsive font size

  static textLagre(String text, var color) {
    return Text(
      text,
      maxLines: 1,
      style: TextStyle(
          fontSize: Sizelagre,
          fontFamily: Fontconstants.fc_family_proxima,
          fontWeight: FontWeight.w600,
          color: color),
    );
  }

  static subheading(String text, var color) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 17.5,
          fontFamily: Fontconstants.fc_family_proxima,
          fontWeight: FontWeight.w700,
          color: color),
    );
  }

  static subheading2(String text, var color) {
    return Text(
      text,
      maxLines: 1,
      style: TextStyle(
          fontSize: Sizesubheading2,
          fontFamily: Fontconstants.fc_family_proxima,
          fontWeight: FontWeight.w500,
          color: color),
    );
  }

  static subtitle(String text, var color) {
    return Text(
      text,
      maxLines: 1,
      style: TextStyle(
          fontSize: 13,
          fontFamily: Fontconstants.fc_family_proxima,
          fontWeight: FontWeight.w500,
          color: color),
    );
  }

  static regular(String text, var color) {
    return Text(
      text,
      style: TextStyle(
          fontSize: SizeSmall,
          fontFamily: Fontconstants.fc_family_proxima,
          fontWeight: FontWeight.w400,
          color: color),
    );
  }

  static Text regularBold(
    String text,
    Color color, {
    int? maxline,
    TextAlign? textalign,
    TextStyle? trt,
    String fontFamily = Fontconstants.fc_family_proxima,
  }) {
    return Text(
      text,
      textAlign: textalign!,
      maxLines: maxline!,
      style: getRegularStyle(color, SizeSmall,
          trt: trt, fontFamily: fontFamily ?? Fontconstants.fc_family_proxima),
    );
  }

  static TextStyle getRegularStyle(
    Color color,
    double size, {
    TextStyle? trt,
    String? fontFamily, // Default value for fontFamily
  }) {
    return TextStyle(
      color: color,
      fontSize: size,
      fontFamily: fontFamily,
    ).copyWith(
      color: trt?.color,
      fontSize: trt?.fontSize,
      fontWeight: trt?.fontWeight,
      letterSpacing: trt?.letterSpacing,
      height: trt?.height,
      decoration: trt?.decoration,
      decorationColor: trt?.decorationColor,

      // Copy other attributes as needed from `trt`
    );
  }
}
