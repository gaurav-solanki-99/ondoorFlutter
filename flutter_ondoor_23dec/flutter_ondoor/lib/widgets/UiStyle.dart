import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/Constant.dart';
import '../constants/FontConstants.dart';
import '../constants/ImageConstants.dart';
import '../constants/StringConstats.dart';
import '../database/database_helper.dart';
import '../database/dbconstants.dart';
import '../models/AllProducts.dart';
import '../models/HomepageModel.dart';
import '../screens/AddCard/card_bloc.dart';
import '../screens/AddCard/card_event.dart';
import '../screens/FeaturedProduct/FeatuuredBloc/featured_bloc.dart';
import '../screens/FeaturedProduct/FeatuuredBloc/featured_event.dart';
import '../screens/FeaturedProduct/FeatuuredBloc/featured_state.dart';
import '../screens/shop_by_category/shop_by_category_bloc/shop_by_category_bloc.dart';
import '../services/Navigation/routes.dart';
import '../utils/Commantextwidget.dart';
import '../utils/SizeConfig.dart';
import '../utils/Utility.dart';
import '../utils/colors.dart';
import '../utils/sharedpref.dart';
import '../utils/themeData.dart';
import 'AppWidgets.dart';
import 'MyDialogs.dart';
import 'common_cached_image_widget.dart';

