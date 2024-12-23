import 'package:animated_hint_textfield/animated_hint_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ondoor/utils/colors.dart';

import 'FontConstants.dart';

class CustomTextField extends StatefulWidget {
  final TextInputType keyboardType;
  final String hintText;
  final String activeIcon;

  final String inactiveIcon;
  final EdgeInsetsGeometry padding;
  final TextEditingController controller;
  final bool isPassword;
  final bool? obscureText;
  final bool readOnly;
  final String? suffixIcon;
  final String? initialValue;
  final int? textInputNumber;
  final Function ontap;
  final Function(String) onchanged;
  final Function(String) onSubmit;
  final bool iskeyboardopen;
  final List<String> hinttextlist;

  const CustomTextField(
      {Key? key,
      required this.keyboardType,
      required this.hintText,
      required this.activeIcon,
      required this.inactiveIcon,
      required this.padding,
      required this.controller,
      required this.isPassword,
      required this.readOnly,
      this.obscureText,
      this.suffixIcon,
      this.initialValue,
      this.textInputNumber,
      required this.ontap,
      required this.onchanged,
      required this.onSubmit,
      required this.iskeyboardopen,
      required this.hinttextlist})
      : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isFocused = false;
  bool passwordVisible = false;

  @override
  void initState() {
    super.initState();
    passwordVisible = true;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: AnimatedTextField(
        animationType: Animationtype.typer,
        inputFormatters: widget.isPassword
            ? [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ]
            : [
                LengthLimitingTextInputFormatter(widget.textInputNumber),
              ],
        initialValue: widget.initialValue,
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        enableInteractiveSelection: true,
        enabled: widget.readOnly ? false : true,
        showCursor: true,
        onSubmitted: ((value) {
          debugPrint("ONAction Done");
          widget.onSubmit(value);
        }),
        cursorColor: ColorName.ColorPrimary,
        readOnly: widget.readOnly,
        autofocus: widget.iskeyboardopen,
        onTap: () {
          setState(() {
            isFocused = true;
          });
        },
        onChanged: (text) {
          setState(() {
            isFocused = text.isNotEmpty;
          });

          widget.onchanged(text);
        },
        textInputAction: TextInputAction.search,
        obscureText: widget.isPassword ? passwordVisible : !passwordVisible,
        decoration: InputDecoration(
          filled: true,
          fillColor: widget.readOnly ? Colors.white : Colors.white,
          contentPadding: EdgeInsets.all(10),
          isDense: true,
          hintText: widget.hintText,
          hintStyle: TextStyle(fontSize: 14.0, color: ColorName.textlight),
          prefixIcon: InkWell(
            child: Padding(
                padding: widget.padding,
                child: Icon(
                  Icons.search,
                  color: ColorName.ColorPrimary,
                  size: 22,
                )

                /*     Container(
                child: SizedBox(
                  height: 4,
                  child:


                  Image.asset(
                    color: ColorName.ColorPrimary,
                    widget.readOnly
                        ? widget.inactiveIcon
                        : isFocused
                            ? widget.activeIcon
                            : widget.inactiveIcon,
                    width: 3,
                  ),
                ),
              ),*/
                ),
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: Icon(
                      size: 20,
                      color: ColorName.black,
                      passwordVisible
                          ? Icons.visibility_off
                          : Icons.visibility),
                  onPressed: () {
                    setState(
                      () {
                        passwordVisible = !passwordVisible;
                      },
                    );
                  },
                )
              : InkWell(
                  onTap: () {
                    widget.ontap();
                  },
                  child: Padding(
                      padding: widget.padding,
                      child: Icon(
                        Icons.mic,
                        color: ColorName.ColorPrimary,
                        size: 20,
                      )
                      // Image.asset(
                      //   widget.suffixIcon!,
                      //   color: ColorName.ColorPrimary,
                      //   height: 3,
                      //   width: 3,
                      // ),

                      ),
                ),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white54, // Sets the default border color
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(
                8.0), // Sets the corner radius of the border
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white54, // Sets the default border color
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color:
                  Colors.grey.withOpacity(0.5), // Sets the default border color
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white54, // Sets the default border color
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        hintTexts: widget.hinttextlist,
        hintTextStyle: const TextStyle(
          color: ColorName.textlight,
          fontSize: 13.0,
        ),
        style: TextStyle(
          color: widget.readOnly
              ? ColorName.black
              : ColorName.black, // Change the text color here
          fontFamily: Fontconstants.fc_family_sf,
        ),
      ),
    );
  }
}
