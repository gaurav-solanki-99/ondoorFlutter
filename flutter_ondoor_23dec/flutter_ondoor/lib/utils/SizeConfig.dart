import 'package:flutter/cupertino.dart';

class Sizeconfig
{

  static double getHeight(BuildContext context)=>MediaQuery.of(context).size.height;
  static double getWidth(BuildContext context)=>MediaQuery.of(context).size.width;

}