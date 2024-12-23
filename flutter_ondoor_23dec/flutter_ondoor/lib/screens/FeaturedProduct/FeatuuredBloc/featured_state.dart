import '../../../models/AllProducts.dart';
import '../../../models/OrderSummaryProducts.dart';

abstract class FeaturedState {}

class LodingFeatruedState extends FeaturedState {}

final class FeaturedInitial extends FeaturedState {}

class LoadedFeaturedState extends FeaturedState {
  List<ProductData>? list;
  LoadedFeaturedState({required this.list});
}

class LoadedUnitState extends FeaturedState {
  List<ProductUnit>? list;
  LoadedUnitState({required this.list});
}

class LoadedOrderSummaryState extends FeaturedState {
  List<OrderSummaryProductsDatum>? listProducSummary;
  String backgroundColor;
  String backgroundImage;
  String appbarTitle;
  String appbarTitleColor;
  LoadedOrderSummaryState(
      {required this.listProducSummary,
      required this.backgroundColor,
      required this.backgroundImage,
      required this.appbarTitle,
      required this.appbarTitleColor});
}

class LodingState extends FeaturedState {}

class OfferRowState extends FeaturedState {
  bool status;
  int row;
  OfferRowState({required this.row, required this.status});
}

class ProductUnitState extends FeaturedState {
  ProductUnit unit;
  ProductUnitState({required this.unit});
}

class ProductNullState extends FeaturedState {}

class ProductUpdateQuantityState extends FeaturedState {
  int quanitity;
  int index;
  ProductUpdateQuantityState({required this.quanitity, required this.index});
}

class ProductUpdateQuantityInitialState extends FeaturedState {
  List<ProductData>? list;
  ProductUpdateQuantityInitialState({required this.list});
}

class ProductUpdateQuantityStateBYModel extends FeaturedState {
  ProductUnit model;
  ProductUpdateQuantityStateBYModel({required this.model});
}

class ProductChangeState extends FeaturedState {
  ProductUnit model;
  ProductChangeState({required this.model});
}

class SearchHistroryState extends FeaturedState {
  List<String> searchHistoryList = [];
  SearchHistroryState({required this.searchHistoryList});
}

class ProductListEmptyState extends FeaturedState {}

class ProductUnitUpddateState extends FeaturedState {}

class FeaturedEmptyState extends FeaturedState {}

class ProductForShopByState extends FeaturedState {
  List<ProductData>? list;
  ProductForShopByState({required this.list});
}

class ShopByFilterdState extends FeaturedState {
  List<ProductData> filterdlist;
  ShopByFilterdState({required this.filterdlist});
}

class ProductForPaginationState extends FeaturedState {
  List<ProductData>? list;
  int index;
  ProductForPaginationState({required this.list, required this.index});
}

class OldListState extends FeaturedState {
  List<ProductData>? list;
  OldListState({required this.list});
}

class ProductLoadMoreState extends FeaturedState {
  int index;
  bool loadmore;

  ProductLoadMoreState({required this.index, required this.loadmore});
}

class ProductInitialSummaryState extends FeaturedState {
  List<ProductData>? list;
  int index;
  bool loadmore;
  ProductInitialSummaryState(
      {required this.list, required this.index, required this.loadmore});
}
