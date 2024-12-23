import '../../models/AllProducts.dart';

abstract class CardEvent {}

class AddCardEvent extends CardEvent {
  int count;
  AddCardEvent({required this.count});
}

class AddCardProductEvent extends CardEvent {
  List<ProductUnit> listProduct;
  AddCardProductEvent({required this.listProduct});
}

class AddCardOrderProductEvent extends CardEvent {
  List<ProductUnit> listProduct;
  AddCardOrderProductEvent({required this.listProduct});
}

class CardUpdateQuantityEvent extends CardEvent {
  List<ProductUnit> listProduct;
  int quantity;
  int index;
  CardUpdateQuantityEvent(
      {required this.quantity, required this.index, required this.listProduct});
}

class CardDeleteEvent extends CardEvent {
  ProductUnit model;
  List<ProductUnit> listProduct;
  CardDeleteEvent({required this.model, required this.listProduct});
}

class CardEmptyEvent extends CardEvent {}

class CardNullEvent extends CardEvent {}

class CardLoadStopEvent extends CardEvent {}

class CardWarningShowEvent extends CardEvent {
  bool show;
  CardWarningShowEvent({required this.show});
}

class CardOfferAppliedEvent extends CardEvent {
  bool showApplied;
  CardOfferAppliedEvent({required this.showApplied});
}

class CardAddcOfferProdutsEvent extends CardEvent {
  ProductUnit unit;
  CardAddcOfferProdutsEvent({required this.unit});
}

class CardValidationLoadEvent extends CardEvent {
  bool validationload;
  CardValidationLoadEvent({required this.validationload});
}

class CardCheckboxEvent extends CardEvent {
  bool status;
  int index;
  CardCheckboxEvent({required this.status, required this.index});
}

class CardViewMoreEvent extends CardEvent {
  bool status;
  CardViewMoreEvent({required this.status});
}
