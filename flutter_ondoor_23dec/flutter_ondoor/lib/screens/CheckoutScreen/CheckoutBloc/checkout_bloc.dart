import 'package:bloc/bloc.dart';

import 'checkout_event.dart';
import 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  CheckoutBloc() : super(CheckoutInitial()) {
    on<CheckoutEvent>((event, emit) {
      emit(CheckoutInitial());
    });

    on<CheckoutPriceUpdateEvent>((event, emit) {
      emit(CheckoutInitial());
      emit(CheckoutPriceUpdateState(
          subtotoal: event.subtotoal, subtotoalcross: event.subtotoalcross));
    });
    on<CheckoutNullEvent>((event, emit) {
      emit(CheckoutInitial());
      emit(CheckoutNullState());
    });

    on<CheckoutShippingLoadEvent>((event, emit) {
      emit(CheckoutInitial());
      emit(CheckoutShippingLoadState());
    });
    on<GetTimeSlotEvent>((event, emit) {
      emit(CheckoutInitial());
      emit(GetTimeSlotState(timeSlotResponse: event.timeSlotResponse));
    });
    on<GetTimeSlotErrorEvent>((event, emit) {
      emit(CheckoutInitial());
      emit(GetTimeSlotErrorState(timeSlotResponse: event.timeSlotResponse));
    });

    on<GetAddressEvent>((event, emit) {
      emit(CheckoutInitial());
      emit(GetAddressState(street: event.street, locality: event.locality));
    });

    on<TimeSlotSelectedEvent>((event, emit) {
      emit(CheckoutInitial());
      emit(TimeSlotSelectedState(
          selectedDateSlot: event.selectedDateSlot,
          selectedTimeSlot: event.selectedTimeSlot,
          selected_date_Text: event.selected_date_Text));
    });

    on<CheckoutSeeAllEvent>((event, emit) {
      emit(CheckoutInitial());
      emit(CheckoutSeeAllState(cartListLength: event.cartListLength));
    });

    on<CheckoutShipingAmountEvent>((event, emit) {
      emit(CheckoutInitial());
      emit(CheckoutShipingAmountState(
          isShow: event.isShow,
          shippingCharges: event.shippingCharges,
          freeDeliveryAmount: event.freeDeliveryAmount));
    });
  }
}
