import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondoor/models/AllProducts.dart';
import 'package:ondoor/models/shopping_list_modification_response.dart';
import 'package:ondoor/screens/shopping_list_detail_screen/shopping_list_detail_bloc/shopping_list_detail_event.dart';
import 'package:ondoor/screens/shopping_list_detail_screen/shopping_list_detail_bloc/shopping_list_detail_state.dart';
import 'package:ondoor/screens/shopping_list_screen/shopping_list_bloc/shopping_list_bloc.dart';
import 'package:ondoor/services/ApiServices.dart';
import 'package:ondoor/services/Navigation/routes.dart';
import 'package:ondoor/utils/Connection.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/widgets/MyDialogs.dart';

import '../../../utils/colors.dart';
import '../../../widgets/AppWidgets.dart';

class ShoppingListDetailBloc
    extends Bloc<ShoppingListDetailEvent, ShoppingListDetailState> {
  TextEditingController shoppingListNameController = TextEditingController();
  ShoppingListDetailBloc() : super(ShoppingListDetailInitialState()) {
    on<ShoppingListDetailInitialEvent>(
        (event, emit) => emit(ShoppingListDetailInitialState()));
    on<ShoppingListDetailLoadingEvent>(
        (event, emit) => emit(ShoppingListDetailLoadingState()));
    on<ProductChangeEvent>(
        (event, emit) => emit(ProductChangeState(model: event.model)));
    on<ProductUpdateQuantityEvent>((event, emit) => emit(
        ProductUpdateQuantityState(
            index: event.index, quanitity: event.quanitity)));
    on<ShoppingListDetailLoadedEvent>(
        (event, emit) => emit(ShoppingListDetailLoadedState(data: event.data)));
  }

  updateShoppingListDialog(context, String shoppingList_Id) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: ColorName.ColorBagroundPrimary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Wrap(
            runSpacing: 10,
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextFormField(
                  style: Appwidgets().commonTextStyle(ColorName.black),
                  controller: shoppingListNameController,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: ColorName.lightGey, width: 1),
                        borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: ColorName.lightGey, width: 1),
                        borderRadius: BorderRadius.circular(12)),
                    hintText: "Enter Shopping List Name",
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        var updated = await updateShoppinglistApi(
                            context, shoppingList_Id);
                        if (updated) {
                          Navigator.pushReplacementNamed(
                              context, Routes.shopping_list);
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        "Update",
                        style: Appwidgets()
                            .commonTextStyle(ColorName.ColorBagroundPrimary),
                      )),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Cancel",
                          style: Appwidgets().commonTextStyle(
                              ColorName.ColorBagroundPrimary))),
                ],
              ),
              5.toSpace
            ],
          ),
        );
      },
    );
  }

  Future<bool> updateShoppinglistApi(context, String shoppingList_id) async {
    ShoppingListModificationResponse shoppingListModificationResponse =
        await ApiProvider().renameShoppingList(
            shoppingListNameController.text, shoppingList_id);
    if (shoppingListModificationResponse.success == true) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> deleteShoppinglistApi(context, String shoppingList_id) async {
    // ShoppingListBloc shoppingListBloc = ShoppingListBloc();
    ShoppingListModificationResponse? shoppingListModificationResponse;
    if (await Network.isConnected()) {
      shoppingListModificationResponse =
          await ApiProvider().deleteShoppingList(shoppingList_id);
    } else {
      MyDialogs.showInternetDialog(context, () async {
        Navigator.pop(context);
        shoppingListModificationResponse =
            await ApiProvider().deleteShoppingList(shoppingList_id);
      });
    }

    return shoppingListModificationResponse!.success ?? false;
  }

  getProductsFromShoppingList(context, String shoppingListID) async {
    if (await Network.isConnected()) {
      List<ProductUnit> unitList = [];
      add(ShoppingListDetailLoadingEvent());
      ProductsModel productsModel =
          await ApiProvider().getProductFromShoppingList(shoppingListID);
      for (ProductData shopBycategoryData in productsModel.data!) {
        shopBycategoryData.unit!.forEach(
          (element) {
            element.selectedQuantity =
                "${element.productWeight} ${element.productWeightUnit!}";
          },
        );
        unitList.addAll(shopBycategoryData.unit!);
      }
      add(ShoppingListDetailLoadedEvent(data: unitList));
    } else {
      MyDialogs.showInternetDialog(context, () {
        Navigator.pop(context);
        getProductsFromShoppingList(context, shoppingListID);
      });
    }
  }
}
