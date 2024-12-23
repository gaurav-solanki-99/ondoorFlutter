import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ondoor/constants/Constant.dart';
import 'package:ondoor/constants/FontConstants.dart';
import 'package:ondoor/constants/StringConstats.dart';
import 'package:ondoor/models/AllProducts.dart';
import 'package:ondoor/models/get_shopping_list_response.dart';
import 'package:ondoor/screens/shopping_list_detail_screen/shopping_list_detail_bloc/shopping_list_detail_bloc.dart';
import 'package:ondoor/screens/shopping_list_detail_screen/shopping_list_detail_bloc/shopping_list_detail_event.dart';
import 'package:ondoor/screens/shopping_list_detail_screen/shopping_list_detail_bloc/shopping_list_detail_state.dart';
import 'package:ondoor/screens/shopping_list_screen/shopping_list_bloc/shopping_list_bloc.dart';
import 'package:ondoor/screens/shopping_list_screen/shopping_list_screen.dart';
import 'package:ondoor/services/Navigation/route_generator.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/colors.dart';
import 'package:ondoor/widgets/AppWidgets.dart';
import 'package:ondoor/widgets/common_loading_widget.dart';

import '../../constants/ImageConstants.dart';
import '../../database/database_helper.dart';
import '../../database/dbconstants.dart';
import '../../services/Navigation/routes.dart';
import '../../utils/SizeConfig.dart';
import '../../utils/themeData.dart';
import '../../widgets/MyDialogs.dart';
import '../../widgets/common_cached_image_widget.dart';
import '../AddCard/card_bloc.dart';
import '../AddCard/card_event.dart';

class ShoppingListDetailScreen extends StatefulWidget {
  Shoppinglist shoppinglistDetail;
  ShoppingListDetailScreen({super.key, required this.shoppinglistDetail});

  @override
  State<ShoppingListDetailScreen> createState() =>
      _ShoppingListDetailScreenState();
}

class _ShoppingListDetailScreenState extends State<ShoppingListDetailScreen> {
  ShoppingListDetailBloc shoppingListDetailBloc = ShoppingListDetailBloc();
  bool isLoading = false;
  List<ProductUnit> unitList = [];
  List<ProductData>? list = [];
  int isMoreUnitIndex = 0;
  final dbHelper = DatabaseHelper();
  CardBloc cardBloc = CardBloc();
  String shoppingListName = "";
  @override
  void initState() {
    Appwidgets.setStatusBarColor();
    shoppingListName = widget.shoppinglistDetail.name!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: Appwidgets.shoppingListAppBar(context, shoppingListName, [
              GestureDetector(
                onTap: () {
                  MyDialogs.commonDialogwithtwoActionButtons(
                      context: context,
                      actionTap: () async {
                        var isDeleted =
                            await shoppingListDetailBloc.deleteShoppinglistApi(
                                context,
                                widget.shoppinglistDetail.shoppingListId!);
                        if (isDeleted) {
                          Navigator.popAndPushNamed(
                              context, Routes.shopping_list);
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      titleText: "Are you sure you want to delete this list ??",
                      actionText: "Yes");
                },
                child: const Icon(
                  Icons.delete,
                  color: ColorName.ColorBagroundPrimary,
                ),
              ),
              10.toSpace,
              GestureDetector(
                onTap: () {
                  shoppingListDetailBloc.shoppingListNameController.text =
                      widget.shoppinglistDetail.name!;
                  shoppingListDetailBloc.updateShoppingListDialog(
                      context, widget.shoppinglistDetail.shoppingListId!);
                },
                child: const Icon(
                  Icons.edit,
                  color: ColorName.ColorBagroundPrimary,
                ),
              ),
              10.toSpace,
            ]),
            body: BlocBuilder(
              bloc: shoppingListDetailBloc,
              builder: (context, state) {
                if (state is ShoppingListDetailInitialState) {
                  isLoading = false;
                  shoppingListDetailBloc.getProductsFromShoppingList(
                      context, widget.shoppinglistDetail.shoppingListId!);
                }
                if (state is ShoppingListDetailLoadingState) {
                  isLoading = true;
                }
                if (state is ShoppingListDetailLoadedState) {
                  isLoading = false;
                  unitList = state.data;
                }
                return isLoading
                    ? const Center(
                        child: CommonLoadingWidget(),
                      )
                    : unitList.isEmpty
                        ? Center(
                            child: Appwidgets.Text_20(
                                "Your shopping list has no products",
                                ColorName.black),
                          )
                        : ListView.builder(
                            itemCount: unitList.length,
                            itemBuilder: (context, index) {
                              var unit = unitList[index];
                              return categoryItemView(
                                  context, unit, state, index, false);
                            },
                          );
              },
            )));
  }