class Uistyle {
  static ui_appbar(BuildContext context, String title, String? image,
      var titlecolor, var backgroundcolor, Function() onpress) {
    var decoration;

    if (image!.isEmpty || image == "" || image == null || image == "null") {
      decoration = BoxDecoration(color: backgroundcolor);
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // transparent status bar
        statusBarIconBrightness:
            Brightness.light, // dark icons on the status bar
      ));
      print("APP bar ${image}");
      decoration = BoxDecoration(
        color: backgroundcolor ?? Colors.transparent,
        image: DecorationImage(
          image: FileImage(File(image!)),
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
        height: 80,
        width: Sizeconfig.getWidth(context),
        decoration: decoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(),
            Container(
              child: Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: Sizeconfig.getWidth(context),
                      padding: EdgeInsets.only(bottom: 10),
                      child: Center(
                        child: Text(title,
                            style: TextStyle(
                              fontSize: 17,
                              fontFamily: Fontconstants.fc_family_sf,
                              fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
                              color: titlecolor,
                            )),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: Container(
                      margin: EdgeInsets.only(left: 5),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: IconButton(
                          icon: Icon(Icons.home, color: Colors.white),
                          onPressed: () {
                            try {
                              Navigator.of(context)
                                  .pushReplacementNamed(Routes.home_page);
                            } catch (e) {
                              debugPrint("Exeption " + e.toString());
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  static ui_type_appbar(
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

                      // For Manage card list product Quanityt
                      if (state is ProductUpdateQuantityInitialState) {
                        list = state.list!;
                      }

                      return Container(
                          height: Sizeconfig.getHeight(context) * 0.28,
                          color: Colors.white,
                          // padding: const EdgeInsets.only(top: 10),
                          child: Container(
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
                                    if (list![index].unit!.length == 1) {
                                      debugPrint("Quanititycondition  1 ");

                                      if (dummyData.productId ==
                                          state.model.productId) {
                                        dummyData.addQuantity =
                                            state.model.addQuantity;
                                        //G  bloc.add(ProductNullEvent());
                                      }
                                    } else {
                                      for (var obj in list![index].unit!) {
                                        if (obj.name == state.model.name ||
                                            obj.productId ==
                                                state.model.productId) {
                                          debugPrint(
                                              "G>>>>>>>>>>>>>>>>>>>>    " +
                                                  state.model.addQuantity
                                                      .toString());

                                          debugPrint("G>>>>>>Index    " +
                                              isMoreUnitIndex.toString());

                                          if (dummyData!.cOfferId != 0 &&
                                              dummyData.cOfferId != null) {
                                            debugPrint(
                                                "##***********************");
                                            if (dummyData.subProduct != null) {
                                              log("##***********************>>>>>>>>>>>>>>>>" +
                                                  dummyData.subProduct!
                                                      .toJson());

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
                                                  dummyData.subProduct!
                                                      .toJson());
                                              if (dummyData
                                                      .subProduct!
                                                      .subProductDetail!
                                                      .length >
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
                                  return GestureDetector(
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
                                          'fromchekcout': fromchekcout,
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
                                                      width:
                                                          Sizeconfig.getWidth(
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
                                                                            .circular(5),
                                                                    border: Border.all(
                                                                        width:
                                                                            1,
                                                                        color: ColorName
                                                                            .newgray),
                                                                  ),
                                                                  child: Center(
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              0),
                                                                      child:
                                                                          Stack(
                                                                        children: [
                                                                          Center(
                                                                            child:
                                                                                Container(
                                                                              padding: EdgeInsets.all(4),
                                                                              height: Sizeconfig.getWidth(context) * .25,
                                                                              width: Sizeconfig.getWidth(context) * .25,
                                                                              child: CommonCachedImageWidget(
                                                                                imgUrl: dummyData.image!,
                                                                                height: Sizeconfig.getWidth(context) * .25,
                                                                                width: Sizeconfig.getWidth(context) * .25,
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
                                                                            dummyData.name!,
                                                                            maxLines:
                                                                                2,
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 12,
                                                                              fontFamily: Fontconstants.fc_family_sf,
                                                                              fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
                                                                              color: Colors.black,
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
                                                                      onTap:
                                                                          () {
                                                                        if (isMoreunit) {
                                                                          MyDialogs.optionDialog(context, list![index].unit!, dummyData)
                                                                              .then((value) {
                                                                            isMoreUnitIndex = list![index].unit!.indexWhere((model) =>
                                                                                model ==
                                                                                value);
                                                                            value.selectedUnitIndex =
                                                                                isMoreUnitIndex;
                                                                            debugPrint("Dialog value ${index} ${value.name} ");

                                                                            for (int i = 0;
                                                                                i < list![index].unit!.length;
                                                                                i++) {
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
                                                                          width:
                                                                              Sizeconfig.getWidth(context) * .20,
                                                                          child:
                                                                              Align(
                                                                            alignment:
                                                                                Alignment.center,
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
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
                                                          height: Sizeconfig
                                                                  .getWidth(
                                                                      context) *
                                                              0.08,
                                                          child: dummyData
                                                                      .addQuantity !=
                                                                  0
                                                              ? Container(
                                                                  alignment:
                                                                      Alignment
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
                                                                        int.parse(dummyData
                                                                            .orderQtyLimit!
                                                                            .toString()!)) {
                                                                      Fluttertoast.showToast(
                                                                          msg: StringContants
                                                                              .msg_quanitiy);
                                                                    } else {
                                                                      dummyData
                                                                              .addQuantity =
                                                                          dummyData.addQuantity +
                                                                              1;
                                                                      bloc.add(ProductUpdateQuantityEvent(
                                                                          quanitity: dummyData
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

                                                                        dbHelper
                                                                            .loadAddCardProducts(cardBloc);
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
                                                    Positioned(
                                                        top: 0,
                                                        left: 0,
                                                        child:
                                                            (dummyData.discountText ??
                                                                        "") ==
                                                                    ""
                                                                ? Container()
                                                                : Visibility(
                                                                    visible: (dummyData!.discountText !=
                                                                            "" ||
                                                                        dummyData!.discountText !=
                                                                            null),
                                                                    child:
                                                                        Positioned(
                                                                      // left: 7,
                                                                      left: 0,
                                                                      top: 0,
                                                                      child:
                                                                          Stack(
                                                                        alignment:
                                                                            Alignment.center,
                                                                        children: [
                                                                          ClipRRect(
                                                                            borderRadius:
                                                                                BorderRadius.only(topLeft: Radius.circular(5.0)),
                                                                            child:
                                                                                Image.asset(
                                                                              Imageconstants.img_tag,
                                                                              height: 25,
                                                                              width: 31,
                                                                              fit: BoxFit.fill,
                                                                            ),
                                                                          ),
                                                                          Align(
                                                                            alignment:
                                                                                Alignment.center,
                                                                            child:
                                                                                Text(
                                                                              dummyData.discountText ?? "",
                                                                              overflow: TextOverflow.ellipsis,
                                                                              maxLines: 2,
                                                                              style: const TextStyle(
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
                                                    : index !=
                                                            (list!.length - 1)
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
                                  );
                                }),
                          ));
                    }),
              );
  }

  static ui_type1(
      bool fromchekcout,
      BuildContext context,
      String title,
      String subtitle,
      dynamic state,
      List<ProductData>? list,
      FeaturedBloc bloc,
      int isMoreUnitIndex,
      CardBloc cardBloc,
      DatabaseHelper dbHelper,
      ScrollController _scrollController,
      bool loadMore,
      var themecolor,
      var commontextcolor,
      var titlecolor) {
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

                      // For Manage card list product Quanityt
                      if (state is ProductUpdateQuantityInitialState) {
                        list = state.list!;
                      }

                      return Container(
                          height: Sizeconfig.getHeight(context) < 800
                              ? Sizeconfig.getHeight(context) * 0.46
                              : Sizeconfig.getHeight(context) * 0.44,
                          color: themecolor,
                          // padding: const EdgeInsets.only(top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    width: Sizeconfig.getWidth(context) * 0.8,
                                    child: Center(
                                        child: CommanTextWidget.subheading(
                                            title, titlecolor)
                                        /* Text(title.toUpperCase(),
                                style: TextStyle(
                                    letterSpacing: 2,
                                    wordSpacing: 5,
                                    fontSize:
                                    Constants.SizeExtralagre,
                                    fontFamily:
                                    Fontconstants.fc_family_sf,
                                    fontWeight: Fontconstants
                                        .SF_Pro_Display_SEMIBOLD,
                                    color: titlecolor)),*/
                                        )

                                    // Image.asset(Imageconstants.img_eclusiveoffer)

                                    ),
                              ),
                              Container(
                                height: Sizeconfig.getHeight(context) < 800
                                    ? Sizeconfig.getHeight(context) * 0.36
                                    : Sizeconfig.getHeight(context) * 0.32,
                                child: ListView.builder(
                                    controller: _scrollController,
                                    shrinkWrap: true,
                                    itemCount: list!.length,
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
                                        debugPrint(
                                            "LIST Featured Product State  " +
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
                                        if (list![index].unit!.length == 1) {
                                          debugPrint("Quanititycondition  1 ");

                                          if (dummyData.productId ==
                                              state.model.productId) {
                                            dummyData.addQuantity =
                                                state.model.addQuantity;
                                            //G  bloc.add(ProductNullEvent());
                                          }
                                        } else {
                                          for (var obj in list![index].unit!) {
                                            if (obj.name == state.model.name ||
                                                obj.productId ==
                                                    state.model.productId) {
                                              debugPrint(
                                                  "G>>>>>>>>>>>>>>>>>>>>    " +
                                                      state.model.addQuantity
                                                          .toString());

                                              debugPrint("G>>>>>>Index    " +
                                                  isMoreUnitIndex.toString());

                                              if (dummyData!.cOfferId != 0 &&
                                                  dummyData.cOfferId != null) {
                                                debugPrint(
                                                    "##***********************");
                                                if (dummyData.subProduct !=
                                                    null) {
                                                  log("##***********************>>>>>>>>>>>>>>>>" +
                                                      dummyData.subProduct!
                                                          .toJson());

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
                                              debugPrint("##****" +
                                                  state!.model!.name!);

                                              if (dummyData!.cOfferId != 0 &&
                                                  dummyData.cOfferId != null) {
                                                debugPrint(
                                                    "##***********************");
                                                if (dummyData.subProduct !=
                                                    null) {
                                                  log("##***********************>>>>>>>>>>>>>>>>" +
                                                      dummyData.subProduct!
                                                          .toJson());
                                                  if (dummyData
                                                          .subProduct!
                                                          .subProductDetail!
                                                          .length >
                                                      0) {
                                                    List<ProductUnit>?
                                                        listsubproduct =
                                                        dummyData.subProduct!
                                                            .subProductDetail!;

                                                    for (int x = 0;
                                                        x <
                                                            listsubproduct
                                                                .length;
                                                        x++) {
                                                      getCartQuantity(
                                                              listsubproduct[x]
                                                                  .productId!)
                                                          .then((value) {
                                                        debugPrint(
                                                            "${listsubproduct[x].name} Sub Product Quantity quanityt ${value}");
                                                        listsubproduct[x]
                                                                .addQuantity =
                                                            value;
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

                                      if (state is ProductUnitState) {
                                        if (dummyData.productId ==
                                            state.unit.productId) {
                                          dummyData = state.unit;
                                        }
                                      }

                                      return GestureDetector(
                                        onTap: () async {
                                          for (int i = 0;
                                              i < list![index].unit!.length!;
                                              i++) {
                                            debugPrint(
                                                "Model  ${dummyData.productId} ${dummyData.addQuantity} ");
                                            if (dummyData.productId ==
                                                list![index]
                                                    .unit![i]
                                                    .productId!) {
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
                                              'fromchekcout': fromchekcout,
                                              'list': list![index].unit!,
                                              'index': isMoreunit
                                                  ? isMoreUnitIndex
                                                  : index,
                                            },
                                          ).then((value) async {
                                            ProductUnit unit =
                                                value as ProductUnit;
                                            debugPrint(
                                                "FeatureCallback ${value.addQuantity}");
                                            SystemChrome
                                                .setSystemUIOverlayStyle(
                                                    SystemUiOverlayStyle(
                                              statusBarColor: Colors
                                                  .transparent, // transparent status bar
                                              statusBarIconBrightness: Brightness
                                                  .light, // dark icons on the status bar
                                            ));
                                            bloc.add(ProductUpdateQuantityEvent(
                                                quanitity: unit.addQuantity!,
                                                index: index));
                                          });
                                        },
                                        child: Stack(
                                          children: [
                                            Padding(
                                              padding: index == 0
                                                  ? EdgeInsets.only(left: 10)
                                                  : EdgeInsets.symmetric(
                                                      horizontal: 0,
                                                      vertical: 0),
                                              child: Card(
                                                elevation: 0,
                                                color: themecolor,
                                                child: Row(
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        Container(
                                                          // height: Sizeconfig.getHeight(context)*0.2,
                                                          width: Sizeconfig
                                                                  .getWidth(
                                                                      context) *
                                                              0.36,
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
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        borderRadius:
                                                                            BorderRadius.circular(5),
                                                                        border: Border.all(
                                                                            width:
                                                                                1,
                                                                            color:
                                                                                ColorName.newgray),
                                                                      ),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              EdgeInsets.symmetric(horizontal: 0),
                                                                          child:
                                                                              Stack(
                                                                            children: [
                                                                              Center(
                                                                                child: Container(
                                                                                  height: Sizeconfig.getWidth(context) * .25,
                                                                                  padding: EdgeInsets.all(4),
                                                                                  width: Sizeconfig.getWidth(context) * .25,
                                                                                  child: CommonCachedImageWidget(
                                                                                    imgUrl: dummyData.image!,
                                                                                    width: Sizeconfig.getWidth(context) * .25,
                                                                                    height: Sizeconfig.getWidth(context) * .25,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Positioned(
                                                                        bottom:
                                                                            5,
                                                                        right:
                                                                            5,
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
                                                                  flex: 4,
                                                                  child:
                                                                      /*   Container(
                                                          child:
                                                          Column(
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
                                                                    child: Text(
                                                                      dummyData.name!,
                                                                      maxLines: 2,
                                                                      style: TextStyle(
                                                                        fontSize: 12,
                                                                        fontFamily: Fontconstants.fc_family_sf,
                                                                        fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
                                                                        color: commontextcolor,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  (dummyData!.cOfferId != 0 && dummyData.cOfferId != null)
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
                                                                      child: Container(
                                                                        margin: EdgeInsets.only(top: 2),
                                                                        child: Image.asset(
                                                                          Imageconstants.img_giftoffer,
                                                                          height: 20,
                                                                          width: 20,
                                                                          color: commontextcolor,
                                                                        ),
                                                                      ))
                                                                      : Container()
                                                                ],
                                                              ),
                                                              InkWell(
                                                                onTap:
                                                                    () {
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
                                                                child:
                                                                Container(
                                                                  child:
                                                                  Container(
                                                                    margin: isMoreunit ? EdgeInsets.only(top: 5) : null,
                                                                    width: Sizeconfig.getWidth(context) * .20,
                                                                    child: Align(
                                                                      alignment: Alignment.center,
                                                                      child: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text(
                                                                            dummyData.productWeight.toString() + " ${dummyData.productWeightUnit}",
                                                                            style: TextStyle(
                                                                              fontSize: Constants.SizeSmall,
                                                                              fontFamily: Fontconstants.fc_family_sf,
                                                                              fontWeight: Fontconstants.SF_Pro_Display_Bold,
                                                                              color: isMoreunit ? commontextcolor : commontextcolor,
                                                                            ),
                                                                          ),
                                                                          Visibility(
                                                                              visible: isMoreunit,
                                                                              child: Container(
                                                                                width: 10,
                                                                                height: 10,
                                                                                child: Image.asset(
                                                                                  Imageconstants.img_dropdownarrow,
                                                                                  color: commontextcolor,
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
                                                                Alignment.bottomCenter,
                                                                child:
                                                                Row(
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Column(
                                                                      children: [
                                                                        Text(
                                                                          dummyData.specialPrice == "" ? "" : "₹ ${double.parse(dummyData.price!).toStringAsFixed(2)}",
                                                                          style: TextStyle(fontSize: Constants.SizeSmall,
                                                                           fontFamily: Fontconstants.fc_family_sf, fontWeight:
                                                                           Fontconstants.SF_Pro_Display_Medium, letterSpacing: 0,
                                                                            decoration: TextDecoration.lineThrough,
                                                                            decorationColor: ColorName.textlight, color: commontextcolor),
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
                                                                                color: commontextcolor,
                                                                              ),
                                                                            )),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )*/
                                                                      Container(
                                                                    padding: EdgeInsets
                                                                        .symmetric(
                                                                            horizontal:
                                                                                0),
                                                                    child:
                                                                        Column(
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
                                                                        2.toSpace,
                                                                        Container(
                                                                          height:
                                                                              Sizeconfig.getHeight(context) * 0.05,
                                                                          child:
                                                                              CommanTextWidget.regularBold(
                                                                            dummyData.name!,
                                                                            commontextcolor,
                                                                            maxline:
                                                                                2,
                                                                            trt:
                                                                                TextStyle(
                                                                              fontSize: 14,
                                                                              height: 1.0,
                                                                              fontWeight: FontWeight.w600,
                                                                            ),
                                                                            textalign:
                                                                                TextAlign.start,
                                                                          ),
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

                                                                        1.toSpace,
                                                                        Row(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Container(
                                                                              child: InkWell(
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
                                                                                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(4.0)), border: Border.all(width: 0.6, color: commontextcolor.withOpacity(0.5))),
                                                                                        child: Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                          children: [
                                                                                            Container(
                                                                                                padding: EdgeInsets.symmetric(horizontal: 8),
                                                                                                child: CommanTextWidget.regularBold(
                                                                                                  dummyData.productWeight.toString() + " ${dummyData.productWeightUnit}",
                                                                                                  commontextcolor,
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
                                                                                    : Container(
                                                                                        // height: 20,
                                                                                        padding: EdgeInsets.symmetric(horizontal: 8),
                                                                                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(4.0)), border: Border.all(width: 0.6, color: commontextcolor.withOpacity(0.5))),
                                                                                        child: CommanTextWidget.regularBold(
                                                                                          dummyData.productWeight.toString() + " ${dummyData.productWeightUnit}",
                                                                                          commontextcolor,
                                                                                          maxline: 2,
                                                                                          trt: TextStyle(
                                                                                            fontSize: 14,
                                                                                            fontWeight: FontWeight.w600,
                                                                                          ),
                                                                                          textalign: TextAlign.start,
                                                                                        ),
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
                                                                              alignment: Alignment.bottomLeft,
                                                                              child: Container(
                                                                                padding: EdgeInsets.only(bottom: 1),
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    // Text(
                                                                                    //   dummyData.specialPrice == "" ? "" : "₹ ${double.parse(dummyData.price!).toStringAsFixed(2)}",
                                                                                    //   style: TextStyle(fontSize: 10, fontFamily: Fontconstants.fc_family_sf, fontWeight: Fontconstants.SF_Pro_Display_Medium, letterSpacing: 0, decoration: TextDecoration.lineThrough, decorationColor: textsecondary, color: textsecondary),
                                                                                    // ),

                                                                                    CommanTextWidget.regularBold(
                                                                                      dummyData.specialPrice == "" ? "" : "₹ ${double.parse(dummyData.price!).toStringAsFixed(2)}",
                                                                                      commontextcolor,
                                                                                      maxline: 1,
                                                                                      trt: TextStyle(
                                                                                        fontSize: 11,
                                                                                        height: 1,
                                                                                        decoration: TextDecoration.lineThrough,
                                                                                        decorationColor: commontextcolor,
                                                                                        fontWeight: FontWeight.w600,
                                                                                      ),
                                                                                      textalign: TextAlign.start,
                                                                                    ),
                                                                                    Visibility(
                                                                                      visible: dummyData.specialPrice != "",
                                                                                      child: SizedBox(
                                                                                        width: 5,
                                                                                      ),
                                                                                    ),
                                                                                    // Text(
                                                                                    //   dummyData.specialPrice == "" ? "₹ ${double.parse(dummyData.sortPrice!).toStringAsFixed(2)}" : "₹ ${double.parse(dummyData.specialPrice!).toStringAsFixed(2)}",
                                                                                    //   style: TextStyle(
                                                                                    //     fontSize: Constants.SizeMidium,
                                                                                    //     fontFamily: Fontconstants.fc_family_sf,
                                                                                    //     fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
                                                                                    //     color: textcolor,
                                                                                    //   ),
                                                                                    // ),
                                                                                    2.toSpace,

                                                                                    CommanTextWidget.regularBold(
                                                                                      dummyData.specialPrice == "" ? "₹ ${double.parse(dummyData.sortPrice!).toStringAsFixed(2)}" : "₹ ${double.parse(dummyData.specialPrice!).toStringAsFixed(2)}",
                                                                                      commontextcolor,
                                                                                      maxline: 1,
                                                                                      trt: TextStyle(
                                                                                        fontSize: 12,
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
                                                        Positioned(
                                                          right: 0,
                                                          bottom: 0,
                                                          child: Container(
                                                              height: Sizeconfig
                                                                      .getWidth(
                                                                          context) *
                                                                  0.08,
                                                              child: dummyData
                                                                          .addQuantity !=
                                                                      0
                                                                  ? Container(
                                                                      alignment:
                                                                          Alignment
                                                                              .bottomRight,
                                                                      child: AddQuantityButton(
                                                                          commontextcolor,
                                                                          ColorName
                                                                              .ColorPrimary,
                                                                          StringContants
                                                                              .lbl_add,
                                                                          dummyData.addQuantity!
                                                                              as int,
                                                                          () {
                                                                        //increase

                                                                        if (dummyData.addQuantity ==
                                                                            int.parse(dummyData.orderQtyLimit!.toString())) {
                                                                          Fluttertoast.showToast(
                                                                              msg: StringContants.msg_quanitiy);
                                                                        } else {
                                                                          dummyData.addQuantity =
                                                                              dummyData.addQuantity + 1;
                                                                          bloc.add(ProductUpdateQuantityEvent(
                                                                              quanitity: dummyData.addQuantity!,
                                                                              index: index));
                                                                          bloc.add(
                                                                              ProductChangeEvent(model: dummyData));
                                                                          updateCard(
                                                                              dummyData,
                                                                              dbHelper,
                                                                              cardBloc);
                                                                          debugPrint(
                                                                              "Scroll Event1111 ");
                                                                        }
                                                                      }, () async {
                                                                        if (dummyData.addQuantity ==
                                                                            1) {
                                                                          debugPrint(
                                                                              "SHOPBY 1");
                                                                          dummyData.addQuantity =
                                                                              0;

                                                                          bloc.add(
                                                                              ProductUpdateQuantityEventBYModel(model: dummyData));

                                                                          await dbHelper
                                                                              .deleteCard(int.parse(dummyData.productId!))
                                                                              .then((value) {
                                                                            debugPrint("Delete Product $value ");

                                                                            // cardBloc.add(CardDeleteEvent(
                                                                            //     model: model,
                                                                            //     listProduct:  list![0].unit!));

                                                                            dbHelper.loadAddCardProducts(cardBloc);
                                                                          });
                                                                        } else if (dummyData.addQuantity !=
                                                                            0) {
                                                                          debugPrint(
                                                                              "SHOPBY 2");
                                                                          dummyData.addQuantity =
                                                                              dummyData.addQuantity - 1;

                                                                          updateCard(
                                                                              dummyData,
                                                                              dbHelper,
                                                                              cardBloc);
                                                                          bloc.add(
                                                                              ProductUpdateQuantityEventBYModel(model: dummyData));

                                                                          bloc.add(
                                                                              ProductChangeEvent(model: dummyData));
                                                                        }
                                                                      }),
                                                                    )
                                                                  : buttonPrimary(
                                                                      commontextcolor,
                                                                      ColorName
                                                                          .ColorPrimary,
                                                                      StringContants
                                                                          .lbl_add,
                                                                      () {
                                                                        dummyData
                                                                            .addQuantity = dummyData
                                                                                .addQuantity +
                                                                            1;
                                                                        checkItemId(dummyData.productId!,
                                                                                dbHelper)
                                                                            .then((value) {
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
                                                                                dummyData.addQuantity!,
                                                                            index: index));
                                                                        bloc.add(ProductChangeEvent(
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
                                                                      visible: (dummyData.discountText !=
                                                                              "" ||
                                                                          dummyData.discountText !=
                                                                              null),
                                                                      child:
                                                                          Stack(
                                                                        alignment:
                                                                            Alignment.center,
                                                                        children: [
                                                                          ClipRRect(
                                                                            borderRadius:
                                                                                BorderRadius.only(topLeft: Radius.circular(5)),
                                                                            child:
                                                                                Image.asset(
                                                                              Imageconstants.img_tag,
                                                                              height: 40,
                                                                              width: 38,
                                                                              fit: BoxFit.fill,
                                                                            ),
                                                                          ),
                                                                          Align(
                                                                            alignment:
                                                                                Alignment.center,
                                                                            // alignment: Alignment.center,
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                              child: Text(
                                                                                dummyData.discountText ?? "",
                                                                                overflow: TextOverflow.ellipsis,
                                                                                maxLines: 2,
                                                                                style: const TextStyle(
                                                                                  color: ColorName.black,
                                                                                  fontSize: 9.5,
                                                                                  fontWeight: FontWeight.w700,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                        ),
                                                      ],
                                                    ),
                                                    loadMore == false
                                                        ? Container()
                                                        : index !=
                                                                    (list!.length -
                                                                        1) ||
                                                                list!.length < 4
                                                            ? Container()
                                                            : Container(
                                                                height: 30,
                                                                width: 30,
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            10),
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  color:
                                                                      commontextcolor,
                                                                ))
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                              ),
                            ],
                          ));
                    }),
              );
  }

  //Trending Ite
  //Trending Ite
  static ui_type5(
      bool fromchekcout,
      BuildContext context,
      String title,
      String subtitle,
      dynamic state,
      List<ProductData>? list,
      FeaturedBloc bloc,
      int isMoreUnitIndex,
      CardBloc cardBloc,
      DatabaseHelper dbHelper,
      ScrollController _scrollController,
      bool loadMore,
      var themecolor,
      var commontextcolor,
      var titlecolor,
      String? image,
      Function callback) {
    debugPrint("similarProductsUI  ${list!.length} ${loadMore}");

    /* bool firstRowActive=false;
    bool secondRowActive =false;

    if(list!.length>3)
      {
        for(int i=0;i<3;i++)
          {
            var dummyData = list![i].unit![0];
            if ((dummyData!.cOfferId != 0 && dummyData.cOfferId != null))
              {
                firstRowActive=true;
                bloc.add(ProductNullEvent());
                bloc.add(OfferRowEvent(row: 1, status: secondRowActive));
              }
            debugPrint("OFFER_PRESENT_IN_ROW $firstRowActive");
          }
      }

    if(list!.length>3)
    {
      for(int i=3;i<list!.length;i++)
      {
        var dummyData = list![i].unit![0];
        if ((dummyData!.cOfferId != 0 && dummyData.cOfferId != null))
        {
          secondRowActive=true;
          bloc.add(ProductNullEvent());
          bloc.add(OfferRowEvent(row: 2, status: secondRowActive));

          debugPrint("OFFER_PRESENT_IN_ROW $secondRowActive");
        }
      }
    }
*/

    var headingview;
    int giftindex = 0;

    if (image!.isEmpty || image == "" || image == null || image == "null") {
      headingview = Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: Sizeconfig.getWidth(context),
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  child: CommanTextWidget.subheading(title, titlecolor)
                  //Appwidgets.TextLagre(title, titlecolor),
                  ),
            ),
            Container(
              width: Sizeconfig.getWidth(context),
              child: CommanTextWidget.subtitle(subtitle, titlecolor),
            ),
          ],
        ),
      );
    } else {
      // headingview = Container(
      //     padding: EdgeInsets.symmetric(vertical: 3),
      //     decoration: BoxDecoration(
      //       color: themecolor ?? Colors.transparent,
      //       image: DecorationImage(
      //         image: FileImage(File(image)),
      //         fit: BoxFit.cover,
      //       ),
      //     ),
      //     child: Container(
      //       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      //       child: Column(
      //         mainAxisAlignment: MainAxisAlignment.start,
      //         children: [
      //           Container(
      //             width: Sizeconfig.getWidth(context),
      //             child: Padding(
      //               padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      //               child: Appwidgets.TextLagre("", titlecolor),
      //             ),
      //           ),
      //           Container(
      //             width: Sizeconfig.getWidth(context),
      //             child: Appwidgets.TextRegular("", titlecolor),
      //           ),
      //         ],
      //       ),
      //     ));

      headingview = Container(
        width: Sizeconfig.getWidth(context),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                      child: CommanTextWidget.subheading(title, titlecolor)
                      //Appwidgets.TextLagre(title, titlecolor),
                      ),
                ),
                Container(
                  child: CommanTextWidget.subtitle(subtitle.trim(), titlecolor),
                ),
              ],
            ),
            Image(
              image: FileImage(File(image)),
              fit: BoxFit.cover,
              height: 50,
            ),
          ],
        ),
      );
    }
    final double itemWidth = (Sizeconfig.getWidth(context)) / 3; // 3 columns

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
                      if (state is OfferRowState) {
                        /*   debugPrint(
                              "Featured Product State %%%%%%  ${state.row } ${state.status} " );
                          if(state.row==1)
                            {
                              firstRowActive=state.status;
                            }

                          if(state.row==2)
                          {
                            secondRowActive=state.status;
                          }*/
                      }

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

                      // For Manage card list product Quanityt
                      if (state is ProductUpdateQuantityInitialState) {
                        list = state.list!;
                      }

                      int line = (list!.length / 3).round();

                      debugPrint("Uitype5 Size " + line.toString());

                      if (line == 0) {
                        line = 1;
                      }

                      if (state is ProductUnitState) {
                        for (int i = 0; i < list!.length; i++) {
                          var dummyData = list![i].unit![0];

                          if (dummyData.productId == state.unit.productId) {
                            dummyData = state.unit;
                            list![i].unit![0] = dummyData!;
                          }
                        }
                      }
                      int selectedIndex = -1;
                      return Container(
                          //height: Sizeconfig.getHeight(context) * 0.60,
                          color: themecolor,
                          // padding: const EdgeInsets.only(top: 10),
                          child: Column(
                            children: [
                              headingview,
                              Container(
                                // height: line * Sizeconfig.getHeight(context) * 0.25,
                                margin: EdgeInsets.symmetric(horizontal: 5),
                                //  color: Colors.red,
                                child: StaggeredGridView.countBuilder(
                                  // gridDelegate:
                                  //     const SliverGridDelegateWithFixedCrossAxisCount(
                                  //   crossAxisCount: 3, // Number of columns
                                  //   crossAxisSpacing:
                                  //       2.0, // Spacing between columns
                                  //   mainAxisSpacing: 2.0,
                                  //   childAspectRatio:
                                  //       0.54, // Spacing between rows
                                  // ),
                                  controller: _scrollController,
                                  shrinkWrap: true,
                                  itemCount:
                                      (list!.length == 4 || list!.length == 5)
                                          ? 3
                                          : list!.length > 6
                                              ? 6
                                              : list!.length,
                                  scrollDirection: Axis.vertical,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    var dummyData = list![index].unit![0];
                                    bool isMoreunit = false;

                                    debugPrint("Trending Object  " +
                                        dummyData.toJson());
                                    if (list![index].unit!.length > 1) {
                                      isMoreunit = true;
                                    }

                                    if (state
                                        is ProductUpdateQuantityStateBYModel) {
                                      debugPrint(
                                          "LIST Featured Product State  " +
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
                                      if (list![index].unit!.length == 1) {
                                        debugPrint("Quanititycondition  1 ");

                                        if (dummyData.productId ==
                                            state.model.productId) {
                                          dummyData.addQuantity =
                                              state.model.addQuantity;
                                          //G  bloc.add(ProductNullEvent());
                                        }
                                      } else {
                                        for (var obj in list![index].unit!) {
                                          if (obj.name == state.model.name ||
                                              obj.productId ==
                                                  state.model.productId) {
                                            debugPrint(
                                                "G>>>>>>>>>>>>>>>>>>>>    " +
                                                    state.model.addQuantity
                                                        .toString());

                                            debugPrint("G>>>>>>Index    " +
                                                isMoreUnitIndex.toString());

                                            if (dummyData!.cOfferId != 0 &&
                                                dummyData.cOfferId != null) {
                                              debugPrint(
                                                  "##***********************");
                                              if (dummyData.subProduct !=
                                                  null) {
                                                log("##***********************>>>>>>>>>>>>>>>>" +
                                                    dummyData.subProduct!
                                                        .toJson());

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
                                              if (dummyData.subProduct !=
                                                  null) {
                                                log("##***********************>>>>>>>>>>>>>>>>" +
                                                    dummyData.subProduct!
                                                        .toJson());
                                                if (dummyData
                                                        .subProduct!
                                                        .subProductDetail!
                                                        .length >
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

                                    if (((dummyData!.cOfferId != 0 &&
                                        dummyData.cOfferId != null))) {
                                      giftindex = index;
                                      print("HHHHHH $giftindex");
                                    }

                                    return Container(
                                      height:
                                          Sizeconfig.getHeight(context) * 0.5,
                                      child: GestureDetector(
                                        onTap: () async {
                                          for (int i = 0;
                                              i < list![index].unit!.length!;
                                              i++) {
                                            debugPrint(
                                                "Model  ${dummyData.productId} ${dummyData.addQuantity} ");
                                            if (dummyData.productId ==
                                                list![index]
                                                    .unit![i]
                                                    .productId!) {
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
                                              'fromchekcout': fromchekcout,
                                              'list': list![index].unit!,
                                              'index': isMoreunit
                                                  ? isMoreUnitIndex
                                                  : index,
                                            },
                                          ).then((value) async {
                                            ProductUnit unit =
                                                value as ProductUnit;
                                            debugPrint(
                                                "FeatureCallback ${value.addQuantity}");
                                            SystemChrome
                                                .setSystemUIOverlayStyle(
                                                    SystemUiOverlayStyle(
                                              statusBarColor: Colors
                                                  .transparent, // transparent status bar
                                              statusBarIconBrightness: Brightness
                                                  .light, // dark icons on the status bar
                                            ));
                                            bloc.add(ProductUpdateQuantityEvent(
                                                quanitity: unit.addQuantity!,
                                                index: index));

                                            bloc.add(
                                                ProductUnitEvent(unit: unit));
                                            callback();
                                          });
                                        },
                                        child: Container(
                                          width: Sizeconfig.getWidth(context) *
                                              0.31,
                                          margin: EdgeInsets.only(right: 1),
                                          child: Stack(
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    width: Sizeconfig.getWidth(
                                                            context) *
                                                        0.31,

                                                    //padding: EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      border: Border.all(
                                                          width: 1,
                                                          color: ColorName
                                                              .white_card),
                                                    ),
                                                    margin: EdgeInsets.only(
                                                        bottom: 0),

                                                    child: IntrinsicHeight(
                                                      child: Column(
                                                        mainAxisAlignment: (dummyData!
                                                                        .cOfferId !=
                                                                    0 &&
                                                                dummyData
                                                                        .cOfferId !=
                                                                    null)
                                                            ? MainAxisAlignment
                                                                .start
                                                            : MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          IntrinsicHeight(
                                                            child: Container(
                                                              height: Sizeconfig
                                                                      .getWidth(
                                                                          context) *
                                                                  .30,
                                                              width: Sizeconfig
                                                                      .getWidth(
                                                                          context) *
                                                                  0.31,
                                                              child: Stack(
                                                                children: [
                                                                  Container(
                                                                    height:
                                                                        Sizeconfig.getWidth(context) *
                                                                            .30,
                                                                    width: Sizeconfig.getWidth(
                                                                            context) *
                                                                        0.31,
                                                                    margin: EdgeInsets.only(
                                                                        right:
                                                                            0,
                                                                        bottom:
                                                                            0),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .only(
                                                                        topLeft:
                                                                            Radius.circular(10),
                                                                        topRight:
                                                                            Radius.circular(10),
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              0),
                                                                      child:
                                                                          Container(
                                                                        child:
                                                                            Container(
                                                                          padding:
                                                                              EdgeInsets.all(4),
                                                                          child:
                                                                              CommonCachedImageWidget2(
                                                                            imgUrl:
                                                                                dummyData.image!,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Positioned(
                                                                    top: 0,
                                                                    child:
                                                                        Visibility(
                                                                      visible:
                                                                          dummyData.discountText !=
                                                                              "",
                                                                      child:
                                                                          Container(
                                                                        width: Sizeconfig.getWidth(context) *
                                                                            0.30,
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Container(),
                                                                            Container(
                                                                              width: Sizeconfig.getWidth(context) * 0.20,
                                                                              decoration: BoxDecoration(
                                                                                  color: ColorName.ColorPrimary,
                                                                                  borderRadius: BorderRadius.only(
                                                                                    bottomLeft: Radius.circular(10),
                                                                                    bottomRight: Radius.circular(10),
                                                                                  )),
                                                                              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 3),
                                                                              child: Center(
                                                                                child: CommanTextWidget.regularBold(
                                                                                  dummyData.discountText!.trim().replaceAll("\n", " ") ?? "",
                                                                                  Colors.white,
                                                                                  maxline: 1,
                                                                                  trt: TextStyle(
                                                                                    fontSize: 10,
                                                                                    height: 1,
                                                                                    fontWeight: FontWeight.w700,
                                                                                  ),
                                                                                  textalign: TextAlign.start,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Container(),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                              child: Container(
                                                            width: Sizeconfig
                                                                    .getWidth(
                                                                        context) *
                                                                0.31,
                                                            // color: Colors.white,
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .only(
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                            ),
                                                            // padding: EdgeInsets.symmetric(horizontal: 5),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                    padding: EdgeInsets
                                                                        .symmetric(
                                                                            horizontal:
                                                                                5),
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        15.toSpace,
                                                                        Container(
                                                                          height:
                                                                              Sizeconfig.getHeight(context) * 0.06,
                                                                          child:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Container(
                                                                                child: CommanTextWidget.regularBold(
                                                                                  dummyData.name!,
                                                                                  commontextcolor,
                                                                                  maxline: 2,
                                                                                  trt: TextStyle(
                                                                                    fontSize: 14,
                                                                                    height: 1.05,
                                                                                    fontWeight: FontWeight.w700,
                                                                                  ),
                                                                                  textalign: TextAlign.start,
                                                                                ),
                                                                              ),
                                                                              Container(),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        3.toSpace,
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Container(
                                                                              child: InkWell(
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
                                                                                                  commontextcolor,
                                                                                                  maxline: 2,
                                                                                                  trt: TextStyle(
                                                                                                    fontSize: 12,
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
                                                                                    : Container(
                                                                                        padding: EdgeInsets.symmetric(horizontal: 8),
                                                                                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(4.0)), border: Border.all(width: 0.6, color: ColorName.border.withOpacity(0.5))),
                                                                                        child: CommanTextWidget.regularBold(
                                                                                          dummyData.productWeight.toString() + " ${dummyData.productWeightUnit}",
                                                                                          commontextcolor,
                                                                                          maxline: 2,
                                                                                          trt: TextStyle(
                                                                                            fontSize: 12,
                                                                                            fontWeight: FontWeight.w600,
                                                                                          ),
                                                                                          textalign: TextAlign.start,
                                                                                        ),
                                                                                      ),
                                                                              ),
                                                                            ),
                                                                            Container()
                                                                          ],
                                                                        ),
                                                                        3.toSpace,
                                                                        Container(
                                                                          child:
                                                                              CommanTextWidget.regularBold(
                                                                            dummyData.specialPrice == ""
                                                                                ? ""
                                                                                : "₹${double.parse(dummyData.price!).toStringAsFixed(2)}",
                                                                            commontextcolor,
                                                                            maxline:
                                                                                1,
                                                                            trt:
                                                                                TextStyle(
                                                                              fontSize: 10,
                                                                              decoration: TextDecoration.lineThrough,
                                                                              decorationColor: commontextcolor,
                                                                              fontWeight: FontWeight.w500,
                                                                            ),
                                                                            textalign:
                                                                                TextAlign.start,
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          child:
                                                                              Container(
                                                                            child:
                                                                                CommanTextWidget.regularBold(
                                                                              dummyData.specialPrice == "" ? "₹ ${double.parse(dummyData.sortPrice!).toStringAsFixed(2)}" : "₹ ${double.parse(dummyData.specialPrice!).toStringAsFixed(2)}",
                                                                              commontextcolor,
                                                                              maxline: 2,
                                                                              trt: TextStyle(
                                                                                fontSize: 14,
                                                                                fontWeight: FontWeight.w700,
                                                                              ),
                                                                              textalign: TextAlign.start,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        3.toSpace,
                                                                      ],
                                                                    )),
                                                                Visibility(
                                                                  visible: (dummyData!
                                                                              .cOfferId !=
                                                                          0 &&
                                                                      dummyData
                                                                              .cOfferId !=
                                                                          null),
                                                                  // visible: index==4,
                                                                  child:
                                                                      GestureDetector(
                                                                    onTap: () {
                                                                      List<ProductUnit>
                                                                          subProductsDetailsList =
                                                                          dummyData!
                                                                              .subProduct!
                                                                              .subProductDetail!;

                                                                      print(
                                                                          "model quantity ${dummyData.addQuantity}");

                                                                      SubProduct
                                                                          subproducts =
                                                                          dummyData
                                                                              .subProduct!;
                                                                      for (int i =
                                                                              0;
                                                                          i < subProductsDetailsList.length;
                                                                          i++) {
                                                                        SubProduct
                                                                            subproduct =
                                                                            SubProduct();
                                                                        subproduct.cOfferInfo =
                                                                            subproducts!.cOfferInfo;
                                                                        subproduct.getQty =
                                                                            subproducts!.getQty;
                                                                        subproduct.discType =
                                                                            subproducts!.discType;
                                                                        subproduct.discAmt =
                                                                            subproducts!.discAmt;
                                                                        subproduct.cOfferAvail =
                                                                            subproducts!.cOfferAvail;
                                                                        subproduct.cOfferApplied =
                                                                            subproducts!.cOfferApplied;
                                                                        subproduct.offerProductId =
                                                                            subproducts!.offerProductId;
                                                                        subproduct.offerWarning =
                                                                            subproducts!.offerWarning;
                                                                        List<ProductUnit>?
                                                                            subProductDetail =
                                                                            [];
                                                                        for (var x
                                                                            in subproducts!.subProductDetail!) {
                                                                          ProductUnit
                                                                              y =
                                                                              ProductUnit();
                                                                          y.productId =
                                                                              x.productId;
                                                                          y.quantity =
                                                                              x.quantity;
                                                                          y.image =
                                                                              x.image;
                                                                          y.price =
                                                                              x.specialPrice;
                                                                          y.subProduct =
                                                                              x.subProduct;
                                                                          y.model =
                                                                              x.model;
                                                                          y.name =
                                                                              x.name;

                                                                          subProductDetail
                                                                              .add(y);
                                                                        }
                                                                        subproduct.subProductDetail =
                                                                            subProductDetail;
                                                                        subProductsDetailsList[i].subProduct =
                                                                            subproduct;
                                                                        subProductsDetailsList[i]
                                                                            .subProduct!
                                                                            .buyQty = dummyData!.subProduct!.buyQty;
                                                                        subProductsDetailsList[i].cOfferId =
                                                                            dummyData.cOfferId;
                                                                        subProductsDetailsList[i].discountLabel =
                                                                            dummyData.discountLabel;
                                                                        subProductsDetailsList[i].discountText =
                                                                            dummyData.discountText;
                                                                        subProductsDetailsList[i].cOfferType =
                                                                            dummyData.cOfferType;
                                                                        debugPrint("GGGGGG" +
                                                                            dummyData.subProduct!.cOfferInfo!);
                                                                        debugPrint("GGGGGGGG" +
                                                                            subProductsDetailsList[i].subProduct!.cOfferInfo!);
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
                                                                        debugPrint(
                                                                            'Refresh call >>  ');

                                                                        // loadFeatureProduct();
                                                                        // searchProduct(searchController.text);
                                                                      }, (value) {});
                                                                    },
                                                                    child: Container(
                                                                        decoration: const BoxDecoration(
                                                                            gradient: LinearGradient(
                                                                              colors: [
                                                                                Color(0xFF29A809),
                                                                                Color(0xFFDBFFD2),
                                                                              ],
                                                                              begin: Alignment.topLeft,
                                                                              end: Alignment.bottomRight,
                                                                            ),
                                                                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0))),
                                                                        width: Sizeconfig.getWidth(context) * 0.32,
                                                                        height: 20,
                                                                        padding: EdgeInsets.symmetric(horizontal: 8),
                                                                        child: Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          children: [
                                                                            Container(
                                                                              child: CommanTextWidget.regularBold(
                                                                                "Free Gifts",
                                                                                Colors.white,
                                                                                maxline: 2,
                                                                                trt: TextStyle(
                                                                                  fontSize: 12,
                                                                                  fontWeight: FontWeight.w600,
                                                                                ),
                                                                                textalign: TextAlign.start,
                                                                              ),
                                                                            ),
                                                                            Container(
                                                                                child: Image.asset(
                                                                              Imageconstants.img_arrowgreen,
                                                                              height: 10,
                                                                            ))
                                                                          ],
                                                                        )),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          )),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Positioned(
                                                top: Sizeconfig.getWidth(
                                                        context) *
                                                    0.25,
                                                right: 4,
                                                child: Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 0),
                                                  child: Container(
                                                    width: Sizeconfig.getWidth(
                                                            context) *
                                                        0.31,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Container(),
                                                        Container(
                                                            height: Sizeconfig
                                                                    .getWidth(
                                                                        context) *
                                                                0.08,
                                                            //   width: Sizeconfig.getWidth(context) * 0.14,
                                                            child: dummyData
                                                                        .addQuantity !=
                                                                    0
                                                                ? Container(
                                                                    width: Sizeconfig.getWidth(
                                                                            context) *
                                                                        0.20,
                                                                    child: smallAddQuantityButtonborder(
                                                                        ColorName
                                                                            .ColorPrimary,
                                                                        commontextcolor,
                                                                        StringContants
                                                                            .lbl_add,
                                                                        dummyData.addQuantity!
                                                                            as int,
                                                                        () {
                                                                      //increase

                                                                      if (dummyData
                                                                              .addQuantity ==
                                                                          int.parse(dummyData
                                                                              .orderQtyLimit!
                                                                              .toString())) {
                                                                        Fluttertoast.showToast(
                                                                            msg:
                                                                                StringContants.msg_quanitiy);
                                                                      } else {
                                                                        dummyData
                                                                            .addQuantity = dummyData
                                                                                .addQuantity +
                                                                            1;
                                                                        bloc.add(ProductUpdateQuantityEvent(
                                                                            quanitity:
                                                                                dummyData.addQuantity!,
                                                                            index: index));
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
                                                                            .deleteCard(int.parse(dummyData.productId!))
                                                                            .then((value) {
                                                                          debugPrint(
                                                                              "Delete Product $value ");

                                                                          // cardBloc.add(CardDeleteEvent(
                                                                          //     model: model,
                                                                          //     listProduct:  list![0].unit!));

                                                                          dbHelper
                                                                              .loadAddCardProducts(cardBloc);
                                                                        });
                                                                      } else if (dummyData
                                                                              .addQuantity !=
                                                                          0) {
                                                                        debugPrint(
                                                                            "SHOPBY 2");
                                                                        dummyData
                                                                            .addQuantity = dummyData
                                                                                .addQuantity -
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
                                                                    }))
                                                                : Container(
                                                                    child:
                                                                        smallbuttonPrimaryborder(
                                                                    ColorName
                                                                        .ColorPrimary,
                                                                    commontextcolor,
                                                                    StringContants
                                                                        .lbl_add,
                                                                    () {
                                                                      dummyData
                                                                              .addQuantity =
                                                                          dummyData.addQuantity +
                                                                              1;
                                                                      checkItemId(
                                                                              dummyData.productId!,
                                                                              dbHelper)
                                                                          .then((value) {
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
                                                                          quanitity: dummyData
                                                                              .addQuantity!,
                                                                          index:
                                                                              index));
                                                                      bloc.add(ProductChangeEvent(
                                                                          model:
                                                                              dummyData));
                                                                    },
                                                                  ))),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  crossAxisCount: 3,
                                  staggeredTileBuilder: (int index) {
                                    var dummyData = list![index].unit![0];

/*

                                    if(firstRowActive)
                                      {
                                        if(index==0||index==1||index==2)
                                          {
                                            debugPrint("OFFER_PRESENT_IN_ROW 1");
                                            return StaggeredTile.count(1, 2);
                                          }
                                      }
                                    else if(secondRowActive)
                                      {
                                        debugPrint("OFFER_PRESENT_IN_ROW 2A");
                                        if(index==3||index==4||index==5)
                                        {
                                          debugPrint("OFFER_PRESENT_IN_ROW 2");
                                          return StaggeredTile.count(1, 2);
                                        }
                                      }
                                    else
                                      {
                                        debugPrint("OFFER_PRESENT_IN_ROW 3${firstRowActive} ${secondRowActive}");
                                        return StaggeredTile.count(1, 1.80);
                                      }
*/

                                    /*  if ((dummyData!.cOfferId != 0 &&
                                        dummyData.cOfferId != null)) {
                                      selectedIndex=index;
                                      return StaggeredTile.count(1, 2);

                                    } else {
                                      //return StaggeredTile.count(1, 1.80);


                                      return StaggeredTile.count(1, 2);

                                    }*/
                                    return StaggeredTile.count(1, 2.3);
                                    // return StaggeredTile.count(1, 1.85);
                                  },
                                ),
                              ),
                            ],
                          ));
                    }),
              );
  }

  //Fresh vegitables
  static ui_type8(
      bool fromchekcout,
      BuildContext context,
      String title,
      String subtitle,
      dynamic state,
      List<ProductData>? list,
      FeaturedBloc bloc,
      int isMoreUnitIndex,
      CardBloc cardBloc,
      DatabaseHelper dbHelper,
      ScrollController _scrollController,
      bool loadMore,
      var themecolor,
      var commontextcolor,
      var titlecolor,
      String? image,
      String buttontext,
      var buttontextcolor,
      var buttonbackground,
      Function callback,
      String paginationurl,
      List<Category>? categoriesList,
      String categoryId) {
    debugPrint("similarProductsUI  ${list!.length} ${loadMore}");

    var headingview;
    int giftindex = 0;

    if (image!.isEmpty || image == "" || image == null || image == "null") {
      headingview = Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: Sizeconfig.getWidth(context),
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  child: CommanTextWidget.subheading(title, titlecolor)
                  //Appwidgets.TextLagre(title, titlecolor),
                  ),
            ),
            Container(
              width: Sizeconfig.getWidth(context),
              child: CommanTextWidget.subtitle(subtitle, titlecolor),
            ),
          ],
        ),
      );
    } else {
      // headingview = Container(
      //     padding: EdgeInsets.symmetric(vertical: 3),
      //     decoration: BoxDecoration(
      //       color: themecolor ?? Colors.transparent,
      //       image: DecorationImage(
      //         image: FileImage(File(image)),
      //         fit: BoxFit.cover,
      //       ),
      //     ),
      //     child: Container(
      //       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      //       child: Column(
      //         mainAxisAlignment: MainAxisAlignment.start,
      //         children: [
      //           Container(
      //             width: Sizeconfig.getWidth(context),
      //             child: Padding(
      //               padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      //               child: Appwidgets.TextLagre("", titlecolor),
      //             ),
      //           ),
      //           Container(
      //             width: Sizeconfig.getWidth(context),
      //             child: Appwidgets.TextRegular("", titlecolor),
      //           ),
      //         ],
      //       ),
      //     ));

      headingview = Container(
        width: Sizeconfig.getWidth(context),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                      child: CommanTextWidget.subheading(title, titlecolor)
                      //Appwidgets.TextLagre(title, titlecolor),
                      ),
                ),
                Container(
                  child: CommanTextWidget.subtitle(subtitle.trim(), titlecolor),
                ),
              ],
            ),
            Image(
              image: FileImage(File(image)),
              fit: BoxFit.cover,
              height: 50,
            ),
          ],
        ),
      );
    }
    final double itemWidth = (Sizeconfig.getWidth(context)) / 3; // 3 columns

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

                      // For Manage card list product Quanityt
                      if (state is ProductUpdateQuantityInitialState) {
                        list = state.list!;
                      }

                      int line = (list!.length / 3).round();

                      debugPrint("Uitype5 Size " + line.toString());

                      if (line == 0) {
                        line = 1;
                      }

                      // if(state is OldListState)
                      //   {
                      //     list=state.list!;
                      //   }
                      return Container(
                          //height: Sizeconfig.getHeight(context) * 0.60,
                          color: themecolor,
                          // padding: const EdgeInsets.only(top: 10),
                          child: Column(
                            children: [
                              headingview,
                              Container(
                                // height: line * Sizeconfig.getHeight(context) * 0.25,
                                margin: EdgeInsets.symmetric(horizontal: 5),
                                padding: const EdgeInsets.only(left: 4),
                                //  color: Colors.red,
                                child: StaggeredGridView.countBuilder(
                                  // gridDelegate:
                                  //     const SliverGridDelegateWithFixedCrossAxisCount(
                                  //   crossAxisCount: 3, // Number of columns
                                  //   crossAxisSpacing:
                                  //       2.0, // Spacing between columns
                                  //   mainAxisSpacing: 2.0,
                                  //   childAspectRatio:
                                  //       0.54, // Spacing between rows
                                  // ),
                                  controller: _scrollController,
                                  shrinkWrap: true,
                                  itemCount:
                                      list!.length > 3 ? 3 : list!.length,
                                  scrollDirection: Axis.vertical,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    var dummyData = list![index].unit![0];
                                    bool isMoreunit = false;

                                    debugPrint("Trending Object  " +
                                        dummyData.toJson());
                                    if (list![index].unit!.length > 1) {
                                      isMoreunit = true;
                                    }

                                    if (state
                                        is ProductUpdateQuantityStateBYModel) {
                                      debugPrint(
                                          "LIST Featured Product State  " +
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
                                      if (list![index].unit!.length == 1) {
                                        debugPrint("Quanititycondition  1 ");

                                        if (dummyData.productId ==
                                            state.model.productId) {
                                          dummyData.addQuantity =
                                              state.model.addQuantity;
                                          //G  bloc.add(ProductNullEvent());
                                        }
                                      } else {
                                        for (var obj in list![index].unit!) {
                                          if (obj.name == state.model.name ||
                                              obj.productId ==
                                                  state.model.productId) {
                                            debugPrint(
                                                "G>>>>>>>>>>>>>>>>>>>>    " +
                                                    state.model.addQuantity
                                                        .toString());

                                            debugPrint("G>>>>>>Index    " +
                                                isMoreUnitIndex.toString());

                                            if (dummyData!.cOfferId != 0 &&
                                                dummyData.cOfferId != null) {
                                              debugPrint(
                                                  "##***********************");
                                              if (dummyData.subProduct !=
                                                  null) {
                                                log("##***********************>>>>>>>>>>>>>>>>" +
                                                    dummyData.subProduct!
                                                        .toJson());

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
                                              if (dummyData.subProduct !=
                                                  null) {
                                                log("##***********************>>>>>>>>>>>>>>>>" +
                                                    dummyData.subProduct!
                                                        .toJson());
                                                if (dummyData
                                                        .subProduct!
                                                        .subProductDetail!
                                                        .length >
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

                                    if (((dummyData!.cOfferId != 0 &&
                                        dummyData.cOfferId != null))) {
                                      giftindex = index;
                                      print("HHHHHH $giftindex");
                                    }

                                    if (state is ProductUnitState) {
                                      if (dummyData.productId ==
                                          state.unit.productId) {
                                        dummyData = state.unit;
                                      }
                                    }
                                    return Container(
                                      height:
                                          Sizeconfig.getHeight(context) * 0.5,
                                      child: GestureDetector(
                                        onTap: () async {
                                          for (int i = 0;
                                              i < list![index].unit!.length!;
                                              i++) {
                                            debugPrint(
                                                "Model  ${dummyData.productId} ${dummyData.addQuantity} ");
                                            if (dummyData.productId ==
                                                list![index]
                                                    .unit![i]
                                                    .productId!) {
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
                                              'fromchekcout': fromchekcout,
                                              'list': list![index].unit!,
                                              'index': isMoreunit
                                                  ? isMoreUnitIndex
                                                  : index,
                                            },
                                          ).then((value) async {
                                            ProductUnit unit =
                                                value as ProductUnit;
                                            debugPrint(
                                                "FeatureCallback ${value.addQuantity}");
                                            SystemChrome
                                                .setSystemUIOverlayStyle(
                                                    SystemUiOverlayStyle(
                                              statusBarColor: Colors
                                                  .transparent, // transparent status bar
                                              statusBarIconBrightness: Brightness
                                                  .light, // dark icons on the status bar
                                            ));
                                            bloc.add(ProductUpdateQuantityEvent(
                                                quanitity: unit.addQuantity!,
                                                index: index));
                                            callback();
                                          });
                                        },
                                        child: Container(
                                          width: Sizeconfig.getWidth(context) *
                                              0.31,
                                          margin: EdgeInsets.only(right: 1),
                                          child: Stack(
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    width: Sizeconfig.getWidth(
                                                            context) *
                                                        0.31,

                                                    //padding: EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      border: Border.all(
                                                          width: 1,
                                                          color: ColorName
                                                              .white_card),
                                                    ),
                                                    margin: EdgeInsets.only(
                                                        bottom: 0),

                                                    child: IntrinsicHeight(
                                                      child: Column(
                                                        mainAxisAlignment: (dummyData!
                                                                        .cOfferId !=
                                                                    0 &&
                                                                dummyData
                                                                        .cOfferId !=
                                                                    null)
                                                            ? MainAxisAlignment
                                                                .start
                                                            : MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          IntrinsicHeight(
                                                            child: Container(
                                                              height: Sizeconfig
                                                                      .getHeight(
                                                                          context) *
                                                                  .13,
                                                              width: Sizeconfig
                                                                      .getWidth(
                                                                          context) *
                                                                  0.31,
                                                              child: Stack(
                                                                children: [
                                                                  Container(
                                                                    // height:
                                                                    //     Sizeconfig.getHeight(context) *
                                                                    //         .38,
                                                                    // width: Sizeconfig.getWidth(
                                                                    //         context) *
                                                                    //     0.38,
                                                                    margin: EdgeInsets.only(
                                                                        right:
                                                                            0,
                                                                        bottom:
                                                                            0),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .only(
                                                                        topLeft:
                                                                            Radius.circular(10),
                                                                        topRight:
                                                                            Radius.circular(10),
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          CommonCachedImageWidget2(
                                                                        imgUrl:
                                                                            dummyData.image!,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Positioned(
                                                                    top: 0,
                                                                    child:
                                                                        Visibility(
                                                                      visible:
                                                                          dummyData.discountText !=
                                                                              "",
                                                                      child:
                                                                          Container(
                                                                        width: Sizeconfig.getWidth(context) *
                                                                            0.30,
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Container(),
                                                                            Container(
                                                                              width: Sizeconfig.getWidth(context) * 0.20,
                                                                              decoration: BoxDecoration(
                                                                                  color: ColorName.ColorPrimary,
                                                                                  borderRadius: BorderRadius.only(
                                                                                    bottomLeft: Radius.circular(10),
                                                                                    bottomRight: Radius.circular(10),
                                                                                  )),
                                                                              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 3),
                                                                              child: Center(
                                                                                child: CommanTextWidget.regularBold(
                                                                                  dummyData.discountText!.trim().replaceAll("\n", " ") ?? "",
                                                                                  Colors.white,
                                                                                  maxline: 1,
                                                                                  trt: TextStyle(
                                                                                    fontSize: 10,
                                                                                    height: 1,
                                                                                    fontWeight: FontWeight.w700,
                                                                                  ),
                                                                                  textalign: TextAlign.start,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Container(),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                              child: Container(
                                                            width: Sizeconfig
                                                                    .getWidth(
                                                                        context) *
                                                                0.31,
                                                            // color: Colors.white,
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .only(
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                            ),
                                                            // padding: EdgeInsets.symmetric(horizontal: 5),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                    padding: EdgeInsets
                                                                        .symmetric(
                                                                            horizontal:
                                                                                5),
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        15.toSpace,
                                                                        Container(
                                                                          height:
                                                                              Sizeconfig.getHeight(context) * 0.06,
                                                                          child:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Container(
                                                                                child: CommanTextWidget.regularBold(
                                                                                  dummyData.name!,
                                                                                  commontextcolor,
                                                                                  maxline: 2,
                                                                                  trt: TextStyle(
                                                                                    fontSize: 14,
                                                                                    height: 1.05,
                                                                                    fontWeight: FontWeight.w700,
                                                                                  ),
                                                                                  textalign: TextAlign.start,
                                                                                ),
                                                                              ),
                                                                              Container(),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        5.toSpace,
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Container(
                                                                              child: InkWell(
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
                                                                                                  commontextcolor,
                                                                                                  maxline: 2,
                                                                                                  trt: TextStyle(
                                                                                                    fontSize: 12,
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
                                                                                    : Container(
                                                                                        padding: EdgeInsets.symmetric(horizontal: 8),
                                                                                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(4.0)), border: Border.all(width: 0.6, color: ColorName.border.withOpacity(0.5))),
                                                                                        child: CommanTextWidget.regularBold(
                                                                                          dummyData.productWeight.toString() + " ${dummyData.productWeightUnit}",
                                                                                          commontextcolor,
                                                                                          maxline: 2,
                                                                                          trt: TextStyle(
                                                                                            fontSize: 12,
                                                                                            fontWeight: FontWeight.w600,
                                                                                          ),
                                                                                          textalign: TextAlign.start,
                                                                                        ),
                                                                                      ),
                                                                              ),
                                                                            ),
                                                                            Container()
                                                                          ],
                                                                        ),
                                                                        4.toSpace,
                                                                        Container(
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.end,
                                                                            children: [
                                                                              Container(
                                                                                child: CommanTextWidget.regularBold(
                                                                                  dummyData.specialPrice == "" ? "₹ ${double.parse(dummyData.sortPrice!).toStringAsFixed(2)}" : "₹ ${double.parse(dummyData.specialPrice!).toStringAsFixed(2)}",
                                                                                  commontextcolor,
                                                                                  maxline: 2,
                                                                                  trt: TextStyle(
                                                                                    fontSize: 14,
                                                                                    fontWeight: FontWeight.w700,
                                                                                  ),
                                                                                  textalign: TextAlign.start,
                                                                                ),
                                                                              ),
                                                                              Flexible(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.only(bottom: 1.0, left: 5),
                                                                                  child: CommanTextWidget.regularBold(
                                                                                    dummyData.specialPrice == "" ? "" : "₹${double.parse(dummyData.price!).toStringAsFixed(2)}",
                                                                                    commontextcolor,
                                                                                    maxline: 1,
                                                                                    trt: TextStyle(
                                                                                      fontSize: 10,
                                                                                      decoration: TextDecoration.lineThrough,
                                                                                      decorationColor: commontextcolor,
                                                                                      fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                    textalign: TextAlign.start,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        4.toSpace,
                                                                      ],
                                                                    )),
                                                                Visibility(
                                                                  visible: (dummyData!
                                                                              .cOfferId !=
                                                                          0 &&
                                                                      dummyData
                                                                              .cOfferId !=
                                                                          null),
                                                                  // visible: index==4,
                                                                  child:
                                                                      GestureDetector(
                                                                    onTap: () {
                                                                      List<ProductUnit>
                                                                          subProductsDetailsList =
                                                                          dummyData!
                                                                              .subProduct!
                                                                              .subProductDetail!;

                                                                      print(
                                                                          "model quantity ${dummyData.addQuantity}");

                                                                      SubProduct
                                                                          subproducts =
                                                                          dummyData
                                                                              .subProduct!;
                                                                      for (int i =
                                                                              0;
                                                                          i < subProductsDetailsList.length;
                                                                          i++) {
                                                                        SubProduct
                                                                            subproduct =
                                                                            SubProduct();
                                                                        subproduct.cOfferInfo =
                                                                            subproducts!.cOfferInfo;
                                                                        subproduct.getQty =
                                                                            subproducts!.getQty;
                                                                        subproduct.discType =
                                                                            subproducts!.discType;
                                                                        subproduct.discAmt =
                                                                            subproducts!.discAmt;
                                                                        subproduct.cOfferAvail =
                                                                            subproducts!.cOfferAvail;
                                                                        subproduct.cOfferApplied =
                                                                            subproducts!.cOfferApplied;
                                                                        subproduct.offerProductId =
                                                                            subproducts!.offerProductId;
                                                                        subproduct.offerWarning =
                                                                            subproducts!.offerWarning;
                                                                        List<ProductUnit>?
                                                                            subProductDetail =
                                                                            [];
                                                                        for (var x
                                                                            in subproducts!.subProductDetail!) {
                                                                          ProductUnit
                                                                              y =
                                                                              ProductUnit();
                                                                          y.productId =
                                                                              x.productId;
                                                                          y.quantity =
                                                                              x.quantity;
                                                                          y.image =
                                                                              x.image;
                                                                          y.price =
                                                                              x.specialPrice;
                                                                          y.subProduct =
                                                                              x.subProduct;
                                                                          y.model =
                                                                              x.model;
                                                                          y.name =
                                                                              x.name;

                                                                          subProductDetail
                                                                              .add(y);
                                                                        }
                                                                        subproduct.subProductDetail =
                                                                            subProductDetail;
                                                                        subProductsDetailsList[i].subProduct =
                                                                            subproduct;
                                                                        subProductsDetailsList[i]
                                                                            .subProduct!
                                                                            .buyQty = dummyData!.subProduct!.buyQty;
                                                                        subProductsDetailsList[i].cOfferId =
                                                                            dummyData.cOfferId;
                                                                        subProductsDetailsList[i].discountLabel =
                                                                            dummyData.discountLabel;
                                                                        subProductsDetailsList[i].discountText =
                                                                            dummyData.discountText;
                                                                        subProductsDetailsList[i].cOfferType =
                                                                            dummyData.cOfferType;
                                                                        debugPrint("GGGGGG" +
                                                                            dummyData.subProduct!.cOfferInfo!);
                                                                        debugPrint("GGGGGGGG" +
                                                                            subProductsDetailsList[i].subProduct!.cOfferInfo!);
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
                                                                        debugPrint(
                                                                            'Refresh call >>  ');

                                                                        // loadFeatureProduct();
                                                                        // searchProduct(searchController.text);
                                                                      }, (value) {});
                                                                    },
                                                                    child: Container(
                                                                        decoration: const BoxDecoration(
                                                                            gradient: LinearGradient(
                                                                              colors: [
                                                                                Color(0xFF29A809),
                                                                                Color(0xFFDBFFD2),
                                                                              ],
                                                                              begin: Alignment.topLeft,
                                                                              end: Alignment.bottomRight,
                                                                            ),
                                                                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0))),
                                                                        width: Sizeconfig.getWidth(context) * 0.32,
                                                                        height: 20,
                                                                        padding: EdgeInsets.symmetric(horizontal: 8),
                                                                        child: Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          children: [
                                                                            Container(
                                                                              child: CommanTextWidget.regularBold(
                                                                                "Free Gifts",
                                                                                Colors.white,
                                                                                maxline: 2,
                                                                                trt: TextStyle(
                                                                                  fontSize: 12,
                                                                                  fontWeight: FontWeight.w600,
                                                                                ),
                                                                                textalign: TextAlign.start,
                                                                              ),
                                                                            ),
                                                                            Container(
                                                                                child: Image.asset(
                                                                              Imageconstants.img_arrowgreen,
                                                                              height: 10,
                                                                            ))
                                                                          ],
                                                                        )),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          )),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Positioned(
                                                top: Sizeconfig.getWidth(
                                                            context) <
                                                        400
                                                    ? Sizeconfig.getWidth(
                                                            context) *
                                                        0.2
                                                    : Sizeconfig.getWidth(
                                                            context) *
                                                        0.23,
                                                right: 2,
                                                child: Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 0),
                                                  child: Container(
                                                    width: Sizeconfig.getWidth(
                                                            context) *
                                                        0.31,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Container(),
                                                        Container(
                                                            height: Sizeconfig
                                                                    .getWidth(
                                                                        context) *
                                                                0.08,
                                                            //   width: Sizeconfig.getWidth(context) * 0.14,
                                                            child: dummyData
                                                                        .addQuantity !=
                                                                    0
                                                                ? Container(
                                                                    width: Sizeconfig.getWidth(
                                                                            context) *
                                                                        0.20,
                                                                    child: smallAddQuantityButtonborder(
                                                                        ColorName
                                                                            .ColorPrimary,
                                                                        commontextcolor,
                                                                        StringContants
                                                                            .lbl_add,
                                                                        dummyData.addQuantity!
                                                                            as int,
                                                                        () {
                                                                      //increase

                                                                      if (dummyData
                                                                              .addQuantity ==
                                                                          int.parse(dummyData
                                                                              .orderQtyLimit!
                                                                              .toString())) {
                                                                        Fluttertoast.showToast(
                                                                            msg:
                                                                                StringContants.msg_quanitiy);
                                                                      } else {
                                                                        dummyData
                                                                            .addQuantity = dummyData
                                                                                .addQuantity +
                                                                            1;
                                                                        bloc.add(ProductUpdateQuantityEvent(
                                                                            quanitity:
                                                                                dummyData.addQuantity!,
                                                                            index: index));
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
                                                                            .deleteCard(int.parse(dummyData.productId!))
                                                                            .then((value) {
                                                                          debugPrint(
                                                                              "Delete Product $value ");

                                                                          // cardBloc.add(CardDeleteEvent(
                                                                          //     model: model,
                                                                          //     listProduct:  list![0].unit!));

                                                                          dbHelper
                                                                              .loadAddCardProducts(cardBloc);
                                                                        });
                                                                      } else if (dummyData
                                                                              .addQuantity !=
                                                                          0) {
                                                                        debugPrint(
                                                                            "SHOPBY 2");
                                                                        dummyData
                                                                            .addQuantity = dummyData
                                                                                .addQuantity -
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
                                                                    }))
                                                                : Container(
                                                                    child:
                                                                        smallbuttonPrimaryborder(
                                                                    ColorName
                                                                        .ColorPrimary,
                                                                    commontextcolor,
                                                                    StringContants
                                                                        .lbl_add,
                                                                    () {
                                                                      dummyData
                                                                              .addQuantity =
                                                                          dummyData.addQuantity +
                                                                              1;
                                                                      checkItemId(
                                                                              dummyData.productId!,
                                                                              dbHelper)
                                                                          .then((value) {
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
                                                                          quanitity: dummyData
                                                                              .addQuantity!,
                                                                          index:
                                                                              index));
                                                                      bloc.add(ProductChangeEvent(
                                                                          model:
                                                                              dummyData));
                                                                    },
                                                                  ))),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  crossAxisCount: 3,
                                  staggeredTileBuilder: (int index) {
                                    var dummyData = list![index].unit![0];

                                    // if(index==4)
                                    if ((dummyData!.cOfferId != 0 &&
                                        dummyData.cOfferId != null)) {
                                      return StaggeredTile.count(1, 2.1);
                                    } else {
                                      return StaggeredTile.count(1, 2.0);
                                    }

                                    return StaggeredTile.count(1, 1.85);
                                  },
                                ),
                              ),
                              buttontext == ""
                                  ? Container()
                                  : Appwidgets.MyUiButton(
                                      context,
                                      buttontext,
                                      buttonbackground,
                                      buttontextcolor,
                                      Sizeconfig.getWidth(context), () async {
                                      /*   SharedPref.setStringPreference(
                                          Constants.sp_homepageproducts,
                                          jsonEncode(list));
                                      Navigator.pushNamed(
                                          context, Routes.featuredProduct,
                                          arguments: {
                                            "key": title,
                                            "list": list,
                                            "paninatinUrl": paginationurl
                                          }).then((value) {
                                        list = value as List<ProductData>;

                                        print("vlaueGG ${list!.length}");

                                        //bloc.add(OldListEvent(list: list!));
                                      });*/

                                      Category? category;

                                      int subcategoryIndex = 0;
                                      for (var x in categoriesList!) {
                                        print(
                                            "SeeAllGGGG id ${x.name} ${x.id} ${categoryId}");

                                        if (categoryId == x.id) {
                                          category = x;
                                        }
                                      }

                                      if (category == null) {
                                        for (var x in categoriesList!) {
                                          for (int y = 0;
                                              y < x.subCategories!.length;
                                              y++) {
                                            SubCategory sub =
                                                x.subCategories![y];
                                            print(
                                                "SeeAllGGGG2 id ${sub.name} ${sub.categoryId} ${categoryId}");
                                            if (categoryId == sub.categoryId) {
                                              subcategoryIndex = y;
                                              category = x;
                                            }
                                          }
                                        }
                                      }

                                      if (category == null) {
                                        for (var x in categoriesList!) {
                                          for (var y in x.subCategories!) {
                                            for (int z = 0;
                                                z < y.subCategories!.length;
                                                z++) {
                                              SubCategory sub =
                                                  y.subCategories![z];
                                              print(
                                                  "SeeAllGGGG3 id ${z} ${sub.name} ${sub.categoryId} ${categoryId}");
                                              if (categoryId ==
                                                  sub.categoryId) {
                                                subcategoryIndex = z;
                                                category = x;
                                              }
                                            }
                                          }
                                        }
                                      }

                                      print("SeeAllGGGG4  ${subcategoryIndex}");
                                      print(
                                          "SeeAllGGGG4  ${category!.subCategories![subcategoryIndex!]}");
                                      print("SeeAllGGGG4  ${category!.id}");
                                      print(
                                          "SeeAllGGGG4   ${category!.subCategories![subcategoryIndex!].categoryId}");
                                      Navigator.pushNamed(
                                          context, Routes.shop_by_category,
                                          arguments: {
                                            "selected_category": category,
                                            "category_list": categoriesList,
                                            "selected_sub_category":
                                                category!.subCategories![
                                                    subcategoryIndex!]
                                          }).then((value) {
                                        for (int index = 0;
                                            index < list!.length;
                                            index++) {
                                          var newmodel = list![index].unit![0];
                                          getCartQuantity(newmodel.productId!)
                                              .then((value) {
                                            debugPrint(
                                                "getCartQuanityUI $value");

                                            if (value > 0) {
                                              debugPrint(
                                                  "getCartQuanity name  ${list![index].unit![0].name}");
                                            }
                                            list![index].unit![0].addQuantity =
                                                value;
                                            // bloc.add(ProductUpdateQuantityInitial(list: list));
                                          });

                                          if (newmodel!.cOfferId != 0 &&
                                              newmodel.cOfferId != null) {
                                            debugPrint(
                                                "***********************");
                                            if (newmodel.subProduct != null) {
                                              log("***********************>>>>>>>>>>>>>>>>" +
                                                  newmodel.subProduct!
                                                      .toJson());
                                              if (newmodel
                                                      .subProduct!
                                                      .subProductDetail!
                                                      .length >
                                                  0) {
                                                list![index]
                                                        .unit![0]
                                                        .subProduct!
                                                        .subProductDetail =
                                                    MyUtility
                                                        .checkOfferSubProductLoad(
                                                            newmodel, dbHelper);
                                              }
                                            }
                                          }

                                          if (list![index].unit!.length > 1) {
                                            for (int i = 0;
                                                i < list![index].unit!.length;
                                                i++) {
                                              getCartQuantity(list![index]
                                                      .unit![i]
                                                      .productId!)
                                                  .then((value) {
                                                debugPrint(
                                                    "getCartQuanityUI $value");
                                                list![index]
                                                    .unit![i]
                                                    .addQuantity = value;
                                                // bloc.add(ProductUpdateQuantityInitial(list: list));
                                              });
                                            }
                                          }
                                        }
                                        //callback();
                                      });
                                    })
                            ],
                          ));
                    }),
              );
  }

  //Cookware
  static ui_type7(
      bool fromchekcout,
      BuildContext context,
      String title,
      String subtitle,
      dynamic state,
      List<ProductData>? list,
      FeaturedBloc bloc,
      int isMoreUnitIndex,
      CardBloc cardBloc,
      DatabaseHelper dbHelper,
      ScrollController _scrollController,
      bool loadMore,
      var themecolor,
      var commontextcolor,
      var titlecolor,
      String? image,
      String buttontext,
      var buttontextcolor,
      var buttonbackground,
      Function callback,
      String paginationurl,
      List<Category>? categoriesList,
      String categoryId) {
    debugPrint("similarProductsUI  ${list!.length} ${loadMore}");

    var headingview;

    if (image!.isEmpty || image == "" || image == null || image == "null") {
      headingview = Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: Sizeconfig.getWidth(context),
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  child: CommanTextWidget.subheading(title, titlecolor)
                  //Appwidgets.TextLagre(title, titlecolor),
                  ),
            ),
            Container(
              width: Sizeconfig.getWidth(context),
              child: CommanTextWidget.subtitle(subtitle, titlecolor),
            ),
          ],
        ),
      );
    } else {
      headingview = Container(
          padding: EdgeInsets.symmetric(vertical: 3),
          decoration: BoxDecoration(
            color: themecolor ?? Colors.transparent,
            image: DecorationImage(
              image: FileImage(File(image)),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: Sizeconfig.getWidth(context),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    child: Appwidgets.TextLagre("", titlecolor),
                  ),
                ),
                Container(
                  width: Sizeconfig.getWidth(context),
                  child: Appwidgets.TextRegular("", titlecolor),
                ),
              ],
            ),
          ));
    }

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
                      debugPrint(
                          "Featured Product State 24oct " + state.toString());

                      if (state is ProductForShopByState) {
                        list = state.list!;
                        debugPrint(
                            "Uitype7G list   ${state.list!.length.toString()}");

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

                      int line = (list!.length / 3).round();

                      debugPrint("Uitype7G Size " + line.toString());

                      if (line == 0) {
                        line = 1;
                      }

                      /*  if (state is OldListState) {
                        list = state.list;
                      }*/

                      return Container(
                          //height: Sizeconfig.getHeight(context) * 0.60,
                          color: themecolor,
                          // padding: const EdgeInsets.only(top: 10),
                          child: Column(
                            children: [
                              headingview,
                              Container(
                                height: Sizeconfig.getHeight(context) * 0.26,
                                margin: EdgeInsets.symmetric(horizontal: 7),
                                padding: const EdgeInsets.only(left: 4),
                                //  color: Colors.red,
                                child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3, // Number of columns
                                    crossAxisSpacing:
                                        5.0, // Spacing between columns
                                    mainAxisSpacing: 5.0,
                                    childAspectRatio:
                                        0.58, // Spacing between rows
                                  ),
                                  controller: _scrollController,
                                  shrinkWrap: true,
                                  itemCount:
                                      list!.length > 3 ? 3 : list!.length,
                                  scrollDirection: Axis.vertical,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    var dummyData = list![index].unit![0];

                                    if (state is ProductUnitState) {
                                      if (dummyData.productId ==
                                          state.unit.productId) {
                                        dummyData = state.unit;
                                      }
                                    }

                                    bool isMoreunit = false;

                                    debugPrint(
                                        "GGGGG  $index  =>  ${list![index].unit!.length.toString()}");
                                    if (list![index].unit!.length > 1) {
                                      isMoreunit = true;
                                    }

                                    if (state
                                        is ProductUpdateQuantityStateBYModel) {
                                      debugPrint(
                                          "LIST Featured Product State  " +
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
                                      if (list![index].unit!.length == 1) {
                                        debugPrint("Quanititycondition  1 ");

                                        if (dummyData.productId ==
                                            state.model.productId) {
                                          dummyData.addQuantity =
                                              state.model.addQuantity;
                                          //G  bloc.add(ProductNullEvent());
                                        }
                                      } else {
                                        for (var obj in list![index].unit!) {
                                          if (obj.name == state.model.name ||
                                              obj.productId ==
                                                  state.model.productId) {
                                            debugPrint(
                                                "G>>>>>>>>>>>>>>>>>>>>    " +
                                                    state.model.addQuantity
                                                        .toString());

                                            debugPrint("G>>>>>>Index    " +
                                                isMoreUnitIndex.toString());

                                            if (dummyData!.cOfferId != 0 &&
                                                dummyData.cOfferId != null) {
                                              debugPrint(
                                                  "##***********************");
                                              if (dummyData.subProduct !=
                                                  null) {
                                                log("##***********************>>>>>>>>>>>>>>>>" +
                                                    dummyData.subProduct!
                                                        .toJson());

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
                                              if (dummyData.subProduct !=
                                                  null) {
                                                log("##***********************>>>>>>>>>>>>>>>>" +
                                                    dummyData.subProduct!
                                                        .toJson());
                                                if (dummyData
                                                        .subProduct!
                                                        .subProductDetail!
                                                        .length >
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
                                    return Container(
                                      child: GestureDetector(
                                        onTap: () async {
                                          for (int i = 0;
                                              i < list![index].unit!.length!;
                                              i++) {
                                            debugPrint(
                                                "Model  ${dummyData.productId} ${dummyData.addQuantity} ");
                                            if (dummyData.productId ==
                                                list![index]
                                                    .unit![i]
                                                    .productId!) {
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
                                              'fromchekcout': fromchekcout,
                                              'list': list![index].unit!,
                                              'index': isMoreunit
                                                  ? isMoreUnitIndex
                                                  : index,
                                            },
                                          ).then((value) async {
                                            ProductUnit unit =
                                                value as ProductUnit;
                                            debugPrint(
                                                "FeatureCallback ${value.addQuantity}");
                                            SystemChrome
                                                .setSystemUIOverlayStyle(
                                                    SystemUiOverlayStyle(
                                              statusBarColor: Colors
                                                  .transparent, // transparent status bar
                                              statusBarIconBrightness: Brightness
                                                  .light, // dark icons on the status bar
                                            ));
                                            bloc.add(ProductUpdateQuantityEvent(
                                                quanitity: unit.addQuantity!,
                                                index: index));

                                            callback();
                                          });
                                        },
                                        child: Stack(
                                          children: [
                                            Container(
                                              child: Row(
                                                children: [
                                                  Stack(
                                                    children: [
                                                      Container(
                                                        // height: Sizeconfig.getHeight(context)*0.2,
                                                        // width:
                                                        //     Sizeconfig.getWidth(
                                                        //             context) *
                                                        //         0.28,
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
                                                                    // height: Sizeconfig
                                                                    //     .getWidth(
                                                                    //         context),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color:
                                                                          themecolor,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                      /*   border: Border.all(
                                                                          width:
                                                                              1,
                                                                          color: ColorName
                                                                              .imagebackg),*/
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            EdgeInsets.symmetric(horizontal: 0),
                                                                        child:
                                                                            Stack(
                                                                          children: [
                                                                            Center(
                                                                              child: Container(
                                                                                // height: Sizeconfig.getWidth(context) * .25,
                                                                                padding: EdgeInsets.all(4),
                                                                                // width: Sizeconfig.getWidth(context) * .25,
                                                                                child: CommonCachedImageWidget(
                                                                                  imgUrl: dummyData.image!,
                                                                                  // width: Sizeconfig.getWidth(context) * .25,
                                                                                  // height: Sizeconfig.getWidth(context) * .25,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
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
                                                                              child: Container(
                                                                                margin: EdgeInsets.only(top: 2),
                                                                                child: Image.asset(
                                                                                  Imageconstants.img_gifoffer2,
                                                                                  height: Sizeconfig.getWidth(context) * .06,
                                                                                  width: Sizeconfig.getWidth(context) * .06,
                                                                                ),
                                                                              ))
                                                                          : Container())
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                                flex: 5,
                                                                child:
                                                                    Container(
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      2.toSpace,
                                                                      Container(
                                                                        // height: Sizeconfig.getHeight(context) *
                                                                        //     0.05,
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              Sizeconfig.getWidth(context) * .28,
                                                                          child:
                                                                              // Text(
                                                                              //   dummyData.name!,
                                                                              //   maxLines: 2,
                                                                              //   style: TextStyle(
                                                                              //     fontSize: 11.34,
                                                                              //     fontFamily: Fontconstants.fc_family_sf,
                                                                              //     fontWeight: Fontconstants.SF_Pro_Display_Medium,
                                                                              //     color: commontextcolor,
                                                                              //   ),
                                                                              // ),

                                                                              CommanTextWidget.regularBold(
                                                                            dummyData.name!,
                                                                            commontextcolor,
                                                                            maxline:
                                                                                2,
                                                                            trt:
                                                                                TextStyle(
                                                                              fontSize: 14,
                                                                              height: 1,
                                                                              fontWeight: FontWeight.w700,
                                                                            ),
                                                                            textalign:
                                                                                TextAlign.start,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      5.toSpace,
                                                                      Container(
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Container(
                                                                              child: InkWell(
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
                                                                                                  commontextcolor,
                                                                                                  maxline: 2,
                                                                                                  trt: TextStyle(
                                                                                                    fontSize: 12,
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
                                                                                        commontextcolor,
                                                                                        maxline: 2,
                                                                                        trt: TextStyle(
                                                                                          fontSize: 12,
                                                                                          fontWeight: FontWeight.w600,
                                                                                        ),
                                                                                        textalign: TextAlign.start,
                                                                                      ),
                                                                              ),
                                                                            ),
                                                                            Container()
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      5.toSpace,
                                                                      Align(
                                                                        alignment:
                                                                            Alignment.bottomCenter,
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                /* Text(
                                                                                                                                                      dummyData.specialPrice == "" ? "" : "₹ ${double.parse(dummyData.price!).toStringAsFixed(2)}",
                                                                                                                                                      style: TextStyle(fontSize: 8.72, fontFamily: Fontconstants.fc_family_sf, fontWeight: Fontconstants.SF_Pro_Display_Regular, letterSpacing: 0, decoration: TextDecoration.lineThrough, decorationColor: commontextcolor, color: commontextcolor),
                                                                                                                                                    ),
                                                                                                        */
                                                                                CommanTextWidget.regularBold(
                                                                                  dummyData.specialPrice == "" ? "" : "₹ ${double.parse(dummyData.price!).toStringAsFixed(2)}",
                                                                                  commontextcolor,
                                                                                  maxline: 1,
                                                                                  trt: TextStyle(
                                                                                    fontSize: 9,
                                                                                    height: 1,
                                                                                    decoration: TextDecoration.lineThrough,
                                                                                    decorationColor: commontextcolor,
                                                                                    fontWeight: FontWeight.w300,
                                                                                  ),
                                                                                  textalign: TextAlign.start,
                                                                                ),
                                                                                Visibility(
                                                                                  visible: dummyData.specialPrice != "",
                                                                                  child: SizedBox(
                                                                                    width: 5,
                                                                                  ),
                                                                                ),
                                                                                // Text(
                                                                                //   dummyData.specialPrice == "" ? "₹ ${double.parse(dummyData.sortPrice!).toStringAsFixed(2)}" : "₹ ${double.parse(dummyData.specialPrice!).toStringAsFixed(2)}",
                                                                                //   style: TextStyle(
                                                                                //     fontSize: 11,
                                                                                //     fontFamily: Fontconstants.fc_family_sf,
                                                                                //     fontWeight: Fontconstants.SF_Pro_Display_Bold,
                                                                                //     color: commontextcolor,
                                                                                //   ),
                                                                                //
                                                                                // ),

                                                                                2.toSpace,
                                                                                CommanTextWidget.regularBold(
                                                                                  dummyData.specialPrice == "" ? "₹ ${double.parse(dummyData.sortPrice!).toStringAsFixed(2)}" : "₹ ${double.parse(dummyData.specialPrice!).toStringAsFixed(2)}",
                                                                                  commontextcolor,
                                                                                  maxline: 1,
                                                                                  trt: TextStyle(
                                                                                    fontSize: 9,
                                                                                    height: 1,
                                                                                    fontWeight: FontWeight.w800,
                                                                                  ),
                                                                                  textalign: TextAlign.start,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Sizeconfig.getWidth(context) > 400
                                                                                ? 10.toSpace
                                                                                : 5.toSpace,
                                                                            Align(
                                                                              alignment: Alignment.bottomRight,
                                                                              child: Container(
                                                                                  height: Sizeconfig.getHeight(context) * 0.04,
                                                                                  // width: 50,
                                                                                  /*  width: Sizeconfig.getWidth(context) * 0.14,*/
                                                                                  child: dummyData.addQuantity != 0
                                                                                      ? smallAddQuantityButton(ColorName.ColorPrimary, Colors.white, StringContants.lbl_add, dummyData.addQuantity! as int, () {
                                                                                          //increase

                                                                                          if (dummyData.addQuantity == int.parse(dummyData.orderQtyLimit!.toString())) {
                                                                                            Fluttertoast.showToast(msg: StringContants.msg_quanitiy);
                                                                                          } else {
                                                                                            dummyData.addQuantity = dummyData.addQuantity + 1;
                                                                                            bloc.add(ProductUpdateQuantityEvent(quanitity: dummyData.addQuantity!, index: index));
                                                                                            bloc.add(ProductChangeEvent(model: dummyData));
                                                                                            updateCard(dummyData, dbHelper, cardBloc);
                                                                                            debugPrint("Scroll Event1111 ");
                                                                                          }
                                                                                        }, () async {
                                                                                          if (dummyData.addQuantity == 1) {
                                                                                            debugPrint("SHOPBY 1");
                                                                                            dummyData.addQuantity = 0;

                                                                                            bloc.add(ProductUpdateQuantityEventBYModel(model: dummyData));

                                                                                            await dbHelper.deleteCard(int.parse(dummyData.productId!)).then((value) {
                                                                                              debugPrint("Delete Product $value ");

                                                                                              // cardBloc.add(CardDeleteEvent(
                                                                                              //     model: model,
                                                                                              //     listProduct:  list![0].unit!));

                                                                                              dbHelper.loadAddCardProducts(cardBloc);
                                                                                            });
                                                                                          } else if (dummyData.addQuantity != 0) {
                                                                                            debugPrint("SHOPBY 2");
                                                                                            dummyData.addQuantity = dummyData.addQuantity - 1;

                                                                                            updateCard(dummyData, dbHelper, cardBloc);
                                                                                            bloc.add(ProductUpdateQuantityEventBYModel(model: dummyData));

                                                                                            bloc.add(ProductChangeEvent(model: dummyData));
                                                                                          }
                                                                                        })
                                                                                      : smallbuttonPrimary(
                                                                                          ColorName.ColorPrimary,
                                                                                          Colors.white,
                                                                                          StringContants.lbl_add,
                                                                                          () {
                                                                                            dummyData.addQuantity = dummyData.addQuantity + 1;
                                                                                            checkItemId(dummyData.productId!, dbHelper).then((value) {
                                                                                              debugPrint("CheckItemId $value");

                                                                                              if (value == false) {
                                                                                                addCard(dummyData, dbHelper, cardBloc);
                                                                                              } else {
                                                                                                updateCard(dummyData, dbHelper, cardBloc);
                                                                                              }
                                                                                            });

                                                                                            bloc.add(ProductUpdateQuantityEvent(quanitity: dummyData.addQuantity!, index: index));
                                                                                            bloc.add(ProductChangeEvent(model: dummyData));
                                                                                          },
                                                                                        )),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )),
                                                          ],
                                                        ),
                                                      ),
                                                      /*Positioned(
                                                        right: 0,
                                                        bottom: 6,
                                                        child: Container(
                                                            height: Sizeconfig.getWidth(
                                                                        context) * 0.06,
                                                            width: Sizeconfig.getWidth(context) * 0.14,
                                                            child: dummyData
                                                                        .addQuantity !=
                                                                    0
                                                                ? smallAddQuantityButton(
                                                                    ColorName
                                                                        .ColorPrimary,
                                                                    commontextcolor,
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
                                                                          dummyData.orderQtyLimit!.toString())) {
                                                                    Fluttertoast.showToast(
                                                                        msg: StringContants
                                                                            .msg_quanitiy);
                                                                  } else {
                                                                    dummyData
                                                                            .addQuantity =
                                                                        dummyData.addQuantity +
                                                                            1;
                                                                    bloc.add(ProductUpdateQuantityEvent(
                                                                        quanitity: dummyData
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

                                                                      dbHelper
                                                                          .loadAddCardProducts(cardBloc);
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
                                                                : smallbuttonPrimary(
                                                                    ColorName
                                                                        .ColorPrimary,
                                                                    commontextcolor,
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
                                                      ),*/
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              buttontext == ""
                                  ? Container()
                                  : Appwidgets.MyUiButton(
                                      context,
                                      buttontext,
                                      buttonbackground,
                                      buttontextcolor,
                                      Sizeconfig.getWidth(context), () async {
                                      /* SharedPref.setStringPreference(
                                          Constants.sp_homepageproducts,
                                          jsonEncode(list));
                                      Navigator.pushNamed(
                                          context, Routes.featuredProduct,
                                          arguments: {
                                            "key": title,
                                            "list": list,
                                            "paninatinUrl": paginationurl
                                          }).then((value) {
                                        list = value as List<ProductData>;

                                        print("vlaueGG ${list!.length}");

                                        // bloc.add(OldListEvent(list: list!));
                                      });*/

                                      Category? category;

                                      int subcategoryIndex = 0;
                                      for (var x in categoriesList!) {
                                        print(
                                            "SeeAllGGGG id ${x.name} ${x.id} ${categoryId}");

                                        if (categoryId == x.id) {
                                          category = x;
                                        }
                                      }

                                      if (category == null) {
                                        for (var x in categoriesList!) {
                                          for (int y = 0;
                                              y < x.subCategories!.length;
                                              y++) {
                                            SubCategory sub =
                                                x.subCategories![y];
                                            print(
                                                "SeeAllGGGG2 id ${sub.name} ${sub.categoryId} ${categoryId}");
                                            if (categoryId == sub.categoryId) {
                                              subcategoryIndex = y;
                                              category = x;
                                            }
                                          }
                                        }
                                      }

                                      if (category == null) {
                                        for (var x in categoriesList!) {
                                          for (var y in x.subCategories!) {
                                            for (int z = 0;
                                                z < y.subCategories!.length;
                                                z++) {
                                              SubCategory sub =
                                                  y.subCategories![z];
                                              print(
                                                  "SeeAllGGGG3 id ${z} ${sub.name} ${sub.categoryId} ${categoryId}");
                                              if (categoryId ==
                                                  sub.categoryId) {
                                                subcategoryIndex = z;
                                                category = x;
                                              }
                                            }
                                          }
                                        }
                                      }

                                      print("SeeAllGGGG4  ${subcategoryIndex}");
                                      print(
                                          "SeeAllGGGG4  ${category!.subCategories![subcategoryIndex!]}");
                                      print("SeeAllGGGG4  ${category!.id}");
                                      print(
                                          "SeeAllGGGG4   ${category!.subCategories![subcategoryIndex!].categoryId}");
                                      Navigator.pushNamed(
                                          context, Routes.shop_by_category,
                                          arguments: {
                                            "selected_category": category,
                                            "category_list": categoriesList,
                                            "selected_sub_category":
                                                category!.subCategories![
                                                    subcategoryIndex!]
                                          }).then((value) {
                                        for (int index = 0;
                                            index < list!.length;
                                            index++) {
                                          var newmodel = list![index].unit![0];
                                          getCartQuantity(newmodel.productId!)
                                              .then((value) {
                                            debugPrint(
                                                "getCartQuanityUI $value");

                                            if (value > 0) {
                                              debugPrint(
                                                  "getCartQuanity name  ${list![index].unit![0].name}");
                                            }
                                            list![index].unit![0].addQuantity =
                                                value;
                                            // bloc.add(ProductUpdateQuantityInitial(list: list));
                                          });

                                          if (newmodel!.cOfferId != 0 &&
                                              newmodel.cOfferId != null) {
                                            debugPrint(
                                                "***********************");
                                            if (newmodel.subProduct != null) {
                                              log("***********************>>>>>>>>>>>>>>>>" +
                                                  newmodel.subProduct!
                                                      .toJson());
                                              if (newmodel
                                                      .subProduct!
                                                      .subProductDetail!
                                                      .length >
                                                  0) {
                                                list![index]
                                                        .unit![0]
                                                        .subProduct!
                                                        .subProductDetail =
                                                    MyUtility
                                                        .checkOfferSubProductLoad(
                                                            newmodel, dbHelper);
                                              }
                                            }
                                          }

                                          if (list![index].unit!.length > 1) {
                                            for (int i = 0;
                                                i < list![index].unit!.length;
                                                i++) {
                                              getCartQuantity(list![index]
                                                      .unit![i]
                                                      .productId!)
                                                  .then((value) {
                                                debugPrint(
                                                    "getCartQuanityUI $value");
                                                list![index]
                                                    .unit![i]
                                                    .addQuantity = value;
                                                // bloc.add(ProductUpdateQuantityInitial(list: list));
                                              });
                                            }
                                          }
                                        }
                                        //callback();
                                      });
                                    })
                            ],
                          ));
                    }),
              );
  }

  static ui_type2(
      bool fromchekcout,
      BuildContext context,
      dynamic state,
      String title,
      String subtitle,
      List<ProductData>? list,
      FeaturedBloc bloc,
      int isMoreUnitIndex,
      CardBloc cardBloc,
      DatabaseHelper dbHelper,
      ScrollController _scrollController,
      bool loadMore,
      var textcolor,
      var textsecondary,
      var themecolor,
      var abovecolor,
      var titlecolor,
      Function callback) {
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

                      // For Manage card list product Quanityt
                      if (state is ProductUpdateQuantityInitialState) {
                        list = state.list!;
                      }

                      return Container(
                        height: Sizeconfig.getHeight(context) < 800
                            ? Sizeconfig.getHeight(context) * 0.48
                            : Sizeconfig.getHeight(context) * 0.40,
                        child: Stack(
                          children: [
                            Container(
                              height: Sizeconfig.getHeight(context) * 0.10,
                              color: abovecolor,
                            ),
                            Container(
                              height: Sizeconfig.getHeight(context) * 0.20,
                              decoration: BoxDecoration(
                                  color: themecolor,
                                  borderRadius: BorderRadius.circular(5.0)),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: Sizeconfig.getWidth(context),
                                        child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 0, vertical: 0),
                                            child: CommanTextWidget.subheading(
                                                title, titlecolor)
                                            /*Appwidgets.TextLagre(
                                    title, titlecolor),*/
                                            ),
                                      ),
                                      Container(
                                        width: Sizeconfig.getWidth(context),
                                        child: Appwidgets.TextRegular(
                                            subtitle, ColorName.textlight),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                    height: Sizeconfig.getHeight(context) < 800
                                        ? Sizeconfig.getHeight(context) * 0.35
                                        : Sizeconfig.getHeight(context) * 0.29,
                                    child: ListView.builder(
                                        controller: _scrollController,
                                        shrinkWrap: true,
                                        itemCount: list!.length,
                                        scrollDirection: Axis.horizontal,
                                        padding: EdgeInsets.all(0),
                                        itemBuilder: (context, index) {
                                          var dummyData = list![index].unit![0];

                                          bool isMoreunit = false;

                                          debugPrint(
                                              "GGGGG  $index  =>  ${list![index].unit!.length.toString()}");
                                          if (list![index].unit!.length > 1) {
                                            isMoreunit = true;
                                          }

                                          debugPrint(
                                              "LAstIndex ${index == list!.length - 1}");

                                          if (state
                                              is ProductUpdateQuantityStateBYModel) {
                                            debugPrint(
                                                "LIST Featured Product State  " +
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
                                            debugPrint(
                                                "BestSellingG>>>>>>    " +
                                                    state.model.addQuantity
                                                        .toString());

                                            if (list![index].unit!.length ==
                                                1) {
                                              debugPrint(
                                                  "Quanititycondition  1 ");

                                              if (dummyData.productId ==
                                                  state.model.productId) {
                                                dummyData.addQuantity =
                                                    state.model.addQuantity;
                                                //G  bloc.add(ProductNullEvent());
                                              }
                                            } else {
                                              for (var obj
                                                  in list![index].unit!) {
                                                if (obj.productId ==
                                                    state.model.productId) {
                                                  debugPrint(
                                                      "Quanititycondition  2 ");
                                                  debugPrint(
                                                      "BestSellingG>>>>>> ****   " +
                                                          state
                                                              .model.addQuantity
                                                              .toString());
                                                  debugPrint(
                                                      "G>>>>>>Index    " +
                                                          isMoreUnitIndex
                                                              .toString());

                                                  if (dummyData!.cOfferId !=
                                                          0 &&
                                                      dummyData.cOfferId !=
                                                          null) {
                                                    debugPrint(
                                                        "##***********************");
                                                    if (dummyData.subProduct !=
                                                        null) {
                                                      log("##***********************>>>>>>>>>>>>>>>>" +
                                                          dummyData.subProduct!
                                                              .toJson());

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
                                                      "Quanititycondition  3 ${list![index].unit!.length}");
                                                  debugPrint("##****" +
                                                      state!.model!.name!);

                                                  if (dummyData!.cOfferId !=
                                                          0 &&
                                                      dummyData.cOfferId !=
                                                          null) {
                                                    debugPrint(
                                                        "##***********************");
                                                    if (dummyData.subProduct !=
                                                        null) {
                                                      log("##***********************>>>>>>>>>>>>>>>>" +
                                                          dummyData.subProduct!
                                                              .toJson());
                                                      if (dummyData
                                                              .subProduct!
                                                              .subProductDetail!
                                                              .length >
                                                          0) {
                                                        List<ProductUnit>?
                                                            listsubproduct =
                                                            dummyData
                                                                .subProduct!
                                                                .subProductDetail!;

                                                        for (int x = 0;
                                                            x <
                                                                listsubproduct
                                                                    .length;
                                                            x++) {
                                                          getCartQuantity(
                                                                  listsubproduct[
                                                                          x]
                                                                      .productId!)
                                                              .then((value) {
                                                            debugPrint(
                                                                "${listsubproduct[x].name} Sub Product Quantity quanityt ${value}");
                                                            listsubproduct[x]
                                                                    .addQuantity =
                                                                value;
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
                                          if (state is ProductUnitState) {
                                            if (dummyData.productId ==
                                                state.unit.productId) {
                                              dummyData = state.unit;
                                            }
                                          }
                                          return Stack(
                                            children: [
                                              Padding(
                                                padding: (index ==
                                                        list!.length - 1)
                                                    ? const EdgeInsets.only(
                                                        right: 7)
                                                    : index == 0
                                                        ? const EdgeInsets.only(
                                                            left: 7)
                                                        : EdgeInsets.symmetric(
                                                            horizontal: 0,
                                                            vertical: 0),
                                                child: Row(
                                                  children: [
                                                    Card(
                                                      elevation: 1,
                                                      color: Colors.white,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Stack(
                                                            children: [
                                                              GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  for (int i =
                                                                          0;
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
                                                                      isMoreUnitIndex =
                                                                          i;
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
                                                                      'list': list![
                                                                              index]
                                                                          .unit!,
                                                                      'index': isMoreunit
                                                                          ? isMoreUnitIndex
                                                                          : index,
                                                                    },
                                                                  ).then(
                                                                      (value) async {
                                                                    ProductUnit
                                                                        unit =
                                                                        value
                                                                            as ProductUnit;
                                                                    debugPrint(
                                                                        "FeatureCallback ${value.addQuantity}");

                                                                    SystemChrome
                                                                        .setSystemUIOverlayStyle(
                                                                            SystemUiOverlayStyle(
                                                                      statusBarColor:
                                                                          Colors
                                                                              .transparent, // transparent status bar
                                                                      statusBarIconBrightness:
                                                                          Brightness
                                                                              .light, // dark icons on the status bar
                                                                    ));
                                                                    bloc.add(ProductUpdateQuantityEvent(
                                                                        quanitity:
                                                                            unit
                                                                                .addQuantity!,
                                                                        index:
                                                                            index));
                                                                    callback();
                                                                  });
                                                                },
                                                                child:
                                                                    Container(
                                                                  width: Sizeconfig
                                                                          .getWidth(
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
                                                                        child:
                                                                            Stack(
                                                                          children: [
                                                                            Container(
                                                                              height: Sizeconfig.getWidth(context),
                                                                              width: Sizeconfig.getWidth(context),
                                                                              child: Align(
                                                                                alignment: Alignment.bottomCenter,
                                                                                child: Container(
                                                                                  height: Sizeconfig.getWidth(context) * .27,
                                                                                  width: Sizeconfig.getWidth(context) * .27,
                                                                                  child: CommonCachedImageWidget(
                                                                                    imgUrl: dummyData.image!,
                                                                                    width: Sizeconfig.getWidth(context) * .27,
                                                                                    height: Sizeconfig.getWidth(context) * .27,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Positioned(
                                                                                bottom: 5,
                                                                                right: 5,
                                                                                child: (dummyData!.cOfferId != 0 && dummyData.cOfferId != null)
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
                                                                          flex:
                                                                              5,
                                                                          child:
                                                                              Container(
                                                                            padding:
                                                                                EdgeInsets.symmetric(horizontal: 8),
                                                                            child:
                                                                                Column(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                                                                2.toSpace,
                                                                                Container(
                                                                                  // height: Sizeconfig.getHeight(context) * 0.05,
                                                                                  child: CommanTextWidget.regularBold(
                                                                                    dummyData.name!,
                                                                                    textcolor,
                                                                                    maxline: 2,
                                                                                    trt: TextStyle(
                                                                                      fontSize: 14,
                                                                                      height: 1.25,
                                                                                      fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                    textalign: TextAlign.start,
                                                                                  ),
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

                                                                                /* Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Container(
                                                                                      child: InkWell(
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
                                                                                ),*/
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Container(
                                                                                      child: InkWell(
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
                                                                                                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(4.0)), border: Border.all(width: 0.6, color: ColorName.textsecondary.withOpacity(0.5))),
                                                                                                child: Row(
                                                                                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                                                                            : Container(
                                                                                                height: 20,
                                                                                                padding: EdgeInsets.symmetric(horizontal: 8),
                                                                                                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(4.0)), border: Border.all(width: 0.6, color: ColorName.textsecondary.withOpacity(0.5))),
                                                                                                child: Center(
                                                                                                  child: CommanTextWidget.regularBold(
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
                                                                                      ),
                                                                                    ),
                                                                                    Container()
                                                                                  ],
                                                                                ),
                                                                                2.toSpace,
                                                                                Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Align(
                                                                                      alignment: Alignment.bottomLeft,
                                                                                      child: Container(
                                                                                        padding: EdgeInsets.only(bottom: 1),
                                                                                        child: Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          children: [
                                                                                            // Text(
                                                                                            //   dummyData.specialPrice == "" ? "" : "₹ ${double.parse(dummyData.price!).toStringAsFixed(2)}",
                                                                                            //   style: TextStyle(fontSize: 10, fontFamily: Fontconstants.fc_family_sf, fontWeight: Fontconstants.SF_Pro_Display_Medium, letterSpacing: 0, decoration: TextDecoration.lineThrough, decorationColor: textsecondary, color: textsecondary),
                                                                                            // ),

                                                                                            CommanTextWidget.regularBold(
                                                                                              dummyData.specialPrice == "" ? "" : "₹ ${double.parse(dummyData.price!).toStringAsFixed(2)}",
                                                                                              textsecondary,
                                                                                              maxline: 1,
                                                                                              trt: TextStyle(
                                                                                                fontSize: 11,
                                                                                                height: 1,
                                                                                                decoration: TextDecoration.lineThrough,
                                                                                                decorationColor: textsecondary,
                                                                                                fontWeight: FontWeight.w600,
                                                                                              ),
                                                                                              textalign: TextAlign.start,
                                                                                            ),
                                                                                            Visibility(
                                                                                              visible: dummyData.specialPrice != "",
                                                                                              child: SizedBox(
                                                                                                width: 5,
                                                                                              ),
                                                                                            ),
                                                                                            // Text(
                                                                                            //   dummyData.specialPrice == "" ? "₹ ${double.parse(dummyData.sortPrice!).toStringAsFixed(2)}" : "₹ ${double.parse(dummyData.specialPrice!).toStringAsFixed(2)}",
                                                                                            //   style: TextStyle(
                                                                                            //     fontSize: Constants.SizeMidium,
                                                                                            //     fontFamily: Fontconstants.fc_family_sf,
                                                                                            //     fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
                                                                                            //     color: textcolor,
                                                                                            //   ),
                                                                                            // ),
                                                                                            2.toSpace,

                                                                                            CommanTextWidget.regularBold(
                                                                                              dummyData.specialPrice == "" ? "₹ ${double.parse(dummyData.sortPrice!).toStringAsFixed(2)}" : "₹ ${double.parse(dummyData.specialPrice!).toStringAsFixed(2)}",
                                                                                              textcolor,
                                                                                              maxline: 1,
                                                                                              trt: TextStyle(
                                                                                                fontSize: 13,
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
                                                                    height: Sizeconfig.getWidth(context) * 0.08,
                                                                    child: dummyData.addQuantity != 0
                                                                        ? AddQuantityButton(ColorName.ColorPrimary, Colors.white, StringContants.lbl_add, dummyData.addQuantity! as int, () {
                                                                            //increase

                                                                            if (dummyData.addQuantity ==
                                                                                int.parse(dummyData.orderQtyLimit!.toString())) {
                                                                              Fluttertoast.showToast(msg: StringContants.msg_quanitiy);
                                                                            } else {
                                                                              dummyData.addQuantity = dummyData.addQuantity + 1;
                                                                              bloc.add(ProductUpdateQuantityEvent(quanitity: dummyData.addQuantity!, index: index));
                                                                              bloc.add(ProductChangeEvent(model: dummyData));
                                                                              updateCard(dummyData, dbHelper, cardBloc);
                                                                              debugPrint("Scroll Event1111 ");
                                                                            }
                                                                          }, () async {
                                                                            if (dummyData.addQuantity ==
                                                                                1) {
                                                                              debugPrint("SHOPBY 1");
                                                                              dummyData.addQuantity = 0;

                                                                              bloc.add(ProductUpdateQuantityEventBYModel(model: dummyData));

                                                                              await dbHelper.deleteCard(int.parse(dummyData.productId!)).then((value) {
                                                                                debugPrint("Delete Product $value ");

                                                                                // cardBloc.add(CardDeleteEvent(
                                                                                //     model: model,
                                                                                //     listProduct:  list![0].unit!));

                                                                                dbHelper.loadAddCardProducts(cardBloc);
                                                                              });
                                                                            } else if (dummyData.addQuantity !=
                                                                                0) {
                                                                              debugPrint("SHOPBY 2");
                                                                              dummyData.addQuantity = dummyData.addQuantity - 1;

                                                                              updateCard(dummyData, dbHelper, cardBloc);
                                                                              bloc.add(ProductUpdateQuantityEventBYModel(model: dummyData));

                                                                              bloc.add(ProductChangeEvent(model: dummyData));
                                                                            }
                                                                          })
                                                                        : buttonPrimary(
                                                                            ColorName.ColorPrimary,
                                                                            Colors.white,
                                                                            StringContants.lbl_add,
                                                                            () {
                                                                              dummyData.addQuantity = dummyData.addQuantity + 1;
                                                                              checkItemId(dummyData.productId!, dbHelper).then((value) {
                                                                                debugPrint("CheckItemId $value");

                                                                                if (value == false) {
                                                                                  addCard(dummyData, dbHelper, cardBloc);
                                                                                } else {
                                                                                  updateCard(dummyData, dbHelper, cardBloc);
                                                                                }
                                                                              });

                                                                              bloc.add(ProductUpdateQuantityEvent(quanitity: dummyData.addQuantity!, index: index));
                                                                              bloc.add(ProductChangeEvent(model: dummyData));
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
                                                        : index !=
                                                                    (list!.length -
                                                                        1) ||
                                                                list!.length < 4
                                                            ? Container()
                                                            : Container(
                                                                height: 30,
                                                                width: 30,
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            10),
                                                                child: list!.length <
                                                                        3
                                                                    ? Container()
                                                                    : CircularProgressIndicator(
                                                                        color: ColorName
                                                                            .ColorPrimary,
                                                                      ))
                                                  ],
                                                ),
                                              ),
                                              Positioned(
                                                top: 4,
                                                left: 3,
                                                child: Padding(
                                                  padding: index == 0
                                                      ? const EdgeInsets.only(
                                                          left: 7)
                                                      : EdgeInsets.zero,
                                                  child:
                                                      (dummyData.discountText ??
                                                                  "") ==
                                                              ""
                                                          ? Container()
                                                          : Visibility(
                                                              visible: (dummyData
                                                                          .discountText !=
                                                                      "" ||
                                                                  dummyData
                                                                          .discountText !=
                                                                      null),
                                                              child: Stack(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                children: [
                                                                  ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(10)),
                                                                    child: Image
                                                                        .asset(
                                                                      Imageconstants
                                                                          .img_tag,
                                                                      height:
                                                                          40,
                                                                      width: 38,
                                                                      fit: BoxFit
                                                                          .fill,
                                                                    ),
                                                                  ),
                                                                  Positioned(
                                                                    top: 1,
                                                                    // alignment: Alignment.center,
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              5),
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
                                                                          color:
                                                                              ColorName.black,
                                                                          fontSize:
                                                                              9.5,
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
                                        })

                                    /*ListView.builder(
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
                                  debugPrint(
                                      "LIST Featured Product State  " +
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
                                  if (list![index].unit!.length==1) {
                                    debugPrint("Quanititycondition  1 ");


                                    if(dummyData.productId==state.model.productId)
                                    {
                                      dummyData.addQuantity = state.model.addQuantity;
                                    //G  bloc.add(ProductNullEvent());
                                    }
                                  }
                                  else {
                                    for (var obj
                                    in list![index].unit!) {
                                      if (obj.name ==
                                          state.model.name ||
                                          obj.productId ==
                                              state.model.productId) {
                                        debugPrint(
                                            "G>>>>>>>>>>>>>>>>>>>>    " +
                                                state
                                                    .model.addQuantity
                                                    .toString());

                                        debugPrint(
                                            "G>>>>>>Index    " +
                                                isMoreUnitIndex
                                                    .toString());

                                        if (dummyData!.cOfferId !=
                                            0 &&
                                            dummyData.cOfferId !=
                                                null) {
                                          debugPrint(
                                              "##***********************");
                                          if (dummyData.subProduct !=
                                              null) {
                                            log("##***********************>>>>>>>>>>>>>>>>" +
                                                dummyData.subProduct!
                                                    .toJson());

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
                                        debugPrint("##****" +
                                            state!.model!.name!);

                                        if (dummyData!.cOfferId !=
                                            0 &&
                                            dummyData.cOfferId !=
                                                null) {
                                          debugPrint(
                                              "##***********************");
                                          if (dummyData.subProduct !=
                                              null) {
                                            log("##***********************>>>>>>>>>>>>>>>>" +
                                                dummyData.subProduct!
                                                    .toJson());
                                            if (dummyData
                                                .subProduct!
                                                .subProductDetail!
                                                .length >
                                                0) {
                                              List<ProductUnit>?
                                              listsubproduct =
                                              dummyData
                                                  .subProduct!
                                                  .subProductDetail!;

                                              for (int x = 0;
                                              x <
                                                  listsubproduct
                                                      .length;
                                              x++) {
                                                getCartQuantity(
                                                    listsubproduct[
                                                    x]
                                                        .productId!)
                                                    .then((value) {
                                                  debugPrint(
                                                      "${listsubproduct[x].name} Sub Product Quantity quanityt ${value}");
                                                  listsubproduct[x]
                                                      .addQuantity =
                                                      value;
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
                                return GestureDetector(
                                  onTap: () async {
                                    for (int i = 0;
                                    i <
                                        list![index]
                                            .unit!
                                            .length!;
                                    i++) {
                                      debugPrint(
                                          "Model  ${dummyData.productId} ${dummyData.addQuantity} ");
                                      if (dummyData.productId ==
                                          list![index]
                                              .unit![i]
                                              .productId!) {
                                        list![index].unit![i] =
                                            dummyData;
                                        isMoreUnitIndex = i;
                                      }
                                      debugPrint(
                                          "DATA Model  ${list![index].unit![i].productId!}  ${list![index].unit![i].addQuantity!}");
                                    }

                                    await Navigator.pushNamed(
                                      context,
                                      Routes.product_Detail_screen,
                                      arguments: {
                                       'fromchekcout': fromchekcout,
                                        'list': list![index].unit!,
                                        'index': isMoreunit
                                            ? isMoreUnitIndex
                                            : index,
                                      },
                                    ).then((value) async {
                                      ProductUnit unit =
                                      value as ProductUnit;
                                      debugPrint(
                                          "FeatureCallback ${value.addQuantity}");

                                      SystemChrome
                                          .setSystemUIOverlayStyle(
                                          SystemUiOverlayStyle(
                                            statusBarColor: Colors
                                                .transparent, // transparent status bar
                                            statusBarIconBrightness:
                                            Brightness
                                                .light, // dark icons on the status bar
                                          ));
                                      bloc.add(
                                          ProductUpdateQuantityEvent(
                                              quanitity:
                                              unit.addQuantity!,
                                              index: index));
                                      callback();
                                    });
                                  },
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding:
                                        index==0?EdgeInsets.only(left: 10):
                                        EdgeInsets.symmetric(
                                            horizontal: 0,
                                            vertical: 0),
                                        child: Card(
                                          elevation: 1,
                                          color: Colors.white,
                                          shape:
                                          RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(
                                                10.0),
                                          ),
                                          child: Row(
                                            children: [
                                              Stack(
                                                children: [
                                                  Container(
                                                    // height: Sizeconfig.getHeight(context)*0.2,
                                                    width: Sizeconfig
                                                        .getWidth(
                                                        context) *
                                                        0.36,
                                                    //padding: EdgeInsets.all(4),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .center,
                                                      children: [
                                                        Expanded(
                                                          flex: 4,
                                                          child:
                                                          Stack(
                                                            children: [
                                                              Container(
                                                                height:
                                                                Sizeconfig.getWidth(context),
                                                                width:
                                                                Sizeconfig.getWidth(context),
                                                                decoration:
                                                                BoxDecoration(
                                                                  color:
                                                                  Colors.white,
                                                                  borderRadius:
                                                                  BorderRadius.circular(10),
                                                                  border:
                                                                  Border.all(width: 1, color: ColorName.newgray),
                                                                ),
                                                                child:
                                                                Center(
                                                                  child:
                                                                  Padding(
                                                                    padding: EdgeInsets.symmetric(horizontal: 0),
                                                                    child: Stack(
                                                                      children: [
                                                                        Center(
                                                                          child: ClipRRect(
                                                                            borderRadius: BorderRadius.circular(10.0),
                                                                            child: Container(
                                                                              height: Sizeconfig.getWidth(context) * .25,
                                                                              padding: EdgeInsets.all(4),
                                                                              width: Sizeconfig.getWidth(context) * .25,
                                                                              child: CommonCachedImageWidget(
                                                                                imgUrl: dummyData.image!,
                                                                                width: Sizeconfig.getWidth(context) * .25,
                                                                                height: Sizeconfig.getWidth(context) * .25,
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
                                                          ),
                                                        ),
                                                        Expanded(
                                                            flex: 5,
                                                            child:
                                                            Container(
                                                              padding:
                                                              EdgeInsets.symmetric(horizontal: 5),
                                                              child:
                                                              Column(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment.spaceBetween,
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
                                                                          dummyData.name!,
                                                                          maxLines: 2,
                                                                          style: TextStyle(
                                                                            fontSize: 12,
                                                                            fontFamily: Fontconstants.fc_family_sf,
                                                                            fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
                                                                            color: Colors.black,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      (dummyData!.cOfferId != 0 && dummyData.cOfferId != null)
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
                                                                        // decoration: isMoreunit
                                                                        //     ? BoxDecoration(
                                                                        //   color: ColorName
                                                                        //       .ColorBagroundPrimary,
                                                                        //   // borderRadius:
                                                                        //   // BorderRadius.circular(10),
                                                                        //   // border: Border.all(
                                                                        //   //     color:
                                                                        //   //     ColorName.lightGey),
                                                                        // )
                                                                        //     : null,
                                                                        margin: isMoreunit ? EdgeInsets.only(top: 5) : null,

                                                                        width: Sizeconfig.getWidth(context) * .20,
                                                                        child: Align(
                                                                          alignment: Alignment.center,
                                                                          child: Row(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                                    alignment: Alignment.bottomCenter,
                                                                    child: Container(
                                                                      padding: EdgeInsets.only(bottom: 5),
                                                                      child: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                        height: Sizeconfig
                                                            .getWidth(
                                                            context) *
                                                            0.08,
                                                        child: dummyData
                                                            .addQuantity !=
                                                            0
                                                            ? Container(
                                                          alignment:
                                                          Alignment.bottomRight,
                                                          child: AddQuantityButton(
                                                              ColorName.ColorPrimary,
                                                              Colors.white,
                                                              StringContants.lbl_add,
                                                              dummyData.addQuantity! as int, () {
                                                            //increase

                                                            if (dummyData.addQuantity ==
                                                                int.parse(dummyData.quantity!)) {
                                                              Fluttertoast.showToast(msg: StringContants.msg_quanitiy);
                                                            } else {
                                                              dummyData.addQuantity = dummyData.addQuantity + 1;
                                                              bloc.add(ProductUpdateQuantityEvent(quanitity: dummyData.addQuantity!, index: index));
                                                              bloc.add(ProductChangeEvent(model: dummyData));
                                                              updateCard(dummyData, dbHelper, cardBloc);
                                                              debugPrint("Scroll Event1111 ");
                                                            }
                                                          }, () async {
                                                            if (dummyData.addQuantity ==
                                                                1) {
                                                              debugPrint("SHOPBY 1");
                                                              dummyData.addQuantity = 0;

                                                              bloc.add(ProductUpdateQuantityEventBYModel(model: dummyData));

                                                              await dbHelper.deleteCard(int.parse(dummyData.productId!)).then((value) {
                                                                debugPrint("Delete Product $value ");

                                                                // cardBloc.add(CardDeleteEvent(
                                                                //     model: model,
                                                                //     listProduct:  list![0].unit!));

                                                                dbHelper.loadAddCardProducts(cardBloc);
                                                              });
                                                            } else if (dummyData.addQuantity !=
                                                                0) {
                                                              debugPrint("SHOPBY 2");
                                                              dummyData.addQuantity = dummyData.addQuantity - 1;

                                                              updateCard(dummyData, dbHelper, cardBloc);
                                                              bloc.add(ProductUpdateQuantityEventBYModel(model: dummyData));

                                                              bloc.add(ProductChangeEvent(model: dummyData));
                                                            }
                                                          }),
                                                        )
                                                            : buttonPrimary(
                                                          ColorName
                                                              .ColorPrimary,
                                                          Colors
                                                              .white,
                                                          StringContants
                                                              .lbl_add,
                                                              () {
                                                            dummyData.addQuantity =
                                                                dummyData.addQuantity + 1;
                                                            checkItemId(dummyData.productId!, dbHelper).then((value) {
                                                              debugPrint("CheckItemId $value");

                                                              if (value == false) {
                                                                addCard(dummyData, dbHelper, cardBloc);
                                                              } else {
                                                                updateCard(dummyData, dbHelper, cardBloc);
                                                              }
                                                            });

                                                            bloc.add(ProductUpdateQuantityEvent(
                                                                quanitity: dummyData.addQuantity!,
                                                                index: index));
                                                            bloc.add(ProductChangeEvent(model: dummyData));
                                                          },
                                                        )),
                                                  ),
                                                  Positioned(
                                                      top: 0,
                                                      left: 0,
                                                      child: (dummyData.discountText ??
                                                          "") ==
                                                          ""
                                                          ? Container()
                                                          : Visibility(
                                                        visible: (dummyData!.discountText !=
                                                            "" ||
                                                            dummyData!.discountText !=
                                                                null),
                                                        child:
                                                        Positioned(
                                                          // left: 7,
                                                          left:
                                                          0,
                                                          top:
                                                          0,
                                                          child:
                                                          Stack(
                                                            alignment:
                                                            Alignment.center,
                                                            children: [
                                                              ClipRRect(
                                                                borderRadius: BorderRadius.only(topLeft: Radius.circular(5.0)),
                                                                child: Image.asset(
                                                                  Imageconstants.img_tag,
                                                                  height: 25,
                                                                  width: 31,
                                                                  fit: BoxFit.fill,
                                                                ),
                                                              ),
                                                              Align(
                                                                alignment: Alignment.center,
                                                                child: Text(
                                                                  dummyData.discountText ?? "",
                                                                  overflow: TextOverflow.ellipsis,
                                                                  maxLines: 2,
                                                                  style: const TextStyle(
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
                                                  : index !=
                                                  (list!.length -
                                                      1)
                                                  ? Container()
                                                  : Container(
                                                  height: 30,
                                                  width: 30,
                                                  margin: EdgeInsets
                                                      .only(
                                                      left:
                                                      10),
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
                                );
                              })*/

                                    ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
              );
  }

  //BestSelling Items
  static ui_type3(
      bool fromchekcout,
      BuildContext context,
      dynamic state,
      String title,
      String subtitle,
      List<ProductData>? list,
      FeaturedBloc bloc,
      int isMoreUnitIndex,
      CardBloc cardBloc,
      DatabaseHelper dbHelper,
      ScrollController _scrollController,
      bool loadMore,
      var themecolor,
      var textcolor,
      var textsecondary,
      var titlecolor,
      var buttonbackground,
      var buttontextcolor,
      String buttontext,
      Function callback,
      String paginationurl,
      List<Category>? categoriesList,
      String categoryId) {
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
                      debugPrint(
                          "BestSelling Product State  " + state.toString());

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

                      // For Manage card list product Quanityt
                      if (state is ProductUpdateQuantityInitialState) {
                        list = state.list!;
                      }

                      if (state is OldListState) {
                        list = state.list!;
                      }

                      return Container(
                        height: buttontext == ""
                            ? Sizeconfig.getHeight(context) * 0.44
                            : Sizeconfig.getHeight(context) * 0.44,
                        child: Stack(
                          children: [
                            Container(
                              height: Sizeconfig.getHeight(context) * 0.20,
                              color: themecolor,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                            width: Sizeconfig.getWidth(context),
                                            child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 0, vertical: 0),
                                                child:
                                                    CommanTextWidget.subheading(
                                                        title, titlecolor)
                                                /* Text(
                                      title,
                                      style: TextStyle(
                                          fontSize: 16,
                                          letterSpacing: 0.7,
                                          fontFamily: Fontconstants
                                              .fc_family_sf,
                                          fontWeight: FontWeight.w600,
                                          color: titlecolor),
                                    ),*/
                                                )),
                                        2.toSpace,
                                        Container(
                                            width: Sizeconfig.getWidth(context),
                                            child: CommanTextWidget.subtitle(
                                                subtitle, titlecolor)),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                    height:
                                        Sizeconfig.getHeight(context) * 0.32,
                                    child: ListView.builder(
                                        controller: _scrollController,
                                        shrinkWrap: true,
                                        itemCount: list!.length,
                                        scrollDirection: Axis.horizontal,
                                        padding: EdgeInsets.all(0),
                                        itemBuilder: (context, index) {
                                          var dummyData = list![index].unit![0];

                                          bool isMoreunit = false;

                                          debugPrint(
                                              "GGGGG  $index  =>  ${list![index].unit!.length.toString()}");
                                          if (list![index].unit!.length > 1) {
                                            isMoreunit = true;
                                          }

                                          debugPrint(
                                              "LAstIndex ${index == list!.length - 1}");

                                          if (state
                                              is ProductUpdateQuantityStateBYModel) {
                                            debugPrint(
                                                "LIST Featured Product State  " +
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
                                            debugPrint(
                                                "BestSellingG>>>>>>    " +
                                                    state.model.addQuantity
                                                        .toString());

                                            if (list![index].unit!.length ==
                                                1) {
                                              debugPrint(
                                                  "Quanititycondition  1 ");

                                              if (dummyData.productId ==
                                                  state.model.productId) {
                                                dummyData.addQuantity =
                                                    state.model.addQuantity;
                                                //G  bloc.add(ProductNullEvent());
                                              }
                                            } else {
                                              for (var obj
                                                  in list![index].unit!) {
                                                if (obj.productId ==
                                                    state.model.productId) {
                                                  debugPrint(
                                                      "Quanititycondition  2 ");
                                                  debugPrint(
                                                      "BestSellingG>>>>>> ****   " +
                                                          state
                                                              .model.addQuantity
                                                              .toString());
                                                  debugPrint(
                                                      "G>>>>>>Index    " +
                                                          isMoreUnitIndex
                                                              .toString());

                                                  if (dummyData!.cOfferId !=
                                                          0 &&
                                                      dummyData.cOfferId !=
                                                          null) {
                                                    debugPrint(
                                                        "##***********************");
                                                    if (dummyData.subProduct !=
                                                        null) {
                                                      log("##***********************>>>>>>>>>>>>>>>>" +
                                                          dummyData.subProduct!
                                                              .toJson());

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
                                                      "Quanititycondition  3 ${list![index].unit!.length}");
                                                  debugPrint("##****" +
                                                      state!.model!.name!);

                                                  if (dummyData!.cOfferId !=
                                                          0 &&
                                                      dummyData.cOfferId !=
                                                          null) {
                                                    debugPrint(
                                                        "##***********************");
                                                    if (dummyData.subProduct !=
                                                        null) {
                                                      log("##***********************>>>>>>>>>>>>>>>>" +
                                                          dummyData.subProduct!
                                                              .toJson());
                                                      if (dummyData
                                                              .subProduct!
                                                              .subProductDetail!
                                                              .length >
                                                          0) {
                                                        List<ProductUnit>?
                                                            listsubproduct =
                                                            dummyData
                                                                .subProduct!
                                                                .subProductDetail!;

                                                        for (int x = 0;
                                                            x <
                                                                listsubproduct
                                                                    .length;
                                                            x++) {
                                                          getCartQuantity(
                                                                  listsubproduct[
                                                                          x]
                                                                      .productId!)
                                                              .then((value) {
                                                            debugPrint(
                                                                "${listsubproduct[x].name} Sub Product Quantity quanityt ${value}");
                                                            listsubproduct[x]
                                                                    .addQuantity =
                                                                value;
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

                                          if (state is ProductUnitState) {
                                            if (dummyData.productId ==
                                                state.unit.productId) {
                                              dummyData = state.unit;
                                            }
                                          }

                                          return Stack(
                                            children: [
                                              Padding(
                                                padding: (index ==
                                                        list!.length - 1)
                                                    ? const EdgeInsets.only(
                                                        right: 7)
                                                    : index == 0
                                                        ? const EdgeInsets.only(
                                                            left: 7)
                                                        : EdgeInsets.symmetric(
                                                            horizontal: 0,
                                                            vertical: 0),
                                                child: Row(
                                                  children: [
                                                    Card(
                                                      elevation: 1,
                                                      color: Colors.white,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Stack(
                                                            children: [
                                                              GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  for (int i =
                                                                          0;
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
                                                                      isMoreUnitIndex =
                                                                          i;
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
                                                                      'list': list![
                                                                              index]
                                                                          .unit!,
                                                                      'index': isMoreunit
                                                                          ? isMoreUnitIndex
                                                                          : index,
                                                                    },
                                                                  ).then(
                                                                      (value) async {
                                                                    ProductUnit
                                                                        unit =
                                                                        value
                                                                            as ProductUnit;
                                                                    debugPrint(
                                                                        "FeatureCallback ${value.addQuantity}");

                                                                    SystemChrome
                                                                        .setSystemUIOverlayStyle(
                                                                            SystemUiOverlayStyle(
                                                                      statusBarColor:
                                                                          Colors
                                                                              .transparent, // transparent status bar
                                                                      statusBarIconBrightness:
                                                                          Brightness
                                                                              .light, // dark icons on the status bar
                                                                    ));
                                                                    bloc.add(ProductUpdateQuantityEvent(
                                                                        quanitity:
                                                                            unit
                                                                                .addQuantity!,
                                                                        index:
                                                                            index));
                                                                    callback();
                                                                  });
                                                                },
                                                                child:
                                                                    Container(
                                                                  width: Sizeconfig
                                                                          .getWidth(
                                                                              context) *
                                                                      0.40,
                                                                  //padding: EdgeInsets.all(4),
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Expanded(
                                                                        flex: Sizeconfig.getWidth(context) <
                                                                                400
                                                                            ? 4
                                                                            : 5,
                                                                        child:
                                                                            Stack(
                                                                          children: [
                                                                            Container(
                                                                              height: Sizeconfig.getWidth(context),
                                                                              width: Sizeconfig.getWidth(context),
                                                                              child: Align(
                                                                                alignment: Alignment.bottomCenter,
                                                                                child: Container(
                                                                                  height: Sizeconfig.getWidth(context) * .27,
                                                                                  width: Sizeconfig.getWidth(context) * .27,
                                                                                  child: CommonCachedImageWidget(
                                                                                    imgUrl: dummyData.image!,
                                                                                    width: Sizeconfig.getWidth(context) * .27,
                                                                                    height: Sizeconfig.getWidth(context) * .27,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Positioned(
                                                                                bottom: 5,
                                                                                right: 5,
                                                                                child: (dummyData!.cOfferId != 0 && dummyData.cOfferId != null)
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
                                                                          flex:
                                                                              5,
                                                                          child:
                                                                              Container(
                                                                            padding:
                                                                                EdgeInsets.symmetric(horizontal: 8),
                                                                            child:
                                                                                Column(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                                                                2.toSpace,
                                                                                CommanTextWidget.regularBold(
                                                                                  dummyData.name!,
                                                                                  textcolor,
                                                                                  maxline: 2,
                                                                                  trt: TextStyle(
                                                                                    fontSize: 14,
                                                                                    height: 1.25,
                                                                                    fontWeight: FontWeight.w600,
                                                                                  ),
                                                                                  textalign: TextAlign.start,
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

                                                                                /*     Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Container(
                                                                                      child: InkWell(
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
                                                                                ),*/
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Container(
                                                                                      child: InkWell(
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
                                                                                                height: 22,
                                                                                                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(4.0)), border: Border.all(width: 0.6, color: ColorName.textsecondary.withOpacity(0.5))),
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
                                                                                                            fontSize: 13,
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
                                                                                            : Container(
                                                                                                height: 22,
                                                                                                padding: EdgeInsets.symmetric(horizontal: 8),
                                                                                                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(4.0)), border: Border.all(width: 0.6, color: ColorName.textsecondary.withOpacity(0.5))),
                                                                                                child: CommanTextWidget.regularBold(
                                                                                                  dummyData.productWeight.toString() + " ${dummyData.productWeightUnit}",
                                                                                                  ColorName.textsecondary,
                                                                                                  maxline: 2,
                                                                                                  trt: TextStyle(
                                                                                                    fontSize: 13,
                                                                                                    fontWeight: FontWeight.w600,
                                                                                                  ),
                                                                                                  textalign: TextAlign.start,
                                                                                                ),
                                                                                              ),
                                                                                      ),
                                                                                    ),
                                                                                    Container()
                                                                                  ],
                                                                                ),

                                                                                2.toSpace,
                                                                                Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Align(
                                                                                      alignment: Alignment.bottomLeft,
                                                                                      child: Container(
                                                                                        padding: EdgeInsets.only(bottom: 5),
                                                                                        child: Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          children: [
                                                                                            // Text(
                                                                                            //   dummyData.specialPrice == "" ? "" : "₹ ${double.parse(dummyData.price!).toStringAsFixed(2)}",
                                                                                            //   style: TextStyle(fontSize: 10, fontFamily: Fontconstants.fc_family_sf, fontWeight: Fontconstants.SF_Pro_Display_Medium, letterSpacing: 0, decoration: TextDecoration.lineThrough, decorationColor: textsecondary, color: textsecondary),
                                                                                            // ),

                                                                                            CommanTextWidget.regularBold(
                                                                                              dummyData.specialPrice == "" ? "" : "₹ ${double.parse(dummyData.price!).toStringAsFixed(2)}",
                                                                                              textsecondary,
                                                                                              maxline: 1,
                                                                                              trt: TextStyle(
                                                                                                fontSize: 11,
                                                                                                height: 1,
                                                                                                decoration: TextDecoration.lineThrough,
                                                                                                decorationColor: textsecondary,
                                                                                                fontWeight: FontWeight.w600,
                                                                                              ),
                                                                                              textalign: TextAlign.start,
                                                                                            ),
                                                                                            Visibility(
                                                                                              visible: dummyData.specialPrice != "",
                                                                                              child: SizedBox(
                                                                                                width: 5,
                                                                                              ),
                                                                                            ),
                                                                                            // Text(
                                                                                            //   dummyData.specialPrice == "" ? "₹ ${double.parse(dummyData.sortPrice!).toStringAsFixed(2)}" : "₹ ${double.parse(dummyData.specialPrice!).toStringAsFixed(2)}",
                                                                                            //   style: TextStyle(
                                                                                            //     fontSize: Constants.SizeMidium,
                                                                                            //     fontFamily: Fontconstants.fc_family_sf,
                                                                                            //     fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
                                                                                            //     color: textcolor,
                                                                                            //   ),
                                                                                            // ),
                                                                                            2.toSpace,

                                                                                            CommanTextWidget.regularBold(
                                                                                              dummyData.specialPrice == "" ? "₹ ${double.parse(dummyData.sortPrice!).toStringAsFixed(2)}" : "₹ ${double.parse(dummyData.specialPrice!).toStringAsFixed(2)}",
                                                                                              textcolor,
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
                                                                right: 0,
                                                                bottom: 0,
                                                                // bottom: 0,
                                                                child: Container(
                                                                    height: Sizeconfig.getHeight(context) * 0.04,
                                                                    // width: Sizeconfig.getWidth(context) * .2,
                                                                    alignment: Alignment.center,
                                                                    child: dummyData.addQuantity != 0
                                                                        ? AddQuantityButton(ColorName.ColorPrimary, Colors.white, StringContants.lbl_add, dummyData.addQuantity! as int, () {
                                                                            //increase

                                                                            if (dummyData.addQuantity ==
                                                                                int.parse(dummyData.orderQtyLimit!.toString())) {
                                                                              Fluttertoast.showToast(msg: StringContants.msg_quanitiy);
                                                                            } else {
                                                                              dummyData.addQuantity = dummyData.addQuantity + 1;
                                                                              bloc.add(ProductUpdateQuantityEvent(quanitity: dummyData.addQuantity!, index: index));
                                                                              bloc.add(ProductChangeEvent(model: dummyData));
                                                                              updateCard(dummyData, dbHelper, cardBloc);
                                                                              debugPrint("Scroll Event1111 ");
                                                                            }
                                                                          }, () async {
                                                                            if (dummyData.addQuantity ==
                                                                                1) {
                                                                              debugPrint("SHOPBY 1");
                                                                              dummyData.addQuantity = 0;

                                                                              bloc.add(ProductUpdateQuantityEventBYModel(model: dummyData));

                                                                              await dbHelper.deleteCard(int.parse(dummyData.productId!)).then((value) {
                                                                                debugPrint("Delete Product $value ");

                                                                                // cardBloc.add(CardDeleteEvent(
                                                                                //     model: model,
                                                                                //     listProduct:  list![0].unit!));

                                                                                dbHelper.loadAddCardProducts(cardBloc);
                                                                              });
                                                                            } else if (dummyData.addQuantity !=
                                                                                0) {
                                                                              debugPrint("SHOPBY 2");
                                                                              dummyData.addQuantity = dummyData.addQuantity - 1;

                                                                              updateCard(dummyData, dbHelper, cardBloc);
                                                                              bloc.add(ProductUpdateQuantityEventBYModel(model: dummyData));

                                                                              bloc.add(ProductChangeEvent(model: dummyData));
                                                                            }
                                                                          })
                                                                        : buttonPrimary(
                                                                            ColorName.ColorPrimary,
                                                                            Colors.white,
                                                                            StringContants.lbl_add,
                                                                            () {
                                                                              dummyData.addQuantity = dummyData.addQuantity + 1;
                                                                              checkItemId(dummyData.productId!, dbHelper).then((value) {
                                                                                debugPrint("CheckItemId $value");

                                                                                if (value == false) {
                                                                                  addCard(dummyData, dbHelper, cardBloc);
                                                                                } else {
                                                                                  updateCard(dummyData, dbHelper, cardBloc);
                                                                                }
                                                                              });

                                                                              bloc.add(ProductUpdateQuantityEvent(quanitity: dummyData.addQuantity!, index: index));
                                                                              bloc.add(ProductChangeEvent(model: dummyData));
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
                                                        : index !=
                                                                    (list!.length -
                                                                        1) ||
                                                                list!.length < 4
                                                            ? Container()
                                                            : Container(
                                                                height: 30,
                                                                width: 30,
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            10),
                                                                child: list!.length <
                                                                        3
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
                                                        ? const EdgeInsets.only(
                                                            left: 7)
                                                        : EdgeInsets.symmetric(
                                                            horizontal: 0,
                                                            vertical: 0),
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
                                                                child: Stack(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  children: [
                                                                    Positioned(
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.only(topLeft: Radius.circular(10.0)),
                                                                        child: Image
                                                                            .asset(
                                                                          Imageconstants
                                                                              .img_tag,
                                                                          height:
                                                                              40,
                                                                          width:
                                                                              38,
                                                                          fit: BoxFit
                                                                              .fill,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Positioned(
                                                                      top: 1,
                                                                      child:
                                                                          Container(
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
                                                                            color:
                                                                                ColorName.black,
                                                                            fontSize:
                                                                                9.5,
                                                                            fontWeight:
                                                                                FontWeight.w700,
                                                                          ),
                                                                          // overflow:
                                                                          //     TextOverflow.ellipsis,
                                                                          // maxLines:
                                                                          //     2,
                                                                          // style:
                                                                          //     const TextStyle(
                                                                          //   color:
                                                                          //       ColorName.black,
                                                                          //   fontSize:
                                                                          //       10,
                                                                          //   fontWeight:
                                                                          //       FontWeight.w500,
                                                                          // ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )),
                                              ),
                                            ],
                                          );
                                        })),
                                buttontext == ""
                                    ? Container()
                                    : Appwidgets.MyUiButton(
                                        context,
                                        buttontext,
                                        buttonbackground,
                                        buttontextcolor,
                                        Sizeconfig.getWidth(context), () async {
                                        /* SharedPref.setStringPreference(
                                            Constants.sp_homepageproducts,
                                            jsonEncode(list));
                                        Navigator.pushNamed(
                                            context, Routes.featuredProduct,
                                            arguments: {
                                              "key": title,
                                              "list": list,
                                              "paninatinUrl": paginationurl
                                            }).then((value) {
                                          list = value as List<ProductData>;

                                          print("vlaueGG ${list!.length}");

                                          bloc.add(OldListEvent(list: list!));
                                        });*/

                                        Category? category;

                                        int subcategoryIndex = 0;
                                        for (var x in categoriesList!) {
                                          print(
                                              "SeeAllGGGG id ${x.name} ${x.id} ${categoryId}");

                                          if (categoryId == x.id) {
                                            category = x;
                                          }
                                        }

                                        if (category == null) {
                                          for (var x in categoriesList!) {
                                            for (int y = 0;
                                                y < x.subCategories!.length;
                                                y++) {
                                              SubCategory sub =
                                                  x.subCategories![y];
                                              print(
                                                  "SeeAllGGGG2 id ${sub.name} ${sub.categoryId} ${categoryId}");
                                              if (categoryId ==
                                                  sub.categoryId) {
                                                subcategoryIndex = y;
                                                category = x;
                                              }
                                            }
                                          }
                                        }

                                        if (category == null) {
                                          for (var x in categoriesList!) {
                                            for (var y in x.subCategories!) {
                                              for (int z = 0;
                                                  z < y.subCategories!.length;
                                                  z++) {
                                                SubCategory sub =
                                                    y.subCategories![z];
                                                print(
                                                    "SeeAllGGGG3 id ${z} ${sub.name} ${sub.categoryId} ${categoryId}");
                                                if (categoryId ==
                                                    sub.categoryId) {
                                                  subcategoryIndex = z;
                                                  category = x;
                                                }
                                              }
                                            }
                                          }
                                        }

                                        print(
                                            "SeeAllGGGG4  ${subcategoryIndex}");
                                        print(
                                            "SeeAllGGGG4  ${category!.subCategories![subcategoryIndex!]}");
                                        print("SeeAllGGGG4  ${category!.id}");
                                        print(
                                            "SeeAllGGGG4   ${category!.subCategories![subcategoryIndex!].categoryId}");
                                        Navigator.pushNamed(
                                            context, Routes.shop_by_category,
                                            arguments: {
                                              "selected_category": category,
                                              "category_list": categoriesList,
                                              "selected_sub_category":
                                                  category!.subCategories![
                                                      subcategoryIndex!]
                                            }).then((value) {
                                          for (int index = 0;
                                              index < list!.length;
                                              index++) {
                                            var newmodel =
                                                list![index].unit![0];
                                            getCartQuantity(newmodel.productId!)
                                                .then((value) {
                                              debugPrint(
                                                  "getCartQuanityUI $value");

                                              if (value > 0) {
                                                debugPrint(
                                                    "getCartQuanity name  ${list![index].unit![0].name}");
                                              }
                                              list![index]
                                                  .unit![0]
                                                  .addQuantity = value;
                                              // bloc.add(ProductUpdateQuantityInitial(list: list));
                                            });

                                            if (newmodel!.cOfferId != 0 &&
                                                newmodel.cOfferId != null) {
                                              debugPrint(
                                                  "***********************");
                                              if (newmodel.subProduct != null) {
                                                log("***********************>>>>>>>>>>>>>>>>" +
                                                    newmodel.subProduct!
                                                        .toJson());
                                                if (newmodel
                                                        .subProduct!
                                                        .subProductDetail!
                                                        .length >
                                                    0) {
                                                  list![index]
                                                          .unit![0]
                                                          .subProduct!
                                                          .subProductDetail =
                                                      MyUtility
                                                          .checkOfferSubProductLoad(
                                                              newmodel,
                                                              dbHelper);
                                                }
                                              }
                                            }

                                            if (list![index].unit!.length > 1) {
                                              for (int i = 0;
                                                  i < list![index].unit!.length;
                                                  i++) {
                                                getCartQuantity(list![index]
                                                        .unit![i]
                                                        .productId!)
                                                    .then((value) {
                                                  debugPrint(
                                                      "getCartQuanityUI $value");
                                                  list![index]
                                                      .unit![i]
                                                      .addQuantity = value;
                                                  // bloc.add(ProductUpdateQuantityInitial(list: list));
                                                });
                                              }
                                            }
                                          }
                                          //callback();
                                        });
                                      })
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
              );
  }

  //Heavy Discount
  static ui_type16(
      bool fromchekcout,
      BuildContext context,
      dynamic state,
      String title,
      String subtitle,
      List<ProductData>? list,
      FeaturedBloc bloc,
      int isMoreUnitIndex,
      CardBloc cardBloc,
      DatabaseHelper dbHelper,
      ScrollController _scrollController,
      bool loadMore,
      var themecolor,
      var textcolor,
      var textsecondary,
      var titlecolor,
      var buttonbackground,
      var buttontextcolor,
      String buttontext,
      Function callback,
      String paginationurl,
      List<Category>? categoriesList,
      String categoryId) {
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

                      // For Manage card list product Quanityt
                      if (state is ProductUpdateQuantityInitialState) {
                        list = state.list!;
                      }

                      if (state is OldListState) {
                        list = state.list;
                      }

                      return Container(
                        height: buttontext == ""
                            ? Sizeconfig.getHeight(context) < 800
                                ? Sizeconfig.getHeight(context) * 0.48
                                : Sizeconfig.getHeight(context) * 0.44
                            : Sizeconfig.getHeight(context) * 0.44,
                        child: Stack(
                          children: [
                            Container(
                              height: Sizeconfig.getHeight(context) * 0.20,
                              color: themecolor,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                            width: Sizeconfig.getWidth(context),
                                            child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 0, vertical: 0),
                                                child:
                                                    CommanTextWidget.subheading(
                                                        title, titlecolor)
                                                /*Text(
                                      title,
                                      style: TextStyle(
                                          fontSize: 16,
                                          letterSpacing: 0.7,
                                          fontFamily: Fontconstants
                                              .fc_family_sf,
                                          fontWeight: FontWeight.w600,
                                          color: titlecolor),
                                    ),*/
                                                )),
                                        2.toSpace,
                                        Container(
                                          width: Sizeconfig.getWidth(context),
                                          child: CommanTextWidget.subtitle(
                                              subtitle, titlecolor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                    height: Sizeconfig.getHeight(context) < 800
                                        ? Sizeconfig.getHeight(context) * 0.35
                                        : Sizeconfig.getHeight(context) * 0.30,
                                    child: ListView.builder(
                                        controller: _scrollController,
                                        shrinkWrap: true,
                                        itemCount: list!.length,
                                        scrollDirection: Axis.horizontal,
                                        padding: EdgeInsets.all(0),
                                        itemBuilder: (context, index) {
                                          var dummyData = list![index].unit![0];

                                          bool isMoreunit = false;

                                          debugPrint(
                                              "GGGGG  $index  =>  ${list![index].unit!.length.toString()}");
                                          if (list![index].unit!.length > 1) {
                                            isMoreunit = true;
                                          }

                                          debugPrint(
                                              "LAstIndex ${index == list!.length - 1}");

                                          if (state
                                              is ProductUpdateQuantityStateBYModel) {
                                            debugPrint(
                                                "LIST Featured Product State  " +
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
                                            if (list![index].unit!.length ==
                                                1) {
                                              debugPrint(
                                                  "Quanititycondition  1 ");

                                              if (dummyData.productId ==
                                                  state.model.productId) {
                                                dummyData.addQuantity =
                                                    state.model.addQuantity;
                                                //G  bloc.add(ProductNullEvent());
                                              }
                                            } else {
                                              for (var obj
                                                  in list![index].unit!) {
                                                if (obj.name ==
                                                        state.model.name ||
                                                    obj.productId ==
                                                        state.model.productId) {
                                                  debugPrint(
                                                      "G>>>>>>>>>>>>>>>>>>>>    " +
                                                          state
                                                              .model.addQuantity
                                                              .toString());

                                                  debugPrint(
                                                      "G>>>>>>Index    " +
                                                          isMoreUnitIndex
                                                              .toString());

                                                  if (dummyData!.cOfferId !=
                                                          0 &&
                                                      dummyData.cOfferId !=
                                                          null) {
                                                    debugPrint(
                                                        "##***********************");
                                                    if (dummyData.subProduct !=
                                                        null) {
                                                      log("##***********************>>>>>>>>>>>>>>>>" +
                                                          dummyData.subProduct!
                                                              .toJson());

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
                                                  debugPrint("##****" +
                                                      state!.model!.name!);

                                                  if (dummyData!.cOfferId !=
                                                          0 &&
                                                      dummyData.cOfferId !=
                                                          null) {
                                                    debugPrint(
                                                        "##***********************");
                                                    if (dummyData.subProduct !=
                                                        null) {
                                                      log("##***********************>>>>>>>>>>>>>>>>" +
                                                          dummyData.subProduct!
                                                              .toJson());
                                                      if (dummyData
                                                              .subProduct!
                                                              .subProductDetail!
                                                              .length >
                                                          0) {
                                                        List<ProductUnit>?
                                                            listsubproduct =
                                                            dummyData
                                                                .subProduct!
                                                                .subProductDetail!;

                                                        for (int x = 0;
                                                            x <
                                                                listsubproduct
                                                                    .length;
                                                            x++) {
                                                          getCartQuantity(
                                                                  listsubproduct[
                                                                          x]
                                                                      .productId!)
                                                              .then((value) {
                                                            debugPrint(
                                                                "${listsubproduct[x].name} Sub Product Quantity quanityt ${value}");
                                                            listsubproduct[x]
                                                                    .addQuantity =
                                                                value;
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

                                          if (state is ProductUnitState) {
                                            if (dummyData.productId ==
                                                state.unit.productId) {
                                              dummyData = state.unit;
                                            }
                                          }
                                          return Stack(
                                            children: [
                                              Padding(
                                                /*padding: (index == list!.length - 1) ?
                                      const EdgeInsets.only(right: 7)
                                          : index == 0 ? const EdgeInsets.only(left: 7,right: 7)
                                          : const EdgeInsets.only(right: 0),*/

                                                padding: (index ==
                                                        list!.length - 1)
                                                    ? const EdgeInsets.only(
                                                        right: 7)
                                                    : index == 0
                                                        ? const EdgeInsets.only(
                                                            left: 7)
                                                        : EdgeInsets.symmetric(
                                                            horizontal: 0,
                                                            vertical: 0),
                                                child: Row(
                                                  children: [
                                                    Card(
                                                      elevation: 1,
                                                      color: Colors.white,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Stack(
                                                            children: [
                                                              GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  for (int i =
                                                                          0;
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
                                                                      isMoreUnitIndex =
                                                                          i;
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
                                                                      'list': list![
                                                                              index]
                                                                          .unit!,
                                                                      'index': isMoreunit
                                                                          ? isMoreUnitIndex
                                                                          : index,
                                                                    },
                                                                  ).then(
                                                                      (value) async {
                                                                    ProductUnit
                                                                        unit =
                                                                        value
                                                                            as ProductUnit;
                                                                    debugPrint(
                                                                        "FeatureCallback ${value.addQuantity}");

                                                                    SystemChrome
                                                                        .setSystemUIOverlayStyle(
                                                                            SystemUiOverlayStyle(
                                                                      statusBarColor:
                                                                          Colors
                                                                              .transparent, // transparent status bar
                                                                      statusBarIconBrightness:
                                                                          Brightness
                                                                              .light, // dark icons on the status bar
                                                                    ));
                                                                    bloc.add(ProductUpdateQuantityEvent(
                                                                        quanitity:
                                                                            unit
                                                                                .addQuantity!,
                                                                        index:
                                                                            index));
                                                                    callback();
                                                                  });
                                                                },
                                                                child:
                                                                    Container(
                                                                  width: Sizeconfig
                                                                          .getWidth(
                                                                              context) *
                                                                      0.45,
                                                                  //padding: EdgeInsets.all(4),
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Expanded(
                                                                        flex: 5,
                                                                        child:
                                                                            Container(
                                                                          child:
                                                                              Stack(
                                                                            children: [
                                                                              Container(
                                                                                // height: Sizeconfig.getWidth(context),
                                                                                // width: Sizeconfig.getWidth(context),
                                                                                child: Align(
                                                                                  alignment: Alignment.bottomCenter,
                                                                                  child: Container(
                                                                                    // height: Sizeconfig.getWidth(context) * .30,
                                                                                    // width: Sizeconfig.getWidth(context) * .30,
                                                                                    child: CommonCachedImageWidget(
                                                                                      imgUrl: dummyData.image!,
                                                                                      // width: Sizeconfig.getWidth(context) * .30,
                                                                                      // height: Sizeconfig.getWidth(context) * .30,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Positioned(
                                                                                  bottom: 5,
                                                                                  right: 3,
                                                                                  child: (dummyData!.cOfferId != 0 && dummyData.cOfferId != null)
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
                                                                                            height: 22,
                                                                                            width: 22,
                                                                                          ))
                                                                                      : Container())
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                          flex:
                                                                              5,
                                                                          child:
                                                                              Container(
                                                                            padding:
                                                                                EdgeInsets.symmetric(horizontal: 8),
                                                                            child:
                                                                                Column(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                                                                CommanTextWidget.regularBold(
                                                                                  dummyData.name!,
                                                                                  textcolor,
                                                                                  maxline: 2,
                                                                                  trt: TextStyle(
                                                                                    fontSize: 14,
                                                                                    height: 1.30,
                                                                                    fontWeight: FontWeight.w600,
                                                                                  ),
                                                                                  textalign: TextAlign.start,
                                                                                ),

                                                                                /*                      InkWell(
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
                                                                                      fontFamily: Fontconstants.fc_family_sf
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
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Container(
                                                                                      child: InkWell(
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
                                                                                                          textsecondary,
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
                                                                                                textsecondary,
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
                                                                                Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Align(
                                                                                      alignment: Alignment.bottomCenter,
                                                                                      child: Container(
                                                                                        padding: EdgeInsets.only(bottom: 5),
                                                                                        child: Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                          children: [
                                                                                            Column(
                                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                                              children: [
                                                                                                // Text(
                                                                                                //   dummyData.specialPrice == "" ? "" : "₹ ${double.parse(dummyData.price!).toStringAsFixed(2)}",
                                                                                                //   style: TextStyle(fontSize: 10, fontFamily: Fontconstants.fc_family_sf, fontWeight: Fontconstants.SF_Pro_Display_Medium, letterSpacing: 0, decoration: TextDecoration.lineThrough, decorationColor: textsecondary, color: textsecondary),
                                                                                                // ),

                                                                                                CommanTextWidget.regularBold(
                                                                                                  dummyData.specialPrice == "" ? "" : "₹ ${double.parse(dummyData.price!).toStringAsFixed(2)}",
                                                                                                  textsecondary,
                                                                                                  maxline: 1,
                                                                                                  trt: TextStyle(
                                                                                                    fontSize: 10,
                                                                                                    height: 1,
                                                                                                    decoration: TextDecoration.lineThrough,
                                                                                                    decorationColor: textsecondary,
                                                                                                    fontWeight: FontWeight.w600,
                                                                                                  ),
                                                                                                  textalign: TextAlign.start,
                                                                                                ),
                                                                                                Visibility(
                                                                                                  visible: dummyData.specialPrice != "",
                                                                                                  child: SizedBox(
                                                                                                    width: 5,
                                                                                                  ),
                                                                                                ),
                                                                                                3.toSpace,
                                                                                                // Text(
                                                                                                //   dummyData.specialPrice == "" ? "₹ ${double.parse(dummyData.sortPrice!).toStringAsFixed(2)}" : "₹ ${double.parse(dummyData.specialPrice!).toStringAsFixed(2)}",
                                                                                                //   style: TextStyle(
                                                                                                //     fontSize: Constants.SizeMidium,
                                                                                                //     fontFamily: Fontconstants.fc_family_sf,
                                                                                                //     fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
                                                                                                //     color: textcolor,
                                                                                                //   ),
                                                                                                //
                                                                                                // ),
                                                                                                CommanTextWidget.regularBold(
                                                                                                  dummyData.specialPrice == "" ? "₹ ${double.parse(dummyData.sortPrice!).toStringAsFixed(2)}" : "₹ ${double.parse(dummyData.specialPrice!).toStringAsFixed(2)}",
                                                                                                  textcolor,
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
                                                                    height: Sizeconfig.getHeight(context) * .05,
                                                                    child: dummyData.addQuantity != 0
                                                                        ? borderAddQuantityButton(ColorName.ColorPrimary, Colors.white, StringContants.lbl_add, dummyData.addQuantity! as int, () {
                                                                            //increase

                                                                            if (dummyData.addQuantity ==
                                                                                int.parse(dummyData.orderQtyLimit!.toString())) {
                                                                              Fluttertoast.showToast(msg: StringContants.msg_quanitiy);
                                                                            } else {
                                                                              dummyData.addQuantity = dummyData.addQuantity + 1;
                                                                              bloc.add(ProductUpdateQuantityEvent(quanitity: dummyData.addQuantity!, index: index));
                                                                              bloc.add(ProductChangeEvent(model: dummyData));
                                                                              updateCard(dummyData, dbHelper, cardBloc);
                                                                              debugPrint("Scroll Event1111 ");
                                                                            }
                                                                          }, () async {
                                                                            if (dummyData.addQuantity ==
                                                                                1) {
                                                                              debugPrint("SHOPBY 1");
                                                                              dummyData.addQuantity = 0;

                                                                              bloc.add(ProductUpdateQuantityEventBYModel(model: dummyData));

                                                                              await dbHelper.deleteCard(int.parse(dummyData.productId!)).then((value) {
                                                                                debugPrint("Delete Product $value ");

                                                                                // cardBloc.add(CardDeleteEvent(
                                                                                //     model: model,
                                                                                //     listProduct:  list![0].unit!));

                                                                                dbHelper.loadAddCardProducts(cardBloc);
                                                                              });
                                                                            } else if (dummyData.addQuantity !=
                                                                                0) {
                                                                              debugPrint("SHOPBY 2");
                                                                              dummyData.addQuantity = dummyData.addQuantity - 1;

                                                                              updateCard(dummyData, dbHelper, cardBloc);
                                                                              bloc.add(ProductUpdateQuantityEventBYModel(model: dummyData));

                                                                              bloc.add(ProductChangeEvent(model: dummyData));
                                                                            }
                                                                          })
                                                                        : borderbuttonPrimary(
                                                                            ColorName.ColorPrimary,
                                                                            Colors.white,
                                                                            StringContants.lbl_add,
                                                                            () {
                                                                              dummyData.addQuantity = dummyData.addQuantity + 1;
                                                                              checkItemId(dummyData.productId!, dbHelper).then((value) {
                                                                                debugPrint("CheckItemId $value");

                                                                                if (value == false) {
                                                                                  addCard(dummyData, dbHelper, cardBloc);
                                                                                } else {
                                                                                  updateCard(dummyData, dbHelper, cardBloc);
                                                                                }
                                                                              });

                                                                              bloc.add(ProductUpdateQuantityEvent(quanitity: dummyData.addQuantity!, index: index));
                                                                              bloc.add(ProductChangeEvent(model: dummyData));
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
                                                        : index !=
                                                                (list!.length -
                                                                    1)
                                                            ? Container()
                                                            : Container(
                                                                height: 30,
                                                                width: 30,
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            10),
                                                                child: list!.length <
                                                                        3
                                                                    ? Container()
                                                                    : CircularProgressIndicator(
                                                                        color: ColorName
                                                                            .ColorPrimary,
                                                                      ))
                                                  ],
                                                ),
                                              ),
                                              Positioned(
                                                top: 3,
                                                left: 3,
                                                child: Padding(
                                                    padding: index == 0
                                                        ? const EdgeInsets.only(
                                                            left: 7)
                                                        : EdgeInsets.symmetric(
                                                            horizontal: 0,
                                                            vertical: 0),
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
                                                                child: Stack(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  children: [
                                                                    Positioned(
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.only(topLeft: Radius.circular(10.0)),
                                                                        child: Image
                                                                            .asset(
                                                                          Imageconstants
                                                                              .img_tag,
                                                                          height:
                                                                              32,
                                                                          width:
                                                                              31,
                                                                          fit: BoxFit
                                                                              .fill,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      child:
                                                                          Container(
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
                                                                            color:
                                                                                ColorName.black,
                                                                            fontSize:
                                                                                10,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )),
                                              ),
                                            ],
                                          );
                                        })),
                                buttontext == ""
                                    ? Container()
                                    : Appwidgets.MyUiButton(
                                        context,
                                        buttontext,
                                        buttonbackground,
                                        buttontextcolor,
                                        Sizeconfig.getWidth(context), () async {
                                        /* SharedPref.setStringPreference(
                                            Constants.sp_homepageproducts,
                                            jsonEncode(list));
                                        Navigator.pushNamed(
                                            context, Routes.featuredProduct,
                                            arguments: {
                                              "key": title,
                                              "list": list,
                                              "paninatinUrl": paginationurl
                                            }).then((value) {
                                          list = value as List<ProductData>;

                                          print("vlaueGG ${list!.length}");

                                          bloc.add(OldListEvent(list: list));
                                        });*/

                                        Category? category;

                                        int subcategoryIndex = 0;
                                        for (var x in categoriesList!) {
                                          print(
                                              "SeeAllGGGG id ${x.name} ${x.id} ${categoryId}");

                                          if (categoryId == x.id) {
                                            category = x;
                                          }
                                        }

                                        if (category == null) {
                                          for (var x in categoriesList!) {
                                            for (int y = 0;
                                                y < x.subCategories!.length;
                                                y++) {
                                              SubCategory sub =
                                                  x.subCategories![y];
                                              print(
                                                  "SeeAllGGGG2 id ${sub.name} ${sub.categoryId} ${categoryId}");
                                              if (categoryId ==
                                                  sub.categoryId) {
                                                subcategoryIndex = y;
                                                category = x;
                                              }
                                            }
                                          }
                                        }

                                        if (category == null) {
                                          for (var x in categoriesList!) {
                                            for (var y in x.subCategories!) {
                                              for (int z = 0;
                                                  z < y.subCategories!.length;
                                                  z++) {
                                                SubCategory sub =
                                                    y.subCategories![z];
                                                print(
                                                    "SeeAllGGGG3 id ${z} ${sub.name} ${sub.categoryId} ${categoryId}");
                                                if (categoryId ==
                                                    sub.categoryId) {
                                                  subcategoryIndex = z;
                                                  category = x;
                                                }
                                              }
                                            }
                                          }
                                        }

                                        print(
                                            "SeeAllGGGG4  ${subcategoryIndex}");
                                        print(
                                            "SeeAllGGGG4  ${category!.subCategories![subcategoryIndex!]}");
                                        print("SeeAllGGGG4  ${category!.id}");
                                        print(
                                            "SeeAllGGGG4   ${category!.subCategories![subcategoryIndex!].categoryId}");
                                        Navigator.pushNamed(
                                            context, Routes.shop_by_category,
                                            arguments: {
                                              "selected_category": category,
                                              "category_list": categoriesList,
                                              "selected_sub_category":
                                                  category!.subCategories![
                                                      subcategoryIndex!]
                                            }).then((value) {
                                          for (int index = 0;
                                              index < list!.length;
                                              index++) {
                                            var newmodel =
                                                list![index].unit![0];
                                            getCartQuantity(newmodel.productId!)
                                                .then((value) {
                                              debugPrint(
                                                  "getCartQuanityUI $value");

                                              if (value > 0) {
                                                debugPrint(
                                                    "getCartQuanity name  ${list![index].unit![0].name}");
                                              }
                                              list![index]
                                                  .unit![0]
                                                  .addQuantity = value;
                                              // bloc.add(ProductUpdateQuantityInitial(list: list));
                                            });

                                            if (newmodel!.cOfferId != 0 &&
                                                newmodel.cOfferId != null) {
                                              debugPrint(
                                                  "***********************");
                                              if (newmodel.subProduct != null) {
                                                log("***********************>>>>>>>>>>>>>>>>" +
                                                    newmodel.subProduct!
                                                        .toJson());
                                                if (newmodel
                                                        .subProduct!
                                                        .subProductDetail!
                                                        .length >
                                                    0) {
                                                  list![index]
                                                          .unit![0]
                                                          .subProduct!
                                                          .subProductDetail =
                                                      MyUtility
                                                          .checkOfferSubProductLoad(
                                                              newmodel,
                                                              dbHelper);
                                                }
                                              }
                                            }

                                            if (list![index].unit!.length > 1) {
                                              for (int i = 0;
                                                  i < list![index].unit!.length;
                                                  i++) {
                                                getCartQuantity(list![index]
                                                        .unit![i]
                                                        .productId!)
                                                    .then((value) {
                                                  debugPrint(
                                                      "getCartQuanityUI $value");
                                                  list![index]
                                                      .unit![i]
                                                      .addQuantity = value;
                                                  // bloc.add(ProductUpdateQuantityInitial(list: list));
                                                });
                                              }
                                            }
                                          }
                                          //callback();
                                        });
                                      })
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
              );
  }

  //New Arrivals
  static ui_type17(
      bool fromchekcout,
      BuildContext context,
      dynamic state,
      String title,
      String subtitle,
      List<ProductData>? list,
      FeaturedBloc bloc,
      int isMoreUnitIndex,
      CardBloc cardBloc,
      DatabaseHelper dbHelper,
      ScrollController _scrollController,
      bool loadMore,
      var themecolor,
      var themecolor2,
      var titlecolor,
      var textcolor,
      String buttontext,
      var buttonbackground,
      var buttontextcolor,
      String? image,
      Function callback,
      String paginationurl,
      List<Category>? categoriesList,
      String categoryId) {
    debugPrint("similarProductsUI  ${list!.length} ${loadMore}");
    var headingview;

    if (image!.isEmpty || image == "" || image == null || image == "null") {
      headingview = Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: Sizeconfig.getWidth(context),
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  child: CommanTextWidget.subheading(title, titlecolor)
                  //Appwidgets.TextLagre(title, titlecolor),
                  ),
            ),
            Container(
              width: Sizeconfig.getWidth(context),
              child: CommanTextWidget.subtitle(subtitle, titlecolor),
            ),
          ],
        ),
      );
    } else {
      headingview = Container(
          padding: EdgeInsets.symmetric(vertical: 3),
          height: Sizeconfig.getHeight(context) * 0.12,
          decoration: BoxDecoration(
            color: themecolor ?? Colors.transparent,
            image: DecorationImage(
              image: FileImage(File(image)),
              fit: BoxFit.contain,
            ),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: Sizeconfig.getWidth(context),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    child: Appwidgets.TextLagre("", titlecolor),
                  ),
                ),
                Container(
                  width: Sizeconfig.getWidth(context),
                  child: Appwidgets.TextRegular("", titlecolor),
                ),
              ],
            ),
          ));
    }

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

                      // For Manage card list product Quanityt
                      if (state is ProductUpdateQuantityInitialState) {
                        list = state.list!;
                      }

                      if (state is OldListState) {
                        list = state.list;
                      }

                      return Container(
                        height: buttontext == ""
                            ? Sizeconfig.getHeight(context) * 0.50
                            : Sizeconfig.getHeight(context) * 0.50,
                        color: themecolor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            headingview,
                            Container(
                                height: Sizeconfig.getHeight(context) < 800
                                    ? Sizeconfig.getHeight(context) * 0.38
                                    : Sizeconfig.getHeight(context) * 0.32,
                                child: ListView.builder(
                                    controller: _scrollController,
                                    shrinkWrap: true,
                                    itemCount: list!.length,
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
                                        debugPrint(
                                            "LIST Featured Product State  " +
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
                                        if (list![index].unit!.length == 1) {
                                          debugPrint("Quanititycondition  1 ");

                                          if (dummyData.productId ==
                                              state.model.productId) {
                                            dummyData.addQuantity =
                                                state.model.addQuantity;
                                            //G  bloc.add(ProductNullEvent());
                                          }
                                        } else {
                                          for (var obj in list![index].unit!) {
                                            if (obj.name == state.model.name ||
                                                obj.productId ==
                                                    state.model.productId) {
                                              debugPrint(
                                                  "G>>>>>>>>>>>>>>>>>>>>    " +
                                                      state.model.addQuantity
                                                          .toString());

                                              debugPrint("G>>>>>>Index    " +
                                                  isMoreUnitIndex.toString());

                                              if (dummyData!.cOfferId != 0 &&
                                                  dummyData.cOfferId != null) {
                                                debugPrint(
                                                    "##***********************");
                                                if (dummyData.subProduct !=
                                                    null) {
                                                  log("##***********************>>>>>>>>>>>>>>>>" +
                                                      dummyData.subProduct!
                                                          .toJson());

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
                                              debugPrint("##****" +
                                                  state!.model!.name!);

                                              if (dummyData!.cOfferId != 0 &&
                                                  dummyData.cOfferId != null) {
                                                debugPrint(
                                                    "##***********************");
                                                if (dummyData.subProduct !=
                                                    null) {
                                                  log("##***********************>>>>>>>>>>>>>>>>" +
                                                      dummyData.subProduct!
                                                          .toJson());
                                                  if (dummyData
                                                          .subProduct!
                                                          .subProductDetail!
                                                          .length >
                                                      0) {
                                                    List<ProductUnit>?
                                                        listsubproduct =
                                                        dummyData.subProduct!
                                                            .subProductDetail!;

                                                    for (int x = 0;
                                                        x <
                                                            listsubproduct
                                                                .length;
                                                        x++) {
                                                      getCartQuantity(
                                                              listsubproduct[x]
                                                                  .productId!)
                                                          .then((value) {
                                                        debugPrint(
                                                            "${listsubproduct[x].name} Sub Product Quantity quanityt ${value}");
                                                        listsubproduct[x]
                                                                .addQuantity =
                                                            value;
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

                                      if (state is ProductUnitState) {
                                        if (dummyData.productId ==
                                            state.unit.productId) {
                                          dummyData = state.unit;
                                        }
                                      }
                                      return Stack(
                                        children: [
                                          Padding(
                                            padding: index == 0
                                                ? const EdgeInsets.only(left: 7)
                                                : EdgeInsets.symmetric(
                                                    horizontal: 0, vertical: 0),
                                            child: Row(
                                              children: [
                                                Card(
                                                  elevation: 1,
                                                  color: themecolor2,
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        color: Colors.white),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          Container(
                                                            width: Sizeconfig
                                                                    .getWidth(
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
                                                                  child:
                                                                      InkWell(
                                                                    onTap:
                                                                        () async {
                                                                      for (int i =
                                                                              0;
                                                                          i < list![index].unit!.length!;
                                                                          i++) {
                                                                        debugPrint(
                                                                            "Model  ${dummyData.productId} ${dummyData.addQuantity} ");
                                                                        if (dummyData.productId ==
                                                                            list![index].unit![i].productId!) {
                                                                          list![index].unit![i] =
                                                                              dummyData;
                                                                          isMoreUnitIndex =
                                                                              i;
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
                                                                          'list':
                                                                              list![index].unit!,
                                                                          'index': isMoreunit
                                                                              ? isMoreUnitIndex
                                                                              : index,
                                                                        },
                                                                      ).then(
                                                                          (value) async {
                                                                        ProductUnit
                                                                            unit =
                                                                            value
                                                                                as ProductUnit;
                                                                        debugPrint(
                                                                            "FeatureCallback ${value.addQuantity}");

                                                                        SystemChrome.setSystemUIOverlayStyle(
                                                                            SystemUiOverlayStyle(
                                                                          statusBarColor:
                                                                              Colors.transparent, // transparent status bar
                                                                          statusBarIconBrightness:
                                                                              Brightness.light, // dark icons on the status bar
                                                                        ));
                                                                        bloc.add(ProductUpdateQuantityEvent(
                                                                            quanitity:
                                                                                unit.addQuantity!,
                                                                            index: index));

                                                                        callback();
                                                                      });
                                                                    },
                                                                    child:
                                                                        Stack(
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              Sizeconfig.getWidth(context),
                                                                          width:
                                                                              Sizeconfig.getWidth(context),
                                                                          /*    decoration:
                                                                BoxDecoration(
                                                                  color:
                                                                  Colors.white,
                                                                  borderRadius:
                                                                  BorderRadius.circular(10),
                                                                  border:
                                                                  Border.all(width: 1, color: ColorName.newgray),
                                                                ),*/

                                                                          decoration: BoxDecoration(
                                                                              color: Colors.white,
                                                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))),
                                                                          child:
                                                                              Align(
                                                                            alignment:
                                                                                Alignment.bottomCenter,
                                                                            child:
                                                                                Container(
                                                                              height: Sizeconfig.getWidth(context) * .27,
                                                                              padding: EdgeInsets.all(4),
                                                                              width: Sizeconfig.getWidth(context) * .27,
                                                                              child: CommonCachedImageWidget(
                                                                                imgUrl: dummyData.image!,
                                                                                width: Sizeconfig.getWidth(context) * .24,
                                                                                height: Sizeconfig.getWidth(context) * .25,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Positioned(
                                                                            bottom:
                                                                                5,
                                                                            right:
                                                                                5,
                                                                            child: (dummyData!.cOfferId != 0 && dummyData.cOfferId != null)
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
                                                                ),
                                                                Expanded(
                                                                    flex: 5,
                                                                    child:
                                                                        Container(
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              8),
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          1.toSpace,
                                                                          Container(
                                                                            height: Sizeconfig.getHeight(context) < 800
                                                                                ? Sizeconfig.getHeight(context) * 0.07
                                                                                : Sizeconfig.getHeight(context) * 0.06,
                                                                            child:
                                                                                Column(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                2.toSpace,
                                                                                Row(
                                                                                  children: [
                                                                                    Expanded(
                                                                                      child:
                                                                                          // Text(
                                                                                          //   dummyData.name!,
                                                                                          //   maxLines: 2,
                                                                                          //   style: TextStyle(
                                                                                          //     fontSize: 12,
                                                                                          //     fontFamily: Fontconstants.fc_family_sf,
                                                                                          //     fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
                                                                                          //     color: titlecolor,
                                                                                          //   ),
                                                                                          // ),

                                                                                          CommanTextWidget.regularBold(
                                                                                        dummyData.name!,
                                                                                        titlecolor,
                                                                                        maxline: 2,
                                                                                        trt: TextStyle(
                                                                                          fontSize: 14,
                                                                                          height: 1.2,
                                                                                          fontWeight: FontWeight.w600,
                                                                                        ),
                                                                                        textalign: TextAlign.start,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Container(),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          InkWell(
                                                                            onTap:
                                                                                () {
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
                                                                            child:
                                                                                Container(
                                                                              child: Container(
                                                                                // margin: isMoreunit ? EdgeInsets.only(top: 5) : null,

                                                                                width: Sizeconfig.getWidth(context) * .20,
                                                                                child: Align(
                                                                                  alignment: Alignment.center,
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    children: [
                                                                                      /*  Text(
                                                                              dummyData.productWeight.toString() + " ${dummyData.productWeightUnit}",
                                                                              style: TextStyle(
                                                                                fontSize: 11,
                                                                                fontFamily: Fontconstants.fc_family_sf,
                                                                                fontWeight: Fontconstants.SF_Pro_Display_Bold,
                                                                                color: textcolor,
                                                                              ),
                                                                            ),*/
                                                                                      CommanTextWidget.regularBold(
                                                                                        dummyData.productWeight.toString() + " ${dummyData.productWeightUnit}",
                                                                                        textcolor,
                                                                                        maxline: 2,
                                                                                        trt: TextStyle(
                                                                                          fontSize: 14,
                                                                                          fontWeight: FontWeight.w600,
                                                                                        ),
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
                                                                                                  color: themecolor2,
                                                                                                ),
                                                                                              )),
                                                                                        ],
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Align(
                                                                            alignment:
                                                                                Alignment.bottomCenter,
                                                                            child:
                                                                                Container(
                                                                              padding: EdgeInsets.only(bottom: 3),
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      /*
                                                                           Text(
                                                                              dummyData.specialPrice == "" ? "" : "₹ ${double.parse(dummyData.price!).toStringAsFixed(2)}",
                                                                              style: TextStyle(fontSize: 10, fontFamily: Fontconstants.fc_family_sf, fontWeight: Fontconstants.SF_Pro_Display_Medium, letterSpacing: 0, decoration: TextDecoration.lineThrough, decorationColor: ColorName.textlight, color: ColorName.textlight),
                                                                            ),*/
                                                                                      CommanTextWidget.regularBold(
                                                                                        dummyData.specialPrice == "" ? "" : "₹ ${double.parse(dummyData.price!).toStringAsFixed(2)}",
                                                                                        ColorName.bottom_white,
                                                                                        maxline: 2,
                                                                                        trt: TextStyle(
                                                                                          fontSize: 10,
                                                                                          decoration: TextDecoration.lineThrough,
                                                                                          decorationColor: ColorName.bottom_white,
                                                                                          fontWeight: FontWeight.w600,
                                                                                        ),
                                                                                        textalign: TextAlign.start,
                                                                                      ),
                                                                                      Visibility(
                                                                                        visible: dummyData.specialPrice != "",
                                                                                        child: SizedBox(
                                                                                          width: 5,
                                                                                        ),
                                                                                      ),
                                                                                      Expanded(
                                                                                        flex: 0,
                                                                                        child:

                                                                                            //     Text(
                                                                                            //   dummyData.specialPrice == "" ? "₹ ${double.parse(dummyData.sortPrice!).toStringAsFixed(2)}" : "₹ ${double.parse(dummyData.specialPrice!).toStringAsFixed(2)}",
                                                                                            //   style: TextStyle(
                                                                                            //     fontSize: Constants.SizeMidium,
                                                                                            //     fontFamily: Fontconstants.fc_family_sf,
                                                                                            //     fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
                                                                                            //     color: Colors.white,
                                                                                            //   ),
                                                                                            // )

                                                                                            CommanTextWidget.regularBold(
                                                                                          dummyData.specialPrice == "" ? "₹ ${double.parse(dummyData.sortPrice!).toStringAsFixed(2)}" : "₹ ${double.parse(dummyData.specialPrice!).toStringAsFixed(2)}",
                                                                                          Colors.white,
                                                                                          maxline: 2,
                                                                                          trt: TextStyle(
                                                                                            fontSize: Constants.SizeMidium,
                                                                                            fontWeight: FontWeight.w600,
                                                                                          ),
                                                                                          textalign: TextAlign.start,
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    )),
                                                              ],
                                                            ),
                                                          ),
                                                          Positioned(
                                                            right: 0,
                                                            bottom: 0,
                                                            child: Container(
                                                                height: Sizeconfig
                                                                        .getWidth(
                                                                            context) *
                                                                    0.08,
                                                                child: dummyData.addQuantity !=
                                                                        0
                                                                    ? AddQuantityButton(
                                                                        ColorName
                                                                            .ColorPrimary,
                                                                        Colors
                                                                            .white,
                                                                        StringContants
                                                                            .lbl_add,
                                                                        dummyData.addQuantity!
                                                                            as int,
                                                                        () {
                                                                        //increase

                                                                        if (dummyData.addQuantity ==
                                                                            int.parse(dummyData.orderQtyLimit!.toString())) {
                                                                          Fluttertoast.showToast(
                                                                              msg: StringContants.msg_quanitiy);
                                                                        } else {
                                                                          dummyData.addQuantity =
                                                                              dummyData.addQuantity + 1;
                                                                          bloc.add(ProductUpdateQuantityEvent(
                                                                              quanitity: dummyData.addQuantity!,
                                                                              index: index));
                                                                          bloc.add(
                                                                              ProductChangeEvent(model: dummyData));
                                                                          updateCard(
                                                                              dummyData,
                                                                              dbHelper,
                                                                              cardBloc);
                                                                          debugPrint(
                                                                              "Scroll Event1111 ");
                                                                        }
                                                                      }, () async {
                                                                        if (dummyData.addQuantity ==
                                                                            1) {
                                                                          debugPrint(
                                                                              "SHOPBY 1");
                                                                          dummyData.addQuantity =
                                                                              0;

                                                                          bloc.add(
                                                                              ProductUpdateQuantityEventBYModel(model: dummyData));

                                                                          await dbHelper
                                                                              .deleteCard(int.parse(dummyData.productId!))
                                                                              .then((value) {
                                                                            debugPrint("Delete Product $value ");

                                                                            // cardBloc.add(CardDeleteEvent(
                                                                            //     model: model,
                                                                            //     listProduct:  list![0].unit!));

                                                                            dbHelper.loadAddCardProducts(cardBloc);
                                                                          });
                                                                        } else if (dummyData.addQuantity !=
                                                                            0) {
                                                                          debugPrint(
                                                                              "SHOPBY 2");
                                                                          dummyData.addQuantity =
                                                                              dummyData.addQuantity - 1;

                                                                          updateCard(
                                                                              dummyData,
                                                                              dbHelper,
                                                                              cardBloc);
                                                                          bloc.add(
                                                                              ProductUpdateQuantityEventBYModel(model: dummyData));

                                                                          bloc.add(
                                                                              ProductChangeEvent(model: dummyData));
                                                                        }
                                                                      })
                                                                    : buttonPrimary(
                                                                        ColorName
                                                                            .ColorPrimary,
                                                                        Colors
                                                                            .white,
                                                                        StringContants
                                                                            .lbl_add,
                                                                        () {
                                                                          dummyData.addQuantity =
                                                                              dummyData.addQuantity + 1;
                                                                          checkItemId(dummyData.productId!, dbHelper)
                                                                              .then((value) {
                                                                            debugPrint("CheckItemId $value");

                                                                            if (value ==
                                                                                false) {
                                                                              addCard(dummyData, dbHelper, cardBloc);
                                                                            } else {
                                                                              updateCard(dummyData, dbHelper, cardBloc);
                                                                            }
                                                                          });

                                                                          bloc.add(ProductUpdateQuantityEvent(
                                                                              quanitity: dummyData.addQuantity!,
                                                                              index: index));
                                                                          bloc.add(
                                                                              ProductChangeEvent(model: dummyData));
                                                                        },
                                                                      )),
                                                          ),
                                                          Positioned(
                                                              top: 0,
                                                              left: 0,
                                                              child: (dummyData
                                                                              .discountText ??
                                                                          "") ==
                                                                      ""
                                                                  ? Container()
                                                                  : Visibility(
                                                                      visible: (dummyData!.discountText !=
                                                                              "" ||
                                                                          dummyData!.discountText !=
                                                                              null),
                                                                      child:
                                                                          Positioned(
                                                                        // left: 7,
                                                                        left: 0,
                                                                        top: 0,
                                                                        child:
                                                                            Stack(
                                                                          alignment:
                                                                              Alignment.center,
                                                                          children: [
                                                                            ClipRRect(
                                                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(5.0)),
                                                                              child: Image.asset(
                                                                                Imageconstants.img_tag,
                                                                                height: 25,
                                                                                width: 31,
                                                                                fit: BoxFit.fill,
                                                                              ),
                                                                            ),
                                                                            Align(
                                                                              alignment: Alignment.center,
                                                                              child: Text(
                                                                                dummyData.discountText ?? "",
                                                                                overflow: TextOverflow.ellipsis,
                                                                                maxLines: 2,
                                                                                style: const TextStyle(
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
                                                    ],
                                                  ),
                                                ),
                                                loadMore == false
                                                    ? Container()
                                                    : index !=
                                                            (list!.length - 1)
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
                                        ],
                                      );
                                    })),
                            buttontext == ""
                                ? Container()
                                : Appwidgets.MyUiButton(
                                    context,
                                    buttontext,
                                    buttonbackground,
                                    buttontextcolor,
                                    Sizeconfig.getWidth(context), () async {
                                    /*  SharedPref.setStringPreference(
                                        Constants.sp_homepageproducts,
                                        jsonEncode(list));
                                    Navigator.pushNamed(
                                        context, Routes.featuredProduct,
                                        arguments: {
                                          "key": title,
                                          "list": list,
                                          "paninatinUrl": paginationurl
                                        }).then((value) {
                                      list = value as List<ProductData>;

                                      print("vlaueGG ${list!.length}");

                                      bloc.add(OldListEvent(list: list));
                                    });*/

                                    Category? category;

                                    int subcategoryIndex = 0;
                                    for (var x in categoriesList!) {
                                      print(
                                          "SeeAllGGGG id ${x.name} ${x.id} ${categoryId}");

                                      if (categoryId == x.id) {
                                        category = x;
                                      }
                                    }

                                    if (category == null) {
                                      for (var x in categoriesList!) {
                                        for (int y = 0;
                                            y < x.subCategories!.length;
                                            y++) {
                                          SubCategory sub = x.subCategories![y];
                                          print(
                                              "SeeAllGGGG2 id ${sub.name} ${sub.categoryId} ${categoryId}");
                                          if (categoryId == sub.categoryId) {
                                            subcategoryIndex = y;
                                            category = x;
                                          }
                                        }
                                      }
                                    }

                                    if (category == null) {
                                      for (var x in categoriesList!) {
                                        for (var y in x.subCategories!) {
                                          for (int z = 0;
                                              z < y.subCategories!.length;
                                              z++) {
                                            SubCategory sub =
                                                y.subCategories![z];
                                            print(
                                                "SeeAllGGGG3 id ${z} ${sub.name} ${sub.categoryId} ${categoryId}");
                                            if (categoryId == sub.categoryId) {
                                              subcategoryIndex = z;
                                              category = x;
                                            }
                                          }
                                        }
                                      }
                                    }

                                    print("SeeAllGGGG4  ${subcategoryIndex}");
                                    print(
                                        "SeeAllGGGG4  ${category!.subCategories![subcategoryIndex!]}");
                                    print("SeeAllGGGG4  ${category!.id}");
                                    print(
                                        "SeeAllGGGG4   ${category!.subCategories![subcategoryIndex!].categoryId}");
                                    Navigator.pushNamed(
                                        context, Routes.shop_by_category,
                                        arguments: {
                                          "selected_category": category,
                                          "category_list": categoriesList,
                                          "selected_sub_category": category!
                                              .subCategories![subcategoryIndex!]
                                        }).then((value) {
                                      for (int index = 0;
                                          index < list!.length;
                                          index++) {
                                        var newmodel = list![index].unit![0];
                                        getCartQuantity(newmodel.productId!)
                                            .then((value) {
                                          debugPrint("getCartQuanityUI $value");

                                          if (value > 0) {
                                            debugPrint(
                                                "getCartQuanity name  ${list![index].unit![0].name}");
                                          }
                                          list![index].unit![0].addQuantity =
                                              value;
                                          // bloc.add(ProductUpdateQuantityInitial(list: list));
                                        });

                                        if (newmodel!.cOfferId != 0 &&
                                            newmodel.cOfferId != null) {
                                          debugPrint("***********************");
                                          if (newmodel.subProduct != null) {
                                            log("***********************>>>>>>>>>>>>>>>>" +
                                                newmodel.subProduct!.toJson());
                                            if (newmodel.subProduct!
                                                    .subProductDetail!.length >
                                                0) {
                                              list![index]
                                                      .unit![0]
                                                      .subProduct!
                                                      .subProductDetail =
                                                  MyUtility
                                                      .checkOfferSubProductLoad(
                                                          newmodel, dbHelper);
                                            }
                                          }
                                        }

                                        if (list![index].unit!.length > 1) {
                                          for (int i = 0;
                                              i < list![index].unit!.length;
                                              i++) {
                                            getCartQuantity(list![index]
                                                    .unit![i]
                                                    .productId!)
                                                .then((value) {
                                              debugPrint(
                                                  "getCartQuanityUI $value");
                                              list![index]
                                                  .unit![i]
                                                  .addQuantity = value;
                                              // bloc.add(ProductUpdateQuantityInitial(list: list));
                                            });
                                          }
                                        }
                                      }
                                      //callback();
                                    });
                                  })
                          ],
                        ),
                      );
                    }),
              );
  }

  //Grocery Stample Subcategory
  static ui_type4(
      bool fromchekcout,
      BuildContext context,
      dynamic state,
      String title,
      String subtitle,
      List<SubCategory>? list,
      FeaturedBloc bloc,
      int isMoreUnitIndex,
      CardBloc cardBloc,
      DatabaseHelper dbHelper,
      ScrollController _scrollController,
      bool loadMore,
      var themecolor,
      var themecolor2,
      var titlecolor,
      var textcolor,
      List<Category> listcategory,
      Function callback) {
    debugPrint("ui_type5similarProductsUI  ${list!.length} ${loadMore}");
    List<SubCategory> listsub = [];
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

                      // if (state is ProductForShopByState) {
                      //   list = state.list!;
                      //   debugPrint(
                      //       "LoadedFeaturedState  ${state.list!.length.toString()}");
                      //
                      //   for (int index = 0; index < list!.length; index++) {
                      //     var newmodel = list![index].unit![0];
                      //     getCartQuantity(newmodel.productId!).then((value) {
                      //       debugPrint("getCartQuanity $value");
                      //
                      //       if (value > 0) {
                      //         debugPrint(
                      //             "getCartQuanity name  ${list![index].unit![0].name}");
                      //       }
                      //       list![index].unit![0].addQuantity = value;
                      //       bloc.add(ProductUpdateQuantityInitial(list: list));
                      //     });
                      //
                      //     if (newmodel!.cOfferId != 0 &&
                      //         newmodel.cOfferId != null) {
                      //       debugPrint("***********************");
                      //       if (newmodel.subProduct != null) {
                      //         log("***********************>>>>>>>>>>>>>>>>" +
                      //             newmodel.subProduct!.toJson());
                      //         if (newmodel
                      //                 .subProduct!.subProductDetail!.length >
                      //             0) {
                      //           list![index]
                      //                   .unit![0]
                      //                   .subProduct!
                      //                   .subProductDetail =
                      //               MyUtility.checkOfferSubProductLoad(
                      //                   newmodel, dbHelper);
                      //         }
                      //       }
                      //     }
                      //
                      //     if (list![index].unit!.length > 1) {
                      //       for (int i = 0;
                      //           i < list![index].unit!.length;
                      //           i++) {
                      //         getCartQuantity(list![index].unit![i].productId!)
                      //             .then((value) {
                      //           debugPrint("getCartQuanity $value");
                      //           list![index].unit![i].addQuantity = value;
                      //           bloc.add(
                      //               ProductUpdateQuantityInitial(list: list));
                      //         });
                      //       }
                      //     }
                      //   }
                      // }
                      //
                      // // For Manage card list product Quanityt
                      // if (state is ProductUpdateQuantityInitialState) {
                      //   list = state.list!;
                      // }

                      int line = (list!.length / 4).round();

                      debugPrint("Uitype7G Size " + line.toString());

                      if (line == 0) {
                        line = 1;
                      }

                      return Container(
                        color: themecolor,
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              child: Container(
                                padding: const EdgeInsets.only(left: 5),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                        width: Sizeconfig.getWidth(context),
                                        child: CommanTextWidget.subheading(
                                            title, titlecolor)),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              //height: line * Sizeconfig.getHeight(context) * 0.14,
                              padding: const EdgeInsets.only(left: 1),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 8.0,
                                  right: 8.0,
                                  left: 8.0,
                                ),
                                child: GridView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4, // Number of columns
                                    crossAxisSpacing:
                                        0.0, // Spacing between columns
                                    mainAxisSpacing: 0.0,
                                    childAspectRatio:
                                        0.73, // Spacing between rows
                                  ),
                                  itemCount: list.length, // Number of items
                                  itemBuilder: (context, index) {
                                    listsub.add(list[index]);
                                    return GestureDetector(
                                      onTap: () {
                                        Category category = Category();

                                        category.id = list[index].categoryId;
                                        category.name = title;
                                        category.parentId =
                                            list[index].parentId;
                                        category.subCategories = listsub;

                                        //listcategory.add(category);
                                        debugPrint("${listcategory}");

                                        Navigator.pushNamed(
                                            context, Routes.shop_by_category,
                                            arguments: {
                                              "selected_category": category,
                                              "category_list": listcategory,
                                              "selected_sub_category":
                                                  list[index]
                                            }).then((value) {
                                          callback();
                                        });
                                      },
                                      child: Container(
                                        child: Column(
                                          children: [
                                            Container(
                                              height:
                                                  Sizeconfig.getWidth(context) *
                                                      0.21,
                                              width:
                                                  Sizeconfig.getWidth(context) *
                                                      0.22,
                                              decoration: BoxDecoration(
                                                color: themecolor2,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Center(
                                                child: list[index].name ==
                                                            "All" &&
                                                        list[index]
                                                                .categoryId ==
                                                            "18"
                                                    ? Image.asset(
                                                        Imageconstants
                                                            .img_all18,
                                                        // width: Sizeconfig.getWidth(context) * .19,
                                                        // height: Sizeconfig.getWidth(context) * .21,
                                                        scale: 1.5,
                                                      )
                                                    : list[index].name == "All"
                                                        ? Image.asset(
                                                            Imageconstants
                                                                .all_products,
                                                            width: Sizeconfig
                                                                    .getWidth(
                                                                        context) *
                                                                .15,
                                                            height: Sizeconfig
                                                                    .getWidth(
                                                                        context) *
                                                                .15,
                                                          )
                                                        : CommonCachedImageWidget(
                                                            imgUrl: list[index]
                                                                .mobileSubCatImage!,
                                                            width: Sizeconfig
                                                                    .getWidth(
                                                                        context) *
                                                                .13,
                                                            height: Sizeconfig
                                                                    .getWidth(
                                                                        context) *
                                                                .13,
                                                          ),
                                              ),
                                            ),
                                            // Text(list[index].name!,
                                            //     textAlign: TextAlign.center,
                                            //     maxLines: 1,
                                            //     style: TextStyle(
                                            //         fontSize:
                                            //             Constants.Size_11,
                                            //         letterSpacing: 1.015,
                                            //         fontFamily:
                                            //             Fontconstants
                                            //                 .fc_family_sf,
                                            //         fontWeight: Fontconstants
                                            //             .SF_Pro_Display_SEMIBOLD,
                                            //         color: textcolor))

                                            2.toSpace,
                                            Container(
                                              width:
                                                  Sizeconfig.getWidth(context) *
                                                      0.22,
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5.0),
                                                child: CommanTextWidget
                                                    .regularBold(
                                                  list[index].name!,
                                                  Color(0xFF232323),
                                                  maxline: 2,
                                                  trt: TextStyle(
                                                    fontSize: 13,
                                                    height: 1.2,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  textalign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
              );
  }

  //Kitchen Appliance
  static ui_type10(
      bool fromchekcout,
      BuildContext context,
      dynamic state,
      String title,
      String subtitle,
      FeaturedBloc bloc,
      int isMoreUnitIndex,
      CardBloc cardBloc,
      DatabaseHelper dbHelper,
      ScrollController _scrollController,
      bool loadMore,
      var themecolor,
      var themecolor2,
      var titlecolor,
      var textcolor,
      List<ProductData> listproduct,
      String buttontext,
      var buttonbackground,
      var buttontextcolor,
      String? image,
      Function callback,
      String paginationurl,
      List<Category>? categoriesList,
      String categoryId) {
    debugPrint("ui_type5similarProductsUI ${loadMore}");
    List<SubCategory> listsub = [];

    var headingview;

    if (image!.isEmpty || image == "" || image == null || image == "null") {
      headingview = Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Container(
          padding: const EdgeInsets.only(left: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.only(left: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          width: Sizeconfig.getWidth(context),
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 0),
                              child:
                                  CommanTextWidget.subheading(title, titlecolor)
                              //     Text(
                              //   title,
                              //   style: TextStyle(
                              //       fontSize: 23,
                              //       letterSpacing: 0.5,
                              //       fontFamily: Fontconstants.fc_family_sf,
                              //       fontWeight: FontWeight.w600,
                              //       color: titlecolor),
                              // ),
                              )),
                      Container(
                        width: Sizeconfig.getWidth(context),
                        child: Text(
                          subtitle,
                          style: TextStyle(
                              fontSize: 13,
                              fontFamily: Fontconstants.fc_family_sf,
                              color: titlecolor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      headingview = Container(
          padding: EdgeInsets.symmetric(vertical: 3),
          decoration: BoxDecoration(
            color: themecolor ?? Colors.transparent,
            image: DecorationImage(
              image: FileImage(File(image)),
              fit: BoxFit.contain,
            ),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: Sizeconfig.getWidth(context),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    child: Appwidgets.TextLagre("", titlecolor),
                  ),
                ),
                Container(
                  width: Sizeconfig.getWidth(context),
                  child: Appwidgets.TextRegular("", titlecolor),
                ),
              ],
            ),
          ));
    }
    return state is ShopByCategoryErrorState
        ? Center(
            child: Text(
              state.errorMessage,
              style: Appwidgets().commonTextStyle(ColorName.black),
            ),
          )
        : listproduct!.isEmpty
            ? Container()
            : BlocProvider(
                create: (context) => bloc,
                child: BlocBuilder<FeaturedBloc, FeaturedState>(
                    bloc: bloc,
                    builder: (context, state) {
                      debugPrint(
                          "12Featured Product State  " + state.toString());

                      // if (state is ProductForShopByState) {
                      //   list = state.list!;
                      //   debugPrint(
                      //       "LoadedFeaturedState  ${state.list!.length.toString()}");
                      //
                      //   for (int index = 0; index < list!.length; index++) {
                      //     var newmodel = list![index].unit![0];
                      //     getCartQuantity(newmodel.productId!).then((value) {
                      //       debugPrint("getCartQuanity $value");
                      //
                      //       if (value > 0) {
                      //         debugPrint(
                      //             "getCartQuanity name  ${list![index].unit![0].name}");
                      //       }
                      //       list![index].unit![0].addQuantity = value;
                      //       bloc.add(ProductUpdateQuantityInitial(list: list));
                      //     });
                      //
                      //     if (newmodel!.cOfferId != 0 &&
                      //         newmodel.cOfferId != null) {
                      //       debugPrint("***********************");
                      //       if (newmodel.subProduct != null) {
                      //         log("***********************>>>>>>>>>>>>>>>>" +
                      //             newmodel.subProduct!.toJson());
                      //         if (newmodel
                      //                 .subProduct!.subProductDetail!.length >
                      //             0) {
                      //           list![index]
                      //                   .unit![0]
                      //                   .subProduct!
                      //                   .subProductDetail =
                      //               MyUtility.checkOfferSubProductLoad(
                      //                   newmodel, dbHelper);
                      //         }
                      //       }
                      //     }
                      //
                      //     if (list![index].unit!.length > 1) {
                      //       for (int i = 0;
                      //           i < list![index].unit!.length;
                      //           i++) {
                      //         getCartQuantity(list![index].unit![i].productId!)
                      //             .then((value) {
                      //           debugPrint("getCartQuanity $value");
                      //           list![index].unit![i].addQuantity = value;
                      //           bloc.add(
                      //               ProductUpdateQuantityInitial(list: list));
                      //         });
                      //       }
                      //     }
                      //   }
                      // }
                      //
                      // // For Manage card list product Quanityt
                      // if (state is ProductUpdateQuantityInitialState) {
                      //   list = state.list!;
                      // }

                      // double size=  Sizeconfig.getHeight(context) * 0.22;

                      int line = (listproduct.length / 4).round();

                      debugPrint("Uitype5 Size " + line.toString());

                      if (line == 0) {
                        line = 1;
                      }

                      if (state is OldListState) {
                        listproduct = state.list!;
                      }

                      return Container(
                        color: themecolor,
                        child: Column(
                          children: [
                            headingview,
                            Container(
                              // height:
                              // line * Sizeconfig.getHeight(context) * 0.14,
                              padding: const EdgeInsets.only(left: 1),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GridView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4, // Number of columns

                                    crossAxisSpacing:
                                        8.0, // Spacing between columns
                                    mainAxisSpacing: 8.0,
                                    childAspectRatio:
                                        0.73, // Spacing between rows
                                  ),
                                  itemCount:
                                      listproduct.length, // Number of items
                                  itemBuilder: (context, index) {
                                    var dummyData =
                                        listproduct![index].unit![0];
                                    if (state is ProductUnitState) {
                                      if (dummyData.productId ==
                                          state.unit.productId) {
                                        dummyData = state.unit;
                                      }
                                    }
                                    return GestureDetector(
                                      onTap: () async {
                                        bool isMoreunit = false;

                                        if (listproduct![index].unit!.length >
                                            1) {
                                          isMoreunit = true;
                                        }

                                        for (int i = 0;
                                            i <
                                                listproduct![index]
                                                    .unit!
                                                    .length!;
                                            i++) {
                                          debugPrint(
                                              "Model  ${dummyData.productId} ${dummyData.addQuantity} ");
                                          if (dummyData.productId ==
                                              listproduct![index]
                                                  .unit![i]
                                                  .productId!) {
                                            listproduct![index].unit![i] =
                                                dummyData;
                                            isMoreUnitIndex = i;
                                          }
                                          debugPrint(
                                              "DATA Model  ${listproduct![index].unit![i].productId!}  ${listproduct![index].unit![i].addQuantity!}");
                                        }

                                        await Navigator.pushNamed(
                                          context,
                                          Routes.product_Detail_screen,
                                          arguments: {
                                            'fromchekcout': fromchekcout,
                                            'list': listproduct![index].unit!,
                                            'index': isMoreunit
                                                ? isMoreUnitIndex
                                                : index,
                                          },
                                        ).then((value) async {
                                          ProductUnit unit =
                                              value as ProductUnit;
                                          debugPrint(
                                              "FeatureCallback ${value.addQuantity}");

                                          SystemChrome.setSystemUIOverlayStyle(
                                              SystemUiOverlayStyle(
                                            statusBarColor: Colors
                                                .transparent, // transparent status bar
                                            statusBarIconBrightness: Brightness
                                                .light, // dark icons on the status bar
                                          ));
                                          bloc.add(ProductUpdateQuantityEvent(
                                              quanitity: unit.addQuantity!,
                                              index: index));
                                          callback();
                                        });
                                      },
                                      child: Container(
                                        child: Column(
                                          children: [
                                            Container(
                                              height:
                                                  Sizeconfig.getWidth(context) *
                                                      0.2,
                                              width:
                                                  Sizeconfig.getWidth(context) *
                                                      0.2,
                                              decoration: BoxDecoration(
                                                color: themecolor2,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Center(
                                                child: CommonCachedImageWidget(
                                                  imgUrl: dummyData.image!,
                                                  width: Sizeconfig.getWidth(
                                                          context) *
                                                      .15,
                                                  height: Sizeconfig.getWidth(
                                                          context) *
                                                      .15,
                                                ),
                                              ),
                                            ),
                                            /*  Text(dummyData.name!,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontSize: Constants.Size_10,
                                          fontFamily: Fontconstants
                                              .fc_family_sf,
                                          fontWeight: Fontconstants
                                              .SF_Pro_Display_Medium,
                                          color: textcolor))*/

                                            2.toSpace,
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 5),
                                              child:
                                                  CommanTextWidget.regularBold(
                                                dummyData.name!,
                                                textcolor,
                                                maxline: 2,
                                                trt: TextStyle(
                                                  fontSize: 12,
                                                  height: 1.2,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                textalign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            buttontext == ""
                                ? Container()
                                : Appwidgets.MyUiButton(
                                    context,
                                    buttontext,
                                    buttonbackground,
                                    buttontextcolor,
                                    Sizeconfig.getWidth(context), () async {
                                    /*  SharedPref.setStringPreference(
                                        Constants.sp_homepageproducts,
                                        jsonEncode(listproduct));
                                    Navigator.pushNamed(
                                        context, Routes.featuredProduct,
                                        arguments: {
                                          "key": title,
                                          "list": listproduct,
                                          "paninatinUrl": paginationurl
                                        }).then((value) {
                                      listproduct = value as List<ProductData>;

                                      print("vlaueGG ${listproduct.length}");

                                      bloc.add(OldListEvent(list: listproduct));
                                    });*/

                                    Category? category;

                                    int subcategoryIndex = 0;
                                    for (var x in categoriesList!) {
                                      print(
                                          "SeeAllGGGG id ${x.name} ${x.id} ${categoryId}");

                                      if (categoryId == x.id) {
                                        category = x;
                                      }
                                    }

                                    if (category == null) {
                                      for (var x in categoriesList!) {
                                        for (int y = 0;
                                            y < x.subCategories!.length;
                                            y++) {
                                          SubCategory sub = x.subCategories![y];
                                          print(
                                              "SeeAllGGGG2 id ${sub.name} ${sub.categoryId} ${categoryId}");
                                          if (categoryId == sub.categoryId) {
                                            subcategoryIndex = y;
                                            category = x;
                                          }
                                        }
                                      }
                                    }

                                    if (category == null) {
                                      for (var x in categoriesList!) {
                                        for (var y in x.subCategories!) {
                                          for (int z = 0;
                                              z < y.subCategories!.length;
                                              z++) {
                                            SubCategory sub =
                                                y.subCategories![z];
                                            print(
                                                "SeeAllGGGG3 id ${z} ${sub.name} ${sub.categoryId} ${categoryId}");
                                            if (categoryId == sub.categoryId) {
                                              subcategoryIndex = z;
                                              category = x;
                                            }
                                          }
                                        }
                                      }
                                    }

                                  //  print("SeeAllGGGG4  ${subcategoryIndex}");
                                  //  print("SeeAllGGGG4  ${category!.subCategories![subcategoryIndex!]}");
                                  //  print("SeeAllGGGG4  ${category!.id}");
                                   // print("SeeAllGGGG4   ${category!.subCategories![subcategoryIndex!].categoryId}");
                                    Navigator.pushNamed(
                                        context, Routes.shop_by_category,
                                        arguments: {
                                          "selected_category": category,
                                          "category_list": categoriesList,
                                          "selected_sub_category": category!
                                              .subCategories![subcategoryIndex!]
                                        }).then((value) {
                                      for (int index = 0;
                                          index < listproduct!.length;
                                          index++) {
                                        var newmodel =
                                            listproduct![index].unit![0];
                                        getCartQuantity(newmodel.productId!)
                                            .then((value) {
                                          debugPrint("getCartQuanityUI $value");

                                          if (value > 0) {
                                            debugPrint(
                                                "getCartQuanity name  ${listproduct![index].unit![0].name}");
                                          }
                                          listproduct![index]
                                              .unit![0]
                                              .addQuantity = value;
                                          // bloc.add(ProductUpdateQuantityInitial(list: list));
                                        });

                                        if (newmodel!.cOfferId != 0 &&
                                            newmodel.cOfferId != null) {
                                          debugPrint("***********************");
                                          if (newmodel.subProduct != null) {
                                            log("***********************>>>>>>>>>>>>>>>>" +
                                                newmodel.subProduct!.toJson());
                                            if (newmodel.subProduct!
                                                    .subProductDetail!.length >
                                                0) {
                                              listproduct![index]
                                                      .unit![0]
                                                      .subProduct!
                                                      .subProductDetail =
                                                  MyUtility
                                                      .checkOfferSubProductLoad(
                                                          newmodel, dbHelper);
                                            }
                                          }
                                        }

                                        if (listproduct![index].unit!.length >
                                            1) {
                                          for (int i = 0;
                                              i <
                                                  listproduct![index]
                                                      .unit!
                                                      .length;
                                              i++) {
                                            getCartQuantity(listproduct![index]
                                                    .unit![i]
                                                    .productId!)
                                                .then((value) {
                                              debugPrint(
                                                  "getCartQuanityUI $value");
                                              listproduct![index]
                                                  .unit![i]
                                                  .addQuantity = value;
                                              // bloc.add(ProductUpdateQuantityInitial(list: list));
                                            });
                                          }
                                        }
                                      }
                                      //callback();
                                    });
                                  })
                          ],
                        ),
                      );
                    }),
              );
  }

  //Hair care products

  static ui_type14(
      bool fromchekcout,
      BuildContext context,
      dynamic state,
      String title,
      String subtitle,
      FeaturedBloc bloc,
      int isMoreUnitIndex,
      CardBloc cardBloc,
      DatabaseHelper dbHelper,
      ScrollController _scrollController,
      bool loadMore,
      var themecolor,
      var themecolor2,
      var titlecolor,
      var textcolor,
      List<ProductData> listproduct,
      String buttontext,
      var buttonbackground,
      var buttontextcolor,
      String? image,
      Function callback,
      String paginationurl,
      List<Category>? categoriesList,
      String categoryId) {
    debugPrint("ui_type5similarProductsUI ${loadMore}");
    List<SubCategory> listsub = [];

    var headingview;
    List<ProductData> listProducttemp = [];
    if (image!.isEmpty || image == "" || image == null || image == "null") {
      headingview = Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Container(
          padding: const EdgeInsets.only(left: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.only(left: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          width: Sizeconfig.getWidth(context),
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 0),
                              child:
                                  CommanTextWidget.subheading(title, titlecolor)

                              //     Text(
                              //   title,
                              //   style: TextStyle(
                              //       fontSize: 23,
                              //       letterSpacing: 0.5,
                              //       fontFamily: Fontconstants.fc_family_sf,
                              //       fontWeight: FontWeight.w600,
                              //       color: titlecolor),
                              // ),
                              )),
                      Container(
                        width: Sizeconfig.getWidth(context),
                        child: Text(
                          subtitle,
                          style: TextStyle(
                              fontSize: 13,
                              fontFamily: Fontconstants.fc_family_sf,
                              color: titlecolor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      headingview = Container(
          padding: EdgeInsets.symmetric(vertical: 3),
          decoration: BoxDecoration(
            color: themecolor ?? Colors.transparent,
            image: DecorationImage(
              image: FileImage(File(image)),
              fit: BoxFit.contain,
            ),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: Sizeconfig.getWidth(context),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    child: Appwidgets.TextLagre("", titlecolor),
                  ),
                ),
                Container(
                  width: Sizeconfig.getWidth(context),
                  child: Appwidgets.TextRegular("", titlecolor),
                ),
              ],
            ),
          ));
    }
    return state is ShopByCategoryErrorState
        ? Center(
            child: Text(
              state.errorMessage,
              style: Appwidgets().commonTextStyle(ColorName.black),
            ),
          )
        : listproduct!.isEmpty
            ? Container()
            : BlocProvider(
                create: (context) => bloc,
                child: BlocBuilder(
                    bloc: bloc,
                    builder: (context, state) {
                      if (state is OldListState) {
                        listproduct = state.list!;
                      }

                      return Container(
                        color: themecolor,
                        child: Column(
                          children: [
                            headingview,
                            5.toSpace,
                            Container(
                              //      height: line * Sizeconfig.getHeight(context) * 0.17,
                              padding: const EdgeInsets.only(left: 1),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: GridView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3, // Number of columns
                                    crossAxisSpacing:
                                        8.0, // Spacing between columns
                                    mainAxisSpacing: 8.0,
                                    childAspectRatio:
                                        0.9, // Spacing between rows
                                  ),
                                  itemCount: listproduct.length > 6
                                      ? 6
                                      : listproduct.length, // Number of items
                                  itemBuilder: (context, index) {
                                    var dummyData =
                                        listproduct![index].unit![0];
                                    if (state is ProductUnitState) {
                                      if (dummyData.productId ==
                                          state.unit.productId) {
                                        dummyData = state.unit;
                                      }
                                    }
                                    return GestureDetector(
                                      onTap: () async {
                                        bool isMoreunit = false;

                                        if (listproduct![index].unit!.length >
                                            1) {
                                          isMoreunit = true;
                                        }

                                        for (int i = 0;
                                            i <
                                                listproduct![index]
                                                    .unit!
                                                    .length!;
                                            i++) {
                                          debugPrint(
                                              "Model  ${dummyData.productId} ${dummyData.addQuantity} ");
                                          if (dummyData.productId ==
                                              listproduct![index]
                                                  .unit![i]
                                                  .productId!) {
                                            listproduct![index].unit![i] =
                                                dummyData;
                                            isMoreUnitIndex = i;
                                          }
                                          debugPrint(
                                              "DATA Model  ${listproduct![index].unit![i].productId!}  ${listproduct![index].unit![i].addQuantity!}");
                                        }

                                        await Navigator.pushNamed(
                                          context,
                                          Routes.product_Detail_screen,
                                          arguments: {
                                            'fromchekcout': fromchekcout,
                                            'list': listproduct![index].unit!,
                                            'index': isMoreunit
                                                ? isMoreUnitIndex
                                                : index,
                                          },
                                        ).then((value) async {
                                          ProductUnit unit =
                                              value as ProductUnit;
                                          debugPrint(
                                              "FeatureCallback ${value.addQuantity}");

                                          SystemChrome.setSystemUIOverlayStyle(
                                              SystemUiOverlayStyle(
                                            statusBarColor: Colors
                                                .transparent, // transparent status bar
                                            statusBarIconBrightness: Brightness
                                                .light, // dark icons on the status bar
                                          ));
                                          bloc.add(ProductUpdateQuantityEvent(
                                              quanitity: unit.addQuantity!,
                                              index: index));

                                          callback();
                                        });
                                      },
                                      child: Container(
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: Container(
                                                width: Sizeconfig.getWidth(
                                                        context) *
                                                    0.3,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      height:
                                                          Sizeconfig.getWidth(
                                                                  context) *
                                                              0.18,
                                                      width:
                                                          Sizeconfig.getWidth(
                                                                  context) *
                                                              0.3,
                                                      decoration: BoxDecoration(
                                                        color: themecolor2,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                    ),
                                                    /*       Text(dummyData.name!,
                                                    textAlign:
                                                    TextAlign.center,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        fontSize: Constants
                                                            .Size_11,
                                                        letterSpacing:
                                                        1.015,
                                                        fontFamily:
                                                        Fontconstants
                                                            .fc_family_sf,
                                                        fontWeight:
                                                        Fontconstants
                                                            .SF_Pro_Display_SEMIBOLD,
                                                        color: textcolor))*/

                                                    5.toSpace,
                                                    CommanTextWidget
                                                        .regularBold(
                                                      dummyData.name!,
                                                      textcolor,
                                                      maxline: 2,
                                                      trt: TextStyle(
                                                        fontSize: 12,
                                                        height: 1.25,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      textalign:
                                                          TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 0,
                                              child: Container(
                                                width: Sizeconfig.getWidth(
                                                        context) *
                                                    0.3,
                                                child: Center(
                                                  child:
                                                      CommonCachedImageWidget(
                                                    imgUrl: dummyData.image!,
                                                    width: Sizeconfig.getWidth(
                                                            context) *
                                                        .18,
                                                    height: Sizeconfig.getWidth(
                                                            context) *
                                                        .20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            buttontext == ""
                                ? Container()
                                : Appwidgets.MyUiButton(
                                    context,
                                    buttontext,
                                    buttonbackground,
                                    buttontextcolor,
                                    Sizeconfig.getWidth(context), () async {
                                    /*  SharedPref.setStringPreference(
                                        Constants.sp_homepageproducts,
                                        jsonEncode(listproduct));

                                    Navigator.pushNamed(
                                        context, Routes.featuredProduct,
                                        arguments: {
                                          "key": title,
                                          "list": listproduct,
                                          "paninatinUrl": paginationurl
                                        }).then((value) {
                                      listproduct = value as List<ProductData>;

                                      print("vlaueGG ${listproduct.length}");

                                      bloc.add(OldListEvent(list: listproduct));
                                    });*/

                                    Category? category;

                                    int subcategoryIndex = 0;
                                    for (var x in categoriesList!) {
                                      print(
                                          "SeeAllGGGG id ${x.name} ${x.id} ${categoryId}");

                                      if (categoryId == x.id) {
                                        category = x;
                                      }
                                    }

                                    if (category == null) {
                                      for (var x in categoriesList!) {
                                        for (int y = 0;
                                            y < x.subCategories!.length;
                                            y++) {
                                          SubCategory sub = x.subCategories![y];
                                          print(
                                              "SeeAllGGGG2 id ${sub.name} ${sub.categoryId} ${categoryId}");
                                          if (categoryId == sub.categoryId) {
                                            subcategoryIndex = y;
                                            category = x;
                                          }
                                        }
                                      }
                                    }

                                    if (category == null) {
                                      for (var x in categoriesList!) {
                                        for (var y in x.subCategories!) {
                                          for (int z = 0;
                                              z < y.subCategories!.length;
                                              z++) {
                                            SubCategory sub =
                                                y.subCategories![z];
                                            print(
                                                "SeeAllGGGG3 id ${z} ${sub.name} ${sub.categoryId} ${categoryId}");
                                            if (categoryId == sub.categoryId) {
                                              subcategoryIndex = z;
                                              category = x;
                                            }
                                          }
                                        }
                                      }
                                    }

                                    print("SeeAllGGGG4  ${subcategoryIndex}");
                                    print(
                                        "SeeAllGGGG4  ${category!.subCategories![subcategoryIndex!]}");
                                    print("SeeAllGGGG4  ${category!.id}");
                                    print(
                                        "SeeAllGGGG4   ${category!.subCategories![subcategoryIndex!].categoryId}");
                                    Navigator.pushNamed(
                                        context, Routes.shop_by_category,
                                        arguments: {
                                          "selected_category": category,
                                          "category_list": categoriesList,
                                          "selected_sub_category": category!
                                              .subCategories![subcategoryIndex!]
                                        }).then((value) {
                                      for (int index = 0;
                                          index < listproduct!.length;
                                          index++) {
                                        var newmodel =
                                            listproduct![index].unit![0];
                                        getCartQuantity(newmodel.productId!)
                                            .then((value) {
                                          debugPrint("getCartQuanityUI $value");

                                          if (value > 0) {
                                            debugPrint(
                                                "getCartQuanity name  ${listproduct![index].unit![0].name}");
                                          }
                                          listproduct![index]
                                              .unit![0]
                                              .addQuantity = value;
                                          // bloc.add(ProductUpdateQuantityInitial(list: list));
                                        });

                                        if (newmodel!.cOfferId != 0 &&
                                            newmodel.cOfferId != null) {
                                          debugPrint("***********************");
                                          if (newmodel.subProduct != null) {
                                            log("***********************>>>>>>>>>>>>>>>>" +
                                                newmodel.subProduct!.toJson());
                                            if (newmodel.subProduct!
                                                    .subProductDetail!.length >
                                                0) {
                                              listproduct![index]
                                                      .unit![0]
                                                      .subProduct!
                                                      .subProductDetail =
                                                  MyUtility
                                                      .checkOfferSubProductLoad(
                                                          newmodel, dbHelper);
                                            }
                                          }
                                        }

                                        if (listproduct![index].unit!.length >
                                            1) {
                                          for (int i = 0;
                                              i <
                                                  listproduct![index]
                                                      .unit!
                                                      .length;
                                              i++) {
                                            getCartQuantity(listproduct![index]
                                                    .unit![i]
                                                    .productId!)
                                                .then((value) {
                                              debugPrint(
                                                  "getCartQuanityUI $value");
                                              listproduct![index]
                                                  .unit![i]
                                                  .addQuantity = value;
                                              // bloc.add(ProductUpdateQuantityInitial(list: list));
                                            });
                                          }
                                        }
                                      }
                                      //callback();
                                    });
                                  })
                          ],
                        ),
                      );
                    }),
              );
  }

  //Big Sale
  static ui_type18(
      bool fromchekcout,
      BuildContext context,
      dynamic state,
      String title,
      String subtitle,
      FeaturedBloc bloc,
      int isMoreUnitIndex,
      CardBloc cardBloc,
      DatabaseHelper dbHelper,
      ScrollController _scrollController,
      bool loadMore,
      var themecolor,
      var themecolor2,
      var titlecolor,
      var textcolor,
      List<Category> listcategory,
      String buttontext,
      var buttonbackground,
      var buttontextcolor,
      String? image,
      Function callback) {
    print("ui_type18 imagepath ${image}");
    List<SubCategory> listsub = [];

    var headingview;

    if (image!.isEmpty || image == "" || image == null || image == "null") {
      headingview = Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Container(
          padding: const EdgeInsets.only(left: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.only(left: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          width: Sizeconfig.getWidth(context),
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 0),
                              child:
                                  CommanTextWidget.subheading(title, titlecolor)
                              /* Text(
                              title,
                              style: TextStyle(
                                  fontSize: 23,
                                  letterSpacing: 0.5,
                                  fontFamily: Fontconstants.fc_family_sf,
                                  fontWeight: FontWeight.w600,
                                  color: titlecolor),

                            ),*/
                              )),
                      Container(
                        width: Sizeconfig.getWidth(context),
                        child: Text(
                          subtitle,
                          style: TextStyle(
                              fontSize: 13,
                              fontFamily: Fontconstants.fc_family_sf,
                              color: titlecolor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      headingview = Container(
          height: Sizeconfig.getHeight(context) * 0.22,
          padding: EdgeInsets.symmetric(vertical: 3),
          decoration: BoxDecoration(
            color: themecolor ?? Colors.transparent,
            image: DecorationImage(
              image: FileImage(File(image)),
              // Use FileImage here
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: Sizeconfig.getWidth(context),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    child: Appwidgets.TextLagre("", titlecolor),
                  ),
                ),
                Container(
                  width: Sizeconfig.getWidth(context),
                  child: Appwidgets.TextRegular("", titlecolor),
                ),
              ],
            ),
          ));
    }
    return state is ShopByCategoryErrorState
        ? Center(
            child: Text(
              state.errorMessage,
              style: Appwidgets().commonTextStyle(ColorName.black),
            ),
          )
        : listcategory!.isEmpty
            ? Container()
            : BlocProvider(
                create: (context) => bloc,
                child: BlocBuilder<FeaturedBloc, FeaturedState>(
                    bloc: bloc,
                    builder: (context, state) {
                      debugPrint(
                          "12Featured Product State  " + state.toString());

                      // if (state is ProductForShopByState) {
                      //   list = state.list!;
                      //   debugPrint(
                      //       "LoadedFeaturedState  ${state.list!.length.toString()}");
                      //
                      //   for (int index = 0; index < list!.length; index++) {
                      //     var newmodel = list![index].unit![0];
                      //     getCartQuantity(newmodel.productId!).then((value) {
                      //       debugPrint("getCartQuanity $value");
                      //
                      //       if (value > 0) {
                      //         debugPrint(
                      //             "getCartQuanity name  ${list![index].unit![0].name}");
                      //       }
                      //       list![index].unit![0].addQuantity = value;
                      //       bloc.add(ProductUpdateQuantityInitial(list: list));
                      //     });
                      //
                      //     if (newmodel!.cOfferId != 0 &&
                      //         newmodel.cOfferId != null) {
                      //       debugPrint("***********************");
                      //       if (newmodel.subProduct != null) {
                      //         log("***********************>>>>>>>>>>>>>>>>" +
                      //             newmodel.subProduct!.toJson());
                      //         if (newmodel
                      //                 .subProduct!.subProductDetail!.length >
                      //             0) {
                      //           list![index]
                      //                   .unit![0]
                      //                   .subProduct!
                      //                   .subProductDetail =
                      //               MyUtility.checkOfferSubProductLoad(
                      //                   newmodel, dbHelper);
                      //         }
                      //       }
                      //     }
                      //
                      //     if (list![index].unit!.length > 1) {
                      //       for (int i = 0;
                      //           i < list![index].unit!.length;
                      //           i++) {
                      //         getCartQuantity(list![index].unit![i].productId!)
                      //             .then((value) {
                      //           debugPrint("getCartQuanity $value");
                      //           list![index].unit![i].addQuantity = value;
                      //           bloc.add(
                      //               ProductUpdateQuantityInitial(list: list));
                      //         });
                      //       }
                      //     }
                      //   }
                      // }
                      //
                      // // For Manage card list product Quanityt
                      // if (state is ProductUpdateQuantityInitialState) {
                      //   list = state.list!;
                      // }

                      // double size=  Sizeconfig.getHeight(context) * 0.22;

                      int line = (listcategory.length / 4).round();

                      debugPrint("Uitype5 Size " + line.toString());

                      if (line == 0) {
                        line = 1;
                      }

                      int parts = (listcategory.length / 4)
                          .ceil(); // Calculate the number of parts needed

                      List<bool> fulllenght = [];
                      List<List<Category>> listall = [];
                      for (int i = 0; i < parts; i++) {
                        int start = i * 4; // Starting index for each part
                        int end = start + 4; // Ending index (exclusive)

                        List<Category> sublist = listcategory.sublist(
                            start,
                            end > listcategory.length
                                ? listcategory.length
                                : end);
                        listall.add(sublist); // Add the sublist to listall

                        if (i * 4 + 4 <= listcategory.length) {
                          fulllenght.add(true); // This part is full
                        } else {
                          fulllenght.add(false); // This part is not full
                        }
                      }

                      debugPrint("Uitype5 Size ${fulllenght} ");
                      return Container(
                        color: themecolor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            headingview,
                            ListView.builder(
                                itemCount: line,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index2) {
                                  debugPrint("Uitype5 GGGGG ${index2 != 1} ");
                                  debugPrint(
                                      "Uitype5 GGGGG ${Sizeconfig.getHeight(context) * .22} ");
                                  return Container(
                                    padding: const EdgeInsets.only(left: 1),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child:
                                          /*   index2 != 1&&listall[index2].length==4
                                          ? */
                                          listall[index2].length > 3
                                              ? GridView.builder(
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  gridDelegate:
                                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount:
                                                        4, // Number of columns
                                                    crossAxisSpacing:
                                                        8.0, // Spacing between columns
                                                    mainAxisSpacing: 8.0,
                                                    childAspectRatio:
                                                        0.65, // Spacing between rows
                                                  ),
                                                  // itemCount: listcategory.length, // Number of items
                                                  itemCount: listall[index2]
                                                      .length, // Number of items
                                                  itemBuilder:
                                                      (context, index) {
                                                    var category =
                                                        listall[index2]![index];
                                                    return Container(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          Navigator.pushNamed(
                                                              context,
                                                              Routes
                                                                  .shop_by_category,
                                                              arguments: {
                                                                "selected_category":
                                                                    category,
                                                                "category_list":
                                                                    listcategory,
                                                                "selected_sub_category":
                                                                    category
                                                                        .subCategories![0]
                                                              }).then((value) {
                                                            callback();
                                                          });
                                                        },
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                              height: Sizeconfig
                                                                          .getHeight(
                                                                              context) <
                                                                      800
                                                                  ? Sizeconfig.getHeight(
                                                                          context) *
                                                                      0.11
                                                                  : Sizeconfig.getWidth(
                                                                          context) *
                                                                      0.22,
                                                              // width:
                                                              // Sizeconfig.getWidth(context) *
                                                              //     0.2,

                                                              decoration:
                                                                  BoxDecoration(
                                                                color:
                                                                    themecolor2,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              child: Center(
                                                                child:
                                                                    CommonCachedImageWidget(
                                                                  imgUrl: category
                                                                      .image!,
                                                                  width: Sizeconfig
                                                                          .getWidth(
                                                                              context) *
                                                                      .15,
                                                                  height: Sizeconfig
                                                                          .getWidth(
                                                                              context) *
                                                                      .15,
                                                                ),
                                                              ),
                                                            ),
                                                            // Text(category.name!,
                                                            //     textAlign: TextAlign.center,
                                                            //     maxLines: 2,
                                                            //     style: TextStyle(
                                                            //         fontSize: Constants.Size_10,
                                                            //         fontFamily: Fontconstants
                                                            //             .fc_family_sf,
                                                            //         fontWeight: Fontconstants
                                                            //             .SF_Pro_Display_Medium,
                                                            //         color: textcolor)),
                                                            5.toSpace,
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          5),
                                                              child: CommanTextWidget
                                                                  .regularBold(
                                                                category.name!,
                                                                Color(
                                                                    0xFF232323),
                                                                maxline: 2,
                                                                trt: TextStyle(
                                                                  fontSize: 14,
                                                                  height: 1,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                                textalign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                )
                                              : Container(
                                                  width: Sizeconfig.getWidth(
                                                          context) *
                                                      0.8,
                                                  height: Sizeconfig.getHeight(
                                                          context) *
                                                      .22,
                                                  child: Center(
                                                    child: ListView.builder(
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      shrinkWrap: true,

                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount: listall[index2]
                                                          .length, // Number of items
                                                      itemBuilder:
                                                          (context, index) {
                                                        var category = listall[
                                                            index2]![index];
                                                        return Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              Navigator.pushNamed(
                                                                  context,
                                                                  Routes
                                                                      .shop_by_category,
                                                                  arguments: {
                                                                    "selected_category":
                                                                        category,
                                                                    "category_list":
                                                                        listcategory,
                                                                    "selected_sub_category":
                                                                        category
                                                                            .subCategories![0]
                                                                  }).then(
                                                                  (value) {
                                                                callback();
                                                              });
                                                            },
                                                            child: Column(
                                                              children: [
                                                                Container(
                                                                  height: Sizeconfig
                                                                          .getWidth(
                                                                              context) *
                                                                      0.22,
                                                                  width: Sizeconfig
                                                                          .getWidth(
                                                                              context) *
                                                                      0.22,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color:
                                                                        themecolor2,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                  child: Center(
                                                                    child:
                                                                        CommonCachedImageWidget(
                                                                      imgUrl: category
                                                                          .image!,
                                                                      width: Sizeconfig.getWidth(
                                                                              context) *
                                                                          .15,
                                                                      height:
                                                                          Sizeconfig.getWidth(context) *
                                                                              .15,
                                                                    ),
                                                                  ),
                                                                ),
                                                                // Text(category.name!,
                                                                //     textAlign: TextAlign.center,
                                                                //     maxLines: 2,
                                                                //     style: TextStyle(
                                                                //         fontSize: Constants.Size_10,
                                                                //         fontFamily: Fontconstants
                                                                //             .fc_family_sf,
                                                                //         fontWeight: Fontconstants
                                                                //             .SF_Pro_Display_Medium,
                                                                //         color: textcolor)),
                                                                5.toSpace,
                                                                Container(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              3),
                                                                  width: Sizeconfig
                                                                          .getWidth(
                                                                              context) *
                                                                      0.18,
                                                                  child: CommanTextWidget
                                                                      .regularBold(
                                                                    category
                                                                        .name!,
                                                                    Color(
                                                                        0xFF232323),
                                                                    maxline: 2,
                                                                    trt:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      height: 1,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                    textalign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                    ),
                                  );
                                }),
                            buttontext == ""
                                ? Container()
                                : Appwidgets.MyUiButton(
                                    context,
                                    buttontext,
                                    buttonbackground,
                                    buttontextcolor,
                                    Sizeconfig.getWidth(context),
                                    () async {})
                          ],
                        ),
                      );
                    }),
              );
  }

  static Future<String> downloadAndSaveImage(
      String url, String fileName) async {
    debugPrint("GauravNew1 ${url}");

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    debugPrint("GauravNew2 ${url}");

    if (await File(filePath).exists() == false) {
      final response = await http.get(Uri.parse(url));

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
    }

    debugPrint("GauravNew2 ${filePath}");
    return filePath;
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
    if (model.addQuantity != 0) {
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

      bool isSubProductAvailable = false;

      if (model!.cOfferId != 0 && model.cOfferId != null) {
        debugPrint("SubProduct Json >>>${model.subProduct!.toJson()}");
        isSubProductAvailable = true;
      }

      int status = await dbHelper.insertAddCardProduct({
        DBConstants.PRODUCT_ID: int.parse(model.productId!),
        DBConstants.PRODUCT_NAME: model.name,
        DBConstants.PRODUCT_WEIGHT: model.productWeight,
        DBConstants.PRODUCT_WEIGHT_UNIT: model.productWeightUnit,
        DBConstants.ORDER_QTY_LIMIT: model.orderQtyLimit,
        DBConstants.CNF_SHIPPING_SURCHARGE: "",
        DBConstants.SHIPPING_MAX_AMOUNT: "",
        DBConstants.IMAGE: model.image,
        DBConstants.DISTEXT: model.discountText,
        DBConstants.DISLABEL: model.discountLabel,
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
        DBConstants.OFFER_ID: model.cOfferId.toString(),
        DBConstants.OFFER_TYPE: model.cOfferType.toString(),
        DBConstants.SUB_PRODUCT:
            isSubProductAvailable ? model.subProduct!.toJson() : "",
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

  static AddQuantityButton(var bgcolor, var textcolor, String text,
      int quantity, Function() onincress, Function() ondecrease) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      margin: EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8.0)), color: bgcolor),
      child: Container(
        child: Container(
          height: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: ondecrease,
                child: Container(
                    height: double.infinity,
                    padding: EdgeInsets.only(right: 6, left: 10),
                    child: Image.asset(Imageconstants.img_minus,
                        width: 11, color: textcolor)
                    // const Icon(Icons.remove, size: Constants.SizeButton)

                    ),
              ),
              2.toSpace,
              Container(
                child: Text(
                  "$quantity",
                  style: TextStyle(
                      fontSize: Constants.SizeMidium,
                      fontFamily: Fontconstants.fc_family_sf,
                      fontWeight: Fontconstants.SF_Pro_Display_Bold,
                      color: textcolor),
                ),
              ),
              2.toSpace,
              GestureDetector(
                onTap: onincress,
                child: Container(
                    height: double.infinity,
                    padding: EdgeInsets.only(left: 6, right: 10),
                    child: Image.asset(Imageconstants.img_plus,
                        width: 11, color: textcolor)
                    /* const Icon(
                      Icons.add,
                      size: Constants.SizeButton,
                    )*/

                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static buttonPrimary(
      var bgcolor, var textcolor, String text, Function() onpress) {
    return InkWell(
      onTap: onpress,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 0),
        margin: EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            color: bgcolor),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
                fontSize: Constants.SizeSmall,
                fontFamily: Fontconstants.fc_family_sf,
                fontWeight: Fontconstants.SF_Pro_Display_Bold,
                color: textcolor),
          ),
        ),
      ),
    );
  }

  static smallbuttonPrimary(
      var bgcolor, var textcolor, String text, Function() onpress) {
    return InkWell(
      onTap: onpress,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 13, vertical: 0),
        margin: EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            color: bgcolor),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
                fontSize: Constants.Size_11,
                fontFamily: Fontconstants.fc_family_sf,
                fontWeight: Fontconstants.SF_Pro_Display_Bold,
                color: textcolor),
          ),
        ),
      ),
    );
  }

  static smallbuttonPrimaryborder(
      var bgcolor, var textcolor, String text, Function() onpress) {
    return InkWell(
      onTap: onpress,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
        margin: EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(7.0)),
            border: Border.all(color: bgcolor, width: 1),
            color: Colors.white),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
                fontSize: 12,
                fontFamily: Fontconstants.fc_family_sf,
                fontWeight: Fontconstants.SF_Pro_Display_Bold,
                color: bgcolor),
          ),
        ),
      ),
    );
  }

  static smallAddQuantityButton(var bgcolor, var textcolor, String text,
      int quantity, Function() onincress, Function() ondecrease) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 0),
        padding: EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            color: bgcolor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
                onTap: ondecrease,
                child: Container(
                  height: double.infinity,
                  padding: EdgeInsets.only(right: 4, left: 6),
                  child: Image.asset(Imageconstants.img_minus,
                      color: Colors.white, width: 10),
                  // Icon(Icons.remove, size: Constants.SizeSmall)
                )),
            1.toSpace,
            Container(
              child: Text(
                " $quantity ",
                style: TextStyle(
                    fontSize: Constants.SizeSmall,
                    fontFamily: Fontconstants.fc_family_sf,
                    fontWeight: Fontconstants.SF_Pro_Display_Bold,
                    color: textcolor),
              ),
            ),
            1.toSpace,
            InkWell(
                onTap: onincress,
                child: Container(
                  height: double.infinity,
                  padding: EdgeInsets.only(left: 4, right: 6),
                  child: Image.asset(Imageconstants.img_plus,
                      color: Colors.white, width: 10),
                )),
          ],
        ),
      ),
    );
  }

  static smallAddQuantityButtonborder(var bgcolor, var textcolor, String text,
      int quantity, Function() onincress, Function() ondecrease) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0),
      padding: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(7.0)),
          border: Border.all(color: bgcolor, width: 1),
          color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: InkWell(
                onTap: ondecrease,
                child: Container(
                    child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Image.asset(
                    Imageconstants.img_minus,
                  ),
                )
                    //Icon(Icons.remove, size: 13,color: bgcolor,)

                    )

                /*    Text(
                "  -  ",
                style: TextStyle(
                    fontSize: Constants.Size_11,
                    fontFamily: Fontconstants.fc_family_sf,
                    fontWeight: Fontconstants.SF_Pro_Display_Bold,
                    color: textcolor),
              ),*/
                ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: Center(
                child: Text(
                  "$quantity",
                  style: TextStyle(
                      fontSize: 13,
                      fontFamily: Fontconstants.fc_family_roboto,
                      fontWeight: FontWeight.w700,
                      color: bgcolor),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: InkWell(
                onTap: onincress,
                child: Container(
                    child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Image.asset(
                    Imageconstants.img_plus,
                  ),
                )
                    //Icon(Icons.add, size: 13,color: bgcolor)
                    )),
          ),
        ],
      ),
    );
  }

  static borderAddQuantityButton(var bgcolor, var textcolor, String text,
      int quantity, Function() onincress, Function() ondecrease) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      margin: EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
          color: bgcolor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: ondecrease,
            child: Container(
                height: double.infinity,
                padding: EdgeInsets.only(right: 9, left: 10),
                child: Image.asset(Imageconstants.img_minus,
                    width: 11, color: textcolor)
                //const Icon(Icons.remove, size: Constants.SizeButton)

                ),
          ),
          Container(
            child: Text(
              "$quantity",
              style: TextStyle(
                  fontSize: Constants.SizeMidium,
                  fontFamily: Fontconstants.fc_family_sf,
                  fontWeight: Fontconstants.SF_Pro_Display_Bold,
                  color: textcolor),
            ),
          ),
          GestureDetector(
            onTap: onincress,
            child: Container(
                height: double.infinity,
                padding: EdgeInsets.only(left: 9, right: 10),
                child: Image.asset(Imageconstants.img_plus,
                    width: 11, color: textcolor)),
          ),
        ],
      ),
    );
  }

  static borderbuttonPrimary(
      var bgcolor, var textcolor, String text, Function() onpress) {
    return InkWell(
      onTap: onpress,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
          // You can keep this border color or change it
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color(0xFFD9D9D9), // #D9D9D9
              Color(0xFFA3A3A3), // #A3A3A3
            ],
          ),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),

          margin: EdgeInsets.all(1), // Adjust the width of the border here
          decoration: BoxDecoration(
            color: Colors.white, // Inner container background color
            borderRadius: BorderRadius.all(Radius.circular(
                15.0)), // Same as outer container's borderRadius minus the border thickness
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.asset(Imageconstants.img_plus,
                      width: 11, color: bgcolor),
                )
                    //Icon(Icons.add, size: Constants.SizeButton, color: bgcolor)

                    ),
                4.toSpace,
                Text(
                  text,
                  style: TextStyle(
                      fontSize: Constants.SizeSmall,
                      fontFamily: Fontconstants.fc_family_sf,
                      fontWeight: Fontconstants.SF_Pro_Display_Bold,
                      color: bgcolor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
