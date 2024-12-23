import 'package:equatable/equatable.dart';

class ChangeDeliverySlotEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChangeDeliveryInitialEvent extends ChangeDeliverySlotEvent {
  @override
  List<Object?> get props => [];
}

class ChangeDeliverySlotSelectedDateEvent extends ChangeDeliverySlotEvent {
  String selectedDate;
  @override
  List<Object?> get props => [selectedDate];
  ChangeDeliverySlotSelectedDateEvent({required this.selectedDate});
}

class ChangeDeliverySlotSelectedTimeEvent extends ChangeDeliverySlotEvent {
  String selectedTimeSlot;
  @override
  List<Object?> get props => [selectedTimeSlot];
  ChangeDeliverySlotSelectedTimeEvent({required this.selectedTimeSlot});
}
