import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ondoor/constants/Constant.dart';
import 'package:ondoor/utils/sharedpref.dart';

import '../constants/ImageConstants.dart';
import '../constants/StringConstats.dart';
import '../database/database_helper.dart';
import '../database/dbconstants.dart';
import '../models/AllProducts.dart';
import '../models/locationvalidationmodel.dart';
import '../screens/AddCard/card_bloc.dart';
import '../screens/AddCard/card_event.dart';
import '../screens/AddCard/card_state.dart';
import '../services/ApiServices.dart';
import '../services/Navigation/routes.dart';
import '../utils/SizeConfig.dart';
import '../utils/colors.dart';
import 'AppWidgets.dart';
import 'MyDialogs.dart';

class Productvalidationswidgets {
  static productValidationlistUi(
    BuildContext context,
    List<ProductUnit> listProduct,
    List<ProductUnit> list_cOffers,
    CardBloc cardBloc,
    DatabaseHelper dbhelper,
    bool mixed,
    String recurring,
    String totalitemAllowed,
  ) {
    List<ProductUnit> cartitesmList = [];
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

    int totalItesmAddes = 0;
    bool ischeckbx = false;
    int isCheckedIndex = 0;

    if (mixed == false) {
      ischeckbx = true;
    }

    debugPrint("ischeckbx ${ischeckbx}");

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

            return Container(
              // height: (MediaQuery.of(context).size.height * 0.5) +
              //     (Sizeconfig.getHeight(context) * 0.1) *
              //         listProduct.length,

              height: Sizeconfig.getHeight(context) * 0.72,

              child: Scaffold(
                backgroundColor: Color(0xFF291722),
                body: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0),
                      )),
                  child: Container(
                    padding: EdgeInsets.only(top: 0),
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: Sizeconfig.getHeight(context) * 0.55,
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: listProduct.length,
                              itemBuilder: (context, index) {
                                var dummyData = listProduct[index];

                                if (state is CardCheckboxState) {
                                  if (index == state.index) {
                                    dummyData.isChecked = state.status;

                                    if (state.status) {
                                      dummyData.addQuantity =
                                          int.parse(dummyData!.quantity ?? "0");
                                    } else {
                                      dummyData.isChecked = false;
                                      dummyData.addQuantity = 0;
                                    }
                                  } else {
                                    dummyData.isChecked = false;
                                    dummyData.addQuantity = 0;
                                  }
                                }

                                if (state is CardUpdateQuanitiyState) {
                                  debugPrint(
                                      "CardUpdateQuantity*****************");
                                  listProduct[state.index].addQuantity =
                                      state.quantity;
                                }

                                if ((dummyData!.mandatory ?? false)) {
                                  dummyData.addQuantity =
                                      int.parse(dummyData!.max_quantity ?? "0");
                                }

                                return Appwidgets
                                    .categoryItemViewproductValidation(
                                        context,
                                        listProduct,
                                        dummyData,
                                        null,
                                        0,
                                        () {
                                          totalItesmAddes = 0;
                                          for (var x in listProduct) {
                                            totalItesmAddes =
                                                totalItesmAddes + x.addQuantity;
                                            debugPrint(
                                                "Increase cart total itemAdded ${totalitemAllowed} ${totalItesmAddes} ${(int.parse(totalitemAllowed) <= totalItesmAddes)}");
                                          }

                                          if ((int.parse(
                                                  totalitemAllowed ?? "0") <=
                                              totalItesmAddes)) {
                                            debugPrint("totalitemAllowed true");
                                            Fluttertoast.showToast(
                                                msg:
                                                    "You can add ${totalitemAllowed} offer items.");
                                          } else {
                                            debugPrint(
                                                "totalitemAllowed false");
                                            dummyData.addQuantity =
                                                dummyData.addQuantity + 1;

                                            debugPrint(
                                                "${dummyData.addQuantity}");

                                            updateCard(
                                                dummyData, index, listProduct);
                                          }
                                        },
                                        () async {
                                          if (dummyData.addQuantity == 1) {
                                            // dummyData.addQuantity = 0;
                                            dummyData.addQuantity =
                                                dummyData.addQuantity - 1;

                                            updateCard(
                                                dummyData, index, listProduct);
                                            // await dbhelper
                                            //     .deleteCard(int.parse(
                                            //     dummyData.productId!))
                                            //     .then((value) {
                                            //   debugPrint(
                                            //       "Delete Product $value ");
                                            //   cardBloc.add(CardDeleteEvent(
                                            //       model: listProduct[index],
                                            //       listProduct: listProduct));
                                            //   dbhelper.loadAddCardProducts(
                                            //       cardBloc);
                                            //
                                            //   listProduct.removeAt(index);
                                            //
                                            //   if (listProduct.length == 0) {
                                            //     cardBloc.add(CardEmptyEvent());
                                            //     Navigator.pop(context);
                                            //   }
                                            // });
                                          } else if (dummyData.addQuantity !=
                                              0) {
                                            dummyData.addQuantity =
                                                dummyData.addQuantity - 1;

                                            updateCard(
                                                dummyData, index, listProduct);
                                          }
                                        },
                                        () async {
                                          dummyData.addQuantity = 0;

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
                                        },
                                        () {
                                          dbhelper
                                              .loadAddCardProducts(cardBloc);
                                        },
                                        true,
                                        ischeckbx,
                                        () {
                                          if (dummyData.isChecked) {
                                            cardBloc.add(CardCheckboxEvent(
                                                status: false, index: index));
                                          } else {
                                            cardBloc.add(CardCheckboxEvent(
                                                status: true, index: index));
                                          }
                                        },
                                        true);
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return Divider(height: 0);
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
                                            borderRadius: BorderRadius.only(
                                                bottomLeft:
                                                    Radius.circular(0.0)),
                                            color: ColorName.ColorPrimary),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 14),
                                        child: Center(
                                            child: Text(
                                                StringContants.lbl_shopMore))),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: InkWell(
                                    onTap: () async {
                                      debugPrint("MyFreeProducts " +
                                          listProduct.length.toString());
                                      debugPrint("MyFreeProducts " +
                                          cartitesmList.length.toString());
                                      debugPrint("MyFreeProducts " +
                                          list_cOffers.length.toString());

                                      bool isQuanitiyAdded = false;

                                      for (var x in listProduct) {
                                        if (x.addQuantity != 0) {
                                          isQuanitiyAdded = true;
                                          cartitesmList.add(x);
                                        }
                                      }

                                      debugPrint(
                                          "Validation  continue ${isQuanitiyAdded} ");

                                      if (isQuanitiyAdded) {
                                        // freeProducts = value;
                                        // cardBloc.add(AddCardProductEvent(
                                        //     listProduct: cartitesmList));
                                        // Navigator.pop(context);
                                        Navigator.pushNamed(
                                          context,
                                          Routes.checkoutscreen,
                                          arguments: {
                                            'list': cartitesmList,
                                            'list_cOffers': list_cOffers,
                                          },
                                        ).then(
                                          (value) {
                                            Appwidgets.setStatusBarColor();
                                          },
                                        );
                                      } else {
                                        debugPrint(
                                            "MyFreeProducts ${isQuanitiyAdded}");

                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            title: Text(
                                              "Are you sure you don't want to add free products ?",
                                              style: Appwidgets()
                                                  .commonTextStyle(
                                                      ColorName.black),
                                            ),
                                            actions: [
                                              GestureDetector(
                                                  onTap: () async {
                                                    Navigator.pop(context);
                                                    Navigator.pushNamed(
                                                      context,
                                                      Routes.checkoutscreen,
                                                      arguments: {
                                                        'list': cartitesmList,
                                                        'list_cOffers':
                                                            list_cOffers,
                                                      },
                                                    ).then(
                                                      (value) {
                                                        Appwidgets
                                                            .setStatusBarColor();
                                                      },
                                                    );
                                                  },
                                                  child: Text("Yes",
                                                      style: Appwidgets()
                                                          .commonTextStyle(
                                                              ColorName
                                                                  .ColorPrimary))),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text("No",
                                                    style: Appwidgets()
                                                        .commonTextStyle(
                                                            ColorName
                                                                .ColorPrimary)),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                        margin: EdgeInsets.only(
                                            left:
                                                Sizeconfig.getHeight(context) *
                                                    0.001),
                                        decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                bottomRight:
                                                    Radius.circular(0.0)),
                                            color: ColorName.ColorPrimary),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 14),
                                        child: Center(
                                            child: Text(
                                                StringContants.lbl_continue))),
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
    );
  }

  static loadProductValication(DatabaseHelper dbHelper, BuildContext context,
      List<ProductUnit> cartItems, Function callback) {
    List<ProductUnit> list_cOffers = [];
    List<ProductUnit> freeProducts = [];
    List<ProductUnit> list_product_offer = [];
    ApiProvider().productValidation(cartItems, context, () {
      loadProductValication(dbHelper, context, cartItems, callback);
    }).then((value) {
      log("PRODUCT VALIDATION RESPONSE ${value}");
      if (value != null && value != "") {
        final response = jsonDecode(value.toString());
        var status = response["success"] ?? false;

        if (status) {
          if (value.toString().contains("sub_products")) {
            final responseData = jsonDecode(value.toString());

            List<dynamic> jsonDataList = responseData["final_products"];

            for (var finalproduct in jsonDataList) {
              if (finalproduct["sub_product"]
                  .toString()
                  .contains("sub_products")) {
                List<dynamic> subproducts =
                    finalproduct["sub_product"]["sub_products"];

                debugPrint("Final Products Found 1 ${subproducts}");

                for (var unitproduct in subproducts) {
                  var c_offer_info = unitproduct['c_offer_info'];
                  var add_item = unitproduct['add_item'];
                  var quantity = unitproduct['quantity'];
                  var total = unitproduct['total'];
                  var orp = unitproduct['orp'];

                  ProductUnit unit =
                      ProductUnit.fromJson(jsonEncode(unitproduct));

                  SubProduct sub = SubProduct();
                  sub.cOfferInfo = c_offer_info;
                  unit.subProduct = sub;
                  unit.addQuantity = int.parse(add_item.toString() ?? "0");
                  unit.quantity = quantity.toString();
                  unit.specialPrice = total;
                  unit.price = total.toString();

                  list_cOffers.add(unit);
                  debugPrint("Final Products Found ${list_cOffers.length}");
                  // cardBloc.add(
                  //     CardAddcOfferProdutsEvent(
                  //         unit: unit));
                  // list_cOffers.add(unit);
                  debugPrint("Dialog close here ${list_cOffers.length}");
                }
              }
            }
          }

          if (value.toString().contains("offer_alert")) {
            final responseData = jsonDecode(value.toString());
            String offerAlert = responseData["offer_alert"].toString();
            if (offerAlert == "true") {
              if (value.toString().contains("message")) {
                String offerMessage = responseData["message"].toString();
                debugPrint(" offerMessage >>${offerMessage}");
                MyDialogs.showProductOffersDialog(context, offerMessage, () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    Routes.checkoutscreen,
                    arguments: {
                      'list': list_cOffers,
                      'list_cOffers': list_cOffers,
                    },
                  ).then((value) {
                    Appwidgets.setStatusBarColor();
                    callback();
                  });
                });
              }
            }
          } else if (value.toString().contains("free_bies")) {
            final responseData = jsonDecode(value.toString());

            List<dynamic> jsonDataList =
                responseData["offer"]["free_bies"]["products"];

            for (var jsonmodel in jsonDataList) {
              log("offer json productlist  ${jsonEncode(jsonmodel)}");
              ProductUnit unit = ProductUnit.fromJson(jsonEncode(jsonmodel));
              list_product_offer.add(unit);
              log("offer json productlist 22 ${unit.toMap()}");
            }

            Appwidgets.showToastMessage("Free Product Available ");
            var subtitile =
                responseData["offer"]["free_bies"]["total_items_msg"];
            var description =
                responseData["offer"]["free_bies"]["offer_description"];
            var title = responseData["offer"]["free_bies"]["offer_title"];
            var mixed = responseData["offer"]["free_bies"]["mixed"];
            var recurring = responseData["offer"]["free_bies"]["is_recurring"];
            var totalitemAllowed =
                responseData["offer"]["free_bies"]["total_items_allowed"];

            Navigator.pushNamed(
              context,
              Routes.productValidation,
              arguments: {
                'list': list_product_offer,
                'list_cOffers': list_cOffers,
                'title': title,
                'subtitle': subtitile,
                'details': description,
                'mixed': mixed,
                'recurring': recurring,
                'totalitemAllowed': totalitemAllowed,
              },
            ).then((value) {
              callback();
            });
          } else if (value.toString().contains("discounts")) {
            final responseData = jsonDecode(value.toString());

            List<dynamic> jsonDataList =
                responseData["offer"]["discounts"]["products"];

            debugPrint("offer json productlist >>${jsonEncode(jsonDataList)}");

            for (var jsonmodel in jsonDataList) {
              ProductUnit unit = ProductUnit.fromJson(jsonEncode(jsonmodel));
              list_product_offer.add(unit);
            }

            Appwidgets.showToastMessage("Free Product Available ");
            var subtitile =
                responseData["offer"]["discounts"]["total_items_msg"];
            var description =
                responseData["offer"]["discounts"]["offer_description"];
            var title = responseData["offer"]["discounts"]["offer_title"];
            var mixed = responseData["offer"]["discounts"]["mixed"];
            var recurring = responseData["offer"]["discounts"]["is_recurring"];
            var totalitemAllowed =
                responseData["offer"]["discounts"]["total_items_allowed"];

            Navigator.pushNamed(
              context,
              Routes.productValidation,
              arguments: {
                'list': list_product_offer,
                'list_cOffers': list_cOffers,
                'title': title,
                'subtitle': subtitile,
                'details': description,
                'mixed': mixed,
                'recurring': recurring,
                'totalitemAllowed': totalitemAllowed,
              },
            ).then((value) {
              callback();
            });
          } else {
            // Navigator.pushNamed(context,
            //     Routes.checkoutscreen)
            //     .then((value) {
            //   callback();
            //   dbhelper
            //       .loadAddCardProducts(cardBloc);
            //
            //   if (isup == false) {
            //     Navigator.pop(context);
            //   }
            // });

            Navigator.pushNamed(
              context,
              Routes.checkoutscreen,
              arguments: {
                'list': list_cOffers,
                'list_cOffers': list_cOffers,
              },
            ).then((value) {
              callback();
            });
          }
        } else {
          loadLocationValidation(context, cartItems, CardBloc(), dbHelper);
        }
      }
    });
  }

  static updateCard(ProductUnit model, int index, var list,
      BuildContext context, DatabaseHelper dbHelper) async {
    int status = await dbHelper.updateCard({
      DBConstants.PRODUCT_ID: int.parse(model.productId!),
      DBConstants.QUANTITY: model.addQuantity,
      DBConstants.PRICE: model.price,
      DBConstants.SORT_PRICE: model.sortPrice,
      DBConstants.SPECIAL_PRICE: model.specialPrice,
    });

    debugPrint("Update Product Status " + status.toString());

    Navigator.of(context).pushReplacementNamed(Routes.home_page);
  }

  static loadLocationValidation(
      BuildContext context,
      List<ProductUnit> cartitesmList,
      CardBloc cardbloc,
      DatabaseHelper dbHelper) async {
    String location_id1 =
        await SharedPref.getStringPreference(Constants.LOCATION_ID);
    String coustomerId =
        await SharedPref.getStringPreference(Constants.sp_CustomerId);
    String token_type =
        await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
    String access_token =
        await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);
    String store_id1 = await SharedPref.getStringPreference(Constants.STORE_ID);
    String store_code1 =
        await SharedPref.getStringPreference(Constants.STORE_CODE);
    String store_name1 =
        await SharedPref.getStringPreference(Constants.STORE_Name);
    String wms_store_id1 =
        await SharedPref.getStringPreference(Constants.WMS_STORE_ID);

    ApiProvider().locationproductValidation(cartitesmList, store_id1,
        store_name1, wms_store_id1, location_id1, store_code1, () {
      loadLocationValidation(context, cartitesmList, cardbloc, dbHelper);
    }).then((value) {
      // debugPrint(
      //     "ONADDRESSCHANGE locationproductValidation ${selectedAddressData.toJson()}");

      if (value != "") {
        LocationProductsModel locationProduucts =
            LocationProductsModel.fromJson(value.toString());
        debugPrint("ONADDRESSCHANGE locationproductValidation 2 ${value}");
        if (locationProduucts.success == false) {
          debugPrint("ONADDRESSCHANGE result ${locationProduucts.toJson()}");

          MyDialogs.showLocationProductsDialog(context, locationProduucts,
              (updatelist) async {
            for (int i = 0; i < cartitesmList.length; i++) {
              debugPrint("i******   ${cartitesmList[i].name}");
              for (int j = 0; j < updatelist.length; j++) {
                debugPrint("j******   ${updatelist[j].name}");

                if (updatelist[j].outOfStock == "0" &&
                    updatelist[j].productId == cartitesmList[i].productId) {
                  debugPrint("GCondition 1");
                  cartitesmList[i].addQuantity =
                      int.parse(updatelist[j].qty ?? "0");
                  cartitesmList[i].price = updatelist[j].price;
                  cartitesmList[i].sortPrice = updatelist[j].newPrice;
                  cartitesmList[i].specialPrice = updatelist[j].newPrice;
                  //  cartitesmList[i].specialPrice=updatelist[j];

                  debugPrint(
                      "Updatecart Items call ${cartitesmList[i].toJson()}");

                  updateCard(
                      cartitesmList[i], i, cartitesmList, context, dbHelper);
                } else if ((updatelist[j].outOfStock == "1" &&
                    updatelist[j].productId == cartitesmList[i].productId)) {
                  debugPrint("GCondition 2");
                  //GGGGNNNNN
                  await dbHelper
                      .deleteCard(int.parse(cartitesmList[i].productId!))
                      .then((value) {
                    routestoHomeOrLocation(context);
                  });
                }
              }
            }
          }, () async {
            //GGGGNNNNN
            await dbHelper.cleanCartDatabase().then((value) {
              dbHelper.loadAddCardProducts(cardbloc);

              routestoHomeOrLocation(context);
            });
          });
        }
      }
    });
  }

  static routestoHomeOrLocation(BuildContext context) async {
    // // street = await SharedPref.getStringPreference(Constants.ADDRESS);
    // // locality = await SharedPref.getStringPreference(Constants.LOCALITY);
    // // if (isAddressEmpty()) {
    //   Navigator.pushNamed(context, Routes.location_screen,
    //       arguments: Routes.checkoutscreen);
    // } else {
    Navigator.of(context).pushReplacementNamed(Routes.home_page);
    // }
  }

  loadProductValicationforReorder(
      BuildContext context,
      List<ProductUnit> cartItems,
      String orderId,
      CardBloc cardBloc,
      DatabaseHelper dbhelper,
      Function callback) {
    List<ProductUnit> list_cOffers = [];
    List<ProductUnit> freeProducts = [];
    List<ProductUnit> list_product_offer = [];
    ApiProvider()
        .productValidationForOrderModification(cartItems, orderId, context, () {
      loadProductValicationforReorder(
          context, cartItems, orderId, cardBloc, dbhelper, callback);
    }).then((value) {
      // if (value != null && value != "") {
      //   if (value.toString().contains("sub_products")) {
      //     final responseData = jsonDecode(value.toString());
      //
      //     List<dynamic> jsonDataList = responseData["final_products"];
      //
      //     for (var finalproduct in jsonDataList) {
      //       if (finalproduct["sub_product"]
      //           .toString()
      //           .contains("sub_products")) {
      //         List<dynamic> subproducts =
      //             finalproduct["sub_product"]["sub_products"];
      //
      //         debugPrint("Final Products Found 1 ${subproducts}");
      //
      //         for (var unitproduct in subproducts) {
      //           var c_offer_info = unitproduct['c_offer_info'];
      //           var add_item = unitproduct['add_item'];
      //           var quantity = unitproduct['quantity'];
      //           var total = unitproduct['total'];
      //           var orp = unitproduct['orp'];
      //
      //           ProductUnit unit =
      //               ProductUnit.fromJson(jsonEncode(unitproduct));
      //
      //           SubProduct sub = SubProduct();
      //           sub.cOfferInfo = c_offer_info;
      //           unit.subProduct = sub;
      //           unit.addQuantity = int.parse(add_item.toString() ?? "0");
      //           unit.quantity = quantity.toString();
      //           unit.specialPrice = total;
      //           unit.price = total.toString();
      //
      //           list_cOffers.add(unit);
      //           debugPrint("Final Products Found ${list_cOffers.length}");
      //           // cardBloc.add(
      //           //     CardAddcOfferProdutsEvent(
      //           //         unit: unit));
      //           // list_cOffers.add(unit);
      //           debugPrint("Dialog close here ${list_cOffers.length}");
      //         }
      //       }
      //     }
      //   }
      //
      //   if (value.toString().contains("offer_alert")) {
      //     final responseData = jsonDecode(value.toString());
      //     String offerAlert = responseData["offer_alert"].toString();
      //     if (offerAlert == "true") {
      //       if (value.toString().contains("message")) {
      //         String offerMessage = responseData["message"].toString();
      //         debugPrint(" offerMessage >>${offerMessage}");
      //         MyDialogs.showProductOffersDialog(context, offerMessage, () {
      //           Navigator.pop(context);
      //           Navigator.pushNamed(
      //             context,
      //             Routes.checkoutscreen,
      //             arguments: {
      //               'list': list_cOffers,
      //               'list_cOffers': list_cOffers,
      //             },
      //           ).then((value) {
      //             Appwidgets.setStatusBarColor();
      //             callback();
      //           });
      //         });
      //       }
      //     }
      //   } else if (value.toString().contains("free_bies")) {
      //     final responseData = jsonDecode(value.toString());
      //
      //     List<dynamic> jsonDataList =
      //         responseData["offer"]["free_bies"]["products"];
      //
      //     for (var jsonmodel in jsonDataList) {
      //       log("offer json productlist  ${jsonEncode(jsonmodel)}");
      //       ProductUnit unit = ProductUnit.fromJson(jsonEncode(jsonmodel));
      //       list_product_offer.add(unit);
      //       log("offer json productlist 22 ${unit.toMap()}");
      //     }
      //
      //     Appwidgets.showToastMessage("Free Product Available ");
      //     var subtitile = responseData["offer"]["free_bies"]["total_items_msg"];
      //     var description =
      //         responseData["offer"]["free_bies"]["offer_description"];
      //     var title = responseData["offer"]["free_bies"]["offer_title"];
      //     var mixed = responseData["offer"]["free_bies"]["mixed"];
      //     var recurring = responseData["offer"]["free_bies"]["is_recurring"];
      //     var totalitemAllowed =
      //         responseData["offer"]["free_bies"]["total_items_allowed"];
      //
      //     Navigator.pushNamed(
      //       context,
      //       Routes.productValidation,
      //       arguments: {
      //         'list': list_product_offer,
      //         'list_cOffers': list_cOffers,
      //         'title': title,
      //         'subtitle': subtitile,
      //         'details': description,
      //         'mixed': mixed,
      //         'recurring': recurring,
      //         'totalitemAllowed': totalitemAllowed,
      //       },
      //     ).then((value) {
      //       callback();
      //     });
      //   } else if (value.toString().contains("discounts")) {
      //     final responseData = jsonDecode(value.toString());
      //
      //     List<dynamic> jsonDataList =
      //         responseData["offer"]["discounts"]["products"];
      //
      //     debugPrint("offer json productlist >>${jsonEncode(jsonDataList)}");
      //
      //     for (var jsonmodel in jsonDataList) {
      //       ProductUnit unit = ProductUnit.fromJson(jsonEncode(jsonmodel));
      //       list_product_offer.add(unit);
      //     }
      //
      //     Appwidgets.showToastMessage("Free Product Available ");
      //     var subtitile = responseData["offer"]["discounts"]["total_items_msg"];
      //     var description =
      //         responseData["offer"]["discounts"]["offer_description"];
      //     var title = responseData["offer"]["discounts"]["offer_title"];
      //     var mixed = responseData["offer"]["discounts"]["mixed"];
      //     var recurring = responseData["offer"]["discounts"]["is_recurring"];
      //     var totalitemAllowed =
      //         responseData["offer"]["discounts"]["total_items_allowed"];
      //
      //     Navigator.pushNamed(
      //       context,
      //       Routes.productValidation,
      //       arguments: {
      //         'list': list_product_offer,
      //         'list_cOffers': list_cOffers,
      //         'title': title,
      //         'subtitle': subtitile,
      //         'details': description,
      //         'mixed': mixed,
      //         'recurring': recurring,
      //         'totalitemAllowed': totalitemAllowed,
      //       },
      //     ).then((value) {
      //       callback();
      //     });
      //   } else {
      //     Navigator.pushNamed(
      //       context,
      //       Routes.checkoutscreen,
      //       arguments: {
      //         'list': list_cOffers,
      //         'list_cOffers': list_cOffers,
      //       },
      //     ).then((value) {
      //       Appwidgets.setStatusBarColor();
      //       callback();
      //     });
      //   }
      // }
      if (value != null && value != "") {
        SharedPref.setStringPreference(
            Constants.OrderPlaceFlow, "Order Edited");
        SharedPref.setStringPreference(Constants.OrderidForEditOrder, orderId);

        if (value.toString().contains("sub_products")) {
          print("Product Validation for order Modification SUB PRODUCTS ");
          final responseData = jsonDecode(value.toString());

          List<dynamic> jsonDataList = responseData["final_products"];

          for (var finalproduct in jsonDataList) {
            if (finalproduct["sub_product"]
                .toString()
                .contains("sub_products")) {
              List<dynamic> subproducts =
                  finalproduct["sub_product"]["sub_products"];

              debugPrint("Final Products Found 1 ${subproducts}");

              for (var unitproduct in subproducts) {
                var c_offer_info = unitproduct['c_offer_info'];
                var add_item = unitproduct['add_item'];
                var quantity = unitproduct['quantity'];
                var total = unitproduct['total'];
                var orp = unitproduct['orp'];

                ProductUnit unit =
                    ProductUnit.fromJson(jsonEncode(unitproduct));

                SubProduct sub = SubProduct();
                sub.cOfferInfo = c_offer_info;
                unit.subProduct = sub;
                unit.addQuantity = int.parse(add_item.toString() ?? "0");
                unit.quantity = quantity.toString();
                unit.specialPrice = total;
                unit.price = total.toString();

                list_cOffers.add(unit);
                debugPrint("Final Products Found ${list_cOffers.length}");
                // cardBloc.add(
                //     CardAddcOfferProdutsEvent(
                //         unit: unit));
                // list_cOffers.add(unit);
                debugPrint("Dialog close here ${list_cOffers.length}");
              }
            }
          }
        } else if (value.toString().contains("offer_alert")) {
          print("Product Validation for order Modification OFFER ALERTS  ");
          final responseData = jsonDecode(value.toString());
          String offerAlert = responseData["offer_alert"].toString();
          if (offerAlert == "true") {
            if (value.toString().contains("message")) {
              String offerMessage = responseData["message"].toString();
              debugPrint(" offerMessage >>${offerMessage}");
              MyDialogs.showProductOffersDialog(context, offerMessage, () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  Routes.checkoutscreen,
                  arguments: {
                    'list': list_cOffers,
                    'list_cOffers': list_cOffers,
                  },
                ).then((value) {
                  Appwidgets.setStatusBarColor();
                  callback();
                });
              });
            }
          }
        } else if (value.toString().contains("free_bies")) {
          print("Product Validation for order Modification FREE BIES");
          final responseData = jsonDecode(value.toString());

          List<dynamic> jsonDataList =
              responseData["offer"]["free_bies"]["products"];

          for (var jsonmodel in jsonDataList) {
            log("offer json productlist  ${jsonEncode(jsonmodel)}");
            ProductUnit unit = ProductUnit.fromJson(jsonEncode(jsonmodel));
            list_product_offer.add(unit);
            log("offer json productlist 22 ${unit.toMap()}");
          }

          Appwidgets.showToastMessage("Free Product Available ");
          var subtitile = responseData["offer"]["free_bies"]["total_items_msg"];
          var description =
              responseData["offer"]["free_bies"]["offer_description"];
          var title = responseData["offer"]["free_bies"]["offer_title"];
          var mixed = responseData["offer"]["free_bies"]["mixed"];
          var recurring = responseData["offer"]["free_bies"]["is_recurring"];
          var totalitemAllowed =
              responseData["offer"]["free_bies"]["total_items_allowed"];

          Navigator.pushNamed(
            context,
            Routes.productValidation,
            arguments: {
              'list': list_product_offer,
              'list_cOffers': list_cOffers,
              'title': title,
              'subtitle': subtitile,
              'details': description,
              'mixed': mixed,
              'recurring': recurring,
              'totalitemAllowed': totalitemAllowed,
            },
          ).then((value) {
            callback();
          });
        } else if (value.toString().contains("discounts")) {
          print("Product Validation for order Modification DISCOUNTS");
          final responseData = jsonDecode(value.toString());

          List<dynamic> jsonDataList =
              responseData["offer"]["discounts"]["products"];

          debugPrint("offer json productlist >>${jsonEncode(jsonDataList)}");

          for (var jsonmodel in jsonDataList) {
            ProductUnit unit = ProductUnit.fromJson(jsonEncode(jsonmodel));
            list_product_offer.add(unit);
          }

          Appwidgets.showToastMessage("Free Product Available ");
          var subtitile = responseData["offer"]["discounts"]["total_items_msg"];
          var description =
              responseData["offer"]["discounts"]["offer_description"];
          var title = responseData["offer"]["discounts"]["offer_title"];
          var mixed = responseData["offer"]["discounts"]["mixed"];
          var recurring = responseData["offer"]["discounts"]["is_recurring"];
          var totalitemAllowed =
              responseData["offer"]["discounts"]["total_items_allowed"];

          Navigator.pushNamed(
            context,
            Routes.productValidation,
            arguments: {
              'list': list_product_offer,
              'list_cOffers': list_cOffers,
              'title': title,
              'subtitle': subtitile,
              'details': description,
              'mixed': mixed,
              'recurring': recurring,
              'totalitemAllowed': totalitemAllowed,
            },
          ).then((value) {
            callback();
          });
        } else {
          print("Product Validation for order Modification else condition");
          // Navigator.pushNamed(context,
          //     Routes.checkoutscreen)
          //     .then((value) {
          //   callback();
          //   dbhelper
          //       .loadAddCardProducts(cardBloc);
          //
          //   if (isup == false) {
          //     Navigator.pop(context);
          //   }
          // });
          Navigator.pop(context);
          Navigator.pushNamed(
            context,
            Routes.checkoutscreen,
            arguments: {
              'list': list_cOffers,
              'list_cOffers': list_cOffers,
            },
          ).then((value) {
            callback();
          });
        }
      }
    });
  }
}
