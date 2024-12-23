import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ondoor/constants/Constant.dart';
import 'package:ondoor/constants/FontConstants.dart';
import 'package:ondoor/constants/StringConstats.dart';
import 'package:ondoor/models/AllProducts.dart';
import 'package:ondoor/screens/location_screen/location_bloc/location_state.dart';
import 'package:ondoor/services/ApiServices.dart';
import 'package:ondoor/utils/Connection.dart';
import 'package:ondoor/utils/SizeConfig.dart';
import 'package:ondoor/utils/colors.dart';
import 'package:ondoor/widgets/AppWidgets.dart';

import '../../../models/HomepageModel.dart';
import '../../../models/filter_data_params.dart';
import '../../../models/shop_by_category_response.dart';
import '../../../widgets/MyDialogs.dart';

part 'shop_by_category_event.dart';
part 'shop_by_category_state.dart';

class ShopByCategoryBloc
    extends Bloc<ShopByCategoryEvent, ShopByCategoryState> {
  int currentIndex = 0;
  int quantityIndex = 0;
  int count = 0;
  bool isPaginationListEnded = false;
  bool isPaginationLoading = false;
  bool routetoProductDetail = false;
  Category? category;
  String selectedFilterCategory = "All";
  String sortingIndex = "0";
  String selectedFilter = "";
  int pageNumber = 1;
  List<SubCategory> subCategoryDataNew = [];
  List<ProductData> productDataList = [];
  ProductUnit selectedUnit = ProductUnit();
  SubCategory? selectedSubcategory;
  SubCategory categoryfromPreviousScreen = SubCategory();
  List<SubCategory> subCategoryList = [];
  List<ProductUnit> unitList = [];
  List<ProductData> dataList = [];
  List<SubCategory> categoryList = [];
  ShopByCategoryBloc() : super(ShopByCategoryInitialState()) {
    on<ShopByCategoryInitialEvent>(
        (event, emit) => emit(ShopByCategoryInitialState()));
    on<FilterEvent>(
      (event, emit) {
        emit(ShopByCategoryLoadingState());
        emit(FilterState(
            isFilterOn: event.isFilterOn,
            selected_Filter: event.selected_Filter));
      },
    );
    on<ShopByCategoryTabChangeEvent>((event, emit) =>
        emit(ShopByCategoryTabChangeState(tabIndex: event.tabIndex)));
    on<ShopByCategoryLoadingEvent>(
        (event, emit) => emit(ShopByCategoryLoadingState()));
    on<WeightChangeEvent>(
      (event, emit) {
        emit(ShopByCategoryLoadingState());
        emit(WeightChangeState(
            event.unit,
            event
                .selectedIndex /*,
         event.filterList, event.selectedIndex*/
            ));
      },
    );

    on<ShopByCategoryLoadedEvent>(
      (event, emit) {
        emit(ShopByCategoryLoadingState());
        emit(ShopByCategoryLoadedState(event.categoryList,
            event.subCategoryList, event.unitList, event.selectedIndex));
      },
    );
    on<SectorChangeEvent>(
      (event, emit) {
        emit(ShopByCategoryLoadingState());
        emit(SectorChangeState(event.selectedCategory, event.categoryList));
      },
    );
    on<QuantityChangeEvent>(
      (event, emit) {
        emit(ShopByCategoryLoadingState());
        emit(QuantityChangeState(event.categoryList, event.dummyList,
            event.filterList, event.count, event.selectedIndex));
      },
    );
    on<ShopByCategoryErrorEvent>(
        (event, emit) => emit(ShopByCategoryErrorState(event.errorMessage)));

    on<ShopbyProductUpdateQuantityEvent>((event, emit) {
      emit(ShopByCategoryLoadingState());
      emit(ShopbyProductUpdateQuantityState(
          model: event.model, unitList: event.unitList, index: event.index));
    });
    on<ShopbyProductChangeEvent>(
      (event, emit) {
        emit(ShopByCategoryLoadingState());
        emit(ShopbyProductChangeState(model: event.model));
      },
    );

    on<ShopByNullEvent>((event, emit) {
      emit(ShopByNullState());
    });
    on<NoInternetEvent>((event, emit) {
      emit(NoInternetState());
    });

    on<ShopbyUpdateUnitEvent>((event, emit) {
      emit(ShopByCategoryLoadingState());
      emit(ShopbyUpdateUnitState(model: event.model, index: event.index));
    });

    on<SearchAnimatedEvent>((event, emit) {
      emit(ShopByCategoryLoadingState());

      emit(SearchAnimatedState(height: event.height));
    });
  }

  void addCategoryData(Category categoryData, BuildContext context) async {
    category = categoryData;
    add(ShopByCategoryLoadingEvent());
    subCategoryList.clear();
    print("FILTER LIST CLEAR ADD CATEGORY DATA1 ${categoryData.id!}");
    callingApi(categoryData.id!, "1", context);
  }

  void addCategoryData2(Category categoryData, SubCategory subcategoryData,
      BuildContext context) async {
    category = categoryData;
    add(ShopByCategoryLoadingEvent());
    if (routetoProductDetail = false) {
      subCategoryList.clear();
    }
    print("FILTER LIST CLEAR ADD CATEGORY DATA ${subcategoryData.categoryId!}");
    callingApi(subcategoryData.categoryId!, "4", context);
  }

  callingApi(categoryID, String currentflow, BuildContext context) async {
    if (await Network.isConnected()) {
      isPaginationLoading = true;
      add(ShopByCategoryErrorEvent(""));
      if (sortingIndex == "0") {
        selectedFilter = "Default";
        add(FilterEvent(isFilterOn: false, selected_Filter: selectedFilter));
      } else {
        add(FilterEvent(isFilterOn: true, selected_Filter: selectedFilter));
      }
      add(ShopByCategoryLoadingEvent());
      print(
          "getCategoriesItem Request >>>   ${categoryID} ${sortingIndex}  ${pageNumber}");
      ProductsModel shopByCategoryResponse = await ApiProvider()
          .shopByCAtegoryApi(categoryID, sortingIndex, pageNumber);
      if (shopByCategoryResponse.success == true) {
        isPaginationLoading = false;
        isPaginationListEnded = false;
        if (pageNumber == 1) {
          unitList.clear();
        }
        productDataList = shopByCategoryResponse.data;
        for (ProductData shopBycategoryData in shopByCategoryResponse.data!) {
          shopBycategoryData.unit!.forEach(
            (element) {
              element.selectedQuantity =
                  "${element.productWeight} ${element.productWeightUnit!}";
            },
          );
          unitList.addAll(shopBycategoryData.unit!);
        }
        print("categoryIDcategoryID ${categoryID}");
        print("currentflow ${currentflow}");
        if (currentflow == "1") {
          subCategoryList.clear();
          for (var subCategoryData in category!.subCategories!) {
            categoryList = subCategoryData.subCategories!;
            // filterLists.add(SubCategory(name: "Sort"));
            subCategoryList = subCategoryData.subCategories!;
          }
          // filterLists.add(categoryList[0]);
          add(ShopByCategoryLoadedEvent(category!.subCategories!,
              shopByCategoryResponse.data!, subCategoryList, currentIndex));
        }
        if (currentflow == "3") {
          for (var filterData in category!.subCategories!) {
            subCategoryList = filterData.subCategories!;
          }
          // subCategoryList = categoryfromPreviousScreen.subCategories ?? [];
          add(ShopByCategoryLoadedEvent(category!.subCategories!,
              shopByCategoryResponse.data!, subCategoryList, currentIndex));
        }
        if (currentflow == "4") {
          subCategoryList = categoryfromPreviousScreen.subCategories ?? [];
          print("SUB CATEGORY LIST ${subCategoryList.length}");
          add(ShopByCategoryLoadedEvent(category!.subCategories!,
              shopByCategoryResponse.data!, subCategoryList, currentIndex));
        }
        if (currentflow == "5") {
          subCategoryList = category!.subCategories![0].subCategories!;
          add(ShopByCategoryLoadedEvent(category!.subCategories!,
              shopByCategoryResponse.data!, subCategoryList, currentIndex));
        }
        if (currentflow == "6") {
          subCategoryList = selectedSubcategory!.subCategories!;
          add(ShopByCategoryLoadedEvent(category!.subCategories!,
              shopByCategoryResponse.data!, subCategoryList, currentIndex));
        } else {
          add(ShopByCategoryLoadedEvent(category!.subCategories!,
              shopByCategoryResponse.data!, subCategoryList, currentIndex));
        }
      } else {
        isPaginationLoading = false;
        isPaginationListEnded = true;
        if (pageNumber == 1) {
          unitList.clear();

          add(ShopByCategoryErrorEvent(shopByCategoryResponse.data.toString()));
        } else {
          add(ShopByNullEvent());
          add(ShopByCategoryLoadedEvent(category!.subCategories!,
              productDataList, subCategoryList, currentIndex));
        }
      }
    } else {
      isPaginationLoading = false;
      MyDialogs.showInternetDialog(context, () {
        Navigator.pop(context);
        subCategoryList.clear();

        callingApi(categoryID, currentflow, context);
      });
    }

    print("GGGGGGGG 1 $isPaginationListEnded");
    print("GGGGGGGG 2$isPaginationLoading");
  }

  getFilteredData(
      categoryID,
      BuildContext context,
      List<FilterDataParams> filterDataParams,
      List<SubCategory> filterList) async {
    if (await Network.isConnected()) {
      add(ShopByCategoryErrorEvent(""));
      add(FilterEvent(isFilterOn: true, selected_Filter: selectedFilter));
      add(ShopByCategoryLoadingEvent());

      ProductsModel shopByCategoryResponse = await ApiProvider()
          .getFilteredData(
              categoryID, sortingIndex, pageNumber, filterDataParams);
      if (shopByCategoryResponse.success == true) {
        isPaginationListEnded = false;
        unitList.clear();
        for (ProductData shopBycategoryData in shopByCategoryResponse.data!) {
          shopBycategoryData.unit!.forEach(
            (element) {
              element.selectedQuantity =
                  "${element.productWeight} ${element.productWeightUnit!}";
            },
          );
          unitList.addAll(shopBycategoryData.unit!);
        }
        for (var subCategoryData in category!.subCategories!) {
          categoryList = subCategoryData.subCategories!;
          // filterLists.add(SubCategory(name: "Sort"));
        }
        add(ShopByCategoryLoadedEvent(category!.subCategories!,
            shopByCategoryResponse.data!, filterList, currentIndex));
      } else {
        isPaginationLoading = false;
        isPaginationListEnded = true;
        if (pageNumber == 1) {
          unitList.clear();

          add(ShopByCategoryErrorEvent(shopByCategoryResponse.data.toString()));
        } else {
          add(ShopByCategoryLoadedEvent(category!.subCategories!,
              const <ProductData>[], subCategoryList, currentIndex));
        }
      }
    } else {
      MyDialogs.showInternetDialog(context, () {
        Navigator.pop(context);
        getFilteredData(categoryID, context, filterDataParams, filterList);
      });
    }
  }

  /*void refreshingFilter(SubCategory shopByCategoryData,
      int currentNavigationIndex, context, List<ProductData>? list) {
    currentIndex = currentNavigationIndex;
    add(ShopByCategoryLoadingEvent());
    // subCategoryList.clear();
    print("filterData ${shopByCategoryData.subCategories!.length}");
    for (var filterData in shopByCategoryData.subCategories!) {
      print("filterData ${filterData.name}");
      subCategoryList.add(filterData);
    }
    // print("filterData ${subCategoryList.length}");

    callingApi(shopByCategoryData.categoryId!, "2", context);

    add(ShopByCategoryLoadedEvent(category!.subCategories!, list!,
        shopByCategoryData.subCategories!, currentIndex));
  }*/
  void refreshingFilter(SubCategory shopByCategoryData,
      int currentNavigationIndex, context, List<ProductData>? list) {
    currentIndex = currentNavigationIndex;
    add(ShopByCategoryLoadingEvent());
    subCategoryList = shopByCategoryData.subCategories ?? [];

    if (subCategoryList.isNotEmpty) {
      callingApi(subCategoryList[0].categoryId!, "2", context);
    }
    // filterLists.clear();
    // // filterLists.add(SubCategory(name: "Sort"));
    // for (var filterData in shopByCategoryData.subCategories!) {
    //   filterLists.add(filterData);
    // }
    add(ShopByNullEvent());
    // add(ShopByCategoryLoadedEvent(category!.subCategories!, list!,
    //     shopByCategoryData.subCategories!, currentIndex));
  }

  void optionDialog(
      context, List<ProductUnit> similarUnits, ProductUnit selectedUnit) {
    if (selectedUnit.sku == similarUnits[0].sku) {
    } else {
      selectedUnit = similarUnits[0];
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: Sizeconfig.getHeight(context) * 0.1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: MediaQuery.of(context).size.width,
          height: ((similarUnits.length + 1) *
              (Sizeconfig.getWidth(context) * 0.2)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 60,
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: ColorName.ColorPrimary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  ),
                ),
                child: Row(
                  children: [
                    Spacer(),
                    Text(
                      StringContants.lbl_pack_size,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Constants.SizeMidium,
                        fontFamily: Fontconstants.fc_family_sf,
                        fontWeight: Fontconstants.SF_Pro_Display_Medium,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.close))
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: similarUnits.length,
                itemBuilder: (context, quantityItemIndex) {
                  ProductUnit similarUnit = similarUnits[quantityItemIndex];
                  double specialPrice = 0.0;
                  String specialPriceStr = "";

                  if (similarUnit.specialPrice != null &&
                      similarUnit.specialPrice != "" &&
                      similarUnit.price != null &&
                      similarUnit.price != "") {
                    specialPrice = double.parse(similarUnit.specialPrice!);
                    specialPriceStr = specialPrice.toStringAsFixed(2);
                  }

                  double price = double.parse(similarUnit.price!);
                  String priceStr = price.toStringAsFixed(2);

                  return GestureDetector(
                    onTap: () {
                      quantityIndex = quantityItemIndex;

                      // Update the selectedUnit and selectedIndex
                      similarUnit.selectedQuantity =
                          similarUnit.productWeight.toString() +
                              " " +
                              similarUnit.productWeightUnit!;
                      similarUnit.addQuantity = 0;
                      add(WeightChangeEvent(similarUnit, quantityIndex));
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: similarUnit == selectedUnit
                            ? ColorName.lightPink
                            : ColorName.ColorBagroundPrimary,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      margin: EdgeInsets.all(10.0),
                      height: Sizeconfig.getWidth(context) * 0.15,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "${similarUnit.productWeight} ${similarUnit.productWeightUnit!.toLowerCase()}",
                              style: TextStyle(
                                fontSize: Constants.SizeSmall,
                                fontFamily: Fontconstants.fc_family_sf,
                                fontWeight: Fontconstants.Poppins_SemiBold,
                                color: ColorName.black,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                specialPriceStr.isEmpty
                                    ? Constants.ruppessymbol + " 0.0"
                                    : Constants.ruppessymbol +
                                        " " +
                                        specialPriceStr,
                                style: TextStyle(
                                  fontSize: Constants.Sizelagre,
                                  fontFamily: Fontconstants.fc_family_sf,
                                  fontWeight: Fontconstants.SF_Pro_Display_Bold,
                                  color: ColorName.black,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                priceStr,
                                style: TextStyle(
                                  fontSize: Constants.SizeSmall,
                                  fontFamily: Fontconstants.fc_family_sf,
                                  fontWeight:
                                      Fontconstants.SF_Pro_Display_Medium,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: ColorName.textlight,
                                  color: ColorName.textlight,
                                ),
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
