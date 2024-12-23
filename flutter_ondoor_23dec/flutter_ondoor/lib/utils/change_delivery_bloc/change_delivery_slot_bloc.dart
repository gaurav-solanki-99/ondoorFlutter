import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondoor/utils/change_delivery_bloc/change_delivery_slot_event.dart';
import 'package:ondoor/utils/change_delivery_bloc/change_delivery_slot_state.dart';

class ChangeDeliverySlotBloc
    extends Bloc<ChangeDeliverySlotEvent, ChangeDeliverySlotState> {
  ChangeDeliverySlotBloc() : super(ChangeDeliveryInitialState()) {
    on<ChangeDeliveryInitialEvent>(
      (event, emit) {
        emit(ChangeDeliveryInitialState());
      },
    );
    on<ChangeDeliverySlotSelectedDateEvent>(
      (event, emit) {
        emit(ChangeDeliverySlotSelectedDateState(
            selectedDate: event.selectedDate));
      },
    );
    on<ChangeDeliverySlotSelectedTimeEvent>(
      (event, emit) {
        emit(ChangeDeliverySlotSelectedTimeState(
            selectedTimeSlot: event.selectedTimeSlot));
      },
    );
  }
}
