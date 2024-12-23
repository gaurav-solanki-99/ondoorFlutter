import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ondoor/constants/Constant.dart';
import 'package:ondoor/models/GetTimeSlotsResponse.dart';
import 'package:ondoor/models/get_coco_code_response.dart';
import 'package:ondoor/screens/CheckoutScreen/CheckoutBloc/checkout_bloc.dart';
import 'package:ondoor/screens/CheckoutScreen/CheckoutBloc/checkout_event.dart';
import 'package:ondoor/screens/CheckoutScreen/CheckoutBloc/checkout_state.dart';
import 'package:ondoor/services/ApiServices.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/SizeConfig.dart';
import 'package:ondoor/utils/sharedpref.dart';
import 'package:ondoor/widgets/select_time_slot_dialog.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../constants/FontConstants.dart';
import '../../constants/ImageConstants.dart';
import '../../constants/StringConstats.dart';
import '../../database/database_helper.dart';
import '../../database/dbconstants.dart';
import '../../models/AllProducts.dart';
import '../../models/OrderSummaryProducts.dart';
import '../../models/TopProducts.dart';
import '../../models/address_list_response.dart';
import '../../services/Navigation/routes.dart';
import '../../utils/Utility.dart';
import '../../utils/colors.dart';
import '../../utils/shimmerUi.dart';
import '../../utils/themeData.dart';
import '../../widgets/AppWidgets.dart';
import '../../widgets/CheckoutWidgets.dart';
import '../../widgets/HomeWidgetConst.dart';
import '../../widgets/MyDialogs.dart';
import '../../widgets/ProductValidationsWidgets.dart';
import '../../widgets/UiStyle.dart';
import '../AddCard/card_bloc.dart';
import '../AddCard/card_event.dart';
import '../AddCard/card_state.dart';
import '../FeaturedProduct/FeatuuredBloc/featured_bloc.dart';
import '../FeaturedProduct/FeatuuredBloc/featured_event.dart';
import '../FeaturedProduct/FeatuuredBloc/featured_state.dart';
import '../HomeScreen/HomeBloc/home_page_bloc.dart';
import '../HomeScreen/HomeBloc/home_page_event.dart';
import '../HomeScreen/HomeBloc/home_page_state.dart';
import '../NewAnimation/animation_bloc.dart';
import '../NewAnimation/animation_event.dart';
import '../NewAnimation/animation_state.dart';
import '../shop_by_category/shop_by_category_bloc/shop_by_category_bloc.dart';

class OrderSummaryscreen extends StatefulWidget {
  String ProductsIds;
  String response;
  OrderSummaryscreen(
      {super.key, required this.ProductsIds, required this.response});

  @override
  State<OrderSummaryscreen> createState() => _OrderSummaryscreenState();
}

class _OrderSummaryscreenState extends State<OrderSummaryscreen> {
  List<TopProducts> listTopProducts = [
    TopProducts(
        imageUrl: Imageconstants.img_featured,
        name: StringContants.lbl_featuredprod,
        quantitiy: 0),
    TopProducts(
        imageUrl: Imageconstants.img_heavydiscount,
        name: StringContants.lbl_heavydis,
        quantitiy: 0),
    TopProducts(
        imageUrl: Imageconstants.img_newarrivals,
        name: StringContants.lbl_newarr,
        quantitiy: 0),
    // TopProducts(imageUrl: Imageconstants.img_offers, name: StringContants.lbl_offrs),
  ];
  var animationsizebottom = 0.0;
  AnimationBloc animationBloc = AnimationBloc();
  List<ProductUnit> list_cOffers = [];
  List<ProductUnit> cartitesmList = [];
  List<ProductUnit> freeProducts = [];
  bool loadProductValidation = false;
  GetTimeSlotResponse getTimeSlotResponse = GetTimeSlotResponse();
  final dbHelper = DatabaseHelper();
  CardBloc cardBloc = CardBloc();
  CheckoutBloc checkoutBloc = CheckoutBloc();
  double subtotal = 0;
  double subtotalcross = 0;
  double grandtotal = 0;
  double remaingAmountonFreeDelivery = 0;
  double freeDeliveryAmount = 0;
  double savingamount = 0;
  double shippingCharge = 0;
  bool isShowShipping = false;
  bool loadshippingAmount = false;
  String street = "";
  String locality = "";
  String token = "";
  String city = "";
  String userstate = "";
  String selectedTimeSlot = "";
  String selectedDateSlot = "";
  double latitude = 0.0;
  double longitude = 0.0;
  AddressData selectedAddressData = AddressData();
  GetCocoCodeByLatLngResponse? cocoCodeByLatLngResponse;
  bool viewmore = false;
  int isMoreUnitIndex = 0;
  List<ProductData> listSimilarProducts1 = [];
  FeaturedBloc featuredBloc = FeaturedBloc();
  int pagenolist1 = 1;
  List<int> pageno_list = [];
  List<OrderSummaryProductsDatum> listProducSummary = [];
  ScrollController _scrollController = ScrollController();
  var appbartbackgroundColor;
  String? appbarbackgroundImage = "";
  String? appbarTitle;
  var appbarTitleColor;
  List<ScrollController> _listScrolController = [];
  HomePageBloc homePageBloc2 = HomePageBloc();
  bool isOpenBottomview = false;

