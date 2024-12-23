import 'package:equatable/equatable.dart';
import 'package:ondoor/models/contact_us_reason_list_response.dart';
import 'package:ondoor/models/get_latest_order_response.dart';

class ContactUsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ContactUsInitialEvent extends ContactUsEvent {
  ContactUsInitialEvent();
  @override
  List<Object?> get props => [];
}

class ContactUsLoadingEvent extends ContactUsEvent {
  @override
  List<Object?> get props => [];
}

class First_Reason_Selected_Event extends ContactUsEvent {
  ContactUsReasonCategory selectedCategory;
  First_Reason_Selected_Event({required this.selectedCategory});
  @override
  List<Object?> get props => [selectedCategory];
}

class Second_Reason_Selected_Event extends ContactUsEvent {
  ContactUsReasonSubCategory selectedSubCategory;
  Second_Reason_Selected_Event({required this.selectedSubCategory});
  @override
  List<Object?> get props => [selectedSubCategory];
}

class Order_ID_Selected_Event extends ContactUsEvent {
  LatestOrderData selectedOrderData;
  Order_ID_Selected_Event({required this.selectedOrderData});
  @override
  List<Object?> get props => [selectedOrderData];
}
