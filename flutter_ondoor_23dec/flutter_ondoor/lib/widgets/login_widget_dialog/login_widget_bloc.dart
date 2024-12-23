import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondoor/widgets/login_widget_dialog/login_widget_events.dart';
import 'package:ondoor/widgets/login_widget_dialog/login_widget_state.dart';

class LoginWidgetBloc extends Bloc<LoginWidgetEvent, LoginWidgetState> {
  LoginWidgetBloc() : super(LoginWidgetInitialState()) {
    on<LoginWidgetInitialEvent>(
      (event, emit) {
        emit(LoginWidgetInitialState());
      },
    );
    on<LoginWidgetFocusEvent>(
      (event, emit) {
        emit(LoginWidgetFocusState(focusNode: event.focusNode));
      },
    );
    on<LoginWidgetPageChangeEvent>(
      (event, emit) {
        emit(LoginWidgetPageChangeState(pageIndex: event.pageIndex));
      },
    );
  }
}
