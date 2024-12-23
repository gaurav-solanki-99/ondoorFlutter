import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondoor/screens/HomeScreen/HomeBloc/home_page_bloc.dart';
import 'package:ondoor/screens/HomeScreen/HomeBloc/home_page_event.dart';
import 'package:ondoor/screens/HomeScreen/HomeBloc/home_page_state.dart';
import 'package:ondoor/screens/profile_screen/profile_screen.dart';
import 'package:ondoor/screens/shop_by_category/shop_by_category_bloc/shop_by_category_bloc.dart';
import 'package:ondoor/services/ApiServices.dart';
import 'package:ondoor/services/Navigation/routes.dart';
import 'package:ondoor/utils/Connection.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/SizeConfig.dart';
import 'package:ondoor/utils/sharedpref.dart';
import 'package:ondoor/utils/shimmerUi.dart';
import 'package:ondoor/utils/themeData.dart';
import 'package:ondoor/widgets/HomeWidgetConst.dart';
import 'package:ondoor/widgets/MyDialogs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../constants/Constant.dart';
import '../../constants/CustomTextFormFilled.dart';
import '../../constants/FontConstants.dart';
import '../../constants/ImageConstants.dart';
import '../../constants/StringConstats.dart';
import '../../database/database_helper.dart';
import '../../database/dbconstants.dart';
import '../../main.dart';
import '../../models/AllProducts.dart';
import '../../models/HomepageModel.dart';
import '../../models/OrderSummaryProducts.dart';
import '../../models/TopProducts.dart';
import '../../models/locationvalidationmodel.dart';
import '../../services/NetworkConfig.dart';
import '../../utils/Comman_Loader.dart';
import '../../utils/Commantextwidget.dart';
import '../../utils/Utility.dart';
import '../../utils/colors.dart';
import '../../widgets/AppWidgets.dart';
import '../../widgets/Bannerwidegets.dart';
import '../../widgets/UiStyle.dart';
import '../AddCard/card_bloc.dart';
import '../FeaturedProduct/FeatuuredBloc/featured_bloc.dart';
import '../FeaturedProduct/FeatuuredBloc/featured_event.dart';
import '../FeaturedProduct/FeatuuredBloc/featured_state.dart';
import '../NewAnimation/animation_bloc.dart';
import '../NewAnimation/animation_event.dart';
import 'package:http/http.dart' as http;

class Homepagescreen extends StatefulWidget {
  const Homepagescreen({super.key});

  @override
  State<Homepagescreen> createState() => _HomepagescreenState();
}

class _HomepagescreenState extends State<Homepagescreen> {
  ScrollController scrollController = ScrollController();

  var street = "";
  var locality = "";
  List<Category>? categoriesList = [];
  List<Banners> banners = [];
  HomePageBloc homePageBloc = HomePageBloc();
  HomePageBloc homePageBloc2 = HomePageBloc();
  AnimationBloc animationBloc = AnimationBloc();
  int isMoreUnitIndex = 0;
  var animationsizebottom = 0.0;
  final dbHelper = DatabaseHelper();
  CardBloc cardBloc = CardBloc();

  String notificatonCount = "";
  String searchint = "";
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
    TopProducts(
        imageUrl: Imageconstants.img_offers,
        name: StringContants.lbl_offrs,
        quantitiy: 0),
  ];
  List<String> listBanner = [
    "https://img.freepik.com/premium-vector/food-delivery-online-mobile-phone-shopping-online-online-food-order-internet-ecommerce-concept-website-banner-3d-perspective-vector-illustration_473922-75.jpg",
    "https://img.freepik.com/premium-vector/food-delivery-online-mobile-phone-shopping-online-online-food-order-internet-ecommerce-concept-website-banner-3d-perspective-vector-illustration_473922-75.jpg",
    "https://img.freepik.com/premium-vector/food-delivery-online-mobile-phone-shopping-online-online-food-order-internet-ecommerce-concept-website-banner-3d-perspective-vector-illustration_473922-75.jpg",
    "https://img.freepik.com/premium-vector/food-delivery-online-mobile-phone-shopping-online-online-food-order-internet-ecommerce-concept-website-banner-3d-perspective-vector-illustration_473922-75.jpg",
    "https://img.freepik.com/premium-vector/food-delivery-online-mobile-phone-shopping-online-online-food-order-internet-ecommerce-concept-website-banner-3d-perspective-vector-illustration_473922-75.jpg",
  ];
  bool isScroll = false;
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey<ScaffoldState>();
  List<String> searchtext = [];
  bool isOpenBottomview = false;
  bool bottomviewstatus = false;
  List<OrderSummaryProductsDatum> listProducSummary = [];
  FeaturedBloc featuredBloc = FeaturedBloc();
  List<ScrollController> _listScrolController = [];
  ScrollController _scrollController = ScrollController();
  int pageno = 0;
  bool mainloadmore = true;
  List<int> pageno_list = [];
  bool showcategory = true;

  var appbarcolor = ColorName.ColorPrimary;
  var appbartextcolor = Colors.white;

  bool homepageVisisblility = false;
  bool dilaogVisiblity = true;

  int read_notification_batch = 0;

  @override
  void initState() {
    Constants.tv_email = "";
    Constants.tv_name = "";
    Constants.tv_number = "";

    debugPrint("HomePage>>>>");
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: ColorName.ColorPrimary,
        statusBarBrightness: Brightness.light // Set status bar color here
        ));
    OndoorThemeData.keyBordDow();

    _scrollController.addListener(_scrollListener);
    initializedDb();
    // getTopProductHomeScreen(false);
    // loadData();
    // checkCreditRequest();
    //
    // getNotificationCount();
    checkNotificationRoute();
    reloadHomepage();
    SharedPref.setStringPreference(Constants.OrderidForEditOrder, "");
    SharedPref.setStringPreference(Constants.OrderPlaceFlow, "");
    super.initState();
  }

  reloadHomepage() async {
    pageno = 0;

    read_notification_batch = await SharedPref.getIntegerPreference(
            Constants.show_notification_bach) ??
        0;
    if (await Network.isConnected()) {
      getTopProductHomeScreen(false);
      initializedDb();

      loadData();
      checkCreditRequest();

      getNotificationCount();
    } else {
      MyDialogs.showInternetDialog(context, () {
        Navigator.pop(context);
        reloadHomepage();
      });
    }
    //  17:33:46.423949
    // 0 17:33:46.449579
    // 1 17:33:46.450068
    // 2 17:33:51.555560
    // 3 17:33:51.555656

    // 1 17:34:31.143173
    // 2 17:34:35.966814
    // 3 17:34:35.966879
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose of the controller
    CommanLoader().dismissEasyLoader();
    super.dispose();
  }

  checkNotificationRoute() async {
    String data =
        await SharedPref.getStringPreference(Constants.sp_notificationdata);

    debugPrint("checkNotificationRoute1  $data");
    debugPrint("checkNotificationRoute1  ${Constants.notificationdata}");

    if (data != null && data != "") {
      _handleNotificationTap(data);
      // await SharedPref.setStringPreference(Constants.sp_notificationdata, "");
    }
  }

  void _handleNotificationTap(String data) async {
    if (data.isNotEmpty) {
      await DioFactory().getDio();
      // Example: Navigate to a specific screen based on notification data
      String customer_id =
          await SharedPref.getStringPreference(Constants.sp_CustomerId);
      String token_type =
          await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
      String access_token =
          await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);

      String token = "$token_type $access_token";
      if (token == ' ' && customer_id == '') {
        await SharedPref.setStringPreference(
            Constants.sp_VerifyRoute, Routes.notification_center);
        Navigator.pushNamed(navigationService.navigatorKey.currentContext!,
                Routes.register_screen,
                arguments: Routes.home_page)
            .then(
          (value) {
            Appwidgets.setStatusBarColor();
          },
        );
      } else {
        debugPrint("checkNotificationRoute 2  $data");

        // try
        //   {
        String input = data;
        String? orderId;
        String? type;
        // Replace single quotes with double quotes to make it valid JSON
        // input = input.replaceAllMapped(RegExp(r'(\w+):'), (match) {
        //   return '"${match[1]}":';
        // });

        // String jsonFormatted = input
        //     .replaceAllMapped(RegExp(r'(\w+):'), (
        //     match) => '"${match[1]}":') // Add quotes to keys
        //     .replaceAllMapped(RegExp(r': (\w+)'), (
        //     match) => ': "${match[1]}"'); // Add quotes to values

        // Decode the JSON string
        //  Map<String, dynamic> data2 = jsonDecode(jsonFormatted);
        //   Map<String, dynamic> data2 = jsonDecode(data) ;
        //
        //   // Access the values
        //   String type = data2['type'];
        //
        //
        //   debugPrint('checkNotificationRoute Type: $type');

        if (input.contains("type")) {
          // RegExp orderIdRegExp = RegExp(r'type: (\d+)');
          // type = orderIdRegExp.firstMatch(input)?.group(1)?.trim();

          // Extract 'type'
          RegExp typeRegExp = RegExp(r'type: (.*?),');
          type = typeRegExp.firstMatch(input)?.group(1)?.trim();
        }

        // Extract 'title'
        RegExp titleRegExp = RegExp(r'title: (.*?),');
        String? title = titleRegExp.firstMatch(input)?.group(1)?.trim();

        // Extract 'message'
        RegExp messageRegExp = RegExp(r'message: (.*?), order_id:');
        String? message = messageRegExp.firstMatch(input)?.group(1)?.trim();

        // Extract 'order_id'
        if (input.contains("order_id")) {
          RegExp orderIdRegExp = RegExp(r'order_id: (\d+)');
          orderId = orderIdRegExp.firstMatch(input)?.group(1)?.trim();
        }

        debugPrint("Title: $title");
        debugPrint("Message: $message");
        debugPrint("Order ID: $orderId");
        debugPrint("Type: $type");

        if (type == "Order") {
          //String orderId = data2['order_id'];
          debugPrint('checkNotificationRoute Order ID: $orderId');

          if (orderId != null && orderId != "null" && orderId != "") {
            Navigator.pushNamed(navigationService.navigatorKey.currentContext!,
                Routes.order_history_detail,
                arguments: {"order_id": orderId, "order_type": ""});
          } else {
            Navigator.pushNamed(navigationService.navigatorKey.currentContext!,
                Routes.order_history);
          }
        } else if (type == "General") {
          //String orderId = data2['order_id'];
          debugPrint('checkNotificationRoute Order ID: $orderId');

          Navigator.pushNamed(navigationService.navigatorKey.currentContext!,
                  Routes.notification_center)
              .then(
            (value) {
              Appwidgets.setStatusBarColor();
            },
          );
        } else {
          // Navigator.pushNamed(navigationService.navigatorKey.currentContext!,
          //     Routes.notification_center)
          //     .then(
          //       (value) {
          //     Appwidgets.setStatusBarColor();
          //   },
          // );
        }

        //   }
        /*     catch(e)
    {
      Navigator.pushNamed(navigationService.navigatorKey.currentContext!,
          Routes.notification_center)
          .then(
            (value) {
          Appwidgets.setStatusBarColor();
        },
      );
    }*/
      }
    }
  }

  // @override
  // void _scrollListener() {
  //   print(
  //       "_scrollController_scrollController ****${_scrollController.position.maxScrollExtent}");
  //   print(
  //       "_scrollController_scrollController ****${_scrollController.offset.toInt()}");
  //   if (_scrollController.offset.toInt() ==
  //       _scrollController.position.maxScrollExtent.toInt()) {
  //     // if (loadmore == true) {
  //     //   cheflist(pageNo, "", "", "", "", "", searchController.text);
  //     // }
  //
  //     print("_scrollListener call $mainloadmore");
  //
  //     if (mainloadmore == true) {
  //       getTopProductHomeScreen(true);
  //     } else {
  //       //_scrollController.dispose();
  //     }
  //   }
  // }

  @override
  void _scrollListener() {
    final scrollPosition = _scrollController.position;
    final maxScrollExtent = scrollPosition.maxScrollExtent;
    final currentOffset =
        _scrollController.position.pixels; // Current scroll position

    debugPrint("Current Offset: $currentOffset, Max Extent: $maxScrollExtent");

    // Trigger API call when within a threshold of the bottom (e.g., 200 pixels)
    var preloadThreshold = Sizeconfig.getHeight(context) + 200;

    if ((maxScrollExtent - currentOffset) <= preloadThreshold) {
      if (mainloadmore && !_isLoadingPagination) {
        if (mainloadmore == true) {
          _isLoadingPagination = true;
          debugPrint("Preloading next page...");
          getTopProductHomeScreen(true);
        } else {
          debugPrint("No more data to load.");
        }
      }
    }
  }

  Future<String> getStreetAddress() async {
    return await SharedPref.getStringPreference(Constants.ADDRESS) ?? "";
  }

  Future<String> getLocalityAddress() async {
    return await SharedPref.getStringPreference(Constants.LOCALITY) ?? "";
  }

  Timer? _debounce;
  bool _isLoading = false;
  /*void _scrollListenerlist(int index, String url, bool loadmore) {



    if (_listScrolController[index].offset.toInt() ==
       listProducSummary[index].scrollController.position.maxScrollExtent.toInt()) {
      // if (loadmore == true) {
      //   cheflist(pageNo, "", "", "", "", "", searchController.text);
      // }

      debugPrint("_scrollListenerlist call $index  ${loadmore}");

      if (loadmore) {
        getHomePageProductPagination(loadmore, url, index);
      }
    }
  }*/

  void _scrollListenerlist(int index, String url, bool loadmore) {
    if (listProducSummary[index].scrollController.offset.toInt() ==
            listProducSummary[index]
                .scrollController
                .position
                .maxScrollExtent
                .toInt() &&
        !_isLoading) {
      if (loadmore) {
        _isLoading = true;
        debugPrint("_scrollListenerlist call $index  $loadmore  URL $url");

        getHomePageProductPagination(loadmore, url,
                index) /*.then((_) {
            _isLoading = false;
          }).catchError((error) {
            _isLoading = false;
          })*/
            ;
      }
    }
    // if (_debounce?.isActive ?? false)
    //   _debounce!.cancel(); // Cancel previous Timer
    //
    // _debounce = Timer(const Duration(milliseconds: 300), () {
    //
    // });
  }

  getHomePageProductPagination(bool loadmore, String url, int index) {
    // ApiProvider().getSimilarProducts("").th;

    int pageno = pageno_list[index];
    debugPrint(
        "getHomePageProductPagination api call1 ${listProducSummary[index].isLoadMore}");
    debugPrint(
        "getHomePageProductPagination api call1 page ${pageno_list[index]}");

    if (listProducSummary[index].isLoadMore) {
      pageno_list[index] = pageno + 1;
      debugPrint(
          "getHomePageProductPagination api call2 ${pageno_list[index]}");

      ApiProvider()
          .getHomeProductPagination(pageno_list[index], url)
          .then((value) async {
        final responseData = jsonDecode(value.toString());
        _isLoading = false;
        if (responseData["success"]) {
          debugPrint(
              "getHomePageProductPagination api call3 ${responseData["success"]}");
          debugPrint("getHomePageProductPagination Product Listing " + value);

          ProductsModel productsModel =
              ProductsModel.fromJson(value.toString());

          debugPrint("getbeforeYourCheckoutPagination Product Listing " +
              productsModel.data!.length.toString());

          List<ProductData> paginationlist = productsModel.data;

          featuredBloc.add(ProductListEmptyEvent());
          featuredBloc.add(
              ProductForPaginationEvent(list: paginationlist, index: index));
        } else {
          debugPrint(
              "getHomePageProductPagination api call3 ${responseData["success"]}");
          listProducSummary[index].isLoadMore = false;
          featuredBloc.add(ProductListEmptyEvent());
          featuredBloc.add(ProductLoadMoreEvent(index: index, loadmore: false));
        }
      });
    }
  }

  initializedDb() async {
    loadData();
    cardBloc = CardBloc();
    await dbHelper.init();
    dbHelper.loadAddCardProducts(cardBloc);
  }

