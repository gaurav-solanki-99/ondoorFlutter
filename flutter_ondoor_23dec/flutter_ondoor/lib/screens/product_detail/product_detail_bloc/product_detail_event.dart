import 'package:equatable/equatable.dart';

import '../../../models/AllProducts.dart';
import '../../../models/shop_by_category_response.dart';

class ProductDetailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProductDetailLoadingEvent extends ProductDetailEvent {
  @override
  List<Object?> get props => [];
}

class ProductDetailScrollEvent extends ProductDetailEvent {
  double scrollOffset;
  @override
  List<Object?> get props => [];
  ProductDetailScrollEvent({required this.scrollOffset});
}

class ProductDetailLoadedEvent extends ProductDetailEvent {
  ProductUnit dummyData;

  bool isviewMoreEnabled = false;
  int currentIndex = 0;
  int imageIndex = 0;
  ProductDetailLoadedEvent(this.dummyData, this.isviewMoreEnabled,
      this.currentIndex, this.imageIndex);
  @override
  List<Object?> get props => [dummyData, isviewMoreEnabled];
}

class UpdateIndexEvent extends ProductDetailEvent {
  int index;
  UpdateIndexEvent({required this.index});
}
