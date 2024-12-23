import 'package:equatable/equatable.dart';
import 'package:ondoor/models/AllProducts.dart';

class ShoppingListDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ShoppingListDetailInitialState extends ShoppingListDetailState {
  @override
  List<Object?> get props => [];
}

class ShoppingListDetailLoadingState extends ShoppingListDetailState {
  @override
  List<Object?> get props => [];
}

class ShoppingListDetailLoadedState extends ShoppingListDetailState {
  List<ProductUnit> data = [];
  ShoppingListDetailLoadedState({required this.data});
  @override
  List<Object?> get props => [];
}

class ProductChangeState extends ShoppingListDetailState {
  ProductUnit model;
  ProductChangeState({required this.model});
}

class ProductUpdateQuantityState extends ShoppingListDetailState {
  int quanitity;
  int index;
  ProductUpdateQuantityState({required this.quanitity, required this.index});
}
