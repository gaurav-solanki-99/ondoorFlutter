import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondoor/screens/order_status_screen/order_status_bloc/order_status_events.dart';
import 'package:ondoor/screens/order_status_screen/order_status_bloc/order_status_state.dart';

class OrderStatusBloc extends Bloc<OrderStatusEvent, OrderStatusState> {
  OrderStatusBloc() : super(OrderStatusInitialState()) {
    on<OrderStatusInitialEvent>(
      (event, emit) {
        emit(OrderStatusNullState());
        emit(OrderStatusInitialState());
      },
    );
    on<OrderStatusNullEvent>(
      (event, emit) {
        emit(OrderStatusNullState());
      },
    );
    on<OrderStatusAnimationEvent>(
      (event, emit) {
        emit(OrderStatusNullState());
        emit(OrderStatusAnimationState(
            animation: event.animation,
            slideAnimation: event.slideAnimation,
            dataAppearenceAnimation: event.dataAppearenceAnimation));
      },
    );
  }
}
