import 'package:equatable/equatable.dart';
import 'package:ondoor/models/get_shopping_list_response.dart';

class ShoppingListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ShoppingListInitialState extends ShoppingListState {
  @override
  List<Object?> get props => [];
}

class ShoppingListLoadingState extends ShoppingListState {
  @override
  List<Object?> get props => [];
}

class ShoppingListLoadedState extends ShoppingListState {
  List<Shoppinglist> shoppinglist;
  ShoppingListLoadedState({required this.shoppinglist});
  @override
  List<Object?> get props => [shoppinglist];
}
