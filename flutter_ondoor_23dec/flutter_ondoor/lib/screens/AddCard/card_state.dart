import '../../models/AllProducts.dart';

abstract class CardState {}

final class CardInitial extends CardState {}

class AddCardState extends CardState {
  int count;
  AddCardState({required this.count});
}

class AddCardProductState extends CardState {
  List<ProductUnit> listProduct;
  AddCardProductState({required this.listProduct});
}

class AddCardOrderProductState extends CardState {
  List<ProductUnit> listProduct;
  AddCardOrderProductState({required this.listProduct});
}

class CardUpdateQuanitiyState extends CardState {
  int quantity;
  int index;
  List<ProductUnit> listProduct;
  CardUpdateQuanitiyState(
      {required this.quantity, required this.index, required this.listProduct});
}

class CardDeleteSatate extends CardState {
  ProductUnit model;
  List<ProductUnit> listProduct;
  CardDeleteSatate({required this.model, required this.listProduct});
}

class CardEmptyState extends CardState {}

class CardNullState extends CardState {}

class CardLoadStopState extends CardState {}

class CardWarningShowState extends CardState {
  bool show;
  CardWarningShowState({required this.show});
}

class CardOfferAppliedState extends CardState {
  bool showApplied;
  CardOfferAppliedState({required this.showApplied});
}

class CardAddcOfferProdutsState extends CardState {
  ProductUnit unit;
  CardAddcOfferProdutsState({required this.unit});
}

class CardValidationLoadState extends CardState {
  bool validationload;
  CardValidationLoadState({required this.validationload});
}

class CardCheckboxState extends CardState {
  bool status;
  int index;
  CardCheckboxState({required this.status, required this.index});
}

class CardViewMoreState extends CardState {
  bool status;
  CardViewMoreState({required this.status});
}