/*
  initializedDb2() async {
    cardBloc = CardBloc();
    await dbHelper.init();
    dbHelper.loadAddCardProducts(cardBloc);
  }
*/

  loadData() async {
    street = await getStreetAddress();
    locality = await getLocalityAddress();

    if (await Network.isConnected()) {
      Map<String, String> formData = {
        "location_id": "1",
      };
      ApiProvider().getNewCategory(formData).then((value) async {
        debugPrint("ResponseGGG  " + value.banners!.length.toString());

        List<Category>? list = value.categories;

        for (var i = 0; i < list!.length; i++) {
          var x = list[i];

          if (x.image != "") {
            var name = x.image!.split("/").last;
            String largeImagePath = "";
            largeImagePath = await _downloadAndSaveImage(x.image!, '${name}');
            x.image = largeImagePath ?? "";
            list[i].image = x.image;
          }
        }

        homePageBloc.add(HomePageCategoryEvent(
            categories: value.categories, bannersList: value.banners!));
      });
    } else {
      debugPrint(StringContants.lbl_network);
      // MyDialogs.showInternetDialog(context, () {
      //   Navigator.pop(context);
      //  // loadData();
      // });
    }

    debugPrint("Load Data CardBloc ${cardBloc.state}");

    //locationValidation();
  }

