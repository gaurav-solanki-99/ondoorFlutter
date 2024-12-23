import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:ondoor/constants/StringConstats.dart';
import 'package:ondoor/database/database_helper.dart';

import '../../../models/AllProducts.dart';
import '../../../services/ApiServices.dart';
import '../../../utils/Connection.dart';
import 'featured_event.dart';
import 'featured_state.dart';

class FeaturedBloc extends Bloc<FeaturedEvent, FeaturedState> {
  FeaturedBloc() : super(FeaturedInitial()) {
    on<LoadingFeaturedEvent>((event, emit) async {
      debugPrint("Event Tag " + event.title.toString());
      emit(LodingFeatruedState());
      if (await Network.isConnected()) {
        List<ProductData>? list;

        if (event.title.contains(StringContants.lbl_bannersprodcut)) {
          debugPrint("Banner Product Api here ");

          ApiProvider()
              .getBannerProducts(event.title
                  .replaceAll(StringContants.lbl_bannersprodcut, "")
                  .replaceAll(" ", ""))
              .then((value) async {
            final responseData = jsonDecode(value.toString());
            if (responseData['success'] != false) {
              ProductsModel productsModel =
                  ProductsModel.fromJson(value.toString());
              list = productsModel.data;

              add(LoadedFeaturedEvent(list: list));
            } else {
              add(ProductListEmptyEvent());
            }
          });
        } else {
          ApiProvider().getFeaturedProduct(event.title).then((value) async {
            debugPrint(
                "Features Product Listing " + value.data!.length.toString());
            list = value.data;
            add(LoadedFeaturedEvent(list: list));
          });
        }
      } else {}
    });

    on<LoadedFeaturedEvent>((event, emit) {
      emit(LoadedFeaturedState(list: event.list));
    });

    on<LoadedUnitEvent>((event, emit) {
      emit(LoadedUnitState(list: event.list));
    });
    on<LoadedOrderSummaryEvent>((event, emit) {
      emit(LoadedOrderSummaryState(
          listProducSummary: event.listProducSummary,
          backgroundColor: event.backgroundColor,
          backgroundImage: event.backgroundImage,
          appbarTitle: event.appbarTitle,
          appbarTitleColor: event.appbarTitleColor));
    });

    on<ProductListEmptyEvent>((event, emit) {
      emit(ProductListEmptyState());
    });
    on<LodingEvent>((event, emit) {
      emit(LodingState());
    });

    on<ProductUpdateQuantityEvent>((event, emit) {
      emit(ProductUpdateQuantityState(
          quanitity: event.quanitity, index: event.index));
    });

    on<ProductUpdateQuantityEventBYModel>((event, emit) {
      emit(ProductUpdateQuantityStateBYModel(
        model: event.model,
      ));
    });

    on<ProductUpdateQuantityInitial>((event, emit) {
      emit(ProductUpdateQuantityInitialState(list: event.list));
    });
    on<OfferRowEvent>((event, emit) {
      emit(OfferRowState(row: event.row, status: event.status));
    });

    on<ProductChangeEvent>((event, emit) {
      emit(ProductChangeState(model: event.model));
    });
    on<SearchHistroryEvent>((event, emit) {
      emit(SearchHistroryState(searchHistoryList: event.searchHistoryList));
    });
    on<ProductUnitUpddate>((event, emit) {
      emit(ProductUnitUpddateState());
    });
    on<ProductUnitEvent>((event, emit) {
      emit(ProductUnitState(unit: event.unit));
    });
    on<FeaturedEmptyEvent>((event, emit) {
      emit(FeaturedEmptyState());
    });
    on<ProductNullEvent>((event, emit) {
      emit(ProductNullState());
    });

    on<ProductForShopByEvent>((event, emit) {
      emit(ProductForShopByState(list: event.list));
    });
    on<ProductLoadMoreEvent>((event, emit) {
      emit(ProductLoadMoreState(index: event.index, loadmore: event.loadmore));
    });

    on<ShopByFilterdEvent>((event, emit) {
      emit(ShopByFilterdState(filterdlist: event.filterdlist));
    });

    on<ProductForPaginationEvent>((event, emit) {
      emit(ProductForPaginationState(list: event.list, index: event.index));
    });

    on<ProductInitialSummaryEvent>((event, emit) {
      emit(ProductInitialSummaryState(
          list: event.list, index: event.index, loadmore: event.loadmore));
    });
    on<OldListEvent>((event, emit) {
      emit(OldListState(list: event.list));
    });
  }
}
