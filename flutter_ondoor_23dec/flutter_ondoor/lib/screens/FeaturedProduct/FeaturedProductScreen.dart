import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:ondoor/PaginationBloc/pagination_state.dart';
import 'package:ondoor/constants/ImageConstants.dart';
import 'package:ondoor/models/shop_by_category_response.dart';
import 'package:ondoor/screens/AddCard/card_bloc.dart';
import 'package:ondoor/screens/AddCard/card_event.dart';
import 'package:ondoor/screens/HomeScreen/HomeBloc/home_page_bloc.dart';
import 'package:ondoor/screens/NewAnimation/animation_bloc.dart';
import 'package:ondoor/screens/product_detail/product_detail_bloc/product_detail_event.dart';
import 'package:ondoor/screens/shop_by_category/shop_by_category_bloc/shop_by_category_bloc.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/Utility.dart';
import 'package:ondoor/utils/shimmerUi.dart';
import 'package:ondoor/widgets/HomeWidgetConst.dart';
import 'package:ondoor/widgets/common_cached_image_widget.dart';
import 'package:speech_to_text_google_dialog/speech_to_text_google_dialog.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../PaginationBloc/pagination_bloc.dart';
import '../../PaginationBloc/pagination_event.dart';
import '../../constants/Constant.dart';
import '../../constants/CustomTextFormFilled.dart';
import '../../constants/FontConstants.dart';
import '../../constants/StringConstats.dart';
import '../../database/database_helper.dart';
import '../../database/dbconstants.dart';
import '../../models/AllProducts.dart';
import '../../services/ApiServices.dart';
import '../../services/Navigation/routes.dart';
import '../../utils/Commantextwidget.dart';
import '../../utils/Connection.dart';
import '../../utils/SizeConfig.dart';
import '../../utils/colors.dart';
import '../../utils/sharedpref.dart';
import '../../utils/themeData.dart';
import '../../widgets/AppWidgets.dart';
import '../../widgets/MyDialogs.dart';
import '../AddCard/card_state.dart';
import '../HomeScreen/HomeBloc/home_page_event.dart';
import '../HomeScreen/HomeBloc/home_page_state.dart';
import 'FeatuuredBloc/featured_bloc.dart';
import 'FeatuuredBloc/featured_event.dart';
import 'FeatuuredBloc/featured_state.dart';

class FeaturedProductScreen extends StatefulWidget {
  String title;
  List<ProductData> listdata = [];
  String paninatinUrl = "";
  FeaturedProductScreen(
      {super.key,
      required this.title,
      required this.listdata,
      required this.paninatinUrl});

  @override
  State<FeaturedProductScreen> createState() => _FeaturedProductScreenState();
}

