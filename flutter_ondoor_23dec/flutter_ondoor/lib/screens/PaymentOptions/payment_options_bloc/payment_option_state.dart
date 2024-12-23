import 'package:equatable/equatable.dart';
import 'package:flutter/animation.dart';
import 'package:ondoor/models/ShippingCharges.dart';
import 'package:ondoor/models/address_list_response.dart';
import 'package:ondoor/models/save_order_to_database_response.dart';

class PaymentOptionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PaymentOptionInitialState extends PaymentOptionState {
  @override
  List<Object?> get props => [];
}

class PaymentOptionAddressChangeState extends PaymentOptionState {
  AddressData selectedAddressData;
  @override
  List<Object?> get props => [selectedAddressData];
  PaymentOptionAddressChangeState({required this.selectedAddressData});
}

class PaymentOptionAnimationState extends PaymentOptionState {
  Animation<double> shrinkAnimation;
  @override
  List<Object?> get props => [shrinkAnimation];
  PaymentOptionAnimationState({required this.shrinkAnimation});
}

class PaymentOptionNullState extends PaymentOptionState {
  @override
  List<Object?> get props => [];
}

class PaymentStatusState extends PaymentOptionState {
  SaveOrdertoDatabaseResponse saveOrdertoDatabaseResponse;

  @override
  List<Object?> get props => [saveOrdertoDatabaseResponse];
  PaymentStatusState({required this.saveOrdertoDatabaseResponse});
}

class PaymentOptionSelectedState extends PaymentOptionState {
  PaymentGetway selectedPaymentGateway;
  @override
  List<Object?> get props => [selectedPaymentGateway];
  PaymentOptionSelectedState({required this.selectedPaymentGateway});
}

class PaymentOptionSuccessState extends PaymentOptionState {
  final SaveOrdertoDatabaseResponse resjsondata;

  @override
  List<Object?> get props => [resjsondata];
  PaymentOptionSuccessState({required this.resjsondata});
}

class PaymentOptionFailureState extends PaymentOptionState {
  SaveOrdertoDatabaseResponse saveOrdertoDatabaseResponse;

  @override
  List<Object?> get props => [saveOrdertoDatabaseResponse];
  PaymentOptionFailureState({required this.saveOrdertoDatabaseResponse});
}
