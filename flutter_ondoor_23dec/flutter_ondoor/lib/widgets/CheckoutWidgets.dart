import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:ondoor/constants/StringConstats.dart';
import 'package:ondoor/screens/AddCard/card_bloc.dart';
import 'package:ondoor/screens/CheckoutScreen/CheckoutBloc/checkout_bloc.dart';
import 'package:ondoor/screens/CheckoutScreen/CheckoutBloc/checkout_event.dart';
import 'package:ondoor/screens/CheckoutScreen/CheckoutBloc/checkout_state.dart';
import 'package:ondoor/screens/FeaturedProduct/FeatuuredBloc/featured_bloc.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/SizeConfig.dart';
import 'package:ondoor/utils/sharedpref.dart';
import 'package:ondoor/utils/shimmerUi.dart';
// import '../constants/FontConstants.dart';
import '../constants/Constant.dart';
import '../constants/FontConstants.dart';
import '../constants/ImageConstants.dart';
// import '../models/TopProducts.dart';
import '../database/database_helper.dart';
import '../database/dbconstants.dart';
import '../models/AllProducts.dart';
import '../models/TopProducts.dart';
import '../models/TopProducts.dart';
import '../screens/AddCard/card_event.dart';
import '../screens/AddCard/card_state.dart';
import '../screens/FeaturedProduct/FeatuuredBloc/featured_event.dart';
import '../screens/FeaturedProduct/FeatuuredBloc/featured_state.dart';
import '../screens/HomeScreen/HomeBloc/TopSellingBloc/top_selling_bloc.dart';
import '../screens/HomeScreen/HomeBloc/TopSellingBloc/top_selling_state.dart';
import '../screens/shop_by_category/shop_by_category_bloc/shop_by_category_bloc.dart';
import '../services/Navigation/routes.dart';
import '../utils/Commantextwidget.dart';
import '../utils/Utility.dart';
import '../utils/colors.dart';
import '../utils/themeData.dart';
import 'AppWidgets.dart';
import 'MyDialogs.dart';
import 'UiStyle.dart';
import 'common_cached_image_widget.dart';

class Checkoutwidgets {
  static SavingCardView(
      BuildContext context, String title, String subTitle, String amount) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      width: Sizeconfig.getWidth(context),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          color: ColorName.blue),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 7,
              child: Container(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Appwidgets.TextLagre(title, ColorName.white_card),
                  Appwidgets.TextRegular(subTitle, ColorName.white_card),
                ],
              ))),
          Expanded(
              flex: 3,
              child: Container(
                  child: Align(
                alignment: Alignment.topRight,
                child: Appwidgets.TextLagre(amount, ColorName.white_card),
              )))
        ],
      ),
    );
  }

