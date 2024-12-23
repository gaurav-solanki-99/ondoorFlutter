import 'package:equatable/equatable.dart';
import 'package:ondoor/models/AllProducts.dart';

import '../../../models/shop_by_category_response.dart';

class ProductDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProductDetailInitialState extends ProductDetailState {
  @override
  List<Object?> get props => [];
}

class ProductDetailLoadingState extends ProductDetailState {
  @override
  List<Object?> get props => [];
}

class ProductDetailScrollState extends ProductDetailState {
  double scrollOffset;
  @override
  List<Object?> get props => [];
  ProductDetailScrollState({required this.scrollOffset});
}

class ProductDetailNullState extends ProductDetailState {
  @override
  List<Object?> get props => [];
  ProductDetailNullState();
}

class ProductDetailLoadedState extends ProductDetailState {
  ProductUnit dummyData;

  bool isviewMoreEnabled = false;
  int currentIndex = 0;
  int imageIndex;

  ProductDetailLoadedState(this.dummyData, this.isviewMoreEnabled,
      this.currentIndex, this.imageIndex);
  @override
  List<Object?> get props => [dummyData, isviewMoreEnabled];
}

class UpdateImageIndexState extends ProductDetailState {
  int imageIndex;
  UpdateImageIndexState({required this.imageIndex});
}
