import 'package:flutter_bloc/flutter_bloc.dart';
import 'card_event.dart';
import 'card_state.dart';

class CardBloc extends Bloc<CardEvent, CardState> {
  CardBloc() : super(CardInitial()) {
    on<CardEvent>((event, emit) {});

    on<AddCardEvent>((event, emit) {
      emit(AddCardState(count: event.count));
    });

    on<AddCardProductEvent>((event, emit) {
      emit(AddCardProductState(listProduct: event.listProduct));
    });

    on<AddCardOrderProductEvent>((event, emit) {
      emit(AddCardOrderProductState(listProduct: event.listProduct));
    });

    on<CardUpdateQuantityEvent>((event, emit) {
      emit(CardUpdateQuanitiyState(
          quantity: event.quantity,
          index: event.index,
          listProduct: event.listProduct));
    });

    on<CardDeleteEvent>((event, emit) {
      emit(
          CardDeleteSatate(model: event.model, listProduct: event.listProduct));
    });

    on<CardEmptyEvent>((event, emit) {
      emit(CardEmptyState());
    });
    on<CardNullEvent>((event, emit) {
      emit(CardNullState());
    });
    on<CardLoadStopEvent>((event, emit) {
      emit(CardLoadStopState());
    });
    on<CardWarningShowEvent>((event, emit) {
      emit(CardWarningShowState(show: event.show));
    });
    on<CardOfferAppliedEvent>((event, emit) {
      emit(CardOfferAppliedState(showApplied: event.showApplied));
    });

    on<CardAddcOfferProdutsEvent>((event, emit) {
      emit(CardAddcOfferProdutsState(unit: event.unit));
    });

    on<CardValidationLoadEvent>((event, emit) {
      emit(CardValidationLoadState(validationload: event.validationload));
    });

    on<CardCheckboxEvent>((event, emit) {
      emit(CardCheckboxState(status: event.status, index: event.index));
    });

    on<CardViewMoreEvent>((event, emit) {
      emit(CardViewMoreState(status: event.status));
    });
  }
}
