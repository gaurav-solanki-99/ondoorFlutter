import 'package:equatable/equatable.dart';
import 'package:ondoor/models/get_shopping_list_response.dart';

class ShoppingListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ShoppingListInitialEvent extends ShoppingListEvent {
  @override
  List<Object?> get props => [];
}

class ShoppingListLoadingEvent extends ShoppingListEvent {
  @override
  List<Object?> get props => [];
}

class ShoppingListLoadedEvent extends ShoppingListEvent {
  List<Shoppinglist> shoppinglist;
  ShoppingListLoadedEvent({required this.shoppinglist});
  @override
  List<Object?> get props => [shoppinglist];
}
