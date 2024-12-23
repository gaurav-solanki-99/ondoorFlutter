import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondoor/screens/contact_us_screen/contact_us_bloc/contact_us_event.dart';
import 'package:ondoor/screens/contact_us_screen/contact_us_bloc/contact_us_state.dart';

class Contact_Us_Bloc extends Bloc<ContactUsEvent, ContactUsState> {
  Contact_Us_Bloc() : super(ContactUsInitialState()) {
    on<ContactUsInitialEvent>((event, emit) => emit(ContactUsInitialState()));
    on<ContactUsLoadingEvent>((event, emit) => emit(ContactUsLoadingState()));
    on<First_Reason_Selected_Event>((event, emit) => emit(
        First_Reason_Selected_State(selectedCategory: event.selectedCategory)));
    on<Second_Reason_Selected_Event>((event, emit) => emit(
        Second_Reason_Selected_State(
            selectedSubCategory: event.selectedSubCategory)));
    on<Order_ID_Selected_Event>((event, emit) => emit(
        Order_ID_Selected_State(selectedOrderData: event.selectedOrderData)));
  }
}
