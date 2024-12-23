import 'package:equatable/equatable.dart';
import 'package:ondoor/models/AllProducts.dart';

class ShoppingListDetailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ShoppingListDetailInitialEvent extends ShoppingListDetailEvent {
  @override
  List<Object?> get props => [];
}

class ShoppingListDetailLoadingEvent extends ShoppingListDetailEvent {
  @override
  List<Object?> get props => [];
}

class ShoppingListDetailLoadedEvent extends ShoppingListDetailEvent {
  List<ProductUnit> data = [];
  @override
  List<Object?> get props => [];
  ShoppingListDetailLoadedEvent({required this.data});
}

class ProductChangeEvent extends ShoppingListDetailEvent {
  ProductUnit model;
  ProductChangeEvent({required this.model});
}

class ProductUpdateQuantityEvent extends ShoppingListDetailEvent {
  int quanitity;
  int index;
  ProductUpdateQuantityEvent({required this.quanitity, required this.index});
}
