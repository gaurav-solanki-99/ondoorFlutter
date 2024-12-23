part of 'shop_by_category_bloc.dart';

class ShopByCategoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ShopByCategoryInitialEvent extends ShopByCategoryEvent {
  @override
  List<Object?> get props => [];
}

class ShopByCategoryLoadingEvent extends ShopByCategoryEvent {
  @override
  List<Object?> get props => [];
  ShopByCategoryLoadingEvent();
}

class SectorChangeEvent extends ShopByCategoryEvent {
  Category selectedCategory;
  List<Category> categoryList;
  SectorChangeEvent(this.selectedCategory, this.categoryList);
  @override
  List<Object?> get props => [selectedCategory, categoryList];
}

class ShopByCategoryLoadedEvent extends ShopByCategoryEvent {
  final List<SubCategory> categoryList;
  final List<SubCategory> subCategoryList;
  final List<ProductData> unitList;

  int selectedIndex = 0;

  ShopByCategoryLoadedEvent(
    this.categoryList,
    this.unitList,
    this.subCategoryList,
    this.selectedIndex,
  );
  @override
  List<Object?> get props =>
      [categoryList, subCategoryList, unitList, selectedIndex];
}

// class AddtoCartEvent extends ShopByCategoryEvent {
//   List<ProductUnit> unit;
//   final int selectedIndex;
//   ProductUnit unitData;
//   AddtoCartEvent(this.unit, this.selectedIndex, this.unitData);
//   @override
//   List<Object?> get props => [unit, selectedIndex];
// }

class QuantityChangeEvent extends ShopByCategoryEvent {
  final List<ProductUnit> dummyList;
  final List<SubCategory> categoryList;
  int selectedIndex = 0;
  final List<SubCategory> filterList;
  final int count;
  QuantityChangeEvent(this.categoryList, this.dummyList, this.filterList,
      this.count, this.selectedIndex);
  @override
  List<Object?> get props =>
      [categoryList, dummyList, filterList, count, selectedIndex];
}

class WeightChangeEvent extends ShopByCategoryEvent {
  ProductUnit unit;
  int selectedIndex = 0;
  // final List<SubCategory> filterList;
  WeightChangeEvent(this.unit, this.selectedIndex);
  @override
  List<Object?> get props => [unit, selectedIndex];
}

class ShopByCategoryErrorEvent extends ShopByCategoryEvent {
  String errorMessage;
  ShopByCategoryErrorEvent(this.errorMessage);
  @override
  List<Object?> get props => [errorMessage];
}

class ShopbyProductUpdateQuantityEvent extends ShopByCategoryEvent {
  ProductUnit model;
  List<ProductUnit> unitList;
  int index;
  ShopbyProductUpdateQuantityEvent(
      {required this.model, required this.unitList, required this.index});
}

class ShopbyProductChangeEvent extends ShopByCategoryEvent {
  ProductUnit model;
  ShopbyProductChangeEvent({required this.model});
}

class ShopByNullEvent extends ShopByCategoryEvent {}

class FilterEvent extends ShopByCategoryEvent {
  bool isFilterOn;
  String selected_Filter;
  FilterEvent({required this.isFilterOn, required this.selected_Filter});
  @override
  List<Object?> get props => [isFilterOn, selected_Filter];
}

class NoInternetEvent extends ShopByCategoryEvent {}

class ShopbyUpdateUnitEvent extends ShopByCategoryEvent {
  ProductUnit model;
  int index;
  ShopbyUpdateUnitEvent({required this.model, required this.index});
}

class ShopByCategoryTabChangeEvent extends ShopByCategoryEvent {
  int tabIndex;
  ShopByCategoryTabChangeEvent({required this.tabIndex});
  @override
  List<Object?> get props => [tabIndex];
}

class SearchAnimatedEvent extends ShopByCategoryEvent {
  double height;
  SearchAnimatedEvent({required this.height});
}
