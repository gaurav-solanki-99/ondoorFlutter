import 'package:equatable/equatable.dart';

class ChangeDeliverySlotState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChangeDeliveryInitialState extends ChangeDeliverySlotState {
  @override
  List<Object?> get props => [];
}

class ChangeDeliverySlotSelectedDateState extends ChangeDeliverySlotState {
  String selectedDate;
  @override
  List<Object?> get props => [selectedDate];
  ChangeDeliverySlotSelectedDateState({required this.selectedDate});
}

class ChangeDeliverySlotSelectedTimeState extends ChangeDeliverySlotState {
  String selectedTimeSlot;
  @override
  List<Object?> get props => [selectedTimeSlot];
  ChangeDeliverySlotSelectedTimeState({required this.selectedTimeSlot});
}
