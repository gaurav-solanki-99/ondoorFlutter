import 'package:equatable/equatable.dart';
import 'package:ondoor/models/GetTimeSlotsResponse.dart';
import '../../../models/AllProducts.dart';

class CheckoutState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {}

class CheckoutPriceUpdateState extends CheckoutState {
  double subtotoal = 0;
  double subtotoalcross = 0;

  CheckoutPriceUpdateState(
      {required this.subtotoal, required this.subtotoalcross});
  @override
  List<Object?> get props => [subtotoal, subtotoalcross];
}

class CheckoutNullState extends CheckoutState {
  CheckoutNullState();
  @override
  List<Object?> get props => [];
}

class CheckoutSeeAllState extends CheckoutState {
  int cartListLength;
  CheckoutSeeAllState({required this.cartListLength});
  @override
  List<Object?> get props => [cartListLength];
}

class CheckoutShipingAmountState extends CheckoutState {
  bool isShow = false;
  double shippingCharges = 0;
  double freeDeliveryAmount = 0;

  CheckoutShipingAmountState({
    required this.isShow,
    required this.shippingCharges,
    required this.freeDeliveryAmount,
  });
  @override
  List<Object?> get props => [isShow, shippingCharges, freeDeliveryAmount];
}

class TimeSlotSelectedState extends CheckoutState {
  String selectedTimeSlot;
  String selectedDateSlot;
  String selected_date_Text;
  TimeSlotSelectedState({
    required this.selectedTimeSlot,
    required this.selectedDateSlot,
    required this.selected_date_Text,
  });
  @override
  List<Object?> get props =>
      [selectedTimeSlot, selectedDateSlot, selected_date_Text];
}

class CheckoutShippingLoadState extends CheckoutState {
  @override
  List<Object?> get props => [/*isShow, shippingCharges, freeDeliveryAmount*/];
}

class GetTimeSlotState extends CheckoutState {
  GetTimeSlotResponse timeSlotResponse;
  @override
  List<Object?> get props => [timeSlotResponse];
  GetTimeSlotState({required this.timeSlotResponse});
}

class GetTimeSlotErrorState extends CheckoutState {
  GetTimeSlotResponse timeSlotResponse;
  @override
  List<Object?> get props => [timeSlotResponse];
  GetTimeSlotErrorState({required this.timeSlotResponse});
}

class GetAddressState extends CheckoutState {
  String street;
  String locality;
  GetAddressState({required this.street, required this.locality});
  @override
  List<Object?> get props => [street, locality];
}
