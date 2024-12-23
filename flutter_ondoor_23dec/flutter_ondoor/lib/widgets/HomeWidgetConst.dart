import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:ondoor/constants/StringConstats.dart';
import 'package:ondoor/screens/AddCard/card_bloc.dart';
import 'package:ondoor/screens/AddCard/card_state.dart';
import 'package:ondoor/screens/HomeScreen/HomeBloc/TopSellingBloc/top_selling_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondoor/screens/HomeScreen/HomeBloc/TopSellingBloc/top_selling_event.dart';
import 'package:ondoor/screens/HomeScreen/HomeBloc/TopSellingBloc/top_selling_state.dart';
import 'package:ondoor/screens/HomeScreen/HomeBloc/home_page_bloc.dart';
import 'package:ondoor/screens/HomeScreen/HomeBloc/home_page_state.dart';
import 'package:ondoor/utils/Commantextwidget.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/shimmerUi.dart';
import 'package:ondoor/widgets/common_cached_image_widget.dart';
import '../constants/FontConstants.dart';
import '../constants/Constant.dart';
import '../constants/ImageConstants.dart';
import '../models/AllProducts.dart';
import '../models/HomepageModel.dart';
import '../models/TopProducts.dart';
import '../models/HomepageModel.dart';
import '../models/TopProducts.dart';
import '../screens/FeaturedProduct/FeatuuredBloc/featured_bloc.dart';
import '../screens/HomeScreen/HomeBloc/home_page_event.dart';

import '../screens/shop_by_category/shop_by_category_bloc/shop_by_category_bloc.dart';
import '../services/Navigation/routes.dart';
import '../utils/SizeConfig.dart';
import '../utils/colors.dart';
import 'AppWidgets.dart';