/*  static selectedAddressUi(
      BuildContext context, String street, String locality, String token) {
    debugPrint("street ${street}");
    debugPrint("locality ${locality}");
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              child: Image.asset(
                Imageconstants.img_location_marker,
                height: 50,
                width: 50,
              ),
            ),
            flex: 1,
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 10, top: 5),
              child: street == ""
                  ? Shimmerui.shimmer_for_street_and_city_location(context, 50)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Appwidgets.TextLagre(street, Colors.black),
                        Appwidgets.TextMedium(locality, Colors.black)
                      ],
                    ),
            ),
            flex: 7,
          ),
          Expanded(
            flex: 2,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        border:
                            Border.all(color: ColorName.textlight, width: 0.5),
                      ),
                      child: Center(
                        child: Appwidgets.TextRegular(
                            StringContants.lbl_change, ColorName.ColorPrimary),
                      ),
                    ),
                  ),
                  Container(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }*/

  static productDetailsList(
    BuildContext context,
    List<ProductUnit> cartitesmList,
    List<ProductUnit> freeproducts,
    List<ProductUnit> cofferList,
    CardBloc cardBloc,
    DatabaseHelper dbHelper,
    CheckoutBloc checkoutbloc,
    bool viewmore,
  ) {
    int selectedIndex = -1;
    updateCard(ProductUnit model, int index, var list) async {
      int status = await dbHelper.updateCard({
        DBConstants.PRODUCT_ID: int.parse(model.productId!),
        DBConstants.QUANTITY: model.addQuantity,
      });

      debugPrint("Update Product Status " + status.toString());

      cardBloc.add(CardUpdateQuantityEvent(
          quantity: model.addQuantity, index: index, listProduct: list));

      dbHelper.loadAddCardProducts(cardBloc);

      cardBloc.add(CardValidationLoadEvent(validationload: true));
    }

    calculateAmount(List<ProductUnit> list) {
      double subtotalshow = 0;
      double subtotalcross = 0;

      try {
        for (var dummyData in list) {
          if (dummyData.specialPrice == "Free") {
          } else {
            log(" ROHITTT 1 DUMMY DATA ${dummyData.toMap()}");
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
            var crossprice = dummyData.specialPrice == ""
                ? "₹ ${double.parse(price).toStringAsFixed(2)}"
                : "₹ ${double.parse(price).toStringAsFixed(2)}";
            var showprice = dummyData.specialPrice == ""
                ? "₹ ${double.parse(sortPrice ?? "0.0").toStringAsFixed(2)}"
                : "₹ ${double.parse(specialPrice).toStringAsFixed(2)}";

            subtotalshow =
                subtotalshow + double.parse(showprice.replaceAll('₹ ', ""));
            subtotalcross =
                subtotalcross + double.parse(crossprice.replaceAll('₹ ', ""));
          }
        }

        print("GauravEvent>>>>>>>>>>>>>>>>>>>>>>> 1");
        checkoutbloc.add(CheckoutPriceUpdateEvent(
            subtotoal: subtotalshow, subtotoalcross: subtotalcross));
      } catch (excep, stackTrace) {
        log("Bug Found HERE ROHITTT $excep");
        log("Bug Found HERE ROHITTT $stackTrace");
      }
    }

    return BlocProvider(
      create: (context) => cardBloc,
      child: BlocBuilder(
          bloc: cardBloc,
          builder: (context, state) {
            if (state is CardAddcOfferProdutsState) {
              cartitesmList.add(state.unit);
            }

            debugPrint("State >>>>>>>>>>>>>>>>>  $state");
            if (state is AddCardState) {
              //count= state.count;
            }
            if (state is AddCardProductState) {
              cartitesmList = state.listProduct;
              calculateAmount(state.listProduct);
              // for(var x in freeproducts)
              // {
              //   cartitesmList.add(x);
              // }

              for (var x in cofferList) {
                if (cartitesmList.contains(x) == false) {
                  cartitesmList.add(x);
                  log("coffersProducts" + x.toJson());
                }
              }
            }

            if (state is CardUpdateQuanitiyState) {
              debugPrint(" CARD UPDATE ${state.listProduct.length}");

              cartitesmList = state.listProduct;
              calculateAmount(state.listProduct);
              for (var x in freeproducts) {
                cartitesmList.add(x);
              }
            }
            if (cartitesmList.isEmpty) {
              return Container(
                height: 0,
              );
            }
            if (state is CardEmptyState) {
              return Container(
                height: 0,
              );
            }
            if (state is CardDeleteSatate) {
              debugPrint("CardDeleteSatate >>>>>  ${state.listProduct.length}");
              cartitesmList = state.listProduct;
              calculateAmount(state.listProduct);
              for (var x in freeproducts) {
                cartitesmList.add(x);
              }
            }

            return Container(
                width: Sizeconfig.getWidth(context),
                //   height: Sizeconfig.getHeight(context)*0.30,
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: viewmore
                        ? cartitesmList.length
                        : (cartitesmList.length > 3 ? 3 : cartitesmList.length),
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      var dummyData = cartitesmList[index];

                      if (state is CardUpdateQuanitiyState) {
                        debugPrint("CardUpdateQuantity");
                        cartitesmList[state.index].addQuantity = state.quantity;
                      }

                      return ProductDetailsUI(context, dummyData, null, 0, () {
                        dummyData.addQuantity = dummyData.addQuantity + 1;

                        updateCard(dummyData, index, cartitesmList);
                      }, () async {
                        if (dummyData.addQuantity == 1) {
                          dummyData.addQuantity = 0;
                          await dbHelper
                              .deleteCard(int.parse(dummyData.productId!))
                              .then((value) {
                            debugPrint("Delete Product $value ");
                            cardBloc.add(CardDeleteEvent(
                                model: cartitesmList[index],
                                listProduct: cartitesmList));
                            dbHelper.loadAddCardProducts(cardBloc);

                            cartitesmList.removeAt(index);

                            if (cartitesmList.length == 0) {
                              cardBloc.add(CardEmptyEvent());
                              Navigator.pop(context);
                            }
                          });
                        } else if (dummyData.addQuantity != 0) {
                          dummyData.addQuantity = dummyData.addQuantity - 1;

                          updateCard(dummyData, index, cartitesmList);
                        }
                      }, () async {
                        dummyData.addQuantity = 0;

                        cardBloc.add(CardDeleteEvent(
                            model: cartitesmList[index],
                            listProduct: cartitesmList));
                        dbHelper.loadAddCardProducts(cardBloc);

                        cartitesmList.removeAt(index);

                        if (cartitesmList.length == 0) {
                          cardBloc.add(CardEmptyEvent());
                          Navigator.pop(context);
                        }
                      }, checkoutbloc);
                    }));
          }),
    );
  }

  static productDetailsListFinal(
      BuildContext context,
      List<ProductUnit> cartitesmList,
      List<ProductUnit> freeproducts,
      List<ProductUnit> cofferList,
      CardBloc cardBloc,
      DatabaseHelper dbHelper,
      CheckoutBloc checkoutbloc,
      int cartlistLength) {
    int selectedIndex = -1;
    updateCard(ProductUnit model, int index, var list) async {
      int status = await dbHelper.updateCard({
        DBConstants.PRODUCT_ID: int.parse(model.productId!),
        DBConstants.QUANTITY: model.addQuantity,
      });

      debugPrint("Update Product Status " + status.toString());

      cardBloc.add(CardUpdateQuantityEvent(
          quantity: model.addQuantity, index: index, listProduct: list));

      dbHelper.loadAddCardProducts(cardBloc);

      cardBloc.add(CardValidationLoadEvent(validationload: true));
    }

    calculateAmount(List<ProductUnit> list) {
      double subtotalshow = 0;
      double subtotalcross = 0;

      for (var dummyData in list) {
        if (dummyData.specialPrice == "Free") {
        } else {
          // dummyData.price ?? "0.0" added by Rohit before it was "0.0"
          var sortPrice = (double.parse(dummyData.sortPrice == null ||
                          dummyData.sortPrice == "null" ||
                          dummyData.sortPrice == ""
                      ? "0.0"
                      : dummyData.sortPrice!) *
                  dummyData.addQuantity)
              .toString();
          var specialPrice = (double.parse(
                      dummyData.specialPrice.toString() == null ||
                              dummyData.specialPrice.toString() == "null" ||
                              dummyData.specialPrice.toString() == ""
                          ? "0.0"
                          : dummyData.specialPrice!.toString()) *
                  dummyData.addQuantity)
              .toString();
          var price = (double.parse(dummyData.price == null ||
                          dummyData.price == "null" ||
                          dummyData.price == ""
                      ? "0.0"
                      : dummyData.price!) *
                  dummyData.addQuantity)
              .toString();
          var crossprice = dummyData.specialPrice == null ||
                  dummyData.specialPrice == "null" ||
                  dummyData.specialPrice == ""
              ? "₹ ${double.parse(price).toStringAsFixed(2)}"
              : "₹ ${double.parse(price).toStringAsFixed(2)}";
          var showprice = dummyData.specialPrice == null ||
                  dummyData.specialPrice == "null" ||
                  dummyData.specialPrice == ""
              ? "₹ ${double.parse(sortPrice).toStringAsFixed(2)}"
              : "₹ ${double.parse(specialPrice).toStringAsFixed(2)}";

          subtotalshow =
              subtotalshow + double.parse(showprice.replaceAll('₹ ', ""));
          // print("GauravEvent>>>>>>>>>>>>>>>>>>>>>>> 2 $showprice");
          // print("GauravEvent>>>>>>>>>>>>>>>>>>>>>>> 2 $crossprice");

          if (showprice != crossprice) {
            subtotalcross =
                subtotalcross + double.parse(crossprice.replaceAll('₹ ', ""));
          }

          // subtotalcross =
          //     subtotalcross + double.parse(crossprice.replaceAll('₹ ', ""));
        }
      }

      // print("GauravEvent>>>>>>>>>>>>>>>>>>>>>>> 2");

      checkoutbloc.add(CheckoutPriceUpdateEvent(
          subtotoal: subtotalshow, subtotoalcross: subtotalcross));
    }

    return BlocProvider(
      create: (context) => cardBloc,
      child: BlocBuilder(
          bloc: cardBloc,
          builder: (context, state) {
            if (state is CardAddcOfferProdutsState) {
              cartitesmList.add(state.unit);
            }

            if (state is AddCardState) {
              //count= state.count;
            }
            if (state is AddCardProductState) {
              cartitesmList = state.listProduct;
              calculateAmount(state.listProduct);
              // for(var x in freeproducts)
              // {
              //   cartitesmList.add(x);
              // }

              for (var x in cofferList) {
                if (cartitesmList.contains(x) == false) {
                  cartitesmList.add(x);
                  log("coffersProducts" + x.toJson());
                }
              }
            }

            if (state is CardUpdateQuanitiyState) {
              debugPrint(" CARD UPDATE ${state.listProduct.length}");

              cartitesmList = state.listProduct;
              calculateAmount(state.listProduct);
              for (var x in freeproducts) {
                cartitesmList.add(x);
              }
            }
            // if (cartitesmList.isEmpty) {
            //   return Container(
            //     height: 0,
            //   );
            // }
            if (state is CardEmptyState) {
              return Container(
                height: 0,
              );
            }
            if (state is CardDeleteSatate) {
              debugPrint("CardDeleteSatate >>>>>  ${state.listProduct.length}");
              cartitesmList = state.listProduct;
              calculateAmount(state.listProduct);
              for (var x in freeproducts) {
                cartitesmList.add(x);
              }
            }

            return Container(
                width: Sizeconfig.getWidth(context),
                //   height: Sizeconfig.getHeight(context)*0.30,
                child: cartitesmList.isEmpty
                    ? Shimmerui.cartproductListUi(context)
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: cartlistLength,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          var dummyData = cartitesmList[index];

                          if (state is CardUpdateQuanitiyState) {
                            debugPrint("CardUpdateQuantity");
                            cartitesmList[state.index].addQuantity =
                                state.quantity;
                          }

                          return ProductDetailsUIFinal(
                              context, dummyData, null, 0, () {
                            dummyData.addQuantity = dummyData.addQuantity + 1;

                            updateCard(dummyData, index, cartitesmList);
                          }, () async {
                            if (dummyData.addQuantity == 1) {
                              dummyData.addQuantity = 0;
                              await dbHelper
                                  .deleteCard(int.parse(dummyData.productId!))
                                  .then((value) {
                                debugPrint("Delete Product $value ");
                                cardBloc.add(CardDeleteEvent(
                                    model: cartitesmList[index],
                                    listProduct: cartitesmList));
                                dbHelper.loadAddCardProducts(cardBloc);

                                cartitesmList.removeAt(index);

                                if (cartitesmList.length == 0) {
                                  cardBloc.add(CardEmptyEvent());
                                  Navigator.pop(context);
                                }
                              });
                            } else if (dummyData.addQuantity != 0) {
                              dummyData.addQuantity = dummyData.addQuantity - 1;

                              updateCard(dummyData, index, cartitesmList);
                            }
                          }, () async {
                            dummyData.addQuantity = 0;

                            cardBloc.add(CardDeleteEvent(
                                model: cartitesmList[index],
                                listProduct: cartitesmList));
                            dbHelper.loadAddCardProducts(cardBloc);

                            cartitesmList.removeAt(index);

                            if (cartitesmList.length == 0) {
                              cardBloc.add(CardEmptyEvent());
                              Navigator.pop(context);
                            }
                          }, checkoutbloc);
                        }));
          }),
    );
  }

  static ProductDetailsUI(
      BuildContext context,
      ProductUnit dummyData,
      dynamic state,
      int index,
      Function increase,
      Function decrease,
      Function delete,
      CheckoutBloc checkoutbloc) {
    var sortPrice = (double.parse(dummyData.sortPrice == null ||
                    dummyData.sortPrice == "" ||
                    dummyData.sortPrice == "null"
                ? "0.0"
                : dummyData.sortPrice!) *
            dummyData.addQuantity)
        .toString();
    var specialPrice = (double.parse(dummyData.specialPrice == null ||
                    dummyData.specialPrice == "null" ||
                    dummyData.specialPrice == "" ||
                    dummyData.specialPrice == "Free"
                ? "0.0"
                : dummyData.specialPrice!) *
            dummyData.addQuantity)
        .toString();
    var price = (double.parse(dummyData.price == null ||
                    dummyData.price == "null" ||
                    dummyData.price == "" ||
                    dummyData.price == "Free"
                ? "0.0"
                : dummyData.price!) *
            dummyData.addQuantity)
        .toString();
    var crossprice = dummyData.specialPrice == ""
        ? ""
        : "₹ ${double.parse(price).toStringAsFixed(2)}";
    var showprice = dummyData.specialPrice == ""
        ? "₹ ${double.parse(sortPrice ?? "0.0").toStringAsFixed(2)}"
        : "₹ ${double.parse(specialPrice).toStringAsFixed(2)}";

    // Show unit price only

    var sortPrice2 = (double.parse(dummyData.sortPrice == null ||
                dummyData.sortPrice == "null" ||
                dummyData.sortPrice == "" ||
                dummyData.sortPrice == "null"
            ? "0.0"
            : dummyData.sortPrice!))
        .toString();
    var specialPrice2 = (double.parse(dummyData.specialPrice == null ||
                dummyData.specialPrice == "null" ||
                dummyData.specialPrice == "" ||
                dummyData.specialPrice == "Free"
            ? "0.0"
            : dummyData.specialPrice!))
        .toString();

    var showprice2 = dummyData.specialPrice == ""
        ? "₹ ${double.parse(sortPrice2 ?? "0.0").toStringAsFixed(2)}"
        : "₹ ${double.parse(specialPrice2).toStringAsFixed(2)}";

    return Container(
      padding: EdgeInsets.all(0),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        //height: 120,
        width: Sizeconfig.getWidth(context),
        // decoration: BoxDecoration(
        //   border:
        //       Border(top: BorderSide(color: ColorName.aquaHazeColor, width: 1)),
        // ),
        child: Container(
          child: Column(
            children: [
              Container(
                height: 1,
                color: ColorName.aquaHazeColor,
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: Sizeconfig.getWidth(context) * 0.02,
                          horizontal: Sizeconfig.getWidth(context) * 0.02),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          color: ColorName.white_card.withOpacity(0.2)),
                      child: CommonCachedImageWidget(
                        imgUrl: dummyData.image!,
                      ),
                    ),
                    flex: 2,
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                          left: Sizeconfig.getWidth(context) * 0.01),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 6,
                                child: Container(
                                  padding: EdgeInsets.only(right: 5),
                                  child: Text(
                                    dummyData.name!,
                                    maxLines: 2,
                                    style: TextStyle(
                                        letterSpacing: 0,
                                        fontSize: Constants.SizeSmall,
                                        fontFamily: Fontconstants.fc_family_sf,
                                        fontWeight: Fontconstants
                                            .SF_Pro_Display_SEMIBOLD,
                                        color: Colors.black),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: dummyData.specialPrice == "Free"
                                    ? Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          child: Appwidgets.TextMediumBold(
                                              dummyData.specialPrice == "Free"
                                                  ? "Free"
                                                  : "",
                                              ColorName.black),
                                        ),
                                      )
                                    :

                                    // Container(
                                    //   child: Appwidgets.TextSemiBold(
                                    //       "Qty : ${dummyData!.addQuantity ?? ""}",
                                    //       ColorName.ColorPrimary,
                                    //       TextAlign.right),
                                    // ),

                                    dummyData.addQuantity != 0
                                        ? Container(
                                            alignment: Alignment.topRight,
                                            child: Appwidgets.AddQuantityButton(
                                                StringContants.lbl_add,
                                                dummyData.addQuantity! as int,
                                                () {
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
                                        : Appwidgets().buttonPrimary(
                                            StringContants.lbl_add,
                                            () {
                                              dummyData.addQuantity =
                                                  dummyData.addQuantity + 1;
                                            },
                                          ),
                              ),
                            ],
                          ),
                          dummyData.price == "Free"
                              ? Container()
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 5),
                                      child: Text(
                                        dummyData.productWeight.toString()! +
                                            " ${dummyData.productWeightUnit}",
                                        style: TextStyle(
                                          fontSize: Constants.SizeSmall,
                                          fontFamily:
                                              Fontconstants.fc_family_sf,
                                          fontWeight:
                                              Fontconstants.SF_Pro_Display_Bold,
                                          color: ColorName.textlight,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          crossprice,
                                          style: TextStyle(
                                              fontSize: Constants.SizeSmall,
                                              fontFamily:
                                                  Fontconstants.fc_family_sf,
                                              fontWeight: Fontconstants
                                                  .SF_Pro_Display_Medium,
                                              letterSpacing: 0,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              decorationColor:
                                                  ColorName.textlight,
                                              color: ColorName.textlight),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                            flex: 0,
                                            child: Appwidgets.TextMediumBold(
                                                dummyData.specialPrice == "Free"
                                                    ? "Free"
                                                    : showprice,
                                                ColorName.black)),
                                      ],
                                    ),
                                  ],
                                ),
                          dummyData!.price == "Free" &&
                                  dummyData.subProduct!.cOfferInfo != ""
                              ? Container()
                              : Text(
                                  dummyData.specialPrice == "Free"
                                      ? crossprice
                                      : showprice2,
                                  style: TextStyle(
                                    fontSize: Constants.SizeSmall,
                                    fontFamily: Fontconstants.fc_family_sf,
                                    fontWeight:
                                        Fontconstants.SF_Pro_Display_Bold,
                                    color: ColorName.textlight,
                                  ),
                                ),
                          dummyData!.price == "Free" &&
                                  dummyData.subProduct!.cOfferInfo != ""
                              ? Container(
                                  margin: EdgeInsets.only(top: 10),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.green.shade400,
                                          width: 1),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0))),
                                  padding: EdgeInsets.all(5.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        Imageconstants.img_offer,
                                        height: 20,
                                        width: 20,
                                        color: Colors.green.shade400,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Appwidgets.TextRegular(
                                          dummyData.subProduct!.cOfferInfo! ??
                                              "",
                                          Colors.green.shade400),
                                    ],
                                  ),
                                )
                              : Container()
                        ],
                      ),
                    ),
                    flex: 8,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static ProductDetailsUIFinal(
      BuildContext context,
      ProductUnit dummyData,
      dynamic state,
      int index,
      Function increase,
      Function decrease,
      Function delete,
      CheckoutBloc checkoutbloc) {
    var sortPrice = (double.parse(dummyData.sortPrice == null ||
                    dummyData.sortPrice == "" ||
                    dummyData.sortPrice == "null"
                ? "0.0"
                : dummyData.sortPrice!) *
            dummyData.addQuantity)
        .toString();
    var specialPrice = (double.parse(
                dummyData.specialPrice.toString() == null ||
                        dummyData.specialPrice.toString() == "null" ||
                        dummyData.specialPrice.toString() == "" ||
                        dummyData.specialPrice.toString() == "Free"
                    ? "0.0"
                    : dummyData.specialPrice!.toString()) *
            dummyData.addQuantity)
        .toString();
    var price = (double.parse(dummyData.price == null ||
                    dummyData.price == "null" ||
                    dummyData.price.toString() == "" ||
                    dummyData.price.toString() == "Free"
                ? "0.0"
                : dummyData.price!.toString()) *
            dummyData.addQuantity)
        .toString();
    var crossprice = dummyData.specialPrice == ""
        ? ""
        : "₹ ${double.parse(price).toStringAsFixed(2)}";
    var showprice = dummyData.specialPrice == ""
        ? "₹ ${double.parse(sortPrice ?? "0.0").toStringAsFixed(2)}"
        : "₹ ${double.parse(specialPrice).toStringAsFixed(2)}";

    // Show unit price only

    var sortPrice2 = (double.parse(dummyData.sortPrice == null ||
                dummyData.sortPrice == "null" ||
                dummyData.sortPrice == ""
            ? "0.0"
            : dummyData.sortPrice!))
        .toString();
    var specialPrice2 = (double.parse(dummyData.specialPrice == null ||
                dummyData.specialPrice == "null" ||
                dummyData.specialPrice.toString() == "" ||
                dummyData.specialPrice.toString() == "Free"
            ? "0.0"
            : dummyData.specialPrice!.toString()))
        .toString();

    var showprice2 = dummyData.specialPrice == ""
        ? "₹ ${double.parse(sortPrice2 ?? "0.0").toStringAsFixed(2)}"
        : "₹ ${double.parse(specialPrice2).toStringAsFixed(2)}";
    return Container(
      padding: EdgeInsets.all(0),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        //height: 120,
        width: Sizeconfig.getWidth(context),
        decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: ColorName.aquaHazeColor, width: 2)),
        ),
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      vertical: Sizeconfig.getWidth(context) * 0.02,
                      horizontal: Sizeconfig.getWidth(context) * 0.02),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      color: ColorName.white_card.withOpacity(0.2)),
                  child: CommonCachedImageWidget(
                    imgUrl: dummyData.image!,
                  ),
                ),
              ),
              Expanded(
                flex: 8,
                child: Container(
                  margin: EdgeInsets.only(
                      left: Sizeconfig.getWidth(context) * 0.01),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: Container(
                              padding: EdgeInsets.only(right: 5),
                              child: Text(
                                "${dummyData.name!} ${dummyData.price}",
                                maxLines: 2,
                                style: TextStyle(
                                    letterSpacing: 0,
                                    fontSize: 13,
                                    fontFamily: Fontconstants.fc_family_sf,
                                    fontWeight:
                                        Fontconstants.SF_Pro_Display_SEMIBOLD,
                                    color: Colors.black),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: dummyData.specialPrice == "Free"
                                ? Align(
                                    alignment: Alignment.topRight,
                                    child: Column(
                                      children: [
                                        Container(
                                          child: Appwidgets.TextMediumBold(
                                              dummyData.specialPrice == "Free"
                                                  ? "Free"
                                                  : "",
                                              ColorName.black),
                                        ),
                                        Container(
                                          child: Appwidgets.TextSemiBold(
                                              "Qty : ${dummyData!.addQuantity ?? ""}",
                                              ColorName.ColorPrimary,
                                              TextAlign.right),
                                        )
                                      ],
                                    ),
                                  )
                                : Container(
                                    child: Appwidgets.TextSemiBold(
                                        "Qty : ${dummyData!.addQuantity ?? ""}",
                                        ColorName.ColorPrimary,
                                        TextAlign.right),
                                  ),

                            // dummyData.addQuantity != 0
                            //     ? Container(
                            //   alignment: Alignment.topRight,
                            //   child: Appwidgets.AddQuantityButton(
                            //       StringContants.lbl_add,
                            //       dummyData.addQuantity! as int, () {
                            //     if (dummyData.addQuantity ==
                            //         int.parse(dummyData.quantity!)) {
                            //       Fluttertoast.showToast(
                            //           msg: StringContants
                            //               .msg_quanitiy);
                            //     } else {
                            //       increase();
                            //     }
                            //   }, () {
                            //     decrease();
                            //   }),
                            // )
                            //     : Appwidgets().buttonPrimary(
                            //   StringContants.lbl_add,
                            //       () {
                            //     dummyData.addQuantity =
                            //         dummyData.addQuantity + 1;
                            //   },
                            // ),
                          ),
                        ],
                      ),
                      dummyData.price == "Free"
                          ? Container()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                    dummyData.productWeight.toString()! +
                                        " ${dummyData.productWeightUnit}",
                                    style: TextStyle(
                                      fontSize: Constants.SizeSmall,
                                      fontFamily: Fontconstants.fc_family_sf,
                                      fontWeight:
                                          Fontconstants.SF_Pro_Display_Bold,
                                      color: ColorName.textlight,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    showprice == "₹ 0.00"
                                        ? SizedBox.shrink()
                                        : Text(
                                            crossprice,
                                            style: TextStyle(
                                                fontSize: Constants.SizeSmall,
                                                fontFamily:
                                                    Fontconstants.fc_family_sf,
                                                fontWeight: Fontconstants
                                                    .SF_Pro_Display_Medium,
                                                letterSpacing: 0,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                decorationColor:
                                                    ColorName.textlight,
                                                color: ColorName.textlight),
                                          ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                        flex: 0,
                                        child: Appwidgets.TextMediumBold(
                                            dummyData.specialPrice == "Free"
                                                ? ""
                                                : showprice == "₹ 0.00"
                                                    ? crossprice
                                                    : showprice,
                                            ColorName.black)),
                                  ],
                                ),
                              ],
                            ),
                      dummyData!.price == "Free" &&
                              dummyData.subProduct!.cOfferInfo != ""
                          ? Container()
                          : Text(
                              dummyData.specialPrice == "Free"
                                  ? crossprice
                                  : showprice == "₹ 0.00"
                                      ? crossprice
                                      : showprice2,
                              style: TextStyle(
                                fontSize: Constants.SizeSmall,
                                fontFamily: Fontconstants.fc_family_sf,
                                fontWeight: Fontconstants.SF_Pro_Display_Bold,
                                color: ColorName.textlight,
                              ),
                            ),
                      dummyData!.price == "Free" &&
                              dummyData.subProduct!.cOfferInfo != ""
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: Sizeconfig.getWidth(context) * 0.6,
                                  margin: EdgeInsets.only(top: 15),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.green.shade400,
                                          width: 1),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0))),
                                  padding: EdgeInsets.all(3.0),
                                  child: Marquee(
                                    autoRepeat: true,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          Imageconstants.img_offer,
                                          height: 13,
                                          width: 13,
                                          color: Colors.green.shade400,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Appwidgets.Text_10_Regular(
                                            dummyData.subProduct!.cOfferInfo! ??
                                                "",
                                            Colors.green.shade400),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(),
                              ],
                            )
                          : Container()
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<int> getCartQuantity(String id) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    await dbHelper.init();
    final allRows = await dbHelper.queryAllRowsCardProducts();
    for (final row in allRows) {
      String id2 = row[DBConstants.PRODUCT_ID].toString();

      if (id == id2) {
        return row[DBConstants.QUANTITY];
      }
    }
    return 0;
  }

  static similarProductsUI(
      bool fromchekcout,
      BuildContext context,
      dynamic state,
      List<ProductData>? list,
      FeaturedBloc bloc,
      int isMoreUnitIndex,
      CardBloc cardBloc,
      DatabaseHelper dbHelper,
      ScrollController _scrollController,
      bool loadMore) {
    debugPrint("similarProductsUI  ${list!.length} ${loadMore}");

    return state is ShopByCategoryErrorState
        ? Center(
            child: Text(
              state.errorMessage,
              style: Appwidgets().commonTextStyle(ColorName.black),
            ),
          )
        : list!.isEmpty
            ? Container()
            : BlocProvider(
                create: (context) => bloc,
                child: BlocBuilder<FeaturedBloc, FeaturedState>(
                    bloc: bloc,
                    builder: (context, state) {
                      debugPrint("Featured Product State  " + state.toString());

                      if (state is ProductForShopByState) {
                        list = state.list!;
                        debugPrint(
                            "LoadedFeaturedState  ${state.list!.length.toString()}");

                        for (int index = 0; index < list!.length; index++) {
                          var newmodel = list![index].unit![0];
                          getCartQuantity(newmodel.productId!).then((value) {
                            debugPrint("getCartQuanity $value");

                            if (value > 0) {
                              debugPrint(
                                  "getCartQuanity name  ${list![index].unit![0].name}");
                            }
                            list![index].unit![0].addQuantity = value;
                            bloc.add(ProductUpdateQuantityInitial(list: list));
                          });

                          if (newmodel!.cOfferId != 0 &&
                              newmodel.cOfferId != null) {
                            debugPrint("***********************");
                            if (newmodel.subProduct != null) {
                              log("***********************>>>>>>>>>>>>>>>>" +
                                  newmodel.subProduct!.toJson());
                              if (newmodel
                                      .subProduct!.subProductDetail!.length >
                                  0) {
                                list![index]
                                        .unit![0]
                                        .subProduct!
                                        .subProductDetail =
                                    MyUtility.checkOfferSubProductLoad(
                                        newmodel, dbHelper);
                              }
                            }
                          }

                          if (list![index].unit!.length > 1) {
                            for (int i = 0;
                                i < list![index].unit!.length;
                                i++) {
                              getCartQuantity(list![index].unit![i].productId!)
                                  .then((value) {
                                debugPrint("getCartQuanity $value");
                                list![index].unit![i].addQuantity = value;
                                bloc.add(
                                    ProductUpdateQuantityInitial(list: list));
                              });
                            }
                          }
                        }
                      }

                      if (state is LoadedFeaturedState) {
                        for (int index = 0; index < list!.length; index++) {
                          var newmodel = list![index].unit![0];
                          getCartQuantity(newmodel.productId!).then((value) {
                            debugPrint("getCartQuanity $value");

                            if (value > 0) {
                              debugPrint(
                                  "getCartQuanity name  ${list![index].unit![0].name}");
                            }
                            list![index].unit![0].addQuantity = value;
                            bloc.add(ProductUpdateQuantityInitial(list: list));
                          });

                          if (newmodel!.cOfferId != 0 &&
                              newmodel.cOfferId != null) {
                            debugPrint("***********************");
                            if (newmodel.subProduct != null) {
                              log("***********************>>>>>>>>>>>>>>>>" +
                                  newmodel.subProduct!.toJson());
                              if (newmodel
                                      .subProduct!.subProductDetail!.length >
                                  0) {
                                list![index]
                                        .unit![0]
                                        .subProduct!
                                        .subProductDetail =
                                    MyUtility.checkOfferSubProductLoad(
                                        newmodel, dbHelper);
                              }
                            }
                          }

                          if (list![index].unit!.length > 1) {
                            for (int i = 0;
                                i < list![index].unit!.length;
                                i++) {
                              getCartQuantity(list![index].unit![i].productId!)
                                  .then((value) {
                                debugPrint("getCartQuanity $value");
                                list![index].unit![i].addQuantity = value;
                                bloc.add(
                                    ProductUpdateQuantityInitial(list: list));
                              });
                            }
                          }
                        }
                      }

                      // For Manage card list product Quanityt
                      if (state is ProductUpdateQuantityInitialState) {
                        list = state.list!;
                      }

                      return Container(
                          height: Sizeconfig.getHeight(context) * 0.35,
                          color: Colors.white,
                          // padding: const EdgeInsets.only(top: 10),
                          child: ListView.builder(
                              controller: _scrollController,
                              shrinkWrap: true,
                              itemCount: list!.length,

                              // itemBuilder: (context, index) {

                              //
                              //   return categoryItemView2(
                              //       context, dummyData, null, index, isMoreunit,bloc,list,isMoreUnitIndex,dbHelper, cardBloc);
                              // },

                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                var dummyData = list![index].unit![0];

                                bool isMoreunit = false;

                                debugPrint(
                                    "GGGGG  $index  =>  ${list![index].unit!.length.toString()}");
                                if (list![index].unit!.length > 1) {
                                  isMoreunit = true;
                                }

                                if (state
                                    is ProductUpdateQuantityStateBYModel) {
                                  debugPrint("LIST Featured Product State  " +
                                      state.toString());

                                  if (dummyData.productId ==
                                      state.model.productId) {
                                    debugPrint(
                                        "MATCH Featured Product State  " +
                                            state.toString());
                                    dummyData.addQuantity =
                                        state.model.addQuantity;
                                  }
                                }
                                if (state is ProductChangeState) {
                                  if (isMoreunit) {
                                    for (var obj in list![index].unit!) {
                                      if (obj.name == state.model.name) {
                                        dummyData = state.model;

                                        debugPrint("G>>>>>>    " +
                                            state.model.addQuantity.toString());

                                        debugPrint("G>>>>>>Index    " +
                                            isMoreUnitIndex.toString());
                                      }
                                    }
                                  } else {
                                    for (var obj in list![index].unit!) {
                                      if (obj.name == state.model.name ||
                                          obj.productId ==
                                              state.model.productId) {
                                        debugPrint("G>>>>>>>>>>>>>>>>>>>>    " +
                                            state.model.addQuantity.toString());

                                        debugPrint("G>>>>>>Index    " +
                                            isMoreUnitIndex.toString());

                                        if (dummyData!.cOfferId != 0 &&
                                            dummyData.cOfferId != null) {
                                          debugPrint(
                                              "##***********************");
                                          if (dummyData.subProduct != null) {
                                            log("##***********************>>>>>>>>>>>>>>>>" +
                                                dummyData.subProduct!.toJson());

                                            dummyData = MyUtility
                                                .checkOfferSubProductUpdate(
                                                    dummyData,
                                                    state.model,
                                                    dbHelper);
                                          }
                                        } else {
                                          dummyData = state.model;
                                        }
                                      } else {
                                        // For sub products
                                        debugPrint(
                                            "##****" + state!.model!.name!);

                                        if (dummyData!.cOfferId != 0 &&
                                            dummyData.cOfferId != null) {
                                          debugPrint(
                                              "##***********************");
                                          if (dummyData.subProduct != null) {
                                            log("##***********************>>>>>>>>>>>>>>>>" +
                                                dummyData.subProduct!.toJson());
                                            if (dummyData.subProduct!
                                                    .subProductDetail!.length >
                                                0) {
                                              List<ProductUnit>?
                                                  listsubproduct = dummyData
                                                      .subProduct!
                                                      .subProductDetail!;

                                              for (int x = 0;
                                                  x < listsubproduct.length;
                                                  x++) {
                                                getCartQuantity(
                                                        listsubproduct[x]
                                                            .productId!)
                                                    .then((value) {
                                                  debugPrint(
                                                      "${listsubproduct[x].name} Sub Product Quantity quanityt ${value}");
                                                  listsubproduct[x]
                                                      .addQuantity = value;
                                                });
                                              }

                                              dummyData.subProduct!
                                                      .subProductDetail =
                                                  listsubproduct;
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                                return Stack(
                                  children: [
                                    Padding(
                                      padding: (index == list!.length - 1)
                                          ? const EdgeInsets.only(right: 7)
                                          : index == 0
                                              ? const EdgeInsets.only(left: 7)
                                              : EdgeInsets.symmetric(
                                                  horizontal: 0, vertical: 0),
                                      child: Row(
                                        children: [
                                          Card(
                                            elevation: 1,
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: Row(
                                              children: [
                                                Stack(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () async {
                                                        for (int i = 0;
                                                            i <
                                                                list![index]
                                                                    .unit!
                                                                    .length!;
                                                            i++) {
                                                          debugPrint(
                                                              "Model  ${dummyData.productId} ${dummyData.addQuantity} ");
                                                          if (dummyData
                                                                  .productId ==
                                                              list![index]
                                                                  .unit![i]
                                                                  .productId!) {
                                                            list![index]
                                                                    .unit![i] =
                                                                dummyData;
                                                            isMoreUnitIndex = i;
                                                          }
                                                          debugPrint(
                                                              "DATA Model  ${list![index].unit![i].productId!}  ${list![index].unit![i].addQuantity!}");
                                                        }

                                                        await Navigator
                                                            .pushNamed(
                                                          context,
                                                          Routes
                                                              .product_Detail_screen,
                                                          arguments: {
                                                            'fromchekcout':
                                                                fromchekcout,
                                                            'list': list![index]
                                                                .unit!,
                                                            'index': isMoreunit
                                                                ? isMoreUnitIndex
                                                                : index,
                                                          },
                                                        ).then((value) async {
                                                          ProductUnit unit =
                                                              value
                                                                  as ProductUnit;
                                                          debugPrint(
                                                              "FeatureCallback ${value.addQuantity}");

                                                          OndoorThemeData
                                                              .setStatusBarColor();
                                                          bloc.add(ProductUpdateQuantityEvent(
                                                              quanitity: unit
                                                                  .addQuantity!,
                                                              index: index));
                                                        });
                                                      },
                                                      child: Container(
                                                        width:
                                                            Sizeconfig.getWidth(
                                                                    context) *
                                                                0.40,
                                                        //padding: EdgeInsets.all(4),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Expanded(
                                                              flex: 5,
                                                              child: Stack(
                                                                children: [
                                                                  Container(
                                                                    height: Sizeconfig
                                                                        .getWidth(
                                                                            context),
                                                                    width: Sizeconfig
                                                                        .getWidth(
                                                                            context),
                                                                    child:
                                                                        Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .bottomCenter,
                                                                      child:
                                                                          Container(
                                                                        height: Sizeconfig.getWidth(context) *
                                                                            .27,
                                                                        width: Sizeconfig.getWidth(context) *
                                                                            .27,
                                                                        child:
                                                                            CommonCachedImageWidget(
                                                                          imgUrl:
                                                                              dummyData.image!,
                                                                          width:
                                                                              Sizeconfig.getWidth(context) * .27,
                                                                          height:
                                                                              Sizeconfig.getWidth(context) * .27,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Positioned(
                                                                      bottom: 5,
                                                                      right: 5,
                                                                      child: (dummyData!.cOfferId != 0 &&
                                                                              dummyData.cOfferId != null)
                                                                          ? InkWell(
                                                                              onTap: () {
                                                                                List<ProductUnit> subProductsDetailsList = dummyData!.subProduct!.subProductDetail!;

                                                                                print("model quantity ${dummyData.addQuantity}");
                                                                                SubProduct subproducts = dummyData.subProduct!;

                                                                                for (int i = 0; i < subProductsDetailsList.length; i++) {
                                                                                  SubProduct subproduct = SubProduct();
                                                                                  subproduct.cOfferInfo = subproducts!.cOfferInfo;
                                                                                  subproduct.getQty = subproducts!.getQty;
                                                                                  subproduct.discType = subproducts!.discType;
                                                                                  subproduct.discAmt = subproducts!.discAmt;
                                                                                  subproduct.cOfferAvail = subproducts!.cOfferAvail;
                                                                                  subproduct.cOfferApplied = subproducts!.cOfferApplied;
                                                                                  subproduct.offerProductId = subproducts!.offerProductId;
                                                                                  subproduct.offerWarning = subproducts!.offerWarning;
                                                                                  List<ProductUnit>? subProductDetail = [];
                                                                                  for (var x in subproducts!.subProductDetail!) {
                                                                                    ProductUnit y = ProductUnit();
                                                                                    y.productId = x.productId;
                                                                                    y.quantity = x.quantity;
                                                                                    y.image = x.image;
                                                                                    y.price = x.specialPrice;
                                                                                    y.subProduct = x.subProduct;
                                                                                    y.model = x.model;
                                                                                    y.name = x.name;

                                                                                    subProductDetail.add(y);
                                                                                  }
                                                                                  subproduct.subProductDetail = subProductDetail;
                                                                                  subProductsDetailsList[i].subProduct = subproduct;
                                                                                  subProductsDetailsList[i].subProduct!.buyQty = dummyData!.subProduct!.buyQty;
                                                                                  subProductsDetailsList[i].cOfferId = dummyData.cOfferId;
                                                                                  subProductsDetailsList[i].discountLabel = dummyData.discountLabel;
                                                                                  subProductsDetailsList[i].discountText = dummyData.discountText;
                                                                                  subProductsDetailsList[i].cOfferType = dummyData.cOfferType;
                                                                                  debugPrint("GGGGGG" + dummyData.subProduct!.cOfferInfo!);
                                                                                  debugPrint("GGGGGGGG" + subProductsDetailsList[i].subProduct!.cOfferInfo!);
                                                                                }

                                                                                Appwidgets.showSubProductsOffer(
                                                                                    int.parse(dummyData!.subProduct!.buyQty! ?? "0"),
                                                                                    dummyData!.subProduct!.cOfferApplied!,
                                                                                    dummyData!.subProduct!.cOfferInfo!,
                                                                                    dummyData!.subProduct!.offerWarning!,
                                                                                    context,
                                                                                    cardBloc,
                                                                                    // model!.subProduct!.subProductDetail!,
                                                                                    subProductsDetailsList,
                                                                                    bloc,
                                                                                    ShopByCategoryBloc(), () {
                                                                                  debugPrint('Refresh call >>  ');

                                                                                  // loadFeatureProduct();
                                                                                  // searchProduct(searchController.text);
                                                                                }, (value) {});
                                                                              },
                                                                              child: Image.asset(
                                                                                Imageconstants.img_gifoffer2,
                                                                                height: 20,
                                                                                width: 20,
                                                                              ))
                                                                          : Container())
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                                flex: 5,
                                                                child:
                                                                    Container(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              8),
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      // Text(
                                                                      //   dummyData.name!,
                                                                      //   maxLines: 2,
                                                                      //   style: TextStyle(
                                                                      //     fontSize: 12,
                                                                      //     fontFamily: Fontconstants.fc_family_sf,
                                                                      //     fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
                                                                      //     color: textcolor,
                                                                      //   ),
                                                                      // ),
                                                                      // ),
                                                                      1.toSpace,
                                                                      CommanTextWidget
                                                                          .regularBold(
                                                                        dummyData
                                                                            .name!,
                                                                        Colors
                                                                            .black,
                                                                        maxline:
                                                                            2,
                                                                        trt:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          height:
                                                                              1.25,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                        textalign:
                                                                            TextAlign.start,
                                                                      ),
                                                                      /*           InkWell(
                                                                        onTap: () {
                                                                          if (isMoreunit) {
                                                                            MyDialogs.optionDialog(context, list![index].unit!, dummyData).then((value) {
                                                                              isMoreUnitIndex = list![index].unit!.indexWhere((model) => model == value);
                                                                              value.selectedUnitIndex = isMoreUnitIndex;
                                                                              debugPrint("Dialog value ${index} ${value.name} ");

                                                                              for (int i = 0; i < list![index].unit!.length; i++) {
                                                                                if (list![index].unit![i].productId == value.productId) {
                                                                                  list![index].unit![i].isselectUnit = true;
                                                                                  value.isselectUnit = true;
                                                                                } else {
                                                                                  list![index].unit![i].isselectUnit = false;
                                                                                }
                                                                              }

                                                                              bloc.add(ProductChangeEvent(model: value));
                                                                            });
                                                                          }
                                                                        },
                                                                        child: Container(
                                                                          child: Container(
                                                                            // margin: isMoreunit ? EdgeInsets.only(top: 5) : null,

                                                                            width: Sizeconfig.getWidth(context) * .20,
                                                                            child: Align(
                                                                              alignment: Alignment.center,
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                children: [
                                                                                  // Text(
                                                                                  //   dummyData.productWeight.toString() + " ${dummyData.productWeightUnit}",
                                                                                  //   style: TextStyle(
                                                                                  //     fontSize: 11,
                                                                                  //     fontFamily: Fontconstants.fc_family_sf,
                                                                                  //     fontWeight: Fontconstants.SF_Pro_Display_Bold,
                                                                                  //     color: textsecondary,
                                                                                  //   ),
                                                                                  // ),

                                                                                  CommanTextWidget.regularBold (
                                                                                      dummyData.productWeight.toString() + " ${dummyData.productWeightUnit}",
                                                                                      textsecondary,
                                                                                      maxline: 1,
                                                                                      trt: TextStyle(
                                                                                        fontSize: 14,
                                                                                        height: 1,

                                                                                        fontWeight: FontWeight.w600,),
                                                                                      textalign: TextAlign.start,
                                                                                  ),
                                                                                  10.toSpace,
                                                                                  Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: [
                                                                                      Visibility(
                                                                                          visible: isMoreunit,
                                                                                          child: Container(
                                                                                            width: 8,
                                                                                            height: 8,
                                                                                            child: Image.asset(
                                                                                              Imageconstants.img_dropdownarrow,
                                                                                              color: ColorName.textsecondary,
                                                                                            ),
                                                                                          )),
                                                                                    ],
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),*/



                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Container(
                                                                            child:
                                                                                InkWell(
                                                                              onTap: () {
                                                                                if (isMoreunit) {
                                                                                  MyDialogs.optionDialog(context, list![index].unit!, dummyData).then((value) {
                                                                                    isMoreUnitIndex = list![index].unit!.indexWhere((model) => model == value);
                                                                                    value.selectedUnitIndex = isMoreUnitIndex;
                                                                                    debugPrint("Dialog value ${index} ${value.name} ");

                                                                                    for (int i = 0; i < list![index].unit!.length; i++) {
                                                                                      if (list![index].unit![i].productId == value.productId) {
                                                                                        list![index].unit![i].isselectUnit = true;
                                                                                        value.isselectUnit = true;
                                                                                      } else {
                                                                                        list![index].unit![i].isselectUnit = false;
                                                                                      }
                                                                                    }

                                                                                    bloc.add(ProductChangeEvent(model: value));
                                                                                  });
                                                                                }
                                                                              },
                                                                              child: isMoreunit
                                                                                  ? Container(
                                                                                      height: 20,
                                                                                      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(4.0)), border: Border.all(width: 0.6, color: ColorName.border.withOpacity(0.5))),
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                        children: [
                                                                                          Container(
                                                                                              padding: EdgeInsets.symmetric(horizontal: 8),
                                                                                              child: CommanTextWidget.regularBold(
                                                                                                dummyData.productWeight.toString() + " ${dummyData.productWeightUnit}",
                                                                                                ColorName.textsecondary,
                                                                                                maxline: 2,
                                                                                                trt: TextStyle(
                                                                                                  fontSize: 14,
                                                                                                  fontWeight: FontWeight.w600,
                                                                                                ),
                                                                                                textalign: TextAlign.start,
                                                                                              )),
                                                                                          5.toSpace,
                                                                                          Visibility(
                                                                                              visible: isMoreunit,
                                                                                              child: Container(
                                                                                                decoration: BoxDecoration(
                                                                                                  color: ColorName.ColorPrimary,
                                                                                                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                                                                                ),
                                                                                                width: 20,
                                                                                                height: 20,
                                                                                                padding: EdgeInsets.all(5),
                                                                                                child: Image.asset(
                                                                                                  Imageconstants.img_dropdownarrow,
                                                                                                  color: Colors.white,
                                                                                                  height: 10,
                                                                                                  width: 10,
                                                                                                ),
                                                                                              ))
                                                                                        ],
                                                                                      ),
                                                                                    )
                                                                                  : CommanTextWidget.regularBold(
                                                                                      dummyData.productWeight.toString() + " ${dummyData.productWeightUnit}",
                                                                                      ColorName.textsecondary,
                                                                                      maxline: 2,
                                                                                      trt: TextStyle(
                                                                                        fontSize: 14,
                                                                                        fontWeight: FontWeight.w600,
                                                                                      ),
                                                                                      textalign: TextAlign.start,
                                                                                    ),
                                                                            ),
                                                                          ),
                                                                          Container()
                                                                        ],
                                                                      ),
                                                                      2.toSpace,
                                                                      Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Align(
                                                                            alignment:
                                                                                Alignment.bottomLeft,
                                                                            child:
                                                                                Container(
                                                                              padding: EdgeInsets.only(bottom: 5),
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [



                                                                                  Container(
                                                                                    child: CommanTextWidget.regularBold(
                                                                                      dummyData.specialPrice == "" ? "" : "₹${double.parse(dummyData.price!).toStringAsFixed(2)}",
                                                                                      ColorName.black,
                                                                                      maxline: 1,
                                                                                      trt: TextStyle(
                                                                                        fontSize: 10,
                                                                                        decoration: TextDecoration.lineThrough,
                                                                                        decorationColor: ColorName.black,
                                                                                        fontWeight: FontWeight.w500,
                                                                                      ),
                                                                                      textalign: TextAlign.start,
                                                                                    ),
                                                                                  ),



                                                                                  CommanTextWidget.regularBold(
                                                                                    dummyData.specialPrice == "" ? "₹ ${double.parse(dummyData.sortPrice!).toStringAsFixed(2)}" : "₹ ${double.parse(dummyData.specialPrice!).toStringAsFixed(2)}",
                                                                                    Colors.black,
                                                                                    maxline: 1,
                                                                                    trt: TextStyle(
                                                                                      fontSize: Constants.SizeMidium,
                                                                                      height: 1,
                                                                                      fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                    textalign: TextAlign.start,
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    ],
                                                                  ),
                                                                )),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      right: 5,
                                                      bottom: 7,
                                                      child: Container(
                                                          height: Sizeconfig
                                                                  .getWidth(
                                                                      context) *
                                                              0.08,
                                                          child: dummyData
                                                                      .addQuantity !=
                                                                  0
                                                              ? Uistyle.AddQuantityButton(
                                                                  ColorName
                                                                      .ColorPrimary,
                                                                  Colors.white,
                                                                  StringContants
                                                                      .lbl_add,
                                                                  dummyData
                                                                          .addQuantity!
                                                                      as int,
                                                                  () {
                                                                  //increase

                                                                  if (dummyData
                                                                          .addQuantity ==
                                                                      int.parse(dummyData
                                                                          .orderQtyLimit!
                                                                          .toString()!)) {
                                                                    Fluttertoast
                                                                        .showToast(
                                                                            msg:
                                                                                StringContants.msg_quanitiy);
                                                                  } else {
                                                                    dummyData
                                                                            .addQuantity =
                                                                        dummyData.addQuantity +
                                                                            1;
                                                                    bloc.add(ProductUpdateQuantityEvent(
                                                                        quanitity:
                                                                            dummyData
                                                                                .addQuantity!,
                                                                        index:
                                                                            index));
                                                                    bloc.add(ProductChangeEvent(
                                                                        model:
                                                                            dummyData));
                                                                    updateCard(
                                                                        dummyData,
                                                                        dbHelper,
                                                                        cardBloc);
                                                                    debugPrint(
                                                                        "Scroll Event1111 ");
                                                                  }
                                                                }, () async {
                                                                  if (dummyData
                                                                          .addQuantity ==
                                                                      1) {
                                                                    debugPrint(
                                                                        "SHOPBY 1");
                                                                    dummyData
                                                                        .addQuantity = 0;

                                                                    bloc.add(ProductUpdateQuantityEventBYModel(
                                                                        model:
                                                                            dummyData));

                                                                    await dbHelper
                                                                        .deleteCard(int.parse(dummyData
                                                                            .productId!))
                                                                        .then(
                                                                            (value) {
                                                                      debugPrint(
                                                                          "Delete Product $value ");

                                                                      // cardBloc.add(CardDeleteEvent(
                                                                      //     model: model,
                                                                      //     listProduct:  list![0].unit!));

                                                                      dbHelper.loadAddCardProducts(
                                                                          cardBloc);
                                                                    });
                                                                  } else if (dummyData
                                                                          .addQuantity !=
                                                                      0) {
                                                                    debugPrint(
                                                                        "SHOPBY 2");
                                                                    dummyData
                                                                            .addQuantity =
                                                                        dummyData.addQuantity -
                                                                            1;

                                                                    updateCard(
                                                                        dummyData,
                                                                        dbHelper,
                                                                        cardBloc);
                                                                    bloc.add(ProductUpdateQuantityEventBYModel(
                                                                        model:
                                                                            dummyData));

                                                                    bloc.add(ProductChangeEvent(
                                                                        model:
                                                                            dummyData));
                                                                  }
                                                                })
                                                              : Uistyle
                                                                  .buttonPrimary(
                                                                  ColorName
                                                                      .ColorPrimary,
                                                                  Colors.white,
                                                                  StringContants
                                                                      .lbl_add,
                                                                  () {
                                                                    dummyData
                                                                            .addQuantity =
                                                                        dummyData.addQuantity +
                                                                            1;
                                                                    checkItemId(
                                                                            dummyData
                                                                                .productId!,
                                                                            dbHelper)
                                                                        .then(
                                                                            (value) {
                                                                      debugPrint(
                                                                          "CheckItemId $value");

                                                                      if (value ==
                                                                          false) {
                                                                        addCard(
                                                                            dummyData,
                                                                            dbHelper,
                                                                            cardBloc);
                                                                      } else {
                                                                        updateCard(
                                                                            dummyData,
                                                                            dbHelper,
                                                                            cardBloc);
                                                                      }
                                                                    });

                                                                    bloc.add(ProductUpdateQuantityEvent(
                                                                        quanitity:
                                                                            dummyData
                                                                                .addQuantity!,
                                                                        index:
                                                                            index));
                                                                    bloc.add(ProductChangeEvent(
                                                                        model:
                                                                            dummyData));
                                                                  },
                                                                )),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          loadMore == false
                                              ? Container()
                                              : index != (list!.length - 1)
                                                  ? Container()
                                                  : Container(
                                                      height: 30,
                                                      width: 30,
                                                      margin: EdgeInsets.only(
                                                          left: 10),
                                                      child: list!.length < 3
                                                          ? Container()
                                                          : CircularProgressIndicator(
                                                              color: ColorName
                                                                  .ColorPrimary,
                                                            ))
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      top: 2,
                                      left: 3,
                                      child: Padding(
                                        padding: index == 0
                                            ? const EdgeInsets.only(left: 7)
                                            : EdgeInsets.symmetric(
                                                horizontal: 0, vertical: 0),
                                        child: (dummyData.discountText ?? "") ==
                                                ""
                                            ? Container()
                                            : Visibility(
                                                visible: (dummyData
                                                            .discountText !=
                                                        "" ||
                                                    dummyData.discountText !=
                                                        null),
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(
                                                                      10)),
                                                      child: Image.asset(
                                                        Imageconstants.img_tag,
                                                        height: 40,
                                                        width: 38,
                                                        fit: BoxFit.fill,
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 1,
                                                      // alignment: Alignment.center,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 5),
                                                        child: Text(
                                                          dummyData
                                                                  .discountText ??
                                                              "",
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 2,
                                                          style:
                                                              const TextStyle(
                                                            color:
                                                                ColorName.black,
                                                            fontSize: 9.5,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                );
                                /*  GestureDetector(
                                  onTap: () async {
                                    for (int i = 0;
                                        i < list![index].unit!.length!;
                                        i++) {
                                      debugPrint(
                                          "Model  ${dummyData.productId} ${dummyData.addQuantity} ");
                                      if (dummyData.productId ==
                                          list![index].unit![i].productId!) {
                                        list![index].unit![i] = dummyData;
                                        isMoreUnitIndex = i;
                                      }
                                      debugPrint(
                                          "DATA Model  ${list![index].unit![i].productId!}  ${list![index].unit![i].addQuantity!}");
                                    }

                                    await Navigator.pushNamed(
                                      context,
                                      Routes.product_Detail_screen,
                                      arguments: {
                                      'fromchekcout': false,
                                        'list': list![index].unit!,
                                        'index': isMoreunit
                                            ? isMoreUnitIndex
                                            : index,
                                      },
                                    ).then((value) async {
                                      ProductUnit unit = value as ProductUnit;
                                      debugPrint(
                                          "FeatureCallback ${value.addQuantity}");
                                      OndoorThemeData.setStatusBarColor();
                                      bloc.add(ProductUpdateQuantityEvent(
                                          quanitity: unit.addQuantity!,
                                          index: index));
                                    });
                                  },
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 3, vertical: 0),
                                        child: Card(
                                          elevation: 0,
                                          color: Colors.white,
                                          child: Row(
                                            children: [
                                              Stack(
                                                children: [
                                                  Container(
                                                    // height: Sizeconfig.getHeight(context)*0.2,
                                                    width: Sizeconfig.getWidth(
                                                            context) *
                                                        0.38,
                                                    //padding: EdgeInsets.all(4),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Expanded(
                                                          flex: 3,
                                                          child: Stack(
                                                            children: [
                                                              Container(
                                                                height: Sizeconfig
                                                                    .getWidth(
                                                                        context),
                                                                width: Sizeconfig
                                                                    .getWidth(
                                                                        context),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                  border: Border.all(
                                                                      width: 1,
                                                                      color: ColorName
                                                                          .newgray),
                                                                ),
                                                                child: Center(
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsets
                                                                        .symmetric(
                                                                            horizontal:
                                                                                0),
                                                                    child:
                                                                        Stack(
                                                                      children: [
                                                                        Center(
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                Sizeconfig.getWidth(context) * .25,
                                                                            padding:
                                                                                EdgeInsets.all(4),
                                                                            width:
                                                                                Sizeconfig.getWidth(context) * .25,
                                                                            child:
                                                                                CommonCachedImageWidget(
                                                                              imgUrl: dummyData.image!,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Expanded(
                                                            flex: 4,
                                                            child: Container(
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                        // height: Sizeconfig.getHeight(context) * .04,
                                                                        // width: Sizeconfig.getWidth(context) * 0.55,
                                                                        // color: Colors.red,
                                                                        child:
                                                                            Text(
                                                                          dummyData
                                                                              .name!,
                                                                          maxLines:
                                                                              2,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            fontFamily:
                                                                                Fontconstants.fc_family_sf,
                                                                            fontWeight:
                                                                                Fontconstants.SF_Pro_Display_SEMIBOLD,
                                                                            color:
                                                                                Colors.black,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      (dummyData!.cOfferId != 0 &&
                                                                              dummyData.cOfferId != null)
                                                                          ? InkWell(
                                                                              onTap: () {
                                                                                List<ProductUnit> subProductsDetailsList = dummyData!.subProduct!.subProductDetail!;

                                                                                print("model quantity ${dummyData.addQuantity}");

                                                                                SubProduct subproducts = dummyData.subProduct!;
                                                                                for (int i = 0; i < subProductsDetailsList.length; i++) {
                                                                                  SubProduct subproduct = SubProduct();
                                                                                  subproduct.cOfferInfo = subproducts!.cOfferInfo;
                                                                                  subproduct.getQty = subproducts!.getQty;
                                                                                  subproduct.discType = subproducts!.discType;
                                                                                  subproduct.discAmt = subproducts!.discAmt;
                                                                                  subproduct.cOfferAvail = subproducts!.cOfferAvail;
                                                                                  subproduct.cOfferApplied = subproducts!.cOfferApplied;
                                                                                  subproduct.offerProductId = subproducts!.offerProductId;
                                                                                  subproduct.offerWarning = subproducts!.offerWarning;
                                                                                  List<ProductUnit>? subProductDetail = [];
                                                                                  for (var x in subproducts!.subProductDetail!) {
                                                                                    ProductUnit y = ProductUnit();
                                                                                    y.productId = x.productId;
                                                                                    y.quantity = x.quantity;
                                                                                    y.image = x.image;
                                                                                    y.price = x.specialPrice;
                                                                                    y.subProduct = x.subProduct;
                                                                                    y.model = x.model;
                                                                                    y.name = x.name;

                                                                                    subProductDetail.add(y);
                                                                                  }
                                                                                  subproduct.subProductDetail = subProductDetail;
                                                                                  subProductsDetailsList[i].subProduct = subproduct;
                                                                                  subProductsDetailsList[i].subProduct!.buyQty = dummyData!.subProduct!.buyQty;
                                                                                  subProductsDetailsList[i].cOfferId = dummyData.cOfferId;
                                                                                  subProductsDetailsList[i].discountLabel = dummyData.discountLabel;
                                                                                  subProductsDetailsList[i].discountText = dummyData.discountText;
                                                                                  subProductsDetailsList[i].cOfferType = dummyData.cOfferType;
                                                                                  debugPrint("GGGGGG" + dummyData.subProduct!.cOfferInfo!);
                                                                                  debugPrint("GGGGGGGG" + subProductsDetailsList[i].subProduct!.cOfferInfo!);
                                                                                }

                                                                                Appwidgets.showSubProductsOffer(
                                                                                    int.parse(dummyData!.subProduct!.buyQty! ?? "0"),
                                                                                    dummyData!.subProduct!.cOfferApplied!,
                                                                                    dummyData!.subProduct!.cOfferInfo!,
                                                                                    dummyData!.subProduct!.offerWarning!,
                                                                                    context,
                                                                                    cardBloc,
                                                                                    // model!.subProduct!.subProductDetail!,
                                                                                    subProductsDetailsList,
                                                                                    bloc,
                                                                                    ShopByCategoryBloc(), () {
                                                                                  debugPrint('Refresh call >>  ');

                                                                                  // loadFeatureProduct();
                                                                                  // searchProduct(searchController.text);
                                                                                }, (value) {});
                                                                              },
                                                                              child: Image.asset(
                                                                                Imageconstants.img_giftoffer,
                                                                                height: 20,
                                                                                width: 20,
                                                                              ))
                                                                          : Container()
                                                                    ],
                                                                  ),
                                                                  InkWell(
                                                                    onTap: () {
                                                                      if (isMoreunit) {
                                                                        MyDialogs.optionDialog(
                                                                                context,
                                                                                list![index].unit!,
                                                                                dummyData)
                                                                            .then((value) {
                                                                          isMoreUnitIndex = list![index].unit!.indexWhere((model) =>
                                                                              model ==
                                                                              value);
                                                                          value.selectedUnitIndex =
                                                                              isMoreUnitIndex;
                                                                          debugPrint(
                                                                              "Dialog value ${index} ${value.name} ");

                                                                          for (int i = 0;
                                                                              i < list![index].unit!.length;
                                                                              i++) {
                                                                            if (list![index].unit![i].productId ==
                                                                                value.productId) {
                                                                              list![index].unit![i].isselectUnit = true;
                                                                              value.isselectUnit = true;
                                                                            } else {
                                                                              list![index].unit![i].isselectUnit = false;
                                                                            }
                                                                          }

                                                                          bloc.add(
                                                                              ProductChangeEvent(model: value));
                                                                        });
                                                                      }
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      child:
                                                                          Container(
                                                                        decoration: isMoreunit
                                                                            ? BoxDecoration(
                                                                                color: ColorName.ColorBagroundPrimary,
                                                                                // borderRadius:
                                                                                // BorderRadius.circular(10),
                                                                                // border: Border.all(
                                                                                //     color:
                                                                                //     ColorName.lightGey),
                                                                              )
                                                                            : null,
                                                                        margin: isMoreunit
                                                                            ? EdgeInsets.only(top: 5)
                                                                            : null,
                                                                        padding:
                                                                            EdgeInsets.only(top: 5),
                                                                        width: Sizeconfig.getWidth(context) *
                                                                            .20,
                                                                        child:
                                                                            Align(
                                                                          alignment:
                                                                              Alignment.center,
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Text(
                                                                                dummyData.productWeight.toString() + " ${dummyData.productWeightUnit}",
                                                                                style: TextStyle(
                                                                                  fontSize: Constants.SizeSmall,
                                                                                  fontFamily: Fontconstants.fc_family_sf,
                                                                                  fontWeight: Fontconstants.SF_Pro_Display_Bold,
                                                                                  color: isMoreunit ? ColorName.black : ColorName.textlight,
                                                                                ),
                                                                              ),
                                                                              Visibility(
                                                                                  visible: isMoreunit,
                                                                                  child: Container(
                                                                                    width: 10,
                                                                                    height: 10,
                                                                                    child: Image.asset(
                                                                                      Imageconstants.img_dropdownarrow,
                                                                                      color: ColorName.ColorPrimary,
                                                                                    ),
                                                                                  ))
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .bottomCenter,
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Column(
                                                                          children: [
                                                                            Text(
                                                                              dummyData.specialPrice == "" ? "" : "₹ ${double.parse(dummyData.price!).toStringAsFixed(2)}",
                                                                              style: TextStyle(fontSize: Constants.SizeSmall, fontFamily: Fontconstants.fc_family_sf, fontWeight: Fontconstants.SF_Pro_Display_Medium, letterSpacing: 0, decoration: TextDecoration.lineThrough, decorationColor: ColorName.textlight, color: ColorName.textlight),
                                                                            ),
                                                                            Visibility(
                                                                              visible: dummyData.specialPrice != "",
                                                                              child: SizedBox(
                                                                                width: 5,
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                                flex: 0,
                                                                                child: Text(
                                                                                  dummyData.specialPrice == "" ? "₹ ${double.parse(dummyData.sortPrice!).toStringAsFixed(2)}" : "₹ ${double.parse(dummyData.specialPrice!).toStringAsFixed(2)}",
                                                                                  style: TextStyle(
                                                                                    fontSize: Constants.SizeSmall,
                                                                                    fontFamily: Fontconstants.fc_family_sf,
                                                                                    fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
                                                                                    color: Colors.black,
                                                                                  ),
                                                                                )),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )),
                                                      ],
                                                    ),
                                                  ),
                                                  Positioned(
                                                    right: 5,
                                                    bottom: 5,
                                                    child: Container(
                                                        width: Sizeconfig
                                                                .getWidth(
                                                                    context) *
                                                            0.21,
                                                        height:
                                                            Sizeconfig.getWidth(
                                                                    context) *
                                                                0.08,
                                                        child: dummyData
                                                                    .addQuantity !=
                                                                0
                                                            ? Container(
                                                                alignment: Alignment
                                                                    .bottomRight,
                                                                child: Appwidgets.AddQuantityButton(
                                                                    StringContants
                                                                        .lbl_add,
                                                                    dummyData
                                                                            .addQuantity!
                                                                        as int,
                                                                    () {
                                                                  //increase

                                                                  if (dummyData
                                                                          .addQuantity ==
                                                                      int.parse(
                                                                          dummyData
                                                                              .quantity!)) {
                                                                    Fluttertoast
                                                                        .showToast(
                                                                            msg:
                                                                                StringContants.msg_quanitiy);
                                                                  } else {
                                                                    dummyData
                                                                            .addQuantity =
                                                                        dummyData.addQuantity +
                                                                            1;
                                                                    bloc.add(ProductUpdateQuantityEvent(
                                                                        quanitity:
                                                                            dummyData
                                                                                .addQuantity!,
                                                                        index:
                                                                            index));
                                                                    bloc.add(ProductChangeEvent(
                                                                        model:
                                                                            dummyData));
                                                                    updateCard(
                                                                        dummyData,
                                                                        dbHelper,
                                                                        cardBloc);
                                                                    debugPrint(
                                                                        "Scroll Event1111 ");
                                                                  }
                                                                }, () async {
                                                                  if (dummyData
                                                                          .addQuantity ==
                                                                      1) {
                                                                    debugPrint(
                                                                        "SHOPBY 1");
                                                                    dummyData
                                                                        .addQuantity = 0;

                                                                    bloc.add(ProductUpdateQuantityEventBYModel(
                                                                        model:
                                                                            dummyData));

                                                                    await dbHelper
                                                                        .deleteCard(int.parse(dummyData
                                                                            .productId!))
                                                                        .then(
                                                                            (value) {
                                                                      debugPrint(
                                                                          "Delete Product $value ");

                                                                      // cardBloc.add(CardDeleteEvent(
                                                                      //     model: model,
                                                                      //     listProduct:  list![0].unit!));

                                                                      dbHelper.loadAddCardProducts(
                                                                          cardBloc);
                                                                    });
                                                                  } else if (dummyData
                                                                          .addQuantity !=
                                                                      0) {
                                                                    debugPrint(
                                                                        "SHOPBY 2");
                                                                    dummyData
                                                                            .addQuantity =
                                                                        dummyData.addQuantity -
                                                                            1;

                                                                    updateCard(
                                                                        dummyData,
                                                                        dbHelper,
                                                                        cardBloc);
                                                                    bloc.add(ProductUpdateQuantityEventBYModel(
                                                                        model:
                                                                            dummyData));

                                                                    bloc.add(ProductChangeEvent(
                                                                        model:
                                                                            dummyData));
                                                                  }
                                                                }),
                                                              )
                                                            : Appwidgets()
                                                                .buttonPrimary(
                                                                StringContants
                                                                    .lbl_add,
                                                                () {
                                                                  dummyData
                                                                          .addQuantity =
                                                                      dummyData
                                                                              .addQuantity +
                                                                          1;
                                                                  checkItemId(
                                                                          dummyData
                                                                              .productId!,
                                                                          dbHelper)
                                                                      .then(
                                                                          (value) {
                                                                    debugPrint(
                                                                        "CheckItemId $value");

                                                                    if (value ==
                                                                        false) {
                                                                      addCard(
                                                                          dummyData,
                                                                          dbHelper,
                                                                          cardBloc);
                                                                    } else {
                                                                      updateCard(
                                                                          dummyData,
                                                                          dbHelper,
                                                                          cardBloc);
                                                                    }
                                                                  });

                                                                  bloc.add(ProductUpdateQuantityEvent(
                                                                      quanitity:
                                                                          dummyData
                                                                              .addQuantity!,
                                                                      index:
                                                                          index));
                                                                  bloc.add(
                                                                      ProductChangeEvent(
                                                                          model:
                                                                              dummyData));
                                                                },
                                                              )),
                                                  ),
                                                  Positioned(
                                                      top: 0,
                                                      left: 0,
                                                      child:
                                                          (dummyData.discountText ??
                                                                      "") ==
                                                                  ""
                                                              ? Container()
                                                              : Visibility(
                                                                  visible: (dummyData!
                                                                              .discountText !=
                                                                          "" ||
                                                                      dummyData!
                                                                              .discountText !=
                                                                          null),
                                                                  child:
                                                                      Positioned(
                                                                    // left: 7,
                                                                    left: 0,
                                                                    top: 0,
                                                                    child:
                                                                        Stack(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      children: [
                                                                        ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.only(topLeft: Radius.circular(5.0)),
                                                                          child:
                                                                              Image.asset(
                                                                            Imageconstants.img_tag,
                                                                            height:
                                                                                25,
                                                                            width:
                                                                                31,
                                                                            fit:
                                                                                BoxFit.fill,
                                                                          ),
                                                                        ),
                                                                        Align(
                                                                          alignment:
                                                                              Alignment.center,
                                                                          child:
                                                                              Text(
                                                                            dummyData.discountText ??
                                                                                "",
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            maxLines:
                                                                                2,
                                                                            style:
                                                                                const TextStyle(
                                                                              color: ColorName.black,
                                                                              fontSize: 7,
                                                                              fontWeight: FontWeight.w600,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                )),
                                                ],
                                              ),
                                              loadMore == false
                                                  ? Container()
                                                  : index != (list!.length - 1)
                                                      ? Container()
                                                      : Container(
                                                          height: 30,
                                                          width: 30,
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 10),
                                                          child:
                                                              CircularProgressIndicator(
                                                            color: ColorName
                                                                .ColorPrimary,
                                                          ))
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );*/
                              }));
                    }),
              );
  }

  static updateCard(
      ProductUnit model, DatabaseHelper dbHelper, CardBloc cardBloc) async {
    int status = await dbHelper.updateCard({
      DBConstants.PRODUCT_ID: int.parse(model.productId!),
      DBConstants.QUANTITY: model.addQuantity,
    });

    dbHelper.loadAddCardProducts(cardBloc);
  }

  static addCard(
      ProductUnit model, DatabaseHelper dbHelper, CardBloc cardBloc) async {
    String image_array_json = "";
    for (int i = 0; i < model!.imageArray!.length; i++) {
      if (i == 0) {
        image_array_json = model!.imageArray![i].toJson() + "";
      } else {
        image_array_json = "," + model!.imageArray![i].toJson();
      }
    }

    debugPrint("ImageArrayNew ${image_array_json}");

    if (image_array_json.startsWith(',')) {
      image_array_json = image_array_json.substring(1);
    }
    debugPrint("ImageArrayNew ${image_array_json}");

    image_array_json = '[${image_array_json}]';

    int status = await dbHelper.insertAddCardProduct({
      DBConstants.PRODUCT_ID: int.parse(model.productId!),
      DBConstants.PRODUCT_NAME: model.name,
      DBConstants.PRODUCT_WEIGHT: model.productWeight,
      DBConstants.PRODUCT_WEIGHT_UNIT: model.productWeightUnit,
      DBConstants.ORDER_QTY_LIMIT: model.orderQtyLimit,
      DBConstants.CNF_SHIPPING_SURCHARGE: "",
      DBConstants.SHIPPING_MAX_AMOUNT: "",
      DBConstants.IMAGE: model.image,
      DBConstants.DISLABEL: model.discountLabel,
      DBConstants.DISTEXT: model.discountText,
      DBConstants.DETAIL_IMAGE: model.detailsImage,
      DBConstants.IMAGE_ARRAY: image_array_json,
      DBConstants.PRICE: model.price,
      DBConstants.SPECIAL_PRICE: model.specialPrice,
      DBConstants.SORT_PRICE: model.sortPrice,
      DBConstants.OPTION_PRICE_ALL: 0,
      DBConstants.DESCRIPTION: model.description,
      DBConstants.MODEL: model.model,
      DBConstants.QUANTITY: model.addQuantity,
      DBConstants.TOTALQUANTITY: model.quantity,
      DBConstants.SUBTRACT: model.subtract,
      DBConstants.MSG_ON_CAKE: model.messageOnCake,
      DBConstants.MSG_ON_CARD: model.messageOnCard,
      DBConstants.VENDOR_PRODUCT: model.ondoorProduct,
      DBConstants.SELLER_ID: "",
      DBConstants.GIFT_ITEM: "",
      DBConstants.SHIPPING_OPTION_ID: "",
      DBConstants.DELIVERY_DATE: "",
      DBConstants.DELIVERY_TIME_SLOT: "",
      DBConstants.TIME_SLOT_JSON: "",
      DBConstants.SHIPPING_CHARGE: "",
      DBConstants.IS_OPTION: model.isOption,
      DBConstants.SELLER_NICKNAME: "",
      DBConstants.SHOW_CARD_MSG: model.messageOnCard,
      DBConstants.SHOW_CAKE_MGS: model.messageOnCake,
      DBConstants.SHIPPING_JSON: "",
      DBConstants.SHIPPING_OPTION_SELECTED: "",
      DBConstants.TIME_SLOT_SELECT: "",
      DBConstants.SELLER_DATA: "",
      DBConstants.OPTION_UNI: "",
      DBConstants.OPTION_JSON_ALL: "",
      DBConstants.ACTUAL_SHIPPING_CHARGE: 0,
      DBConstants.REWARD_POINTS: model.rewardPoints,
      DBConstants.OFFER_DESC: "",
      DBConstants.OFFER_LABEL: "",
      DBConstants.OFFER_ID: "",
      DBConstants.OFFER_TYPE: "",
      DBConstants.OFFER_PRODUCT: "",
      DBConstants.OFFER_COUNT: 0,
      DBConstants.OFFER_MAX: 0,
      DBConstants.OFFER_APPLIED: "",
      DBConstants.OFFER_WARNING: "",
      DBConstants.BUY_QTY: 0,
      DBConstants.GET_QTY: 0
    });

    cardBloc.add(AddCardEvent(count: status));
    dbHelper.loadAddCardProducts(cardBloc);
  }

  static Future<bool> checkItemId(String id, DatabaseHelper dbHelper) async {
    final allRows = await dbHelper.queryAllRowsCardProducts();
    for (final row in allRows) {
      String id2 = row[DBConstants.PRODUCT_ID].toString();

      if (id == id2) {
        return true;
      }
    }
    return false;
  }

  static categoryItemView2(
      BuildContext context,
      ProductUnit model,
      dynamic state,
      int index,
      bool isMoreUnit,
      FeaturedBloc bloc,
      List<ProductData>? list,
      int isMoreUnitIndex,
      DatabaseHelper dbHelper,
      CardBloc cardBloc) {
    bool showWarningMessage = false;
    bool offerAppilied = false;
    debugPrint("categoryItemViewModel ${jsonEncode(model.discountText)}");
    debugPrint("categoryItemViewModel ${model.cOfferId != null}");

    int totalAdded = 0;

    print("On Add Total Quanitiyt ${totalAdded}");

    int remainingQuanityt = 0;
    int buy_quantity = 0;
    String applied = "";
    String warningtitle = "";
    String offerinfo = "";

    if (model.subProduct != null && model!.subProduct!.buyQty != null) {
      for (var x in model.subProduct!.subProductDetail!) {
        if (x.productId == model.productId) {
          totalAdded = totalAdded + model.addQuantity;
        } else {
          totalAdded = totalAdded + x.addQuantity;
        }
      }

      if (totalAdded == 0) {
        totalAdded = model.addQuantity;
      }

      debugPrint("TotalAdded Quantity ${totalAdded}");

      applied = model!.subProduct!.cOfferApplied!;
      offerinfo = model!.subProduct!.cOfferInfo!;
      warningtitle = model!.subProduct!.offerWarning!;
      buy_quantity = int.parse(model!.subProduct!.buyQty! ?? "0");
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

    if (isMoreUnit) {
      for (var x in list![index].unit!) {
        debugPrint("isMoreUnitGGGGGG ${x.name} ${x.selectedUnitIndex}");
        //   if (x.selectedUnitIndex > 0)
        if (x.isselectUnit) {
          model = x;
        }
      }
    }

    return Column(
      children: [
        InkWell(
          onTap: () {
            for (int i = 0; i < list![index].unit!.length!; i++) {
              debugPrint("Model  ${model.productId} ${model.addQuantity} ");
              if (model.productId == list![index].unit![i].productId!) {
                list![index].unit![i] = model;
                isMoreUnitIndex = i;
              }
              debugPrint(
                  "DATA Model  ${list![index].unit![i].productId!}  ${list![index].unit![i].addQuantity!}");
            }

            Navigator.pushNamed(
              context,
              Routes.product_Detail_screen,
              arguments: {
                'fromchekcout': false,
                'list': list![index].unit!,
                'index': isMoreUnit ? isMoreUnitIndex : index,
              },
            ).then((value) async {
              OndoorThemeData.setStatusBarColor();

              // shopByCategoryBloc.refreshingFilter(
              //     selectedSubcategory!, selectedIndex, context,list);
              ProductUnit unit = value as ProductUnit;
              bloc.add(ProductUpdateQuantityEvent(
                  quanitity: unit.addQuantity!, index: index));
            });
          },
          child: Stack(
            children: [
              (model!.cOfferId != 0 &&
                      model.cOfferId != null &&
                      model.subProduct != null &&
                      (showWarningMessage != false || offerAppilied != false))
                  ? Container(
                      height: Sizeconfig.getHeight(context) * 0.18,
                      margin:
                          EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
                      padding: EdgeInsets.only(bottom: 1),
                      decoration: BoxDecoration(
                        color: showWarningMessage
                            ? Colors.red.shade400
                            : Colors.green,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: ColorName.lightGey),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(),
                          Column(
                            children: [
                              showWarningMessage == false
                                  ? Container()
                                  : Container(
                                      width: Sizeconfig.getWidth(context),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 10),
                                      alignment: Alignment.center,
                                      child: Text(
                                        warningtitle.replaceAll(
                                            "@#\$", "${remainingQuanityt}"),
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 10,
                                        ),
                                      )),
                              Visibility(
                                visible: offerAppilied,
                                child: Container(
                                    width: Sizeconfig.getWidth(context),
                                    // margin: EdgeInsets.symmetric(
                                    //     horizontal: 10, vertical: 10),

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
                                        SizedBox(
                                          width: 3,
                                        ),
                                        Container(
                                          width: Sizeconfig.getWidth(context) *
                                              0.5,
                                          child: Text(
                                            applied.replaceAll("@#\$",
                                                buy_quantity.toString()),
                                            maxLines: 1,
                                            style: TextStyle(fontSize: 10),
                                          ),
                                        )
                                      ],
                                    )),
                              ),
                            ],
                          )
                        ],
                      ))
                  : Container(),
              IntrinsicHeight(
                child: Stack(
                  children: [
                    Container(
                      key: Key(model.productId!),
                      // height: isMoreUnit
                      //     ? Sizeconfig.getHeight(context) * 0.16
                      //
                      //     : Sizeconfig.getHeight(context) * 0.15,
                      margin:
                          EdgeInsets.symmetric(horizontal: 5.0, vertical: 2),
                      padding:
                          EdgeInsets.only(top: 6, bottom: 6, left: 5, right: 6),
                      decoration: BoxDecoration(
                        color: ColorName.ColorBagroundPrimary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: ColorName.lightGey),
                      ),
                      // margin:  EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                      child: Padding(
                        padding: EdgeInsets.all(0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    height: Sizeconfig.getWidth(context) * .25,
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 0),
                                      child: Stack(
                                        children: [
                                          Card(
                                            elevation: 1,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: ColorName
                                                    .ColorBagroundPrimary,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    color: ColorName.lightGey),
                                              ),
                                              height:
                                                  Sizeconfig.getWidth(context) *
                                                      .25,
                                              padding: EdgeInsets.all(4),
                                              width:
                                                  Sizeconfig.getWidth(context) *
                                                      .25,
                                              child: CommonCachedImageWidget(
                                                imgUrl: model.image!,
                                              ),
                                            ),
                                          ),
                                          (model.discountText ?? "") == ""
                                              ? Container()
                                              : Visibility(
                                                  visible:
                                                      (model!.discountText !=
                                                              "" ||
                                                          model!.discountText !=
                                                              null),
                                                  child: Positioned(
                                                    // left: 7,
                                                    left: 11,
                                                    top: 4,
                                                    child: Stack(
                                                      alignment:
                                                          Alignment.center,
                                                      children: [
                                                        Image.asset(
                                                          Imageconstants
                                                              .img_tag,
                                                          height: 20,
                                                          width: 31,
                                                          fit: BoxFit.fill,
                                                        ),
                                                        Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                            model.discountText ??
                                                                "",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 2,
                                                            style:
                                                                const TextStyle(
                                                              color: ColorName
                                                                  .black,
                                                              fontSize: 7,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
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
                                ),
                                Expanded(
                                  flex: 8,
                                  child: Container(
                                    padding: EdgeInsets.only(left: 6),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              // height: Sizeconfig.getHeight(context) * .04,
                                              // width: Sizeconfig.getWidth(context) * 0.55,
                                              // color: Colors.red,
                                              child: Text(
                                                model.name!,
                                                maxLines: 2,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontFamily: Fontconstants
                                                      .fc_family_sf,
                                                  fontWeight: Fontconstants
                                                      .SF_Pro_Display_SEMIBOLD,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            (model!.cOfferId != 0 &&
                                                    model.cOfferId != null)
                                                ? InkWell(
                                                    onTap: () {
                                                      List<ProductUnit>
                                                          subProductsDetailsList =
                                                          model!.subProduct!
                                                              .subProductDetail!;

                                                      print(
                                                          "model quantity ${model.addQuantity}");

                                                      SubProduct subproducts =
                                                          model.subProduct!;
                                                      for (int i = 0;
                                                          i <
                                                              subProductsDetailsList
                                                                  .length;
                                                          i++) {
                                                        SubProduct subproduct =
                                                            SubProduct();
                                                        subproduct.cOfferInfo =
                                                            subproducts!
                                                                .cOfferInfo;
                                                        subproduct.getQty =
                                                            subproducts!.getQty;
                                                        subproduct.discType =
                                                            subproducts!
                                                                .discType;
                                                        subproduct.discAmt =
                                                            subproducts!
                                                                .discAmt;
                                                        subproduct.cOfferAvail =
                                                            subproducts!
                                                                .cOfferAvail;
                                                        subproduct
                                                                .cOfferApplied =
                                                            subproducts!
                                                                .cOfferApplied;
                                                        subproduct
                                                                .offerProductId =
                                                            subproducts!
                                                                .offerProductId;
                                                        subproduct
                                                                .offerWarning =
                                                            subproducts!
                                                                .offerWarning;
                                                        List<ProductUnit>?
                                                            subProductDetail =
                                                            [];
                                                        for (var x in subproducts!
                                                            .subProductDetail!) {
                                                          ProductUnit y =
                                                              ProductUnit();
                                                          y.productId =
                                                              x.productId;
                                                          y.quantity =
                                                              x.quantity;
                                                          y.image = x.image;
                                                          y.price =
                                                              x.specialPrice;
                                                          y.subProduct =
                                                              x.subProduct;
                                                          y.model = x.model;
                                                          y.name = x.name;

                                                          subProductDetail
                                                              .add(y);
                                                        }
                                                        subproduct
                                                                .subProductDetail =
                                                            subProductDetail;
                                                        subProductsDetailsList[
                                                                    i]
                                                                .subProduct =
                                                            subproduct;
                                                        subProductsDetailsList[
                                                                    i]
                                                                .subProduct!
                                                                .buyQty =
                                                            model!.subProduct!
                                                                .buyQty;
                                                        subProductsDetailsList[
                                                                    i]
                                                                .cOfferId =
                                                            model.cOfferId;
                                                        subProductsDetailsList[
                                                                    i]
                                                                .discountLabel =
                                                            model.discountLabel;
                                                        subProductsDetailsList[
                                                                    i]
                                                                .discountText =
                                                            model.discountText;
                                                        subProductsDetailsList[
                                                                    i]
                                                                .cOfferType =
                                                            model.cOfferType;
                                                        debugPrint("GGGGGG" +
                                                            model.subProduct!
                                                                .cOfferInfo!);
                                                        debugPrint("GGGGGGGG" +
                                                            subProductsDetailsList[
                                                                    i]
                                                                .subProduct!
                                                                .cOfferInfo!);
                                                      }

                                                      Appwidgets
                                                          .showSubProductsOffer(
                                                              int.parse(model!
                                                                      .subProduct!
                                                                      .buyQty! ??
                                                                  "0"),
                                                              model!.subProduct!
                                                                  .cOfferApplied!,
                                                              model!.subProduct!
                                                                  .cOfferInfo!,
                                                              model!.subProduct!
                                                                  .offerWarning!,
                                                              context,
                                                              cardBloc,
                                                              // model!.subProduct!.subProductDetail!,
                                                              subProductsDetailsList,
                                                              bloc,
                                                              ShopByCategoryBloc(),
                                                              () {
                                                        debugPrint(
                                                            'Refresh call >>  ');

                                                        // loadFeatureProduct();
                                                        // searchProduct(searchController.text);
                                                      }, (value) {});
                                                    },
                                                    child: Image.asset(
                                                      Imageconstants
                                                          .img_giftoffer,
                                                      height: 20,
                                                      width: 20,
                                                    ))
                                                : Container()
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            if (isMoreUnit) {
                                              MyDialogs.optionDialog(context,
                                                      list![index].unit!, model)
                                                  .then((value) {
                                                isMoreUnitIndex = list![index]
                                                    .unit!
                                                    .indexWhere((model) =>
                                                        model == value);
                                                value.selectedUnitIndex =
                                                    isMoreUnitIndex;
                                                debugPrint(
                                                    "Dialog value ${index} ${value.name} ");

                                                for (int i = 0;
                                                    i <
                                                        list![index]
                                                            .unit!
                                                            .length;
                                                    i++) {
                                                  if (list![index]
                                                          .unit![i]
                                                          .productId ==
                                                      value.productId) {
                                                    list![index]
                                                        .unit![i]
                                                        .isselectUnit = true;
                                                    value.isselectUnit = true;
                                                  } else {
                                                    list![index]
                                                        .unit![i]
                                                        .isselectUnit = false;
                                                  }
                                                }

                                                bloc.add(ProductChangeEvent(
                                                    model: value));
                                              });
                                            }
                                          },
                                          child: Container(
                                            child: Container(
                                              decoration: isMoreUnit
                                                  ? BoxDecoration(
                                                      color: ColorName
                                                          .ColorBagroundPrimary,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      border: Border.all(
                                                          color: ColorName
                                                              .lightGey),
                                                    )
                                                  : null,
                                              margin: isMoreUnit
                                                  ? EdgeInsets.only(top: 5)
                                                  : null,
                                              padding: isMoreUnit
                                                  ? EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                      vertical: 4)
                                                  : EdgeInsets.only(top: 5),
                                              width:
                                                  Sizeconfig.getWidth(context) *
                                                      .20,
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      model.productWeight
                                                              .toString() +
                                                          " ${model.productWeightUnit}",
                                                      style: TextStyle(
                                                        fontSize:
                                                            Constants.SizeSmall,
                                                        fontFamily:
                                                            Fontconstants
                                                                .fc_family_sf,
                                                        fontWeight: Fontconstants
                                                            .SF_Pro_Display_Bold,
                                                        color: isMoreUnit
                                                            ? ColorName.black
                                                            : ColorName
                                                                .textlight,
                                                      ),
                                                    ),
                                                    Visibility(
                                                        visible: isMoreUnit,
                                                        child: Container(
                                                          width: 10,
                                                          height: 10,
                                                          child: Image.asset(
                                                            Imageconstants
                                                                .img_dropdownarrow,
                                                          ),
                                                        ))
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                // Text(
                                                //   model.specialPrice == ""
                                                //       ? ""
                                                //       : "₹ ${double.parse(model.price!).toStringAsFixed(2)}",
                                                //   style: TextStyle(
                                                //       fontSize: Constants.SizeSmall,
                                                //       fontFamily: Fontconstants.fc_family_sf,
                                                //       fontWeight:
                                                //       Fontconstants.SF_Pro_Display_Medium,
                                                //       letterSpacing: 0,
                                                //       decoration: TextDecoration.lineThrough,
                                                //       decorationColor: ColorName.textlight,
                                                //       color: ColorName.textlight),
                                                // ),
                                                // Visibility(
                                                //   visible: model.specialPrice != "",
                                                //   child: SizedBox(
                                                //     width: 5,
                                                //   ),
                                                // ),
                                                Expanded(
                                                    flex: 0,
                                                    child: Text(
                                                      model.specialPrice == ""
                                                          ? "₹ ${double.parse(model.sortPrice!).toStringAsFixed(2)}"
                                                          : "₹ ${double.parse(model.specialPrice!).toStringAsFixed(2)}",
                                                      style: TextStyle(
                                                        fontSize:
                                                            Constants.SizeSmall,
                                                        fontFamily:
                                                            Fontconstants
                                                                .fc_family_sf,
                                                        fontWeight: Fontconstants
                                                            .SF_Pro_Display_SEMIBOLD,
                                                        color: Colors.black,
                                                      ),
                                                    )),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      bottom: 15,
                      child: Container(
                          width: Sizeconfig.getWidth(context) * 0.20,
                          height: Sizeconfig.getWidth(context) * 0.08,
                          child: model.addQuantity != 0
                              ? Container(
                                  alignment: Alignment.bottomRight,
                                  child: Appwidgets.AddQuantityButton(
                                      StringContants.lbl_add,
                                      model.addQuantity! as int, () {
                                    //increase

                                    if (model.addQuantity ==
                                        int.parse(
                                            model.orderQtyLimit!.toString())) {
                                      Fluttertoast.showToast(
                                          msg: StringContants.msg_quanitiy);
                                    } else {
                                      model.addQuantity = model.addQuantity + 1;
                                      bloc.add(ProductUpdateQuantityEvent(
                                          quanitity: model.addQuantity!,
                                          index: index));
                                      bloc.add(
                                          ProductChangeEvent(model: model));
                                      updateCard(model, dbHelper, cardBloc);
                                      debugPrint("Scroll Event1111 ");
                                    }
                                  }, () async {
                                    if (model.addQuantity == 1) {
                                      debugPrint("SHOPBY 1");
                                      model.addQuantity = 0;

                                      bloc.add(
                                          ProductUpdateQuantityEventBYModel(
                                              model: model));

                                      await dbHelper
                                          .deleteCard(
                                              int.parse(model.productId!))
                                          .then((value) {
                                        debugPrint("Delete Product $value ");

                                        // cardBloc.add(CardDeleteEvent(
                                        //     model: model,
                                        //     listProduct:  list![0].unit!));

                                        dbHelper.loadAddCardProducts(cardBloc);
                                      });
                                    } else if (model.addQuantity != 0) {
                                      debugPrint("SHOPBY 2");
                                      model.addQuantity = model.addQuantity - 1;

                                      updateCard(model, dbHelper, cardBloc);
                                      bloc.add(
                                          ProductUpdateQuantityEventBYModel(
                                              model: model));

                                      bloc.add(
                                          ProductChangeEvent(model: model));
                                    }
                                  }),
                                )
                              : Appwidgets().buttonPrimary(
                                  StringContants.lbl_add,
                                  () {
                                    // debugPrint("GGGGGGG " + cardItesmList.length.toString());

                                    model.addQuantity = model.addQuantity + 1;
                                    checkItemId(model.productId!, dbHelper)
                                        .then((value) {
                                      debugPrint("CheckItemId $value");

                                      if (value == false) {
                                        addCard(model, dbHelper, cardBloc);
                                      } else {
                                        updateCard(model, dbHelper, cardBloc);
                                      }
                                    });

                                    bloc.add(ProductUpdateQuantityEvent(
                                        quanitity: model.addQuantity!,
                                        index: index));
                                    bloc.add(ProductChangeEvent(model: model));
                                  },
                                )),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        index == list!.length - 1
            ? Container(
                height: 150,
                color: Colors.white,
              )
            : Container(),
      ],
    );
  }
}
