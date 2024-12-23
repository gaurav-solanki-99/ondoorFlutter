import 'dart:convert';
import 'dart:developer';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ondoor/constants/ImageConstants.dart';
import 'package:ondoor/models/AllProducts.dart';
import 'package:ondoor/models/filter_data_params.dart';
import 'package:ondoor/models/get_filter_response.dart';
import 'package:ondoor/screens/AddCard/card_bloc.dart';
import 'package:ondoor/screens/FeaturedProduct/FeatuuredBloc/featured_bloc.dart';
import 'package:ondoor/screens/NewAnimation/animation_state.dart';
import 'package:ondoor/screens/shop_by_category/shop_by_category_bloc/shop_by_category_bloc.dart';
import 'package:ondoor/services/ApiServices.dart';
import 'package:ondoor/utils/Comman_Loader.dart';
import 'package:ondoor/utils/Connection.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/SizeConfig.dart';
import 'package:ondoor/constants/Constant.dart';
import 'package:ondoor/constants/StringConstats.dart';
import 'package:ondoor/utils/shimmerUi.dart';
import 'package:ondoor/widgets/MyDialogs.dart';
import 'package:ondoor/widgets/common_box_widget.dart';
import 'package:ondoor/widgets/common_cached_image_widget.dart';
import 'package:ondoor/widgets/filter_widget.dart';
import 'package:ondoor/widgets/ondoor_loader_widget.dart';
import 'package:speech_to_text_google_dialog/speech_to_text_google_dialog.dart';
import '../../constants/CustomTextFormFilled.dart';
import '../../constants/FontConstants.dart';
import '../../database/database_helper.dart';
import '../../database/dbconstants.dart';
import '../../models/HomepageModel.dart';
import '../../models/shop_by_category_response.dart';
import '../../services/Navigation/routes.dart';
import '../../utils/Commantextwidget.dart';
import '../../utils/Utility.dart';
import '../../utils/colors.dart';
import '../../utils/sharedpref.dart';
import '../../utils/themeData.dart';
import '../../widgets/AppWidgets.dart';
import '../../widgets/animated_drop_down.dart';
import '../AddCard/card_event.dart';
import '../AddCard/card_state.dart';
import '../FeaturedProduct/FeatuuredBloc/featured_event.dart';
import '../FeaturedProduct/FeatuuredBloc/featured_state.dart';
import '../HomeScreen/HomeBloc/home_page_bloc.dart';
import '../HomeScreen/HomeBloc/home_page_event.dart';
import '../HomeScreen/HomeBloc/home_page_state.dart';
import '../NewAnimation/animation_bloc.dart';
import '../NewAnimation/animation_event.dart';

class ShopByCategoryScreen extends StatefulWidget {
  Map<String, dynamic> arguementData = {};

  ShopByCategoryScreen({super.key, required this.arguementData});

  @override
  State<ShopByCategoryScreen> createState() => _ShopByCategoryScreenState();
}

