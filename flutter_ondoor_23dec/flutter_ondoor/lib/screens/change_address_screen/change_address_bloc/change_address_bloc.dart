import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondoor/screens/change_address_screen/change_address_bloc/change_address_event.dart';
import 'package:ondoor/screens/change_address_screen/change_address_bloc/change_address_state.dart';

class ChangeAddressBloc extends Bloc<ChangeAddressEvent, ChangeAddressState> {
  ChangeAddressBloc() : super(FetchAddressInitialState()) {
    on<FetchAddressLoadingEvent>(
      (event, emit) => emit(FetchAddressLoadingState()),
    );
    on<FetchAddressEvent>(
      (event, emit) => emit(FetchAddressState(event.addresslist)),
    );
    on<SelectAddressEvent>(
      (event, emit) {
        emit(FetchAddressLoadingState());
        emit(SelectAddressState(addressData: event.addressdata));
      },
    );
  }
}
