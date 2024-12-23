import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ondoor/constants/Constant.dart';
import 'package:ondoor/constants/ImageConstants.dart';
import 'package:ondoor/models/AllProducts.dart';
import 'package:ondoor/screens/NewAnimation/animation_bloc.dart';
import 'package:ondoor/screens/NewAnimation/animation_event.dart';
import 'package:ondoor/screens/product_detail/product_detail_bloc/product_detail_bloc.dart';
import 'package:ondoor/screens/product_detail/product_detail_bloc/product_detail_event.dart';
import 'package:ondoor/screens/product_detail/product_detail_bloc/product_detail_state.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/SizeConfig.dart';
import 'package:ondoor/widgets/HomeWidgetConst.dart';
import 'package:ondoor/widgets/common_cached_image_widget.dart';
import 'package:ondoor/widgets/common_loading_widget.dart';
import '../../constants/FontConstants.dart';
import '../../constants/StringConstats.dart';
import '../../database/database_helper.dart';
import '../../database/dbconstants.dart';
import '../../models/shop_by_category_response.dart';
import '../../services/ApiServices.dart';
import '../../services/Navigation/routes.dart';
import '../../utils/Utility.dart';
import '../../utils/colors.dart';
import '../../utils/sharedpref.dart';
import '../../widgets/AppWidgets.dart';
import '../../widgets/CheckoutWidgets.dart';
import '../../widgets/ProductValidationsWidgets.dart';
import '../AddCard/card_bloc.dart';
import '../AddCard/card_event.dart';
import '../AddCard/card_state.dart';
import '../FeaturedProduct/FeatuuredBloc/featured_bloc.dart';
import '../FeaturedProduct/FeatuuredBloc/featured_event.dart';
import '../FeaturedProduct/FeatuuredBloc/featured_state.dart';
import '../NewAnimation/animation_state.dart';

class ProductDetailScreen extends StatefulWidget {
  List<ProductUnit> listproduct;
  int selectedIndex;
  bool fromchekcout;
  ProductDetailScreen(
      {super.key,
      required this.listproduct,
      required this.selectedIndex,
      required this.fromchekcout});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductDetailBloc productDetailBloc = ProductDetailBloc();
  ProductUnit? dummyData;
  final dbHelper = DatabaseHelper();
  CardBloc cardBloc = CardBloc();
  int count = 0;
  int imageIndex = 0;
  int current_index = 0;
  bool isRefresh = false;
  bool viewMore = false;
  double offerimageSize = 0.0;
  double scrollOffset = 0.0;
  double mainscrollOffset = 0.0;
  double screenHeight = 0.0;
  double maxScrollExtent = 0.0;
  double opacity = 0.0;
  double angle = 0.0;
  AnimationBloc animationBloc = AnimationBloc();
  List<ProductUnit> cartItems = [];
  int isMoreUnitIndex = 0;
  List<ProductData> listSimilarProducts = [];
  FeaturedBloc featuredBloc = FeaturedBloc();
  int pagenolist1 = 1;
  bool LoadMore = true;
  bool _isLoading = false;
  ScrollController _scrollController = ScrollController();
  ScrollController _mainPagescrollController = ScrollController();
  void _scrollListener() {
    Appwidgets.setStatusBarColorWhite();
    if (_scrollController.offset.toInt() ==
            _scrollController.position.maxScrollExtent.toInt() &&
        !_isLoading) {
      // if (loadmore == true) {
      //   cheflist(pageNo, "", "", "", "", "", searchController.text);
      // }

      debugPrint("_scrollListener call ");

      getSimilarProducts(true);
    }
  }

  @override
  void initState() {
    Appwidgets.setStatusBarColorWhite();
    productDetailBloc.add(UpdateIndexEvent(index: widget.selectedIndex));
    initializedDb();

    super.initState();
  }

  initializedDb() async {
    debugPrint("ProductDetails Card Initiliaze");

    cardBloc = CardBloc();
    await dbHelper.init();

    dbHelper.loadAddCardProducts(cardBloc);

    getSimilarProducts(false);

    _scrollController.addListener(_scrollListener);

    await Future.delayed(Duration(seconds: 1), () {
      Appwidgets.setStatusBarColorWhite();
    });
  }

