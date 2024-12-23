import 'package:flutter/material.dart';

class Validator {
  // static RegExp emailRegex = RegExp(
  //     r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");


  static RegExp emailRegex = RegExp(
      r"^(?!\.)([a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+)@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$");



  static RegExp passwordRegex =
      RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
  static RegExp doubleRegex = RegExp(r'^(?:0|[1-9][0-9]*)\.[0-9]+$');
  static RegExp gstRegex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');

  static RegExp name = RegExp(r'[a-z A-Z]');

  static String? emailValidator(String email) {
    if (email.isEmpty) {
      return null;
    }

    if (!emailRegex.hasMatch(email)) {
      return "Please Enter valid mail";
    }
    return null;
  }



  static String? gstValidator(String gst) {
    if (gst.isEmpty) {
      return null;
    }

    if (!gstRegex.hasMatch(gst)) {
      return "Please Enter valid GST No.";
    }
    return null;
  }

  String patttern = r'(^[0-9]*$)';
  static String? validateMobile(String value, BuildContext context) {
    String patttern = r'(^[0-9]*$)';
    RegExp regExp = RegExp(patttern);
    if (value.isEmpty) {
      // return "please_enter_mobile_number_key".tr();
    } else if (value.length != 10) {
      return "Please enter atleast 10 digit";
    } else if (!regExp.hasMatch(value)) {
      return "Only digit allow";
    }
    return null;
  }

  static String? passwordValidator(String password) {
    if (password.isEmpty) {
      return null;
    }
    // if (!passwordRegex.hasMatch(password)) {
    //   return '';
    // }
    return null;
  }
}

extension extString on String {
  bool get isValidEmail {
    final emailRegExp = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegExp.hasMatch(this);
  }

  bool get isValidName {
    final nameRegExp =
        new RegExp(r"^\s*([A-Za-z]{1,}([\.,] |[-']| ))+[A-Za-z]+\.?\s*$");
    return nameRegExp.hasMatch(this);
  }

  bool get isValidPassword {
    final passwordRegExp = RegExp(
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\><*~]).{8,}/pre>');
    return passwordRegExp.hasMatch(this);
  }

  bool get isNotNull {
    return this != null;
  }

  bool get isValidPhone {
    final phoneRegExp = RegExp(r"^\+?0[0-9]{10}$");
    return phoneRegExp.hasMatch(this);
  }
}