  Widget categoryItemView(BuildContext context, ProductUnit model,
      dynamic state, int index, bool isMoreUnit) {
    print("categoryItemViewModel ${jsonEncode(model.discountText)}");

    return InkWell(
      onTap: () {
        for (int i = 0; i < list![index].unit!.length!; i++) {
          print("Model  ${model.productId} ${model.addQuantity} ");
          if (model.productId == list![index].unit![i].productId!) {
            list![index].unit![i] = model;
            isMoreUnitIndex = i;
          }
          print(
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
        ).then((value) {
          OndoorThemeData.setStatusBarColor();

          initState();
        });
      },
      child: Container(
        key: Key(model.productId!),
        height: isMoreUnit
            ? Sizeconfig.getHeight(context) * 0.16
            : Sizeconfig.getHeight(context) * 0.14,
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
        padding: EdgeInsets.only(top: 6, bottom: 6, left: 5, right: 6),
        decoration: BoxDecoration(
          color: ColorName.ColorBagroundPrimary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ColorName.lightGey),
        ),
        // margin:  EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        child: Padding(
          padding: EdgeInsets.all(0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  height: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    child: Stack(
                      children: [
                        Card(
                          elevation: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: ColorName.ColorBagroundPrimary,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: ColorName.lightGey),
                            ),
                            height: Sizeconfig.getWidth(context) * .25,
                            padding: EdgeInsets.all(10),
                            width: Sizeconfig.getWidth(context) * .25,
                            child: CommonCachedImageWidget(
                              imgUrl: model.image!,
                            ),
                          ),
                        ),
                        (model.discountText ?? "") == ""
                            ? Container()
                            : Visibility(
                                visible: (model!.discountText != "" ||
                                    model!.discountText != null),
                                child: Positioned(
                                  left: 7,
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
                ),
              ),
              Expanded(
                flex: 8,
                child: Container(
                  height: double.infinity,
                  padding: EdgeInsets.only(left: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: Sizeconfig.getHeight(context) * .05,
                        width: Sizeconfig.getWidth(context) * 0.55,
                        child: Appwidgets.TextMediumBold(
                          model.name!,
                          ColorName.black,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (isMoreUnit) {
                            MyDialogs.optionDialog(
                                    context, list![index].unit!, model)
                                .then((value) {
                              isMoreUnitIndex = list![index]
                                  .unit!
                                  .indexWhere((model) => model == value);
                              print("Dialog value ${index} ${value.name} ");
                              shoppingListDetailBloc
                                  .add(ProductChangeEvent(model: value));
                            });
                          }
                        },
                        child: Container(
                          child: Container(
                            decoration: isMoreUnit
                                ? BoxDecoration(
                                    color: ColorName.ColorBagroundPrimary,
                                    borderRadius: BorderRadius.circular(10),
                                    border:
                                        Border.all(color: ColorName.lightGey),
                                  )
                                : null,
                            padding: isMoreUnit
                                ? EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 5)
                                : EdgeInsets.only(top: 5),
                            width: Sizeconfig.getWidth(context) * .25,
                            child: Align(
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    model.productWeight.toString() +
                                        " ${model.productWeightUnit}",
                                    style: TextStyle(
                                      fontSize: Constants.SizeSmall,
                                      fontFamily: Fontconstants.fc_family_sf,
                                      fontWeight:
                                          Fontconstants.SF_Pro_Display_Bold,
                                      color: isMoreUnit
                                          ? ColorName.black
                                          : ColorName.textlight,
                                    ),
                                  ),
                                  Visibility(
                                      visible: isMoreUnit,
                                      child: Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black,
                                      ))
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                model.specialPrice == ""
                                    ? ""
                                    : "₹ ${double.parse(model.price!).toStringAsFixed(2)}",
                                style: TextStyle(
                                    fontSize: Constants.SizeSmall,
                                    fontFamily: Fontconstants.fc_family_sf,
                                    fontWeight:
                                        Fontconstants.SF_Pro_Display_Medium,
                                    letterSpacing: 0,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: ColorName.textlight,
                                    color: ColorName.textlight),
                              ),
                              Visibility(
                                visible: model.specialPrice != "",
                                child: SizedBox(
                                  width: 5,
                                ),
                              ),
                              Expanded(
                                  flex: 0,
                                  child: Appwidgets.TextMediumBold(
                                      model.specialPrice == ""
                                          ? "₹ ${double.parse(model.sortPrice!).toStringAsFixed(2)}"
                                          : "₹ ${double.parse(model.specialPrice!).toStringAsFixed(2)}",
                                      ColorName.black)),
                            ],
                          ),
                          model.addQuantity != 0
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
                                      shoppingListDetailBloc.add(
                                          ProductUpdateQuantityEvent(
                                              quanitity: model.addQuantity!,
                                              index: index));
                                      shoppingListDetailBloc.add(
                                          ProductChangeEvent(model: model));
                                      updateCard(model);
                                      print("Scroll Event1111 ");
                                    }
                                  }, () async {
                                    //decrease

                                    if (model.addQuantity != 0) {
                                      model.addQuantity = model.addQuantity - 1;

                                      shoppingListDetailBloc.add(
                                          ProductUpdateQuantityEvent(
                                              quanitity: model.addQuantity!,
                                              index: index));

                                      updateCard(model);

                                      if (model.addQuantity == 0) {
                                        await dbHelper
                                            .deleteCard(
                                                int.parse(model.productId!))
                                            .then((value) {
                                          debugPrint("Delete Product $value ");

                                          cardBloc.add(CardDeleteEvent(
                                              model: model,
                                              listProduct: list![0].unit!));
                                          dbHelper
                                              .loadAddCardProducts(cardBloc);

                                          if (list![0].unit!.length == 0) {
                                            cardBloc.add(CardEmptyEvent());
                                          }

                                          shoppingListDetailBloc.add(
                                              ProductUpdateQuantityEvent(
                                                  quanitity: model.addQuantity!,
                                                  index: index));

                                          updateCard(model);
                                        });
                                      }
                                      shoppingListDetailBloc.add(
                                          ProductChangeEvent(model: model));
                                    }
                                  }),
                                )
                              : Appwidgets().buttonPrimary(
                                  StringContants.lbl_add,
                                  () {
                                    // print("GGGGGGG " +
                                    //     cardItesmList.length.toString());

                                    model.addQuantity = model.addQuantity + 1;
                                    checkItemId(model.productId!).then((value) {
                                      print("CheckItemId $value");

                                      if (value == false) {
                                        addCard(model);
                                      } else {
                                        updateCard(model);
                                      }
                                    });

                                    shoppingListDetailBloc.add(
                                        ProductUpdateQuantityEvent(
                                            quanitity: model.addQuantity!,
                                            index: index));
                                    shoppingListDetailBloc
                                        .add(ProductChangeEvent(model: model));
                                  },
                                )
                        ],
                      ),
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

  updateCard(ProductUnit model) async {
    int status = await dbHelper.updateCard({
      DBConstants.PRODUCT_ID: int.parse(model.productId!),
      DBConstants.QUANTITY: model.addQuantity,
    });

    dbHelper.loadAddCardProducts(cardBloc);
  }

  addCard(ProductUnit model) async {
    print("${jsonEncode(model.imageArray)}       >>>>>>>>>>>>>>>>>>");
    String image_array_json = "";

    print("Image Array .length " + model.imageArray!.length.toString());
    for (int i = 0; i < model!.imageArray!.length; i++) {
      print("** $i ");
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

    print("Moodel to Add " + image_array_json);

    int status = await dbHelper.insertAddCardProduct({
      DBConstants.PRODUCT_ID: int.parse(model.productId!),
      DBConstants.PRODUCT_NAME: model.name,
      DBConstants.PRODUCT_WEIGHT: model.productWeight,
      DBConstants.PRODUCT_WEIGHT_UNIT: model.productWeightUnit,
      DBConstants.ORDER_QTY_LIMIT: model.orderQtyLimit,
      DBConstants.CNF_SHIPPING_SURCHARGE: "",
      DBConstants.SHIPPING_MAX_AMOUNT: "",
      DBConstants.IMAGE: model.image,
      DBConstants.IMAGE: model.discountText,
      DBConstants.IMAGE: model.discountLabel,
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

    print("Add Card Status $status");

    cardBloc.add(AddCardEvent(count: status));
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
}
