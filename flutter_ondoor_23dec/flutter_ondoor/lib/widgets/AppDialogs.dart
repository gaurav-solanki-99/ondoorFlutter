import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ondoor/constants/ImageConstants.dart';
import 'package:ondoor/constants/StringConstats.dart';
import 'package:ondoor/utils/SizeConfig.dart';
import 'package:ondoor/utils/colors.dart';

import '../constants/Constant.dart';
import '../constants/FontConstants.dart';
import '../utils/Connection.dart';
import 'AppWidgets.dart';

class CustomDialog extends StatelessWidget {
  final String title, description, buttonText, image;
  Function onTap;
  Color colors;
  // final Image image;

  CustomDialog({
    required this.title,
    required this.description,
    required this.buttonText,
    required this.image,
    required this.onTap,
    required this.colors,
    // required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Container(
      child: Container(
        decoration: new BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(Consts.padding),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: const Offset(0.0, 10.0),
            ),
          ],
        ),
        width: Sizeconfig.getWidth(context),
        height: 250,
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Column(
          children: [
            Container(
              height: 80,
              width: Sizeconfig.getWidth(context),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  Container(
                      height: 50,
                      width: 50,
                      child: Image.asset(
                        Imageconstants.img_no_internet,
                        height: 50,
                        width: 50,
                        color: ColorName.ColorPrimary,
                      )),
                  Container(),
                ],
              ),
            ),

            Container(
              height: 160,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    child: Center(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: Constants.Sizelagre,
                          fontFamily: Fontconstants.fc_family_sf,
                          fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Center(
                      child: Text(
                        description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: Constants.SizeSmall,
                          fontFamily: Fontconstants.fc_family_sf,
                          fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      if (await Network.isConnected()) {
                        onTap();
                      } else {
                        Appwidgets.showToastMessage(
                            StringContants.lbl_no_connection);
                      }
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                            color: ColorName.ColorPrimary),
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        child: Text(StringContants.lbl_refresh)),
                  )
                ],
              ),
            )

            // Appwidgets.TextLagre(StringContants.lbl_ok, ColorName.black),
          ],
        ),
      ),
    );
  }
}

class Consts {
  Consts._();

  static const double padding = 5.0;
  static const double avatarRadius = 45.0;
}