class _ShopByCategoryScreenState extends State<ShopByCategoryScreen>
    with TickerProviderStateMixin {
  late AnimationController controller;
  Category selectedCategory = Category();
  List<ProductData>? list = [];
  List<ProductData>? listTemp = [];
  List<Category> sectorList = [];
  final itemKey = GlobalKey();
  List<SubCategory> categoryList = [];
  ScrollController scrollController = ScrollController();
  ScrollController productScrollController = ScrollController();
  ScrollController filterScrollController = ScrollController();
  List<SubCategory> subCategoryList = [];
  int isMoreUnitIndex = 0;
  List<ProductUnit> unitList = [];
  ProductUnit selectedUnit = ProductUnit();
  bool showWarningMessage = false;
  bool offerAppilied = false;
  int selectedIndex = 0;
  int itemcount = 0;
  String errorMessage = "";
  bool showSectors = false;
  bool isFilterOn = false;
  bool isLoading = false;
  AnimationBloc animationBloc = AnimationBloc();
  var animationsizebottom = 0.0;
  late TabController tabController;
  List<Filter> selected_filter_list = [];
  List<FilterGroup> selectedFilterGroup = [];
  List<FilterDataParams> filterDataParams = [];
  bool isSortingFilter = false;
  ShopByCategoryBloc shopByCategoryBloc = ShopByCategoryBloc();
  int tabIndex = 0;
  int pageNumber = 0;
  String? selectedSort;
  SubCategory? selectedSubFiltercategory;
  String selectedSubcategoryId = "";
  String selectedFilterName = "";
  CardBloc cardBloc = CardBloc();
  final dbHelper = DatabaseHelper();
  List<ProductUnit> cardItesmList = [];
  FeaturedBloc bloc = FeaturedBloc();
  TextEditingController searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);
  var _width;
  var _height = 0.0;
  double bottomviewheight = 0;
  double screenHeight = 0.0;
  bool isLargeScreen = false;
  double animationImageSize = 0;
  final GlobalKey _bottomNavigationKey = GlobalKey();
  HomePageBloc homePageBloc2 = HomePageBloc();
  bool isOpenBottomview = false;
  bool paginationOn = false;
  bool paginationWithFilterCategory = false;
  bool isExpanded = false;
  bool initalState = true;

  bool bottomviewstatus = false;
  initializedDb() async {
    await dbHelper.init();
    cardBloc = CardBloc();
    SharedPref.setStringPreference(Constants.OrderidForEditOrder, "");
    SharedPref.setStringPreference(Constants.OrderPlaceFlow, "");
    //   animationBloc = AnimationBloc();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(
      () {},
    );
    String fcmToken = await MyUtility().getFcmToken();
    String serverToken = await MyUtility.getServerToken();
    print("FCM TOKEN ${fcmToken}");
    print("SERVER TOKEN ${serverToken}");
    dbHelper.loadAddCardProducts(cardBloc);
  }

  String getFilterGroupIdForFilter(Filter filter) {
    // Find the filter group that contains the given filter
    for (var group in selectedFilterGroup) {
      if (group.filter != null &&
          group.filter!.any((f) => f.filterId == filter.filterId)) {
        return group.filterGroupId ?? "";
      }
    }
    return ""; // Return an empty string if the filter group is not found
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

  addCard(ProductUnit model) async {
    if (model.addQuantity != 0) {
      String image_array_json = "";
      for (int i = 0; i < model!.imageArray!.length; i++) {
        if (i == 0) {
          image_array_json = model!.imageArray![i].toJson() + "";
        } else {
          image_array_json = "," + model!.imageArray![i].toJson();
        }
      }

      if (image_array_json.startsWith(',')) {
        image_array_json = image_array_json.substring(1);
      }
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
      print("26NovA1");
      // cardBloc.add(AddCardEvent(count: status));
      dbHelper.loadAddCardProducts(cardBloc);
    }
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

  @override
  void initState() {
    initializedDb();
    selectedCategory = widget.arguementData["selected_category"];
    categoryList = selectedCategory.subCategories!;
    shopByCategoryBloc.selectedSubcategory =
        widget.arguementData["selected_sub_category"];

    print(
        "SELECTED SUBCATEGORY ${shopByCategoryBloc.selectedSubcategory?.toJson()}");
    if (shopByCategoryBloc.selectedSubcategory!.name == "All" ||
        shopByCategoryBloc.selectedSubcategory!.name == "all") {
      initalState = false;
    }
    /*   categoryList.forEach(
      (element) {
        print("ELEMENT NAME ${element.name}");
        if(element.name==shopByCategoryBloc.selectedSubcategory!.name!){
          int index=categoryList.indexWhere(shopByCategoryBloc.selectedSubcategory!.name!);
          productScrollController.animateTo(
            0,
            duration: Duration(seconds: 1), // Scrolling to the top
            curve: Curves.easeInOut, // Smooth animation
          );
        }
      },
    );*/
    subCategoryList =
        shopByCategoryBloc.selectedSubcategory!.subCategories ?? [];
    shopByCategoryBloc.categoryfromPreviousScreen =
        shopByCategoryBloc.selectedSubcategory!;

    selectedSubcategoryId =
        shopByCategoryBloc.selectedSubcategory?.categoryId ?? "";
    sectorList = widget.arguementData["category_list"];
    print("CATEGORY DATA ${selectedCategory.toJson()}");
    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    scrollController.addListener(
      () {
        print("offset   ${scrollController.offset}");
        print("maxScrollExtent   ${scrollController.position.maxScrollExtent}");
        if (scrollController.hasClients && scrollController.position.atEdge) {
          // scrollController.animateTo(
          //   scrollController.position.minScrollExtent,
          //   duration: Duration(seconds: 2),
          //   curve: Curves.fastOutSlowIn,
          // );
          // scrollController.jumpTo(scrollController.position.minScrollExtent);

          shopByCategoryBloc.add(ShopByNullEvent());
        }
      },
    );
    productScrollController.addListener(() {
      productScrollListener();
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        Future.delayed(
          const Duration(milliseconds: 100),
          () {
            int index = categoryList.indexWhere(
              (element) =>
                  element.categoryId ==
                  shopByCategoryBloc.selectedSubcategory?.categoryId,
            );

            if (scrollController.hasClients) {
              if (index >= 0 && index < (categoryList.length - 1)) {
                const double itemExtent = 100.0; // Height of each item
                double maxOffset = scrollController.position.maxScrollExtent;

                // Check if the current index is the last item

                // For other items, calculate offset normally and ensure it is within bounds
                double offset = index * itemExtent;
                double finalOffset = min(offset, maxOffset);

                scrollController.animateTo(
                  finalOffset,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
              if (index == categoryList.length - 1) {
                print(
                    "INDEX: $index | CATEGORY LENGTH: ${categoryList.length}");

                // Directly scroll to maxOffset for the last item
                scrollController.animateTo(
                  scrollController.position.maxScrollExtent + 100,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.fastOutSlowIn,
                );
              }
            }
          },
        );
      },
    );
    bloc = FeaturedBloc();
    super.initState();
  }

  void productScrollListener() {
    if (productScrollController.offset ==
            productScrollController.position.maxScrollExtent
        /*productScrollController.position.userScrollDirection ==
                ScrollDirection.reverse &&*/
        ) {
      if (shopByCategoryBloc.isPaginationListEnded == false) {
        if (selected_filter_list.isEmpty) {
          pageNumber = pageNumber + 1;
          shopByCategoryBloc.add(ShopByNullEvent());
          shopByCategoryBloc.pageNumber = shopByCategoryBloc.pageNumber + 1;
          print(
              "CATEGORY NAME ${shopByCategoryBloc.selectedSubcategory!.categoryId} NAME ${shopByCategoryBloc.selectedSubcategory!.name}");
          shopByCategoryBloc.callingApi(selectedSubcategoryId, "6", context);
        } else {
          shopByCategoryBloc.pageNumber = shopByCategoryBloc.pageNumber + 1;
          shopByCategoryBloc.subCategoryList = subCategoryList;
          shopByCategoryBloc.getFilteredData(
            selectedSubcategoryId,
            context,
            filterDataParams,
            subCategoryList,
          );
        }
      }
    } /*else if (productScrollController.position.userScrollDirection ==
            ScrollDirection.idle) {
        }*/ /* else if (shopByCategoryBloc.isPaginationListEnded &&
            shopByCategoryBloc.pageNumber > 1 &&
            productScrollController.position.atEdge &&
            productScrollController.position.userScrollDirection ==
                ScrollDirection.reverse) {
          // Fluttertoast.showToast(
          //     msg: "No More Data Found!",
          //     timeInSecForIosWeb: 1,
          //     backgroundColor: ColorName.ColorPrimary,
          //     textColor: Colors.white,
          //     toastLength: Toast.LENGTH_SHORT);
        }*/
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // controller.dispose();
    productScrollController.dispose();
    scrollController.dispose();
    CommanLoader().dismissEasyLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => shopByCategoryBloc,
      child: BlocBuilder(
        bloc: shopByCategoryBloc,
        builder: (context, state) {
          Appwidgets.setStatusBarColor();
          // if (subCategoryList.isEmpty) {
          //   subCategoryList = selectedCategory.subCategories![0].subCategories!;
          // }
          debugPrint("CURRENT STATE $state");
          debugPrint(
              "routetoProductDetail ${shopByCategoryBloc.routetoProductDetail}");
          isSortingFilter = selectedFilterGroup.any(
            (element) {
              print("ELEMENT ${element.name}");
              print("ELEMENT ${element.toJson()}");
              return element.name == "Sort" ? true : false;
            },
          );
          screenHeight = Sizeconfig.getHeight(context);
          isLargeScreen = screenHeight > 800;
          if (state is ShopByCategoryInitialState) {
            isLoading = false;
            //   shopByCategoryBloc.addCategoryData(selectedCategory, context);
            shopByCategoryBloc.addCategoryData2(selectedCategory,
                shopByCategoryBloc.selectedSubcategory!, context);
          }
          if (state is ShopByCategoryErrorState) {
            isLoading = false;
            errorMessage = state.errorMessage;
            list!.clear();
            subCategoryList =
                shopByCategoryBloc.selectedSubcategory!.subCategories ?? [];
          }
          if (state is ShopByCategoryLoadedState) {
            isLoading = false;
            shopByCategoryBloc.routetoProductDetail = false;
            subCategoryList = state.subCategoryList;
            selectedIndex = state.selectedIndex;
            //   unitList = state.unitList;
            if (shopByCategoryBloc.pageNumber == 1) {
              list = state.unitList;
              listTemp = state.unitList;
            } else {
              if (shopByCategoryBloc.isPaginationListEnded) {
                list = (list! + state.unitList)!;
                listTemp = (listTemp! + state.unitList)!;
                list = list!.toSet().toList();
                listTemp = listTemp!.toSet().toList();
              } else {
                list = (list! + state.unitList)!;
                listTemp = (listTemp! + state.unitList)!;
              }
            }
            //  listTemp = state.unitList;
            // if (productScrollController.hasClients) {
            //   print(
            //       "offset ${productScrollController.offset} maxScrollExtent ${productScrollController.position.maxScrollExtent} ISPAGINATIONENDED ${shopByCategoryBloc.isPaginationListEnded}");
            // }

            bloc.add(ProductForShopByEvent(list: list));

            // for (int i = 0; i < unitList.length; i++) {
            //   // List<ProductUnit> lista =[];
            //   // lista.add(unitList[i]);
            //   // list!.add(ProductData(unit: lista));
            //
            //
            //
            //   getCartQuantity(unitList[i].productId!).then((value) {
            //     debugPrint("getCartQuanity $value");
            //     unitList[i].addQuantity = value;
            //     shopByCategoryBloc.add(ShopByNullEvent());
            //     shopByCategoryBloc
            //         .add(ShopbyProductChangeEvent(model: unitList[i]));
            //   });
            //
            //   ProductUnit newmodel = unitList[i];
            //   if (newmodel!.cOfferId != 0 && newmodel.cOfferId != null) {
            //     debugPrint("Shopby***********************");
            //     if (newmodel.subProduct != null) {
            //       log("Shopby***********************>>>>>>>>>>>>>>>>" +
            //           newmodel.subProduct!.toJson());
            //       if (newmodel.subProduct!.subProductDetail!.length > 0) {
            //         unitList[i].subProduct!.subProductDetail =
            //             MyUtility.checkOfferSubProductLoad(newmodel, dbHelper);
            //
            //         shopByCategoryBloc.add(ShopByNullEvent());
            //         shopByCategoryBloc
            //             .add(ShopbyProductChangeEvent(model: unitList[i]));
            //       }
            //     }
            //   }
            // }
          }
          if (state is ShopByCategoryLoadingState) {
            isLoading = true;
          }
          if (state is ShopbyProductUpdateQuantityState) {
            selectedIndex = state.index;
            selectedUnit = state.model;
            isLoading = false;

            // unitList = state.unitList;
          }
          if (state is SectorChangeState) {
            isLoading = false;

            selectedCategory = state.selectedCategory;
            sectorList = state.categoryList;
            categoryList = selectedCategory.subCategories!;
            print("SELECTED CATEGORY ${selectedCategory.toJson()}");
            shopByCategoryBloc.category = selectedCategory;
            selectedSubcategoryId = selectedCategory.id ?? "";
            // subCategoryList = category.subCategories![0].subCategories!;
            list!.clear();
            listTemp!.clear();
            selected_filter_list!.clear();
            filterDataParams!.clear();
            shopByCategoryBloc.pageNumber = 1;
            shopByCategoryBloc.callingApi(selectedSubcategoryId, "5", context);
          }
          if (state is WeightChangeState) {
            isLoading = false;

            selectedUnit = state.unit;
            selectedIndex = state.selectedIndex;
            selectedUnit.selectedUnitIndex = selectedIndex;

            print("Weight Changed GGGGG ${selectedIndex}");
          }
          if (state is FilterState) {
            isFilterOn = state.isFilterOn;
          }
          if (state is ShopByCategoryErrorState) {
            pageNumber = 1;
          }

          if (state is SearchAnimatedState) {
            _height = state.height;
            searchController.clear();
            isLoading = false;
          }
          // print(
          //     "SHOP BY CATEGORY UPDATE QUANTITY  ${selectedIndex}\nSHOP BY CATEGORY Selected Quantity ${selectedUnit.toJson()} ");
          print("LOADING STATE ${isLoading}");
          return Stack(
            children: [
              buildCategoryView(context, state),
              isLoading && shopByCategoryBloc.pageNumber == 1
                  ? Container(
                      color: Colors.black.withOpacity(.2),
                      width: Sizeconfig.getWidth(context),
                      height: Sizeconfig.getHeight(context),
                      child: Center(child: OndoorLoaderWidget()))
                  : const SizedBox.shrink(),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget appBar(context) {
    return AppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: ColorName.ColorPrimary,
      ),
      leading: InkWell(
        onTap: () {
          functiontoCloseDropDown(eventtoperform: () {
            Navigator.pop(context);
          });
        },
        child: const Align(
          alignment: Alignment.center,
          child: Icon(
            Icons.arrow_back_ios,
            color: ColorName.ColorBagroundPrimary,
          ),
        ),
      ),
      centerTitle: true,
      title: Center(
        //     child: AnimatedContainer(
        //   duration: Duration(milliseconds: 0),
        //   curve: Curves.linear,
        //   transform: Matrix4.rotationX(.2),
        //   transformAlignment: Alignment.bottomCenter,
        //   clipBehavior: Clip.none,
        //   foregroundDecoration:
        //       BoxDecoration(borderRadius: BorderRadius.circular(10)),
        //   child: DropdownButtonHideUnderline(
        //     child: Theme(
        //       data: OndoorThemeData.lightTheme,
        //       child: DropdownButton<Category>(
        //         borderRadius: BorderRadius.circular(15),
        //         value: category,
        //         onChanged: (newValue) {
        //           if (newValue != null) {
        //             category = newValue;
        //             shopByCategoryBloc.currentIndex = 0;
        //             shopByCategoryBloc
        //                 .add(SectorChangeEvent(category, sectorList));
        //           }
        //         },
        //         icon: const SizedBox(), // Show dropdown icon
        //         style: Appwidgets()
        //             .commonTextStyle(ColorName.black)
        //             .copyWith(fontWeight: FontWeight.w400),
        //         selectedItemBuilder: (BuildContext context) {
        //           return sectorList.map((Category value) {
        //             return Padding(
        //               padding: const EdgeInsets.symmetric(vertical: 2),
        //               child: Row(
        //                 children: [
        //                   Text(
        //                     value.name!,
        //                     style: TextStyle(
        //                       fontSize: 16,
        //                       color: ColorName.ColorBagroundPrimary,
        //                     ),
        //                   ),
        //                   Icon(
        //                     Icons.keyboard_arrow_down,
        //                     color: ColorName.ColorBagroundPrimary,
        //                   )
        //                 ],
        //               ),
        //             );
        //           }).toList();
        //         },
        //         items:
        //             sectorList.map<DropdownMenuItem<Category>>((Category value) {
        //           return DropdownMenuItem<Category>(
        //             value: value,
        //             child: Padding(
        //               padding:
        //                   const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        //               child: Text(
        //                 value.name!,
        //                 style: TextStyle(color: ColorName.black),
        //               ),
        //             ),
        //           );
        //         }).toList(),
        //       ),
        //     ),
        //   ),
        // )
        child: BlocBuilder(
          bloc: animationBloc,
          builder: (context, state) {
            double cartsize = 0.0;
            if (state is AnimationCartState) {
              cartsize = state.size;
              // debugPrint("HomeBottomSheetState ${state.status}");
            }
            return AnimatedDropdownButton<Category>(
              animationBloc: animationBloc,
              isOpenBottomview: cartsize <= 70 ? false : true,
              homePageBloc: homePageBloc2,
              controller: controller,
              items: sectorList,
              selectedItem: selectedCategory,
              onChanged: (newValue) {
                if (newValue != null) {
                  initalState = false;
                  selectedCategory = newValue;
                  shopByCategoryBloc.currentIndex = 0;
                  resetData();
                  shopByCategoryBloc
                      .add(SectorChangeEvent(selectedCategory, sectorList));
                }
              },
              itemBuilder: (Category value) => value.name!,
              selectedItemBuilder: (Category value) => initalState
                  ? shopByCategoryBloc.selectedSubcategory!.name!
                  : value.name!,
              borderRadius: BorderRadius.circular(15),
            );
          },
        ),
      ),
      actions: [
        Align(
          alignment: Alignment.center,
          child: InkWell(
            onTap: () {
              List<ProductData> list = [];
              functiontoCloseDropDown(eventtoperform: () {
                Navigator.pushNamed(context, Routes.featuredProduct,
                    arguments: {
                      "key": StringContants.lbl_search,
                      "list": list,
                      "paninatinUrl": ""
                    }).then((value) {
                  initializedDb();
                  OndoorThemeData.setStatusBarColor();
                });
              });
              /* functiontoCloseDropDown(eventtoperform: () {
                if (_height == 50.0) {
                  _height = 0.0;
                } else {
                  _height = 50.0;
                }

                shopByCategoryBloc.add(ShopByNullEvent());
                shopByCategoryBloc.add(SearchAnimatedEvent(height: _height));
                homePageBloc2
                    .add(HomeBottomSheetEvent(status: isOpenBottomview));
              });*/
              /*   if (controller.status == AnimationStatus.completed) {
                controller.reverse().then(
                  (value) {

                  },
                );
              }
              else {
                if (_height == 50.0) {
                  _height = 0.0;
                } else {
                  _height = 50.0;
                }

                shopByCategoryBloc.add(ShopByNullEvent());
                shopByCategoryBloc.add(SearchAnimatedEvent(height: _height));
              }*/
            },
            child: Icon(
              _height == 0.0 ? Icons.search : Icons.search_off,
              color: ColorName.ColorBagroundPrimary,
            ),
          ),
        ),
        10.toSpace
      ],
    );
  }

  functiontoCloseDropDown({required Function eventtoperform}) {
    if (controller.status == AnimationStatus.completed) {
      controller.reverse().then((value) {
        eventtoperform();
      });
    } else {
      eventtoperform();
    }
  }

  Widget buildCategoryView(BuildContext context, state) {
    _width = Sizeconfig.getWidth(context);
    return MediaQuery(
        data: Appwidgets().mediaqueryDataforWholeApp(context: context),
        child: Scaffold(
          appBar: appBar(context),
          body: Container(
            height: Sizeconfig.getHeight(context),
            child: Stack(
              children: [
                Container(
                  height: Sizeconfig.getHeight(context),
                  child: SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          // Use the properties stored in the State class.
                          width: _width,
                          height: _height,
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                          ),
                          // Define how long the animation should take.
                          duration: const Duration(seconds: 1),
                          // Provide an optional curve to make the animation feel smoother.
                          curve: Curves.fastOutSlowIn,
                          child: Container(
                              color: ColorName.ColorBagroundPrimary,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: CustomTextField(
                                ontap: () {
                                  debugPrint("GG GoogeleSpeech Dialog ");
                                  googleSpeechDialog();
                                },
                                keyboardType: TextInputType.emailAddress,
                                obscureText: false,
                                hintText: StringContants.lbl_search_hint,
                                activeIcon: Imageconstants.img_search,
                                // Provide the actual path to the active icon
                                inactiveIcon: Imageconstants.img_search,
                                padding: EdgeInsets.only(
                                  top: 10,
                                  left: 5,
                                  right: 0,
                                  bottom: 10,
                                ),
                                suffixIcon: Imageconstants.img_microphon,
                                // Provide the actual path to the inactive icon
                                controller: searchController,
                                isPassword: false,
                                readOnly: false,
                                onSubmit: (value) {
                                  debugPrint("Search text ${value}");
                                  searchProduct(value);
                                },
                                onchanged: (result) {
                                  _debouncer.run(() async {});
                                },
                                iskeyboardopen: false,
                                hinttextlist: [],
                                //  iskeyboardopen: iskeyboardopen,
                              )),
                        ),
                        SingleChildScrollView(
                          reverse: true,
                          child: Container(
                            color: ColorName.whiteSmokeColor,
                            height: _height != 0.0
                                ? (Sizeconfig.getHeight(context) * 0.9)
                                : (Sizeconfig.getHeight(context)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    height: Sizeconfig.getHeight(context),
                                    color: ColorName.ColorBagroundPrimary,
                                    child: ListView.builder(
                                      key: itemKey,
                                      controller: scrollController,
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: categoryList.length,
                                      itemBuilder: (context, index) {
                                        SubCategory shopByCategoryData =
                                            categoryList[index];

                                        // if (index == 0) {
                                        //   selectedIndex = index;
                                        //   selectedSubcategory = shopByCategoryData;
                                        // }

                                        return InkWell(
                                          onTap: () {
                                            functiontoCloseDropDown(
                                                eventtoperform: () {
                                              changeCategoryDataFunction(
                                                  shopByCategoryData:
                                                      shopByCategoryData,
                                                  index: index);
                                            });
                                          },
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5, bottom: 5),
                                                child: navigationItemWidget(
                                                    state,
                                                    index,
                                                    shopByCategoryData,
                                                    context,
                                                    list),
                                              ),
                                              SizedBox(
                                                height: spacingWidgetForList(
                                                    categoryList.length - 1,
                                                    index),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                    flex: 4,
                                    child: productListWidgetwithFilter(state))
                                // : Center(child: Appwidgets.Text_20(errorMessage, ColorName.black))
                              ],
                            ),
                          ),
                        ),
                      ],
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

                          debugPrint("HomeBottomSheetState ${state.status}");
                        }

                        return bottomviewstatus
                            ? InkWell(
                                onTap: () {
                                  print(
                                      "IS OPEN BOTTOMVIEW ${isOpenBottomview}");
                                  functiontoCloseDropDown(eventtoperform: () {
                                    homePageBloc2.add(HomeNullEvent());
                                    homePageBloc2.add(
                                        HomeBottomSheetEvent(status: false));
                                    animationBloc
                                        .add(AnimationCartEvent(size: 70.00));
                                  });
                                },
                                child: Container(
                                  height: Sizeconfig.getHeight(context),
                                  color: Colors.black12.withOpacity(0.2),
                                ),
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
                            false,
                            context,
                            cardBloc,
                            bloc,
                            shopByCategoryBloc,
                            animationBloc,
                            animationsizebottom,
                            0,
                            "",
                            true,
                            dbHelper,
                            () async {
                              shopByCategoryBloc
                                  .add(ShopByCategoryInitialEvent());
                              //debugPrint(
                              //     "Gaurav Call back tag ${tag} title ${widget.title}");
                              // SystemChrome.setSystemUIOverlayStyle(
                              //     const SystemUiOverlayStyle(
                              //         statusBarColor: ColorName
                              //             .ColorPrimary, // Set status bar color here
                              //         statusBarIconBrightness: Brightness.light));
                              // initializedDb();
                              //
                              // if (!await Network.isConnected()) {
                              //   MyDialogs.showInternetDialog(context, () {
                              //     Navigator.pop(context);
                              //     if (widget.title == StringContants.lbl_search) {
                              //       searchProduct(searchController.text);
                              //     } else {
                              //       bloc.add(LoadingFeaturedEvent(title: tag));
                              //     }
                              //   });
                              // } else {
                              //   if (widget.title == StringContants.lbl_search) {
                              //     searchProduct(searchController.text);
                              //   } else {
                              //     bloc.add(LoadingFeaturedEvent(title: tag));
                              //   }
                              //  }
                            },
                            () {
                              shopByCategoryBloc
                                  .add(ShopByCategoryInitialEvent());
                            },
                            () {
                              functiontoCloseDropDown(eventtoperform: () {
                                homePageBloc2
                                    .add(HomeBottomSheetEvent(status: false));
                              });
                            },
                            false,
                            (value2) {
                              debugPrint("HomePage Screen back >>>>>  $value2");
                              isOpenBottomview = value2;
                              functiontoCloseDropDown(eventtoperform: () {
                                homePageBloc2.add(HomeNullEvent());
                                homePageBloc2.add(HomeBottomSheetEvent(
                                    status: isOpenBottomview));
                              });
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
          /*  bottomNavigationBar: Container(
            key: _bottomNavigationKey,
            child: Appwidgets.ShowBottomView(
                context,
                cardBloc,
                bloc,
                shopByCategoryBloc,
                animationBloc,
                animationsizebottom,
                0,
                "",
                true,
                dbHelper, () {
              shopByCategoryBloc.add(ShopByCategoryInitialEvent());
              initializedDb();

              shopByCategoryBloc.refreshingFilter(
                  selectedSubcategory!, selectedIndex, context, list);
            }, false))*/
        ));
  }

  resetData() {
    pageNumber = 1;
    shopByCategoryBloc.pageNumber = 1;
    shopByCategoryBloc.sortingIndex = "0";
    shopByCategoryBloc.selectedSubcategory = categoryList[0];
    selectedSubcategoryId =
        shopByCategoryBloc.selectedSubcategory!.categoryId ?? "";
    shopByCategoryBloc.selectedFilterCategory = "All";
  }

  changeCategoryDataFunction(
      {required SubCategory shopByCategoryData, required int index}) {
    if (shopByCategoryBloc.selectedSubcategory != shopByCategoryData) {
      // Resetting initial values
      paginationWithFilterCategory = false;
      shopByCategoryBloc.pageNumber = 1;
      pageNumber = 1;
      selectedIndex = index;
      shopByCategoryBloc.currentIndex = index;
      shopByCategoryBloc.selectedSubcategory = shopByCategoryData;
      selectedSubcategoryId = shopByCategoryData.categoryId ?? "";
      shopByCategoryBloc.selectedFilterCategory = "All";
      shopByCategoryBloc.categoryfromPreviousScreen = shopByCategoryData;
      selectedSubcategoryId = shopByCategoryData.categoryId ?? "";
      // Handling subcategory filtering
      if (productScrollController.hasClients) {
        productScrollController.animateTo(
          0,
          duration: Duration(seconds: 1), // Scrolling to the top
          curve: Curves.easeInOut, // Smooth animation
        );
      }

      if (selected_filter_list.isNotEmpty) {
        if (filterScrollController.hasClients) {
          filterScrollController.animateTo(
            0,
            duration: Duration(seconds: 1), // Scrolling to the top
            curve: Curves.easeInOut, // Smooth animation
          );
        }
        // if (scrollController.hasClients) {
        // scrollController.animateTo(
        //   0,
        //   duration: Duration(seconds: 1), // Scrolling to the top
        //   curve: Curves.easeInOut, // Smooth animation
        // );
        // }
        subCategoryList =
            shopByCategoryBloc.selectedSubcategory!.subCategories!;
        list!.clear();

        shopByCategoryBloc.getFilteredData(
          selectedSubcategoryId,
          context,
          filterDataParams,
          subCategoryList,
        );
      } else {
        if (filterScrollController.hasClients) {
          filterScrollController.animateTo(
            0,
            duration: Duration(seconds: 1), // Scrolling to the top
            curve: Curves.easeInOut, // Smooth animation
          );
        }
        if (scrollController.hasClients) {
          // scrollController.animateTo(
          //   0,
          //   duration: Duration(seconds: 1), // Scrolling to the top
          //   curve: Curves.easeInOut, // Smooth animation
          // );
        }
        shopByCategoryBloc.refreshingFilter(
          shopByCategoryBloc.selectedSubcategory!,
          selectedIndex,
          context,
          list,
        );

        // Emitting a reset event to avoid animation conflicts
        shopByCategoryBloc.add(ShopByNullEvent());
      }
    }
  }

  Widget productListWidgetwithFilter(state) {
    return Stack(
      children: [
        Center(child: mainView2(context, state)),
        selected_filter_list.isNotEmpty && isSortingFilter == false
            ? Padding(
                padding: const EdgeInsets.only(top: 40, right: 10),
                child: SizedBox(
                  height: 40,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: selected_filter_list.length,
                    itemBuilder: (context, index) {
                      var selectedFilterData = selected_filter_list[index];
                      return InkWell(
                        onTap: () {
                          selected_filter_list.remove(selectedFilterData);
                          Map<String, List<String>> filterGroupMap = {};
                          for (var filterData in selected_filter_list) {
                            String filterId = filterData.filterId ?? "";
                            String groupId = getFilterGroupIdForFilter(
                                filterData); // Implement this function

                            if (!filterGroupMap.containsKey(groupId)) {
                              filterGroupMap[groupId] = [];
                            }

                            if (filterData.isChecked) {
                              if (!filterGroupMap[groupId]!
                                  .contains(filterId)) {
                                filterGroupMap[groupId]!.add(filterId);
                              }
                            } else {
                              filterGroupMap[groupId]?.remove(filterId);
                            }
                          }
                          filterDataParams =
                              filterGroupMap.entries.map((entry) {
                            return FilterDataParams(
                              filterGroupId: entry.key,
                              filter: entry.value,
                            );
                          }).toList();
                          if (selected_filter_list.isEmpty) {
                            shopByCategoryBloc.callingApi(
                              selectedSubcategoryId,
                              "2",
                              context,
                            );
                            // shopByCategoryBloc.add(
                            //   FilterEvent(
                            //       isFilterOn: false),
                            // );
                            print("FILTER OFF");
                          } else {
                            shopByCategoryBloc.getFilteredData(
                              selectedSubcategoryId,
                              context,
                              filterDataParams,
                              subCategoryList,
                            );
                            print("FILTER ON");
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: ColorName.ColorBagroundPrimary,
                            border: Border.all(
                              color: ColorName.ColorPrimary,
                              width: .5,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          margin: const EdgeInsets.only(
                              top: 0, left: 5, bottom: 10),
                          child: Center(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              runAlignment: WrapAlignment.center,
                              direction: Axis.horizontal,
                              children: [
                                Text(
                                  selectedFilterData.name ?? "",
                                  style: Appwidgets()
                                      .commonTextStyle(ColorName.ColorPrimary)
                                      .copyWith(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14),
                                ),
                                Icon(
                                  Icons.close,
                                  size: 15,
                                  color: ColorName.ColorPrimary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            : const SizedBox.shrink(),
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            height: 40,
            child: Row(
              children: [
                sortingWidget(context, state),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: ListView.builder(
                    controller: filterScrollController,
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: subCategoryList.length,
                    itemBuilder: (context, index) {
                      var filterData = subCategoryList[index];
                      print("FILTER IMAGE  ${filterData.name}");
                      return InkWell(
                        onTap: () {
                          if (selectedSubcategoryId != filterData.categoryId) {
                            selectedSubcategoryId = filterData.categoryId ?? "";
                            // shopByCategoryBloc.selectedSubcategory = filterData;
                            shopByCategoryBloc.pageNumber = 1;
                            pageNumber = 1;
                            paginationWithFilterCategory = true;

                            if (selected_filter_list.isNotEmpty) {
                              shopByCategoryBloc.pageNumber = 1;
                              pageNumber = 1;
                              shopByCategoryBloc.getFilteredData(
                                  filterData.categoryId,
                                  context,
                                  filterDataParams,
                                  subCategoryList);
                            } else {
                              print("FILTER DATA ${filterData.toJson()}");
                              if (filterData.name == "All" &&
                                  shopByCategoryBloc.selectedFilterCategory ==
                                      "All") {
                                shopByCategoryBloc.pageNumber = 1;
                                pageNumber = 1;
                                if (productScrollController.hasClients) {
                                  productScrollController.animateTo(
                                    0,
                                    duration: Duration(
                                        seconds: 1), // Duration of the scroll
                                    curve: Curves.easeInOut, // Animation curve
                                  );
                                }
                                shopByCategoryBloc.refreshingFilter(
                                  shopByCategoryBloc.selectedSubcategory!,
                                  selectedIndex,
                                  context,
                                  list,
                                );
                              } else {
                                shopByCategoryBloc.pageNumber = 1;
                                pageNumber = 1;
                                if (productScrollController.hasClients) {
                                  productScrollController.animateTo(
                                    0,
                                    duration: Duration(
                                        seconds: 1), // Duration of the scroll
                                    curve: Curves.easeInOut, // Animation curve
                                  );
                                }
                                shopByCategoryBloc.callingApi(
                                    filterData.categoryId!, "2", context);
                              }
                            }
                            shopByCategoryBloc.selectedFilterCategory =
                                filterData.name!;
                          }
                        },
                        child: filterWidget(
                            filterData.mobileSubCatImage == null ||
                                    filterData.mobileSubCatImage == ""
                                ? Imageconstants.ondoor_logo
                                : filterData.mobileSubCatImage!,
                            filterData.name!,
                            index),
                      );
                    },
                  ),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget sortingWidget(BuildContext context, state) {
    return InkWell(
      onTap: () async {
        tabIndex = 0;
        if (list!.isNotEmpty) {
          Map<String, dynamic> data = await showModalBottomSheet(
                useSafeArea: true,
                context: context,
                builder: (context) {
                  return Container(
                    width: Sizeconfig.getWidth(context),
                    decoration: BoxDecoration(
                        color: ColorName.whiteSmokeColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: BlocBuilder(
                      bloc: shopByCategoryBloc,
                      builder: (context, state) {
                        if (state is ShopByCategoryTabChangeState) {
                          tabIndex = state.tabIndex;
                        }
                        return FilterWidget(
                          selectedSubcategoryId: selectedSubcategoryId,
                          selected_filter_list: selected_filter_list,
                        );
                      },
                    ),
                  );
                },
              ) ??
              {
                "selected_filter_list": selected_filter_list,
                "filter_group": selectedFilterGroup
              };
          selected_filter_list = data['selected_filter_list'];
          selectedFilterGroup = data['filter_group'];
          selectedFilterName = data['selected_filterName'];
          selected_filter_list = selected_filter_list.toSet().toList();
          print("SELECTED FILTER LIST ${jsonEncode(selected_filter_list)}");
          if (selected_filter_list.isNotEmpty && selectedFilterName != "Sort") {
            _applyFilters(context);
          } else {
            if (selected_filter_list.isNotEmpty) {
              shopByCategoryBloc.sortingIndex =
                  selected_filter_list[0].filterId!;
            } else {
              resetData();
              shopByCategoryBloc.add(ShopByCategoryInitialEvent());
            }
            // shopByCategoryBloc.add(FilterEvent(isFilterOn: false));
            shopByCategoryBloc.callingApi(selectedSubcategoryId, "2", context);
          }
        }
      },
      child: Container(
          margin: const EdgeInsets.only(top: 5, left: 5, bottom: 5),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: BoxDecoration(
              color: selected_filter_list.isNotEmpty
                  ? ColorName.ColorPrimary.withOpacity(.1)
                  : ColorName.ColorBagroundPrimary,
              border: Border.all(
                color: selected_filter_list.isNotEmpty
                    ? ColorName.ColorPrimary
                    : ColorName.ColorBagroundPrimary,
              ),
              borderRadius: BorderRadius.circular(5)),
          // padding: EdgeInsets.symmetric(horizontal: 5),
          child: Image.asset(
            "assets/images/sort_icons.png",
            color: ColorName.darkGrey,
            height: 20,
            width: 20,
          )),
    );
  }

  List<FilterDataParams> generateFilterDataJson() {
    Map<String, List<String>> filterDataMap = {};

    for (var filterGroup in selectedFilterGroup) {
      // Ensure filterGroup.filterGroupId is not null before using it
      String? filterGroupId = filterGroup.filterGroupId;
      if (filterGroupId == null) {
        continue; // Skip this filterGroup if its ID is null
      }

      filterDataMap[filterGroupId] = [];

      for (var filter in filterGroup.filter ?? []) {
        // Ensure filter.filterId is not null before using it
        String? filterId = filter.filterId;
        if (filterId != null && filter.isChecked) {
          filterDataMap[filterGroupId]?.add(filterId);
        } else if (filterId != null && filter.isChecked == false) {
          filterDataMap[filterGroupId]?.remove(filterId);
        } else if (filterGroup.filter!.isEmpty) {
          filterDataMap.clear();
        }
      }
    }

    List<FilterDataParams> filterDataList = filterDataMap.entries.map((entry) {
      return FilterDataParams(
        filterGroupId: entry.key,
        filter: entry.value,
      );
    }).toList();

    return filterDataList;
  }

  void _applyFilters(BuildContext context) {
    // shopByCategoryBloc.add(FilterEvent(isFilterOn: true));
    filterDataParams = generateFilterDataJson();
    if (filterDataParams.isEmpty) {
      // shopByCategoryBloc.add(FilterEvent(isFilterOn: false));
      shopByCategoryBloc.callingApi(selectedSubcategoryId, "2", context);
    } else {
      shopByCategoryBloc.getFilteredData(
        selectedSubcategoryId,
        context,
        filterDataParams,
        subCategoryList,
      );
    }
  }

  Widget commonWidgetForSortingItem(BuildContext context, String text) {
    return Container(
        width: Sizeconfig.getWidth(context) * .98,
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
            color: shopByCategoryBloc.selectedFilter == text
                ? ColorName.ColorPrimary.withOpacity(.1)
                : ColorName.ColorBagroundPrimary,
            border: Border.all(
              width: 1,
              color: shopByCategoryBloc.selectedFilter == text
                  ? ColorName.ColorPrimary
                  : ColorName.ColorBagroundPrimary,
            ),
            borderRadius: BorderRadius.circular(10)),
        child: Text(
          text,
          style: Appwidgets()
              .commonTextStyle(ColorName.black)
              .copyWith(fontWeight: FontWeight.w500),
        ));
  }

  // //view for the list correspondence with categories
  // Widget mainView(BuildContext context, dynamic state) {
  //   print("State >>>>>>>>>>>>>>>>> state " + state.toString());
  //
  //   return Container(
  //       width: double.infinity,
  //       height: double.infinity,
  //       color: ColorName.lightGreyShade,
  //       padding: const EdgeInsets.only(top: 50),
  //       child: state is ShopByCategoryErrorState
  //           ? Center(
  //               child: Text(
  //                 state.errorMessage,
  //                 style: Appwidgets().commonTextStyle(ColorName.black),
  //               ),
  //             )
  //           : unitList.isEmpty
  //               ? Shimmerui.productListUi(context)
  //               : ListView.builder(
  //                   shrinkWrap: true,
  //                   itemCount: unitList.length,
  //                   itemBuilder: (context, index) {
  //                     var selectedUnit = unitList[index];
  //
  //                     // getCartQuantity(selectedUnit.productId!).then((value){
  //                     //
  //                     //
  //                     //   print(">>>>>>> Id get "+value.toString());
  //                     //   selectedUnit.addQuantity=value;
  //                     //   shopByCategoryBloc.add(ShopbyProductChangeEvent(model: selectedUnit));
  //                     // });
  //
  //                     if (state is ShopbyProductChangeState) {
  //                       // int updateIndex =  unitList.indexWhere((value)=>value.productId==state.model.productId);
  //                       //
  //                       // print("ShopbyProductChangeState  ${updateIndex} ${state}");
  //                       //
  //                       //
  //                       // unitList[updateIndex].addQuantity=state.model.addQuantity;
  //                     }
  //
  //                     // Determine if this unit is the first occurrence of its SKU
  //                     bool isFirstOccurrence = unitList.indexWhere(
  //                             (item) => item.sku == selectedUnit.sku) ==
  //                         index;
  //
  //                     print("FeatureBlocState ${bloc.state}");
  //
  //                     if (isFirstOccurrence) {
  //                       List<ProductUnit> similarUnits = unitList
  //                           .where((item) => item.sku == selectedUnit.sku)
  //                           .toList();
  //
  //                       return categoryItemView(context, selectedUnit, state,
  //                           index, unitList, similarUnits);
  //                     } else {
  //                       // Return an empty container for subsequent occurrences of the same SKU
  //                       return SizedBox();
  //                     }
  //                   },
  //                 ));
  // }

  Widget mainView2(BuildContext context, dynamic state) {
    return state is ShopByCategoryErrorState
        ? errorWidget(state)
        : list!.isEmpty
            ? Padding(
                padding: EdgeInsets.only(top: paddingSizeforShimmerList()),
                child: Shimmerui.shopByCategoryproductListUi(context),
              )
            : BlocProvider(
                create: (context) => bloc,
                child: BlocBuilder<FeaturedBloc, FeaturedState>(
                    bloc: bloc,
                    builder: (context, state) {
                      debugPrint("Featured Product State  " + state.toString());
                      // getBottomheight();

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
                            if (list!.isNotEmpty) {
                              list![index].unit![0].addQuantity = value;
                            }
                            bloc.add(ProductUpdateQuantityInitial(list: list));
                          });

                          if (newmodel!.cOfferId != 0 &&
                              newmodel.cOfferId != null) {
                            debugPrint("***********************");
                            if (newmodel.subProduct != null) {
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

                      if (state is ShopByFilterdState) {
                        //list!.clear();
                        list = state.filterdlist;
                        searchController.text = searchController.text;

                        //bloc.add(ProductForShopByEvent(list: list));
                      }
                      return Column(
                        children: [
                          Container(
                              padding: EdgeInsets.only(
                                  top: selected_filter_list.isNotEmpty &&
                                          isSortingFilter == false
                                      ? isLargeScreen
                                          ? screenHeight * .085
                                          : screenHeight * .1
                                      : isLargeScreen
                                          ? screenHeight * .045
                                          : screenHeight * .05),
                              height: Sizeconfig.getHeight(context),
                              color: ColorName.aquaHazeColor,
                              // padding: const EdgeInsets.only(top: 10),
                              child: ListView.builder(
                                shrinkWrap: true,
                                controller: productScrollController,
                                itemCount: list!.length,
                                itemBuilder: (context, index) {
                                  var dummyData = list![index].unit![0];
                                  if (dummyData.productId == "1691") {}
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
                                              state.model.addQuantity
                                                  .toString());

                                          debugPrint("G>>>>>>Index    " +
                                              isMoreUnitIndex.toString());
                                        }
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

                                  print(
                                      "Index ${index} listLength ${list!.length}");
                                  print("Index ${index == list!.length - 1}");
                                  return categoryItemView2(context, dummyData,
                                      null, index, isMoreunit);
                                },
                              )),
                          10.toSpace
                        ],
                      );
                    }),
              );
  }

  Widget errorWidget(ShopByCategoryErrorState state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 105),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          // alignment: Alignment.center,
          // fit: StackFit.loose,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              Imageconstants.newnorecord,
              fit: BoxFit.fill,
              width: Sizeconfig.getWidth(context) * .55,
              height: Sizeconfig.getWidth(context) * .45,
            ),
            20.toSpace,
            Text(
              state.errorMessage,
              textAlign: TextAlign.center,
              style: Appwidgets()
                  .commonTextStyle(ColorName.ColorPrimary)
                  .copyWith(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  double paddingSizeforShimmerList() {
    print("Screen HEight $screenHeight");
    if (isLargeScreen) {
      screenHeight = selected_filter_list.isNotEmpty && isSortingFilter == false
          ? screenHeight * 0.07
          : screenHeight * 0.03;
    } else {
      screenHeight = selected_filter_list.isNotEmpty && isSortingFilter == false
          ? screenHeight * 0.09
          : screenHeight * 0.04;
    }
    return screenHeight;
  }

  getBottomheight() {
    final RenderBox renderBox =
        _bottomNavigationKey.currentContext?.findRenderObject() as RenderBox;
    final double height = renderBox.size.height;
    bottomviewheight = height;
    print('Bottom Navigation Bar Height: $height');
  }

  navigatetoProductDetailScreen(
      {required int index,
      required bool isMoreUnit,
      required ProductUnit model}) {
    for (int i = 0; i < list![index].unit!.length!; i++) {
      debugPrint("Model  ${model.productId} ${model.addQuantity} ");
      if (model.productId == list![index].unit![i].productId!) {
        list![index].unit![i] = model;
        isMoreUnitIndex = i;
      }
      debugPrint(
          "DATA Model  ${list![index].unit![i].productId!}  ${list![index].unit![i].addQuantity!}");
    }
    shopByCategoryBloc.routetoProductDetail = true;
    functiontoCloseDropDown(eventtoperform: () {
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
        shopByCategoryBloc.add(ShopByCategoryInitialEvent());
        //
        // initializedDb();

        // shopByCategoryBloc.refreshingFilter(
        //     selectedSubcategory!, selectedIndex, context,list);
        // ProductUnit unit = value as ProductUnit;
        // bloc.add(ProductUpdateQuantityEvent(
        //     quanitity: unit.addQuantity!, index: index));
      });
    });
  }

  Widget categoryItemView2(BuildContext context, ProductUnit model,
      dynamic state, int index, bool isMoreUnit) {
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
            functiontoCloseDropDown(eventtoperform: () {
              navigatetoProductDetailScreen(
                  index: index, isMoreUnit: isMoreUnit, model: model);
            });
          },
          child: Column(
            children: [
              IntrinsicHeight(
                child: Stack(
                  children: [
                    Container(
                      key: Key(model.productId!),
                      // height: isMoreUnit
                      //     ? Sizeconfig.getHeight(context) * 0.16
                      //
                      //     : Sizeconfig.getHeight(context) * 0.15,
                      margin: (model.cOfferId != 0 &&
                              model.cOfferId != null &&
                              model.subProduct != null &&
                              (showWarningMessage != false ||
                                  offerAppilied != false))
                          ? EdgeInsets.only(left: 5, right: 5, top: 5)
                          : EdgeInsets.symmetric(horizontal: 5.0, vertical: 2),
                      padding:
                          EdgeInsets.only(top: 6, bottom: 8, left: 5, right: 6),
                      decoration: BoxDecoration(
                        color: ColorName.ColorBagroundPrimary,
                        borderRadius: (model.cOfferId != 0 &&
                                model.cOfferId != null &&
                                model.subProduct != null &&
                                (showWarningMessage != false ||
                                    offerAppilied != false))
                            ? BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8))
                            : BorderRadius.circular(8),
                        // border: Border.all(color: ColorName.lightGey),
                      ),
                      // margin:  EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                      child: Padding(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 4,
                                  /*        child: Image.network(
                                    model.image ?? "",
                                    repeat: ImageRepeat.repeat,
                                    filterQuality: FilterQuality.high,
                                    gaplessPlayback: true,
                                    errorBuilder: (context, error,
                                            stackTrace) =>
                                        Image.asset(Imageconstants.ondoor_logo),
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      int expectedBytes = 0;
                                      int loadedBytes = 0;
                                      if (loadingProgress != null) {
                                        expectedBytes = loadingProgress
                                                .expectedTotalBytes ??
                                            0;
                                        loadedBytes = loadingProgress
                                            .cumulativeBytesLoaded;
                                      }

                                      return loadingProgress != null ||
                                              expectedBytes != loadedBytes
                                          ? Shimmerui
                                              .shimmerForProductImageWidget(
                                                  context)
                                          : child;
                                    },
                                  ),*/
                                  child: CachedNetworkImage(
                                    // height: Sizeconfig.getHeight(context) * .11,
                                    // width: Sizeconfig.getWidth(context) * .5,
                                    imageUrl: model.image ?? "",
                                    placeholder: (context, url) =>
                                        Shimmerui.shimmerForProductImageWidget(
                                            context: context,
                                            height:
                                                Sizeconfig.getHeight(context) *
                                                    .11,
                                            width:
                                                Sizeconfig.getWidth(context) *
                                                    .5),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(Imageconstants.ondoor_logo),
                                  ),
                                  // child: CommonCachedImageWidget(
                                  //   imgUrl: model.image!,
                                  // ),
                                ),
                                Expanded(
                                  flex: 8,
                                  child: Container(
                                    padding: EdgeInsets.only(left: 6),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: Sizeconfig.getHeight(
                                                      context) *
                                                  .06,
                                              width: (model!.cOfferId != 0 &&
                                                      model.cOfferId != null)
                                                  ? Sizeconfig.getWidth(
                                                          context) *
                                                      0.42
                                                  : Sizeconfig.getWidth(
                                                          context) *
                                                      0.46,
                                              child:
                                                  // Text(
                                                  //   model.name!,
                                                  //   maxLines: 2,
                                                  //   style: TextStyle(
                                                  //     fontSize: 12,
                                                  //     fontFamily: Fontconstants
                                                  //         .fc_family_sf,
                                                  //     fontWeight: Fontconstants
                                                  //         .SF_Pro_Display_SEMIBOLD,
                                                  //     color: Colors.black,
                                                  //   ),

                                                  CommanTextWidget.regularBold(
                                                model.name!,
                                                Colors.black,
                                                maxline: 2,
                                                trt: TextStyle(
                                                  fontSize: 13,
                                                  height: 1.215,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                textalign: TextAlign.start,
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
                                                          .img_gifoffer2,
                                                      height: 20,
                                                      width: 20,
                                                    ))
                                                : Container()
                                          ],
                                        ),
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  /*   InkWell(
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


                                                      padding:
                                                           EdgeInsets.only(top: 5),
                                                      width:
                                                      Sizeconfig.getWidth(context) *
                                                          .20,
                                                      child: Align(
                                                        alignment: Alignment.center,
                                                        child: Row(
                                                          // mainAxisAlignment:
                                                          //     MainAxisAlignment
                                                          //         .spaceBetween,
                                                          children: [
                                                            Text(
                                                              model.productWeight
                                                                  .toString() +
                                                                  " ${model.productWeightUnit}",
                                                              overflow:
                                                              TextOverflow.ellipsis,
                                                              maxLines: 1,
                                                              style: TextStyle(
                                                                fontSize:
                                                                Constants.SizeSmall,
                                                                fontFamily: Fontconstants
                                                                    .fc_family_sf,
                                                                fontWeight: Fontconstants
                                                                    .SF_Pro_Display_Bold,
                                                                color:ColorName.textsecondary,
                                                              ),
                                                            ),
                                                            5.toSpace,
                                                            Visibility(
                                                                visible: isMoreUnit,
                                                                child: Container(
                                                                  width: 10,
                                                                  height: 10,
                                                                  child: Image.asset(
                                                                    Imageconstants
                                                                        .img_dropdownarrow,
                                                                    color:ColorName.textsecondary,
                                                                  ),
                                                                ))
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),*/
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                            top: 10),
                                                        child: InkWell(
                                                          onTap: () {
                                                            if (isMoreUnit) {
                                                              MyDialogs.optionDialog(
                                                                      context,
                                                                      list![index]
                                                                          .unit!,
                                                                      model)
                                                                  .then(
                                                                      (value) {
                                                                isMoreUnitIndex = list![
                                                                        index]
                                                                    .unit!
                                                                    .indexWhere(
                                                                        (model) =>
                                                                            model ==
                                                                            value);
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
                                                                          .unit![
                                                                              i]
                                                                          .productId ==
                                                                      value
                                                                          .productId) {
                                                                    list![index]
                                                                        .unit![
                                                                            i]
                                                                        .isselectUnit = true;
                                                                    value.isselectUnit =
                                                                        true;
                                                                  } else {
                                                                    list![index]
                                                                        .unit![
                                                                            i]
                                                                        .isselectUnit = false;
                                                                  }
                                                                }

                                                                bloc.add(
                                                                    ProductChangeEvent(
                                                                        model:
                                                                            value));
                                                              });
                                                            }
                                                          },
                                                          child: isMoreUnit
                                                              ? Container(
                                                                  height: 20,
                                                                  width: Sizeconfig
                                                                          .getWidth(
                                                                              context) *
                                                                      0.22,
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.all(Radius.circular(
                                                                              4.0)),
                                                                      border: Border.all(
                                                                          width:
                                                                              0.6,
                                                                          color: ColorName
                                                                              .border
                                                                              .withOpacity(0.5))),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      2.toSpace,
                                                                      Container(
                                                                          padding: EdgeInsets.symmetric(
                                                                              horizontal:
                                                                                  0),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                CommanTextWidget.regularBold(
                                                                              model.productWeight.toString() + " ${model.productWeightUnit}",
                                                                              ColorName.textsecondary,
                                                                              maxline: 2,
                                                                              trt: TextStyle(
                                                                                fontSize: 11,
                                                                                fontWeight: FontWeight.w600,
                                                                              ),
                                                                              textalign: TextAlign.start,
                                                                            ),
                                                                          )),
                                                                      5.toSpace,
                                                                      Visibility(
                                                                          visible:
                                                                              isMoreUnit,
                                                                          child:
                                                                              Container(
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: ColorName.ColorPrimary,
                                                                              borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                                                            ),
                                                                            width:
                                                                                20,
                                                                            height:
                                                                                20,
                                                                            padding:
                                                                                EdgeInsets.all(5),
                                                                            child:
                                                                                Image.asset(
                                                                              Imageconstants.img_dropdownarrow,
                                                                              color: Colors.white,
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
                                                                  ColorName
                                                                      .textsecondary,
                                                                  maxline: 2,
                                                                  trt:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        11,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                  textalign:
                                                                      TextAlign
                                                                          .start,
                                                                ),
                                                        ),
                                                      ),
                                                      Container()
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  model.specialPrice == ""
                                                      ? SizedBox.shrink()
                                                      : Container(
                                                          child:
                                                              CommanTextWidget
                                                                  .regularBold(
                                                            model.specialPrice ==
                                                                    ""
                                                                ? ""
                                                                : "₹${double.parse(model.price!).toStringAsFixed(2)}",
                                                            ColorName.black,
                                                            maxline: 1,
                                                            trt: TextStyle(
                                                              fontSize: 10,
                                                              decoration:
                                                                  TextDecoration
                                                                      .lineThrough,
                                                              decorationColor:
                                                                  ColorName
                                                                      .black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                            textalign:
                                                                TextAlign.start,
                                                          ),
                                                        ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 0,
                                                            child:
                                                                CommanTextWidget
                                                                    .regularBold(
                                                              model.specialPrice ==
                                                                      ""
                                                                  ? "₹ ${double.parse(model.sortPrice!).toStringAsFixed(2)}"
                                                                  : "₹ ${double.parse(model.specialPrice!).toStringAsFixed(2)}",
                                                              Colors.black,
                                                              maxline: 2,
                                                              trt: TextStyle(
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                              textalign:
                                                                  TextAlign
                                                                      .start,
                                                            ),

                                                            /*   Text(
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
                                                              )*/
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                  width: Sizeconfig.getWidth(
                                                          context) *
                                                      0.21,
                                                  height: Sizeconfig.getWidth(
                                                          context) *
                                                      0.08,
                                                  child: model.addQuantity != 0
                                                      ? Container(
                                                          alignment: Alignment
                                                              .bottomRight,
                                                          child: Appwidgets
                                                              .AddQuantityButton(
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
                                                              Fluttertoast.showToast(
                                                                  msg: StringContants
                                                                      .msg_quanitiy);
                                                            } else {
                                                              print("21NovGG");
                                                              model.addQuantity =
                                                                  model.addQuantity +
                                                                      1;
                                                              bloc.add(ProductUpdateQuantityEvent(
                                                                  quanitity: model
                                                                      .addQuantity!,
                                                                  index:
                                                                      index));
                                                              bloc.add(
                                                                  ProductChangeEvent(
                                                                      model:
                                                                          model));
                                                              updateCard(model);
                                                              debugPrint(
                                                                  "Scroll Event1111 ");
                                                            }
                                                          }, () async {
                                                            if (model
                                                                    .addQuantity ==
                                                                1) {
                                                              debugPrint(
                                                                  "SHOPBY 1");
                                                              model.addQuantity =
                                                                  0;

                                                              bloc.add(
                                                                  ProductUpdateQuantityEventBYModel(
                                                                      model:
                                                                          model));
                                                              shopByCategoryBloc
                                                                  .add(
                                                                      ShopByNullEvent());
                                                              shopByCategoryBloc.add(
                                                                  ShopbyProductChangeEvent(
                                                                      model:
                                                                          model));
                                                              await dbHelper
                                                                  .deleteCard(int
                                                                      .parse(model
                                                                          .productId!))
                                                                  .then(
                                                                      (value) {
                                                                debugPrint(
                                                                    "Delete Product $value ");

                                                                // cardBloc.add(CardDeleteEvent(
                                                                //     model: model,
                                                                //     listProduct:  list![0].unit!));

                                                                dbHelper
                                                                    .loadAddCardProducts(
                                                                        cardBloc);
                                                              });
                                                            } else if (model
                                                                    .addQuantity !=
                                                                0) {
                                                              debugPrint(
                                                                  "SHOPBY 2");
                                                              model.addQuantity =
                                                                  model.addQuantity -
                                                                      1;

                                                              updateCard(model);
                                                              bloc.add(
                                                                  ProductUpdateQuantityEventBYModel(
                                                                      model:
                                                                          model));
                                                              shopByCategoryBloc
                                                                  .add(
                                                                      ShopByNullEvent());
                                                              bloc.add(
                                                                  ProductChangeEvent(
                                                                      model:
                                                                          model));
                                                              shopByCategoryBloc
                                                                  .add(
                                                                      ShopByNullEvent());
                                                              shopByCategoryBloc.add(
                                                                  ShopbyProductChangeEvent(
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
                                                            debugPrint("GGGGGGG " +
                                                                cardItesmList
                                                                    .length
                                                                    .toString());

                                                            model.addQuantity =
                                                                model.addQuantity +
                                                                    1;
                                                            checkItemId(model
                                                                    .productId!)
                                                                .then((value) {
                                                              debugPrint(
                                                                  "CheckItemId $value");

                                                              if (value ==
                                                                  false) {
                                                                print("26NovA");
                                                                addCard(model);
                                                              } else {
                                                                print("26NovB");
                                                                updateCard(
                                                                    model);
                                                              }
                                                            });

                                                            bloc.add(ProductUpdateQuantityEvent(
                                                                quanitity: model
                                                                    .addQuantity!,
                                                                index: index));
                                                            bloc.add(
                                                                ProductChangeEvent(
                                                                    model:
                                                                        model));
                                                          },
                                                        ))
                                            ],
                                          ),
                                        )
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
                            visible: (model.discountText != "" ||
                                model.discountText != null),
                            child: Positioned(
                              // left: 7,
                              left: 4,
                              top: 2,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10)),
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: Text(
                                        model.discountText ?? "",
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
                    /* RRRRRRRRR   Positioned(
                      right: 10,
                      bottom: 15,
                      child: Container(
                          width: Sizeconfig.getWidth(context) * 0.21,
                          height: Sizeconfig.getWidth(context) * 0.08,
                          child: model.addQuantity != 0
                              ? Container(
                                  alignment: Alignment.bottomRight,
                                  child: Appwidgets.AddQuantityButton(
                                      StringContants.lbl_add,
                                      model.addQuantity! as int, () {
                                    //increase

                                    if (model.addQuantity ==
                                        int.parse(model.quantity!)) {
                                      Fluttertoast.showToast(
                                          msg: StringContants.msg_quanitiy);
                                    } else {
                                      model.addQuantity = model.addQuantity + 1;
                                      bloc.add(ProductUpdateQuantityEvent(
                                          quanitity: model.addQuantity!,
                                          index: index));
                                      bloc.add(
                                          ProductChangeEvent(model: model));
                                      updateCard(model);
                                      debugPrint("Scroll Event1111 ");
                                    }
                                  }, () async {
                                    if (model.addQuantity == 1) {
                                      debugPrint("SHOPBY 1");
                                      model.addQuantity = 0;

                                      bloc.add(
                                          ProductUpdateQuantityEventBYModel(
                                              model: model));
                                      shopByCategoryBloc.add(ShopByNullEvent());
                                      shopByCategoryBloc.add(
                                          ShopbyProductChangeEvent(
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

                                      updateCard(model);
                                      bloc.add(
                                          ProductUpdateQuantityEventBYModel(
                                              model: model));
                                      shopByCategoryBloc.add(ShopByNullEvent());
                                      bloc.add(
                                          ProductChangeEvent(model: model));
                                      shopByCategoryBloc.add(ShopByNullEvent());
                                      shopByCategoryBloc.add(
                                          ShopbyProductChangeEvent(
                                              model: model));
                                    }
                                  }),
                                )
                              : Appwidgets().buttonPrimary(
                                  StringContants.lbl_add,
                                  () {
                                    debugPrint("GGGGGGG " +
                                        cardItesmList.length.toString());

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
                                        quanitity: model.addQuantity!,
                                        index: index));
                                    bloc.add(ProductChangeEvent(model: model));
                                  },
                                )),
                    )*/
                  ],
                ),
              ),
              (model.cOfferId != 0 &&
                      model.cOfferId != null &&
                      model.subProduct != null &&
                      (showWarningMessage != false || offerAppilied != false))
                  ? Container(
                      width: Sizeconfig.getWidth(context),
                      margin: EdgeInsets.only(right: 5, left: 5, bottom: 5),
                      padding: EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: showWarningMessage
                            ? Colors.red.shade400
                            : Colors.green,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(5),
                            bottomRight: Radius.circular(5)),
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
                                          height: 15,
                                          width: 15,
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
                  : const SizedBox.shrink(),
            ],
          ),
        ),
        // productScrollController.position
        //                 .userScrollDirection ==
        //             ScrollDirection.reverse &&
        //         productScrollController
        //             .position.atEdge
        //     ?
        //     : SizedBox.shrink()

        index == list!.length - 1 &&
                // productScrollController != null &&
                // productScrollController.position != null &&
                // productScrollController.position.atEdge &&
                shopByCategoryBloc.isPaginationLoading &&
                shopByCategoryBloc.pageNumber != 1
            ? Padding(
                padding: const EdgeInsets.all(5),
                child: const CircularProgressIndicator(
                  color: ColorName.ColorPrimary,
                ),
              )
            : const SizedBox.shrink(),
        SizedBox(
          height: spacingWidgetForList(list!.length - 1, index),
        )
        // index == list!.length - 1
        //     ? _height == 50.0
        //         ? SizedBox(
        //             height: Sizeconfig.getHeight(context) * .11,
        //           )
        //         : SizedBox(
        //             height: Sizeconfig.getHeight(context) * .22,
        //           )
        //     : const SizedBox.shrink(),
      ],
    );
  }

  addtoCart(ProductUnit unit, int index, state) {
    // int quantityIndex = 0;
    //
    // if (state is WeightChangeState) {
    //   if (index == state.selectedIndex) {
    //     quantityIndex = state.selectedIndex;
    //   } else {
    //     quantityIndex = shopByCategoryBloc.quantityIndex;
    //   }
    // }
    // else if (state is ShopByCategoryLoadedState) {
    //   quantityIndex = index;
    // }
    // else if (state is ShopbyProductUpdateQuantityState) {
    //   if (index == state.index) {
    //     quantityIndex = state.index;
    //   }
    //   else {
    //     quantityIndex = index;
    //   }
    // }

    // Increment the quantity of the selected unit
    unitList[index].addQuantity += 1;

    // Check if the item exists in the cart and update accordingly
    checkItemId(unit.productId!).then((value) {
      if (value == false) {
        addCard(unit); // Function to add item to cart if not already present
      } else {
        updateCard(unit); // Function to update item in cart if already present
      }
    });

    // Notify the Bloc about the quantity update
    shopByCategoryBloc.add(ShopbyProductUpdateQuantityEvent(
      model: selectedUnit, // Assuming selectedUnit is correctly set elsewhere
      unitList: unitList,
      index: index,
    ));
  }

  removeFromCart(ProductUnit unit, int index, state) async {
    shopByCategoryBloc.add(ShopByNullEvent());
    int quantityIndex = 0;

    if (state is WeightChangeState) {
      if (index == state.selectedIndex) {
        quantityIndex = state.selectedIndex;
      } else {
        quantityIndex = index;
      }
    } else if (state is ShopByCategoryLoadedState) {
      quantityIndex = index;
    } else if (state is ShopbyProductUpdateQuantityState) {
      if (index == state.index) {
        quantityIndex = state.index;
      } else {
        quantityIndex = index;
      }
    }
    if (unit.addQuantity != 0) {
      unit.addQuantity = unit.addQuantity - 1;

      shopByCategoryBloc.add(ShopbyProductUpdateQuantityEvent(
          model: unit, unitList: unitList, index: quantityIndex));

      updateCard(unit);
    }

    if (unit.addQuantity == 0) {
      await dbHelper.deleteCard(int.parse(unit.productId!)).then((value) {
        debugPrint("Delete Product $value ");

        dbHelper.loadAddCardProducts(cardBloc);
        shopByCategoryBloc.add(ShopbyProductUpdateQuantityEvent(
            model: unit, unitList: unitList, index: quantityIndex));

        updateCard(unit);
      });
    }
  }

  double spacingWidgetForList(int listLength, int index) {
    double screenHeight = Sizeconfig.getHeight(context) + 20;
    bool isLargeScreen = screenHeight > 800;
    bool isEmptyState = cardBloc.state is CardEmptyState;

    // If the index is not the last item, return 0.
    if (index != listLength) {
      return 0;
    }

    double heightFactor;

    if (_height == 50.0) {
      // Handle cases where height is 50.0
      if (isEmptyState) {
        heightFactor = isLargeScreen ? 0.06 : 0.09;
      } else {
        heightFactor = isLargeScreen ? 0.14 : 0.18;
      }
    } else if (_height == 0.0) {
      // Handle cases where height is 0.0
      if (!isEmptyState) {
        heightFactor = isLargeScreen ? 0.18 : 0.24;
      } else {
        heightFactor = isLargeScreen ? 0.12 : 0.15;
      }
    } else {
      heightFactor = isLargeScreen ? 0.12 : 0.15;
    }

    return screenHeight * heightFactor;
  }

  Widget navigationItemWidget(
      state,
      currentNavigationIndex,
      SubCategory shopByCategoryData,
      BuildContext context,
      List<ProductData>? list) {
    // Default image size
    double defaultSize = 30;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (navigationSelectionChecker(currentNavigationIndex))
          Appwidgets.navigationIndicator(context),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                fit: StackFit.loose,
                alignment: Alignment.center,
                children: [
                  navigationSelectionChecker(currentNavigationIndex)
                      ? navigationBgWidget(context)
                      : navigationBgWidgetdefault(context),
                  BlocBuilder(
                    bloc: animationBloc,
                    builder: (context, state) {
                      // Use a default size if the state does not provide a new size
                      double imageSize = defaultSize;

                      if (state is AnimationcategoryImageState &&
                          navigationSelectionChecker(currentNavigationIndex)) {
                        imageSize = state.size;
                      }
                      print("HEIGHT ${Sizeconfig.getHeight(context)}");
                      double thirtySize = Sizeconfig.getWidth(context) * .085;
                      double fortySize = Sizeconfig.getWidth(context) * .11;
                      print("WIDTH ${fortySize}");
                      return Positioned(
                          bottom:
                              navigationSelectionChecker(currentNavigationIndex)
                                  ? 10
                                  : 2,
                          child: navigationSelectionChecker(
                                  currentNavigationIndex)
                              ? shopByCategoryData.name == "All"
                                  ? Image.asset(
                                      Imageconstants.all_products,
                                      height: fortySize,
                                      width: fortySize,
                                    )
                                  : Image.network(
                                      height: fortySize,
                                      width: fortySize,
                                      fit: BoxFit.fill,
                                      repeat: ImageRepeat.repeat,
                                      filterQuality: FilterQuality.high,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Image.asset(
                                        Imageconstants.ondoor_logo,
                                        height: 40,
                                        width: 40,
                                      ),
                                      shopByCategoryData.mobileSubCatImage ??
                                          Imageconstants.ondoor_logo,
                                    )
                              : shopByCategoryData.name == "All"
                                  ? Image.asset(
                                      Imageconstants.all_products,
                                      height: 40,
                                      width: 40,
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          bottomRight:
                                              const Radius.circular(9.0),
                                          bottomLeft:
                                              const Radius.circular(9.0)),
                                      child: shopByCategoryData
                                              .mobileSubCatImage!.isEmpty
                                          ? Image.asset(
                                              Imageconstants.ondoor_logo,
                                              height: thirtySize,
                                              width: thirtySize,
                                            )
                                          : Image.network(
                                              shopByCategoryData
                                                      .mobileSubCatImage ??
                                                  "",
                                              height: thirtySize,
                                              width: thirtySize,
                                              fit: BoxFit.fill,
                                              repeat: ImageRepeat.repeat,
                                              filterQuality: FilterQuality.high,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Image.asset(
                                                Imageconstants.ondoor_logo,
                                                height: 40,
                                                width: 40,
                                              ),
                                            ),
                                    ));
                    },
                  ),
                ],
              ),
              navigationSelectionChecker(currentNavigationIndex)
                  ? SizedBox.shrink()
                  : 5.toSpace,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Center(
                  child: Text(
                    shopByCategoryData.name!,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    style: Appwidgets()
                        .commonTextStyle(
                          navigationSelectionChecker(currentNavigationIndex)
                              ? ColorName.ColorPrimary
                              : ColorName.darkGrey,
                        )
                        .copyWith(
                          fontSize: 12,
                          fontFamily: Fontconstants.fc_family_proxima,
                          fontWeight:
                              navigationSelectionChecker(currentNavigationIndex)
                                  ? Fontconstants.SF_Pro_Display_Bold
                                  : Fontconstants.Poppins_SemiBold,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget navigationImageWidget(
      {required double height,
      required double width,
      required String imageUrl}) {
    return CachedNetworkImage(
      height: height,
      width: width,
      imageUrl: imageUrl,
      useOldImageOnUrlChange: true,
      filterQuality: FilterQuality.high,
      errorWidget: (context, url, error) =>
          Image.asset(Imageconstants.ondoor_logo),
      placeholder: (context, url) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: CupertinoActivityIndicator(),
        ),
      ),
      fit: BoxFit.fill,
    );
  }

  // this function will check which index is selected
  bool navigationSelectionChecker(currentNavigationIndex) {
    int index = categoryList.indexWhere(
      (element) {
        return element == shopByCategoryBloc.selectedSubcategory!;
      },
    );
    if (index > 0) {
      shopByCategoryBloc.currentIndex = index;
    }
    return shopByCategoryBloc.currentIndex == currentNavigationIndex
        ? true
        : false;
  }

  // widget for red and white gradient background in subcategory list
  Widget navigationBgWidget(context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 60,
        height: 60,
        // width: Sizeconfig.getWidth(context) * .14,
        // height: Sizeconfig.getHeight(context) * .067,
        //  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        padding: const EdgeInsets.only(left: 15, right: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [ColorName.geraldine, ColorName.ColorBagroundPrimary]),
        ),
      ),
    );
  }

  Widget navigationBgWidgetdefault(context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 50,
        height: 50,
        // width: Sizeconfig.getWidth(context) * .14,
        // height: Sizeconfig.getHeight(context) * .067,
        //  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        padding: const EdgeInsets.only(left: 15, right: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: ColorName.whiteSmokeColor,
        ),
      ),
    );
  }

  Widget filterWidget(var image, var filterTitle, int index) {
    bool filterSelected =
        shopByCategoryBloc.selectedFilterCategory == filterTitle;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      margin: EdgeInsets.only(
          left: index == 0 ? 0 : 5,
          top: 5,
          bottom: 5,
          right: subCategoryList.length - 1 == index ? 5 : 0),
      // padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: filterSelected
              ? ColorName.ColorPrimary.withOpacity(.1)
              : ColorName.ColorBagroundPrimary,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
              width: .7,
              color: filterSelected
                  ? ColorName.ColorPrimary
                  : ColorName.ColorBagroundPrimary)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 5.toSpace,
          filterTitle == "All"
              ? Image.asset(
                  Imageconstants.all_products,
                  height: 20,
                  width: 20,
                )
              : image == Imageconstants.ondoor_logo
                  ? Image.asset(
                      // assetImage
                      image,
                      height: 20,
                      width: 20,
                    )
                  : Image.network(
                      // NetworkImage
                      image,
                      height: 20,
                      width: 20,
                      repeat: ImageRepeat.repeat,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        Imageconstants.ondoor_logo,
                        height: 20,
                        width: 20,
                      ),
                    ),
          5.toSpace,
          Text(
            filterTitle,
            style: Appwidgets()
                .commonTextStyle(
                    shopByCategoryBloc.selectedFilterCategory == filterTitle
                        ? ColorName.black
                        : ColorName.darkGrey)
                .copyWith(
                    fontSize: 15,
                    fontFamily: Fontconstants.fc_family_sf,
                    fontWeight: Fontconstants.SF_Pro_Display_Medium),
          ),
          // 5.toSpace,
          // filterTitle == "Sort"
          //     ? const Icon(
          //         Icons.arrow_drop_down,
          //         color: Colors.black,
          //       )
          //     : const SizedBox()
        ],
      ),
    );
  }

  googleSpeechDialog() async {
    bool isServiceAvailable =
        await SpeechToTextGoogleDialog.getInstance().showGoogleDialog(
      onTextReceived: (data) async {
        searchController.text = data;
        searchProduct(data);
      },
      // locale: "en-US",
    );
  }

  List<ProductData> searchProduct(String result) {
    List<ProductData> listfilterd = [];

    debugPrint("searchProduct 1 ${result}");
    debugPrint("searchProduct 2 ${listTemp!.length.toString()}");
    for (var x in listTemp!) {
      if (x.unit![0].name!.toLowerCase().contains(result.toLowerCase())) {
        listfilterd.add(x);
        debugPrint("FilterdList Data ${x.unit![0].name!} ${subCategoryList!} ");
      }
    }

    if (result == "") {
      shopByCategoryBloc.add(ShopByNullEvent());

      bloc.add(ShopByFilterdEvent(filterdlist: listTemp!));
    }

    if (listfilterd.length == 0) {
      shopByCategoryBloc.add(ShopByNullEvent());
      shopByCategoryBloc
          .add(ShopByCategoryErrorEvent(StringContants.lbl_no_products_found));
    } else {
      shopByCategoryBloc.add(ShopByNullEvent());

      bloc.add(ShopByFilterdEvent(filterdlist: listfilterd));
    }

    OndoorThemeData.keyBordDow();

    return listfilterd;
  }
}