class _FeaturedProductScreenState extends State<FeaturedProductScreen> {
  List<ProductData>? list = [];
  List<ProductData>? listTemp = [];
  List<ProductUnit> cardItesmList = [];
  FeaturedBloc bloc = new FeaturedBloc();
  final dbHelper = DatabaseHelper();
  CardBloc cardBloc = CardBloc();
  AnimationBloc animationBloc = AnimationBloc();
  var animationsizebottom = 0.0;
  int isMoreUnitIndex = 0;
  TextEditingController searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);
  List<String> listSearchHitory = [];
  String tag = "";
  bool isGoogleActive = false;
  String bannerProductTitle = "";
  bool isBannerProdcts = false;
  bool isProductNotFound = false;
  bool iskeyboardopen = true;
  bool showWarningMessage = false;
  bool offerAppilied = false;
  HomePageBloc homePageBloc2 = HomePageBloc();
  bool isOpenBottomview = false;
  ScrollController _scrollController = ScrollController();
  int updatedLength = 0;

  bool bottomviewstatus = false;
  PaginationBloc pagebloc = PaginationBloc();
  bool setFlagIntialized = true;

  int pageno = 1;

  String searchData = "";
  bool loadmore = true;

  bool editOrder = false;

  checkEditOrderSearch() async {
    editOrder = await SharedPref.getBooleanPreference("EditOrder");
  }

  closeEditOrderSearch() async {
    await SharedPref.setBooleanPreference("EditOrder", false);
  }

  @override
  void dispose() {
    closeEditOrderSearch();
    super.dispose();
  }

  @override
  void initState() {
    checkEditOrderSearch();

    bloc = FeaturedBloc();
    OndoorThemeData.setStatusBarColor();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      isGoogleActive = await SharedPref.getBooleanPreference(
          Constants.sp_isGoogleSpeechActive);

      debugPrint("isGoogleActive ${isGoogleActive}");

      if (isGoogleActive == true && widget.title == StringContants.lbl_search) {
        SharedPref.setBooleanPreference(
            Constants.sp_isGoogleSpeechActive, false);
        iskeyboardopen = false;
        googleSpeechDialog();
      }

      initializedDb();
      if (widget.title == StringContants.lbl_search) {
        LoadsearchHistory();
      } else if (widget.title == StringContants.lbl_featuredprod) {
        tag = "featured";
        loadProducts();
      } else if (widget.title == StringContants.lbl_heavydis) {
        tag = "heavy_discount";
        loadProducts();
      } else if (widget.title == StringContants.lbl_newarr) {
        tag = "new_arrival";
        loadProducts();
      } else if (widget.title == StringContants.lbl_offer_proudct) {
        tag = "offer_proudct";

        loadProducts();
      } else if (widget.title.contains(StringContants.lbl_bannersprodcut)) {
        tag = widget.title;
        isBannerProdcts = true;
        bannerProductTitle = await SharedPref.getStringPreference(
            Constants.sp_bannerProductTitle);
        debugPrint("BannerTitile ${bannerProductTitle}");
        loadProducts();
      } else {
        // String response = await SharedPref.getStringPreference(Constants.sp_homepageproducts);
        debugPrint("sp_homepageproducts >>> " + widget.listdata.toString());

        if (setFlagIntialized) {
          setFlagIntialized = false;
          listTemp = widget.listdata;
          print("setFlagIntialized IN ${listTemp!.length.toString()}");
        }
        loadmore == true;
        bloc.add(FeaturedEmptyEvent());
        bloc.add(LoadedFeaturedEvent(list: widget.listdata));

        if (widget.listdata.length < 6) {
          pageno = pageno + 1;
          print("SearchProductsGG Scrooll  ****$pageno");

          loadpaginationdata(pageno);
        }
      }

      /*  if (!await Network.isConnected()) {
        MyDialogs.showInternetDialog(context, () {
          Navigator.pop(context);
          bloc.add(LoadingFeaturedEvent(title: tag));
        });
      } else {
        bloc.add(LoadingFeaturedEvent(title: tag));
      }*/
    });

    super.initState();
  }

  loadpaginationdata(int pageno) {
    ApiProvider()
        .getHomeProductPagination(pageno, widget.paninatinUrl)
        .then((value) async {
      print("getHomeProductPagination $value");

      if (value != "") {
        final responseData = jsonDecode(value.toString());

        if (responseData["success"]) {
          debugPrint(
              "getNewHomeProductPagination api call3 ${responseData["success"]}");
          debugPrint("getNewHomeProductPagination Product Listing " + value);

          ProductsModel productsModel =
              ProductsModel.fromJson(value.toString());

          debugPrint("getbeforeYourCheckoutPagination Product Listing " +
              productsModel.data!.length.toString());

          List<ProductData> paginationlist = productsModel.data;

          // featuredBloc.add(ProductListEmptyEvent());

          updatedLength = updatedLength + paginationlist.length;
          pagebloc.add(
              SeeAllForPaginationEvent(list: paginationlist, isAdded: true));
        } else {
          debugPrint(
              "getHomePageProductPagination api call3 ${responseData["success"]}");
          // listProducSummary[index].isLoadMore = false;
          // featuredBloc.add(ProductListEmptyEvent());
          bloc.add(ProductLoadMoreEvent(index: 0, loadmore: false));
          loadmore == false;
          // Fluttertoast.showToast(
          //     msg: "No More Data Found!",
          //     timeInSecForIosWeb: 1,
          //     backgroundColor: ColorName.ColorPrimary,
          //     textColor: Colors.white,
          //     toastLength: Toast.LENGTH_SHORT);
        }
      } else {
        bloc.add(ProductLoadMoreEvent(index: 0, loadmore: false));
      }
    });
  }

  loadProducts() async {
    if (widget.title == StringContants.lbl_featuredprod) {
      tag = "featured";
    } else if (widget.title == StringContants.lbl_heavydis) {
      tag = "heavy_discount";
    } else if (widget.title == StringContants.lbl_newarr) {
      tag = "new_arrival";
    } else if (widget.title.contains(StringContants.lbl_bannersprodcut)) {
      tag = widget.title;
      isBannerProdcts = true;
      bannerProductTitle =
          await SharedPref.getStringPreference(Constants.sp_bannerProductTitle);
      debugPrint("BannerTitile ${bannerProductTitle}");
    }

    if (!await Network.isConnected()) {
      MyDialogs.showInternetDialog(context, () {
        Navigator.pop(context);
        bloc.add(LoadingFeaturedEvent(title: tag));
      });
    } else {
      bloc.add(LoadingFeaturedEvent(title: tag));
    }
  }

  @override
  void _scrollListener() {
    if (_scrollController.offset.toInt() ==
        _scrollController.position.maxScrollExtent.toInt()) {
      // if (loadmore == true) {
      //   cheflist(pageNo, "", "", "", "", "", searchController.text);
      // }

      pageno = pageno + 1;
      print("SearchProducts Scrooll  ****$pageno");
      if (widget.title == StringContants.lbl_search) {
        if (editOrder == false) {
          searchProduct(searchData, pageno);
        }
      } else {
        loadpaginationdata(pageno);
      }
    }
  }

  initializedDb() async {
    cardBloc = CardBloc();
    await dbHelper.init();
    dbHelper.loadAddCardProducts(cardBloc);
  }

  addCard(ProductUnit model) async {
    if (model.addQuantity != 0) {
      animationBloc = AnimationBloc();
      debugPrint("${jsonEncode(model.imageArray)}       >>>>>>>>>>>>>>>>>>");
      String image_array_json = "";

      debugPrint("Image Array .length " + model.imageArray!.length.toString());
      for (int i = 0; i < model!.imageArray!.length; i++) {
        debugPrint("** $i ");
        if (i == 0) {
          image_array_json = model!.imageArray![i].toJson() + "";
        } else {
          image_array_json =
              image_array_json + "," + model!.imageArray![i].toJson();
        }
      }

      if (image_array_json.startsWith(',')) {
        image_array_json = image_array_json.substring(1);
      }
      image_array_json = '[${image_array_json}]';

      bool isSubProductAvailable = false;

      if (model!.cOfferId != 0 && model.cOfferId != null) {
        debugPrint("SubProduct Json >>>${model.subProduct!.toJson()}");
        isSubProductAvailable = true;
      }

      debugPrint("Moodel to Add " + image_array_json);
      debugPrint(
          "Moodel to SubProduct ${isSubProductAvailable ? model.subProduct!.toJson() : ""}");

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

      debugPrint("Add Card Status $status");

      cardBloc.add(AddCardEvent(count: status));
      dbHelper.loadAddCardProducts(cardBloc);
    }
  }

  updateCard(ProductUnit model) async {
    int status = await dbHelper.updateCard({
      DBConstants.PRODUCT_ID: int.parse(model.productId!),
      DBConstants.QUANTITY: model.addQuantity,
    });

    dbHelper.loadAddCardProducts(cardBloc);
  }

  Future<bool> checkItemId(String id) async {
    final allRows = await dbHelper.queryAllRowsCardProducts();
    for (final row in allRows) {
      String id2 = row[DBConstants.PRODUCT_ID].toString();

      if (id == id2) {
        return true;
      }
    }
    return false;
  }

  Future<int> getCartQuantity(String id) async {
    final allRows = await dbHelper.queryAllRowsCardProducts();
    for (final row in allRows) {
      String id2 = row[DBConstants.PRODUCT_ID].toString();

      if (id == id2) {
        return row[DBConstants.QUANTITY];
      }
    }
    return 0;
  }

  Widget categoryItemView(BuildContext context, ProductUnit model,
      dynamic state, int index, bool isMoreUnit, int lenght, bool loadstatus) {
    debugPrint("categoryItemViewModel ${jsonEncode(model.discountText)}");
    debugPrint("categoryItemViewModel ${model.cOfferId != null}");
    debugPrint("categoryItemViewModel ${bloc.state}");

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
        //  if (x.selectedUnitIndex > 0)
        if (x.isselectUnit) {
          model = x;
        }
      }
    }

    return GestureDetector(
      onTap: () async {
        for (int i = 0; i < list![index].unit!.length!; i++) {
          debugPrint("Model  ${model.productId} ${model.addQuantity} ");
          if (model.productId == list![index].unit![i].productId!) {
            list![index].unit![i] = model;
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
            'index': isMoreUnit ? isMoreUnitIndex : index,
          },
        ).then((value) async {
          ProductUnit unit = value as ProductUnit;
          debugPrint("FeatureCallback ${value.addQuantity}");
          OndoorThemeData.setStatusBarColor();
          bloc.add(ProductUpdateQuantityEvent(
              quanitity: unit.addQuantity!, index: index));
          initializedDb();
        });
      },
      child: Container(
        //   height:
        //   (model!.cOfferId != 0 &&
        //       model.cOfferId != null &&
        //       model.subProduct != null &&
        //       (showWarningMessage != false || offerAppilied != false))?
        // Sizeconfig.getHeight(context) * 0.16:
        //       Sizeconfig.getWidth(context) * .27,

        child: Column(
          children: [
            // (model!.cOfferId != 0 &&
            //         model.cOfferId != null &&
            //         model.subProduct != null &&
            //         (showWarningMessage != false || offerAppilied != false))
            //     ? Container(
            //         height: Sizeconfig.getHeight(context) * 0.15,
            //         margin: EdgeInsets.symmetric(horizontal: 8),
            //         padding: EdgeInsets.only(bottom: 1),
            //         decoration: BoxDecoration(
            //           color: showWarningMessage
            //               ? Colors.red.shade400
            //               : Colors.green,
            //           borderRadius: BorderRadius.circular(5),
            //           border: Border.all(color: ColorName.lightGey),
            //         ),
            //         child: Column(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: [
            //             Container(),
            //             Column(
            //               children: [
            //                 showWarningMessage == false
            //                     ? Container()
            //                     : Container(
            //                         width: Sizeconfig.getWidth(context),
            //                         decoration: BoxDecoration(
            //                             color: Colors.red.shade400,
            //                             borderRadius: BorderRadius.all(
            //                                 Radius.circular(10.0))),
            //                         padding: EdgeInsets.symmetric(
            //                             vertical: 4, horizontal: 10),
            //                         alignment: Alignment.center,
            //                         child: Marquee(
            //                           pauseDuration: Duration(milliseconds: 0),
            //                           directionMarguee:
            //                               DirectionMarguee.oneDirection,
            //                           autoRepeat: true,
            //                           backwardAnimation: Curves.easeOut,
            //                           child: Text(
            //                             warningtitle.replaceAll(
            //                                 "@#\$", "${remainingQuanityt}"),
            //                             maxLines: 1,
            //                             style: TextStyle(
            //                                 fontSize: Constants.Size_10,
            //                                 fontFamily:
            //                                     Fontconstants.fc_family_sf,
            //                                 fontWeight: Fontconstants
            //                                     .SF_Pro_Display_Medium,
            //                                 color: Colors.white),
            //                           ),
            //                         )),
            //                 Visibility(
            //                   visible: offerAppilied,
            //                   child: Container(
            //                       width: Sizeconfig.getWidth(context),
            //                       // margin: EdgeInsets.symmetric(
            //                       //     horizontal: 10, vertical: 10),
            //                       decoration: BoxDecoration(),
            //                       child: Marquee(
            //                         pauseDuration: Duration(milliseconds: 0),
            //                         directionMarguee:
            //                             DirectionMarguee.oneDirection,
            //                         autoRepeat: true,
            //                         backwardAnimation: Curves.easeOut,
            //                         child: Row(
            //                           mainAxisAlignment:
            //                               MainAxisAlignment.center,
            //                           children: [
            //                             Container(
            //                               margin: EdgeInsets.only(
            //                                   left: 5, bottom: 2),
            //                               child: Image.asset(
            //                                 Imageconstants.img_offer,
            //                                 height: 15,
            //                                 width: 15,
            //                                 color: Colors.white,
            //                               ),
            //                             ),
            //                             SizedBox(
            //                               width: 3,
            //                             ),
            //                             Container(
            //                               padding: EdgeInsets.only(bottom: 5),
            //                               child: Text(
            //                                 applied.replaceAll("@#\$",
            //                                     buy_quantity.toString()),
            //                                 style: TextStyle(
            //                                     fontSize: Constants.Size_10,
            //                                     fontFamily:
            //                                         Fontconstants.fc_family_sf,
            //                                     fontWeight: Fontconstants
            //                                         .SF_Pro_Display_Medium,
            //                                     color: Colors.white),
            //                               ),
            //                             )
            //                           ],
            //                         ),
            //                       )),
            //                 ),
            //               ],
            //             )
            //           ],
            //         ))
            //     : Container(),
            IntrinsicHeight(
              child: Stack(
                children: [
                  Container(
                    key: Key(model.productId!),

                    // height: Sizeconfig.getWidth(context) * .27,

                    padding:
                        EdgeInsets.only(top: 0, bottom: 0, left: 5, right: 6),
                    // margin: EdgeInsets.symmetric(horizontal: 8),
                    margin: (model.cOfferId != 0 &&
                            model.cOfferId != null &&
                            model.subProduct != null &&
                            (showWarningMessage != false ||
                                offerAppilied != false))
                        ? EdgeInsets.only(left: 8, right: 8, top: 0)
                        : EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    decoration: BoxDecoration(
                      color: ColorName.ColorBagroundPrimary,

                      borderRadius: (model.cOfferId != 0 &&
                              model.cOfferId != null &&
                              model.subProduct != null &&
                              (showWarningMessage != false ||
                                  offerAppilied != false))
                          ? BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(5))
                          : BorderRadius.circular(5),
                      // border: Border.all(color: ColorName.lightGey),
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
                                flex: 3,
                                child: Container(
                                  height: Sizeconfig.getWidth(context) * .31,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(),
                                      Container(
                                        child: Center(
                                          child: Stack(
                                            children: [
                                              Center(
                                                child: Container(
                                                  child:
                                                      CommonCachedImageWidget(
                                                    imgUrl: model.image!,
                                                    width: Sizeconfig.getWidth(
                                                            context) *
                                                        .22,
                                                    height: Sizeconfig.getWidth(
                                                            context) *
                                                        .25,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container()
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 7,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 7, horizontal: 5),
                                  height: Sizeconfig.getWidth(context) * .32,
                                  child: Column(
                                    mainAxisAlignment: (model!.cOfferId != 0 &&
                                            model.cOfferId != null)
                                        ? MainAxisAlignment.spaceBetween
                                        : MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        // width:
                                        //     Sizeconfig.getWidth(context) * 0.40,
                                        margin: EdgeInsets.only(top: 2),
                                        child:

                                            //     Text(
                                            //   model.name!,
                                            //   maxLines: 2,
                                            //   style: TextStyle(
                                            //     fontSize: 12,
                                            //     fontFamily:
                                            //         Fontconstants.fc_family_sf,
                                            //     fontWeight: Fontconstants
                                            //         .SF_Pro_Display_SEMIBOLD,
                                            //     color: Colors.black,
                                            //   ),
                                            // ),
                                            CommanTextWidget.regularBold(
                                          model.name!,
                                          Colors.black,
                                          maxline: 2,
                                          trt: TextStyle(
                                            fontSize: 14,
                                            height: 1.215,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textalign: TextAlign.start,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(top: 4),
                                            child: InkWell(
                                              onTap: () {
                                                if (isMoreUnit) {
                                                  MyDialogs.optionDialog(
                                                          context,
                                                          list![index].unit!,
                                                          model)
                                                      .then((value) {
                                                    isMoreUnitIndex = list![
                                                            index]
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
                                                                .isselectUnit =
                                                            true;
                                                        value.isselectUnit =
                                                            true;
                                                      } else {
                                                        list![index]
                                                                .unit![i]
                                                                .isselectUnit =
                                                            false;
                                                      }
                                                    }

                                                    bloc.add(ProductChangeEvent(
                                                        model: value));
                                                  });
                                                }
                                              },
                                              child: isMoreUnit
                                                  ? Container(
                                                      height: 20,
                                                      width:
                                                          Sizeconfig.getWidth(
                                                                  context) *
                                                              0.23,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          4.0)),
                                                          border: Border.all(
                                                              width: 0.6,
                                                              color: ColorName
                                                                  .border
                                                                  .withOpacity(
                                                                      0.5))),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          2.toSpace,
                                                          Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          0),
                                                              child: CommanTextWidget
                                                                  .regularBold(
                                                                model.productWeight
                                                                        .toString() +
                                                                    " ${model.productWeightUnit}",
                                                                ColorName
                                                                    .textsecondary,
                                                                maxline: 2,
                                                                trt: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                                textalign:
                                                                    TextAlign
                                                                        .start,
                                                              )),
                                                          5.toSpace,
                                                          Visibility(
                                                              visible:
                                                                  isMoreUnit,
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: ColorName
                                                                      .ColorPrimary,
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              4.0)),
                                                                ),
                                                                width: 20,
                                                                height: 20,
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(5),
                                                                child:
                                                                    Image.asset(
                                                                  Imageconstants
                                                                      .img_dropdownarrow,
                                                                  color: Colors
                                                                      .white,
                                                                  height: 10,
                                                                  width: 10,
                                                                ),
                                                              ))
                                                        ],
                                                      ),
                                                    )
                                                  : CommanTextWidget
                                                      .regularBold(
                                                      model.productWeight
                                                              .toString() +
                                                          " ${model.productWeightUnit}",
                                                      ColorName.textsecondary,
                                                      maxline: 2,
                                                      trt: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      textalign:
                                                          TextAlign.start,
                                                    ),
                                            ),
                                          ),
                                          Container()
                                        ],
                                      ),

                                      /*    Container(
                                        margin: EdgeInsets.only(
                                            top: (model!.cOfferId != 0 &&
                                                    model.cOfferId != null)
                                                ? 0
                                                : 5),
                                        child: InkWell(
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
                                                    "Dialog value ${isMoreUnitIndex} ${index} ${value.name} ");

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
                                                // bloc.add(FeaturedEmptyEvent());
                                                // bloc.add(ProductUnitUpddate());
                                              });
                                            }
                                          },
                                          child: Container(
                                            child: Container(
                                              width:
                                                  Sizeconfig.getWidth(context) *
                                                      .20,
                                              padding:
                                                  EdgeInsets.only(right: 0),
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
                                                            Constants.Size_10,
                                                        fontFamily:
                                                            Fontconstants
                                                                .fc_family_sf,
                                                        fontWeight: Fontconstants
                                                            .SF_Pro_Display_Bold,
                                                        color: isMoreUnit
                                                            ? ColorName.black
                                                            : ColorName
                                                                .textsecondary,
                                                      ),
                                                    ),
                                                    Visibility(
                                                        visible: isMoreUnit,
                                                        child: Container(
                                                          width: 10,
                                                          height: 10,
                                                          margin:
                                                              EdgeInsets.only(
                                                                  right: 10),
                                                          child: Image.asset(
                                                            Imageconstants
                                                                .img_filldropdown,
                                                              color: ColorName.textsecondary,
                                                          ),
                                                        ))
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),*/

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
                                                      subproducts!
                                                          .cOfferApplied;
                                                  subproduct.offerProductId =
                                                      subproducts!
                                                          .offerProductId;
                                                  subproduct.offerWarning =
                                                      subproducts!.offerWarning;
                                                  List<ProductUnit>?
                                                      subProductDetail = [];
                                                  for (var x in subproducts!
                                                      .subProductDetail!) {
                                                    ProductUnit y =
                                                        ProductUnit();
                                                    y.productId = x.productId;
                                                    y.quantity = x.quantity;
                                                    y.image = x.image;
                                                    y.price = x.specialPrice;
                                                    y.subProduct = x.subProduct;
                                                    y.model = x.model;
                                                    y.name = x.name;

                                                    subProductDetail.add(y);
                                                  }
                                                  subproduct.subProductDetail =
                                                      subProductDetail;
                                                  subProductsDetailsList[i]
                                                      .subProduct = subproduct;
                                                  subProductsDetailsList[i]
                                                          .subProduct!
                                                          .buyQty =
                                                      model!.subProduct!.buyQty;
                                                  subProductsDetailsList[i]
                                                          .cOfferId =
                                                      model.cOfferId;
                                                  subProductsDetailsList[i]
                                                          .discountLabel =
                                                      model.discountLabel;
                                                  subProductsDetailsList[i]
                                                          .discountText =
                                                      model.discountText;
                                                  subProductsDetailsList[i]
                                                          .cOfferType =
                                                      model.cOfferType;
                                                  debugPrint("GGGGGG" +
                                                      model.subProduct!
                                                          .cOfferInfo!);
                                                  debugPrint("GGGGGGGG" +
                                                      subProductsDetailsList[i]
                                                          .subProduct!
                                                          .cOfferInfo!);
                                                }

                                                Appwidgets.showSubProductsOffer(
                                                    int.parse(model!.subProduct!
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
                                                    ShopByCategoryBloc(), () {
                                                  debugPrint(
                                                      'Refresh call >>  ');

                                                  // loadFeatureProduct();
                                                  // searchProduct(searchController.text);
                                                }, (value) {});
                                              },
                                              child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 4),
                                                  width: 66,
                                                  decoration: BoxDecoration(
                                                      color: ColorName.darkBlue,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Row(
                                                    children: [
                                                      Image.asset(
                                                        Imageconstants
                                                            .img_offer,
                                                        height: 12,
                                                        width: 12,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Appwidgets.TextRegular(
                                                          "Offers",
                                                          Colors.white),
                                                    ],
                                                  )))
                                          : Container(),

                                      SizedBox(
                                        height: 8,
                                      ),

                                      // ),

                                      Row(
                                        children: [
                                          CommanTextWidget.regularBold(
                                            model.specialPrice == ""
                                                ? ""
                                                : "₹${double.parse(model.price!).toStringAsFixed(2)}",
                                            ColorName.textsecondary,
                                            maxline: 2,
                                            trt: TextStyle(
                                              fontSize: 10,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              decorationColor:
                                                  ColorName.textsecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textalign: TextAlign.start,
                                          ),
                                          5.toSpace,

                                          // Visibility(
                                          //   visible: model.specialPrice != "",
                                          //   child: SizedBox(
                                          //     height: 0,
                                          //   ),
                                          // ),
                                          CommanTextWidget.regularBold(
                                            model.specialPrice == ""
                                                ? "₹ ${double.parse(model.sortPrice!).toStringAsFixed(2)}"
                                                : "₹ ${double.parse(model.specialPrice!).toStringAsFixed(2)}",
                                            Colors.black,
                                            maxline: 2,
                                            trt: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
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
                          ),
                        ],
                      ),
                    ),
                  ),
                  (model.discountText ?? "") == ""
                      ? Container()
                      : Visibility(
                          visible: (model!.discountText != "" ||
                              model!.discountText != null),
                          child: Positioned(
                            left: 8,
                            top: 0,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(5.0)),
                                  child: Image.asset(
                                    Imageconstants.img_tag,
                                    height: 37,
                                    width: 35,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    model.discountText ?? "",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: const TextStyle(
                                      color: ColorName.black,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  Positioned(
                    right: 15,
                    bottom: 10,
                    child: Center(
                      child: Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Container(
                                width: Sizeconfig.getWidth(context) * 0.18,
                                margin: EdgeInsets.only(top: 5),
                                child: model.addQuantity != 0
                                    ? Container(
                                        alignment: Alignment.bottomRight,
                                        child: Appwidgets.AddQuantityButton(
                                            StringContants.lbl_add,
                                            model.addQuantity! as int, () {
                                          //increase

                                          if (model.addQuantity ==
                                              int.parse(model.orderQtyLimit!
                                                  .toString())) {
                                            Fluttertoast.showToast(
                                                msg: StringContants
                                                    .msg_quanitiy);
                                          } else {
                                            model.addQuantity =
                                                model.addQuantity + 1;
                                            bloc.add(ProductUpdateQuantityEvent(
                                                quanitity: model.addQuantity!,
                                                index: index));
                                            bloc.add(ProductChangeEvent(
                                                model: model));
                                            updateCard(model);
                                            debugPrint("Scroll Event1111 ");
                                          }
                                        }, () async {
                                          //decrease

                                          if (model.addQuantity != 0) {
                                            model.addQuantity =
                                                model.addQuantity - 1;

                                            bloc.add(ProductUpdateQuantityEvent(
                                                quanitity: model.addQuantity!,
                                                index: index));

                                            updateCard(model);

                                            if (model.addQuantity == 0) {
                                              await dbHelper
                                                  .deleteCard(int.parse(
                                                      model.productId!))
                                                  .then((value) {
                                                debugPrint(
                                                    "Delete Product $value ");

                                                cardBloc.add(CardDeleteEvent(
                                                    model: model,
                                                    listProduct:
                                                        list![0].unit!));
                                                dbHelper.loadAddCardProducts(
                                                    cardBloc);

                                                if (list![0].unit!.length ==
                                                    0) {
                                                  cardBloc
                                                      .add(CardEmptyEvent());
                                                }

                                                bloc.add(
                                                    ProductUpdateQuantityEvent(
                                                        quanitity:
                                                            model.addQuantity!,
                                                        index: index));

                                                updateCard(model);
                                              });
                                            }
                                            bloc.add(ProductChangeEvent(
                                                model: model));
                                          }
                                        }),
                                      )
                                    : Appwidgets().buttonPrimary(
                                        StringContants.lbl_add,
                                        () {
                                          debugPrint("GGGGGGGSSS " +
                                              cardItesmList.length.toString());

                                          model.addQuantity =
                                              model.addQuantity + 1;
                                          checkItemId(model.productId!)
                                              .then((value) {
                                            debugPrint("CheckItemId $value");

                                            if (value == false) {
                                              addCard(model);
                                            } else {
                                              updateCard(model);
                                            }
                                          });

                                          bloc.add(ProductUpdateQuantityEvent(
                                              quanitity: model.addQuantity!,
                                              index: index));
                                          bloc.add(
                                              ProductChangeEvent(model: model));
                                        },
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
            (model.cOfferId != 0 &&
                    model.cOfferId != null &&
                    model.subProduct != null &&
                    (showWarningMessage != false || offerAppilied != false))
                ? Container(
                    width: Sizeconfig.getWidth(context),
                    margin: EdgeInsets.only(right: 8, left: 8, bottom: 0),
                    padding: EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: showWarningMessage
                          ? Colors.red.shade400
                          : Colors.green,
                      borderRadius: (model.cOfferId != 0 &&
                              model.cOfferId != null &&
                              model.subProduct != null &&
                              (showWarningMessage != false ||
                                  offerAppilied != false))
                          ? BorderRadius.only(
                              bottomLeft: Radius.circular(5),
                              bottomRight: Radius.circular(5))
                          : BorderRadius.circular(5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(),
                        Column(
                          children: [
                            showWarningMessage == false
                                ? SizedBox.shrink()
                                : Container(
                                    width: Sizeconfig.getWidth(context),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2, horizontal: 10),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        Imageconstants.img_offer,
                                        height: 15,
                                        width: 15,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: 3,
                                      ),
                                      Container(
                                        width:
                                            Sizeconfig.getWidth(context) * 0.5,
                                        child: Text(
                                          applied.replaceAll(
                                              "@#\$", buy_quantity.toString()),
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
                : const SizedBox.shrink(),
            // SizedBox(
            //   height: spacingWidgetForList(list!.length - 1, index),
            // ),
            loadmore == false
                ? Container()
                : (index == list!.length - 1) && loadmore && list!.length > 5
                    ? Column(
                        children: [
                          SizedBox(
                            height: 25,
                          ),
                          Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              height: 30,
                              width: 30,
                              child: CircularProgressIndicator(
                                color: ColorName.ColorPrimary,
                              )),
                          SizedBox(
                            height: 50,
                          ),
                        ],
                      )
                    : (index == list!.length - 1)
                        ? Container(
                            height: 80,
                          )
                        : Container()
          ],
        ),
      ),
    );
  }

  Widget categoryItemView2222(BuildContext context, ProductUnit model,
      dynamic state, int index, bool isMoreUnit, int lenght, bool loadstatus) {
    debugPrint("categoryItemViewModel ${jsonEncode(model.discountText)}");
    debugPrint("categoryItemViewModel ${model.cOfferId != null}");
    debugPrint("categoryItemViewModel ${bloc.state}");

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
        //  if (x.selectedUnitIndex > 0)
        if (x.isselectUnit) {
          model = x;
        }
      }
    }

    return GestureDetector(
      onTap: () async {
        for (int i = 0; i < list![index].unit!.length!; i++) {
          debugPrint("Model  ${model.productId} ${model.addQuantity} ");
          if (model.productId == list![index].unit![i].productId!) {
            list![index].unit![i] = model;
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
            'index': isMoreUnit ? isMoreUnitIndex : index,
          },
        ).then((value) async {
          ProductUnit unit = value as ProductUnit;
          debugPrint("FeatureCallback ${value.addQuantity}");
          OndoorThemeData.setStatusBarColor();
          bloc.add(ProductUpdateQuantityEvent(
              quanitity: unit.addQuantity!, index: index));
          initializedDb();
        });
      },
      child: Container(
        //   height:
        //   (model!.cOfferId != 0 &&
        //       model.cOfferId != null &&
        //       model.subProduct != null &&
        //       (showWarningMessage != false || offerAppilied != false))?
        // Sizeconfig.getHeight(context) * 0.16:
        //       Sizeconfig.getWidth(context) * .27,

        child: Column(
          children: [
            // (model!.cOfferId != 0 &&
            //         model.cOfferId != null &&
            //         model.subProduct != null &&
            //         (showWarningMessage != false || offerAppilied != false))
            //     ? Container(
            //         height: Sizeconfig.getHeight(context) * 0.15,
            //         margin: EdgeInsets.symmetric(horizontal: 8),
            //         padding: EdgeInsets.only(bottom: 1),
            //         decoration: BoxDecoration(
            //           color: showWarningMessage
            //               ? Colors.red.shade400
            //               : Colors.green,
            //           borderRadius: BorderRadius.circular(5),
            //           border: Border.all(color: ColorName.lightGey),
            //         ),
            //         child: Column(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: [
            //             Container(),
            //             Column(
            //               children: [
            //                 showWarningMessage == false
            //                     ? Container()
            //                     : Container(
            //                         width: Sizeconfig.getWidth(context),
            //                         decoration: BoxDecoration(
            //                             color: Colors.red.shade400,
            //                             borderRadius: BorderRadius.all(
            //                                 Radius.circular(10.0))),
            //                         padding: EdgeInsets.symmetric(
            //                             vertical: 4, horizontal: 10),
            //                         alignment: Alignment.center,
            //                         child: Marquee(
            //                           pauseDuration: Duration(milliseconds: 0),
            //                           directionMarguee:
            //                               DirectionMarguee.oneDirection,
            //                           autoRepeat: true,
            //                           backwardAnimation: Curves.easeOut,
            //                           child: Text(
            //                             warningtitle.replaceAll(
            //                                 "@#\$", "${remainingQuanityt}"),
            //                             maxLines: 1,
            //                             style: TextStyle(
            //                                 fontSize: Constants.Size_10,
            //                                 fontFamily:
            //                                     Fontconstants.fc_family_sf,
            //                                 fontWeight: Fontconstants
            //                                     .SF_Pro_Display_Medium,
            //                                 color: Colors.white),
            //                           ),
            //                         )),
            //                 Visibility(
            //                   visible: offerAppilied,
            //                   child: Container(
            //                       width: Sizeconfig.getWidth(context),
            //                       // margin: EdgeInsets.symmetric(
            //                       //     horizontal: 10, vertical: 10),
            //                       decoration: BoxDecoration(),
            //                       child: Marquee(
            //                         pauseDuration: Duration(milliseconds: 0),
            //                         directionMarguee:
            //                             DirectionMarguee.oneDirection,
            //                         autoRepeat: true,
            //                         backwardAnimation: Curves.easeOut,
            //                         child: Row(
            //                           mainAxisAlignment:
            //                               MainAxisAlignment.center,
            //                           children: [
            //                             Container(
            //                               margin: EdgeInsets.only(
            //                                   left: 5, bottom: 2),
            //                               child: Image.asset(
            //                                 Imageconstants.img_offer,
            //                                 height: 15,
            //                                 width: 15,
            //                                 color: Colors.white,
            //                               ),
            //                             ),
            //                             SizedBox(
            //                               width: 3,
            //                             ),
            //                             Container(
            //                               padding: EdgeInsets.only(bottom: 5),
            //                               child: Text(
            //                                 applied.replaceAll("@#\$",
            //                                     buy_quantity.toString()),
            //                                 style: TextStyle(
            //                                     fontSize: Constants.Size_10,
            //                                     fontFamily:
            //                                         Fontconstants.fc_family_sf,
            //                                     fontWeight: Fontconstants
            //                                         .SF_Pro_Display_Medium,
            //                                     color: Colors.white),
            //                               ),
            //                             )
            //                           ],
            //                         ),
            //                       )),
            //                 ),
            //               ],
            //             )
            //           ],
            //         ))
            //     : Container(),
            IntrinsicHeight(
              child: Stack(
                children: [
                  Container(
                    key: Key(model.productId!),

                    // height: Sizeconfig.getWidth(context) * .27,

                    padding:
                        EdgeInsets.only(top: 0, bottom: 0, left: 5, right: 6),
                    // margin: EdgeInsets.symmetric(horizontal: 8),
                    margin: (model.cOfferId != 0 &&
                            model.cOfferId != null &&
                            model.subProduct != null &&
                            (showWarningMessage != false ||
                                offerAppilied != false))
                        ? EdgeInsets.only(left: 8, right: 8, top: 0)
                        : EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    decoration: BoxDecoration(
                      color: ColorName.ColorBagroundPrimary,

                      borderRadius: (model.cOfferId != 0 &&
                              model.cOfferId != null &&
                              model.subProduct != null &&
                              (showWarningMessage != false ||
                                  offerAppilied != false))
                          ? BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(5))
                          : BorderRadius.circular(5),
                      // border: Border.all(color: ColorName.lightGey),
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
                                flex: 2,
                                child: Container(
                                  height: Sizeconfig.getWidth(context) * .25,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(),
                                      Container(
                                        child: Center(
                                          child: Stack(
                                            children: [
                                              Center(
                                                child: Container(
                                                  child:
                                                      CommonCachedImageWidget(
                                                    imgUrl: model.image!,
                                                    width: Sizeconfig.getWidth(
                                                            context) *
                                                        .15,
                                                    height: Sizeconfig.getWidth(
                                                            context) *
                                                        .18,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container()
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 5),
                                  height: Sizeconfig.getWidth(context) * .25,
                                  child: Column(
                                    mainAxisAlignment: (model!.cOfferId != 0 &&
                                            model.cOfferId != null)
                                        ? MainAxisAlignment.spaceBetween
                                        : MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width:
                                            Sizeconfig.getWidth(context) * 0.40,
                                        margin: EdgeInsets.only(top: 2),
                                        child:

                                            //     Text(
                                            //   model.name!,
                                            //   maxLines: 2,
                                            //   style: TextStyle(
                                            //     fontSize: 12,
                                            //     fontFamily:
                                            //         Fontconstants.fc_family_sf,
                                            //     fontWeight: Fontconstants
                                            //         .SF_Pro_Display_SEMIBOLD,
                                            //     color: Colors.black,
                                            //   ),
                                            // ),
                                            CommanTextWidget.regularBold(
                                          model.name!,
                                          Colors.black,
                                          maxline: 2,
                                          trt: TextStyle(
                                            fontSize: 14,
                                            height: 1.215,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          textalign: TextAlign.start,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(top: 4),
                                            child: InkWell(
                                              onTap: () {
                                                if (isMoreUnit) {
                                                  MyDialogs.optionDialog(
                                                          context,
                                                          list![index].unit!,
                                                          model)
                                                      .then((value) {
                                                    isMoreUnitIndex = list![
                                                            index]
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
                                                                .isselectUnit =
                                                            true;
                                                        value.isselectUnit =
                                                            true;
                                                      } else {
                                                        list![index]
                                                                .unit![i]
                                                                .isselectUnit =
                                                            false;
                                                      }
                                                    }

                                                    bloc.add(ProductChangeEvent(
                                                        model: value));
                                                  });
                                                }
                                              },
                                              child: isMoreUnit
                                                  ? Container(
                                                      height: 20,
                                                      width:
                                                          Sizeconfig.getWidth(
                                                                  context) *
                                                              0.22,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          4.0)),
                                                          border: Border.all(
                                                              width: 0.6,
                                                              color: ColorName
                                                                  .border
                                                                  .withOpacity(
                                                                      0.5))),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          2.toSpace,
                                                          Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          0),
                                                              child: CommanTextWidget
                                                                  .regularBold(
                                                                model.productWeight
                                                                        .toString() +
                                                                    " ${model.productWeightUnit}",
                                                                ColorName
                                                                    .textsecondary,
                                                                maxline: 2,
                                                                trt: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                                textalign:
                                                                    TextAlign
                                                                        .start,
                                                              )),
                                                          5.toSpace,
                                                          Visibility(
                                                              visible:
                                                                  isMoreUnit,
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: ColorName
                                                                      .ColorPrimary,
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              4.0)),
                                                                ),
                                                                width: 20,
                                                                height: 20,
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(5),
                                                                child:
                                                                    Image.asset(
                                                                  Imageconstants
                                                                      .img_dropdownarrow,
                                                                  color: Colors
                                                                      .white,
                                                                  height: 10,
                                                                  width: 10,
                                                                ),
                                                              ))
                                                        ],
                                                      ),
                                                    )
                                                  : CommanTextWidget
                                                      .regularBold(
                                                      model.productWeight
                                                              .toString() +
                                                          " ${model.productWeightUnit}",
                                                      ColorName.textsecondary,
                                                      maxline: 2,
                                                      trt: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      textalign:
                                                          TextAlign.start,
                                                    ),
                                            ),
                                          ),
                                          Container()
                                        ],
                                      ),

                                      /*    Container(
                                        margin: EdgeInsets.only(
                                            top: (model!.cOfferId != 0 &&
                                                    model.cOfferId != null)
                                                ? 0
                                                : 5),
                                        child: InkWell(
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
                                                    "Dialog value ${isMoreUnitIndex} ${index} ${value.name} ");

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
                                                // bloc.add(FeaturedEmptyEvent());
                                                // bloc.add(ProductUnitUpddate());
                                              });
                                            }
                                          },
                                          child: Container(
                                            child: Container(
                                              width:
                                                  Sizeconfig.getWidth(context) *
                                                      .20,
                                              padding:
                                                  EdgeInsets.only(right: 0),
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
                                                            Constants.Size_10,
                                                        fontFamily:
                                                            Fontconstants
                                                                .fc_family_sf,
                                                        fontWeight: Fontconstants
                                                            .SF_Pro_Display_Bold,
                                                        color: isMoreUnit
                                                            ? ColorName.black
                                                            : ColorName
                                                                .textsecondary,
                                                      ),
                                                    ),
                                                    Visibility(
                                                        visible: isMoreUnit,
                                                        child: Container(
                                                          width: 10,
                                                          height: 10,
                                                          margin:
                                                              EdgeInsets.only(
                                                                  right: 10),
                                                          child: Image.asset(
                                                            Imageconstants
                                                                .img_filldropdown,
                                                              color: ColorName.textsecondary,
                                                          ),
                                                        ))
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),*/
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
                                                      subproducts!
                                                          .cOfferApplied;
                                                  subproduct.offerProductId =
                                                      subproducts!
                                                          .offerProductId;
                                                  subproduct.offerWarning =
                                                      subproducts!.offerWarning;
                                                  List<ProductUnit>?
                                                      subProductDetail = [];
                                                  for (var x in subproducts!
                                                      .subProductDetail!) {
                                                    ProductUnit y =
                                                        ProductUnit();
                                                    y.productId = x.productId;
                                                    y.quantity = x.quantity;
                                                    y.image = x.image;
                                                    y.price = x.specialPrice;
                                                    y.subProduct = x.subProduct;
                                                    y.model = x.model;
                                                    y.name = x.name;

                                                    subProductDetail.add(y);
                                                  }
                                                  subproduct.subProductDetail =
                                                      subProductDetail;
                                                  subProductsDetailsList[i]
                                                      .subProduct = subproduct;
                                                  subProductsDetailsList[i]
                                                          .subProduct!
                                                          .buyQty =
                                                      model!.subProduct!.buyQty;
                                                  subProductsDetailsList[i]
                                                          .cOfferId =
                                                      model.cOfferId;
                                                  subProductsDetailsList[i]
                                                          .discountLabel =
                                                      model.discountLabel;
                                                  subProductsDetailsList[i]
                                                          .discountText =
                                                      model.discountText;
                                                  subProductsDetailsList[i]
                                                          .cOfferType =
                                                      model.cOfferType;
                                                  debugPrint("GGGGGG" +
                                                      model.subProduct!
                                                          .cOfferInfo!);
                                                  debugPrint("GGGGGGGG" +
                                                      subProductsDetailsList[i]
                                                          .subProduct!
                                                          .cOfferInfo!);
                                                }

                                                Appwidgets.showSubProductsOffer(
                                                    int.parse(model!.subProduct!
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
                                                    ShopByCategoryBloc(), () {
                                                  debugPrint(
                                                      'Refresh call >>  ');

                                                  // loadFeatureProduct();
                                                  // searchProduct(searchController.text);
                                                }, (value) {});
                                              },
                                              child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 4),
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                      color: ColorName.darkBlue,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Row(
                                                    children: [
                                                      Image.asset(
                                                        Imageconstants
                                                            .img_offer,
                                                        height: 12,
                                                        width: 12,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Appwidgets.TextRegular(
                                                          "Offers",
                                                          Colors.white),
                                                    ],
                                                  )))
                                          : Container(),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                  flex: 3,
                                  child: Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              // width:
                                              //     Sizeconfig.getWidth(context) *
                                              //         0.28,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Container(
                                                    width: Sizeconfig.getWidth(
                                                            context) *
                                                        0.18,
                                                    margin:
                                                        EdgeInsets.only(top: 5),
                                                    child:
                                                        model.addQuantity != 0
                                                            ? Container(
                                                                alignment: Alignment
                                                                    .bottomRight,
                                                                child: Appwidgets.AddQuantityButton(
                                                                    StringContants
                                                                        .lbl_add,
                                                                    model.addQuantity!
                                                                        as int,
                                                                    () {
                                                                  //increase

                                                                  if (model
                                                                          .addQuantity ==
                                                                      int.parse(model
                                                                          .orderQtyLimit!
                                                                          .toString())) {
                                                                    Fluttertoast
                                                                        .showToast(
                                                                            msg:
                                                                                StringContants.msg_quanitiy);
                                                                  } else {
                                                                    model.addQuantity =
                                                                        model.addQuantity +
                                                                            1;
                                                                    bloc.add(ProductUpdateQuantityEvent(
                                                                        quanitity:
                                                                            model
                                                                                .addQuantity!,
                                                                        index:
                                                                            index));
                                                                    bloc.add(ProductChangeEvent(
                                                                        model:
                                                                            model));
                                                                    updateCard(
                                                                        model);
                                                                    debugPrint(
                                                                        "Scroll Event1111 ");
                                                                  }
                                                                }, () async {
                                                                  //decrease

                                                                  if (model
                                                                          .addQuantity !=
                                                                      0) {
                                                                    model.addQuantity =
                                                                        model.addQuantity -
                                                                            1;

                                                                    bloc.add(ProductUpdateQuantityEvent(
                                                                        quanitity:
                                                                            model
                                                                                .addQuantity!,
                                                                        index:
                                                                            index));

                                                                    updateCard(
                                                                        model);

                                                                    if (model
                                                                            .addQuantity ==
                                                                        0) {
                                                                      await dbHelper
                                                                          .deleteCard(int.parse(model
                                                                              .productId!))
                                                                          .then(
                                                                              (value) {
                                                                        debugPrint(
                                                                            "Delete Product $value ");

                                                                        cardBloc.add(CardDeleteEvent(
                                                                            model:
                                                                                model,
                                                                            listProduct:
                                                                                list![0].unit!));
                                                                        dbHelper
                                                                            .loadAddCardProducts(cardBloc);

                                                                        if (list![0].unit!.length ==
                                                                            0) {
                                                                          cardBloc
                                                                              .add(CardEmptyEvent());
                                                                        }

                                                                        bloc.add(ProductUpdateQuantityEvent(
                                                                            quanitity:
                                                                                model.addQuantity!,
                                                                            index: index));

                                                                        updateCard(
                                                                            model);
                                                                      });
                                                                    }
                                                                    bloc.add(ProductChangeEvent(
                                                                        model:
                                                                            model));
                                                                  }
                                                                }),
                                                              )
                                                            : Appwidgets()
                                                                .buttonPrimary(
                                                                StringContants
                                                                    .lbl_add,
                                                                () {
                                                                  debugPrint("GGGGGGGSSS " +
                                                                      cardItesmList
                                                                          .length
                                                                          .toString());

                                                                  model.addQuantity =
                                                                      model.addQuantity +
                                                                          1;
                                                                  checkItemId(model
                                                                          .productId!)
                                                                      .then(
                                                                          (value) {
                                                                    debugPrint(
                                                                        "CheckItemId $value");

                                                                    if (value ==
                                                                        false) {
                                                                      addCard(
                                                                          model);
                                                                    } else {
                                                                      updateCard(
                                                                          model);
                                                                    }
                                                                  });

                                                                  bloc.add(ProductUpdateQuantityEvent(
                                                                      quanitity:
                                                                          model
                                                                              .addQuantity!,
                                                                      index:
                                                                          index));
                                                                  bloc.add(
                                                                      ProductChangeEvent(
                                                                          model:
                                                                              model));
                                                                },
                                                              ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            // Text(
                                            //   model.specialPrice == ""
                                            //       ? ""
                                            //       : "₹ ${double.parse(model.price!).toStringAsFixed(2)}",
                                            //   style: TextStyle(
                                            //       fontSize: Constants.Size_10,
                                            //       fontFamily: Fontconstants.fc_family_sf,
                                            //       fontWeight: Fontconstants.SF_Pro_Display_Medium,
                                            //       letterSpacing: 0,
                                            //       decoration: TextDecoration.lineThrough,
                                            //       decorationColor: ColorName.textsecondary,
                                            //       color: ColorName.textsecondary),
                                            // ),

                                            CommanTextWidget.regularBold(
                                              model.specialPrice == ""
                                                  ? ""
                                                  : "₹${double.parse(model.price!).toStringAsFixed(2)}",
                                              ColorName.textsecondary,
                                              maxline: 2,
                                              trt: TextStyle(
                                                fontSize: 10,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                decorationColor:
                                                    ColorName.textsecondary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              textalign: TextAlign.start,
                                            ),

                                            Visibility(
                                              visible: model.specialPrice != "",
                                              child: SizedBox(
                                                height: 0,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 0,
                                              child:
                                                  // Text(
                                                  //   model.specialPrice == ""
                                                  //       ? "₹ ${double.parse(model.sortPrice!).toStringAsFixed(2)}"
                                                  //       : "₹ ${double.parse(model.specialPrice!).toStringAsFixed(2)}",
                                                  //   style: TextStyle(
                                                  //     fontSize: Constants.Size_11,
                                                  //     fontFamily: Fontconstants.fc_family_sf,
                                                  //     fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD,
                                                  //     color: Colors.black,
                                                  //   ),
                                                  // ),

                                                  CommanTextWidget.regularBold(
                                                model.specialPrice == ""
                                                    ? "₹ ${double.parse(model.sortPrice!).toStringAsFixed(2)}"
                                                    : "₹ ${double.parse(model.specialPrice!).toStringAsFixed(2)}",
                                                Colors.black,
                                                maxline: 2,
                                                trt: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                textalign: TextAlign.start,
                                              ),
                                            ),
                                          ])))
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  (model.discountText ?? "") == ""
                      ? Container()
                      : Visibility(
                          visible: (model!.discountText != "" ||
                              model!.discountText != null),
                          child: Positioned(
                            left: 8,
                            top: 0,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(5.0)),
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
                                    model.discountText ?? "",
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
                        ),
                ],
              ),
            ),
            (model.cOfferId != 0 &&
                    model.cOfferId != null &&
                    model.subProduct != null &&
                    (showWarningMessage != false || offerAppilied != false))
                ? Container(
                    width: Sizeconfig.getWidth(context),
                    margin: EdgeInsets.only(right: 8, left: 8, bottom: 0),
                    padding: EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: showWarningMessage
                          ? Colors.red.shade400
                          : Colors.green,
                      borderRadius: (model.cOfferId != 0 &&
                              model.cOfferId != null &&
                              model.subProduct != null &&
                              (showWarningMessage != false ||
                                  offerAppilied != false))
                          ? BorderRadius.only(
                              bottomLeft: Radius.circular(5),
                              bottomRight: Radius.circular(5))
                          : BorderRadius.circular(5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(),
                        Column(
                          children: [
                            showWarningMessage == false
                                ? SizedBox.shrink()
                                : Container(
                                    width: Sizeconfig.getWidth(context),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2, horizontal: 10),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        Imageconstants.img_offer,
                                        height: 15,
                                        width: 15,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: 3,
                                      ),
                                      Container(
                                        width:
                                            Sizeconfig.getWidth(context) * 0.5,
                                        child: Text(
                                          applied.replaceAll(
                                              "@#\$", buy_quantity.toString()),
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
                : const SizedBox.shrink(),
            // SizedBox(
            //   height: spacingWidgetForList(list!.length - 1, index),
            // ),
            loadmore == false
                ? Container()
                : (index == list!.length - 1) && loadmore && list!.length > 5
                    ? Column(
                        children: [
                          SizedBox(
                            height: 25,
                          ),
                          Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              height: 30,
                              width: 30,
                              child: CircularProgressIndicator(
                                color: ColorName.ColorPrimary,
                              )),
                          SizedBox(
                            height: 50,
                          ),
                        ],
                      )
                    : (index == list!.length - 1)
                        ? Container(
                            height: 80,
                          )
                        : Container()
          ],
        ),
      ),
    );
  }

  double spacingWidgetForList(int listLength, int index) {
    double screenHeight = Sizeconfig.getHeight(context) + 20;
    bool isLargeScreen = screenHeight > 800;
    bool isEmptyState = cardBloc.state is CardEmptyState;
    double heightFactor;

    // If the index is not the last item, return 0.
    if (index != listLength || isEmptyState) {
      return 0;
    } else {
      heightFactor = isLargeScreen ? 0.15 : 0.10;
    }

    return screenHeight * heightFactor;
  }

  Widget categoryItemViewold(BuildContext context, ProductUnit model,
      dynamic state, int index, bool isMoreUnit) {
    debugPrint("categoryItemViewModel ${jsonEncode(model.discountText)}");
    debugPrint("categoryItemViewModel ${model.cOfferId != null}");
    debugPrint("categoryItemViewModel ${bloc.state}");

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
        //  if (x.selectedUnitIndex > 0)
        if (x.isselectUnit) {
          model = x;
        }
      }
    }

    return GestureDetector(
      onTap: () async {
        for (int i = 0; i < list![index].unit!.length!; i++) {
          debugPrint("Model  ${model.productId} ${model.addQuantity} ");
          if (model.productId == list![index].unit![i].productId!) {
            list![index].unit![i] = model;
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
            'index': isMoreUnit ? isMoreUnitIndex : index,
          },
        ).then((value) async {
          ProductUnit unit = value as ProductUnit;
          debugPrint("FeatureCallback ${value.addQuantity}");
          OndoorThemeData.setStatusBarColor();
          bloc.add(ProductUpdateQuantityEvent(
              quanitity: unit.addQuantity!, index: index));
          initializedDb();
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
                  margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
                  padding: EdgeInsets.only(bottom: 1),
                  decoration: BoxDecoration(
                    color:
                        showWarningMessage ? Colors.red.shade400 : Colors.green,
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
                                  decoration: BoxDecoration(
                                      color: Colors.red.shade400,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0))),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 10),
                                  alignment: Alignment.center,
                                  child: Marquee(
                                    pauseDuration: Duration(milliseconds: 0),
                                    directionMarguee:
                                        DirectionMarguee.oneDirection,
                                    autoRepeat: true,
                                    backwardAnimation: Curves.easeOut,
                                    child: Text(
                                      warningtitle.replaceAll(
                                          "@#\$", "${remainingQuanityt}"),
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontSize: Constants.Size_10,
                                          fontFamily:
                                              Fontconstants.fc_family_sf,
                                          fontWeight: Fontconstants
                                              .SF_Pro_Display_Medium,
                                          color: Colors.white),
                                    ),
                                  )),
                          Visibility(
                            visible: offerAppilied,
                            child: Container(
                                width: Sizeconfig.getWidth(context),
                                // margin: EdgeInsets.symmetric(
                                //     horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(),
                                child: Marquee(
                                  pauseDuration: Duration(milliseconds: 0),
                                  directionMarguee:
                                      DirectionMarguee.oneDirection,
                                  autoRepeat: true,
                                  backwardAnimation: Curves.easeOut,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        margin:
                                            EdgeInsets.only(left: 5, bottom: 2),
                                        child: Image.asset(
                                          Imageconstants.img_offer,
                                          height: 15,
                                          width: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 3,
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          applied.replaceAll(
                                              "@#\$", buy_quantity.toString()),
                                          style: TextStyle(
                                              fontSize: Constants.Size_10,
                                              fontFamily:
                                                  Fontconstants.fc_family_sf,
                                              fontWeight: Fontconstants
                                                  .SF_Pro_Display_Medium,
                                              color: Colors.white),
                                        ),
                                      )
                                    ],
                                  ),
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

                  margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
                  padding:
                      EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 6),
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
                              flex: 3,
                              child: Container(
                                height: Sizeconfig.getWidth(context) * .27,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 0),
                                  child: Stack(
                                    children: [
                                      Card(
                                        elevation: 1,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                                ColorName.ColorBagroundPrimary,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: ColorName.lightGey),
                                          ),
                                          height: Sizeconfig.getWidth(context) *
                                              .25,
                                          padding: EdgeInsets.all(10),
                                          width: Sizeconfig.getWidth(context) *
                                              .25,
                                          child: CommonCachedImageWidget(
                                            imgUrl: model.image!,
                                          ),
                                        ),
                                      ),
                                      (model.discountText ?? "") == ""
                                          ? Container()
                                          : Visibility(
                                              visible: (model!.discountText !=
                                                      "" ||
                                                  model!.discountText != null),
                                              child: Positioned(
                                                // left: 7,
                                                left: 11,
                                                top: 4,
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Image.asset(
                                                      Imageconstants.img_tag,
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
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 2,
                                                        style: const TextStyle(
                                                          color:
                                                              ColorName.black,
                                                          fontSize: 7,
                                                          fontWeight:
                                                              FontWeight.w600,
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
                              child: Stack(
                                children: [
                                  Container(
                                    // height: Sizeconfig.getWidth(context) * .28,
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
                                                style: TextStyle(
                                                  fontSize: 13,
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
                                          height: 6,
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
                                                    "Dialog value ${isMoreUnitIndex} ${index} ${value.name} ");

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
                                                // bloc.add(FeaturedEmptyEvent());
                                                // bloc.add(ProductUnitUpddate());
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
                                                      .25,
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
                                          height: 6,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  model.specialPrice == ""
                                                      ? ""
                                                      : "₹ ${double.parse(model.price!).toStringAsFixed(2)}",
                                                  style: TextStyle(
                                                      fontSize:
                                                          Constants.SizeSmall,
                                                      fontFamily: Fontconstants
                                                          .fc_family_sf,
                                                      fontWeight: Fontconstants
                                                          .SF_Pro_Display_Medium,
                                                      letterSpacing: 0,
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      decorationColor:
                                                          ColorName.textlight,
                                                      color:
                                                          ColorName.textlight),
                                                ),
                                                Visibility(
                                                  visible:
                                                      model.specialPrice != "",
                                                  child: SizedBox(
                                                    width: 5,
                                                  ),
                                                ),
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
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 20,
                  child: Container(
                    width: Sizeconfig.getWidth(context) * 0.23,
                    margin: EdgeInsets.only(right: 10),
                    child: model.addQuantity != 0
                        ? Container(
                            alignment: Alignment.bottomRight,
                            child: Appwidgets.AddQuantityButton(
                                StringContants.lbl_add,
                                model.addQuantity! as int, () {
                              //increase

                              if (model.addQuantity ==
                                  int.parse(model.orderQtyLimit!.toString())) {
                                Fluttertoast.showToast(
                                    msg: StringContants.msg_quanitiy);
                              } else {
                                model.addQuantity = model.addQuantity + 1;
                                bloc.add(ProductUpdateQuantityEvent(
                                    quanitity: model.addQuantity!,
                                    index: index));
                                bloc.add(ProductChangeEvent(model: model));
                                updateCard(model);
                                debugPrint("Scroll Event1111 ");
                              }
                            }, () async {
                              //decrease

                              if (model.addQuantity != 0) {
                                model.addQuantity = model.addQuantity - 1;

                                bloc.add(ProductUpdateQuantityEvent(
                                    quanitity: model.addQuantity!,
                                    index: index));

                                updateCard(model);

                                if (model.addQuantity == 0) {
                                  await dbHelper
                                      .deleteCard(int.parse(model.productId!))
                                      .then((value) {
                                    debugPrint("Delete Product $value ");

                                    cardBloc.add(CardDeleteEvent(
                                        model: model,
                                        listProduct: list![0].unit!));
                                    dbHelper.loadAddCardProducts(cardBloc);

                                    if (list![0].unit!.length == 0) {
                                      cardBloc.add(CardEmptyEvent());
                                    }

                                    bloc.add(ProductUpdateQuantityEvent(
                                        quanitity: model.addQuantity!,
                                        index: index));

                                    updateCard(model);
                                  });
                                }
                                bloc.add(ProductChangeEvent(model: model));
                              }
                            }),
                          )
                        : Appwidgets().buttonPrimary(
                            StringContants.lbl_add,
                            () {
                              debugPrint(
                                  "GGGGGGG " + cardItesmList.length.toString());

                              model.addQuantity = model.addQuantity + 1;
                              checkItemId(model.productId!).then((value) {
                                debugPrint("CheckItemId $value");

                                if (value == false) {
                                  addCard(model);
                                } else {
                                  updateCard(model);
                                }
                              });

                              bloc.add(ProductUpdateQuantityEvent(
                                  quanitity: model.addQuantity!, index: index));
                              bloc.add(ProductChangeEvent(model: model));
                            },
                          ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  SaveSearchHistory(String text) async {
    List<String> searchtextTemp = [];
    List<String> searchtext =
        await SharedPref.getListPreference(Constants.sp_searchHistory);

    if (searchtext.contains(text) == false) {
      searchtextTemp.add(text);
    }

    if (searchtext.length > 3) {
      searchtext.removeAt(3);
    }

    await SharedPref.setListPreference(
        Constants.sp_searchHistory, searchtextTemp + searchtext);
  }

  deleteHistory(String name) async {
    List<String> searchtext =
        await SharedPref.getListPreference(Constants.sp_searchHistory);
    searchtext.remove(name);
    await SharedPref.setListPreference(Constants.sp_searchHistory, searchtext);
    bloc.add(SearchHistroryEvent(searchHistoryList: searchtext));
  }

  void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  LoadsearchHistory() async {
    listSearchHitory =
        await SharedPref.getListPreference(Constants.sp_searchHistory);
    debugPrint("LoadsearchHistory ${listSearchHitory.toString()}");
    if (listSearchHitory.length > 0) {
      bloc.add(SearchHistroryEvent(searchHistoryList: listSearchHitory));
    }
  }

  searchProduct(String result, int pageno) async {
    print("searchProduct >>>>>  $pageno");
    if (pageno == 1) {
      bloc.add(ProductNullEvent());
      bloc.add(LodingEvent());
    }

    if (await Network.isConnected()) {
      //List<ProductData>? list;
      // OndoorThemeData.keyBordDow();
      searchData = result;
      ApiProvider()
          .getSearchProduct(result, context, pageno, editOrder)
          .then((value) async {
        if (value != "") {
          //  searchController.text = result;
          ProductsModel productsModel = ProductsModel.fromJson(value);
          debugPrint("Search Product Listing " +
              productsModel.data!.length.toString());

          if (pageno > 1) {
            debugPrint("Search Product Listing " + list!.length.toString());
            list!.addAll(productsModel!.data);
          } else {
            list = productsModel!.data;
          }

          //hideKeyboard(context);
          bloc.add(LoadedFeaturedEvent(list: list!));
          //  bloc.add(LoadedFeaturedEvent(list: productsModel!.data));
          SaveSearchHistory(result);
        } else {
          // hideKeyboard(context);
          loadmore = false;
          bloc.add(ProductLoadMoreEvent(index: 0, loadmore: false));
          bloc.add(ProductNullEvent());
          debugPrint("Search Product Listing Empty");
          bloc.add(LoadedFeaturedEvent(list: list));
          LoadsearchHistory();
        }
      });
    }
  }

  googleSpeechDialog() async {
    bool isServiceAvailable =
        await SpeechToTextGoogleDialog.getInstance().showGoogleDialog(
      onTextReceived: (data) async {
        if (await Network.isConnected()) {
          List<ProductData>? list;
          searchController.text = data;
          OndoorThemeData.keyBordDow();
          pageno = 1;
          loadmore = true;
          searchData = data;
          ApiProvider()
              .getSearchProduct(data, context, pageno, editOrder)
              .then((value) async {
            if (value != "") {
              ProductsModel productsModel = ProductsModel.fromJson(value);
              debugPrint("Search Product Listing " +
                  productsModel.data!.length.toString());

              bloc.add(LoadedFeaturedEvent(list: productsModel!.data));
              SaveSearchHistory(data);
            } else {
              debugPrint("Search Product Listing Empty");
              bloc.add(LoadedFeaturedEvent(list: []));
            }
          });
        }
      },
      // locale: "en-US",
    );
    if (!isServiceAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Service is not available'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          left: 16,
          right: 16,
        ),
      ));
    }
  }

  loadBannerTitle() async {
    if (widget.title.contains(StringContants.lbl_bannersprodcut)) {
      tag = widget.title;
      isBannerProdcts = true;
      bannerProductTitle =
          await SharedPref.getStringPreference(Constants.sp_bannerProductTitle);
      debugPrint("BannerTitile ${bannerProductTitle}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => pagebloc,
      child: BlocBuilder<PaginationBloc, PaginationState>(
          bloc: pagebloc,
          builder: (context, state) {
            print("SeeAllForPaginationState $state");
            if (state is SeeAllForPaginationState) {
              print("SeeAllForPaginationState 22  ${state.list!.length}");
              if (state.list!.length != 0) {
                if (state.isAdded) {
                  list!.addAll(state.list!);
                } else {
                  list = state.list!;
                }
              }
            }

            return BlocProvider(
              create: (context) => bloc,
              child: BlocBuilder<FeaturedBloc, FeaturedState>(
                  bloc: bloc,
                  builder: (context, state) {
                    debugPrint("Featured Product State ** " + state.toString());
                    debugPrint("editOrder" + editOrder.toString());
                    SystemChrome.setSystemUIOverlayStyle(
                        const SystemUiOverlayStyle(
                            statusBarColor: ColorName
                                .ColorPrimary, // Set status bar color here
                            statusBarIconBrightness: Brightness.light));
                    if (state is ProductListEmptyState) {
                      isProductNotFound = true;
                    }

                    if (state is OldListState) {
                      print("OldListState ${state.list!.length}");
                      list = state.list;
                    }
                    if (state is SearchHistroryState) {
                      listSearchHitory = state.searchHistoryList;
                    }

                    if (state is LoadedFeaturedState) {
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
                            if (newmodel.subProduct!.subProductDetail!.length >
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
                          for (int i = 0; i < list![index].unit!.length; i++) {
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

                      loadBannerTitle();
                    }

                    // For Manage card list product Quanityt
                    if (state is ProductUpdateQuantityInitialState) {
                      list = state.list!;
                    }

                    if (state is ProductLoadMoreState) {
                      loadmore = state.loadmore;
                    }

                    return SafeArea(
                      child: VisibilityDetector(
                        key: Key("FeatureProductScree"),
                        onVisibilityChanged: (VisibilityInfo info) {
                          print("Visibility FeatureProductScree");
                          SystemChrome.setSystemUIOverlayStyle(
                              const SystemUiOverlayStyle(
                                  statusBarColor: ColorName
                                      .ColorPrimary, // Set status bar color here
                                  statusBarIconBrightness: Brightness.light));
                        },
                        child: WillPopScope(
                          onWillPop: () async {
                            // Appwidgets.showExitDialog(context,
                            //     StringContants.lbl_exit,
                            //     StringContants.lbl_exit_message,(){exit(1);});
                            //print("setFlagIntialized OUT ${listTemp!.length.toString()}");
                            // print("setFlagIntialized updatedLength ${updatedLength}");
                            //   print("setFlagIntialized old ${oldlenght} ${oldlist!.length}");
                            int totallenght = listTemp!.length;
                            int newlegth = updatedLength;

                            int oldlenght = totallenght - newlegth;
                            List<ProductData>? oldlist =
                                list?.sublist(0, oldlenght);

                            Navigator.pop(context, oldlist);

                            return false;
                          },
                          child: Scaffold(
                            resizeToAvoidBottomInset: false,
                            appBar: widget.title != StringContants.lbl_search
                                ? Appwidgets.MyAppBar2(
                                    context,
                                    isBannerProdcts
                                        ? bannerProductTitle
                                        : widget.title, () {
                                    print("backpress call");
                                    int totallenght = listTemp!.length;
                                    int newlegth = updatedLength;

                                    int oldlenght = totallenght - newlegth;
                                    List<ProductData>? oldlist =
                                        list?.sublist(0, oldlenght);

                                    Navigator.pop(context, oldlist);
                                  })
                                : PreferredSize(
                                    preferredSize:
                                        Size.fromHeight(110), // Set this height
                                    child: Container(
                                      color: ColorName.ColorPrimary,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Appwidgets.MyAppBar(
                                              context,
                                              isBannerProdcts
                                                  ? bannerProductTitle
                                                  : widget.title,
                                              () {}),
                                          Container(
                                              margin: const EdgeInsets.only(
                                                  left: 10,
                                                  right: 10,
                                                  bottom: 10),
                                              child: CustomTextField(
                                                onSubmit: (value) {
                                                  pageno = 1;
                                                  loadmore = true;
                                                  searchProduct(value, pageno);
                                                },
                                                ontap: () {
                                                  debugPrint(
                                                      "GG GoogeleSpeech Dialog ");
                                                  googleSpeechDialog();
                                                },
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                obscureText: false,
                                                hintText: StringContants
                                                    .lbl_search_hint,
                                                activeIcon:
                                                    Imageconstants.img_search,
                                                // Provide the actual path to the active icon
                                                inactiveIcon:
                                                    Imageconstants.img_search,
                                                padding: EdgeInsets.only(
                                                  top: 10,
                                                  left: 5,
                                                  right: 0,
                                                  bottom: 10,
                                                ),
                                                suffixIcon: Imageconstants
                                                    .img_microphon,
                                                // Provide the actual path to the inactive icon
                                                controller: searchController,
                                                isPassword: false,
                                                readOnly: false,
                                                onchanged: (result) {
                                                  debugPrint(
                                                      "Search text ${result}");
                                                  _debouncer.run(() async {
                                                    if (result.length > 2) {
                                                      list!.clear();
                                                      pageno = 1;
                                                      loadmore = true;
                                                      searchProduct(
                                                          result, pageno);
                                                    } else if (result == "") {
                                                      list!.clear();
                                                      pageno = 1;
                                                      loadmore = true;
                                                      searchProduct(
                                                          result, pageno);
                                                    }
                                                  });
                                                },
                                                iskeyboardopen: iskeyboardopen,
                                                hinttextlist: [],
                                              )),
                                        ],
                                      ),
                                    ),
                                  ),
                            body: Container(
                              height: Sizeconfig.getHeight(context),
                              child: Stack(
                                children: [
                                  Container(
                                      height: Sizeconfig.getHeight(context),
                                      color: ColorName.aquaHazeColor,
                                      padding: EdgeInsets.only(top: 10),
                                      // padding: const EdgeInsets.only(top: 10),
                                      child: (state is LodingState)
                                          ? Container(
                                              height:
                                                  Sizeconfig.getHeight(context),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                      height: 25,
                                                      width: 25,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: ColorName
                                                            .ColorPrimary,
                                                      )),
                                                  Container()
                                                ],
                                              ),
                                            )
                                          : (widget.title ==
                                                      StringContants
                                                          .lbl_search &&
                                                  searchController
                                                      .text.isEmpty &&
                                                  list!.length == 0)
                                              ? Container(
                                                  height: Sizeconfig.getHeight(
                                                      context),
                                                  width: Sizeconfig.getWidth(
                                                      context),
                                                  child: Stack(
                                                    children: [
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Container(),
                                                          Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                child: Image.asset(
                                                                    Imageconstants
                                                                        .img_productfind),
                                                                height: 300,
                                                                width: 300,
                                                              ),
                                                              Appwidgets.TextLagre(
                                                                  StringContants
                                                                      .lbl_search_your_product,
                                                                  ColorName
                                                                      .black),
                                                              Appwidgets.TextMedium(
                                                                  StringContants
                                                                      .lbl_search_your_product2,
                                                                  ColorName
                                                                      .grey)
                                                            ],
                                                          ),
                                                          Container(),
                                                        ],
                                                      ),
                                                      Container(
                                                        child: ListView.builder(
                                                            itemCount:
                                                                listSearchHitory
                                                                    .length,
                                                            shrinkWrap: true,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return Container(
                                                                color: Colors
                                                                    .white,
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top: 5,
                                                                        bottom:
                                                                            5,
                                                                        left:
                                                                            11,
                                                                        right:
                                                                            10),
                                                                child: Column(
                                                                  children: [
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        InkWell(
                                                                          onTap:
                                                                              () {
                                                                            var data =
                                                                                listSearchHitory[index];

                                                                            debugPrint("SearchText $data");
                                                                            if (data !=
                                                                                "") {
                                                                              searchProduct(data, pageno);
                                                                            }
                                                                          },
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            children: [
                                                                              Icon(
                                                                                Icons.restore,
                                                                                color: ColorName.black,
                                                                                size: 20,
                                                                              ),
                                                                              SizedBox(
                                                                                width: 15,
                                                                              ),
                                                                              Appwidgets.TextLagre(listSearchHitory[index], ColorName.ColorPrimary)
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        InkWell(
                                                                            onTap:
                                                                                () {
                                                                              deleteHistory(listSearchHitory[index]);
                                                                            },
                                                                            child:
                                                                                Icon(
                                                                              Icons.close_outlined,
                                                                              color: ColorName.black,
                                                                              size: 20,
                                                                            )),
                                                                      ],
                                                                    ),
                                                                    Visibility(
                                                                      visible: index !=
                                                                          listSearchHitory.length -
                                                                              1,
                                                                      child:
                                                                          Container(
                                                                        margin: EdgeInsets.only(
                                                                            top:
                                                                                2),
                                                                        color: ColorName
                                                                            .white_card,
                                                                        height:
                                                                            1,
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              );
                                                            }),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : ((widget.title ==
                                                              StringContants
                                                                  .lbl_search &&
                                                          searchController.text
                                                              .isNotEmpty &&
                                                          list!.length == 0) ||
                                                      isProductNotFound)
                                                  ? Container(
                                                      height:
                                                          Sizeconfig.getHeight(
                                                              context),
                                                      width:
                                                          Sizeconfig.getWidth(
                                                              context),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Container(),
                                                          /*         Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.start,
                                                      children: [
                                                        Container(
                                                          child: Image.asset(
                                                            Imageconstants
                                                                .img_nosearch,
                                                            color: Colors.grey,
                                                          ),
                                                          height: 50,
                                                          width: 50,
                                                        ),
                                                        SizedBox(
                                                          height: 30,
                                                        ),
                                                        Appwidgets.TextLagre(
                                                            StringContants
                                                                .lbl_no_products_found,
                                                            ColorName.black)
                                                      ],
                                                    ),*/
                                                          Column(
                                                            // alignment: Alignment.center,
                                                            // fit: StackFit.loose,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Image.asset(
                                                                Imageconstants
                                                                    .newnorecord,
                                                                fit:
                                                                    BoxFit.fill,
                                                                width: Sizeconfig
                                                                        .getWidth(
                                                                            context) *
                                                                    .55,
                                                                height: Sizeconfig
                                                                        .getWidth(
                                                                            context) *
                                                                    .45,
                                                              ),
                                                              20.toSpace,
                                                              Text(
                                                                StringContants
                                                                    .lbl_no_products_found,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: Appwidgets()
                                                                    .commonTextStyle(
                                                                        ColorName
                                                                            .ColorPrimary)
                                                                    .copyWith(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w700,
                                                                        fontSize:
                                                                            18),
                                                              ),
                                                            ],
                                                          ),
                                                          Container(),
                                                        ],
                                                      ),
                                                    )
                                                  : list!.length != 0
                                                      ? ListView.separated(
                                                          shrinkWrap: true,
                                                          itemCount:
                                                              list!.length,
                                                          controller:
                                                              _scrollController,
                                                          itemBuilder:
                                                              (context, index) {
                                                            var dummyData =
                                                                list![index]
                                                                    .unit![0];

                                                            bool isMoreunit =
                                                                false;

                                                            debugPrint(
                                                                "GGGGG  $index  =>  ${list![index].unit!.length.toString()}");
                                                            if (list![index]
                                                                    .unit!
                                                                    .length >
                                                                1) {
                                                              isMoreunit = true;
                                                            }

                                                            if (state
                                                                is ProductUpdateQuantityStateBYModel) {
                                                              debugPrint(
                                                                  "LIST Featured Product State  " +
                                                                      state
                                                                          .toString());

                                                              if (dummyData
                                                                      .productId ==
                                                                  state.model
                                                                      .productId) {
                                                                debugPrint(
                                                                    "MATCH Featured Product State  " +
                                                                        state
                                                                            .toString());
                                                                dummyData
                                                                        .addQuantity =
                                                                    state.model
                                                                        .addQuantity;
                                                              }
                                                            }
                                                            if (state
                                                                is ProductChangeState) {
                                                              if (isMoreunit) {
                                                                for (var obj
                                                                    in list![
                                                                            index]
                                                                        .unit!) {
                                                                  if (obj.name ==
                                                                      state
                                                                          .model
                                                                          .name) {
                                                                    dummyData =
                                                                        state
                                                                            .model;

                                                                    debugPrint("G>>>>>>    " +
                                                                        state
                                                                            .model
                                                                            .addQuantity
                                                                            .toString());

                                                                    debugPrint("G>>>>>>Index    " +
                                                                        isMoreUnitIndex
                                                                            .toString());
                                                                  }
                                                                }
                                                              } else {
                                                                for (var obj
                                                                    in list![
                                                                            index]
                                                                        .unit!) {
                                                                  if (obj.name ==
                                                                          state
                                                                              .model
                                                                              .name ||
                                                                      obj.productId ==
                                                                          state
                                                                              .model
                                                                              .productId) {
                                                                    debugPrint("G>>>>>>>>>>>>>>>>>>>>    " +
                                                                        state
                                                                            .model
                                                                            .addQuantity
                                                                            .toString());

                                                                    debugPrint("G>>>>>>Index    " +
                                                                        isMoreUnitIndex
                                                                            .toString());

                                                                    if (dummyData!.cOfferId !=
                                                                            0 &&
                                                                        dummyData.cOfferId !=
                                                                            null) {
                                                                      debugPrint(
                                                                          "##***********************");
                                                                      if (dummyData
                                                                              .subProduct !=
                                                                          null) {
                                                                        log("##***********************>>>>>>>>>>>>>>>>" +
                                                                            dummyData.subProduct!.toJson());

                                                                        dummyData = MyUtility.checkOfferSubProductUpdate(
                                                                            dummyData,
                                                                            state.model,
                                                                            dbHelper);
                                                                      }
                                                                    } else {
                                                                      dummyData =
                                                                          state
                                                                              .model;
                                                                    }
                                                                  } else {
                                                                    // For sub products
                                                                    debugPrint("##****" +
                                                                        state!
                                                                            .model!
                                                                            .name!);

                                                                    if (dummyData!.cOfferId !=
                                                                            0 &&
                                                                        dummyData.cOfferId !=
                                                                            null) {
                                                                      debugPrint(
                                                                          "##***********************");
                                                                      if (dummyData
                                                                              .subProduct !=
                                                                          null) {
                                                                        log("##***********************>>>>>>>>>>>>>>>>" +
                                                                            dummyData.subProduct!.toJson());
                                                                        if (dummyData.subProduct!.subProductDetail!.length >
                                                                            0) {
                                                                          List<ProductUnit>?
                                                                              listsubproduct =
                                                                              dummyData.subProduct!.subProductDetail!;

                                                                          for (int x = 0;
                                                                              x < listsubproduct.length;
                                                                              x++) {
                                                                            getCartQuantity(listsubproduct[x].productId!).then((value) {
                                                                              debugPrint("${listsubproduct[x].name} Sub Product Quantity quanityt ${value}");
                                                                              listsubproduct[x].addQuantity = value;
                                                                            });
                                                                          }

                                                                          dummyData
                                                                              .subProduct!
                                                                              .subProductDetail = listsubproduct;
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                            }

                                                            print(
                                                                "loadStatus $loadmore");

                                                            return Column(
                                                              children: [
                                                                Container(
                                                                  child: categoryItemView(
                                                                      context,
                                                                      dummyData,
                                                                      null,
                                                                      index,
                                                                      isMoreunit,
                                                                      list!
                                                                          .length,
                                                                      loadmore),
                                                                ),
                                                                list!.length -
                                                                            1 ==
                                                                        index
                                                                    ? 80.toSpace
                                                                    : 0.toSpace,
                                                              ],
                                                            );
                                                          },
                                                          separatorBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  int index) {
                                                            return (index ==
                                                                    list!.length -
                                                                        1)
                                                                ? Container(
                                                                    height: 100,
                                                                    color: Colors
                                                                        .black)
                                                                : SizedBox(
                                                                    height:
                                                                        2.0);
                                                          },
                                                        )
                                                      : Shimmerui.productListUi(
                                                          context)),
                                  BlocProvider(
                                      create: (context) => homePageBloc2,
                                      child: BlocBuilder(
                                        bloc: homePageBloc2,
                                        builder: (BuildContext context, state) {
                                          if (state is HomeBottomSheetState) {
                                            bottomviewstatus = state.status;

                                            debugPrint(
                                                "HomeBottomSheetState ${state.status}");
                                          }

                                          return bottomviewstatus
                                              ? Container(
                                                  height: Sizeconfig.getHeight(
                                                      context),
                                                  color: Colors.black12
                                                      .withOpacity(0.2),
                                                )
                                              : Container();
                                        },
                                      )),
                                  Container(
                                    height: Sizeconfig.getHeight(context),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(),
                                        editOrder
                                            ? Padding(
                                                padding:
                                                    EdgeInsets.only(bottom: 10),
                                                child: Appwidgets.MyButton(
                                                    "Done",
                                                    Sizeconfig.getWidth(
                                                        context), () async {
                                                  List<ProductUnit>
                                                      productUnitList =
                                                      await dbHelper
                                                          .getAllCarts(
                                                              cardBloc);
                                                  Navigator.pop(
                                                      context, productUnitList);
                                                }),
                                              )
                                            : Container(
                                                child:
                                                    Appwidgets.ShowBottomView33(
                                                        false,
                                                        context,
                                                        cardBloc,
                                                        bloc,
                                                        ShopByCategoryBloc(),
                                                        animationBloc,
                                                        animationsizebottom,
                                                        0,
                                                        "",
                                                        true,
                                                        dbHelper,
                                                        () async {
                                                          debugPrint(
                                                              "Gaurav Call back tag ${tag} title ${widget.title}");
                                                          SystemChrome.setSystemUIOverlayStyle(
                                                              const SystemUiOverlayStyle(
                                                                  statusBarColor:
                                                                      ColorName
                                                                          .ColorPrimary, // Set status bar color here
                                                                  statusBarIconBrightness:
                                                                      Brightness
                                                                          .light));
                                                          initializedDb();

                                                          if (!await Network
                                                              .isConnected()) {
                                                            MyDialogs
                                                                .showInternetDialog(
                                                                    context,
                                                                    () {
                                                              Navigator.pop(
                                                                  context);
                                                              if (widget
                                                                      .title ==
                                                                  StringContants
                                                                      .lbl_search) {
                                                                searchProduct(
                                                                    searchController
                                                                        .text,
                                                                    pageno);
                                                              } else {
                                                                bloc.add(
                                                                    LoadingFeaturedEvent(
                                                                        title:
                                                                            tag));
                                                              }
                                                            });
                                                          } else {
                                                            if (widget.title ==
                                                                StringContants
                                                                    .lbl_search) {
                                                              searchProduct(
                                                                  searchController
                                                                      .text,
                                                                  pageno);
                                                            } else {
                                                              bloc.add(
                                                                  LoadingFeaturedEvent(
                                                                      title:
                                                                          tag));
                                                            }
                                                          }
                                                        },
                                                        () {},
                                                        () {},
                                                        false,
                                                        (value) {
                                                          debugPrint(
                                                              "HomePage Screen back >>>>>");
                                                          isOpenBottomview =
                                                              value;
                                                          homePageBloc2.add(
                                                              HomeNullEvent());
                                                          homePageBloc2.add(
                                                              HomeBottomSheetEvent(
                                                                  status:
                                                                      value));
                                                        },
                                                        (height) {
                                                          debugPrint(
                                                              "GGheight >> $height");
                                                          animationsizebottom =
                                                              70.0;
                                                        }),
                                              ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            /* bottomNavigationBar: Appwidgets.ShowBottomView(
                              context,
                              cardBloc,
                              bloc,
                              ShopByCategoryBloc(),
                              animationBloc,
                              animationsizebottom,
                              cardItesmList!.length,
                              cardItesmList.isEmpty ? "" : cardItesmList[0].image!,
                              true,
                              dbHelper,
                                  () async {
                            debugPrint(
                                "Gaurav Call back tag ${tag} title ${widget.title}");
                            SystemChrome.setSystemUIOverlayStyle(
                                const SystemUiOverlayStyle(
                                    statusBarColor: ColorName
                                        .ColorPrimary, // Set status bar color here
                                    statusBarIconBrightness: Brightness.light));
                            initializedDb();

                            if (!await Network.isConnected()) {
                              MyDialogs.showInternetDialog(context, () {
                                Navigator.pop(context);
                                if (widget.title == StringContants.lbl_search) {
                                  searchProduct(searchController.text);
                                } else {
                                  bloc.add(LoadingFeaturedEvent(title: tag));
                                }
                              });
                            } else {
                              if (widget.title == StringContants.lbl_search) {
                                searchProduct(searchController.text);
                              } else {
                                bloc.add(LoadingFeaturedEvent(title: tag));
                              }
                            }
                          }, false),*/
                          ),
                        ),
                      ),
                    );
                  }),
            );
          }),
    );
  }
}
