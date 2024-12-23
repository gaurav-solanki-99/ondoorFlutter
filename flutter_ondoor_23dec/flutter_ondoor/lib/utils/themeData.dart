import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ondoor/utils/colors.dart';

class OndoorThemeData {
  static const String defaultFont = "Poppins";
  static setStatusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: ColorName.ColorPrimary, // Set status bar color here
        statusBarIconBrightness: Brightness.light));
  }

  static keyBordDow() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static final lightTheme = ThemeData(
    primarySwatch: MaterialColor(
      0,
      <int, Color>{
        50: ColorName.ColorPrimary.withOpacity(.1),
        100: ColorName.ColorPrimary.withOpacity(.2),
        200: ColorName.ColorPrimary.withOpacity(.3),
        300: ColorName.ColorPrimary.withOpacity(.4),
        400: ColorName.ColorPrimary.withOpacity(.5),
        500: ColorName.ColorPrimary.withOpacity(.6),
        600: ColorName.ColorPrimary.withOpacity(.7),
        700: ColorName.ColorPrimary.withOpacity(.8),
        800: ColorName.ColorPrimary.withOpacity(.9),
        900: ColorName.ColorPrimary.withOpacity(1.0),
      },
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.yellow, elevation: 10),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: ColorName.ColorPrimary,
      selectionColor: ColorName.grey.withOpacity(0.5),
      selectionHandleColor: ColorName.ColorPrimary,
    ),
    primaryColor: ColorName.ColorPrimary,
    brightness: Brightness.light,

    primaryTextTheme: Typography(platform: TargetPlatform.iOS).white,
    textTheme: Typography(platform: TargetPlatform.iOS).white,
    scaffoldBackgroundColor:
        ColorName.ColorBagroundPrimary, // background color for every screen
    useMaterial3: true,
    fontFamily: defaultFont, // font style
    // textSelectionTheme: const TextSelectionThemeData(
    //     cursorColor: ColorName.ColorPrimary), // cursor color
    iconTheme: const IconThemeData(color: ColorName.aquaHazeColor), //icon color
    // icon button
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        elevation: MaterialStateProperty.resolveWith<double>((states) => 0),
        iconColor: MaterialStateProperty.resolveWith<Color>(
            (states) => ColorName.ColorPrimary),
        textStyle: MaterialStateProperty.resolveWith<TextStyle>(
            (states) => const TextStyle(fontWeight: FontWeight.bold)),
      ),
    ),
    // scroll bar
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>(
          (states) => ColorName.ColorPrimary),
      interactive: true,
      trackColor: MaterialStateProperty.resolveWith<Color>(
          (states) => ColorName.grey.withOpacity(0.5)),
      thickness: MaterialStateProperty.resolveWith<double>((states) => 5.0),
    ),

    // radio button
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>(
          (states) => ColorName.ColorPrimary),
    ),

    // switch
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>(
          (states) => ColorName.ColorBagroundPrimary),
    ),

    // checkbox
    checkboxTheme: CheckboxThemeData(
      checkColor: MaterialStateProperty.resolveWith<Color>(
          (states) => ColorName.ColorBagroundPrimary),
    ),

    // alert dialog
    dialogTheme: DialogTheme(
      surfaceTintColor: ColorName.ColorBagroundPrimary,
      shape: Border.all(color: ColorName.grey.withOpacity(0.5)),
    ),

    // app bar of Scafold
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: ColorName.ColorPrimary,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w500,
        color: ColorName.black,
        fontSize: 23, //20
      ),
      iconTheme: IconThemeData(color: ColorName.aquaHazeColor),
      elevation: 0,
      actionsIconTheme: IconThemeData(color: ColorName.ColorPrimary),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: ColorName.ColorBagroundPrimary,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),

    // elevated button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorName.ColorPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: defaultFont,
        ),
      ),
    ),

    // outlined button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        side: BorderSide(color: ColorName.ColorPrimary),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: defaultFont,
        ),
      ),
    ),

    // text button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        elevation: 0,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontFamily: defaultFont,
        ),
      ),
    ),

    // TextFormField decoration
    inputDecorationTheme: InputDecorationTheme(
      fillColor: ColorName.ColorBagroundPrimary,
      filled: true,
      errorStyle: TextStyle(color: ColorName.ColorPrimary),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: ColorName.ColorBagroundPrimary,
          width: 0.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: ColorName.ColorBagroundPrimary,
          width: 0.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: ColorName.ColorPrimary,
          width: 0.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: ColorName.ColorPrimary,
          width: 0.5,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: ColorName.ColorBagroundPrimary,
          width: 0.5,
        ),
      ),
    ),
  );

// static Color black = Colors.black,
//     white = Colors.white,
//     // grey = Colors.grey,
//     // red = Colors.red,
//     transparent = Colors.transparent,
//     blue = Colors.blue,
//     green = Colors.green;
}
