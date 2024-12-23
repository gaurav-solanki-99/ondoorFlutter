import 'package:bloc/bloc.dart';
import 'package:ondoor/screens/AuthScreen/Register/RegisterdBloc/registerd_event.dart';
import 'package:ondoor/screens/AuthScreen/Register/RegisterdBloc/registerd_state.dart';

class RegisterdBloc extends Bloc<RegisterdEvent, RegisterdState> {
  RegisterdBloc() : super(RegisterdInitial()) {
    on<RegisterdEvent>((event, emit) {});

    on<FormStateEvent>((event, emit) {
      emit(FormStateState(isvalid: event.isvalid));
    });
    on<RegisterNullEvent>((event, emit) {
      emit(RegisterNullState());
    });

    on<RegisterFormFillEvent>((event, emit) {
      emit(RegisterFormFillState(
          name: event.name,
          mobile: event.mobile,
          email: event.email));
    });
  }
}