class Homewidgetconst {
  View_singlecategoryitem(BuildContext context, var height, int index,
      Category category, List<Category> categoryList, Function callback) {
    var width = Sizeconfig.getWidth(context) / 2;
    var screenwidth = Sizeconfig.getWidth(context);
    var screenheight = Sizeconfig.getHeight(context);
    print("screen height greater than 400 ${screenheight}");
    print("${screenheight * .08}");
    return InkWell(
      onTap: () {
        // Navigator.pushNamed(context, Routes.shop_by_category, arguments: {
        //   "selected_category": category,
        //   "category_list": categoryList,
        // }).then((value) {
        //   callback();
        // });
        Navigator.pushNamed(context, Routes.shop_by_category, arguments: {
          "selected_category": category,
          "category_list": categoryList,
          "selected_sub_category": category.subCategories![0]
        }).then((value) {
          callback();
        });
      },
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 1),

          width: width,
          child: Card(
            margin: EdgeInsets.zero,
            color: ColorName.categorybg,
            elevation: 1,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: ColorName.mediumGrey.withOpacity(0.2), width: 0.5),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Container(
              height: Sizeconfig.getHeight(context)*0.2,
              child:
/*
              Image.network(
                category.image!,
                width: width,
                fit: BoxFit.fill,
              ),*/

                  /*  Image.file(
                File(category.image!),
                width: width,
                fit: BoxFit.fill,
              ),*/

                  //
                  /*   Image.asset(
                             "assets/images/test0.png",
                              width: width,
                              fit: BoxFit.fill,
                            ),*/
                  Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 10.toSpace,
                  Expanded(
                    flex: 2,
                    child: Text(
                      category.name!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          letterSpacing: 0,
                          fontSize: 12,
                          fontFamily: Fontconstants.fc_family_sf,
                          fontWeight: Fontconstants.SF_Pro_Display_Bold,
                          color: ColorName.black),
                    ),
                  ),
                 // Spacer(),
                  Expanded(
                    flex: 8,
                    child: Container(
                      // height: screenheight > 800
                      //     ? screenheight * .088
                      //     : screenheight * .10,
                      // width: screenwidth > 400
                      //     ? screenwidth * .25
                      //     : screenwidth * .23,
                      child: Image.file(
                        // height: 72,
                        // width: 88,
                        File(category.image!),
                        // fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ],
              ),

            ),
          )),
    );
  }

  View_categoryitem(BuildContext context, var height, int index,
      Category category, List<Category> categoryList, Function callback) {
    var width = Sizeconfig.getWidth(context) / 4;
    print("width ${width}");
    var screenwidth = Sizeconfig.getWidth(context);
    var screenheight = Sizeconfig.getHeight(context);
    print("width  fjghk  ${screenwidth * .244}");
    print("width  fjghk  $screenwidth $screenheight");
    return GestureDetector(
      onTap: () {
        // Navigator.pushNamed(context, Routes.shop_by_category, arguments: {
        //   "selected_category": category,
        //   "category_list": categoryList
        // }).then((value) {
        //   callback();
        // });
        Navigator.pushNamed(context, Routes.shop_by_category, arguments: {
          "selected_category": category,
          "category_list": categoryList,
          "selected_sub_category": category.subCategories![0]
        }).then((value) {
          callback();
        });
      },
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 1),
          width: width,
          child: Card(
            margin: EdgeInsets.zero,
            elevation: 1,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: ColorName.mediumGrey.withOpacity(0.2), width: 0.5),
              borderRadius: BorderRadius.circular(5),
            ),

            color: ColorName.categorybg,

            child: Container(
              height: Sizeconfig.getHeight(context)*0.2,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                 // 10.toSpace,
                  Expanded(
                    flex: 3,
                    child: Container(
                      margin: EdgeInsets.only(top: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        category.name!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            letterSpacing: 0,
                            fontSize: 12,
                            height: 1,
                            fontFamily: Fontconstants.fc_family_sf,
                            fontWeight: Fontconstants.SF_Pro_Display_Bold,
                            color: ColorName.black),
                      ),
                    ),
                  ),
                  // Spacer(),
                  Expanded(
                    flex: 7,
                    child: Container(
                      // height: height - 100,
                      // width: width - 20,
                      child: Center(
                        child: Container(
                          // height: screenheight > 800
                          //     ? screenheight*.080//60//screenheight * .93
                          //     : screenheight * .088,
                          // width: screenwidth > 400
                          //     ? screenwidth * .18
                          //     : screenwidth * .25,
                          alignment: Alignment.bottomCenter,
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Image.file(
                            File(category.image!),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                  ),
                  2.toSpace,
                ],
              ),
/*
              child: Stack(
                children: [
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(5),
                            bottomRight: Radius.circular(5)),
                        // child: SvgPicture.asset(
                        //   Imageconstants.img_categorybackground,
                        //   height: height*0.6,
                        //   width: width,
                        //   fit: BoxFit.fill,
                        // ),
                      )),
                  // Container(
                  //   height: height,
                  //   // color: Colors.amber,
                  //   child:
                  //
                  //   // Image.network(
                  //   //   "assets/images/test${index}.png",
                  //   //   width: width,
                  //   //   fit: BoxFit.fill,
                  //   // ),
                  //
                  //
                  //
                  //   Image.file(
                  //     File(category.image!),
                  //     width: width,
                  //     fit: BoxFit.fill,
                  //   ),
                  // Image.network(
                  //   category.image!,
                  //   width: width,
                  //   fit: BoxFit.fill,
                  // ),

                  Positioned(
                    bottom: 0,
                    child: Container(
                      // height: height - 100,
                      // width: width - 20,
                      child: Center(
                        child: Container(
                          height: screenheight * .08,
                          width: screenwidth * .22,
                          alignment: Alignment.bottomCenter,
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Image.file(
                            File(category.image!),
                            // fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 10,
                    left: 0,
                    child: Container(
                      width: width,
                      child: Center(
                        child: Container(
                          width: width - 10,
                          margin: EdgeInsets.only(right: 4),
                          child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                category.name!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    letterSpacing: 0,
                                    fontSize: 12,
                                    height: 1,
                                    fontFamily: Fontconstants.fc_family_sf,
                                    fontWeight:
                                        Fontconstants.SF_Pro_Display_Bold,
                                    color: ColorName.black),
                              )),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
*/
            ),
          )),
    );
  }

  View_categoryitem9(BuildContext context, var height, int index,
      Category category, List<Category> categoryList, Function callback) {
    var width = Sizeconfig.getWidth(context) / 4;
    var screenwidth = Sizeconfig.getWidth(context);
    var screenheight = Sizeconfig.getHeight(context);
    return GestureDetector(
      onTap: () {
        // Navigator.pushNamed(context, Routes.shop_by_category, arguments: {
        //   "selected_category": category,
        //   "category_list": categoryList
        // }).then((value) {
        //   callback();
        // });
        Navigator.pushNamed(context, Routes.shop_by_category, arguments: {
          "selected_category": category,
          "category_list": categoryList,
          "selected_sub_category": category.subCategories![0]
        }).then((value) {
          callback();
        });
      },
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 1),
          width: width,
          child: Card(
            margin: EdgeInsets.zero,
            elevation: 1,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: ColorName.mediumGrey.withOpacity(0.2), width: 0.5),
              borderRadius: BorderRadius.circular(5),
            ),
            color: Color(0xFFCCE3EC),
            child: Container(
              height: Sizeconfig.getHeight(context)*0.2,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   5.toSpace,
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2,vertical: 2),
                      child: Text(
                        category.name!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            letterSpacing: 0,
                            fontSize: 11,
                            height: 1,
                            fontFamily: Fontconstants.fc_family_sf,
                            fontWeight: Fontconstants.SF_Pro_Display_Bold,
                            color: ColorName.black),
                      ),
                    ),
                  ),
                  // Spacer(),
                  Expanded(
                    flex: 8,
                    child: Container(
                      // height: screenheight > 800
                      //     ? screenheight * .09
                      //     : screenheight * .08,
                      // width:
                      //     screenwidth > 400 ? screenwidth * .22 : screenwidth * .22,
                      // color: Colors.amber,
                      child: Image.file(
                        File(category.image!),
                        width: width,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            /*child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: Sizeconfig.getWidth(context) * 0.3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(),
                        Container(
                          height: height - 90,
                          width: width - 20,
                          // color: Colors.amber,
                          child: Image.file(
                            File(category.image!),
                            width: width,
                            fit: BoxFit.fill,
                          ),
                        ),
                        Container()
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 5,
                  left: 0,
                  child: Container(
                    width: Sizeconfig.getWidth(context) * 0.3,
                    padding: EdgeInsets.symmetric(
                        horizontal: Sizeconfig.getWidth(context) * 0.05),
                    child: Center(
                      child: Container(
                        margin: EdgeInsets.only(right: 4),
                        child: Text(
                          category.name!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              letterSpacing: 0,
                              fontSize: 12,
                              height: 1,
                              fontFamily: Fontconstants.fc_family_sf,
                              fontWeight: Fontconstants.SF_Pro_Display_Bold,
                              color: ColorName.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),*/
          )),
    );
  }

  static StaggerdGridViewNew(
      BuildContext context, List<Category>? categoriesList, Function callback) {
    int length = categoriesList!.length;
    var width = Sizeconfig.getWidth(context);

    int getViewStatus(int index) {
      if (length == 9 && (index == 7 || index == 8)) {
        return 2;
      } else if (length % 4 == 0) {
        // debugPrint("1");
        return 0;
      } else if (length % 4 == 1 && index == 0) {
        // debugPrint("2");

        return 1;
      } else if (length % 4 == 2 && (index == 0 || index == length - 1)) {
        // debugPrint("3");
        return 1;
      } else if (length % 4 == 3 && index == 0) {
        // debugPrint("4");
        return 1;
      } else {
        // debugPrint("5");
        return 0;
      }
    }

    const int itemsPerRow = 4;
    const double ratio = 0.7;
    const double horizontalPadding = 0;

    final double calcHeight = ((width / itemsPerRow) - (horizontalPadding)) *
        (length / itemsPerRow).ceil() *
        (1 / ratio);
    return Container(
      height: calcHeight,
      padding: EdgeInsets.symmetric(horizontal: 9),
      child: StaggeredGridView.countBuilder(
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        itemCount: length,
        itemBuilder: (BuildContext context, int index) {
          if (getViewStatus(index) == 0) {
            return Homewidgetconst().View_categoryitem(
                context,
                Sizeconfig.getHeight(context) * 0.2,
                index,
                categoriesList[index],
                categoriesList, () {
              callback();
            });
          } else if (getViewStatus(index) == 2) {
            return Homewidgetconst().View_singlecategoryitem(
                context,
                Sizeconfig.getHeight(context) * 0.2,
                index,
                categoriesList[index],
                categoriesList, () {
              callback();
            });
          } else {
            return Homewidgetconst().View_singlecategoryitem(
                context,
                Sizeconfig.getHeight(context) * 0.2,
                index,
                categoriesList[index],
                categoriesList, () {
              callback();
            });
          }
        },
        staggeredTileBuilder: (int index) {
          if (getViewStatus(index) == 0) {
            return StaggeredTile.count(1, 1.3);
          } else {
            return StaggeredTile.count(2, 1.3);
          }
        },
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
      ),
    );
  }

  static StaggeredGridViewNew9(
      BuildContext context, List<Category>? categoriesList, Function callback) {
    int length = categoriesList!.length;
    var width = Sizeconfig.getWidth(context);

    int getViewStatus(int index) {
      if (length == 9 && (index == 7 || index == 8)) {
        return 2;
      } else if (length % 3 == 0) {
        return 0;
      } else if (length % 3 == 1 && index == 0) {
        return 1;
      } else if (length % 3 == 2 && (index == 0 || index == length - 1)) {
        return 1;
      } else {
        return 0;
      }
    }

    const int itemsPerRow = 3;
    const double ratio = 0.99;
    const double horizontalPadding = 0;

    final double calcHeight = ((width / itemsPerRow) - (horizontalPadding)) *
        (length / itemsPerRow).ceil() *
        (1 / ratio);

    return Container(
      height: calcHeight,
      padding: EdgeInsets.symmetric(horizontal: 9),
      child: StaggeredGridView.countBuilder(
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 3, // 3 columns for 3x3 grid
        itemCount: length,
        itemBuilder: (BuildContext context, int index) {
          return Homewidgetconst().View_categoryitem9(
              context,
              Sizeconfig.getHeight(context) * 0.2,
              index,
              categoriesList[index],
              categoriesList, () {
            callback();
          });
          /*     if (getViewStatus(index) == 0) {
            return Homewidgetconst().View_categoryitem(
                context,
                Sizeconfig.getHeight(context) * 0.2,
                index,
                categoriesList[index],
                categoriesList, () {
              callback();
            });
          } else {
            return Homewidgetconst().View_singlecategoryitem(
                context,
                Sizeconfig.getHeight(context) * 0.2,
                index,
                categoriesList[index],
                categoriesList, () {
              callback();
            });
          }*/
        },
        staggeredTileBuilder: (int index) {
          return StaggeredTile.count(1, 1); // 1x1 tile for each item
        },
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
      ),
    );
  }

  static topProductList(BuildContext context, List<TopProducts> listTopProducts,
      Function callback) {
    return Container(
      height: Sizeconfig.getHeight(context) * 0.15,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: listTopProducts.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.all(5),
              child: InkWell(
                onTap: () {
                  List<ProductData> list = [];
                  switch (index) {
                    case 0:
                      Navigator.pushNamed(context, Routes.featuredProduct,
                          arguments: {
                            "key": StringContants.lbl_featuredprod,
                            "list": list,
                            "paninatinUrl": ""
                          }).then((value) {
                        callback();
                      });
                      break;

                    case 1:
                      Navigator.pushNamed(context, Routes.featuredProduct,
                          arguments: {
                            "key": StringContants.lbl_heavydis,
                            "list": list,
                            "paninatinUrl": ""
                          }).then((value) {
                        callback();
                      });
                      break;
                    case 2:
                      Navigator.pushNamed(context, Routes.featuredProduct,
                          arguments: {
                            "key": StringContants.lbl_newarr,
                            "list": list,
                            "paninatinUrl": ""
                          }).then((value) {
                        callback();
                      });
                      break;

                    case 3:
                      Navigator.pushNamed(context, Routes.featuredProduct,
                          arguments: {
                            "key": StringContants.lbl_offer_proudct,
                            "list": list,
                            "paninatinUrl": ""
                          }).then((value) {
                        callback();
                      });
                      break;
                  }
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: ColorName.mediumGrey.withOpacity(0.2),
                        width: 0.7),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  elevation: 0.2,
                  color: Colors.white,
                  child: Container(
                    height: Sizeconfig.getHeight(context) * 0.8,
                    width: (Sizeconfig.getWidth(context) / 4) - 19.5,
                    padding: EdgeInsets.only(bottom: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                            flex: 2,
                            child: Container(
                              padding: EdgeInsets.all(9.0),
                              child: Image.asset(
                                listTopProducts[index].imageUrl!,
                                fit: BoxFit.fill,
                              ),
                            )),
                        Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, bottom: 0),
                                child: Text(
                                  listTopProducts[index].name!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      letterSpacing: 0,
                                      fontSize: 12,
                                      fontFamily: Fontconstants.fc_family_sf,
                                      fontWeight:
                                          Fontconstants.SF_Pro_Display_Bold,
                                      color: ColorName.black),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }

  static sublables(String labels) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: Appwidgets.TextRegular(labels, ColorName.darkGrey),
    );
  }

  topSellingList(BuildContext context, List<TopProducts> listTopProducts,
      Function() onscroll, Function closeDialog) {
    int selectedIndex = -1;

    TopSellingBloc bloc = TopSellingBloc();
    CardBloc cardBloc = CardBloc();
    bool isShow = false;
    return BlocProvider(
      create: (context) => bloc,
      child: BlocBuilder<TopSellingBloc, TopSellingState>(
          bloc: bloc,
          builder: (context, state) {
            return Container(
              height: Sizeconfig.getHeight(context) * 0.30,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: listTopProducts.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    if (state is UpdateQuantityState) {
                      if (index == state.index) {
                        listTopProducts[state.index].quantitiy =
                            state.quanitity;
                        isShow = true;
                      }
                    }

                    if (state is AddButtonState) {
                      if (index == state.index) {
                        isShow = true;
                      }
                    }
                    return Padding(
                      padding: EdgeInsets.all(5),
                      child: Card(
                        elevation: 2,
                        color: Colors.white,
                        child: Container(
                          // height: Sizeconfig.getHeight(context)*0.2,
                          width: Sizeconfig.getWidth(context) / 2.8,
                          padding: EdgeInsets.all(4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: Container(
                                    child: Image.asset(
                                        Imageconstants.img_pnchmeva),
                                  )),
                              Expanded(
                                  flex: 4,
                                  child: Container(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Panchmeva - Dry Fruits Mix (405g)",
                                          style: TextStyle(
                                              fontSize: Constants.SizeMidium,
                                              fontFamily:
                                                  Fontconstants.fc_family_sf,
                                              fontWeight: Fontconstants
                                                  .SF_Pro_Display_Medium,
                                              letterSpacing: 0,
                                              color: Colors.black),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "405g",
                                              style: TextStyle(
                                                  fontSize: Constants.SizeSmall,
                                                  fontFamily: Fontconstants
                                                      .fc_family_sf,
                                                  fontWeight: Fontconstants
                                                      .SF_Pro_Display_Medium,
                                                  letterSpacing: 0,
                                                  color: ColorName.textlight),
                                            ),
                                            SizedBox(width: 4),
                                            Icon(
                                              Icons.keyboard_arrow_down,
                                              color: ColorName.watermelonRed,
                                            )
                                            // Image.asset(
                                            //   Imageconstants.img_arrow_down,
                                            //   height: 20,
                                            // )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    Constants.ruppessymbol +
                                                        "519",
                                                    style: TextStyle(
                                                        fontSize:
                                                            Constants.SizeSmall,
                                                        fontFamily:
                                                            Fontconstants
                                                                .fc_family_sf,
                                                        fontWeight: Fontconstants
                                                            .SF_Pro_Display_Medium,
                                                        letterSpacing: 0,
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        decorationColor:
                                                            ColorName.textlight,
                                                        color: ColorName
                                                            .textlight),
                                                  ),
                                                  Text(
                                                    Constants.ruppessymbol +
                                                        "449",
                                                    style: TextStyle(
                                                        fontSize: Constants
                                                            .SizeButton,
                                                        fontFamily:
                                                            Fontconstants
                                                                .fc_family_sf,
                                                        fontWeight: Fontconstants
                                                            .SF_Pro_Display_Medium,
                                                        letterSpacing: 0,
                                                        color: Colors.black),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Container(
                                                    height: 9,
                                                  ),
                                                  listTopProducts[index]
                                                              .quantitiy !=
                                                          0
                                                      ? Align(
                                                          alignment: Alignment
                                                              .bottomRight,
                                                          child: Appwidgets
                                                              .AddQuantityButton(
                                                                  StringContants
                                                                      .lbl_add,
                                                                  listTopProducts[
                                                                          index]
                                                                      .quantitiy!,
                                                                  () {
                                                            //increase

                                                            listTopProducts[
                                                                        index]
                                                                    .quantitiy =
                                                                listTopProducts[
                                                                            index]
                                                                        .quantitiy! +
                                                                    1;
                                                            bloc.add(UpdateQuantityEvent(
                                                                quanitity:
                                                                    listTopProducts[
                                                                            index]
                                                                        .quantitiy!,
                                                                index: index));

                                                            debugPrint(
                                                                "Scroll Event1111 ");

                                                            ShowDialogBottom(
                                                                context, () {
                                                              closeDialog();
                                                            }, cardBloc);
                                                          }, () {
                                                            //decrease

                                                            if (listTopProducts[
                                                                        index]
                                                                    .quantitiy !=
                                                                0) {
                                                              listTopProducts[
                                                                          index]
                                                                      .quantitiy =
                                                                  listTopProducts[
                                                                              index]
                                                                          .quantitiy! -
                                                                      1;
                                                              bloc.add(UpdateQuantityEvent(
                                                                  quanitity: listTopProducts[
                                                                          index]
                                                                      .quantitiy!,
                                                                  index:
                                                                      index));
                                                            }
                                                          }),
                                                        )
                                                      : Align(
                                                          alignment: Alignment
                                                              .bottomRight,
                                                          child: Appwidgets()
                                                              .buttonPrimary(
                                                                  StringContants
                                                                      .lbl_add,
                                                                  () {
                                                            listTopProducts[
                                                                        index]
                                                                    .quantitiy =
                                                                listTopProducts[
                                                                            index]
                                                                        .quantitiy! +
                                                                    1;
                                                            bloc.add(UpdateQuantityEvent(
                                                                quanitity:
                                                                    listTopProducts[
                                                                            index]
                                                                        .quantitiy!,
                                                                index: index));
                                                            ShowDialogBottom(
                                                                context, () {
                                                              closeDialog();
                                                            }, cardBloc);
                                                            selectedIndex =
                                                                index;
                                                            bloc.add(
                                                                AddButtonEvent(
                                                                    index:
                                                                        index));
                                                            onscroll();
                                                          }),
                                                        ),
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            );
          }),
    );
  }

  static ShowDialogBottom(
      BuildContext context, Function closeDialog, CardBloc cardBloc) {
    int count = 0;

    List<ProductUnit> cartitesmList = [];

    showModalBottomSheet(
        elevation: 10,
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(0),
          ),
        ),
        barrierColor: Colors.transparent,
        backgroundColor: Colors.white,
        builder: (BuildContext context) {
          return BlocProvider(
            create: (context) => cardBloc,
            child: BlocBuilder(
                bloc: cardBloc,
                builder: (context, state) {
                  if (state is AddCardState) {
                    count = state.count;
                  }
                  if (state is AddCardProductState) {
                    cartitesmList = state.listProduct;

                    debugPrint(
                        "Cart Items list " + cartitesmList.length.toString());
                  }

                  return Padding(
                    padding: EdgeInsets.only(bottom: 0),
                    child: StatefulBuilder(builder: ((context, setState) {
                      return SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              Container(
                                height: 1,
                                width: Sizeconfig.getWidth(context),
                                color: ColorName.textlight.withOpacity(0.1),
                              ),
                              InkWell(
                                onTap: () {
                                  // Appwidgets.ShowDialogBottom(
                                  //     context, cardBloc, cartitesmList);
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Card(
                                          elevation: 0.1,
                                          color: Colors.white,
                                          child: Container(
                                            padding: EdgeInsets.all(10.0),
                                            child: Image.asset(
                                                height: 40,
                                                Imageconstants.img_flor),
                                          ),
                                        ),
                                        Text(
                                          count.toString() +
                                              " " +
                                              StringContants.lbl_item,
                                          style: Appwidgets()
                                              .commonTextStyle(ColorName.black),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Image.asset(
                                          Imageconstants.img_uparrow,
                                          height: 10,
                                          width: 10,
                                        )
                                      ],
                                    ),
                                    Appwidgets.ButtonSecondary(
                                        StringContants.lbl_next, () {
                                      Navigator.pushNamed(
                                          context, Routes.checkoutscreen);
                                    })
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    })),
                  );
                }),
          );
        }).then((value) {
      closeDialog();

      debugPrint("Close Dialog ");
    });
  }
}