/*
  locationValidation() async {
    await dbHelper.init();
    List<ProductUnit> cartlist = await dbHelper.getAllCarts(cardBloc);

    debugPrint("Load Data GGG ${cartlist.length}");

    String location_id =
        await SharedPref.getStringPreference(Constants.LOCATION_ID);
    String coustomerId =
        await SharedPref.getStringPreference(Constants.sp_CustomerId);
    String token_type =
        await SharedPref.getStringPreference(Constants.sp_TOKENTYPE);
    String access_token =
        await SharedPref.getStringPreference(Constants.sp_AccessTOEKN);
    String store_id = await SharedPref.getStringPreference(Constants.STORE_ID);
    String store_code =
        await SharedPref.getStringPreference(Constants.STORE_CODE);
    String store_name =
        await SharedPref.getStringPreference(Constants.STORE_Name);
    String wms_store_id =
        await SharedPref.getStringPreference(Constants.WMS_STORE_ID);

    loadLocationValidation(store_id ?? "", store_name ?? "", wms_store_id ?? "",
        location_id ?? "", store_code ?? "", cartlist);

    //ApiProvider()
    //     .productValidationcheckout(cartlist,
    //   store_id ?? "",
    //   store_name??"",
    //   wms_store_id ?? "",
    //   location_id?? "",
    //   store_code ?? "",
    //
    // )
    //     .then((value) {
    //   if (value != "") {
    //     if (value
    //         .toString()
    //         .contains("change_address_message")) {
    //       final responseData =
    //       jsonDecode(value.toString());
    //       var  change_address_message = responseData["change_address_message"];
    //       debugPrint("change_address_message ${change_address_message}");
    //
    //
    //       MyDialogs.showAlertDialog(context, change_address_message, "Yes", "No", (){
    //
    //         loadLocationValidation(
    //           store_id ?? "",
    //           store_name??"",
    //           wms_store_id ?? "",
    //           location_id?? "",
    //           store_code ?? "",
    //           cartlist
    //         );
    //         Navigator.pop(context);
    //       }, (){
    //         Navigator.pop(context);
    //       });
    //
    //       // showDialog(
    //       //   context: context,
    //       //   barrierDismissible: false,
    //       //   builder: (context) => WillPopScope(
    //       //     onWillPop: () async {
    //       //       return false;
    //       //     },
    //       //     child: AlertDialog(
    //       //
    //       //       shape: RoundedRectangleBorder(
    //       //           borderRadius:
    //       //           BorderRadius.circular(
    //       //               12)),
    //       //       title: Text(
    //       //         "${change_address_message}",
    //       //         style: Appwidgets()
    //       //             .commonTextStyle(
    //       //             ColorName.black),
    //       //       ),
    //       //       actions: [
    //       //         GestureDetector(
    //       //             onTap: () async {
    //       //               loadLocationValidation(
    //       //                 selectedAddressData.storeId ?? "",
    //       //                 selectedAddressData.storeName??"",
    //       //                 selectedAddressData.wmsStoreId ?? "",
    //       //                 selectedAddressData.locationId ?? "",
    //       //                 selectedAddressData.storeCode ?? "",
    //       //               );
    //       //              Navigator.pop(context);
    //       //
    //       //             },
    //       //             child: Text("Yes",
    //       //                 style: Appwidgets()
    //       //                     .commonTextStyle(
    //       //                     ColorName
    //       //                         .ColorPrimary))),
    //       //
    //       //         GestureDetector(
    //       //             onTap: () async {
    //       //
    //       //               Navigator.pop(context);
    //       //
    //       //             },
    //       //             child: Text("No",
    //       //                 style: Appwidgets()
    //       //                     .commonTextStyle(
    //       //                     ColorName
    //       //                         .black))),
    //       //
    //       //
    //       //       ],
    //       //     ),
    //       //   ),
    //       // );
    //     }
    //
    //
    //   }
    // });
  }
*/

  loadLocationValidation(
      String store_id1,
      String store_name1,
      String wms_store_id1,
      String location_id1,
      String store_code1,
      List<ProductUnit> cartitesmList) {
    ApiProvider().locationproductValidation(cartitesmList, store_id1,
        store_name1, wms_store_id1, location_id1, store_code1, () {
      loadLocationValidation(store_id1, store_name1, wms_store_id1,
          location_id1, store_code1, cartitesmList);
    }).then((value) {
      debugPrint("ONADDRESSCHANGE locationproductValidation");

      if (value != "") {
        LocationProductsModel locationProduucts =
            LocationProductsModel.fromJson(value.toString());
        debugPrint("ONADDRESSCHANGE locationproductValidation 3 ${value}");
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

                  Navigator.pop(context);
                  updateCard(cartitesmList[i], i, cartitesmList);
                } else if ((updatelist[j].outOfStock == "1" &&
                    updatelist[j].productId == cartitesmList[i].productId)) {
                  debugPrint("GCondition 2");
                  await dbHelper
                      .deleteCard(int.parse(cartitesmList[i].productId!))
                      .then((value) {
                    Navigator.of(context)
                        .pushReplacementNamed(Routes.home_page);
                  });
                }
              }
            }
          }, () async {
            await dbHelper.cleanCartDatabase().then((value) {
              dbHelper.loadAddCardProducts(cardBloc);

              Navigator.of(context).pushReplacementNamed(Routes.home_page);
            });
          });
        } else {}
      }
    });
  }

  updateCard(ProductUnit model, int index, var list) async {
    int status = await dbHelper.updateCard({
      DBConstants.PRODUCT_ID: int.parse(model.productId!),
      DBConstants.QUANTITY: model.addQuantity,
      DBConstants.PRICE: model.price,
      DBConstants.SORT_PRICE: model.sortPrice,
      DBConstants.SPECIAL_PRICE: model.specialPrice,
    });

    debugPrint("Update Product Status " + status.toString());
    initializedDb();
    Navigator.pop(context);
  }

  checkCreditRequest() async {
    if (await Network.isConnected()) {
      await ApiProvider().checkCreditRequest(() async {
        checkCreditRequest();
      }).then((value) {
        debugPrint("Response checkCreditRequest $value${jsonEncode(value)}");
        if (value != null) {
          SharedPref.setStringPreference(
              Constants.sp_subscribePopupHeading,
              value.subscribePopupHeading != ""
                  ? value.subscribePopupHeading!
                  : "Schedule Delivery");
          SharedPref.setStringPreference(
              Constants.sp_morningText,
              value.morningText != ""
                  ? value.morningText!
                  : "Morning-(monthly)");
          SharedPref.setStringPreference(
              Constants.sp_eveningText,
              value.eveningText != ""
                  ? value.eveningText!
                  : "Evening-(monthly)");
          SharedPref.setStringPreference(Constants.sp_saveText,
              value.saveText != "" ? value.saveText! : "Save");
          SharedPref.setStringPreference(Constants.sp_cancelText,
              value.cancelText != "" ? value.cancelText! : "Cancel");
          SharedPref.setStringPreference(
              Constants.sp_selectAnyWeekDayForMorning,
              value.selectAnyWeekdayForMorning != ""
                  ? value.selectAnyWeekdayForMorning!
                  : "Please select any day for morning");
          SharedPref.setStringPreference(
              Constants.sp_selectAnyWeekDayForEvening,
              value.selectAnyWeekdayForEvening != ""
                  ? value.selectAnyWeekdayForEvening!
                  : "Please select any day for evening");
          SharedPref.setStringPreference(
              Constants.sp_SelectQuantityForMorning,
              value.selectQuantityForMorning != ""
                  ? value.selectQuantityForMorning!
                  : "Please select quantity for morning");
          SharedPref.setStringPreference(
              Constants.sp_SelectQuantityForEvening,
              value.selectQuantityForEvening != ""
                  ? value.selectAnyWeekdayForEvening!
                  : "Please select quantity for evening");
          SharedPref.setStringPreference(
              Constants.sp_selectAnyOptionToSave,
              value.selectAnyOptionToSave != ""
                  ? value.selectAnyOptionToSave!
                  : "Please select any option to save");
          SharedPref.setBooleanPreference(
              Constants.sp_SHOW_MORNING_OPTION,
              value.showMorningOption != null
                  ? value.showMorningOption!
                  : false);
          SharedPref.setBooleanPreference(
              Constants.sp_SHOW_EVENING_OPTION,
              value.showEveningOption != null
                  ? value.showEveningOption!
                  : false);
          SharedPref.setStringPreference(Constants.sp_resetText,
              value.resetText != "" ? value.resetText! : "Unsubscribe");
          SharedPref.setStringPreference(
              Constants.sp_SUBSCRIPTION_TEXT,
              value.subscritionText != ""
                  ? value.subscritionText!
                  : "Subscription");
          SharedPref.setStringPreference(
              Constants.sp_CREATE_SUBSCRIPTION_TEXT,
              value.createSubscritionText != ""
                  ? value.createSubscritionText!
                  : "Create Subscription");
          SharedPref.setStringPreference(
              Constants.sp_MY_SUBSCRIPTION_TEXT,
              value.mySubscritionText != ""
                  ? value.mySubscritionText!
                  : "My Subscription");
          SharedPref.setStringPreference(
              Constants.sp_MY_SUBSCRIPTION_BOTTOM_TAB_TEXT,
              value.mySubscritionBottomTabText != ""
                  ? value.mySubscritionBottomTabText!
                  : "My Subscription");
          SharedPref.setStringPreference(
              Constants.sp_MY_SUBSCRIPTION_BOTTOM_TAB_HISTORY_TEXT,
              value.mySubscritionBottomTabHistoryText != ""
                  ? value.mySubscritionBottomTabHistoryText!
                  : "History");
          SharedPref.setStringPreference(
              Constants.sp_MY_SUBSCRIPTION_BOTTOM_TAB_RENEW_TEXT,
              value.mySubscritionBottomTabRenewText != ""
                  ? value.mySubscritionBottomTabRenewText!
                  : "History");
          SharedPref.setStringPreference(
              Constants.sp_MY_SUBSCRIPTION_HEADER_TITLE,
              value.mySubscriptionHeaderTitle != ""
                  ? value.mySubscriptionHeaderTitle!
                  : "My Subscription");
          SharedPref.setStringPreference(
              Constants.sp_UNSUBSCRIBE_MESSAGE,
              value.unsubscribe_message != ""
                  ? value.unsubscribe_message!
                  : "Are you sure you want to unsubscribe?");
          SharedPref.setStringPreference(
              Constants.sp_ADD_ON_PAYMENT_MESSAGE,
              value.addOnPaymentMessage != ""
                  ? value.addOnPaymentMessage!
                  : "Please pay for subscription before adding addon");
          SharedPref.setStringPreference(
              Constants.sp_SUBSCRIPTION_DETAILS,
              value.subscriptionDetails != ""
                  ? value.subscriptionDetails!
                  : "Subscription Details");
          SharedPref.setStringPreference(
              Constants.sp_ADDON_PRODUCTS,
              value.addonProducts != ""
                  ? value.addonProducts!
                  : "Addon Products");
          SharedPref.setStringPreference(
              Constants.sp_EDIT_SUBSCRIPTION,
              value.editSubscription != ""
                  ? value.editSubscription!
                  : "Edit Subscription");
          SharedPref.setStringPreference(
              Constants.sp_ARE_YOU_SURE_YOU_WANT_TO_DELETE,
              value.deleteMessage != ""
                  ? value.deleteMessage!
                  : "Are you sure you want to delete this product?");
          SharedPref.setStringPreference(
              Constants.sp_SELECT_DATE_ADDON_HEADING,
              value.selectDateAddonHeading != ""
                  ? value.selectDateAddonHeading!
                  : "Select Date");
          SharedPref.setStringPreference(
              Constants.sp_DISABLE_DATE_MESSAGE,
              value.disableDateMessage != ""
                  ? value.disableDateMessage!
                  : "You are not eligible to create an add on for the selected date, please select the available date from the calender.");
          SharedPref.setStringPreference(
              Constants.sp_FINAL_BASKET_ADD_ON_HEADING,
              value.finalBasketAddOnHeading != ""
                  ? value.finalBasketAddOnHeading!
                  : "Addon Products");
          SharedPref.setStringPreference(
              Constants.sp_FINAL_BASKET_ADD_ON_FOOTER,
              value.finalBasketAddOnFooter != ""
                  ? value.finalBasketAddOnFooter!
                  : "Create Addon");

          // show offers dialog
          if (value.smartOffer != null) {
            String? image_url = value.smartOffer!.smartOfferList!.imageUrl;

            debugPrint(
                "HomeScreenVisibility dilaog $homepageVisisblility $dilaogVisiblity");
            if (homepageVisisblility && dilaogVisiblity) {
              MyDialogs.offersDialogMain(context, image_url!);
              dilaogVisiblity = false;
            }
          }
        }
      });
    } else {
      debugPrint(StringContants.lbl_network);
    }
  }

  // getLocations() async {
  //   await  Constantss.getCurrentLocation().then((value) async {
  //    await  Constantss.getPlacemarks(value!.latitude!,value.longitude!).then((value){
  //      debugPrint("Home Page Data $value");
  //
  //
  //      homePageBloc.add(HomePageIntialEvent(
  //          addressline1: value.last.subLocality!,
  //          addressline2: value.last.locality!));
  //      // homePageBloc.addressline1 = value.last.subLocality!;
  //      // homePageBloc.addressline2 = value.last.locality!;
  //
  //      debugdebugPrint("Home Bloc "+value.last.locality! );
  //
  //      loadData();
  //
  //
  //    });
  //   });
  // }

  // Download image from network
  Future<String> _downloadAndSaveImage(String url, String fileName) async {
    debugPrint("_downloadAndSaveImage $url");
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';

    if (await File(filePath).exists() == false) {
      final response = await http.get(Uri.parse(url));

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
    }

    return filePath;
  }

/*
  saveSaerchText(List<Category>? categoriesList) async {
    searchtext = await SharedPref.getListPreference(Constants.sp_searchtext);
    for (var x in categoriesList!) {
      if (searchtext.contains(x.name) == false) {
        searchtext.add(x.name!);
      }
    }

    await SharedPref.setListPreference(Constants.sp_searchtext, searchtext);

    debugPrint(
        "saveSaerchText ${await SharedPref.getListPreference(Constants.sp_searchtext)}");
  }
*/

