import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondoor/constants/ImageConstants.dart';
import 'package:ondoor/screens/NewAnimation/animation_event.dart';
import 'package:ondoor/screens/NewAnimation/animation_state.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/SizeConfig.dart';
import 'package:ondoor/utils/colors.dart';
import 'package:ondoor/widgets/ProductValidationsWidgets.dart';

import '../../constants/Constant.dart';
import '../../constants/FontConstants.dart';
import '../../database/database_helper.dart';
import '../../models/AllProducts.dart';
import '../../widgets/AppWidgets.dart';
import '../AddCard/card_bloc.dart';
import '../NewAnimation/animation_bloc.dart';

class Productvalidationscreen extends StatefulWidget {
  List<ProductUnit> listproduct;
  List<ProductUnit> list_cOffers;
  String title;
  String subtitle;
  String details;
  bool mixed;
  String recurring;
  String totalitemAllowed;

  Productvalidationscreen(
      {super.key,
      required this.listproduct,
      required this.list_cOffers,
      required this.title,
      required this.subtitle,
      required this.details,
      required this.mixed,
      required this.recurring,
      required this.totalitemAllowed});

  @override
  State<Productvalidationscreen> createState() =>
      _ProductvalidationscreenState();
}

class _ProductvalidationscreenState extends State<Productvalidationscreen> {
  AnimationBloc animationBloc = AnimationBloc();
  var height_offer = 0.0;
  var width_offer = 0.0;
  final dbHelper = DatabaseHelper();
  CardBloc cardBloc = CardBloc();
  @override
  void initState() {
    Appwidgets.setStatusBarColorWhite();
    initializedDb();
    // addAnimation();
    super.initState();
  }

  addAnimation() {
    height_offer = Sizeconfig.getHeight(context) * 0.12;
    width_offer = Sizeconfig.getWidth(context) * 0.5;
    animationBloc
        .add(offerImageEvent(height: height_offer, width: width_offer));
  }

  initializedDb() async {
    cardBloc = CardBloc();
    await dbHelper.init();
    dbHelper.loadAddCardProducts(cardBloc);
  }

  @override
  Widget build(BuildContext context) {
    // height_offer= Sizeconfig.getHeight(context)*0.12;
    // width_offer=Sizeconfig.getWidth(context)*0.5;
    animationBloc.add(offerImageEvent(
        height: Sizeconfig.getHeight(context) * 0.12,
        width: Sizeconfig.getWidth(context) * 0.5));
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // transparent status bar
      statusBarIconBrightness: Brightness.dark, // dark icons on the status bar
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    log("FREE PRODUCT DATA ${jsonEncode(widget.listproduct)}");

    return SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                height: Sizeconfig.getHeight(context) * 0.40,
                color: Color(0xFF291722),
                child: Stack(
                  children: [
                    Image.asset(
                      Imageconstants.img_productvaliation,
                      height: Sizeconfig.getHeight(context) * 0.40,
                      width: Sizeconfig.getWidth(context),
                      fit: BoxFit.cover,
                    ),


                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: Sizeconfig.getWidth(context),

                        child: Center(
                          child: Container(


                            width: Sizeconfig.getWidth(context) * 0.65,
                            //color: Colors.yellow,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Container(

                                    margin:
                                        EdgeInsets.only(top: 80, right: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(),
                                            Container(
                                               width: Sizeconfig.getWidth(context) * 0.40,
                                              child: Text("${widget.title.trim()}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: Constants.SizeSmall,
                                                      fontFamily:
                                                          Fontconstants.fc_family_sf,
                                                      fontWeight: Fontconstants
                                                          .SF_Pro_Display_SEMIBOLD,
                                                      color:  ColorName.white_card)),
                                            ),
                                            Container()
                                          ],
                                        ),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(),
                                            Container(
                                              width: Sizeconfig.getWidth(context) * 0.55,
                                              child: Text("${widget.subtitle.trim()}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: Constants.SizeSmall,
                                                      fontFamily:
                                                      Fontconstants.fc_family_sf,
                                                      fontWeight: Fontconstants
                                                          .SF_Pro_Display_SEMIBOLD,
                                                      color: ColorName.white_card)
                                              ),
                                            ),
                                            Container()
                                          ],
                                        ),

                                        Container(
                                          margin: EdgeInsets.only(top: 5),
                                          height: 1,
                                          color:
                                          ColorName.white_card.withOpacity(
                                                  0.2),
                                          width:
                                              Sizeconfig.getWidth(context) * 0.55,
                                        ),
                                        Container(
                                            margin: EdgeInsets.only(top: 5),
                                            width: Sizeconfig.getWidth(context) * 0.55,
                                            child: Text(
                                                "${widget.details}",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: Constants.Size_10,
                                                    fontFamily:
                                                    Fontconstants.fc_family_sf,
                                                    fontWeight: Fontconstants
                                                        .SF_Pro_Display_SEMIBOLD,
                                                    color: ColorName.white_card)
                                            ),
                                        )
                                      ],
                                    ),
                                  ),


                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: Sizeconfig.getHeight(context) * 0.36
                ),
                child:

              Productvalidationswidgets.productValidationlistUi(
                  context,
                  widget.listproduct,
                  widget.list_cOffers,
                  cardBloc,
                  dbHelper,
                  widget.mixed,
                  widget.recurring,
                  widget.totalitemAllowed),

              )
            ],
          ),
        ));
  }
}
