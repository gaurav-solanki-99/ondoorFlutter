import 'package:equatable/equatable.dart';
import 'package:ondoor/models/contact_us_reason_list_response.dart';
import 'package:ondoor/models/get_latest_order_response.dart';
import 'package:ondoor/screens/contact_us_screen/contact_us_bloc/contact_us_event.dart';

class ContactUsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ContactUsInitialState extends ContactUsState {}

class ContactUsLoadingState extends ContactUsState {
  @override
  List<Object?> get props => [];
}

class First_Reason_Selected_State extends ContactUsState {
  ContactUsReasonCategory selectedCategory;
  First_Reason_Selected_State({required this.selectedCategory});
  @override
  List<Object?> get props => [selectedCategory];
}

class Second_Reason_Selected_State extends ContactUsState {
  ContactUsReasonSubCategory selectedSubCategory;
  Second_Reason_Selected_State({required this.selectedSubCategory});
  @override
  List<Object?> get props => [selectedSubCategory];
}

class Order_ID_Selected_State extends ContactUsState {
  LatestOrderData selectedOrderData;
  Order_ID_Selected_State({required this.selectedOrderData});
  @override
  List<Object?> get props => [selectedOrderData];
}