/*
  getSearchText() async {
    searchtext = await SharedPref.getListPreference(Constants.sp_searchtext);
    // debugPrint("searchtext >>  ${searchtext}");
    // String name = "";
    // for (var x in searchtext) {
    //   name = x;
    //   await Future.delayed(Duration(seconds: 2));
    //   searchint = name;
    //   homePageBloc.add(UpdateSearchTextHomeEvent(text: searchint));
    //   debugPrint("serchhint ${searchint}");
    // }
    //  getSearchText();
  }
*/

  bool _isLoadingPagination = false;
  getTopProductHomeScreen(bool loadmore) {
    // ApiProvider().getSimilarProducts("").th;
    debugPrint("getTopProductHomeScreen api call");
    // if (loadmore) {
    //   pagenolist1++;
    // }

    pageno = pageno + 1;
    ApiProvider().getTopSellingProductHomeScreenFV1(context, pageno, () {
      debugPrint("getTopSellingProductHomeScreenFV1 Empty* ");
      featuredBloc.add(ProductListEmptyEvent());
      // featuredBloc.add(ProductNullEvent());
      mainloadmore = false;
    }).then((value) async {
      debugPrint("getTopProductHomeScreen api response 2 $value");
      if (value != "") {
        _isLoadingPagination = false;
        OrderSummaryProducts orderSummaryProducts =
            OrderSummaryProducts.fromJson(value.toString());

        if (loadmore) {
          listProducSummary.addAll(orderSummaryProducts.data);
        } else {
          listProducSummary = orderSummaryProducts.data;
        }

        for (int index = 0; index < listProducSummary.length; index++) {
          listProducSummary[index].scrollController = ScrollController();
          // _listScrolController
          //     .add(ScrollController());

          listProducSummary[index].scrollController.addListener(() {
            _scrollListenerlist(index, listProducSummary[index].url,
                listProducSummary[index].isLoadMore);
          });

          if (index == 0 && listProducSummary[index].uitype == "18") {
            debugPrint("ShowProductcategory Items ");
            showcategory = false;
          }

          //GCacheImage
          if (listProducSummary[index].backgroundImage != "") {
            var name =
                listProducSummary[index].backgroundImage!.split("/").last;
            String largeImagePath = "";
            debugPrint("listProducSummaryImagePath >>1 ${name}");
            largeImagePath = await _downloadAndSaveImage(
                listProducSummary[index].backgroundImage, '${name}');
            debugPrint("ulistProducSummaryImagePath >>2 ${largeImagePath}");
            listProducSummary[index].backgroundImage = largeImagePath;
          }
          pageno_list.add(1);
          debugPrint(
              "getTopProductHomeScreen ProductData Data  ${listProducSummary[index].toJson()}");
          debugPrint(
              "getTopProductHomeScreen%%%%% $index ${listProducSummary[index].data.toString() == "[]"}");

          if (listProducSummary[index].data.toString() == "[]" ||
              listProducSummary[index].data.toString() == "null" ||
              listProducSummary[index].data.toString() == "") {
            debugPrint("getTopSellingProductHomeScreenFV1%%%%%True");
          } else if (listProducSummary[index].model_type == "1") {
            List<ProductData> productData2 = List<ProductData>.from(
                listProducSummary[index]
                    .data!
                    .map((x) => ProductData.fromMap(x)));
            debugPrint(
                "getTopSellingProductHomeScreenFV1 ProductData Data22  ${productData2.length}");
            listProducSummary[index].lisProductData = productData2;
          } else if (listProducSummary[index].model_type == "3") {
            List<Banners> bannerslist = List<Banners>.from(
                listProducSummary[index].data!.map((x) => Banners.fromMap(x)));
            debugPrint(
                "getTopSellingProductHomeScreenFV1Banner>>>>>${bannerslist}");
            listProducSummary[index].listbanners = bannerslist;
          } else if (listProducSummary[index].model_type == "2") {
            List<SubCategory> list = List<SubCategory>.from(
                listProducSummary[index]
                    .data!
                    .map((x) => SubCategory.fromMap(x)));
            debugPrint("getTopSellingProductHomeScreenFV1Banner>>>>>${list}");
            listProducSummary[index].listsubcategory = list;
          } else if (listProducSummary[index].model_type == "4") {
            List<Category> list = List<Category>.from(
                listProducSummary[index].data!.map((x) => Category.fromMap(x)));
            debugPrint("getTopSellingProductHomeScreenFV1Banner>>>>>${list}");
            listProducSummary[index].listcategory = list;
          }
        }

        featuredBloc.add(LoadedOrderSummaryEvent(
            listProducSummary: listProducSummary,
            backgroundColor: orderSummaryProducts.backgroundColor,
            backgroundImage: orderSummaryProducts.backgroundImage,
            appbarTitle: orderSummaryProducts.appbarTitle,
            appbarTitleColor: orderSummaryProducts.appbarTitleColor));
      } else {
        _isLoadingPagination = false;
      }
    });
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
      var newmodel = lisProductData![index].unit![0];
      debugPrint("getCartQuanity $index ${newmodel.toJson()}");
      try {
        getCartQuantity(newmodel.productId!).then((value) {
          if (value > 0) {
            debugPrint(
                "getCartQuanity name  ${lisProductData![index].unit![0].name}");
          }
          lisProductData![index].unit![0].addQuantity = value;
          featuredBloc.add(ProductInitialSummaryEvent(
              list: lisProductData, index: unitIndex, loadmore: isloaded));
          // featuredBloc.add(ProductNullEvent());
        });

        if (newmodel!.cOfferId != 0 && newmodel.cOfferId != null) {
          debugPrint("***********************");
          if (newmodel.subProduct != null) {
            log("***********************>>>>>>>>>>>>>>>>${newmodel.subProduct!.toJson()}");
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
              // featuredBloc.add(ProductNullEvent());
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
    return SafeArea(
      bottom: false,
      child: VisibilityDetector(
        key: const Key("HaomePageScreen"),
        onVisibilityChanged: (VisibilityInfo info) async {
          debugPrint("RegisterdScreen");

          // await Future.delayed(Duration(seconds: 1), () {
          //   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          //     statusBarColor: Colors.transparent, // transparent status bar
          //     statusBarIconBrightness:
          //         Brightness.light, // dark icons on the status bar
          //   ));
          // });

          var visiblePercentage = info.visibleFraction * 100;
          if (visiblePercentage == 100) {
            debugPrint("HomeScreenVisibility true");
            homepageVisisblility = true;
            mainloadmore = true;
            //reloadHomepage();
          } else {
            debugPrint("HomeScreenVisibility false ");
            homepageVisisblility = false;
          }
        },
        child: BlocProvider(
          create: (context) => homePageBloc,
          child: BlocBuilder<HomePageBloc, HomePageState>(
              bloc: homePageBloc,
              builder: (context, state) {
                debugPrint("HomePageState >> $state");

                if (state is HomeNotificationState) {
                  notificatonCount = state.notification_count;
                }

                if (state is UpdateSearchTextHomeState) {
                  searchint = state.text;
                }

                if (state is HomePageData) {
                  street = state.addressline1 ?? "";
                  locality = state.addressline2 ?? "";
                }

                if (state is HomePageCategoryState) {
                  categoriesList = state.categories;
                  banners = state.bannersList;

                  debugPrint("My Banner List" + banners.length.toString());
                  debugPrint("My category List" + jsonEncode(categoriesList));

                  //saveSaerchText(categoriesList);
                  //getSearchText();

                  for (var x in categoriesList!) {
                    if (searchtext.contains(x.name) == false) {
                      searchtext
                          .add('${StringContants.lbl_search_hint} "${x.name}"');
                    }
                  }
                }

                if (state is HomePageScrollState) {
                  isScroll = state.isScroll;
                }

                if (state is HomePageAppBarState) {
                  Brightness brightness =
                      ThemeData.estimateBrightnessForColor(appbarcolor);

                  appbarcolor = state.appbarcolor;
                  appbartextcolor = state.appbartextcolor;
                  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                    statusBarColor: state.appbarcolor,
                    systemNavigationBarIconBrightness: Brightness.light,
                    // statusBarBrightness: Brightness.light // Set status bar color here
                    statusBarIconBrightness: brightness == Brightness.dark
                        ? Brightness.light
                        : Brightness.dark,
                  ));
                }

                return WillPopScope(
                  onWillPop: () async {
                    if (isOpenBottomview) {
                      animationBloc.add(AnimatedNullEvent());
                      animationBloc.add(AnimatedNullEvent());

                      animationBloc.add(AnimationCartEvent(size: 70.00));

                      isOpenBottomview = false;
                      homePageBloc2.add(HomeNullEvent());
                      homePageBloc2.add(HomeBottomSheetEvent(status: false));
                    } else if (_drawerKey.currentState!.isEndDrawerOpen) {
                      Navigator.pop(context);
                    } else {
                      Appwidgets.showExitDialog(
                          context,
                          StringContants.lbl_exit_question,
                          StringContants.lbl_exit_message, () {
                        exit(1);
                      });
                    }

                    return false;
                  },
                  child: VisibilityDetector(
                    onVisibilityChanged: (visibilityInfo) async {
                      debugPrint("HomeScreen visibility1  ${visibilityInfo}");
                      loadData();
                      //  await Future.delayed(Duration(milliseconds: 600), () {
                      SystemChrome.setSystemUIOverlayStyle(
                          const SystemUiOverlayStyle(
                              statusBarColor: ColorName.ColorPrimary,
                              statusBarBrightness:
                                  Brightness.light // Set status bar color here
                              ));
                      //});
                    },
                    key: const Key('HomoPagescree'),
                    child: Stack(
                      children: [
                        Scaffold(
                          key: _drawerKey,
                          appBar: PreferredSize(
                            preferredSize:
                                const Size.fromHeight(120), // Set this height
                            child: AnimatedContainer(
                              duration: const Duration(
                                  microseconds:
                                      500), // Smooth transition duration

                              decoration: BoxDecoration(
                                color: appbarcolor,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                        0.1), // Lighter opacity for a dim shadow
                                    offset: const Offset(
                                        0, 4), // Shadow below the container
                                    blurRadius:
                                        15, // Increase blur for a softer shadow
                                    spreadRadius:
                                        1, // Keep spread radius the same or adjust if needed
                                  ),
                                ],
                              ),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                          left: 6, right: 6, top: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(context,
                                                  Routes.location_screen,
                                                  arguments: Routes.home_page);
                                            },
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                    Imageconstants.img_location,
                                                    height: 25,
                                                    width: 20,
                                                    fit: BoxFit.fitHeight,
                                                    color: appbartextcolor),
                                                10.toSpace,
                                                street == ""
                                                    ? Shimmerui
                                                        .locationDetailShimmerUI(
                                                            context: context,
                                                            width: Appwidgets()
                                                                .getwidthForText(
                                                                    street,
                                                                    context))
                                                    : Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                  // width: Appwidgets()
                                                                  //     .getwidthForText(
                                                                  //         street,
                                                                  //         context),

                                                                  width: Sizeconfig
                                                                          .getWidth(
                                                                              context) *
                                                                      0.6,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Container(
                                                                        // width: Appwidgets()
                                                                        //     .getwidthForText(
                                                                        //     street,
                                                                        //     context),
                                                                        // width:Sizeconfig.getWidth(context)*0.5,
                                                                        child: CommanTextWidget.textLagre(
                                                                            street.length > 14
                                                                                ? street.substring(0, 14)
                                                                                : street,
                                                                            appbartextcolor),
                                                                      ),
                                                                      2.toSpace,
                                                                      street ==
                                                                              ""
                                                                          ? const SizedBox
                                                                              .shrink()
                                                                          : Icon(
                                                                              Icons.keyboard_arrow_down,
                                                                              color: appbartextcolor,
                                                                            )
                                                                    ],
                                                                  )),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            // width: Appwidgets()
                                                            //     .getwidthForText(
                                                            //         locality, context),
                                                            width: Sizeconfig
                                                                    .getWidth(
                                                                        context) *
                                                                0.6,
                                                            child: CommanTextWidget
                                                                .subheading2(
                                                                    locality,
                                                                    appbartextcolor),
                                                          )
                                                        ],
                                                      )
                                              ],
                                            ),
                                          ),
                                          const Spacer(),
                                          GestureDetector(
                                            onTap: () async {
                                              String customer_id =
                                                  await SharedPref
                                                      .getStringPreference(
                                                          Constants
                                                              .sp_CustomerId);
                                              String token_type =
                                                  await SharedPref
                                                      .getStringPreference(
                                                          Constants
                                                              .sp_TOKENTYPE);
                                              String access_token =
                                                  await SharedPref
                                                      .getStringPreference(
                                                          Constants
                                                              .sp_AccessTOEKN);

                                              String token =
                                                  "$token_type $access_token";

                                              if (token == ' ' &&
                                                  customer_id == '') {
                                                await SharedPref
                                                    .setStringPreference(
                                                        Constants
                                                            .sp_VerifyRoute,
                                                        Routes
                                                            .notification_center);
                                                SystemChrome
                                                    .setSystemUIOverlayStyle(
                                                        const SystemUiOverlayStyle(
                                                  statusBarColor: Colors
                                                      .transparent, // transparent status bar
                                                  statusBarIconBrightness:
                                                      Brightness
                                                          .dark, // dark icons on the status bar
                                                ));
                                                Navigator.pushNamed(context,
                                                        Routes.register_screen,
                                                        arguments:
                                                            Routes.home_page)
                                                    .then(
                                                  (value) {
                                                    SystemChrome.setSystemUIOverlayStyle(
                                                        const SystemUiOverlayStyle(
                                                            statusBarColor:
                                                                ColorName
                                                                    .ColorPrimary,
                                                            statusBarIconBrightness:
                                                                Brightness
                                                                    .light,
                                                            systemNavigationBarIconBrightness:
                                                                Brightness
                                                                    .light));
                                                  },
                                                );
                                              } else {
                                                Navigator.pushNamed(
                                                        context,
                                                        Routes
                                                            .notification_center)
                                                    .then(
                                                  (value) {
                                                    OndoorThemeData
                                                        .keyBordDow();
                                                    loadData();
                                                    initializedDb();
                                                    homePageBloc.add(
                                                        HomeNotificationEvent(
                                                            notification_count:
                                                                ""));
                                                    SystemChrome.setSystemUIOverlayStyle(
                                                        const SystemUiOverlayStyle(
                                                            statusBarColor:
                                                                ColorName
                                                                    .ColorPrimary,
                                                            statusBarIconBrightness:
                                                                Brightness
                                                                    .light,
                                                            systemNavigationBarIconBrightness:
                                                                Brightness
                                                                    .light));
                                                  },
                                                );
                                              }
                                            },
                                            child: Container(
                                              width: 30,
                                              height: 35,
                                              child: Stack(
                                                children: [
                                                  Center(
                                                    child: Image.asset(
                                                        Imageconstants
                                                            .img_notification,
                                                        height: 25,
                                                        width: 25,
                                                        color: appbartextcolor),
                                                  ),
                                                  notificatonCount == "" ||
                                                          notificatonCount ==
                                                              "0"
                                                      ? Container()
                                                      : read_notification_batch
                                                                  .toString() ==
                                                              notificatonCount
                                                          ? Container()
                                                          : Positioned(
                                                              right: 0,
                                                              top: 0,
                                                              child: Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            12),
                                                                height: 18,
                                                                width: 18,
                                                                decoration: BoxDecoration(
                                                                    color: ColorName
                                                                        .darkBlue,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0)),
                                                                child: Center(
                                                                  child: Text(
                                                                    "${notificatonCount}",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        fontFamily:
                                                                            Fontconstants
                                                                                .fc_family_sf,
                                                                        fontWeight:
                                                                            Fontconstants
                                                                                .SF_Pro_Display_Regular,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                ],
                                              ),
                                            ),
                                          ),
                                          15.toSpace,
                                          InkWell(
                                            onTap: () {
                                              _drawerKey.currentState!
                                                  .openEndDrawer();
                                              OndoorThemeData.keyBordDow();
                                              loadData();
                                              initializedDb();
                                              // if (_drawerKey.currentState!.isDrawerOpen ==
                                              //     false) {
                                              //   _drawerKey.currentState!.openEndDrawer();
                                              // } else {
                                              //   _drawerKey.currentState!.closeEndDrawer();
                                              // }
                                              // Navigator.of(context)
                                              //     .push(createRoute(ProfileScreen()));
                                              // Navigator.pushNamed(
                                              //     context, Routes.profile_screen);
                                            },
                                            child: Image.asset(
                                                Imageconstants.img_person,
                                                height: 25,
                                                width: 25,
                                                color: appbartextcolor),
                                          ),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {},
                                      child: Stack(
                                        children: [
                                          Container(
                                              margin: const EdgeInsets.only(
                                                  left: 6,
                                                  right: 6,
                                                  bottom: 13),
                                              child: CustomTextField(
                                                iskeyboardopen: false,
                                                onSubmit: (value) {},
                                                onchanged: (value) {},
                                                ontap: () {
                                                  // debugPrint("GG GoogeleSpeech Dialog ");
                                                  // googleSpeechDialog();

                                                  debugPrint("Click on Mick");

                                                  SharedPref.setBooleanPreference(
                                                      Constants
                                                          .sp_isGoogleSpeechActive,
                                                      true);
                                                  List<ProductData> list = [];
                                                  Navigator.pushNamed(context,
                                                      Routes.featuredProduct,
                                                      arguments: {
                                                        "key": StringContants
                                                            .lbl_search,
                                                        "list": list,
                                                        "paninatinUrl": ""
                                                      }).then((value) {});
                                                },

                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                obscureText: false,
                                                hintText:
                                                    '${StringContants.lbl_search_hint} "${searchint}"',
                                                activeIcon:
                                                    Imageconstants.img_search,
                                                // Provide the actual path to the active icon
                                                inactiveIcon:
                                                    Imageconstants.img_search,
                                                padding: const EdgeInsets.only(
                                                  top: 10,
                                                  left: 5,
                                                  right: 0,
                                                  bottom: 10,
                                                ),
                                                suffixIcon: Imageconstants
                                                    .img_microphon,
                                                // Provide the actual path to the inactive icon
                                                controller:
                                                    TextEditingController(),
                                                isPassword: false,
                                                readOnly: true,
                                                hinttextlist: searchtext,
                                              )),
                                          Row(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  List<ProductData> list = [];
                                                  Navigator.pushNamed(context,
                                                      Routes.featuredProduct,
                                                      arguments: {
                                                        "key": StringContants
                                                            .lbl_search,
                                                        "list": list,
                                                        "paninatinUrl": ""
                                                      }).then((value) {
                                                    initializedDb();
                                                    loadData();
                                                  });
                                                },
                                                child: Container(
                                                  width: Sizeconfig.getWidth(
                                                          context) *
                                                      0.8,
                                                  height: Sizeconfig.getWidth(
                                                          context) *
                                                      0.12,
                                                  color: Colors.transparent,
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  debugPrint("Click on Mick2");

                                                  SharedPref.setBooleanPreference(
                                                      Constants
                                                          .sp_isGoogleSpeechActive,
                                                      true);
                                                  List<ProductData> list = [];
                                                  Navigator.pushNamed(context,
                                                      Routes.featuredProduct,
                                                      arguments: {
                                                        "key": StringContants
                                                            .lbl_search,
                                                        "list": list,
                                                        "paninatinUrl": ""
                                                      }).then((value) {
                                                    initializedDb();
                                                    loadData();
                                                  });
                                                },
                                                child: Container(
                                                  width: Sizeconfig.getWidth(
                                                          context) *
                                                      0.17,
                                                  height: Sizeconfig.getWidth(
                                                          context) *
                                                      0.12,
                                                  color: Colors.transparent,
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          resizeToAvoidBottomInset: true,
                          endDrawer: const ProfileScreen(),
                          body: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 0),
                                child: RefreshIndicator(
                                  color: ColorName.ColorPrimary,
                                  onRefresh: () async {
                                    homepageVisisblility = true;
                                    mainloadmore = true;
                                    reloadHomepage();
                                  },
                                  child: SingleChildScrollView(
                                    controller: _scrollController,
                                    // physics: const BouncingScrollPhysics(),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Showing Bannner View
                                          10.toSpace,

                                          banners.isEmpty
                                              ? Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10),
                                                  child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      child: Shimmerui.bannerUI(
                                                          context)),
                                                )
                                              : Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 5),
                                                  child: BannerView(
                                                    bannerList: banners,
                                                    showindicator: true,
                                                  ),
                                                ),
                                          // 10.toSpace,

                                          //Top Products List View

                                          /*  InkWell(
                                            onTap: () {
                                              // MyDialogs.offersDialogMain(context);
                                            },
                                            child: Homewidgetconst.topProductList(
                                                context, listTopProducts, () {
                                              OndoorThemeData.keyBordDow();
                                              loadData();
                                              initializedDb();
                                            }),
                                          ),*/

                                          //Product Category

                                          Visibility(
                                            visible: showcategory,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Appwidgets.lables(
                                                    StringContants
                                                        .lbl_product_category,
                                                    10,
                                                    10),
                                                categoriesList!.length == 9 ||
                                                        categoriesList!
                                                                .length ==
                                                            6
                                                    ? Homewidgetconst
                                                        .StaggeredGridViewNew9(
                                                            context,
                                                            categoriesList, () {
                                                        OndoorThemeData
                                                            .keyBordDow();
                                                        loadData();
                                                        initializedDb();
                                                      })
                                                    : categoriesList!.isEmpty
                                                        ? Shimmerui.GridViewUi(
                                                            context)
                                                        : Homewidgetconst
                                                            .StaggerdGridViewNew(
                                                                context,
                                                                categoriesList,
                                                                () {
                                                            OndoorThemeData
                                                                .keyBordDow();
                                                            loadData();
                                                            initializedDb();
                                                          }),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(
                                            height: 10,
                                          ),
                                          BlocProvider(
                                            create: (context) => featuredBloc,
                                            child:
                                                BlocBuilder<FeaturedBloc,
                                                        FeaturedState>(
                                                    bloc: featuredBloc,
                                                    builder: (context, state) {
                                                      debugPrint(
                                                          "Featured Product State GG " +
                                                              state.toString());

                                                      if (state
                                                          is LoadedOrderSummaryState) {
                                                        listProducSummary = state
                                                            .listProducSummary!;

                                                        for (int index = 0;
                                                            index <
                                                                listProducSummary
                                                                    .length;
                                                            index++) {
                                                          if (listProducSummary[
                                                                      index]
                                                                  .model_type ==
                                                              "1") {
                                                            chekcartQuantiy(
                                                                index,
                                                                listProducSummary[
                                                                        index]
                                                                    .lisProductData,
                                                                false);
                                                          }
                                                        }
                                                      }

                                                      if (state
                                                          is ProductForPaginationState) {
                                                        debugPrint(
                                                            "GProductForPaginationState  11 ${state.index}  ${state.list!.length}");

                                                        for (int index = 0;
                                                            index <
                                                                listProducSummary
                                                                    .length;
                                                            index++) {
                                                          if (state.index ==
                                                              index) {
                                                            listProducSummary[
                                                                    index]
                                                                .lisProductData
                                                                .addAll(state
                                                                    .list!);

                                                            chekcartQuantiy(
                                                                index,
                                                                listProducSummary[
                                                                        index]
                                                                    .lisProductData,
                                                                false);
                                                          }
                                                        }
                                                      }

                                                      if (state
                                                          is ProductLoadMoreState) {
                                                        for (int index = 0;
                                                            index <
                                                                listProducSummary
                                                                    .length;
                                                            index++) {
                                                          if (state.index ==
                                                              index) {
                                                            listProducSummary[
                                                                        index]
                                                                    .isLoadMore =
                                                                state.loadmore;
                                                          }
                                                        }
                                                      }

                                                      if (state
                                                          is ProductInitialSummaryState) {
                                                        debugPrint(
                                                            "RRNEW ${state.list!.length}");
                                                        for (int index = 0;
                                                            index <
                                                                listProducSummary
                                                                    .length;
                                                            index++) {
                                                          if (state.index ==
                                                              index) {
                                                            listProducSummary[
                                                                        index]
                                                                    .lisProductData =
                                                                state.list!;
                                                          }
                                                        }
                                                      }

                                                      if (state
                                                          is ProductListEmptyEvent) {
                                                        mainloadmore = false;
                                                      }
                                                      return Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          listProducSummary
                                                                  .isEmpty
                                                              ? Shimmerui
                                                                  .orderSummaryui(
                                                                      context)
                                                              : ListView
                                                                  .builder(
                                                                      cacheExtent:
                                                                          200,
                                                                      shrinkWrap:
                                                                          true,
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              0),
                                                                      itemCount:
                                                                          listProducSummary
                                                                              .length,
                                                                      physics:
                                                                          const NeverScrollableScrollPhysics(),
                                                                      itemBuilder:
                                                                          (context,
                                                                              index) {
                                                                        // _listScrolController
                                                                        //     .add(ScrollController());
                                                                        //
                                                                        //listProducSummary[index].scrollController
                                                                        //     .addListener(() {
                                                                        //   _scrollListenerlist(
                                                                        //       index,
                                                                        //       listProducSummary[index].url,
                                                                        //       listProducSummary[index].isLoadMore);
                                                                        // });
                                                                        var backgroundcolor2;
                                                                        var backgroundColor =
                                                                            Color(int.parse(getColor(listProducSummary[index].backgroundColor.split(",")[0].toString()) +
                                                                                ""));
                                                                        var ui_appbar_bg_color =
                                                                            Color(int.parse(getColor(listProducSummary[index].ui_appbar_bg_color.split(",")[0].toString()) +
                                                                                ""));
                                                                        var ui_appbar_text_color =
                                                                            Color(int.parse(getColor(listProducSummary[index].ui_appbar_text_color.split(",")[0].toString()) +
                                                                                ""));

                                                                        if (listProducSummary[index].backgroundColor.length >
                                                                            1) {
                                                                          backgroundcolor2 =
                                                                              Color(int.parse(getColor(listProducSummary[index].backgroundColor.split(",")[1].toString()) + ""));
                                                                        }
                                                                        String
                                                                            backgroundImage =
                                                                            listProducSummary[index].backgroundImage!;
                                                                        String
                                                                            category_id =
                                                                            listProducSummary[index].category_id!;

                                                                        var titleColor =
                                                                            Color(int.parse(getColor(listProducSummary[index].titleColor.split(",")[0].toString()) +
                                                                                ""));
                                                                        var textColor =
                                                                            Color(int.parse(getColor(listProducSummary[index].textColor.split(",")[0].toString()) +
                                                                                ""));
                                                                        var textsecondary;

                                                                        if (listProducSummary[index].textColor.split(",").length >
                                                                            1) {
                                                                          textsecondary =
                                                                              Color(int.parse(getColor(listProducSummary[index].textColor.split(",")[1].toString()) + ""));
                                                                        }

                                                                        var abovecolor;
                                                                        if (listProducSummary.length >
                                                                                index &&
                                                                            listProducSummary[index].uitype ==
                                                                                "2") {
                                                                          abovecolor =
                                                                              Color(int.parse(getColor(listProducSummary[index - 1].backgroundColor.split(",")[0].toString()) + ""));
                                                                        }

                                                                        var buttontextcolor;
                                                                        var buttonbackgroundcolor;

                                                                        if (listProducSummary[index].button_background !=
                                                                                "" &&
                                                                            listProducSummary[index].button_background !=
                                                                                null) {
                                                                          buttonbackgroundcolor =
                                                                              Color(int.parse(getColor(listProducSummary[index].button_background.split(",")[0].toString()) + ""));
                                                                        }

                                                                        if (listProducSummary[index].button_text_color !=
                                                                                "" &&
                                                                            listProducSummary[index].button_text_color !=
                                                                                null) {
                                                                          buttontextcolor =
                                                                              Color(int.parse(getColor(listProducSummary[index].button_text_color.split(",")[0].toString()) + ""));
                                                                        }
                                                                        var list =
                                                                            listProducSummary[index].lisProductData;
                                                                        return VisibilityDetector(
                                                                          key: Key(
                                                                              index.toString()),
                                                                          onVisibilityChanged:
                                                                              (VisibilityInfo info) {
                                                                            var visiblePercentage =
                                                                                info.visibleFraction * 100;
                                                                            debugPrint("HomeScreen visibility2  $info");
                                                                            debugPrint("HomepageonVisibilityChanged visiblePercentage $visiblePercentage");
                                                                            debugPrint("HomepageonVisibilityChanged info.visibleBounds.top ${info.visibleBounds.top}");

                                                                            if (_scrollController.hasClients &&
                                                                                _scrollController.position.atEdge &&
                                                                                _scrollController.offset == 0.0) {
                                                                              homePageBloc.add(HomePageAppBarEvent(appbarcolor: ColorName.ColorPrimary, appbartextcolor: Colors.white));
                                                                            } else if (info.visibleBounds.top > 0) {
                                                                              debugPrint("top Index touch $index");
                                                                              homePageBloc.add(HomePageAppBarEvent(appbarcolor: ui_appbar_bg_color, appbartextcolor: ui_appbar_text_color));
                                                                            }

                                                                            if (info.visibleBounds.top < 1 &&
                                                                                info.visibleFraction < 1) {
                                                                              debugPrint("Botttom Index touch $index");
                                                                              //homePageBloc.add(HomePageAppBarEvent(appbarcolor: ColorName.ColorPrimary, appbartextcolor: Colors.white));
                                                                            }
                                                                            // else
                                                                            //   {
                                                                            //     homePageBloc.add(HomePageAppBarEvent(appbarcolor: ColorName.ColorPrimary, appbartextcolor: Colors.white));
                                                                            //   }

                                                                            if (info.visibleBounds.top <= 0 &&
                                                                                info.visibleFraction > 0) {}
                                                                          },
                                                                          child:
                                                                              BlocProvider(
                                                                            create: (context) =>
                                                                                featuredBloc,
                                                                            child: BlocBuilder<FeaturedBloc, FeaturedState>(
                                                                                bloc: featuredBloc,
                                                                                builder: (context, state) {
                                                                                  /*   debugPrint("GGfeaturedBlocSate ${state}");
                                                                                  debugPrint("GGfeaturedBlocSate ${listProducSummary[index].uitype}");*/

                                                                                  //   return

                                                                                  switch (listProducSummary[index].uitype) {
                                                                                    case "5":
                                                                                      return Uistyle.ui_type5(false, context, listProducSummary[index].title, listProducSummary[index].subtitle, state, listProducSummary[index].lisProductData, featuredBloc, isMoreUnitIndex, cardBloc, dbHelper, listProducSummary[index].scrollController, listProducSummary[index].isLoadMore, backgroundColor, textColor, titleColor, backgroundImage, () {
                                                                                        OndoorThemeData.keyBordDow();
                                                                                        loadData();
                                                                                        initializedDb();
                                                                                      });
                                                                                    case "8":
                                                                                      return Uistyle.ui_type8(false, context, listProducSummary[index].title, listProducSummary[index].subtitle, state, listProducSummary[index].lisProductData, featuredBloc, isMoreUnitIndex, cardBloc, dbHelper, listProducSummary[index].scrollController, listProducSummary[index].isLoadMore, backgroundColor, textColor, titleColor, backgroundImage, listProducSummary[index].button_text, buttontextcolor, buttonbackgroundcolor, () {
                                                                                        OndoorThemeData.keyBordDow();
                                                                                        loadData();
                                                                                        initializedDb();
                                                                                      }, listProducSummary[index].url, categoriesList, category_id);
                                                                                    case "17":
                                                                                      return Uistyle.ui_type17(false, context, state, listProducSummary[index].title, listProducSummary[index].subtitle, listProducSummary[index].lisProductData, featuredBloc, isMoreUnitIndex, cardBloc, dbHelper, listProducSummary[index].scrollController, listProducSummary[index].isLoadMore, backgroundColor, backgroundcolor2, titleColor, textColor, listProducSummary[index].button_text, buttonbackgroundcolor, buttontextcolor, backgroundImage, () {
                                                                                        OndoorThemeData.keyBordDow();
                                                                                        loadData();
                                                                                        initializedDb();
                                                                                      }, listProducSummary[index].url, categoriesList, category_id);

                                                                                    case "3":
                                                                                      return Uistyle.ui_type3(false, context, state, listProducSummary[index].title, listProducSummary[index].subtitle, listProducSummary[index].lisProductData, featuredBloc, isMoreUnitIndex, cardBloc, dbHelper, listProducSummary[index].scrollController, listProducSummary[index].isLoadMore, backgroundColor, textColor, textsecondary, titleColor, buttonbackgroundcolor, buttontextcolor, listProducSummary[index].button_text, () {
                                                                                        OndoorThemeData.keyBordDow();
                                                                                        loadData();
                                                                                        initializedDb();
                                                                                      }, listProducSummary[index].url, categoriesList, category_id);

                                                                                    case "16":
                                                                                      return Uistyle.ui_type16(false, context, state, listProducSummary[index].title, listProducSummary[index].subtitle, listProducSummary[index].lisProductData, featuredBloc, isMoreUnitIndex, cardBloc, dbHelper, listProducSummary[index].scrollController, listProducSummary[index].isLoadMore, backgroundColor, textColor, textsecondary, titleColor, buttonbackgroundcolor, buttontextcolor, listProducSummary[index].button_text, () {
                                                                                        OndoorThemeData.keyBordDow();
                                                                                        loadData();
                                                                                        initializedDb();
                                                                                      }, listProducSummary[index].url, categoriesList, category_id);

                                                                                    case "4":
                                                                                      return Uistyle.ui_type4(false, context, state, listProducSummary[index].title, listProducSummary[index].subtitle, listProducSummary[index].listsubcategory, featuredBloc, isMoreUnitIndex, cardBloc, dbHelper, listProducSummary[index].scrollController, listProducSummary[index].isLoadMore, backgroundColor, backgroundcolor2, titleColor, textColor, categoriesList!, () {
                                                                                        OndoorThemeData.keyBordDow();
                                                                                        loadData();
                                                                                        initializedDb();
                                                                                      });
                                                                                    case "10":
                                                                                      log("IMAGE URL ${listProducSummary[index].backgroundImage}");
                                                                                      return Uistyle.ui_type10(false, context, state, listProducSummary[index].title, listProducSummary[index].subtitle, featuredBloc, isMoreUnitIndex, cardBloc, dbHelper, listProducSummary[index].scrollController, listProducSummary[index].isLoadMore, backgroundColor, backgroundcolor2, titleColor, textColor, listProducSummary[index].lisProductData, listProducSummary[index].button_text, buttonbackgroundcolor, buttontextcolor, backgroundImage, () {
                                                                                        OndoorThemeData.keyBordDow();
                                                                                        loadData();
                                                                                        initializedDb();
                                                                                      }, listProducSummary[index].url, categoriesList, category_id);
                                                                                    case "14":
                                                                                      debugPrint("uitype==14  ${listProducSummary[index].lisProductData.length} ");
                                                                                      debugPrint("HOME PAGE SCREEN STATE UI 14  $state ");
                                                                                      return Uistyle.ui_type14(false, context, state, listProducSummary[index].title, listProducSummary[index].subtitle, featuredBloc, isMoreUnitIndex, cardBloc, dbHelper, listProducSummary[index].scrollController, listProducSummary[index].isLoadMore, backgroundColor, backgroundcolor2, titleColor, textColor, list, listProducSummary[index].button_text, buttonbackgroundcolor, buttontextcolor, backgroundImage, () {
                                                                                        OndoorThemeData.keyBordDow();
                                                                                        loadData();
                                                                                        initializedDb();
                                                                                      }, listProducSummary[index].url, categoriesList, category_id);
                                                                                    case "18":
                                                                                      return Uistyle.ui_type18(false, context, state, listProducSummary[index].title, listProducSummary[index].subtitle, featuredBloc, isMoreUnitIndex, cardBloc, dbHelper, listProducSummary[index].scrollController, listProducSummary[index].isLoadMore, backgroundColor, backgroundcolor2, titleColor, textColor, listProducSummary[index].listcategory, listProducSummary[index].button_text, buttonbackgroundcolor, buttontextcolor, backgroundImage, () {
                                                                                        OndoorThemeData.keyBordDow();
                                                                                        loadData();
                                                                                        initializedDb();
                                                                                      });

                                                                                    case "6":
                                                                                      return listProducSummary[index].listbanners.isEmpty
                                                                                          ? const SizedBox.shrink()
                                                                                          : Padding(
                                                                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                                                              child: BannerView(
                                                                                                bannerList: listProducSummary[index].listbanners,
                                                                                                showindicator: false,
                                                                                              ),
                                                                                            );

                                                                                    case "7":
                                                                                      return Uistyle.ui_type7(false, context, listProducSummary[index].title, listProducSummary[index].subtitle, state, listProducSummary[index].lisProductData, featuredBloc, isMoreUnitIndex, cardBloc, dbHelper, listProducSummary[index].scrollController, listProducSummary[index].isLoadMore, backgroundColor, textColor, titleColor, backgroundImage, listProducSummary[index].button_text, buttontextcolor, buttonbackgroundcolor, () {
                                                                                        OndoorThemeData.keyBordDow();
                                                                                        loadData();
                                                                                        initializedDb();
                                                                                      }, listProducSummary[index].url, categoriesList, category_id);
                                                                                    default:

                                                                                      /* return Container(child:Image.asset(Imageconstants.img_test));*/

                                                                                      return Uistyle.ui_type3(false, context, state, listProducSummary[index].title, listProducSummary[index].subtitle, listProducSummary[index].lisProductData, featuredBloc, isMoreUnitIndex, cardBloc, dbHelper, listProducSummary[index].scrollController, listProducSummary[index].isLoadMore, backgroundColor, textColor, textsecondary, titleColor, buttonbackgroundcolor, buttontextcolor, listProducSummary[index].button_text, () {
                                                                                        OndoorThemeData.keyBordDow();
                                                                                        loadData();
                                                                                        initializedDb();
                                                                                      }, listProducSummary[index].url, categoriesList, category_id);
                                                                                  }
                                                                                }),
                                                                          ),
                                                                        );
                                                                      }),
                                                          mainloadmore
                                                              ? SizedBox(
                                                                  height: Sizeconfig
                                                                          .getHeight(
                                                                              context) *
                                                                      0.1,
                                                                  child:
                                                                      const Center(
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      color: ColorName
                                                                          .ColorPrimary,
                                                                    ),
                                                                  ),
                                                                )
                                                              : Container(),
                                                        ],
                                                      );
                                                    }),
                                          ),
                                          Container(
                                            height: 100,
                                          ),
                                        ]),
                                  ),
                                ),
                              ),
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
                                              height:
                                                  Sizeconfig.getHeight(context),
                                              color: Colors.black12
                                                  .withOpacity(0.2),
                                            )
                                          : Container();
                                    },
                                  )),
                              // Container(
                              //   height: Sizeconfig.getHeight(context),
                              //   child: Column(
                              //     mainAxisAlignment:
                              //         MainAxisAlignment.spaceBetween,
                              //     children: [
                              //       Container(),
                              //       Container(
                              //         child: Appwidgets.ShowBottomView33(
                              //             false,
                              //             context,
                              //             cardBloc,
                              //             featuredBloc,
                              //             ShopByCategoryBloc(),
                              //             animationBloc,
                              //             animationsizebottom,
                              //             0,
                              //             "",
                              //             true,
                              //             dbHelper,
                              //             () {
                              //               loadData();
                              //               initializedDb();
                              //               SystemChrome.setSystemUIOverlayStyle(
                              //                   SystemUiOverlayStyle(
                              //                       statusBarColor:
                              //                           ColorName.ColorPrimary,
                              //                       statusBarBrightness: Brightness
                              //                           .light // Set status bar color here
                              //                       ));
                              //             },
                              //             () {
                              //               reloadHomepage();
                              //             },
                              //             () {},
                              //             false,
                              //             (value) {
                              //               debugPrint(
                              //                   "HomePage Screen back >>>>>$value");
                              //               isOpenBottomview = value;
                              //               homePageBloc2.add(HomeNullEvent());
                              //               homePageBloc2.add(
                              //                   HomeBottomSheetEvent(
                              //                       status: value));
                              //             },
                              //             (height) {
                              //               debugPrint("GGheight >> $height");
                              //               animationsizebottom = 70.0;
                              //             }),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: Sizeconfig.getHeight(context),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(),
                              Container(
                                child: Appwidgets.ShowBottomView33(
                                    false,
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
                                    () {
                                      loadData();
                                      initializedDb();
                                      SystemChrome.setSystemUIOverlayStyle(
                                          const SystemUiOverlayStyle(
                                              statusBarColor:
                                                  ColorName.ColorPrimary,
                                              statusBarBrightness: Brightness
                                                  .light // Set status bar color here
                                              ));
                                    },
                                    () {
                                      reloadHomepage();
                                    },
                                    () {},
                                    false,
                                    (value) {
                                      debugPrint(
                                          "HomePage Screen back >>>>>$value");
                                      isOpenBottomview = value;
                                      homePageBloc2.add(HomeNullEvent());
                                      homePageBloc2.add(
                                          HomeBottomSheetEvent(status: value));
                                    },
                                    (height) {
                                      debugPrint("GGheight >> $height");
                                      animationsizebottom = 70.0;
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }

/*
  Route createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
*/

  void getNotificationCount() async {
    notificatonCount =
        await SharedPref.getStringPreference(Constants.sp_NotificationCount) ??
            "";
    debugPrint(
        "notificatonCount   $notificatonCount  $read_notification_batch");
    homePageBloc
        .add(HomeNotificationEvent(notification_count: notificatonCount));
  }
}

/*

static ShowBottomView(
    BuildContext context,
    CardBloc cardBloc,
    FeaturedBloc blocFeatured,
    ShopByCategoryBloc blocShopby,
    AnimationBloc animationBloc,
    var animatedSize,
    int count,
    String image,
    bool isup,
    DatabaseHelper dbhelper,
    Function callback,
    bool validate,
    ) {
  List<ProductUnit> cartitesmList = [];

  List<ProductUnit> list_cOffers = [];
  List<ProductUnit> freeProducts = [];
  bool loadProductValidation = true;


  double totalAmount = 0;


  dbhelper.loadAddCardProducts(cardBloc);

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


  return BlocProvider(
    create: (context) => cardBloc,
    child: BlocBuilder(
        bloc: cardBloc,
        builder: (context, state) {
          debugPrint("ShowBottomView ***   $state $animatedSize");

          if (state is AddCardState) {
            count = state.count;
          }
          if (state is AddCardProductState) {
            cartitesmList = state.listProduct;
            count = state.listProduct.length;
            image = state.listProduct.first.image!;
            debugPrint(
                "Cart Items list ***" + cartitesmList.length.toString());
            debugPrint("Cart Items list ***" + image);

            if(animatedSize==0)
            {
              animationBloc.add(AnimatedNullEvent());
              animationBloc.add(AnimatedNullEvent());
              animationBloc.add(AnimationCartEvent(size:70.0));

            }

            // //setAnimation(animationBloc,70.0);
            // Future.delayed(Duration(seconds: 1),(){
            //
            //
            //   print("ajhhasdhadla");
            //
            //
            // });

            totalAmount = 0;

            for (var dummyData in cartitesmList) {
              debugPrint(
                  "GGGNull Exception${dummyData.name} ${dummyData.sortPrice == "null"}");
              var sortPrice = (double.parse(dummyData.sortPrice == null ||
                  dummyData.sortPrice == "null" ||
                  dummyData.sortPrice == ""
                  ? "0.0"
                  : dummyData.sortPrice!) *
                  dummyData.addQuantity)
                  .toString();
              var specialPrice = (double.parse(
                  dummyData.specialPrice == null ||
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

              debugPrint("specialPrice 2 ${specialPrice}");
              debugPrint("sortPrice 2 ${sortPrice}");
              debugPrint("price 2 ${price}");

              var crossprice = dummyData.specialPrice == ""
                  ? ""
                  : "₹ ${double.parse(price).toStringAsFixed(2)}";
              var showprice = dummyData.specialPrice == ""
                  ? " ${double.parse(sortPrice ?? "0.0").toStringAsFixed(2)}"
                  : "${double.parse(specialPrice).toStringAsFixed(2)}";

              totalAmount = totalAmount + double.parse(showprice);
            }
            debugPrint("CartTotal amount ${totalAmount}");
          }

          if (state is CardUpdateQuanitiyState) {
            debugPrint(" CARD UPDATE ${state.listProduct.length}");
            image = state.listProduct.first.image!;
            debugPrint(" CARD UPDATE ${image}");
            cartitesmList = state.listProduct;

            // count=state.listProduct.length;
            // image=state.listProduct.first.image!;
          }
          if (cartitesmList.isEmpty) {
            return Container(
              height: 0,
            );
          }
          if (state is CardEmptyState) {
            animationBloc.add(AnimatedNullEvent());
            animationBloc.add(AnimationCartEvent(size: 0.0));
            return Container(
              height: 0,
            );
          }
          if (state is CardDeleteSatate) {
            debugPrint("CardDeleteSatate >>>>>  ${state.listProduct.length}");
            cartitesmList = state.listProduct;
          }

          return BlocProvider(
            create: (context) => animationBloc,
            child: BlocBuilder(
                bloc: animationBloc,
                builder: (context, state2) {
                  debugPrint(
                      "Animation Cart State  1 ${state2} $animatedSize");

                  if (state2 is AnimationCartState) {
                    animatedSize = state2.size;
                    debugPrint(
                        "Animation Cart State ${state2} $animatedSize");
                  }

                  return AnimatedContainer(
                    height: animatedSize,
                    duration: const Duration(seconds: 2),
                    // Provide an optional curve to make the animation feel smoother.
                    curve: Curves.fastOutSlowIn,
                    child: VisibilityDetector(
                      key: const Key('ondoor.widget'),
                      onVisibilityChanged: (visibilityInfo) async {
                        var visiblePercentage =
                            visibilityInfo.visibleFraction * 100;
                        debugPrint(
                            'Widgetnew ${visibilityInfo.key} is $visiblePercentage% visible');
                        dbhelper.loadAddCardProducts(cardBloc);
                      },
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 0),
                        child: StatefulBuilder(builder: ((context, setState) {
                          return Container(
                            height: animatedSize,
                            child: Stack(

                              children: [

                                Container(
                                    color: ColorName.aquaHazeColor,
                                    child: BlocProvider(
                                      create: (context) => cardBloc,
                                      child: BlocBuilder(
                                          bloc: cardBloc,
                                          builder: (context, state) {
                                            debugPrint("Bottom Dialog state $state");
                                            if (state is CardDeleteSatate) {
                                              debugPrint("CardDeleteSatate >>>>>  ");

                                              cartitesmList.remove(state.model);
                                            }

                                            if (state is CardUpdateQuanitiyState) {
                                              debugPrint(
                                                  "CCardUpdateQuanitiyStateGG  ${state.listProduct.length.toString()}");

                                              cartitesmList = state.listProduct;
                                            }

                                            int size = cartitesmList.length;

                                            double height = 0;

                                            animationBloc.add(AnimationCartEvent(size: height));

                                            return BlocProvider(
                                              create: (context) => animationBloc,
                                              child: BlocBuilder(
                                                  bloc: animationBloc,
                                                  builder: (context, state2) {
                                                    if (state2 is AnimationCartState) {
                                                      height = state2.size;
                                                      if (size == 1) {
                                                        height = cartitesmList.length *
                                                            (MediaQuery.of(context)
                                                                .copyWith()
                                                                .size
                                                                .height *
                                                                0.30);
                                                      } else if (size > 2) {
                                                        height = (MediaQuery.of(context)
                                                            .copyWith()
                                                            .size
                                                            .height *
                                                            0.53);
                                                      } else {
                                                        height = (cartitesmList.length *
                                                            (MediaQuery.of(context)
                                                                .copyWith()
                                                                .size
                                                                .height *
                                                                0.21));
                                                      }
                                                    }
                                                    return AnimatedContainer(
                                                      height: height,
                                                      duration: const Duration(seconds: 2),
                                                      // Provide an optional curve to make the animation feel smoother.
                                                      curve: Curves.fastOutSlowIn,
                                                      child: Container(
                                                        height: height,
                                                        child: Scaffold(
                                                          backgroundColor: Colors.transparent,

                                                          body: Container(
                                                            decoration: const BoxDecoration(
                                                              borderRadius: BorderRadius.vertical(
                                                                top: Radius.circular(25),
                                                              ),
                                                              color: ColorName.aquaHazeColor,
                                                            ),
                                                            child: Container(
                                                              padding: EdgeInsets.only(top: 10),
                                                              child: Column(
                                                                children: [
                                                                  Container(
                                                                    padding: EdgeInsets.symmetric(
                                                                        vertical: 10),
                                                                    child: Text(
                                                                      "Your cart (${cartitesmList.length} ${cartitesmList.length > 1 ? 'items' : 'item'})",
                                                                      style: TextStyle(
                                                                          fontSize: Constants.SizeMidium,
                                                                          fontFamily:
                                                                          Fontconstants.fc_family_sf,
                                                                          fontWeight: Fontconstants
                                                                              .SF_Pro_Display_SEMIBOLD,
                                                                          color: ColorName.ColorPrimary),
                                                                    ),
                                                                  ),
                                                                  height == 0
                                                                      ? Container()
                                                                      : Container(
                                                                    child: Expanded(
                                                                      // height: height - 130,
                                                                      child: ListView.builder(
                                                                        shrinkWrap: true,
                                                                        itemCount:
                                                                        cartitesmList.length,
                                                                        itemBuilder:
                                                                            (context, index) {
                                                                          var dummyData =
                                                                          cartitesmList[index];

                                                                          if (state
                                                                          is CardUpdateQuanitiyState) {
                                                                            debugPrint(
                                                                                "CardUpdateQuantity");
                                                                            cartitesmList[state.index]
                                                                                .addQuantity =
                                                                                state.quantity;
                                                                          }

                                                                          return categoryItemView(
                                                                              context,
                                                                              cartitesmList,
                                                                              dummyData,
                                                                              null,
                                                                              0, () {
                                                                            dummyData.addQuantity =
                                                                                dummyData
                                                                                    .addQuantity +
                                                                                    1;

                                                                            debugPrint(
                                                                                "${dummyData.addQuantity}");

                                                                            updateCard(dummyData,
                                                                                index, cartitesmList);

                                                                            blocShopby.add(
                                                                                ShopByNullEvent());
                                                                            blocShopby.add(
                                                                                ShopbyProductChangeEvent(
                                                                                    model:
                                                                                    dummyData));

                                                                            blocFeatured.add(
                                                                                ProductUpdateQuantityEventBYModel(
                                                                                    model:
                                                                                    dummyData));

                                                                            blocFeatured.add(
                                                                                ProductChangeEvent(
                                                                                    model:
                                                                                    dummyData));

                                                                            debugPrint(
                                                                                "Increase cart ");
                                                                          }, () async {
                                                                            if (dummyData
                                                                                .addQuantity ==
                                                                                1) {
                                                                              dummyData
                                                                                  .addQuantity = 0;
                                                                              blocFeatured.add(
                                                                                  ProductUpdateQuantityEventBYModel(
                                                                                      model:
                                                                                      dummyData));
                                                                              blocShopby.add(
                                                                                  ShopByNullEvent());
                                                                              blocShopby.add(
                                                                                  ShopbyProductChangeEvent(
                                                                                      model:
                                                                                      dummyData));
                                                                              await dbhelper
                                                                                  .deleteCard(int
                                                                                  .parse(dummyData
                                                                                  .productId!))
                                                                                  .then((value) {
                                                                                debugPrint(
                                                                                    "Delete Product $value ");
                                                                                cardBloc.add(CardDeleteEvent(
                                                                                    model:
                                                                                    cartitesmList[
                                                                                    index],
                                                                                    listProduct:
                                                                                    cartitesmList));
                                                                                dbhelper
                                                                                    .loadAddCardProducts(
                                                                                    cardBloc);

                                                                                cartitesmList
                                                                                    .removeAt(
                                                                                    index);

                                                                                if (cartitesmList
                                                                                    .length ==
                                                                                    0) {
                                                                                  cardBloc.add(
                                                                                      CardEmptyEvent());
                                                                                  Navigator.pop(
                                                                                      context);
                                                                                }
                                                                              });
                                                                            } else if (dummyData
                                                                                .addQuantity !=
                                                                                0) {
                                                                              dummyData
                                                                                  .addQuantity =
                                                                                  dummyData
                                                                                      .addQuantity -
                                                                                      1;

                                                                              updateCard(
                                                                                  dummyData,
                                                                                  index,
                                                                                  cartitesmList);
                                                                              blocFeatured.add(
                                                                                  ProductUpdateQuantityEventBYModel(
                                                                                      model:
                                                                                      dummyData));
                                                                              blocShopby.add(
                                                                                  ShopByNullEvent());
                                                                              blocFeatured.add(
                                                                                  ProductChangeEvent(
                                                                                      model:
                                                                                      dummyData));
                                                                              blocShopby.add(
                                                                                  ShopByNullEvent());
                                                                              blocShopby.add(
                                                                                  ShopbyProductChangeEvent(
                                                                                      model:
                                                                                      dummyData));
                                                                            }
                                                                          }, () async {
                                                                            dummyData.addQuantity =
                                                                            0;
                                                                            blocFeatured.add(
                                                                                ProductUpdateQuantityEventBYModel(
                                                                                    model:
                                                                                    dummyData));
                                                                            blocShopby.add(
                                                                                ShopByNullEvent());
                                                                            blocShopby.add(
                                                                                ShopbyProductChangeEvent(
                                                                                    model:
                                                                                    dummyData));
                                                                            await dbhelper
                                                                                .deleteCard(int
                                                                                .parse(dummyData
                                                                                .productId!))
                                                                                .then((value) {
                                                                              debugPrint(
                                                                                  "Delete Product $value ");
                                                                              cardBloc.add(CardDeleteEvent(
                                                                                  model:
                                                                                  cartitesmList[
                                                                                  index],
                                                                                  listProduct:
                                                                                  cartitesmList));
                                                                              dbhelper
                                                                                  .loadAddCardProducts(
                                                                                  cardBloc);

                                                                              cartitesmList
                                                                                  .removeAt(index);

                                                                              if (cartitesmList
                                                                                  .length ==
                                                                                  0) {
                                                                                cardBloc.add(
                                                                                    CardEmptyEvent());
                                                                                Navigator.pop(
                                                                                    context);
                                                                              }
                                                                            });
                                                                          }, () {
                                                                            dbhelper
                                                                                .loadAddCardProducts(
                                                                                cardBloc);
                                                                            // refresh();
                                                                          }, true, false, () {},
                                                                              false);
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          // translate the FAB up by 30
                                                          floatingActionButton: Container(
                                                            transform: Matrix4.translationValues(
                                                                0.0, -60, 0.0), // translate up by 30
                                                            child: InkWell(
                                                                onTap: () {
                                                                  // do stuff
                                                                  debugPrint('doing stuff');
                                                                  animationBloc
                                                                      .add(AnimationCartEvent(size: 0));
                                                                },
                                                                child: Image.asset(
                                                                  Imageconstants.img_roud_cross,
                                                                  height: 40,
                                                                  width: 40,
                                                                )),
                                                          ),
                                                          floatingActionButtonLocation:
                                                          FloatingActionButtonLocation.centerTop,


                                                        ),
                                                      ),
                                                    );
                                                  }),
                                            );
                                          }),
                                    )


                                ),

                                Positioned(
                                  bottom: 0,
                                  child: Container(
                                    width:Sizeconfig.getWidth(context),
                                    decoration: BoxDecoration(
                                      // color: Colors.white,

                                      color: ColorName
                                          .ColorPrimary,


                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          spreadRadius: 1,
                                          blurRadius: 5,
                                          offset: Offset(0, -2), // Changes position of shadow
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 10),

                                    child: Column(
                                      children: [
                                        Container(
                                          height: 1,
                                          width: Sizeconfig.getWidth(context),
                                          color:
                                          ColorName.textlight.withOpacity(0.1),
                                        ),
                                        Container(
                                          height: 69,
                                          child: InkWell(
                                            onTap: () {
                                              if (isup) {

                                                animationBloc.add(AnimatedNullEvent());
                                                animationBloc.add(AnimatedNullEvent());

                                                animationBloc.add(AnimationCartEvent(size: 350.00));
                                                debugPrint("Action GG 1");
                                                isup=false;
                                                // Appwidgets.ShowDialogBottom(
                                                //     context,
                                                //     cardBloc,
                                                //     cartitesmList,
                                                //     blocFeatured,
                                                //     blocShopby, () {
                                                //   dbhelper.loadAddCardProducts(
                                                //       cardBloc);
                                                //   callback();
                                                // }, validate);
                                              } else {

                                                animationBloc.add(AnimatedNullEvent());
                                                animationBloc.add(AnimatedNullEvent());

                                                animationBloc.add(AnimationCartEvent(size: 70.00));
                                                //   Navigator.pop(context);
                                                debugPrint("Action GG 2");
                                                isup=true;
                                              }
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(


                                                      child: Container(
                                                        height:
                                                        Sizeconfig.getWidth(
                                                            context) *
                                                            0.13,
                                                        width:
                                                        Sizeconfig.getWidth(
                                                            context) *
                                                            0.13,


                                                        child: Stack(
                                                          children: [
                                                            Positioned(
                                                              bottom:0,
                                                              left: 0,
                                                              child: Container(

                                                                child: Image.asset(
                                                                  height:
                                                                  Sizeconfig.getWidth(
                                                                      context) *
                                                                      0.10,
                                                                  width:
                                                                  Sizeconfig.getWidth(
                                                                      context) *
                                                                      0.11,
                                                                  fit: BoxFit.fill,
                                                                  Imageconstants.img_cartnewicon,
                                                                ),
                                                              ),
                                                            ),
                                                            Positioned(
                                                              right: 0,
                                                              child: Container(
                                                                margin: EdgeInsets.only(
                                                                    left: 12),
                                                                height: 18,
                                                                width: 18,
                                                                decoration: BoxDecoration(
                                                                    color: ColorName.darkBlue,
                                                                    borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                        10.0)),
                                                                child: Center(
                                                                  child: Text(
                                                                    "${count}",
                                                                    style: TextStyle(
                                                                        fontSize: 10,
                                                                        fontFamily:
                                                                        Fontconstants
                                                                            .fc_family_sf,
                                                                        fontWeight:
                                                                        Fontconstants
                                                                            .SF_Pro_Display_Regular,
                                                                        color:
                                                                        Colors.white),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        // child: Icon(
                                                        //   Icons
                                                        //       .shopping_cart_outlined,
                                                        //   color: Colors.black,
                                                        //   size:
                                                        //   Sizeconfig.getWidth(
                                                        //       context) *
                                                        //       0.10,
                                                        // )

                                                        //     CommonCachedImageWidget(
                                                        //   imgUrl: image,
                                                        // ),
                                                        // color: Colors.red,
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(left: 15),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(

                                                                  StringContants
                                                                      .lbl_viewcart,
                                                                  style: TextStyle(
                                                                      fontSize: Constants.Sizelagre,
                                                                      fontFamily: Fontconstants.fc_family_popins,
                                                                      fontWeight: Fontconstants.SF_Pro_Display_Bold,
                                                                      color: Colors.white)),


                                                              Container(
                                                                  margin: EdgeInsets.only(left: 10),
                                                                  child:

                                                                  isup?
                                                                  new Container( // gray box
                                                                    child: new Center(
                                                                      child:  RotationTransition(
                                                                        child: Image.asset(
                                                                            isup
                                                                                ?Imageconstants.img_dropdownarrow
                                                                                : Imageconstants.img_dropdownarrow,
                                                                            height :16,
                                                                            width:16,
                                                                            fit:BoxFit.fill,
                                                                            color: Colors.white
                                                                        ),
                                                                        alignment: FractionalOffset.center,
                                                                        turns: new AlwaysStoppedAnimation(180 / 360),
                                                                      ),
                                                                    ),
                                                                  ):
                                                                  Image.asset(
                                                                      Imageconstants.img_dropdownarrow,

                                                                      height :16,
                                                                      width:16,
                                                                      fit:BoxFit.fill,
                                                                      color: Colors.white
                                                                  )
                                                              )
                                                            ],
                                                          ),
                                                          Text(
                                                            "Total : ${Constants.ruppessymbol}" +
                                                                totalAmount
                                                                    .toString() +
                                                                " ",
                                                            style: TextStyle(
                                                                fontSize: Constants
                                                                    .SizeSmall,
                                                                fontFamily:
                                                                Fontconstants
                                                                    .fc_family_popins,
                                                                fontWeight: Fontconstants
                                                                    .SF_Pro_Display_Bold,
                                                                color: Colors.white),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  child: Appwidgets.ButtonSecondarywhite(
                                                      validate
                                                          ? StringContants
                                                          .lbl_checkout
                                                          : StringContants.lbl_next,
                                                          () {
                                                        debugPrint(
                                                            "Product validation count ${validate}");

                                                        if (isup == false) {
                                                          // Navigator.pop(context);
                                                        }

                                                        if (validate) {
                                                          Productvalidationswidgets
                                                              .loadProductValication(
                                                              context,
                                                              cartitesmList, () {
                                                            debugPrint(
                                                                "isup%%%**  ${isup}");
                                                            callback();
                                                            dbhelper
                                                                .loadAddCardProducts(
                                                                cardBloc);
                                                          });
                                                        } else {
                                                          String id = "";
                                                          for (var x in cartitesmList) {
                                                            id =
                                                                id + x.productId! + ",";
                                                          }

                                                          if (id.endsWith(',')) {
                                                            id = id.substring(
                                                                0, id.length - 1);
                                                          }

                                                          debugPrint(
                                                              "ProductsIds ${id}");
                                                          ApiProvider()
                                                              .beforeYourCheckout(id, 1)
                                                              .then((value) async {
                                                            if (value != "") {
                                                              Navigator.pushNamed(
                                                                context,
                                                                Routes
                                                                    .ordersummary_screen,
                                                                arguments: {
                                                                  "ProductsIds": id,
                                                                  "response": value,
                                                                },
                                                              ).then((value) {
                                                                callback();
                                                              });
                                                            }
                                                          });
                                                        }
                                                      }),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          );
                        })),
                      ),
                    ),
                  );
                }),
          );
        }),
  );
}
*/
