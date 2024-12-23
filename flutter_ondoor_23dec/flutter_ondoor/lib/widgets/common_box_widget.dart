import 'dart:ui';

import 'package:flutter/material.dart';

import '../utils/colors.dart';

class CommonBoxWidget extends StatelessWidget {
  Widget child;
  double height;
  double width;
  Color color;
  EdgeInsetsGeometry padding;
  CommonBoxWidget(
      {super.key,
      required this.child,
      required this.height,
      required this.padding,
      required this.color,
      required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
          border: Border.all(color: ColorName.lightGey),
          borderRadius: BorderRadius.circular(10),
          color: color),
      child: child,
    );
  }




}
