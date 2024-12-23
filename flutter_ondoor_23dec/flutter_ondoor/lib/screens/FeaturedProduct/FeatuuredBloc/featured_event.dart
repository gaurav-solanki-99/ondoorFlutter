import 'package:ondoor/models/AllProducts.dart';

import '../../../models/OrderSummaryProducts.dart';
import '../../HomeScreen/HomeBloc/TopSellingBloc/top_selling_event.dart';

abstract class FeaturedEvent {}

class LoadingFeaturedEvent extends FeaturedEvent {
  String title;
  LoadingFeaturedEvent({required this.title});
}

class LoadedFeaturedEvent extends FeaturedEvent {
  List<ProductData>? list;
  LoadedFeaturedEvent({required this.list});
}

class LoadedUnitEvent extends FeaturedEvent {
  List<ProductUnit>? list;
  LoadedUnitEvent({required this.list});
}

class LodingEvent extends FeaturedEvent {}

class LoadedOrderSummaryEvent extends FeaturedEvent {
  List<OrderSummaryProductsDatum> listProducSummary;
  String backgroundColor;
  String backgroundImage;
  String appbarTitle;
  String appbarTitleColor;
  LoadedOrderSummaryEvent(
      {required this.listProducSummary,
      required this.backgroundColor,
      required this.backgroundImage,
      required this.appbarTitle,
      required this.appbarTitleColor});
}

class ProductUpdateQuantityEvent extends FeaturedEvent {
  int quanitity;
  int index;
  ProductUpdateQuantityEvent({required this.quanitity, required this.index});
}

class ProductUpdateQuantityInitial extends FeaturedEvent {
  List<ProductData>? list;
  ProductUpdateQuantityInitial({required this.list});
}

class ProductUpdateQuantityEventBYModel extends FeaturedEvent {
  ProductUnit model;
  ProductUpdateQuantityEventBYModel({required this.model});
}

class OfferRowEvent extends FeaturedEvent {
  bool status;
  int row;
  OfferRowEvent({required this.row, required this.status});
}

class ProductChangeEvent extends FeaturedEvent {
  ProductUnit model;
  ProductChangeEvent({required this.model});
}

class SearchHistroryEvent extends FeaturedEvent {
  List<String> searchHistoryList = [];
  SearchHistroryEvent({required this.searchHistoryList});
}

class ProductListEmptyEvent extends FeaturedEvent {}

class ProductNullEvent extends FeaturedEvent {}

class ProductUnitUpddate extends FeaturedEvent {}

class FeaturedEmptyEvent extends FeaturedEvent {}

class ProductUnitEvent extends FeaturedEvent {
  ProductUnit unit;
  ProductUnitEvent({required this.unit});
}

class ProductForShopByEvent extends FeaturedEvent {
  List<ProductData>? list;
  ProductForShopByEvent({required this.list});
}

class ShopByFilterdEvent extends FeaturedEvent {
  List<ProductData> filterdlist;
  ShopByFilterdEvent({required this.filterdlist});
}

class ProductForPaginationEvent extends FeaturedEvent {
  List<ProductData>? list;
  int index;
  ProductForPaginationEvent({required this.list, required this.index});
}

class OldListEvent extends FeaturedEvent {
  List<ProductData>? list;
  OldListEvent({required this.list});
}

class ProductLoadMoreEvent extends FeaturedEvent {
  int index;
  bool loadmore;

  ProductLoadMoreEvent({required this.index, required this.loadmore});
}

class ProductInitialSummaryEvent extends FeaturedEvent {
  List<ProductData>? list;
  int index;
  bool loadmore;

  ProductInitialSummaryEvent(
      {required this.list, required this.index, required this.loadmore});
}
