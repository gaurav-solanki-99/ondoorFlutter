import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondoor/screens/product_detail/product_detail_bloc/product_detail_event.dart';
import 'package:ondoor/screens/product_detail/product_detail_bloc/product_detail_state.dart';

import '../../../constants/ImageConstants.dart';
import '../../../constants/StringConstats.dart';
import '../../../models/AllProducts.dart';
import '../../../models/TopProducts.dart';
import '../../../models/shop_by_category_response.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  List<String> quantityList = [];
  List<TopProducts> listTopProducts = [
    TopProducts(
        imageUrl: Imageconstants.img_featured,
        name: StringContants.lbl_featuredprod,
        quantitiy: 0),
    TopProducts(
        imageUrl: Imageconstants.img_heavydiscount,
        name: StringContants.lbl_heavydis,
        quantitiy: 0),
    TopProducts(
        imageUrl: Imageconstants.img_newarrivals,
        name: StringContants.lbl_newarr,
        quantitiy: 0),
    // TopProducts(imageUrl: Imageconstants.img_offers, name: StringContants.lbl_offrs),
  ];

  ProductUnit? dummyProductData;
  ProductDetailBloc() : super(ProductDetailInitialState()) {
    on<ProductDetailLoadingEvent>(
        (event, emit) => emit(ProductDetailLoadingState()));
    on<ProductDetailScrollEvent>(
      (event, emit) {
        emit(ProductDetailNullState());
        emit(ProductDetailScrollState(scrollOffset: event.scrollOffset));
      },
    );
    on<ProductDetailLoadedEvent>(
      (event, emit) {
        emit(ProductDetailLoadingState());
        emit(ProductDetailLoadedState(event.dummyData, event.isviewMoreEnabled,
            event.currentIndex, event.imageIndex));
      },
    );
  }
}
