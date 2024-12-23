import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondoor/models/get_shopping_list_response.dart';
import 'package:ondoor/screens/shopping_list_screen/shopping_list_bloc/shopping_list_bloc.dart';
import 'package:ondoor/screens/shopping_list_screen/shopping_list_bloc/shopping_list_state.dart';
import 'package:ondoor/services/Navigation/routes.dart';
import 'package:ondoor/utils/colors.dart';
import 'package:ondoor/widgets/AppWidgets.dart';
import 'package:ondoor/widgets/common_loading_widget.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'shopping_list_bloc/shopping_list_event.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  ShoppingListBloc shoppingListBloc = ShoppingListBloc();
  bool isLoading = false;
  List<Shoppinglist> shoppingList = [];
  @override
  void initState() {
    Appwidgets.setStatusBarColor();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorName.whiteSmokeColor,
        appBar: Appwidgets.shoppingListAppBar(context, "Shopping List", [
          GestureDetector(
            onTap: () {
              shoppingListBloc.addShoppingListDialog(context);
            },
            child: const Icon(
              Icons.add,
              color: ColorName.ColorBagroundPrimary,
            ),
          )
        ]),
        // appBar: AppBar(
        //   actions: [
        //
        //
        //
        //
        //
        //
        //
        //
        //
        //   ],
        //   title: Appwidgets.TextExtraLagre("Shopping List", Colors.white),
        //   leading: IconButton(
        //     icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        //     onPressed: () => Navigator.of(context).pop(),
        //   ),
        //   centerTitle: true,
        // ),
        body: BlocBuilder(
          bloc: shoppingListBloc,
          builder: (context, state) {
            if (state is ShoppingListInitialState) {
              isLoading = false;
              shoppingListBloc.add(ShoppingListLoadingEvent());
              shoppingListBloc.getShoppingList(context);
            }
            if (state is ShoppingListLoadingState) {
              isLoading = true;
            }
            if (state is ShoppingListLoadedState) {
              shoppingList = state.shoppinglist;
              isLoading = false;
            }
            return VisibilityDetector(
              key: Key("shopping_list_screen"),
              child: isLoading
                  ? const Center(
                      child: CommonLoadingWidget(),
                    )
                  : shoppingList.isEmpty
                      ? Center(
                          child: Appwidgets.Text_20(
                              "No Shopping List Found !!", ColorName.black),
                        )
                      : ListView.builder(
                          itemCount: shoppingList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, Routes.shopping_list_detail,
                                      arguments: shoppingList[index]);
                                },
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: ColorName.lightGey, width: 1),
                                      borderRadius: BorderRadius.circular(12)),
                                  tileColor: ColorName.ColorBagroundPrimary,
                                  leading: Container(
                                    decoration: BoxDecoration(
                                        color: ColorName.ColorPrimary,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    child: Text(
                                      shoppingList[index]
                                          .name![0]
                                          .toUpperCase(),
                                      style: Appwidgets().commonTextStyle(
                                          ColorName.ColorBagroundPrimary),
                                    ),
                                  ),
                                  title: Text(
                                    shoppingList[index].name!,
                                    style: Appwidgets()
                                        .commonTextStyle(ColorName.black),
                                  ),
                                ),
                              ),
                            );
                          }),
              onVisibilityChanged: (info) {
                var visiblePercentage = info.visibleFraction * 100;
                if (visiblePercentage == 100) {
                  shoppingListBloc.getShoppingList(context);
                }
              },
            );
          },
        ),
      ),
    );
  }
}
