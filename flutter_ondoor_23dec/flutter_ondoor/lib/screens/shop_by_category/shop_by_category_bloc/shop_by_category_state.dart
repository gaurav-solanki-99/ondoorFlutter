part of 'shop_by_category_bloc.dart';

class ShopByCategoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ShopByCategoryInitialState extends ShopByCategoryState {
  @override
  List<Object?> get props => [];
}

class ShopByCategoryLoadingState extends ShopByCategoryState {
  @override
  List<Object?> get props => [];
}

class FilterState extends ShopByCategoryState {
  bool isFilterOn;
  String selected_Filter;

  FilterState({required this.isFilterOn, required this.selected_Filter});
  @override
  List<Object?> get props => [isFilterOn, selected_Filter];
}

class ShopByCategoryLoadedState extends ShopByCategoryState {
  final List<SubCategory> categoryList;
  final List<SubCategory> subCategoryList;
  List<ProductData> unitList = [];

  int selectedIndex = 0;
  ShopByCategoryLoadedState(this.categoryList, this.subCategoryList,
      this.unitList, this.selectedIndex);
  @override
  List<Object?> get props =>
      [categoryList, subCategoryList, unitList, selectedIndex];
}

class ShopByCategoryTabChangeState extends ShopByCategoryState {
  int tabIndex;
  ShopByCategoryTabChangeState({required this.tabIndex});
  @override
  List<Object?> get props => [tabIndex];
}

class SectorChangeState extends ShopByCategoryState {
  Category selectedCategory;
  List<Category> categoryList;
  SectorChangeState(this.selectedCategory, this.categoryList);
  @override
  List<Object?> get props => [selectedCategory, categoryList];
}

// class AddtoCartState extends ShopByCategoryState {
//   List<ProductUnit> unit;
//   int selectedIndex = 0;
//   ProductUnit unitData;
//   AddtoCartState(this.unit, this.selectedIndex, this.unitData);
//   @override
//   List<Object?> get props => [unit, selectedIndex];
// }

class WeightChangeState extends ShopByCategoryState {
  ProductUnit unit;
  int selectedIndex = 0;

  WeightChangeState(
      this.unit, this.selectedIndex /*, this.filterList, this.selectedIndex*/);
  @override
  List<Object?> get props =>
      [unit, selectedIndex /*, filterList, selectedIndex*/];
}

class QuantityChangeState extends ShopByCategoryState {
  final List<ProductUnit> dummyList;
  final List<SubCategory> categoryList;
  final List<SubCategory> filterList;

  int count;
  int selectedIndex = 0;

  QuantityChangeState(this.categoryList, this.dummyList, this.filterList,
      this.count, this.selectedIndex);
  @override
  List<Object?> get props =>
      [categoryList, dummyList, filterList, count, selectedIndex];
}

class ShopByCategoryErrorState extends ShopByCategoryState {
  String errorMessage;
  ShopByCategoryErrorState(this.errorMessage);
  @override
  List<Object?> get props => [errorMessage];
}

class ShopbyProductUpdateQuantityState extends ShopByCategoryState {
  ProductUnit model;
  List<ProductUnit> unitList;
  int index;
  ShopbyProductUpdateQuantityState(
      {required this.model, required this.unitList, required this.index});
}

class NoInternetState extends ShopByCategoryState {}

class ShopbyProductChangeState extends ShopByCategoryState {
  ProductUnit model;
  ShopbyProductChangeState({required this.model});
}

class ShopByNullState extends ShopByCategoryState {}

class ShopbyUpdateUnitState extends ShopByCategoryState {
  ProductUnit model;
  int index;
  ShopbyUpdateUnitState({required this.model, required this.index});
}

class SearchAnimatedState extends ShopByCategoryState {
  double height;
  SearchAnimatedState({required this.height});
}
