import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ondoor/models/ShippingCharges.dart';
import 'package:ondoor/models/save_order_to_database_response.dart';

import '../../../models/address_list_response.dart';
import '../../../models/paytm_checksum_response.dart';

class PaymentOptionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PaymentOptionInitialEvent extends PaymentOptionEvent {
  @override
  List<Object?> get props => [];
}

class PaymentOptionNullEvent extends PaymentOptionEvent {
  @override
  List<Object?> get props => [];
}

class PaymentOptionAnimationEvent extends PaymentOptionEvent {
  Animation<double> shrinkAnimation;
  @override
  List<Object?> get props => [shrinkAnimation];
  PaymentOptionAnimationEvent({required this.shrinkAnimation});
}

class PaymentStatusEvent extends PaymentOptionEvent {
  SaveOrdertoDatabaseResponse saveOrdertoDatabaseResponse;
  @override
  List<Object?> get props => [saveOrdertoDatabaseResponse];
  PaymentStatusEvent({required this.saveOrdertoDatabaseResponse});
}

class PaymentOptionSelectedEvent extends PaymentOptionEvent {
  PaymentGetway selectedPaymentGateway;
  @override
  List<Object?> get props => [selectedPaymentGateway];
  PaymentOptionSelectedEvent({required this.selectedPaymentGateway});
}

class PaymentOptionSuccessEvent extends PaymentOptionEvent {
  final SaveOrdertoDatabaseResponse resjsondata;
  final PaytmChecksumresponse checksumResponse;
  BuildContext context;
  String finalAddress;
  Map<dynamic, dynamic> paytmData;
  String selectedTimeSlot;
  String selectedDateSlot;
  String callbackUrl;
  @override
  List<Object?> get props => [
        resjsondata,
        context,
        paytmData,
        checksumResponse,
        finalAddress,
        selectedTimeSlot,
        callbackUrl,
        selectedDateSlot
      ];
  PaymentOptionSuccessEvent(
      {required this.resjsondata,
      required this.context,
      required this.paytmData,
      required this.checksumResponse,
      required this.finalAddress,
      required this.callbackUrl,
      required this.selectedTimeSlot,
      required this.selectedDateSlot});
}

class PaymentOptionAddressChangeEvent extends PaymentOptionEvent {
  AddressData selectedAddressData;
  @override
  List<Object?> get props => [selectedAddressData];
  PaymentOptionAddressChangeEvent({required this.selectedAddressData});
}

class InitilizedPaytmPaymentEvent extends PaymentOptionEvent {
  final SaveOrdertoDatabaseResponse resjsondata;
  BuildContext context;
  String finalAddress;
  String selectedTimeSlot;
  String selectedDateSlot;
  @override
  List<Object?> get props =>
      [resjsondata, context, finalAddress, selectedTimeSlot, selectedDateSlot];
  InitilizedPaytmPaymentEvent(
      {required this.resjsondata,
      required this.context,
      required this.finalAddress,
      required this.selectedTimeSlot,
      required this.selectedDateSlot});
}

class PaymentOptionFailureEvent extends PaymentOptionEvent {
  SaveOrdertoDatabaseResponse saveOrdertoDatabaseResponse;
  @override
  List<Object?> get props => [saveOrdertoDatabaseResponse];
  PaymentOptionFailureEvent({required this.saveOrdertoDatabaseResponse});
}