  getSimilarProducts(bool loadmore) {
    // ApiProvider().getSimilarProducts("").th;

    if (loadmore) {
      pagenolist1++;
    }
    _isLoading = true;
    debugPrint("getSimilarProducts api call $pagenolist1");

    ApiProvider()
        .getSimilarProducts(
            widget.listproduct[widget.selectedIndex].productId!, pagenolist1)
        .then((value) async {
      final responseData = jsonDecode(value.toString());

      if (responseData["success"]) {
        debugPrint("Search Product Listing " + value);
        ProductsModel productsModel = ProductsModel.fromJson(value.toString());

        debugPrint(
            "Search Product Listing " + productsModel.data!.length.toString());

        if (loadmore) {
          listSimilarProducts.addAll(productsModel.data!);
        } else {
          listSimilarProducts = productsModel.data!;
        }
        featuredBloc.add(LoadedFeaturedEvent(list: listSimilarProducts));
        _isLoading = false;
      } else {
        loadmore = false;
        LoadMore = false;
        featuredBloc.add(ProductListEmptyEvent());
        featuredBloc.add(ProductLoadMoreEvent(index: 0, loadmore: false));
        _isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    debugPrint("ProductDetails  " + widget.listproduct.length.toString());
    debugPrint("ProductDetails  " + widget.selectedIndex.toString());

    if (widget.listproduct.length == 1) {
      widget.selectedIndex = 0;
      dummyData = widget.listproduct[widget.selectedIndex];
    } else {
      dummyData = widget.listproduct[widget.selectedIndex];
    }

    log("ProductDetails >>>>>>> ${dummyData!.toJson()}");
    productDetailBloc.add(ProductDetailLoadedEvent(
        dummyData!, false, widget.selectedIndex, imageIndex));
    for (var data in widget.listproduct)
      debugPrint("Data " + jsonEncode(data.addQuantity));
    debugPrint("P details  " + widget.selectedIndex.toString());
    return BlocBuilder(
      bloc: productDetailBloc,
      builder: (context, state) {
        screenHeight = Sizeconfig.getHeight(context);
        Appwidgets.setStatusBarColorWhite();
        if (scrollOffset > 1) {
          double remain = 1.0 - scrollOffset;
          scrollOffset = scrollOffset + remain;
        }
        mainScrollListener();
        if (state is UpdateIndexEvent) {}
        if (state is ProductDetailLoadingState) {
          Appwidgets.setStatusBarColorWhite();
          return const Scaffold(body: Center(child: CommonLoadingWidget()));
        }
        if (state is UpdateImageIndexState) {
          imageIndex = state.imageIndex;
        }
        if (state is ProductDetailLoadedState) {
          isRefresh = false;
          current_index = state.currentIndex;
          dummyData = widget.listproduct[current_index];
          imageIndex = state.imageIndex;
          viewMore = state.isviewMoreEnabled;
          debugPrint("State>>>>>> " + current_index.toString());
          debugPrint("State>>>>>> " + state.imageIndex.toString());

          // initializedDb();

          return productLoadedWidget(state, context);
        } else {
          return const SizedBox();
        }
      },
    );
  }

  mainScrollListener() {
    _mainPagescrollController.addListener(() {
      final offset = _mainPagescrollController.offset;
      final maxScrollExtent =
          _mainPagescrollController.position.maxScrollExtent;

      // Clamp scroll offset between 0 and maxScrollExtent
      scrollOffset = offset.clamp(0.0, maxScrollExtent);
      mainscrollOffset = offset;

      // Calculate opacity and angle based on scroll position
      if (maxScrollExtent > 0) {
        opacity = (offset / (screenHeight / 1.8)).clamp(0.0, 1.0);
        angle = -1.6;

        // Check if scrolled to the end
        if (offset == maxScrollExtent) {
          opacity = 1.0;
          angle = -((offset / (screenHeight / 5)).clamp(0.0, 1.0));
          angle = (angle - .6);
        }
      }
      if (_mainPagescrollController.offset == 0.0) {
        opacity = 0.0;
        angle = 0.0;
      }
      // Trigger event for product detail loading
      if (current_index == widget.selectedIndex) {
        productDetailBloc.add(ProductDetailLoadedEvent(
          dummyData!,
          viewMore,
          widget.selectedIndex,
          imageIndex,
        ));
      } else {
        productDetailBloc.add(ProductDetailLoadedEvent(
          dummyData!,
          viewMore,
          current_index,
          imageIndex,
        ));
      }
    });
  }

  String formatHtmlContent(String html) {
    // Replace every closing bold tag </b> with </b><br> to ensure a new line
    return html.replaceAllMapped(
      RegExp(
          r'(<b>\s*|</b>\s*)'), // Match either <b> or </b> with optional spaces
      (match) {
        return '${match.group(1)}<br>';
      }, // Add a <br> tag after </b>
    );
  }

  setAnimation() {
    Future.delayed(Duration(seconds: 1), () {
      animationBloc.add(AnimationOfferEvent(size: 50.0));
      offerimageSize = 50.0;
    });
  }

  Widget productLoadedWidget(state, context) {
    double price = double.parse(widget.listproduct![current_index].price!);
    var product = widget.listproduct![current_index];
    //   double price = double.parse(state.dummyData.price);
    var priceStr = product.specialPrice == ""
        ? "₹ ${double.parse(product.sortPrice!).toStringAsFixed(2)}"
        : "₹ ${double.parse(product.specialPrice!).toStringAsFixed(2)}";

    //price.toStringAsFixed(0);
    Appwidgets.setStatusBarColorWhite();
    setAnimation();

    // if (_mainPagescrollController.hasClients &&
    //     _mainPagescrollController.position.atEdge &&
    //     _mainPagescrollController.position.userScrollDirection ==
    //         ScrollDirection.idle) {
    //   angle = -(opacity * 2.6);
    // }
    log("PRODUCT DESC ${dummyData!.description}");
    return SafeArea(
      bottom: false,
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, widget.listproduct![current_index]);

          return true;
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: ColorName.ColorBagroundPrimary,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          child: Scaffold(
            body: Stack(
              children: [
                SingleChildScrollView(
                  controller: _mainPagescrollController,
                  child: Column(
                    children: [
                      SizedBox(
                        height: screenHeight * .4,
                        child: Stack(
                          children: [
                            PageView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.listproduct![current_index]
                                  .imageArray!.length,
                              onPageChanged: (value) {
                                //debugPrint("IMAGE URL === ${state.dummyData!.imageUrl}");
                                debugPrint("ValueImage $value");
                                productDetailBloc.add(ProductDetailLoadedEvent(
                                    dummyData!,
                                    state.isviewMoreEnabled,
                                    current_index,
                                    value));
                              },
                              itemBuilder: (context, index) {
                                return Container(
                                  width: Sizeconfig.getWidth(context),
                                  height: screenHeight * .4,
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child: CommonCachedImageWidget(
                                      imgUrl: widget.listproduct![current_index]
                                          .imageArray![index].imageUrl!,
                                      height: screenHeight * .2,
                                      width: Sizeconfig.getWidth(context)),
                                );
                              },
                            ),
                            (dummyData!.discountText != "" &&
                                    dummyData!.discountText != null)
                                ? Positioned(
                                    bottom: 20,
                                    right: 15,
                                    child: BlocProvider(
                                      create: (context) => animationBloc,
                                      child: BlocBuilder(
                                          bloc: animationBloc,
                                          builder: (context, state) {
                                            debugPrint(
                                                "Animtion Bloc State $state");

                                            if (state is AnimationOfferState) {
                                              offerimageSize = state.size;
                                            }

                                            return AnimatedContainer(
                                              height: offerimageSize,
                                              width: offerimageSize,
                                              duration:
                                                  const Duration(seconds: 1),
                                              // Provide an optional curve to make the animation feel smoother.
                                              curve: Curves.fastOutSlowIn,

                                              child: Stack(
                                                children: [
                                                  Container(
                                                      child: Image.asset(
                                                    Imageconstants
                                                        .img_detailoffer,
                                                    height: offerimageSize,
                                                    width: offerimageSize,
                                                  )),
                                                  Container(
                                                    height: offerimageSize,
                                                    width: offerimageSize,
                                                    child: Center(
                                                      child: Text(
                                                        dummyData!
                                                                .discountText ??
                                                            "",
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 2,
                                                        style: const TextStyle(
                                                          color:
                                                              ColorName.black,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                    ))
                                : Container()
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            widget
                                .listproduct![current_index].imageArray!.length,
                            (index) => Container(
                              height: 5,
                              width: index == current_index ? 28 : 9,
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                  color: index == imageIndex
                                      ? ColorName.ColorPrimary
                                      : ColorName.lightGey,
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Appwidgets.TextLagre(
                                          widget.listproduct[current_index]!
                                              .name!,
                                          Colors.black),
                                    ),
                                    double.parse(widget
                                                        .listproduct[
                                                            current_index]
                                                        .averageRating ??
                                                    "0.0")
                                                .toStringAsFixed(1) ==
                                            "0.0"
                                        ? SizedBox.shrink()
                                        : Row(
                                            children: [
                                              Icon(
                                                Icons.star,
                                                color: ColorName.yellow,
                                              ),
                                              Text(
                                                double.parse(widget
                                                            .listproduct[state
                                                                .currentIndex]
                                                            .averageRating ??
                                                        "0.0")
                                                    .toStringAsFixed(1),
                                                style: Appwidgets()
                                                    .commonTextStyle(
                                                        ColorName.black),
                                              ),
                                            ],
                                          )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 50,
                                child: ListView.builder(
                                  itemExtent:
                                      Sizeconfig.getWidth(context) * .25,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: widget.listproduct.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        productDetailBloc.add(
                                            ProductDetailLoadedEvent(
                                                dummyData!,
                                                state.isviewMoreEnabled,
                                                index,
                                                0));
                                        debugPrint("QUANTITY TAP  ${state}");
                                      },
                                      child: Card(
                                        elevation:
                                            index == current_index ? 5 : 0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: index == current_index
                                                  ? ColorName.ColorPrimary
                                                  : ColorName
                                                      .ColorBagroundPrimary,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                  color: index == current_index
                                                      ? ColorName.ColorPrimary
                                                      : ColorName.lightGey)),
                                          padding: EdgeInsets.all(5),
                                          child: Center(
                                            child: Appwidgets.TextSemiBold(
                                                widget.listproduct[index]
                                                        .productWeight
                                                        .toString() +
                                                    " " +
                                                    widget.listproduct[index]
                                                        .productWeightUnit
                                                        .toString(),
                                                index == current_index
                                                    ? ColorName
                                                        .ColorBagroundPrimary
                                                    : ColorName.black,
                                                TextAlign.center),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Divider(
                                  color: ColorName.lightGey,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  StringContants.lbl_product_details,
                                  style: Appwidgets()
                                      .commonTextStyle(ColorName.black),
                                ),
                              ),
                              Wrap(
                                runSpacing: 0,
                                spacing: 0,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Container(
                                      // padding: EdgeInsets.zero,
                                      // width: double.infinity,
                                      // height: state.isviewMoreEnabled
                                      //     ? viewMoreheight
                                      //     : viewLessheight,
                                      constraints: BoxConstraints(
                                          minHeight: 50,
                                          maxHeight: state.isviewMoreEnabled
                                              ? double.maxFinite
                                              : 50),

                                      child: HtmlWidget(
                                        '''
        <div style="text-align: justify;">
    ${formatHtmlContent(dummyData!.description ?? "")}
                                </div>
                                ''',
                                        textStyle: const TextStyle(
                                            color: ColorName.black,
                                            wordSpacing: 0),
                                        customStylesBuilder: (element) {
                                          return {
                                            'text-align':
                                                'justify', // Ensures justified alignment for HTML content
                                          };
                                        },
                                        // renderMode: RenderMode.listView,
                                        // style: {
                                        //   "*": Style(
                                        //     color: Colors.black,
                                        //   ),
                                        // },
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: GestureDetector(
                                      onTap: () {
                                        state.isviewMoreEnabled =
                                            !state.isviewMoreEnabled;
                                        productDetailBloc.add(
                                            ProductDetailLoadedEvent(
                                                dummyData!,
                                                state.isviewMoreEnabled,
                                                current_index,
                                                imageIndex));
                                        debugPrint("ISVIEW MORE ${state}");
                                      },
                                      child: Wrap(
                                        spacing: -3,
                                        runSpacing: 1,
                                        runAlignment: WrapAlignment.start,
                                        direction: Axis.horizontal,
                                        alignment: WrapAlignment.start,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          Text(
                                            state.isviewMoreEnabled
                                                ? StringContants.lbl_view_less
                                                : StringContants.lbl_view_more,
                                            style: Appwidgets()
                                                .commonTextStyle(
                                                    ColorName.darkBlue)
                                                .copyWith(
                                                    decorationColor:
                                                        ColorName.darkBlue,
                                                    fontSize:
                                                        Constants.SizeMidium,
                                                    decoration: TextDecoration
                                                        .underline,
                                                    fontWeight: Fontconstants
                                                        .Poppins_Bold),
                                          ),
                                          Image.asset(
                                            width: 18,
                                            height: 18,
                                            alignment: Alignment.centerLeft,
                                            state.isviewMoreEnabled
                                                ? Imageconstants
                                                    .keyboard_up_arrow
                                                : Imageconstants
                                                    .keyboard_arrow_down,
                                            color: ColorName.darkBlue,
                                            fit: BoxFit.contain,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Divider(
                                  color: ColorName.lightGey,
                                ),
                              ),
                              Card(
                                elevation: 0,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: Container(
                                  height: screenHeight * 0.40,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      BlocProvider(
                                        create: (context) => featuredBloc,
                                        child: BlocBuilder<FeaturedBloc,
                                                FeaturedState>(
                                            bloc: featuredBloc,
                                            builder: (context, state) {
                                              debugPrint(
                                                  "Featured Product State *** " +
                                                      state.toString());

                                              if (state
                                                  is LoadedFeaturedState) {
                                                listSimilarProducts =
                                                    state.list!;
                                                debugPrint(
                                                    "LoadedFeaturedState ** ${state.list!.length.toString()}");

                                                for (int index = 0;
                                                    index <
                                                        listSimilarProducts!
                                                            .length;
                                                    index++) {
                                                  var newmodel =
                                                      listSimilarProducts![
                                                              index]
                                                          .unit![0];
                                                  getCartQuantity(
                                                          newmodel.productId!)
                                                      .then((value) {
                                                    debugPrint(
                                                        "getCartQuanity $value");

                                                    if (value > 0) {
                                                      debugPrint(
                                                          "getCartQuanity name  ${listSimilarProducts![index].unit![0].name}");
                                                    }
                                                    listSimilarProducts![index]
                                                        .unit![0]
                                                        .addQuantity = value;
                                                    featuredBloc.add(
                                                        ProductUpdateQuantityInitial(
                                                            list:
                                                                listSimilarProducts));
                                                  });

                                                  if (newmodel!.cOfferId != 0 &&
                                                      newmodel.cOfferId !=
                                                          null) {
                                                    debugPrint(
                                                        "***********************");
                                                    if (newmodel.subProduct !=
                                                        null) {
                                                      log("***********************>>>>>>>>>>>>>>>>" +
                                                          newmodel.subProduct!
                                                              .toJson());
                                                      if (newmodel
                                                              .subProduct!
                                                              .subProductDetail!
                                                              .length >
                                                          0) {
                                                        listSimilarProducts![
                                                                    index]
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

                                                  if (listSimilarProducts![
                                                              index]
                                                          .unit!
                                                          .length >
                                                      1) {
                                                    for (int i = 0;
                                                        i <
                                                            listSimilarProducts![
                                                                    index]
                                                                .unit!
                                                                .length;
                                                        i++) {
                                                      getCartQuantity(
                                                              listSimilarProducts![
                                                                      index]
                                                                  .unit![i]
                                                                  .productId!)
                                                          .then((value) {
                                                        debugPrint(
                                                            "getCartQuanity ****  $value");
                                                        listSimilarProducts![
                                                                    index]
                                                                .unit![i]
                                                                .addQuantity =
                                                            value;
                                                        featuredBloc.add(
                                                            ProductUpdateQuantityInitial(
                                                                list:
                                                                    listSimilarProducts));
                                                      });
                                                    }
                                                  }
                                                }
                                              }
                                              if (state
                                                  is ProductForShopByState) {
                                                listSimilarProducts =
                                                    state.list!;
                                                debugPrint(
                                                    "LoadedFeaturedState ** ${state.list!.length.toString()}");

                                                for (int index = 0;
                                                    index <
                                                        listSimilarProducts!
                                                            .length;
                                                    index++) {
                                                  var newmodel =
                                                      listSimilarProducts![
                                                              index]
                                                          .unit![0];
                                                  getCartQuantity(
                                                          newmodel.productId!)
                                                      .then((value) {
                                                    debugPrint(
                                                        "getCartQuanity $value");

                                                    if (value > 0) {
                                                      debugPrint(
                                                          "getCartQuanity name  ${listSimilarProducts![index].unit![0].name}");
                                                    }
                                                    listSimilarProducts![index]
                                                        .unit![0]
                                                        .addQuantity = value;
                                                    featuredBloc.add(
                                                        ProductUpdateQuantityInitial(
                                                            list:
                                                                listSimilarProducts));
                                                  });

                                                  if (newmodel!.cOfferId != 0 &&
                                                      newmodel.cOfferId !=
                                                          null) {
                                                    debugPrint(
                                                        "***********************");
                                                    if (newmodel.subProduct !=
                                                        null) {
                                                      log("***********************>>>>>>>>>>>>>>>>" +
                                                          newmodel.subProduct!
                                                              .toJson());
                                                      if (newmodel
                                                              .subProduct!
                                                              .subProductDetail!
                                                              .length >
                                                          0) {
                                                        listSimilarProducts![
                                                                    index]
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

                                                  if (listSimilarProducts![
                                                              index]
                                                          .unit!
                                                          .length >
                                                      1) {
                                                    for (int i = 0;
                                                        i <
                                                            listSimilarProducts![
                                                                    index]
                                                                .unit!
                                                                .length;
                                                        i++) {
                                                      getCartQuantity(
                                                              listSimilarProducts![
                                                                      index]
                                                                  .unit![i]
                                                                  .productId!)
                                                          .then((value) {
                                                        debugPrint(
                                                            "getCartQuanity ****  $value");
                                                        listSimilarProducts![
                                                                    index]
                                                                .unit![i]
                                                                .addQuantity =
                                                            value;
                                                        featuredBloc.add(
                                                            ProductUpdateQuantityInitial(
                                                                list:
                                                                    listSimilarProducts));
                                                      });
                                                    }
                                                  }
                                                }
                                              }

                                              // For Manage card list product Quanityt
                                              if (state
                                                  is ProductUpdateQuantityInitialState) {
                                                listSimilarProducts =
                                                    state.list!;
                                              }

                                              if (state
                                                  is ProductLoadMoreState) {
                                                LoadMore = state.loadmore;
                                              }

                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  listSimilarProducts.length ==
                                                          0
                                                      ? Container()
                                                      : Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10),
                                                          child: Text(
                                                            StringContants
                                                                .lbl_similar_products,
                                                            style: Appwidgets()
                                                                .commonTextStyle(
                                                                    ColorName
                                                                        .black),
                                                          ),
                                                        ),
                                                  // const SizedBox(
                                                  //   height: 20,
                                                  // ),
                                                  Checkoutwidgets
                                                      .similarProductsUI(
                                                          widget.fromchekcout,
                                                          context,
                                                          state,
                                                          listSimilarProducts,
                                                          featuredBloc,
                                                          isMoreUnitIndex,
                                                          cardBloc,
                                                          dbHelper,
                                                          _scrollController,
                                                          LoadMore),
                                                ],
                                              );
                                            }),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                        color: ColorName.ColorBagroundPrimary.withOpacity(
                            scrollOffset),
                        boxShadow: scrollOffset != 0.0
                            ? [
                                const BoxShadow(
                                  color: Colors.black38,
                                  blurStyle: BlurStyle.normal,
                                  blurRadius: 5,
                                ),
                                const BoxShadow(
                                  color: Colors.transparent,
                                  blurStyle: BlurStyle.normal,
                                  blurRadius: 5,
                                ),
                              ]
                            : []),
                    padding: const EdgeInsets.all(5),
                    // width: Sizeconfig.getWidth(context),
                    alignment: Alignment.center,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        5.toSpace,
                        GestureDetector(
                          onTap: () async {
                            if (_mainPagescrollController.hasClients &&
                                _mainPagescrollController.offset > 100) {
                              _mainPagescrollController
                                  .animateTo(0,
                                      duration:
                                          const Duration(milliseconds: 800),
                                      curve: Curves.easeIn)
                                  .then(
                                (value) {
                                  dispose();

                                  Navigator.pop(context, dummyData);
                                },
                              );
                            } else {
                              dispose();

                              Navigator.pop(context, dummyData);
                            }
                          },
                          child: Padding(
                            padding: angle < (-1.5)
                                ? const EdgeInsets.only(bottom: 10)
                                : EdgeInsets.zero,
                            child: Align(
                              alignment: Alignment.center,
                              child: Transform.rotate(
                                angle: angle,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.arrow_back_ios,
                                  color: ColorName.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        10.toSpace,
                        SizedBox(
                          width: Sizeconfig.getWidth(context) * .7,
                          child: _mainPagescrollController.hasClients
                              ? Opacity(
                                  opacity: opacity,
                                  child: Text(
                                    dummyData!.name!,
                                    maxLines: 1,
                                    textWidthBasis: TextWidthBasis.parent,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    style: Appwidgets()
                                        .commonTextStyle(ColorName.black)
                                        .copyWith(
                                            overflow: TextOverflow.ellipsis),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        Spacer(),
                        BlocProvider(
                          create: (context) => cardBloc,
                          child: BlocBuilder(
                              bloc: cardBloc,
                              builder: (context, state) {
                                debugPrint(
                                    "ProductDetaisl screen cat state ${state}");
                                print(
                                    "SCREEN HEIGT ${Sizeconfig.getWidth(context) / 9.3}");
                                if (state is AddCardState) {
                                  count = state.count;
                                }
                                if (state is AddCardProductState) {
                                  count = state.listProduct.length;
                                  cartItems = state.listProduct;
                                  if (isRefresh == true) {
                                    for (var obj in state.listProduct) {
                                      if (dummyData!.productId ==
                                          obj.productId) {
                                        dummyData!.addQuantity =
                                            obj.addQuantity;
                                        productDetailBloc.add(
                                            ProductDetailLoadedEvent(
                                                dummyData!,
                                                false,
                                                widget.selectedIndex,
                                                imageIndex));
                                      }
                                    }
                                  }
                                }

                                if (state is CardEmptyState) {
                                  count = 0;
                                }
                                return count == 0
                                    ? SizedBox.shrink()
                                    : InkWell(
                                        onTap: () {
                                          // Navigator.pushNamed(context,
                                          //         Routes.checkoutscreen,
                                          //   arguments: {'list': []})
                                          //     .then((value) {
                                          //   Appwidgets
                                          //       .setStatusBarColorWhite();
                                          //   initializedDb();
                                          //   isRefresh = true;
                                          // });

                                          // Productvalidationswidgets
                                          //     .loadProductValication(
                                          //         context, cartItems, () {
                                          //   debugPrint(
                                          //       "Product Details callback");
                                          //   Appwidgets.setStatusBarColorWhite();
                                          //   initializedDb();
                                          //   isRefresh = true;
                                          // });

                                          if (widget.fromchekcout) {
                                            Productvalidationswidgets
                                                .loadProductValication(dbHelper,
                                                    context, cartItems, () {});
                                          } else {
                                            String id = "";
                                            for (var x in cartItems) {
                                              id = id + x.productId! + ",";
                                            }

                                            if (id.endsWith(',')) {
                                              id = id.substring(
                                                  0, id.length - 1);
                                            }

                                            debugPrint("ProductsIds ${id}");
                                            ApiProvider()
                                                .beforeYourCheckout(
                                                    id, 1, context)
                                                .then((value) async {
                                              if (value != "") {
                                                log("ROHIT Log 32  ${value}");
                                                Navigator.pushNamed(
                                                  context,
                                                  Routes.ordersummary_screen,
                                                  arguments: {
                                                    "ProductsIds": id,
                                                    "response": value,
                                                  },
                                                ).then((value) {
                                                  // callback();
                                                });
                                              } else {
                                                print("ROHIT Log 3");
                                              }
                                            });
                                          }
                                        },
                                        child: Container(
                                          // color: Colors.red,
                                          height: screenHeight / 9.3,
                                          width: Sizeconfig.getWidth(context) /
                                              9.3,
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Container(
                                                  width: 35,
                                                  height: 35,
                                                  // color: Colors.red,
                                                  child: Image.asset(
                                                    Imageconstants
                                                        .img_cartnewicon,
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 0,
                                                right: 0,
                                                child: Container(
                                                  height: 18,
                                                  width: 18,
                                                  decoration: BoxDecoration(
                                                      color: ColorName
                                                          .ColorPrimary,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0)),
                                                  alignment: Alignment.center,
                                                  child: Center(
                                                    child: Text(
                                                      "${count}",
                                                      style: TextStyle(
                                                          fontSize: 9,
                                                          fontFamily:
                                                              Fontconstants
                                                                  .fc_family_sf,
                                                          fontWeight: Fontconstants
                                                              .SF_Pro_Display_Regular,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        /*       child: SizedBox(
                                          // height: 30,
                                          // width: 30,

                                        ),*/
                                      );
                              }),
                        ),
                        5.toSpace
                      ],
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: Wrap(
              children: [
                Container(
                  // height: Sizeconfig.getHeight(context) * 0.11,
                  padding: EdgeInsets.zero,
                  child: Container(
                    // elevation: 10,
                    // shadowColor: ColorName.ColorPrimary,
                    // color: Colors.white,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, -1),
                          blurRadius: 1,
                          color: Colors.black12.withOpacity(0.3),
                        ),
                      ],
                    ),

                    child: Container(
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Container(
                          //   height: 1,
                          //   width: Sizeconfig.getWidth(context),
                          //   color: ColorName.textlight.withOpacity(0.1),
                          // ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    '₹ ${double.parse(product.price ?? "0.0")}' ==
                                            priceStr
                                        ? const SizedBox.shrink()
                                        : Row(
                                            children: [
                                              Appwidgets.Text_12(
                                                  "MRP", ColorName.black),
                                              10.toSpace,
                                              product.price == null ||
                                                      product.price == "null" ||
                                                      product.price == ""
                                                  ? const SizedBox.shrink()
                                                  : Text(
                                                      "₹ ${double.parse(product.price ?? "0.0")}",
                                                      style: Appwidgets()
                                                          .commonTextStyle(
                                                              ColorName
                                                                  .textlight2)
                                                          .copyWith(
                                                              decorationColor:
                                                                  ColorName
                                                                      .textlight2,
                                                              decoration:
                                                                  TextDecoration
                                                                      .lineThrough),
                                                    )
                                            ],
                                          ),
                                    Appwidgets.Text_20(
                                        "Price $priceStr", ColorName.darkGrey)
                                  ],
                                ),

                                // ElevatedButton(
                                //     onPressed: () {
                                //       // Navigator.pushNamed(context, Routes.checkoutscreen);
                                //     },
                                //     child: Text(
                                //       "Add To Card",
                                //       style: Appwidgets()
                                //           .commonTextStyle(ColorName.ColorBagroundPrimary)
                                //           .copyWith(
                                //           fontWeight: Fontconstants.SF_Pro_Display_SEMIBOLD),
                                //     ))
                                // Appwidgets.ButtonPrimary(
                                //   "Add to Card",
                                //   () {},
                                // )

                                dummyData!.addQuantity != 0
                                    ? Container(
                                        alignment: Alignment.bottomRight,
                                        child:
                                            Appwidgets.AddQuantityButtonDetails(
                                                context,
                                                StringContants.lbl_add,
                                                dummyData!.addQuantity!, () {
                                          //increase

                                          if (dummyData!.addQuantity ==
                                              int.parse(dummyData!
                                                  .orderQtyLimit!
                                                  .toString())) {
                                            Fluttertoast.showToast(
                                                msg: StringContants
                                                    .msg_quanitiy);
                                          } else {
                                            dummyData!.addQuantity =
                                                dummyData!.addQuantity + 1;

                                            dbHelper.updateCard2(
                                                dummyData!, cardBloc);
                                            print("Scroll Event1111 ");
                                          }

                                          productDetailBloc.add(
                                              ProductDetailLoadedEvent(
                                                  dummyData!,
                                                  state.isviewMoreEnabled,
                                                  current_index,
                                                  imageIndex));
                                          // initializedDb();
                                        }, () async {
                                          //decrease

                                          if (dummyData!.addQuantity != 0) {
                                            dummyData!.addQuantity =
                                                dummyData!.addQuantity - 1;
                                            cardBloc.add(CardEmptyEvent());
                                            dbHelper.updateCard2(
                                                dummyData!, cardBloc);

                                            if (dummyData!.addQuantity == 0) {
                                              await dbHelper
                                                  .deleteCard(int.parse(
                                                      dummyData!.productId!))
                                                  .then((value) {
                                                debugPrint(
                                                    "Delete Product $value ");

                                                dbHelper.loadAddCardProducts(
                                                    cardBloc);

                                                dbHelper.updateCard2(
                                                    dummyData!, cardBloc);
                                              });
                                              //initializedDb();
                                            }

                                            productDetailBloc.add(
                                                ProductDetailLoadedEvent(
                                                    dummyData!,
                                                    state.isviewMoreEnabled,
                                                    current_index,
                                                    imageIndex));
                                          }
                                        }),
                                      )
                                    : Appwidgets().buttonPrimaryDetails(
                                        context,
                                        StringContants.lbl_add,
                                        () {
                                          dummyData!.addQuantity =
                                              dummyData!.addQuantity + 1;
                                          dbHelper
                                              .checkItemId(
                                                  dummyData!.productId!)
                                              .then((value) {
                                            print("CheckItemIdGG $value");

                                            if (value == false) {
                                              dbHelper.addCard(
                                                  dummyData!, cardBloc);
                                            } else {
                                              dbHelper.updateCard2(
                                                  dummyData!, cardBloc);
                                            }

                                            productDetailBloc.add(
                                                ProductDetailLoadedEvent(
                                                    dummyData!,
                                                    state.isviewMoreEnabled,
                                                    current_index,
                                                    imageIndex));
                                          });

                                          //  initializedDb();
                                        },
                                      )
                              ],
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
        ),
      ),
    );
  }
}
