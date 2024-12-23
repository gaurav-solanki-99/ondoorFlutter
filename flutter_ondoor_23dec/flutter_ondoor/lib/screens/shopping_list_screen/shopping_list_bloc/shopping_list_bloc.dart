import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondoor/constants/StringConstats.dart';
import 'package:ondoor/models/add_shopping_list_response.dart';
import 'package:ondoor/models/get_shopping_list_response.dart';
import 'package:ondoor/screens/shopping_list_screen/shopping_list_bloc/shopping_list_event.dart';
import 'package:ondoor/screens/shopping_list_screen/shopping_list_bloc/shopping_list_state.dart';
import 'package:ondoor/services/ApiServices.dart';
import 'package:ondoor/services/Navigation/routes.dart';
import 'package:ondoor/utils/Connection.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/colors.dart';
import 'package:ondoor/utils/themeData.dart';
import 'package:ondoor/widgets/AppWidgets.dart';
import 'package:ondoor/widgets/MyDialogs.dart';

class ShoppingListBloc extends Bloc<ShoppingListEvent, ShoppingListState> {
  TextEditingController shoppingListNameController = TextEditingController();
  ShoppingListBloc() : super(ShoppingListInitialState()) {
    on<ShoppingListInitialEvent>(
        (event, emit) => emit(ShoppingListInitialState()));
    on<ShoppingListLoadingEvent>(
        (event, emit) => emit(ShoppingListLoadingState()));
    on<ShoppingListLoadedEvent>(
      (event, emit) {
        emit(ShoppingListLoadingState());
        emit(ShoppingListLoadedState(shoppinglist: event.shoppinglist));
      },
    );
  }
  getShoppingList(context) async {
    if (await Network.isConnected()) {
      GetShoppingListResponse getShoppingListResponse =
          await ApiProvider().getShoppingList(() async {
        getShoppingList(context);
      });
      add(ShoppingListLoadedEvent(
          shoppinglist: getShoppingListResponse.shoppinglist!));
    } else {
      MyDialogs.showInternetDialog(context, () {
        Navigator.pop(context);
        getShoppingList(context);
      });
    }
  }

  addShoppingListDialog(context) {
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
                      onPressed: () {
                        addShoppingList(context);
                      },
                      child: Text(
                        "Add",
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

  addShoppingList(context) async {
    if (await Network.isConnected()) {
      AddShoppingListResponse addShoppingListResponse =
          await ApiProvider().addShoppingList(shoppingListNameController.text);
      shoppingListNameController.clear();
      // Navigator.pop(context);
      if (addShoppingListResponse.success == true) {
        Navigator.pop(context);
        OndoorThemeData.keyBordDow();
        add(ShoppingListLoadingEvent());
        getShoppingList(context);
      } else {
        MyDialogs.commonDialog(
            context: context,
            actionTap: () {
              Navigator.pushNamed(context, Routes.home_page);
            },
            titleText: addShoppingListResponse.message!,
            actionText: StringContants.lbl_continue_shopping);
      }
    } else {
      MyDialogs.showInternetDialog(context, () {
        Navigator.pop(context);
        addShoppingList(context);
      });
    }
  }

  @override
  Future<void> close() {
    shoppingListNameController.dispose();
    // TODO: implement close
    return super.close();
  }
}
