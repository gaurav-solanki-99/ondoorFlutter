import 'package:ondoor/models/AllProducts.dart';
import 'package:equatable/equatable.dart';

import '../../../models/GetTimeSlotsResponse.dart';

// abstract class CheckoutEvent {}

class CheckoutEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CheckoutPriceUpdateEvent extends CheckoutEvent {
  double subtotoal = 0;
  double subtotoalcross = 0;

  CheckoutPriceUpdateEvent(
      {required this.subtotoal, required this.subtotoalcross});
  @override
  List<Object?> get props => [subtotoal, subtotoalcross];
}

class CheckoutNullEvent extends CheckoutEvent {
  CheckoutNullEvent();
  @override
  List<Object?> get props => [];
}

class CheckoutSeeAllEvent extends CheckoutEvent {
  int cartListLength;
  CheckoutSeeAllEvent({required this.cartListLength});
  @override
  List<Object?> get props => [cartListLength];
}

class CheckoutShipingAmountEvent extends CheckoutEvent {
  bool isShow = false;
  double shippingCharges = 0;
  double freeDeliveryAmount = 0;

  CheckoutShipingAmountEvent(
      {required this.isShow,
      required this.shippingCharges,
      required this.freeDeliveryAmount});
  @override
  List<Object?> get props => [isShow, shippingCharges, freeDeliveryAmount];
}

class CheckoutShippingLoadEvent extends CheckoutEvent {}

class GetTimeSlotEvent extends CheckoutEvent {
  GetTimeSlotResponse timeSlotResponse;
  @override
  List<Object?> get props => [timeSlotResponse];
  GetTimeSlotEvent({required this.timeSlotResponse});
}

class GetTimeSlotErrorEvent extends CheckoutEvent {
  GetTimeSlotResponse timeSlotResponse;
  @override
  List<Object?> get props => [timeSlotResponse];
  GetTimeSlotErrorEvent({required this.timeSlotResponse});
}

class TimeSlotSelectedEvent extends CheckoutEvent {
  String selectedTimeSlot;
  String selectedDateSlot;
  String selected_date_Text;
  TimeSlotSelectedEvent({
    required this.selectedTimeSlot,
    required this.selectedDateSlot,
    required this.selected_date_Text,
  });
  @override
  List<Object?> get props =>
      [selectedTimeSlot, selectedDateSlot, selected_date_Text];
}

class GetAddressEvent extends CheckoutEvent {
  String street;
  String locality;
  GetAddressEvent({required this.street, required this.locality});
  @override
  List<Object?> get props => [street, locality];
}