  bool bottomviewstatus = false;
  bool _isLoading = false;
  @override
  void _scrollListener() {
    if (_scrollController.offset.toInt() ==
        _scrollController.position.maxScrollExtent.toInt()) {
      // if (loadmore == true) {
      //   cheflist(pageNo, "", "", "", "", "", searchController.text);
      // }

      debugPrint("_scrollListener call ");

      getSimilarProducts(true);
    }
  }

  void _scrollListenerlist(int index, String type) {
    if (_listScrolController[index].offset.toInt() ==
            _listScrolController[index].position.maxScrollExtent.toInt() &&
        !_isLoading) {
      // if (loadmore == true) {
      //   cheflist(pageNo, "", "", "", "", "", searchController.text);
      // }

      debugPrint("_scrollListenerlist call ");
      _isLoading = true;
      getbeforeYourCheckoutPagination(true, type, index);
    }
  }

  @override
  void initState() {
    // if(widget.freeProducts.length!=0)
    //   {
    //     for (var x in widget.freeProducts) {
    //       if (x.addQuantity != 0) {
    //
    //         cartitesmList.add(x);
    //       }
    //     }
    //   }

    //   OndoorThemeData.setStatusBarColor();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // getSavedAddress();
      initializedDb();
      // getSimilarProducts(false);
      debugPrint("jdfkldjsf0 ${widget.response}");
      log("jdfkldjsf1 ${widget.response}");
      getResponseInitial(widget.response);
      _scrollController.addListener(_scrollListener);
      // retrieveAddressList();
    });

    super.initState();
  }

  gotoHomepage() {
    try {
      Future.delayed(Duration(seconds: 1), () {
        Navigator.of(context).pushReplacementNamed(Routes.home_page);
      });
    } catch (e) {
      debugPrint("Exeption " + e.toString());
    }
  }

  getSimilarProducts(bool loadmore) {
    // ApiProvider().getSimilarProducts("").th;
    debugPrint("getSimilarProducts api call");
    if (loadmore) {
      pagenolist1++;
    }

    ApiProvider()
        .beforeYourCheckout(widget.ProductsIds, pagenolist1, context)
        .then((value) async {
      if (value != "") {
        OrderSummaryProducts orderSummaryProducts =
            OrderSummaryProducts.fromJson(value.toString());
        log("ROHIT Log 12  ${value}");
        listProducSummary = orderSummaryProducts.data;
        debugPrint("beforeYourCheckout api call ** ${listProducSummary}");
        for (int index = 0; index < listProducSummary.length; index++) {
          pageno_list.add(1);

          List<ProductData> productData2 = List<ProductData>.from(
              listProducSummary[index]
                  .data!
                  .map((x) => ProductData.fromMap(x)));
          debugPrint("GGGDDDDD>>>>>${productData2.length}");

          listProducSummary[index].lisProductData = productData2;
        }
        var appBarImage = await Uistyle.downloadAndSaveImage(
            orderSummaryProducts.backgroundImage!, "fileName.png");
        featuredBloc.add(LoadedOrderSummaryEvent(
            listProducSummary: listProducSummary,
            backgroundColor: orderSummaryProducts.backgroundColor,
            backgroundImage: appBarImage,
            appbarTitle: orderSummaryProducts.appbarTitle,
            appbarTitleColor: orderSummaryProducts.appbarTitleColor));
      } else {
        print("ROHIT Log 1");
      }
    });
  }

  getResponseInitial(String value) async {
    if (value != "") {
      OrderSummaryProducts orderSummaryProducts =
          OrderSummaryProducts.fromJson(value.toString());
      listProducSummary = orderSummaryProducts.data;
      debugPrint("beforeYourCheckout api call ** ${listProducSummary}");
      for (int index = 0; index < listProducSummary.length; index++) {
        debugPrint("beforeYourCheckout api callGG ** ${index}");
        pageno_list.add(1);
        debugPrint(
            "beforeYourCheckout api call ****** ${listProducSummary[index].data!}");
        List<ProductData> productData2 = List<ProductData>.from(
            listProducSummary[index].data!.map((x) => ProductData.fromMap(x)));

        debugPrint("GGGDDDDD>>>>>${productData2.length}");

        listProducSummary[index].lisProductData = productData2;
      }
      var appBarImage = await Uistyle.downloadAndSaveImage(
          orderSummaryProducts.backgroundImage!, "fileName.png");

      featuredBloc.add(LoadedOrderSummaryEvent(
          listProducSummary: listProducSummary,
          backgroundColor: orderSummaryProducts.backgroundColor,
          backgroundImage: appBarImage,
          appbarTitle: orderSummaryProducts.appbarTitle,
          appbarTitleColor: orderSummaryProducts.appbarTitleColor));
    }
  }

  getbeforeYourCheckoutPagination(bool loadmore, String type, int index) {
    // ApiProvider().getSimilarProducts("").th;

    int pageno = pageno_list[index];
    debugPrint(
        "getbeforeYourCheckoutPagination api call1 ${listProducSummary[index].isLoadMore}");
    debugPrint(
        "getbeforeYourCheckoutPagination api call1 ${pageno_list[index]}");
    pageno_list[index] = pageno + 1;
    debugPrint(
        "getbeforeYourCheckoutPagination api call2 page ${pageno_list[index]}");

    if (listProducSummary[index].isLoadMore) {
      ApiProvider()
          .getbeforeYourCheckoutPagination(
              widget.ProductsIds, pageno_list[index], type)
          .then((value) async {
        final responseData = jsonDecode(value.toString());

        if (responseData["success"]) {
          debugPrint(
              "getbeforeYourCheckoutPagination api call3 ${responseData["success"]}");
          debugPrint(
              "getbeforeYourCheckoutPagination Product Listing " + value);

          ProductsModel productsModel =
              ProductsModel.fromJson(value.toString());

          debugPrint("getbeforeYourCheckoutPagination Product Listing " +
              productsModel.data!.length.toString());

          List<ProductData> paginationlist = productsModel.data;

          featuredBloc.add(ProductListEmptyEvent());
          featuredBloc.add(
              ProductForPaginationEvent(list: paginationlist, index: index));
          _isLoading = false;
        } else {
          _isLoading = false;
          debugPrint(
              "getbeforeYourCheckoutPagination api call3 ${responseData["success"]}");
          listProducSummary[index].isLoadMore = false;
          featuredBloc.add(ProductListEmptyEvent());
          featuredBloc.add(ProductLoadMoreEvent(index: index, loadmore: false));
        }

        return "";
      });
    } else {
      return "";
    }
  }

  initializedDb() async {
    await dbHelper.init();
    dbHelper.loadAddCardProducts(cardBloc);

    // if (selectedTimeSlot == "" || selectedDateSlot == "") {
    //   debugPrint("*****Gaurav***************");
    //   getCocoApi(latitude, longitude, city, userstate);
    // }

    debugPrint("Cardbloc State ${cardBloc.state}");
    Appwidgets.setStatusBarDynamicLightColor(color: Colors.transparent);
  }

  getSavedAddress() async {
    String latitudeStr =
        await SharedPref.getStringPreference(Constants.SELECTED_LOCATION_LAT);
    String longitudeStr =
        await SharedPref.getStringPreference(Constants.SELECTED_LOCATION_LONG);
    street = await SharedPref.getStringPreference(Constants.SAVED_ADDRESS);
    city = await SharedPref.getStringPreference(Constants.SAVED_CITY);
    userstate = await SharedPref.getStringPreference(Constants.SAVED_STATE);
    latitude = double.parse(latitudeStr);
    longitude = double.parse(longitudeStr);
    locality = "$city $userstate";
    checkoutBloc.add(GetAddressEvent(street: street, locality: locality));
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

  chekcartQuantiy(
      int unitIndex, List<ProductData> lisProductData, bool isloaded) {
    for (int index = 0; index < lisProductData!.length; index++) {
      try {
        var newmodel = lisProductData![index].unit![0];
        getCartQuantity(newmodel.productId!).then((value) {
          debugPrint("getCartQuanity $value");

          if (value > 0) {
            debugPrint(
                "getCartQuanity name  ${lisProductData![index].unit![0].name}");
          }
          lisProductData![index].unit![0].addQuantity = value;
          featuredBloc.add(ProductInitialSummaryEvent(
              list: lisProductData, index: unitIndex, loadmore: isloaded));
        });

        if (newmodel!.cOfferId != 0 && newmodel.cOfferId != null) {
          debugPrint("***********************");
          if (newmodel.subProduct != null) {
            log("***********************>>>>>>>>>>>>>>>>" +
                newmodel.subProduct!.toJson());
            if (newmodel.subProduct!.subProductDetail!.length > 0) {
              lisProductData![index].unit![0].subProduct!.subProductDetail =
                  MyUtility.checkOfferSubProductLoad(newmodel, dbHelper);
            }
          }
        }

        if (lisProductData![index].unit!.length > 1) {
          for (int i = 0; i < lisProductData![index].unit!.length; i++) {
            getCartQuantity(lisProductData![index].unit![i].productId!)
                .then((value) {
              debugPrint("getCartQuanity $value");
              lisProductData![index].unit![i].addQuantity = value;
              featuredBloc.add(ProductInitialSummaryEvent(
                  list: lisProductData, index: unitIndex, loadmore: isloaded));
            });
          }
        }
      } catch (e) {}
    }
  }

  getColor(String data) {
    return data.replaceAll("#", "0xFF");
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          statusBarColor: ColorName.transprent,
          statusBarIconBrightness: Brightness.light),
      child: VisibilityDetector(
        onVisibilityChanged: (visibilityInfo) async {
          debugPrint("OrderSummaryScreen visibility  ${visibilityInfo}");
          var visiblePercentage = visibilityInfo.visibleFraction * 100;
          debugPrint("OrderSummaryScreen visibility  ${visiblePercentage}");
          Appwidgets.setStatusBarDynamicLightColor(color: Colors.transparent);
        },
        key: const Key('OrderSummaryScreen'),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Scaffold(
            body: Container(
              height: Sizeconfig.getHeight(context),
              child: Stack(
                children: [
                  Container(
                    height: Sizeconfig.getHeight(context),
                    child: Column(
                      children: [
                        BlocProvider(
                          create: (context) => featuredBloc,
                          child: BlocBuilder<FeaturedBloc, FeaturedState>(
                              bloc: featuredBloc,
                              builder: (context, state) {
                                debugPrint("Featured Product State GG " +
                                    state.toString());
                                Appwidgets.setStatusBarDynamicLightColor(
                                    color: Colors.transparent);
                                if (state is LoadedOrderSummaryState) {
                                  listProducSummary = state.listProducSummary!;

                                  appbarTitleColor = Color(int.parse(getColor(
                                          state.appbarTitleColor
                                              .split(",")[0]
                                              .toString()) +
                                      ""));
                                  appbarTitle = state.appbarTitle;
                                  appbarbackgroundImage = state.backgroundImage;
                                  appbartbackgroundColor = Color(int.parse(
                                      getColor(state.backgroundColor
                                              .split(",")[0]
                                              .toString()) +
                                          ""));

                                  for (int index = 0;
                                      index < listProducSummary.length;
                                      index++) {
                                    chekcartQuantiy(
                                        index,
                                        listProducSummary[index].lisProductData,
                                        false);
                                  }
                                }

                                if (state is ProductForPaginationState) {
                                  debugPrint(
                                      "ProductForPaginationState ${state.index}  ${state.list!.length}");

                                  for (int index = 0;
                                      index < listProducSummary.length;
                                      index++) {
                                    if (state.index == index) {
                                      listProducSummary[index]
                                          .lisProductData
                                          .addAll(state.list!);

                                      chekcartQuantiy(
                                          index,
                                          listProducSummary[index]
                                              .lisProductData,
                                          false);
                                    }
                                  }
                                }

                                if (state is ProductLoadMoreState) {
                                  for (int index = 0;
                                      index < listProducSummary.length;
                                      index++) {
                                    if (state.index == index) {
                                      listProducSummary[index].isLoadMore =
                                          state.loadmore;
                                    }
                                  }
                                }

                                if (state is ProductInitialSummaryState) {
                                  for (int index = 0;
                                      index < listProducSummary.length;
                                      index++) {
                                    if (state.index == index) {
                                      listProducSummary[index].lisProductData =
                                          state.list!;
                                    }
                                  }
                                }

                                return Container(
                                  child: Container(
                                    color: Colors.white,
                                    //padding: EdgeInsets.symmetric(horizontal: 5.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Uistyle.ui_appbar(
                                            context,
                                            appbarTitle ?? "",
                                            appbarbackgroundImage!,
                                            appbarTitleColor,
                                            appbartbackgroundColor,
                                            () {}),
                                        listProducSummary.isEmpty
                                            ? Shimmerui.orderSummaryui(context)
                                            : Container(
                                                height: Sizeconfig.getHeight(
                                                        context) *
                                                    0.8,
                                                child: ListView.builder(
                                                    shrinkWrap: true,
                                                    padding:
                                                        EdgeInsets.only(top: 0),
                                                    itemCount: listProducSummary
                                                        .length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      _listScrolController.add(
                                                          ScrollController());
                                                      _listScrolController[
                                                              index]
                                                          .addListener(() {
                                                        _scrollListenerlist(
                                                            index,
                                                            listProducSummary[
                                                                    index]
                                                                .uitype);
                                                      });
                                                      var backgroundColor = Color(
                                                          int.parse(getColor(
                                                                  listProducSummary[
                                                                          index]
                                                                      .backgroundColor
                                                                      .split(
                                                                          ",")[0]
                                                                      .toString()) +
                                                              ""));
                                                      String backgroundImage =
                                                          listProducSummary[
                                                                  index]
                                                              .backgroundImage;
                                                      var titleColor = Color(
                                                          int.parse(getColor(
                                                                  listProducSummary[
                                                                          index]
                                                                      .titleColor
                                                                      .split(
                                                                          ",")[0]
                                                                      .toString()) +
                                                              ""));
                                                      var textColor = Color(
                                                          int.parse(getColor(
                                                                  listProducSummary[
                                                                          index]
                                                                      .textColor
                                                                      .split(
                                                                          ",")[0]
                                                                      .toString()) +
                                                              ""));

                                                      var textsecondary =
                                                          Colors.black;

                                                      if (listProducSummary[
                                                                  index]
                                                              .textColor
                                                              .split(",")
                                                              .length >
                                                          1) {
                                                        textsecondary = Color(int.parse(
                                                            getColor(listProducSummary[
                                                                        index]
                                                                    .textColor
                                                                    .split(
                                                                        ",")[1]
                                                                    .toString()) +
                                                                ""));
                                                      }
                                                      var abovecolor;
                                                      if (listProducSummary
                                                                  .length >
                                                              index &&
                                                          listProducSummary[
                                                                      index]
                                                                  .uitype ==
                                                              "2") {
                                                        abovecolor = Color(int.parse(
                                                            getColor(listProducSummary[
                                                                        index -
                                                                            1]
                                                                    .backgroundColor
                                                                    .split(
                                                                        ",")[0]
                                                                    .toString()) +
                                                                ""));
                                                      }

                                                      var buttontextcolor;
                                                      var buttonbackgroundcolor;

                                                      if (listProducSummary[
                                                                      index]
                                                                  .button_background !=
                                                              "" &&
                                                          listProducSummary[
                                                                      index]
                                                                  .button_background !=
                                                              null) {
                                                        buttonbackgroundcolor = Color(int.parse(
                                                            getColor(listProducSummary[
                                                                        index]
                                                                    .button_background
                                                                    .split(
                                                                        ",")[0]
                                                                    .toString()) +
                                                                ""));
                                                      }

                                                      if (listProducSummary[
                                                                      index]
                                                                  .button_text_color !=
                                                              "" &&
                                                          listProducSummary[
                                                                      index]
                                                                  .button_text_color !=
                                                              null) {
                                                        buttontextcolor = Color(int.parse(
                                                            getColor(listProducSummary[
                                                                        index]
                                                                    .button_text_color
                                                                    .split(
                                                                        ",")[0]
                                                                    .toString()) +
                                                                ""));
                                                      }

                                                      return Container(
                                                        child: BlocProvider(
                                                          create: (context) =>
                                                              featuredBloc,
                                                          child: BlocBuilder<
                                                                  FeaturedBloc,
                                                                  FeaturedState>(
                                                              bloc:
                                                                  featuredBloc,
                                                              builder: (context,
                                                                  state) {
                                                                debugPrint(
                                                                    "GGfeaturedBlocSate ${state}");
                                                                return listProducSummary[index].uitype ==
                                                                        "1"
                                                                    ? Uistyle.ui_type1(
                                                                        true,
                                                                        context,
                                                                        listProducSummary[index]
                                                                            .title,
                                                                        listProducSummary[index]
                                                                            .subtitle,
                                                                        state,
                                                                        listProducSummary[index]
                                                                            .lisProductData,
                                                                        featuredBloc,
                                                                        isMoreUnitIndex,
                                                                        cardBloc,
                                                                        dbHelper,
                                                                        _listScrolController[
                                                                            index],
                                                                        listProducSummary[index]
                                                                            .isLoadMore,
                                                                        backgroundColor,
                                                                        textColor,
                                                                        titleColor)
                                                                    : listProducSummary[index].uitype ==
                                                                            "2"
                                                                        ? Uistyle.ui_type2(
                                                                            true,
                                                                            context,
                                                                            state,
                                                                            listProducSummary[index]
                                                                                .title,
                                                                            listProducSummary[index]
                                                                                .subtitle,
                                                                            listProducSummary[index]
                                                                                .lisProductData,
                                                                            featuredBloc,
                                                                            isMoreUnitIndex,
                                                                            cardBloc,
                                                                            dbHelper,
                                                                            _listScrolController[
                                                                                index],
                                                                            listProducSummary[index]
                                                                                .isLoadMore,
                                                                            textColor,
                                                                            textsecondary,
                                                                            backgroundColor,
                                                                            abovecolor,
                                                                            titleColor,
                                                                            () {})
                                                                        : Uistyle.ui_type3(
                                                                            true,
                                                                            context,
                                                                            state,
                                                                            listProducSummary[index].title,
                                                                            listProducSummary[index].subtitle,
                                                                            listProducSummary[index].lisProductData,
                                                                            featuredBloc,
                                                                            isMoreUnitIndex,
                                                                            cardBloc,
                                                                            dbHelper,
                                                                            _listScrolController[index],
                                                                            listProducSummary[index].isLoadMore,
                                                                            backgroundColor,
                                                                            textColor,
                                                                            textsecondary,
                                                                            titleColor,
                                                                            buttonbackgroundcolor,
                                                                            buttontextcolor,
                                                                            listProducSummary[index].button_text,
                                                                            () {},
                                                                            listProducSummary[index].url,
                                                                            [],
                                                                            "");
                                                                //index==0?_scrollController:ScrollController()
                                                              }),
                                                        ),
                                                      );
                                                    }),
                                              ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
                  BlocProvider(
                      create: (context) => homePageBloc2,
                      child: BlocBuilder(
                        bloc: homePageBloc2,
                        builder: (BuildContext context, state) {
                          Appwidgets.setStatusBarDynamicLightColor(
                              color: Colors.transparent);
                          // SystemChrome.setSystemUIOverlayStyle(
                          //     SystemUiOverlayStyle(
                          //   statusBarColor:
                          //       Colors.transparent, // transparent status bar
                          //   statusBarIconBrightness:
                          //       Brightness.light, // dark icons on the status bar
                          // ));
                          if (state is HomeBottomSheetState) {
                            bottomviewstatus = state.status;
                          }

                          return bottomviewstatus
                              ? Container(
                                  height: Sizeconfig.getHeight(context),
                                  color: Colors.black12.withOpacity(0.2),
                                )
                              : Container();
                        },
                      )),
                  Container(
                    height: Sizeconfig.getHeight(context),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(),
                        Container(
                            child: Appwidgets.ShowBottomView33(
                                true,
                                context,
                                cardBloc,
                                featuredBloc,
                                ShopByCategoryBloc(),
                                animationBloc,
                                animationsizebottom,
                                0,
                                "",
                                true,
                                dbHelper,
                                () async {
                                  debugPrint(
                                      "OrderSummary Screen back >>>>>1 ${animationsizebottom}");

                                  Appwidgets.setStatusBarDynamicLightColor(
                                      color: Colors.transparent);

                                  // SystemChrome.setSystemUIOverlayStyle(
                                  //     SystemUiOverlayStyle(
                                  //   statusBarColor: Colors
                                  //       .transparent, // transparent status bar
                                  //   statusBarIconBrightness: Brightness
                                  //       .light, // dark icons on the status bar
                                  // ));

                                  await dbHelper
                                      .queryAllRowsCardProducts()
                                      .then((value) {
                                    debugPrint(
                                        "OrderSummary Screen back >>>>>1 ${value}");

                                    if (value.length == 0) {
                                      gotoHomepage();
                                    }
                                  });
                                },
                                () {
                                  debugPrint("OrderSummary Screen back >>>>>2");
                                  gotoHomepage();
                                },
                                () {
                                  debugPrint("OrderSummary Screen back >>>>>3");
                                },
                                true,
                                (value) {
                                  debugPrint("HomePage Screen back >>>>>");
                                  isOpenBottomview = value;
                                  homePageBloc2.add(HomeNullEvent());
                                  homePageBloc2
                                      .add(HomeBottomSheetEvent(status: value));
                                },
                                (height) {
                                  debugPrint("GGheight >> $height");
                                  animationsizebottom = 70.0;
                                })),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            /*          bottomNavigationBar: Appwidgets.ShowBottomView(
                context,
                cardBloc,
                featuredBloc,
                ShopByCategoryBloc(),
                animationBloc,
                animationsizebottom,
                0,
                "",
                true,
                dbHelper, () {
              debugPrint("OrderSummary Screen back >>>>>");
              SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                statusBarColor: Colors.transparent, // transparent status bar
                statusBarIconBrightness:
                    Brightness.light, // dark icons on the status bar
              ));
            }, true),*/
            /*
                BlocProvider(
                  create: (context) => checkoutBloc,
                  child: BlocBuilder(
                      bloc: checkoutBloc,
                      builder: (context, state) {
                        log("BottomState ${state}");

                        if (state is CheckoutShippingLoadEvent) {
                          loadshippingAmount = true;
                        }
                        // else
                        // {
                        //   loadshippingAmount=false;
                        // }
                        if (state is CheckoutPriceUpdateState) {
                          debugPrint("CheckoutPriceUpdateState " +
                              state.subtotoal.toString());
                          debugPrint("CheckoutPriceUpdateState " +
                              state.subtotoalcross.toString());

                          subtotal = state.subtotoal;
                          subtotalcross = state.subtotoalcross;
                          if (subtotalcross > subtotal) {
                            savingamount = subtotalcross - subtotal;
                          }

                          debugPrint("CheckoutPriceUpdateState " +
                              savingamount.toString());

                          grandtotal = subtotal + shippingCharge;
                        }

                        if (state is CheckoutShipingAmountState) {
                          isShowShipping = state.isShow;
                          shippingCharge = state.shippingCharges;
                          grandtotal = subtotal + shippingCharge;
                        }
                        return Container(
                          padding: EdgeInsets.only(bottom: 10),
                          color: Colors.transparent,
                          child: true
                              ? Container(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            height: 55,
                            child: Row(
                              children: [

                                Expanded(
                                    flex: 1,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0)),
                                          color: ColorName.ColorPrimary),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 0),
                                      child:
                                      state is CheckoutShippingLoadEvent &&
                                          loadProductValidation
                                          ? Center(
                                        child:
                                        CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      )
                                          : Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                            children: [
                                              Text(
                                                StringContants
                                                    .lbl_total_pay,
                                                style: TextStyle(
                                                  fontSize: Constants
                                                      .Sizelagre,
                                                  fontFamily:
                                                  Fontconstants
                                                      .fc_family_sf,
                                                  fontWeight:
                                                  Fontconstants
                                                      .SF_Pro_Display_Regular,
                                                ),
                                              ),
                                              Text(
                                                "${Constants.ruppessymbol} ${grandtotal.toStringAsFixed(2)}",
                                                style: TextStyle(
                                                  fontSize: Constants
                                                      .SizeMidium,
                                                  fontFamily:
                                                  Fontconstants
                                                      .fc_family_sf,
                                                  fontWeight:
                                                  Fontconstants
                                                      .SF_Pro_Display_Bold,
                                                ),
                                              )
                                            ],
                                          ),
                                          10.toSpace,
                                          InkWell(
                                            onTap: () async {
                                              Productvalidationswidgets
                                                  .loadProductValication(
                                                      context, cartitesmList,
                                                      () {


                                                dbHelper.loadAddCardProducts(
                                                    cardBloc);


                                              });
                                            },
                                            child: Row(
                                              children: [
                                                Text(
                                                "${StringContants.lbl_proced_checkout}",
                                                  style: TextStyle(
                                                    fontSize: Constants
                                                        .Sizelagre,
                                                    fontFamily:
                                                    Fontconstants
                                                        .fc_family_sf,
                                                    fontWeight:
                                                    Fontconstants
                                                        .SF_Pro_Display_SEMIBOLD,
                                                  ),
                                                ),
                                                10.toSpace,
                                                Image.asset(
                                                  Imageconstants.img_arrowright,
                                                  height: 10,
                                                  width: 10,
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          )
                              : Appwidgets.MyButton(
                              StringContants.lbl_add_your_address,
                              Sizeconfig.getWidth(context),
                                  () {}),
                        );
                      }),
                )*/
          ),
        ),
      ),
    );
  }

  getCocoApi(double latitude, double longitude, String cityName,
      String stateName) async {
    cocoCodeByLatLngResponse = await ApiProvider()
        .getCocoCodeByLatLngApi(latitude, longitude, cityName, stateName);
    if (cocoCodeByLatLngResponse!.success == true) {
      getTimeSlotsApi();
    }
  }

  getTimeSlotsApi() async {
    print("LOCALITY ${cocoCodeByLatLngResponse!.data!.cityName}");
    print("LOCALITY ${cocoCodeByLatLngResponse!.data!.locationId}");
    String addressId =
        await SharedPref.getStringPreference(Constants.ADDRESS_ID);
    String startDate = DateTime.now().toLocal().toString();
    var getTimeSlots = await ApiProvider().getTimeSlots(
        cocoCodeByLatLngResponse!.data!.locationId!, addressId, startDate, () {
      getTimeSlotsApi();
    });

    if (getTimeSlots.data != null && getTimeSlots.data!.isNotEmpty) {
      selectedDateSlot = getTimeSlots.data![0].date ?? "";
      if (getTimeSlots.data![0].timeslots != null &&
          getTimeSlots.data![0].timeslots!.isNotEmpty) {
        selectedTimeSlot =
            getTimeSlots.data![0].timeslots![0].timeSlotText ?? "";
      }
    }

    checkoutBloc.add(GetTimeSlotEvent(timeSlotResponse: getTimeSlots));
  }

  void getTimeSlotDialog() async {
    var selectedTimeSlot = await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: SelectTimeSlotDialog(
            getTimeSlotResponse: getTimeSlotResponse,
          ),
        );
      },
    );
    if (selectedTimeSlot != null) {
      checkoutBloc.add(TimeSlotSelectedEvent(
          selectedTimeSlot: selectedTimeSlot['selected_Time'],
          selectedDateSlot: selectedTimeSlot['selected_date'],
          selected_date_Text: selectedTimeSlot['selected_Date_Text']));
    }
  }

  bool isAddressEmpty() {
    return street == "" || locality == "" || locality == " " ? true : false;
  }
}
